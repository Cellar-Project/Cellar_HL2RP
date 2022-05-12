<?php

namespace XF\Job;

class PhraseRebuild extends AbstractJob
{
	protected $defaultData = [
		'steps' => 0,
		'phraseId' => 0,
		'batch' => 5000,
		'mapped' => false,
		'skipCore' => false
	];

	public function run($maxRunTime)
	{
		$start = microtime(true);

		if (!$this->data['mapped'])
		{
			/** @var \XF\Service\Phrase\Rebuild $rebuildService */
			$rebuildService = $this->app->service('XF:Phrase\Rebuild');
			$rebuildService->rebuildFullPhraseMap();

			/** @var \XF\Service\Phrase\Group $groupService */
			$groupService = $this->app->service('XF:Phrase\Group');
			$groupService->compileAllPhraseGroups();

			$this->data['mapped'] = true;
		}

		$this->data['steps']++;

		$db = $this->app->db();
		$em = $this->app->em();
		$app = \XF::app();

		if ($this->data['skipCore'])
		{
			$skipCoreSql = "AND (addon_id <> 'XF' OR language_id > 0)";
		}
		else
		{
			$skipCoreSql = '';
		}

		$phraseIds = $db->fetchAllColumn($db->limit(
			"
				SELECT phrase_id
				FROM xf_phrase
				WHERE phrase_id > ?
					{$skipCoreSql}
				ORDER BY phrase_id
			", $this->data['batch']
		), $this->data['phraseId']);
		if (!$phraseIds)
		{
			$app->repository('XF:Language')->rebuildLanguageCache();

			return $this->complete();
		}

		/** @var \XF\Service\Phrase\Compile $compileService */
		$compileService = $app->service('XF:Phrase\Compile');

		$done = 0;

		foreach ($phraseIds AS $phraseId)
		{
			$this->data['phraseId'] = $phraseId;

			/** @var \XF\Entity\Phrase $phrase */
			$phrase = $em->find('XF:Phrase', $phraseId);
			if (!$phrase)
			{
				continue;
			}

			$phrase->getBehavior('XF:DevOutputWritable')->setOption('write_dev_output', false);

			$compileService->recompile($phrase);

			$done++;

			if (microtime(true) - $start >= $maxRunTime)
			{
				break;
			}
		}

		// decache to reduce memory usage
		\XF::em()->clearEntityCache('XF:Phrase');

		$this->data['batch'] = $this->calculateOptimalBatch($this->data['batch'], $done, $start, $maxRunTime, 5000);

		return $this->resume();
	}

	public function getStatusMessage()
	{
		$actionPhrase = \XF::phrase('rebuilding');
		$typePhrase = \XF::phrase('phrases');
		return sprintf('%s... %s %s', $actionPhrase, $typePhrase, str_repeat('. ', $this->data['steps']));
	}

	public function canCancel()
	{
		return false;
	}

	public function canTriggerByChoice()
	{
		return false;
	}
}