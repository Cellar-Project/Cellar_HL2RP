<?php

namespace XF\Template;

class Template implements \JsonSerializable
{
	/**
	 * @var Templater
	 */
	protected $templater;

	protected $name;
	protected $params = [];

	public function __construct(Templater $templater, $name, array $params = [])
	{
		$this->templater = $templater;
		$this->name = $name;
		$this->params = $params;
	}

	public function render()
	{
		return $this->templater->renderTemplate($this->name, $this->params);
	}

	public function __toString()
	{
		try
		{
			return $this->render();
		}
		catch (\Throwable $e)
		{
			\XF::logException($e, false, 'Template rendering error: ');
			return '';
		}
	}

	#[\ReturnTypeWillChange]
	public function jsonSerialize()
	{
		return $this->__toString();
	}
}