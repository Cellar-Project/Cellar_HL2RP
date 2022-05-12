<?php

namespace XF;

use function boolval, is_scalar;

class WebManifestRenderer
{
	/**
	 * @var App
	 */
	protected $app;

	/**
	 * @var Style
	 */
	protected $style;

	/**
	 * @param App $app
	 */
	public function __construct(App $app)
	{
		$this->app = $app;
	}

	/**
	 * @param Style $style
	 * @param Language $language
	 *
	 * @return \XF\Http\Response
	 */
	public function render(Style $style, Language $language): \XF\Http\Response
	{
		$this->setStyle($style);
		$this->setLanguage($language);

		$response = $this->app()->response();

		$this->setupResponse($response);
		$response->body(json_encode($this->getResponseBody(), JSON_PRETTY_PRINT));

		return $response;
	}

	/**
	 * @param Style $style
	 */
	protected function setStyle(Style $style)
	{
		$this->style = $style;
		$this->templater()->setStyle($style);
	}

	/**
	 * @param Language $language
	 */
	protected function setLanguage(Language $language)
	{
		\XF::setLanguage($language);
		$this->templater()->setLanguage($language);
	}

	/**
	 * @param \XF\Http\Response $response
	 */
	protected function setupResponse(\XF\Http\Response $response)
	{
		$response->contentType('application/manifest+json');

		$expires = gmdate('D, d M Y H:i:s', \XF::$time + 86400);
		$lastModified = gmdate('D, d M Y H:i:s', \XF::$time);
		$response->header('Expires', $expires . ' GMT');
		$response->header('Last-Modified', $lastModified . ' GMT');
		$response->header('Cache-Control', 'private, max-age=86400');
	}

	/**
	 * @return array
	 */
	protected function getResponseBody(): array
	{
		$manifest = [];

		$options = $this->app()->options();
		$manifest['name'] = $options->boardTitle;
		$manifest['short_name'] = $options->boardShortTitle;
		$manifest['description'] = $options->boardDescription;

		$manifest['icons'] = $this->getManifestIcons();

		$language = \XF::language();
		$manifest['lang'] = $language->getLanguageCode();
		$manifest['dir'] = $language->getTextDirection();

		$manifest['display'] = $this->getDisplay();
		$manifest['scope'] = $this->baseUrl();
		$manifest['start_url'] = $this->app()->router()->buildLink(
			'index',
			null,
			['_pwa' => 1]
		);

		$manifest['background_color'] = $this->colorProperty('pageBg');
		$manifest['theme_color'] = $this->colorProperty('metaThemeColor');

		return array_filter($manifest);
	}

	/**
	 * @return array
	 */
	protected function getManifestIcons(): array
	{
		$icons = [];

		$maskable = boolval($this->styleProperty('publicIconsMaskable'));

		$iconUrl = $this->styleProperty('publicIconUrl');
		if ($iconUrl)
		{
			$icon = [
				'src' => $this->baseUrl($iconUrl),
				'sizes' => '192x192'
			];
			if ($maskable)
			{
				$icon['purpose'] = 'any maskable';
			}
			$icons[] = $icon;
		}

		$iconUrlLarge = $this->styleProperty('publicIconUrlLarge');
		if ($iconUrlLarge)
		{
			$iconLarge = [
				'src' => $this->baseUrl($iconUrlLarge),
				'sizes' => '512x512'
			];
			if ($maskable)
			{
				$iconLarge['purpose'] = 'any maskable';
			}
			$icons[] = $iconLarge;
		}

		return $icons;
	}

	protected function getDisplay(): string
	{
		$browser = $this->app()->request()->getBrowser();

		return ($browser['browser'] == 'chrome' && $browser['os'] == 'android')
			? 'standalone'
			: 'minimal-ui';
	}

	/**
	 * @return App
	 */
	protected function app(): App
	{
		return $this->app;
	}

	/**
	 * @param string $url
	 *
	 * @return string
	 */
	protected function baseUrl(string $url = ''): string
	{
		$pather = $this->app->container('request.pather');
		return $pather($url, 'base');
	}

	/**
	 * @return Style
	 */
	protected function style(): Style
	{
		return $this->style;
	}

	/**
	 * @param string $property
	 *
	 * @return string
	 *
	 * @throws \InvalidArgumentException
	 */
	protected function styleProperty(string $property): string
	{
		$value = $this->style->getProperty($property);
		if (!is_scalar($value))
		{
			throw new \InvalidArgumentException(
				'Provided style property is not scalar'
			);
		}

		return $value;
	}

	/**
	 * Obtains a style property that is expected to be a color. LESS functions in that
	 * color will be rendered out to a final value.
	 *
	 * @param string $property
	 *
	 * @return string
	 */
	protected function colorProperty(string $property)
	{
		$value = $this->styleProperty($property);

		return $this->templater()->func('parse_less_color', [$value]) ?: $value;
	}

	/**
	 * @return \XF\Template\Templater
	 */
	protected function templater(): \XF\Template\Templater
	{
		return $this->app->templater();
	}
}
