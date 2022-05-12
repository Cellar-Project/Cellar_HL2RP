<?php

namespace XF\BbCode\Helper;

class Instagram
{
	public static function matchCallback($url, $matchedId, \XF\Entity\BbCodeMediaSite $site, $siteId)
	{
		if (\XF::$time > 1603497600)
		{
			// Instagram is deprecating its legacy oEmbed endpoint on October 24, 2020
			// https://developers.facebook.com/docs/instagram/oembed-legacy
			// The new endpoint requires a Facebook developer app, so it's not something that we can include
			// by default, so we just need to prevent new embeds from working.
			return false;
		}

		return $matchedId;
	}
}