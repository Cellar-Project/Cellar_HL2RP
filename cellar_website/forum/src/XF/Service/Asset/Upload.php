<?php

namespace XF\Service\Asset;

class Upload extends \XF\Service\AbstractService
{
	protected $tempFile;
	protected $fileName;

	protected $assetType;

	protected $error = null;

	/**
	 * This represents an abstract version of the target location within the external data path.
	 * First variable will be the asset type, the second will be the file name
	 *
	 * @var string
	 */
	protected $targetLocation = 'assets/%s/%s';

	public function __construct(\XF\App $app, $assetType)
	{
		parent::__construct($app);

		if (!self::validateAssetType($assetType))
		{
			throw new \InvalidArgumentException("Invalid asset type $assetType");
		}

		$this->assetType = $assetType;
	}

	public function getError()
	{
		return $this->error;
	}

	public function getAssetType()
	{
		return $this->assetType;
	}

	public function getImageUrl($pathType = 'nopath')
	{
		if (!$this->fileName)
		{
			return '';
		}

		return $this->app->applyExternalDataUrlPathed(
			sprintf($this->targetLocation, $this->assetType, $this->fileName),
			$pathType
		);
	}

	public function setImageFromUpload(\XF\Http\Upload $upload)
	{
		$upload->requireImage();

		if (!$upload->isValid($errors))
		{
			$this->error = reset($errors);
			return false;
		}

		return $this->setImageFromFile($upload->getFileWrapper());
	}

	public function setImageFromFile(\XF\FileWrapper $file)
	{
		if (!$this->validateImageForAsset($file, $error))
		{
			$this->error = $error;
			$this->tempFile = null;
			return false;
		}

		$fileName = preg_replace('#[^a-z0-9_.-]#i', '', $file->getFileName());
		if (!preg_match('#\.(gif|jpg|jpeg|jpe|png)$#i', $fileName))
		{
			// this is really a complete sanity check -- shouldn't ever happen
			throw new \LogicException("Unexpected file extension for $fileName");
		}

		$this->tempFile = $file->getFilePath();
		$this->fileName = $fileName;
		return true;
	}

	protected function validateImageForAsset(\XF\FileWrapper $file, &$error = null)
	{
		if (!$file->isImage())
		{
			$error = \XF::phrase('provided_file_is_not_valid_image');
			return false;
		}

		// FileWrapper class handles validating that the file is readable, image type is allowed, etc

		return true;
	}

	public function copyImage()
	{
		if (!$this->tempFile)
		{
			throw new \LogicException("No source file for asset set");
		}

		$dataFile = sprintf('data://' . $this->targetLocation, $this->getAssetType(), $this->fileName);
		\XF\Util\File::copyFileToAbstractedPath($this->tempFile, $dataFile);

		return true;
	}

	/**
	 * Statically validate the type name so that validation can be done before instantiating this object
	 * (which will throw an exception on an invalid name)
	 *
	 * @param string $type
	 *
	 * @return bool
	 */
	public static function validateAssetType(string $type)
	{
		return (bool)preg_match('#^[a-z0-9_-]+$#i', $type);
	}
}