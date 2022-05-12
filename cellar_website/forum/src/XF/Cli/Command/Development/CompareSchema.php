<?php

namespace XF\Cli\Command\Development;

use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\OutputInterface;

use function is_array;

class CompareSchema extends Command
{
	use RequiresDevModeTrait;

	protected function configure()
	{
		$this
			->setName('xf-dev:compare-schema')
			->setDescription('Compares database schemas for consequential differences')
			->addArgument(
				'db',
				InputArgument::REQUIRED,
				'Database to compare against'
			)
			->addArgument(
				'db2',
				InputArgument::OPTIONAL,
				'Second database to compare against (defaults to database in config.php if not specified)'
			)
			->addOption(
				'ignore-collation',
				null,
				InputOption::VALUE_NONE,
				'If specified, column collations will not be compared'
			)
			->addOption(
				'ignore-default',
				null,
				InputOption::VALUE_NONE,
				'If specified, column defaults will not be compared'
			)
			->addOption(
				'table-prefix',
				null,
				InputOption::VALUE_REQUIRED,
				'If specified, only tables matching this prefix will be compared.'
			);
	}

	protected function execute(InputInterface $input, OutputInterface $output)
	{
		$config = \XF::config();

		if ($input->getArgument('db2'))
		{
			$db1 = $input->getArgument('db');
			$db2 = $input->getArgument('db2');
		}
		else
		{
			$db1 = $config['db']['dbname'];
			$db2 = $input->getArgument('db');
		}

		if ($db1 == $db2)
		{
			$output->writeln("Attempting to compare $db1 with itself.");
			return 1;
		}

		$compareOptions = [
			'compareCollation' => $input->getOption('ignore-collation') ? false : true,
			'compareDefault' => $input->getOption('ignore-default') ? false : true,
			'tablePrefix' => $input->getOption('table-prefix') ?: ''
		];

		$errors = $this->getComparison($db1, $db2, $compareOptions);
		if ($errors)
		{
			$output->writeln("<error>The following differences were found (changing $db1 to match $db2):</error>");
			$output->writeln("");
			$this->printComparisonErrors($output, $errors);
			$output->writeln("");
			$output->writeln("References are how to change $db1 to match $db2.");
		}
		else
		{
			$output->writeln("<info>There are no differences between $db1 and $db2.</info>");
		}

		return 0;
	}

	protected function getComparison($db1, $db2, array $options = [])
	{
		$options = array_replace([
			'compareCollation' => true,
			'compareDefault' => true,
			'tablePrefix' => ''
		], $options);

		$db = \XF::db();
		$tablePrefix = $options['tablePrefix'];

		$tables = $db->fetchAll('
			SELECT *
			FROM information_schema.tables
			WHERE TABLE_SCHEMA IN (' . $db->quote($db1) . ', ' . $db->quote($db2) . ')
		');
		$db1Tables = [];
		$db2Tables = [];
		foreach ($tables AS $table)
		{
			$tableName = $table['TABLE_NAME'];
			if ($tablePrefix && strpos($tableName, $tablePrefix) !== 0)
			{
				continue;
			}

			if ($table['TABLE_SCHEMA'] == $db1)
			{
				$db1Tables[$tableName] = $table;
			}
			else
			{
				$db2Tables[$tableName] = $table;
			}
		}

		$columns = $db->fetchAll('
			SELECT *
			FROM information_schema.columns
			WHERE TABLE_SCHEMA IN (' . $db->quote($db1) . ', ' . $db->quote($db2) . ')
		');
		$db1Columns = [];
		$db2Columns = [];
		foreach ($columns AS $column)
		{
			$tableName = $column['TABLE_NAME'];
			if ($tablePrefix && strpos($tableName, $tablePrefix) !== 0)
			{
				continue;
			}

			$columnName = $column['COLUMN_NAME'];

			if ($column['TABLE_SCHEMA'] == $db1)
			{
				$db1Columns[$tableName][$columnName] = $column;
			}
			else
			{
				$db2Columns[$tableName][$columnName] = $column;
			}
		}

		$columnCompares = [
			'IS_NULLABLE', 'COLUMN_TYPE'
		];
		if ($options['compareDefault'])
		{
			$columnCompares[] = 'COLUMN_DEFAULT';
		}
		if ($options['compareCollation'])
		{
			$columnCompares[] = 'COLLATION_NAME';
		}

		$errors = [];

		foreach ($db1Tables AS $tableName => $table)
		{
			if (!isset($db2Tables[$tableName]))
			{
				$errors[$tableName] = "REMOVE $tableName";
				continue;
			}

			foreach ($db1Columns[$tableName] AS $columnName => $column)
			{
				if (!isset($db2Columns[$tableName][$columnName]))
				{
					$errors[$tableName][$columnName] = "REMOVE $tableName.$columnName";
					continue;
				}

				$column2 = $db2Columns[$tableName][$columnName];

				foreach ($columnCompares AS $compare)
				{
					if ($column[$compare] !== $column2[$compare])
					{
						$column1Print = ($column[$compare] === NULL ? 'NULL' : $column[$compare]);
						$column2Print = ($column2[$compare] === NULL ? 'NULL' : $column2[$compare]);

						$errors[$tableName][$columnName][$compare] =
							"CHANGE $tableName.$columnName $compare: $column1Print --> $column2Print";
					}
				}
			}

			foreach ($db2Columns[$tableName] AS $columnName => $column)
			{
				if (!isset($db1Columns[$tableName][$columnName]))
				{
					$errors[$tableName][$columnName] = "ADD $tableName.$columnName";
					continue;
				}
			}
		}

		foreach ($db2Tables AS $tableName => $table)
		{
			if (!isset($db1Tables[$tableName]))
			{
				$errors[$tableName] = "ADD $tableName";
				continue;
			}
		}

		$indexes = $db->fetchAll('
			SELECT *
			FROM information_schema.statistics
			WHERE TABLE_SCHEMA IN (' . $db->quote($db1) . ', ' . $db->quote($db2) . ')
		');
		$db1Indexes = [];
		$db2Indexes = [];
		foreach ($indexes AS $index)
		{
			$tableName = $index['TABLE_NAME'];
			if ($tablePrefix && strpos($tableName, $tablePrefix) !== 0)
			{
				continue;
			}

			$indexName = $index['INDEX_NAME'];
			$columnName = $index['COLUMN_NAME'];
			$indexData = [
				'sequence' => $index['SEQ_IN_INDEX'],
				'non_unique' => $index['NON_UNIQUE']
			];

			if ($index['TABLE_SCHEMA'] == $db1)
			{
				$db1Indexes[$tableName][$indexName][$columnName] = $indexData;
			}
			else
			{
				$db2Indexes[$tableName][$indexName][$columnName] = $indexData;
			}
		}

		foreach ($db1Indexes AS $tableName => $indexes)
		{
			if (!isset($db2Indexes[$tableName]))
			{
				// whole table is missing, would've already caught this
				continue;
			}

			$db2TableIndexes = $db2Indexes[$tableName];

			foreach ($indexes AS $indexName => $indexColumns)
			{
				if (!isset($db2TableIndexes[$indexName]))
				{
					$errors[$tableName]["index:$indexName"] = "REMOVE INDEX $tableName.$indexName";
					continue;
				}

				$db2Index = $db2TableIndexes[$indexName];

				foreach ($indexColumns AS $columnName => $indexColumnConfig)
				{
					if (!isset($db2Index[$columnName]))
					{
						$errors[$tableName]["index:$indexName.$columnName"] = "REMOVE INDEX COLUMN $tableName.$indexName:$columnName";
						continue;
					}

					if ($db2Index[$columnName] != $indexColumnConfig)
					{
						$errors[$tableName]["index:$indexName.$columnName"] = "INDEX COLUMN DIFFERS $tableName.$indexName:$columnName";
						continue;
					}
				}

				foreach ($db2Index AS $columnName => $indexColumnConfig)
				{
					if (!isset($indexColumns[$columnName]))
					{
						$errors[$tableName]["index:$indexName.$columnName"] = "ADD INDEX COLUMN $tableName.$indexName:$columnName";
						continue;
					}
				}
			}

			foreach ($db2TableIndexes AS $indexName => $indexColumns)
			{
				if (!isset($indexes[$indexName]))
				{
					$errors[$tableName]["index:$indexName"] = "ADD INDEX $tableName.$indexName";
					continue;
				}
			}
		}

		return $errors;
	}

	protected function printComparisonErrors(OutputInterface $output, array $errors)
	{
		ksort($errors);
		foreach ($errors AS $error)
		{
			if (is_array($error))
			{
				$this->printComparisonErrors($output, $error);
			}
			else
			{
				$output->writeln(" * $error");
			}
		}
	}
}