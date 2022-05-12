<?php

namespace XF\Cli\Command\Development;

class ImportAdminNavigation extends AbstractImportCommand
{
	protected function getContentTypeDetails()
	{
		return [
			'name' => 'admin navigation',
			'command' => 'admin-navigation',
			'dir' => 'admin_navigation',
			'entity' => 'XF:AdminNavigation'
		];
	}

	protected function getTitleIdMap($typeDir, $addOnId)
	{
		return \XF::db()->fetchPairs("
			SELECT navigation_id, navigation_id
			FROM xf_admin_navigation
			WHERE addon_id = ?
		", $addOnId);
	}
}