<?php

namespace XF\Attachment;

use XF\Entity\Attachment;
use XF\Mvc\Entity\Entity;

use function get_class;

abstract class AbstractHandler
{
	protected $contentType;

	public function __construct($contentType)
	{
		$this->contentType = $contentType;
	}

	abstract public function canView(Attachment $attachment, Entity $container, &$error = null);
	abstract public function canManageAttachments(array $context, &$error = null);
	abstract public function onAttachmentDelete(Attachment $attachment, Entity $container = null);
	abstract public function getConstraints(array $context);
	abstract public function getContainerIdFromContext(array $context);
	abstract public function getContext(Entity $entity = null, array $extraContext = []);

	public function getContainerLink(Entity $container, array $extraParams = [])
	{
		if ($container instanceof \XF\Entity\LinkableInterface)
		{
			return $container->getContentUrl(false, $extraParams);
		}

		throw new \LogicException(
			'Implement XF\Entity\LinkableInterface for ' . get_class($container)
			. ' or override ' . get_class($this) . '::getContentLink'
		);
	}

	public function getContainerTitle(Entity $container)
	{
		if ($container instanceof \XF\Entity\LinkableInterface)
		{
			return $container->getContentTitle('attachment');
		}

		return '';
	}

	public function validateAttachmentUpload(\XF\Http\Upload $upload, \XF\Attachment\Manipulator $manipulator)
	{
		return;
	}

	public function beforeNewAttachment(\XF\FileWrapper $file, array &$extra = [])
	{
		return;
	}

	public function onNewAttachment(Attachment $attachment, \XF\FileWrapper $file)
	{
		return;
	}

	public function prepareAttachmentJson(Attachment $attachment, array $context, array $json)
	{
		return $json;
	}

	public function onAssociation(Attachment $attachment, Entity $container = null)
	{
		return;
	}

	public function beforeAttachmentDelete(Attachment $attachment, Entity $container = null)
	{
		return;
	}

	public function getContainerFromContext(array $context)
	{
		$id = $this->getContainerIdFromContext($context);
		return $id ? $this->getContainerEntity($id) : null;
	}

	public function getContainerEntity($id)
	{
		return \XF::app()->findByContentType($this->contentType, $id, $this->getContainerWith());
	}

	public function getContainerWith()
	{
		return [];
	}

	public function getContentType()
	{
		return $this->contentType;
	}

	public function getContentTypePhrase()
	{
		return \XF::app()->getContentTypePhrase($this->contentType);
	}
}