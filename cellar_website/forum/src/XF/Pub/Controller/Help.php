<?php

namespace XF\Pub\Controller;

use XF\Mvc\ParameterBag;
use XF\Mvc\Reply\View;

use function call_user_func_array;

class Help extends AbstractController
{
	protected $_pagesCache = null;

	public function actionIndex(ParameterBag $params)
	{
		$pageName = $params->get('page_name', '');
		$pageName = str_replace('/', '', $pageName);

		if ($pageName !== '')
		{
			return $this->handleHelpPage($pageName);
		}

		$viewParams = [
			'pages' => $this->getActiveHelpPages()
		];

		return $this->addWrapperParams(
			$this->view('XF:Help\Index', 'help_index', $viewParams),
			''
		);
	}

	protected function handleHelpPage($pageName)
	{
		/** @var \XF\Entity\HelpPage $page */
		$page = $this->finder('XF:HelpPage')
			->where('page_name', $pageName)
			->where('active', 1)
			->whereAddOnActive()
			->fetchOne();
		if (!$page)
		{
			return $this->error(\XF::phrase('requested_page_not_found'), 404);
		}

		$this->assertCanonicalUrl($this->buildLink('help', $page));

		$viewParams = [
			'page' => $page,
			'templateName' => 'public:_help_page_' . $page->page_id
		];
		$view = $this->view('XF:Help\Page', 'help_page', $viewParams);

		if ($page->hasCallback())
		{
			call_user_func_array([$page->callback_class, $page->callback_method], [$this, &$view]);
		}

		return $this->addWrapperParams($view, $pageName);
	}

	protected function addWrapperParams(View $view, $selected)
	{
		if (!$view->getParam('pages'))
		{
			$view->setParam('pages', $this->getActiveHelpPages());
		}

		$view->setParams([
			'pageSelected' => $selected,
			'tosUrl' => $this->app->container('tosUrl')
		]);

		return $view;
	}

	/**
	 * @return \XF\Mvc\Entity\ArrayCollection
	 */
	protected function getActiveHelpPages()
	{
		$privacyPolicyUrl = $this->app->container('privacyPolicyUrl');
		$tosUrl = $this->app->container('tosUrl');

		return $this->getHelpPageRepo()
			->findActiveHelpPages()
			->fetch()
			->filter(function(\XF\Entity\HelpPage $page) use($privacyPolicyUrl, $tosUrl)
			{
				if ($page->page_id == 'privacy_policy')
				{
					return ($privacyPolicyUrl ? true : false);
				}
				else if ($page->page_id == 'terms')
				{
					return ($tosUrl ? true : false);
				}
				else
				{
					return true;
				}
			});
	}

	/**
	 * @return \XF\Repository\HelpPage
	 */
	protected function getHelpPageRepo()
	{
		return $this->repository('XF:HelpPage');
	}

	public function assertNotBanned() {}
	public function assertNotRejected($action) {}
	public function assertNotDisabled($action) {}

	public function assertBoardActive($action) {}
	public function assertViewingPermissions($action) {}
	public function assertTfaRequirement($action) {}

	// in case these have custom URL which is a help page
	public function assertPolicyAcceptance($action) {}

	public static function getActivityDetails(array $activities)
	{
		return \XF::phrase('viewing_help');
	}
}