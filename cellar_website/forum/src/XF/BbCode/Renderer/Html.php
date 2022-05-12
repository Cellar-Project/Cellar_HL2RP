<?php

namespace XF\BbCode\Renderer;

use XF\Str\Formatter;
use XF\Template\Templater;
use XF\Util\Arr;

use function call_user_func, count, in_array, intval, is_array, is_string, strlen, strval;

class Html extends AbstractRenderer
{
	protected $trimAfter = 0;

	protected $mediaSites = [];

	protected $allowedUrlProtocolRegex = '#^(https?|ftp)://#i';

	protected $allowedCodeLanguages;

	/**
	 * @var Formatter
	 */
	protected $formatter;

	/**
	 * @var Templater
	 */
	protected $templater;

	public function __construct(Formatter $formatter, Templater $templater)
	{
		$this->formatter = $formatter;
		$this->templater = $templater;
		$this->addDefaultTags();
	}

	public function getTemplater()
	{
		return $this->templater;
	}

	public function setTemplater(Templater $templater)
	{
		$this->templater = $templater;
	}

	public function addDefaultTags()
	{
		$this->addTag('b', ['replace' => ['<b>', '</b>']]);
		$this->addTag('i', ['replace' => ['<i>', '</i>']]);
		$this->addTag('u', ['replace' => ['<u>', '</u>']]);
		$this->addTag('s', ['replace' => ['<s>', '</s>']]);
		$this->addTag('color', ['callback' => 'renderTagColor']);

		$this->addTag('font', ['callback' => 'renderTagFont']);
		$this->addTag('size', ['callback' => 'renderTagSize']);

		$this->addTag('url', [
			'callback' => 'renderTagUrl',
			'trimAfter' => function($option, array $tag)
			{
				if (is_array($option) && isset($option['unfurl']) && $option['unfurl'] === 'true')
				{
					return 1;
				}
				return null;
			}
		]);
		$this->addTag('email', ['callback' => 'renderTagEmail']);

		$this->addTag('left', [
			'callback' => 'renderTagAlign',
			'trimAfter' => 1
		]);
		$this->addTag('center', [
			'callback' => 'renderTagAlign',
			'trimAfter' => 1
		]);
		$this->addTag('right', [
			'callback' => 'renderTagAlign',
			'trimAfter' => 1
		]);
		$this->addTag('justify', [
			'callback' => 'renderTagAlign',
			'trimAfter' => 1
		]);

		$this->addTag('indent', [
			'callback' => 'renderTagIndent',
			'trimAfter' => 1
		]);

		$this->addTag('heading', [
			'callback' => 'renderTagHeading',
			'trimAfter' => 1
		]);

		$this->addTag('hr', [
			'callback' => 'renderTagHr',
			'trimAfter' => 1
		]);

		$this->addTag('img', [
			'callback' => 'renderTagImage'
		]);

		$this->addTag('quote', [
			'callback' => 'renderTagQuote',
			'trimAfter' => 1
		]);

		$this->addTag('code', [
			'callback' => 'renderTagCode',
			'stopBreakConversion' => true,
			'trimAfter' => 1
		]);

		$this->addTag('icode', [
			'callback' => 'renderTagInlineCode',
			'stopBreakConversion' => true,
		]);

		$this->addTag('php', [
			'callback' => 'renderTagPhp',
			'stopBreakConversion' => true,
			'trimAfter' => 1
		]);

		$this->addTag('html', [
			'callback' => 'renderTagHtml',
			'stopBreakConversion' => true,
			'trimAfter' => 1
		]);

		$this->addTag('list', [
			'callback' => 'renderTagList',
			'trimAfter' => 1
		]);

		$this->addTag('plain', [
			'replace' => ['', '']
		]);

		$this->addTag('media', [
			'callback' => 'renderTagMedia',
			'trimAfter' => 1
		]);

		$this->addTag('spoiler', [
			'callback' => 'renderTagSpoiler',
			'trimAfter' => 1
		]);

		$this->addTag('ispoiler', [
			'callback' => 'renderTagInlineSpoiler'
		]);

		$this->addTag('attach', [
			'callback' => 'renderTagAttach',
		]);

		$this->addTag('user', [
			'callback' => 'renderTagUser'
		]);

		$this->addTag('table', [
			'callback' => 'renderTagTable',
			'trimAfter' => 1
		]);
	}

	public function getCustomTagConfig(array $tag)
	{
		$output = [];

		if ($tag['bb_code_mode'] == 'replace')
		{
			$output['replace'] = $tag['replace_html'];
		}
		else if ($tag['bb_code_mode'] == 'callback')
		{
			$output['callback'] = [$tag['callback_class'], $tag['callback_method']];
		}

		if ($tag['trim_lines_after'])
		{
			$output['trimAfter'] = $tag['trim_lines_after'];
		}

		if ($tag['disable_nl2br'])
		{
			$output['stopBreakConversion'] = true;
		}

		if ($tag['allow_empty'])
		{
			$output['keepEmpty'] = true;
		}

		return $output;
	}

	public function addMediaSite($siteId, array $config)
	{
		$this->mediaSites[$siteId] = $config;
	}

	public function addMediaSites(array $sites)
	{
		foreach ($sites AS $siteId => $site)
		{
			$this->addMediaSite($siteId, $site);
		}
	}

	public function getDefaultOptions()
	{
		return [
			'stopSmilies' => 0,
			'stopBreakConversion' => 0,
			'shortenUrl' => true,
			'noFollowUrl' => true,
			'noProxy' => false,
			'attachments' => [],
			'viewAttachments' => false,
			'user' => null,
			'entity' => null,
			'lightbox' => true,
			'treatAsStructuredText' => false,
			'plain' => false,
			'allowUnfurl' => true,
			'simpleUnfurl' => false
		];
	}

	protected function setupRenderOptions(array $ast, array &$options)
	{
		if (
			!empty($options['user'])
			&& $options['user'] instanceof \XF\Entity\User
			&& $options['user']->isLinkTrusted()
		)
		{
			$options['noFollowUrl'] = false;
		}

		if (!empty($options['treatAsStructuredText']))
		{
			if (count($ast) > 1 || !$ast || is_array($ast[0]))
			{
				// contains BB code, not legacy
				$options['treatAsStructuredText'] = false;
			}
			else if (
				preg_match('#(?<=[^a-z0-9@-]|^)(https?://|www\.)[^\s"<>{}`]#i', $ast[0])
				|| preg_match('#(?<=^|\s|[\](,/\'"]|--|@)@\[\d+:#i', $ast[0])
			)
			{
				// a link that hasn't been converted to BB code or a structured text mention means legacy
			}
			else
			{
				// nothing to indicate it as legacy, so assume not
				$options['treatAsStructuredText'] = false;
			}
		}
	}

	protected function setupRender(array $ast, array $options)
	{
		$this->trimAfter = 0;
	}

	public function renderTag(array $tag, array $options)
	{
		$this->trimAfter = 0;

		$tagName = $tag['tag'];
		if (!isset($this->tags[$tagName]))
		{
			return $this->renderUnparsedTag($tag, $options);
		}

		$renderRule = $this->tags[$tagName];
		$rule = $this->rules->getTag($tagName);

		if ($rule && !empty($rule['stopSmilies']))
		{
			$options['stopSmilies']++;
		}
		if (!empty($renderRule['stopBreakConversion']))
		{
			$options['stopBreakConversion']++;
		}
		if (!empty($rule['plain']))
		{
			$options['plain'] = true;
		}

		if (!empty($renderRule['callback']))
		{
			if (is_string($renderRule['callback']))
			{
				$renderRule['callback'] = [$this, $renderRule['callback']];
			}
			if (is_callable($renderRule['callback']))
			{
				$output = call_user_func($renderRule['callback'],
					$tag['children'], $tag['option'], $tag, $options, $this
				);
			}
			else
			{
				$output = $this->renderUnparsedTag($tag, $options);
			}
		}
		else if (!empty($renderRule['replace']))
		{
			$text = $this->renderSubTree($tag['children'], $options);
			if (empty($renderRule['keepEmpty']) && trim($text) === '')
			{
				return $text;
			}

			if ($tag['option'] !== null)
			{
				$optionOutput = $this->filterString($tag['option'], [
					'stopSmilies' => 1,
					'stopBreakConversion' => 1,
					'plain' => true
				] + $options);
			}
			else
			{
				$optionOutput = '';
			}

			if (is_array($renderRule['replace']))
			{
				list($prepend, $append) = $renderRule['replace'];
				$output = $this->wrapHtml($prepend, $text, $append, $optionOutput);
			}
			else
			{
				$output = strtr($renderRule['replace'], [
					'{text}' => $text,
					'{option}' => $optionOutput
				]);
			}
		}
		else
		{
			$output = $this->renderUnparsedTag($tag, $options);
		}

		if (!empty($renderRule['trimAfter']))
		{
			if (is_callable($renderRule['trimAfter']))
			{
				$this->trimAfter = $renderRule['trimAfter']($tag['option'], $tag);
			}
			else
			{
				$this->trimAfter = $renderRule['trimAfter'];
			}
		}

		return $output;
	}

	public function renderString($string, array $options)
	{
		if ($this->trimAfter)
		{
			$string = preg_replace('#^([ \t]*\r?\n){1,' . $this->trimAfter . '}#i', '', $string);
			$this->trimAfter = 0;
		}

		return $this->filterString($string, $options);
	}

	public function filterString($string, array $options)
	{
		$string = $this->formatter->censorText($string);

		if (
			!empty($options['stopSmilies'])
			|| !empty($options['plain'])
			|| !empty($options['treatAsStructuredText']) // smilie conversion can break mentions
		)
		{
			$allowSmilies = false;
		}
		else
		{
			$allowSmilies = true;
		}

		if ($allowSmilies)
		{
			$string = $this->formatter->replaceSmiliesHtml($string);
			$string = $this->formatter->getEmojiFormatter()->formatEmojiToImage($string);
		}
		else
		{
			$string = htmlspecialchars($string);
		}

		if (!empty($options['treatAsStructuredText']) && empty($options['plain']))
		{
			$string = $this->formatter->autoLinkStructuredText($string);
			$string = $this->formatter->linkStructuredTextMentions($string);
		}

		if (empty($options['stopBreakConversion']))
		{
			$string = nl2br($string);
		}

		return $string;
	}

	public function filterFinalOutput($output)
	{
		return '<div class="bbWrapper">' . trim($output) . '</div>';
	}

	public function wrapHtml($open, $inner, $close, $option = null)
	{
		if ($option !== null)
		{
			$open = sprintf($open, $option);
			$close = sprintf($close, $option);
		}

		return $open . $inner . $close;
	}

	protected function endsInBlockTag($text)
	{
		return preg_match('#</(p|div|blockquote|pre|ol|ul)>$#i', substr(rtrim($text), -20));
	}

	public function renderTagAlign(array $children, $option, array $tag, array $options)
	{
		$output = trim($this->renderSubTree($children, $options));

		$invisibleSpace = $this->endsInBlockTag($output) ? '' : '&#8203;';

		switch (strtolower($tag['tag']))
		{
			case 'left':
			case 'center':
			case 'right':
			case 'justify':
				return $this->wrapHtml(
					'<div style="text-align: ' . $tag['tag'] . '">',
					$output . $invisibleSpace,
					'</div>'
				);

			default:
				return $this->wrapHtml('<div>', $output . $invisibleSpace, '</div>');
		}
	}

	public function renderTagAttach(array $children, $option, array $tag, array $options)
	{
		$id = intval($this->renderSubTreePlain($children));
		if (!$id)
		{
			return '';
		}

		/** @var \XF\Entity\Attachment|null $attachment */
		$attachment = $options['attachments'][$id] ?? null;

		$canView = !empty($options['viewAttachments']);
		$full = $this->isFullAttachView($option);

		$processOptions = $this->getDefaultImageDisplayOptions($options);
		if ($full && !$canView)
		{
			$processOptions['skipDimensions'] = true;
		}

		if ($attachment)
		{
			$intrinsicDims = null;

			if ($full)
			{
				$intrinsicDims = [$attachment->width, $attachment->height];
			}
			else if ($attachment->has_thumbnail)
			{
				$intrinsicDims = [$attachment->thumbnail_width, $attachment->thumbnail_height];
			}

			$processOptions['intrinsicDimensions'] = $intrinsicDims;
		}

		$displayAttrs = $this->processImageDisplayModifiers($option, $processOptions);
		$alt = $displayAttrs['alt'] ?? '';

		$viewParams = [
			'id' => $id,
			'attachment' => $attachment,
			'canView' => $canView,
			'full' => $full,
			'alignClass' => $displayAttrs['class'] ?? '',
			'styleAttr' => $displayAttrs['style'] ?? '',
			'alt' =>  $alt ?: ($attachment ? $attachment->filename : ''),
			'displayAttrs' => $displayAttrs
		];

		if (empty($options['lightbox']))
		{
			$viewParams['noLightbox'] = true;
		}

		return $this->getRenderedAttachment($attachment, $viewParams);
	}

	protected function getRenderedAttachment($attachment, array $viewParams)
	{
		return $this->templater->renderTemplate('public:bb_code_tag_attach', $viewParams);
	}

	protected function isFullAttachView($option)
	{
		if ($option)
		{
			if (is_array($option) && isset($option['type']) && strtolower($option['type']) == 'full')
			{
				return true;
			}
			else if (is_string($option) && strtolower($option) == 'full')
			{
				return true;
			}
		}

		return false;
	}

	public function renderTagCode(array $children, $option, array $tag, array $options)
	{
		$content = $this->renderSubTree($children, $options);
		// a bit like ltrim, but only remove blank lines, not leading tabs on the first line
		$content = preg_replace('#^([ \t]*\r?\n)+#', '', $content);
		$content = rtrim($content);

		/** @var \XF\Data\CodeLanguage $codeLanguages */
		$codeLanguages = \XF::app()->data('XF:CodeLanguage');
		$allowedLanguages = $codeLanguages->getSupportedLanguages(true);

		if ($option)
		{
			$language = strtolower(preg_replace('#[^a-z0-9_-]#i', '-', $option));
		}
		else
		{
			$language = null;
		}

		if ($language && isset($allowedLanguages[$language]))
		{
			$config = $allowedLanguages[$language];
		}
		else
		{
			$config = [];
			if ($language == 'rich')
			{
				$config['phrase'] = \XF::phrase('code_language.rich');
			}
			$language = '';
		}

		if (!is_array($this->allowedCodeLanguages))
		{
			$this->allowedCodeLanguages = Arr::stringToArray(\XF::options()->allowedCodeLanguages,'/\r?\n/');
		}


		if (!in_array($language, $this->allowedCodeLanguages))
		{
			$language = '';
		}

		return $this->getRenderedCode($content, $language, $config);
	}

	protected function getRenderedCode($content, $language, array $config = [])
	{
		return $this->templater->renderTemplate('public:bb_code_tag_code', [
			'content' => new \XF\PreEscaped($content),
			'language' => $language,
			'config' => $config
		]);
	}

	public function renderTagInlineCode(array $children, $option, array $tag, array $options)
	{
		$content = $this->renderSubTree($children, $options);
		$this->templater->includeCss('public:bb_code.less');
		return $this->wrapHtml('<code class="bbCodeInline">', $content, '</code>');
	}

	public function renderTagEmail(array $children, $option, array $tag, array $options)
	{
		if ($option !== null)
		{
			$options['lightbox'] = false;

			$email = $option;
			$text = $this->renderSubTree($children, $options);
		}
		else
		{
			$email = $this->renderSubTreePlain($children);
			$text = $this->filterString($email, $options);
		}

		if (strpos($email, '@') === false)
		{
			// invalid URL, ignore
			return $text;
		}

		$censored = $this->formatter->censorText($email);
		if ($censored !== $email)
		{
			return $text;
		}

		return $this->wrapHtml(
			'<a href="mailto:' . htmlspecialchars($email) . '">',
			$text,
			'</a>'
		);
	}

	public function renderTagHtml(array $children, $option, array $tag, array $options)
	{
		return $this->renderTagCode($children, 'html', $tag, $options);
	}

	public function renderTagImage(array $children, $option, array $tag, array $options)
	{
		$url = $this->renderSubTreePlain($children);

		$censored = $this->formatter->censorText($url);
		if ($censored !== $url)
		{
			return $this->filterString($url, $options);
		}

		$validUrl = $this->getValidUrl($url);
		if (!$validUrl)
		{
			return $this->filterString($url, $options);
		}

		if ($options['noProxy'])
		{
			$imageUrl = $validUrl;
		}
		else
		{
			$linkInfo = $this->formatter->getLinkClassTarget($validUrl);
			if ($linkInfo['local'])
			{
				$imageUrl = $validUrl;
			}
			else
			{
				$imageUrl = $this->formatter->getProxiedUrlIfActive('image', $validUrl);
				if (!$imageUrl)
				{
					$imageUrl = $validUrl;
				}
			}
		}

		$displayAttrs = $this->processImageDisplayModifiers(
			$option,
			$this->getDefaultImageDisplayOptions($options)
		);

		$alt = $displayAttrs['alt'] ?? '';

		$altFallback = $alt;
		if ($alt === '')
		{
			$urlPath = @parse_url($validUrl, PHP_URL_PATH);
			if ($urlPath)
			{
				$altFallback = basename($urlPath);
			}
		}

		$params = [
			'lightbox' => !empty($options['lightbox']),
			'alignClass' => $displayAttrs['class'] ?? '',
			'styleAttr' => $displayAttrs['style'] ?? '',
			'alt' => $alt,
			'altFallback' => $altFallback,
			'width' => $displayAttrs['width'] ?? '',
			'height' => $displayAttrs['height'] ?? '',
			'displayAttrs' => $displayAttrs
		];

		return $this->getRenderedImg($imageUrl, $validUrl, $params);
	}

	protected function getRenderedImg($imageUrl, $validUrl, array $params = [])
	{
		$params['imageUrl'] = $imageUrl;
		$params['validUrl'] = $validUrl;

		return $this->templater->renderTemplate('public:bb_code_tag_img', $params);
	}

	protected function getDefaultImageDisplayOptions(array $renderOptions = []): array
	{
		return [];
	}

	protected function processImageDisplayModifiers($modifiers, array $processOptions = []): array
	{
		if (!is_array($modifiers))
		{
			return [];
		}

		$processOptions = array_replace([
			'leftAlignClass' => 'bbImageAligned--left',
			'rightAlignClass' => 'bbImageAligned--right',
			'allowIntrinsicDimensions' => true,
			'intrinsicDimensions' => null,
			'skipDimensions' => false
		], $processOptions);

		$output = [];

		$alignOption = $this->hasAlignOption($modifiers);
		if ($alignOption)
		{
			switch ($alignOption)
			{
				case 'L':
					$output['class'] = $processOptions['leftAlignClass'];
					break;

				case 'R':
					$output['class'] = $processOptions['rightAlignClass'];
					break;
			}
		}

		if (!empty($modifiers['alt']))
		{
			$output['alt'] = $modifiers['alt'];
		}
		else if (!empty($modifiers['title']))
		{
			// always going into alt
			$output['alt'] = $modifiers['title'];
		}

		if ($processOptions['skipDimensions'])
		{
			$width = null;
			$height = null;
		}
		else
		{
			if (isset($modifiers['width']) && preg_match('/^[\d\.]+(px|%)$/i', $modifiers['width']))
			{
				$width = $modifiers['width'];
			}
			else
			{
				$width = null;
			}

			if (isset($modifiers['height']) && preg_match('/^[\d\.]+(px|%)$/i', $modifiers['height']))
			{
				$height = $modifiers['height'];
			}
			else
			{
				$height = null;
			}
		}

		if (
			$processOptions['allowIntrinsicDimensions']
			&& $width !== null
			&& preg_match('/px$/i', $width)
			&& $height !== null
			&& preg_match('/px$/i', $height)
		)
		{
			// we have pixel values for height and width. Use them for intrinsic sizing
			$output['width'] = substr($width, 0, -2);
			$output['height'] = substr($height, 0, -2);

			// without this, we'll use the intrinsic values but our width: auto CSS with prevent the resize
			// from actually applying
			$output['style'] = "width: $width";
		}
		else
		{
			$style = [];

			if ($width !== null)
			{
				$style[] = "width: $width";
			}
			if ($height !== null)
			{
				$style[] = "height: $height";

				if ($width === null && $processOptions['intrinsicDimensions'])
				{
					// if we have intrinsic dimensions, outputting just height is unlikely to
					// resize as expected (see XF-192612).
					$style[] = "width: auto";
				}
			}

			if ($style)
			{
				$output['style'] = implode('; ', $style);
			}
		}

		return $output;
	}

	/**
	 * Returns R, L or false
	 */
	protected function hasAlignOption($option)
	{
		if (is_array($option) && isset($option['align']) && strlen($option['align']))
		{
			return strtoupper($option['align'][0]);
		}

		return false;
	}

	public function renderTagIndent(array $children, $option, array $tag, array $options)
	{
		$output = trim($this->renderSubTree($children, $options));

		$amount = $option ? intval($option) : 1;
		$amount = max(1, min($amount, 5));

		$invisibleSpace = $this->endsInBlockTag($output) ? '' : '&#8203;';

		$side = \XF::language()->isRtl() ? 'right' : 'left';
		return $this->wrapHtml(
			'<div style="margin-' . $side . ': ' . ($amount * 20) . 'px">',
			$output . $invisibleSpace,
			'</div>'
		);
	}

	public function renderTagHeading(array $children, $option, array $tag, array $options)
	{
		$output = trim($this->renderSubTree($children, $options));
		$invisibleSpace = $this->endsInBlockTag($output) ? '' : '&#8203;';

		$type = $option ? intval($option) : 0;
		$tag = $this->getHeadingTagMap($type);

		return $this->wrapHtml("<$tag>", $output . $invisibleSpace, "</$tag>");
	}

	public function renderTagHr(array $children, $option, array $tag, array $options)
	{
		$output = trim($this->renderSubTree($children, $options));

		return '<hr />' . (strlen($output) ? "\n$output" : '');
	}

	protected function getHeadingTagMap(int $type): string
	{
		switch ($type)
		{
			case 1: return 'h2';
			case 2: return 'h3';
			case 3: return 'h4';
			default: return 'div';
		}
	}

	public function renderTagList(array $children, $option, array $tag, array $options)
	{
		$listType = ($option && $option === '1' ? 'ol' : 'ul');
		$elements = [];
		$lastElement = '';

		foreach ($children AS $child)
		{
			if (is_array($child))
			{
				$childText = $this->renderTag($child, $options);
				if (preg_match('#^<(ul|ol)#', $childText))
				{
					$lastElement = rtrim($lastElement);
					if (substr($lastElement, -6) == '<br />')
					{
						$lastElement = substr($lastElement, 0, -6);
					}
				}
				$lastElement .= $childText;
			}
			else
			{
				if (strpos($child, '[*]') !== false)
				{
					$parts = explode('[*]', $child);

					$beforeFirst = array_shift($parts);
					if ($lastElement !== '' || trim($beforeFirst) !== '')
					{
						$lastElement .= $this->renderString($beforeFirst, $options);
					}

					foreach ($parts AS $part)
					{
						$this->appendListElement($elements, $lastElement);
						$lastElement = $this->renderString($part, $options);
					}
				}
				else
				{
					$lastElement .= $this->renderString($child, $options);
				}
			}
		}

		$this->appendListElement($elements, $lastElement);

		if (!$elements)
		{
			return '';
		}

		return $this->renderFinalListOutput($listType, $elements);
	}

	protected function appendListElement(array &$elements, $appendString)
	{
		if ($appendString !== '')
		{
			$appendString = rtrim($appendString);
			if (substr($appendString, -6) == '<br />')
			{
				$appendString = substr($appendString, 0, -6);
			}

			$elements[] = $appendString;
		}
	}

	protected function renderFinalListOutput($listType, array $elements)
	{
		$output = "<$listType>";
		foreach ($elements AS $element)
		{
			$output .= "\n<li data-xf-list-type=\"$listType\">$element</li>";
		}
		$output .= "\n</$listType>";

		return $output;
	}

	public function renderTagMedia(array $children, $option, array $tag, array $options)
	{
		$mediaKey = trim($this->renderSubTreePlain($children));
		if (preg_match('#[&?"\'<>\r\n]#', $mediaKey) || strpos($mediaKey, '..') !== false)
		{
			return '';
		}

		$censored = $this->formatter->censorText($mediaKey);
		if ($censored != $mediaKey)
		{
			return '';
		}

		$mediaSiteId = strtolower($option);
		if (!isset($this->mediaSites[$mediaSiteId]))
		{
			return '';
		}

		$site = $this->mediaSites[$mediaSiteId];

		$embedHtml = '';

		if (!empty($site['callback']) && is_callable($site['callback']))
		{
			$embedHtml = call_user_func($site['callback'], $mediaKey, $site, $mediaSiteId);
		}

		if (!$embedHtml)
		{
			$keyDigits = preg_replace('/[^0-9]/', '', $mediaKey);
			$keyEncoded = rawurlencode($mediaKey);
			$keySlash = str_replace('%2F', '/', $keyEncoded);

			if ($site['oembed_enabled'])
			{
				$embedHtml = $this->templater->renderTemplate('public:_media_site_embed_oembed', [
					'provider' => $mediaSiteId,
					'id' => $mediaKey,
					'site' => $site,
					'jsState' => $mediaSiteId,
					'url' => strtr($site['oembed_url_scheme'], [
						'{$id}' => $keyEncoded,
						'{$idSlash}' => $keySlash,
						'{$idDigits}' => $keyDigits
					])
				]);
			}
			else
			{
				$embedHtml = $this->templater->renderTemplate('public:_media_site_embed_' . $mediaSiteId, [
					'id'       => $keyEncoded,
					'idRaw'    => $mediaKey,
					'idSlash'  => $keySlash,
					'idDigits' => $keyDigits
				]);
			}
		}

		return $embedHtml;
	}

	public function renderTagPhp(array $children, $option, array $tag, array $options)
	{
		return $this->renderTagCode($children, 'php', $tag, $options);
	}

	public function renderTagQuote(array $children, $option, array $tag, array $options)
	{
		if (!$children)
		{
			return '';
		}

		$this->trimChildrenList($children);

		$content = $this->renderSubTree($children, array_merge($options, [
			'noFollowUrl' => true
		]));
		if ($content === '')
		{
			return '';
		}

		$quoteParams = $this->parseQuoteTagParams($option, $options);

		return $this->getRenderedQuote(
			$content,
			$quoteParams['name'],
			$quoteParams['source'],
			$quoteParams['attributes']
		);
	}

	protected function parseQuoteTagParams($params, array $options)
	{
		$name = null;
		$attributes = [];
		$source = [];

		if ($params !== null && strlen($params))
		{
			$parts = explode(',', $params);
			$name = $this->filterString(array_shift($parts), array_merge($options, [
				'stopSmilies' => 1,
				'stopBreakConversion' => 1
			]));

			foreach ($parts AS $part)
			{
				$attributeParts = explode(':', $part, 2);
				if (isset($attributeParts[1]))
				{
					$attrName = trim($attributeParts[0]);
					$attrValue = trim($attributeParts[1]);
					if ($attrName !== '' && $attrValue !== '')
					{
						$attributes[$attrName] = $attrValue;
					}
				}
			}

			if ($attributes)
			{
				$firstValue = reset($attributes);
				$firstName = key($attributes);
				if ($firstName != 'member')
				{
					$source = ['type' => $firstName, 'id' => intval($firstValue)];
				}
			}
		}

		return [
			'name' => $name,
			'source' => $source,
			'attributes' => $attributes
		];
	}

	protected function getRenderedQuote($content, $name, array $source, array $attributes)
	{
		return $this->templater->renderTemplate('public:bb_code_tag_quote', [
			'content' => new \XF\PreEscaped($content),
			'name' => $name ? new \XF\PreEscaped($name) : null,
			'source' => $source,
			'attributes' => $attributes
		]);
	}

	public function renderTagColor(array $children, $option, array $tag, array $options)
	{
		$text = $this->renderSubTree($children, $options);
		if (trim($text) === '')
		{
			return $text;
		}

		if (!$this->isUsableColor($option))
		{
			return $text;
		}

		$color = htmlspecialchars($option);

		return $this->wrapHtml(
			'<span style="color: ' . $color . '">',
			$text,
			'</span>'
		);
	}

	protected function isUsableColor(string $color): bool
	{
		switch (strtolower($color))
		{
			case 'transparent':
				 // a special case, not really appropriate in most cases; spoilers are better
				return false;

			case 'activeborder':
			case 'activecaption':
			case 'activetext':
			case 'appworkspace':
			case 'background':
			case 'buttonface':
			case 'buttonhighlight':
			case 'buttonshadow':
			case 'buttontext':
			case 'canvas':
			case 'canvastext':
			case 'captiontext':
			case 'field':
			case 'fieldtext':
			case 'graytext':
			case 'highlight':
			case 'highlighttext':
			case 'inactiveborder':
			case 'inactivecaption':
			case 'inactivecaptiontext':
			case 'infobackground':
			case 'infotext':
			case 'linktext':
			case 'mark':
			case 'marktext':
			case 'menu':
			case 'menutext':
			case 'scrollbar':
			case 'threeddarkshadow':
			case 'threedface':
			case 'threedhighlight':
			case 'threedlightshadow':
			case 'threedshadow':
			case 'window':
			case 'windowframe':
			case 'windowtext':
			case 'visitedtext':
				// all system colors which may not be consistent, many are deprecated
				return false;

			default:
				return true;
		}
	}

	public function renderTagFont(array $children, $option, array $tag, array $options)
	{
		$text = $this->renderSubTree($children, $options);
		if (trim($text) === '')
		{
			return $text;
		}

		$font = htmlspecialchars($option);

		if (strtolower(trim($font)) != 'inherit')
		{
			$font = "'{$font}'";
		}

		return $this->wrapHtml(
			'<span style="font-family: ' . $font . '">',
			$text,
			'</span>'
		);
	}

	public function renderTagSize(array $children, $option, array $tag, array $options)
	{
		$text = $this->renderSubTree($children, $options);
		if (trim($text) === '')
		{
			return $text;
		}

		$size = $this->getTextSize($option);
		if ($size)
		{
			return $this->wrapHtml(
				'<span style="font-size: ' . htmlspecialchars($size) . '">',
				$text,
				'</span>'
			);
		}
		else
		{
			return $text;
		}
	}

	protected function getTextSize($inputSize)
	{
		if (strval(intval($inputSize)) == strval($inputSize))
		{
			// int only, translate size
			if ($inputSize <= 0)
			{
				return null;
			}

			switch ($inputSize)
			{
				case 1: return '9px';
				case 2: return '10px';
				case 3: return '12px';
				case 4: return '15px';
				case 5: return '18px';
				case 6: return '22px';
				default: return '26px';
			}
		}
		else
		{
			// int and unit
			if (!preg_match('/^([0-9]+)px$/i', $inputSize, $match))
			{
				return null;
			}

			$size = intval($match[1]);
			$size = max(8, min($size, 36));

			return $size . 'px';
		}
	}

	public function renderTagSpoiler(array $children, $option, array $tag, array $options)
	{
		if (!$children)
		{
			return '';
		}

		$this->trimChildrenList($children);

		$content = $this->renderSubTree($children, $options);
		if ($content === '')
		{
			return '';
		}

		if ($option)
		{
			$title = $this->filterString($option, array_merge($options, [
				'stopSmilies' => 1,
				'stopBreakConversion' => 1
			]));
		}
		else
		{
			$title = null;
		}

		return $this->getRenderedSpoiler($content, $title);
	}

	protected function getRenderedSpoiler($content, $title = null)
	{
		return $this->templater->renderTemplate('public:bb_code_tag_spoiler', [
			'content' => new \XF\PreEscaped($content),
			'title' => $title ? new \XF\PreEscaped($title) : null
		]);
	}

	public function renderTagInlineSpoiler(array $children, $option, array $tag, array $options)
	{
		$content = $this->renderSubTree($children, $options);
		return $this->getRenderedInlineSpoiler($content);
	}

	protected function getRenderedInlineSpoiler($content)
	{
		$this->templater->includeCss('public:bb_code.less');

		return $this->wrapHtml(
			'<span class="bbCodeInlineSpoiler" data-xf-click="toggle-class" data-class="bbCodeInlineSpoiler" tabindex="0" role="button">',
			$content,
			'</span>'
		);
	}

	public function renderTagUrl(array $children, $option, array $tag, array $options)
	{
		$unfurl = false;

		if ($option !== null && !is_array($option))
		{
			$options['lightbox'] = false;

			$url = $option;
			$text = $this->renderSubTree($children, $options);

			if ($text === '')
			{
				$text = $this->prepareTextFromUrlExtended($url, $options);
			}
		}
		else if (is_array($option)
			&& isset($option['unfurl'])
			&& $option['unfurl'] === 'true'
			&& !empty($options['allowUnfurl'])
		)
		{
			$url = $this->renderSubTreePlain($children);
			$text = '<div>' . $this->prepareTextFromUrlExtended($url, $options) . '</div>';
			$unfurl = true;
		}
		else
		{
			$url = $this->renderSubTreePlain($children);
			$text = $this->prepareTextFromUrlExtended($url, $options);
		}

		$censored = $this->formatter->censorText($url);
		if ($censored !== $url)
		{
			return $text;
		}

		$url = $this->getValidUrl($url);
		if (!$url)
		{
			return $text;
		}

		if ($unfurl)
		{
			return $this->getRenderedUnfurl($url, $options);
		}
		else
		{
			return $this->getRenderedLink($text, $url, $options);
		}
	}

	/**
	 * @param $url
	 *
	 * @deprecated use method prepareTextFromUrlExtended
	 * @return string
	 */
	protected function prepareTextFromUrl($url)
	{
		return $this->prepareTextFromUrlExtended($url, []);
	}

	protected function prepareTextFromUrlExtended($url, array $options)
	{
		$text = rawurldecode($url);
		if (!preg_match('/./su', $text))
		{
			$text = $url;
		}
		$text = $this->formatter->censorText($text);

		if (!empty($options['shortenUrl']))
		{
			$length = utf8_strlen($text);
			if ($length > 100)
			{
				$text = utf8_substr_replace($text, '...', 35, $length - 35 - 45);
			}
		}

		return htmlspecialchars($text);
	}

	protected function getRenderedLink($text, $url, array $options)
	{
		$linkInfo = $this->formatter->getLinkClassTarget($url);
		$rels = [];

		$classAttr = $linkInfo['class'] ? " class=\"$linkInfo[class]\"" : '';
		$targetAttr = $linkInfo['target'] ? " target=\"$linkInfo[target]\"" : '';

		if (!$linkInfo['trusted'] && !empty($options['noFollowUrl']))
		{
			$rels[] = 'nofollow';
			$rels[] = 'ugc';
		}

		if ($linkInfo['target'])
		{
			$rels[] = 'noopener';
		}

		$proxyAttr = '';
		if (empty($options['noProxy']))
		{
			$proxyUrl = $this->formatter->getProxiedUrlIfActive('link', $url);
			if ($proxyUrl)
			{
				$proxyAttr = ' data-proxy-href="' . htmlspecialchars($proxyUrl) . '"';
			}
		}

		if ($rels)
		{
			$relAttr = ' rel="' . implode(' ', $rels) . '"';
		}
		else
		{
			$relAttr = '';
		}

		return $this->wrapHtml(
			'<a href="' . htmlspecialchars($url) . '"' . $targetAttr . $classAttr . $proxyAttr . $relAttr . '>',
			$text,
			'</a>'
		);
	}

	protected function getRenderedUnfurl($url, array $options)
	{
		$result = $this->getUnfurlResultFromUrl($url, $options);

		if (!$result)
		{
			$text = $this->prepareTextFromUrlExtended($url, $options);
			return '<div>' . $this->getRenderedLink($text, $url, $options) . '</div>';
		}

		return $this->templater->renderUnfurl($result, $options);
	}

	protected function getUnfurlResultFromUrl($url, array $options)
	{
		$urlHash = md5($url);

		if (isset($options['unfurls'][$urlHash]))
		{
			$result = $options['unfurls'][$urlHash];
		}
		else
		{
			/** @var \XF\Repository\Unfurl $unfurlRepo */
			$unfurlRepo = \XF::app()->repository('XF:Unfurl');
			$result = $unfurlRepo->getUnfurlResultByUrl($url);
		}

		return $result;
	}

	/**
	 * Returns a version of the passed in URL that is valid for use in a message or false
	 * if the URL is definitively unusable. Note that this is distinct from the URL being valid
	 * from an RFC perspective, as users may submit URLs that don't always have all components
	 * URL encoded as needed. We generally defer to the browsers to handle this for us rather
	 * than rejecting the URL.
	 *
	 * @param string $url
	 *
	 * @return false|string
	 */
	protected function getValidUrl($url)
	{
		$url = trim($url);

		if (preg_match('/^(\?|\/|#|:)/', $url))
		{
			return false;
		}

		if (strpos($url, "\n") !== false)
		{
			return false;
		}

		if (preg_match('#^(data|https?://data|javascript|about):#i', $url))
		{
			return false;
		}

		if (preg_match('/proxy\.php\?\w+=(http[^&]+)&/i', $url, $match))
		{
			// proxy link of some sort, adjust to the original one
			$proxiedUrl = urldecode($match[1]);
			if (preg_match('/./su', $proxiedUrl))
			{
				$url = $proxiedUrl;
			}
		}

		if (preg_match($this->allowedUrlProtocolRegex, $url))
		{
			return $url;
		}
		else
		{
			return 'http://' . $url;
		}
	}

	public function renderTagUser(array $children, $option, array $tag, array $options)
	{
		$content = $this->renderSubTree($children, $options);
		if ($content === '')
		{
			return '';
		}

		$userId = intval($option);
		if ($userId <= 0)
		{
			return $content;
		}

		return $this->getRenderedUser($content, $userId);
	}

	protected function getRenderedUser($content, int $userId)
	{
		$link = \XF::app()->router('public')->buildLink('full:members', ['user_id' => $userId]);

		return $this->wrapHtml(
			'<a href="' . htmlspecialchars($link) . '" class="username" data-xf-init="member-tooltip" data-user-id="' . $userId .  '" data-username="' . $content . '">',
			$content,
			'</a>'
		);
	}

	public function renderTagTable(array $children, $option, array $tag, array $options)
	{
		$rows = [];
		$columnCounts = [];
		$lostAndFound = [];
		foreach ($children as $child)
		{
			if (is_array($child))
			{
				if ($child['tag'] === 'tr')
				{
					$rows[] = $this->renderTableRow($child, $options, $columnCount, $lostAndFound);
					$columnCounts[] = $columnCount;
				}
				else
				{
					$lostAndFound[] = $this->renderSubTree([$child], $options);
				}
			}
			else if (trim($child) !== '')
			{
				$lostAndFound[] = $this->renderSubTree([$child], $options);
			}
		}

		$maxColumnCount = max($columnCounts ?: [0]);
		foreach ($columnCounts as $i => $columnCount)
		{
			if ($columnCount < $maxColumnCount)
			{
				$td = strpos($rows[$i], '<th') !== false ? 'th' : 'td';
				$filler = str_repeat("<$td></$td>", $maxColumnCount - $columnCount);
				$rows[$i] = preg_replace('#</tr>$#', "$filler\0", $rows[$i]);
			}
		}

		return $this->renderFinalTableHtml(implode('', $rows), $option, implode("\n", $lostAndFound));
	}

	protected function renderFinalTableHtml($tableHtml, $tagOption, $extraContent)
	{
		return "<div class=\"bbTable\">\n<table style='width: 100%'>$tableHtml</table>\n$extraContent</div>";
	}

	protected function renderTableRow(array $tag, array $options, &$columnCount, array &$lostAndFound)
	{
		$output = '';
		$columnCount = 0;
		foreach ($tag['children'] as $child)
		{
			if (is_array($child))
			{
				if ($child['tag'] === 'td' || $child['tag'] === 'th')
				{
					$output .= $this->renderTableCell($child, $options);
					$columnCount++;
				}
				else
				{
					$lostAndFound[] = $this->renderSubTree([$child], $options);
				}
			}
			else if (trim($child) !== '')
			{
				$lostAndFound[] = $this->renderSubTree([$child], $options);
			}
		}

		return "<tr>$output</tr>";
	}

	protected function renderTableCell(array $tag, array $options)
	{
		$output = $this->renderSubTree($tag['children'], $options);
		return "<$tag[tag]>$output</$tag[tag]>";
	}

	protected function trimChildrenList(array &$children)
	{
		$keys = array_keys($children);
		$firstKey = reset($keys);
		$lastKey = end($keys);

		if (is_string($children[$firstKey]))
		{
			$children[$firstKey] = ltrim($children[$firstKey]);
		}
		if (is_string($children[$lastKey]))
		{
			$children[$lastKey] = rtrim($children[$lastKey]);
		}
	}

	public static function factory(\XF\App $app)
	{
		$renderer = new static($app->stringFormatter(), $app->templater());
		$renderer->addMediaSites($app['bbCode.media']);

		return $renderer;
	}
}