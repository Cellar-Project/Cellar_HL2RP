<?php

namespace XF\Cli\Command\Designer;

use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Helper\ProgressBar;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use XF\Cli\Command\StyleArchiveTrait;

use function count;

abstract class AbstractImportCommand extends Command
{
	use RequiresDesignerModeTrait, StyleArchiveTrait;

	// [command, name, entity, dir]
	abstract protected function getContentTypeDetails();

	abstract protected function getTitleIdMap($typeDir, $styleId);

	abstract public function importData($typeDir, $fileName, $path, $content, \XF\Entity\Style $style, array $metadata);

	protected function configure()
	{
		$contentType = $this->getContentTypeDetails();

		$this
			->setName("xf-designer:import-$contentType[command]")
			->setDescription("Imports $contentType[name] from specified designer mode files")
			->addArgument(
				'designer-mode',
				InputArgument::REQUIRED,
				'Designer mode ID'
			);
	}

	/**
	 * @var \XF\Entity\Style
	 */
	protected $style;

	protected function execute(InputInterface $input, OutputInterface $output)
	{
		return $this->executeType($this->getContentTypeDetails(), $input, $output);
	}

	protected function executeType(array $contentType, InputInterface $input, OutputInterface $output)
	{
		$style = $this->getStyleByDesignerModeInput($input, $output);

		$start = microtime(true);

		$output->writeln("Importing $contentType[name]...");

		$designerOutput = \XF::app()->designerOutput();
		$typeMetadata = $designerOutput->getMetadata($contentType['dir'], $style->designer_mode);
		$files = $designerOutput->getAvailableTypeFiles($contentType['dir'], $style->designer_mode);

		$map = $this->getTitleIdMap($contentType['dir'], $style->style_id);

		$printName = ($output->getVerbosity() >= OutputInterface::VERBOSITY_VERBOSE);

		if (!$printName)
		{
			$progress = new ProgressBar($output, count($files));
			$progress->start();
		}
		else
		{
			$progress = null;
		}

		foreach ($files AS $fileName => $path)
		{
			if ($printName)
			{
				$output->writeln("\t$fileName");
			}
			else
			{
				$progress->advance();
			}

			$metadata = $typeMetadata[$fileName] ?? [];
			$content = file_get_contents($path);

			$title = $this->importData($contentType['dir'], $fileName, $path, $content, $style, $metadata);

			unset($map[$title]);
		}

		if (!$printName)
		{
			$progress->finish();
			$output->writeln("");
		}

		$this->deleteRemaining($contentType['dir'], $map, $contentType['entity']);

		\XF::triggerRunOnce();

		$output->writeln(sprintf(ucfirst($contentType['name']) . " imported. (%.02fs)", microtime(true) - $start));

		return 0;
	}

	protected function deleteRemaining($typeDir, array $map, $entity)
	{
		if ($map)
		{
			$old = \XF::em()->findByIds($entity, $map);
			foreach ($old AS $entity)
			{
				$entity->delete();
			}
		}
	}
}