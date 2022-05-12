<?php

namespace XF\Import\Data;

class Forum extends AbstractNode
{
	protected $watchers = [];

	public function getImportType()
	{
		return 'forum';
	}

	public function getEntityShortName()
	{
		return 'XF:Forum';
	}

	public function addForumWatcher($userId, array $userConfig)
	{
		$this->watchers[$userId] = $userConfig;
	}

	protected function preSave($oldId)
	{
		if (!$this->forum_type_id)
		{
			$this->forum_type_id = 'discussion';
			$this->type_config = [];
		}

		return parent::preSave($oldId);
	}

	protected function postSave($oldId, $newId)
	{
		if ($this->watchers)
		{
			/** @var \XF\Import\DataHelper\Forum $forumHelper */
			$forumHelper = $this->dataManager->helper('XF:Forum');
			$forumHelper->importForumWatchBulk($newId, $this->watchers);
		}
	}
}