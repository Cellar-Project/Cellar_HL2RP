<?php

namespace XF\Repository;

use XF\Mvc\Entity\Finder;
use XF\Mvc\Entity\Repository;

class CodeEvent extends Repository
{
	/**
	 * @return Finder
	 */
	public function findEventsForList()
	{
		return $this->finder('XF:CodeEvent')->order(['event_id']);
	}

	public function getEventTitlePairs()
	{
		return $this->findEventsForList()
			->fetch()
			->pluckNamed('event_id', 'event_id');
	}
}