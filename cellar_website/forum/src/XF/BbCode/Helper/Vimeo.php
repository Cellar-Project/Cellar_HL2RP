<?php

namespace XF\BbCode\Helper;

class Vimeo
{
	public static function matchCallback($url, $matchedId, \XF\Entity\BbCodeMediaSite $site, $siteId)
	{
		if (preg_match("/\/{$matchedId}\/(?P<key>[0-9a-f]+)/si", $url, $matches))
		{
			$matchedId .= ':' . $matches['key'];
		}
		if (preg_match('/#t=(?P<time>[0-9]+[hms])/si', $url, $matches))
		{
			$matchedId .= ':' . $matches['time'];
		}

		return $matchedId;
	}

	public static function htmlCallback($mediaKey, array $site, $siteId)
	{
		$mediaInfo = explode(':', $mediaKey);

		$id = null;
		$start = null;
		$key = null;

		foreach ($mediaInfo AS $index => $info)
		{
			if ($index === 0)
			{
				$id = $info;
				\XF::dumpToFile("Setting id to $info");
				continue;
			}

			if (preg_match('/[0-9]+[hms]/', $info))
			{
				$start = $info;
				\XF::dumpToFile("Setting start to $info");
			}
			else if (preg_match('/[0-9a-f]+/', $info))
			{
				$key = $info;
				\XF::dumpToFile("Setting key to $info");
			}
		}

		return \XF::app()->templater()->renderTemplate('public:_media_site_embed_vimeo', [
			'id' => rawurlencode($id),
			'start' => $start,
			'key' => $key
		]);
	}
}