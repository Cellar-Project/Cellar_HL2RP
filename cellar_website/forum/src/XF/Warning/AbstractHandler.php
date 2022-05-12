<?php

namespace XF\Warning;

use XF\Entity\Warning;
use XF\Mvc\Entity\Entity;

use function get_class;

abstract class AbstractHandler
{
	protected $contentType;

	public function __construct($contentType)
	{
		$this->contentType = $contentType;
	}

	abstract public function getStoredTitle(Entity $entity);
	abstract public function getDisplayTitle($title);
	abstract public function getContentForConversation(Entity $entity);
	abstract public function getContentUser(Entity $entity);
	abstract public function canViewContent(Entity $entity, &$error = null);
	abstract public function onWarning(Entity $entity, Warning $warning);
	abstract public function onWarningRemoval(Entity $entity, Warning $warning);

	public function getContentUrl(Entity $entity, $canonical = false)
	{
		if ($entity instanceof \XF\Entity\LinkableInterface)
		{
			return $entity->getContentUrl($canonical);
		}

		throw new \LogicException(
			'Implement XF\Entity\LinkableInterface for ' . get_class($entity)
			. ' or override ' . get_class($this) . '::getContentUrl'
		);
	}

	public function getAvailableContentActions(Entity $entity)
	{
		return [
			'public' => $this->canWarnPublicly($entity),
			'delete' => $this->canDeleteContent($entity)
		];
	}

	public function takeContentAction(Entity $entity, $action, array $options)
	{
		// do nothing by default since nothing is supported
	}

	protected function canWarnPublicly(Entity $entity)
	{
		return false;
	}

	protected function canDeleteContent(Entity $entity)
	{
		return false;
	}

	public function getEntityWith()
	{
		return [];
	}

	public function getContent($id)
	{
		return \XF::app()->findByContentType($this->contentType, $id);
	}

	public function getContentType()
	{
		return $this->contentType;
	}
}