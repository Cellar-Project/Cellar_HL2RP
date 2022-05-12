<?php

namespace XF\Api\Controller;

use XF\Mvc\Entity\Entity;
use XF\Mvc\ParameterBag;

use function intval;

/**
 * @api-group Forums
 */
class Forum extends AbstractController
{
	protected function preDispatchController($action, ParameterBag $params)
	{
		if (strtolower($action) === 'postmarkread')
		{
			// The logic with forum read marking is similar to thread read marking. Note that our
			// node:write scopes generally represent admin-level actions and this is far from that.
			// Indeed, it's minor enough that creating a separate scope seems unnecessary so we shall
			// tie it to the same permission a thread read marking.
			$this->assertApiScope('thread:read');
		}
		else
		{
			$this->assertApiScopeByRequestMethod('node');
		}
	}

	/**
	 * @api-desc Gets information about the specified forum
	 *
	 * @api-in bool $with_threads If true, gets a page of threads in this forum
	 * @api-in int $page
	 *
	 * @api-out Forum $forum
	 * @api-see self::getThreadsInForumPaginated()
	 */
	public function actionGet(ParameterBag $params)
	{
		$forum = $this->assertViewableForum($params->node_id);

		if ($this->filter('with_threads', 'bool'))
		{
			$this->assertApiScope('thread:read');
			$threadData = $this->getThreadsInForumPaginated($forum, $this->filterPage());
		}
		else
		{
			$threadData = [];
		}

		$result = [
			'forum' => $forum->toApiResult(Entity::VERBOSITY_VERBOSE)
		];
		$result += $threadData;

		return $this->apiResult($result);
	}

	/**
	 * @api-desc Gets a page of threads from the specified forum.
	 *
	 * @api-see self::getThreadsInForumPaginated()
	 */
	public function actionGetThreads(ParameterBag $params)
	{
		$this->assertApiScope('thread:read');

		$forum = $this->assertViewableForum($params->node_id);

		$threadData = $this->getThreadsInForumPaginated($forum, $this->filterPage());

		return $this->apiResult($threadData);
	}

	/**
	 * @api-see XF\Api\ControllerPlugin\Thread::applyThreadListFilters
	 * @api-see XF\Api\ControllerPlugin\Thread::applyThreadListSort
	 *
	 * @api-out Thread[] $threads Threads on this page
	 * @api-out pagination $pagination Pagination information
	 * @api-out Thread[] $sticky If on page 1, a list of sticky threads in this forum. Does not count towards the per page limit.
	 */
	protected function getThreadsInForumPaginated(\XF\Entity\Forum $forum, $page = 1, $perPage = null)
	{
		$perPage = intval($perPage);
		if ($perPage <= 0)
		{
			$perPage = $this->options()->discussionsPerPage;
		}

		$threadFinder = $this->setupThreadFinder($forum, $filters, $sort);

		if ($page == 1)
		{
			$stickyThreadFinder = clone $threadFinder;

			/** @var \XF\Entity\Thread[]|\XF\Mvc\Entity\AbstractCollection $stickyThreads */
			$stickyThreads = $stickyThreadFinder->where('sticky', 1)->fetch();
		}
		else
		{
			$stickyThreads = null;
		}

		// applying this here to avoid limiting for sticky threads
		if (!isset($filters['last_days']) && $forum->list_date_limit_days)
		{
			$threadFinder->where('last_post_date', '>=', \XF::$time - ($forum->list_date_limit_days * 86400));
		}

		$threadFinder->where('sticky', 0)
			->limitByPage($page, $perPage);

		$totalThreads = $threadFinder->total();

		$this->assertValidApiPage($page, $perPage, $totalThreads);

		/** @var \XF\Entity\Thread[]|\XF\Mvc\Entity\AbstractCollection $threads */
		$threads = $threadFinder->fetch();
		if (\XF::isApiCheckingPermissions())
		{
			$threads = $threads->filterViewable();
		}

		$threadResults = $threads->toApiResults();
		$this->adjustThreadListApiResults($forum, $threadResults);

		$return = [
			'threads' => $threadResults,
			'pagination' => $this->getPaginationData($threadResults, $page, $perPage, $totalThreads)
		];
		if ($stickyThreads !== null)
		{
			$return['sticky'] = $stickyThreads->toApiResults();
			$this->adjustThreadListApiResults($forum, $return['sticky']);
		}

		return $return;
	}

	/**
	 * @param \XF\Entity\Forum $forum
	 * @param array $filters List of filters that have been applied from input
	 * @param array|null $sort If array, sort that has been applied from input
	 *
	 * @return \XF\Finder\Thread
	 */
	protected function setupThreadFinder(\XF\Entity\Forum $forum, &$filters = [], &$sort = null)
	{
		$threadFinder = $this->repository('XF:Thread')->findThreadsForApi($forum);

		/** @var \XF\Api\ControllerPlugin\Thread $threadPlugin */
		$threadPlugin = $this->plugin('XF:Api:Thread');
		$filters = $threadPlugin->applyThreadListFilters($threadFinder, $forum);
		$sort = $threadPlugin->applyThreadListSort($threadFinder, $forum);

		return $threadFinder;
	}

	protected function adjustThreadListApiResults(\XF\Entity\Forum $forum, \XF\Api\Result\EntityResultInterface $result)
	{
		$result->skipRelation('Forum');
	}

	/**
	 * @api-desc Marks the forum as read up until the specified time. This cannot mark a forum as unread or
	 *  move the read marking date to an earlier point in time.
	 *
	 * @api-in int $date Unix timestamp to mark the forum read to. If not specified, defaults to the current time.
	 *
	 * @api-out true $success
	 */
	public function actionPostMarkRead(ParameterBag $params)
	{
		$this->assertRegisteredUser();

		$forum = $this->assertViewableForum($params->node_id);

		$readDate = $this->filter('date', '?uint');
		if (!$readDate || $readDate > \XF::$time)
		{
			$readDate = null;
		}

		$this->repository('XF:Forum')->markForumReadByVisitor($forum, $readDate);

		return $this->apiSuccess();
	}

	/**
	 * @param int $id
	 * @param string|array $with
	 *
	 * @return \XF\Entity\Forum
	 *
	 * @throws \XF\Mvc\Reply\Exception
	 */
	protected function assertViewableForum($id, $with = 'api')
	{
		return $this->assertViewableApiRecord('XF:Forum', $id, $with);
	}
}