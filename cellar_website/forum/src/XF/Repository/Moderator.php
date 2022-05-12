<?php

namespace XF\Repository;

use XF\Mvc\Entity\AbstractCollection;
use XF\Mvc\Entity\Finder;
use XF\Mvc\Entity\Repository;

use function count;

class Moderator extends Repository
{
	/**
	 * @return Finder
	 */
	public function findModeratorsForList($isSuperModerator = false)
	{
		$finder = $this->finder('XF:Moderator')
			->with('User', true)
			->order('User.username');

		if ($isSuperModerator)
		{
			$finder->where('is_super_moderator', 1);
		}

		return $finder;
	}

	/**
	 * @return Finder
	 */
	public function findContentModeratorsForList()
	{
		return $this->finder('XF:ModeratorContent')
			->with(['User', 'Moderator'])
			->order(['content_id', 'content_type']);
	}

	/**
	 * @param AbstractCollection $contentModerators
	 * @param int $limit
	 *
	 * @return array
	 */
	public function getGroupedContentModeratorsForList(AbstractCollection $contentModerators, $limit = null)
	{
		$groupedModerators = [];

		foreach ($contentModerators AS $contentModerator)
		{
			/** @var \XF\Entity\ModeratorContent $contentModerator */

			$userId = $contentModerator->user_id;

			if ($limit && isset($groupedModerators[$userId]) && count($groupedModerators[$userId]) >= $limit)
			{
				continue;
			}

			$groupedModerators[$userId][] = $contentModerator;
		}

		return $groupedModerators;
	}

	public function getContentModeratorTotals()
	{
		return $this->db()->fetchPairs("
			SELECT user_id, COUNT(*)
			FROM xf_moderator_content
			GROUP BY user_id
		");
	}

	public function getModeratorPermissionData($contentType = null)
	{
		/** @var \XF\Repository\Permission $permissionRepo */
		$permissionRepo = $this->repository('XF:Permission');

		$contentHandler = $contentType ? $permissionRepo->getPermissionHandler($contentType) : null;

		$permissions = $permissionRepo->findPermissionsForList()
			->where('permission_type', 'flag') // all that's supported
			->fetch();
		$interfaceGroups = $permissionRepo->findInterfaceGroupsForList()->where('is_moderator', 1)->fetch();

		$globalPermissions = [];
		$contentPermissions = [];

		foreach ($permissions AS $key => $permission)
		{
			if (!isset($interfaceGroups[$permission->interface_group_id]))
			{
				continue;
			}

			if ($contentHandler && $contentHandler->isValidPermission($permission))
			{
				$contentPermissions[$permission->interface_group_id][] = $permission;
			}
			else
			{
				$globalPermissions[$permission->interface_group_id][] = $permission;
			}
		}

		return [
			'interfaceGroups' => $interfaceGroups,
			'contentPermissions' => $contentPermissions,
			'globalPermissions' => $globalPermissions
		];
	}

	/**
	 * @return \XF\Moderator\AbstractModerator[]
	 */
	public function getModeratorHandlers()
	{
		$handlers = [];

		foreach (\XF::app()->getContentTypeField('moderator_handler_class') AS $contentType => $handlerClass)
		{
			if (class_exists($handlerClass))
			{
				$handlerClass = \XF::extendClass($handlerClass);
				$handlers[$contentType] = new $handlerClass();
			}
		}

		return $handlers;
	}

	/**
	 * @param string $type
	 *
	 * @return \XF\Moderator\AbstractModerator|null
	 */
	public function getModeratorHandler($type)
	{
		$handlerClass = \XF::app()->getContentTypeFieldValue($type, 'moderator_handler_class');
		if (!$handlerClass)
		{
			return null;
		}

		if (!class_exists($handlerClass))
		{
			return null;
		}

		$handlerClass = \XF::extendClass($handlerClass);
		return new $handlerClass();
	}
}