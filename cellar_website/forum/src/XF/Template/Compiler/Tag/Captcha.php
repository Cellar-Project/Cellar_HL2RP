<?php

namespace XF\Template\Compiler\Tag;

use XF\Template\Compiler\Syntax\Tag;
use XF\Template\Compiler;

class Captcha extends AbstractTag
{
	public function compile(Tag $tag, Compiler $compiler, array $context, $inlineExpected)
	{
		$tag->assertEmpty();

		if (isset($tag->attributes['force']))
		{
			$force = $compiler->compileForcedExpression($tag->attributes['force'], $context);
		}
		else
		{
			$force = 'false';
		}

		if (isset($tag->attributes['force-visible']))
		{
			$forceVisible = $compiler->compileForcedExpression($tag->attributes['force-visible'], $context);
		}
		else
		{
			$forceVisible = 'false';
		}

		return "{$compiler->templaterVariable}->func('captcha', array({$force}, {$forceVisible}))";
	}
}