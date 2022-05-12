<?php

namespace XF\Cli\Command\Development;

class ExportTemplateModifications extends AbstractExportCommand
{
	protected function getContentTypeDetails()
	{
		return [
			'name' => 'template modifications',
			'command' => 'template-modifications',
			'entity' => 'XF:TemplateModification'
		];
	}
}