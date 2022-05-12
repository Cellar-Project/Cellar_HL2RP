<?php

namespace XF\Cli\Command\Development;

use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use XF\Mvc\Entity\Entity;

use function count, is_array, is_bool, is_string;

class GenerateSchemaEntity extends Command
{
	use RequiresDevModeTrait;

	protected function configure()
	{
		$this
			->setName('xf-dev:generate-schema-entity')
			->setDescription('Generates schema code from an entity')
			->addArgument(
				'id',
				InputArgument::REQUIRED,
				'Identifier for the Entity (Prefix:Type format)'
			);
	}

	protected function execute(InputInterface $input, OutputInterface $output)
	{
		$id = $input->getArgument('id');
		if (!$id || !preg_match('#^[a-z0-9_\\\\]+:[a-z0-9_\\\\]+$#i', $id))
		{
			$output->writeln("Identifier in the form of Prefix:Type must be provided.");
			return 1;
		}

		try
		{
			$entity = \XF::em()->create($id);
		}
		catch (\Exception $e)
		{
			$class = \XF::stringToClass($id, '%s\Entity\%s');
			$output->writeln("Entity class for $id ($class) could not be created.");
			return 2;
		}

		$structure = $entity->structure();

		$table = $structure->table;
		$primaryKey = $structure->primaryKey;
		$columns = $structure->columns;

		$primaryKeySet = false;
		$columnStrings = [];

		foreach ($columns AS $columnName => $column)
		{
			$type = $this->resolveTypeDefaults($entity, $column['type'], $unsigned, $allowedDefault);

			$length = null;
			if (isset($column['maxLength']))
			{
				$length = $column['maxLength'];
			}
			else
			{
				if ($type == 'varchar')
				{
					$type = 'text';
					$allowedDefault = false;
				}
			}

			$values = null;
			if (isset($column['allowedValues']))
			{
				$type = 'enum';
				if (count($column['allowedValues']) > 1)
				{
					$values = '[\'' . implode('\', \'', $column['allowedValues']) . '\']';
				}
				else
				{
					$values = '\'' . $column['allowedValues'] . '\'';
				}

				$length = null;
			}

			$string = '$table->addColumn(\'' . $columnName . '\', \'' . $type . '\'' . ($length ? ', ' . $length : '') . ')';

			if ($values)
			{
				$string .= '->values(' . $values . ')';
			}

			if ($unsigned !== null)
			{
				if ($unsigned === false)
				{
					$string .= '->unsigned(false)';
				}
			}

			if (isset($column['nullable']) && !isset($column['autoIncrement']))
			{
				$string .= '->nullable()';
			}

			if (isset($column['default']) && $allowedDefault)
			{
				if ($column['default'] === \XF::$time)
				{
					$default = 0;
				}
				else if (is_string($column['default']))
				{
					$default = '\'' . $column['default'] . '\'';
				}
				else if (is_bool($column['default']))
				{
					$default = ($column['default'] === true) ? 1 : 0;
				}
				else
				{
					$default = $column['default'];
				}
				$string .= '->setDefault(' . $default . ')';
			}

			if (isset($column['autoIncrement']))
			{
				$string .= '->autoIncrement()';
				$primaryKeySet = true;
			}

			$string .= ';';

			$columnStrings[] = $string;
		}

		$primaryKeyString = '';
		if (!$primaryKeySet && $primaryKey)
		{
			$primaryKeyString = "\n\t";
			if (is_array($primaryKey) && count($primaryKey) > 1)
			{
				$primaryKeyString .= '$table->addPrimaryKey([\'' . implode('\', \'', $primaryKey) . '\']);';
			}
			else
			{
				$primaryKeyString .= '$table->addPrimaryKey(\'' . $primaryKey . '\');';
			}
		}

		$columnOutput = implode("\n\t", $columnStrings);

		$sm = <<< FUNCTION
\$this->createTable('$table', function (\\XF\Db\Schema\Create \$table)
{
	{$columnOutput}{$primaryKeyString}
});
FUNCTION;

		$output->writeln(["", $sm, ""]);

		return 0;
	}

	protected function resolveTypeDefaults(Entity $entity, $type, &$unsigned = null, &$allowedDefault = true)
	{
		$unsigned = null;
		$allowedDefault = true;

		switch ($type)
		{
			case $entity::INT:
				$unsigned = false;
				return 'int';

			case $entity::UINT:
				return 'int';

			case $entity::FLOAT:
				return 'float';

			case $entity::BOOL:
				return 'tinyint';

			case $entity::STR:
				return 'varchar';

			case $entity::BINARY:
				return 'varbinary';

			case $entity::SERIALIZED:
			case $entity::SERIALIZED_ARRAY:
			case $entity::JSON:
			case $entity::JSON_ARRAY:
			case $entity::LIST_LINES:
			case $entity::LIST_COMMA:
				$allowedDefault = false;
				return 'blob';
		}

		throw new \InvalidArgumentException('Could not infer type.');
	}
}