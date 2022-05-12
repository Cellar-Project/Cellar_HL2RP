<?php

namespace XF\Mail;

use function count, is_array, strlen, strval;

class Mail
{
	/**
	 * @var Mailer
	 */
	protected $mailer;

	/**
	 * @var \Swift_Message
	 */
	protected $message;

	/**
	 * @var \XF\Language|null
	 */
	protected $language;

	/**
	 * @var \XF\Entity\User|null
	 */
	protected $toUser;

	protected $bounceHmac;
	protected $bounceVerpBase;

	protected $templateName;
	protected $templateParams = [];

	/**
	 * Valid values are 'no', 'auto-generated', 'auto-replied', 'auto-notified'
	 *
	 * @var string
	 */
	protected $autoSubmitted = 'auto-generated';

	/**
	 * @var null|\Exception
	 */
	protected $setupError;

	public function __construct(Mailer $mailer, $templateName = null, array $templateParams = null)
	{
		$this->mailer = $mailer;
		$this->message = new \Swift_Message();

		if ($templateName)
		{
			$this->templateName = $templateName;
			$this->templateParams = is_array($templateParams) ? $templateParams : [];
		}
	}

	public function setTo($email, $name = null)
	{
		try
		{
			$this->message->setTo($email, $name);
		}
		catch (\Swift_SwiftException $e)
		{
			$this->applySetupError($e);

			return $this;
		}

		$this->bounceHmac = $this->mailer->calculateBounceHmac($email);

		$headers = $this->message->getHeaders();
		if ($headers->has('X-To-Validate'))
		{
			$headers->removeAll('X-To-Validate');
		}
		$headers->addTextHeader('X-To-Validate', $this->bounceHmac . '+' . $email);

		$this->applyVerp();

		$this->toUser = null;

		return $this;
	}

	public function setToUser(\XF\Entity\User $user)
	{
		if (!$user->email)
		{
			$this->setupError = new \Exception("Trying to send email to user without email (ID: $user->user_id)");

			return $this;
		}

		$this->setTo($user->email, $user->username);

		$language = \XF::app()->userLanguage($user);
		$this->setLanguage($language);

		$this->toUser = $user;

		return $this;
	}

	public function getToUser()
	{
		return $this->toUser;
	}

	public function setFrom($email, $name = null)
	{
		try
		{
			$this->message->setFrom($email, $name);
		}
		catch (\Swift_SwiftException $e)
		{
			$this->applySetupError($e);
		}

		return $this;
	}

	public function setReplyTo($email, $name = null)
	{
		try
		{
			$this->message->setReplyTo($email, $name);
		}
		catch (\Swift_SwiftException $e)
		{
			$this->applySetupError($e);
		}

		return $this;
	}

	public function setReturnPath($email, $useVerp = false)
	{
		$email = preg_replace('/["\'\s\\\\]/', '', $email);

		try
		{
			$this->message->setReturnPath($email);
		}
		catch (\Swift_SwiftException $e)
		{
			$this->applySetupError($e);
		}

		if ($useVerp)
		{
			$this->bounceVerpBase = $email;
			$this->applyVerp();
		}

		return $this;
	}

	public function setListUnsubscribe($unsubEmail, $useVerp = false)
	{
		if (!$unsubEmail || !$this->toUser)
		{
			// if we're not sending to an actual user, or no unsub email no point in setting header
			return $this;
		}

		$unsubEmail = preg_replace('/["\'\s\\\\]/', '', $unsubEmail);
		$hmac = substr($this->toUser->getEmailConfirmKey(), 0, 8);
		$userEmail = $this->toUser->email;

		if ($useVerp)
		{
			$verpAddress = $this->getVerpAddress($hmac, $unsubEmail);
			if ($verpAddress)
			{
				$unsubEmail = $verpAddress;
			}
		}

		// if we have a verp address at this point, great. if not, then pop some query
		// string parameters into the mailto: link for when we parse the requests later.
		$unsubEmailHeaderVal = '<mailto:' . $unsubEmail . '?' . http_build_query([
			'subject' => '[List-Unsubscribe[' . $hmac . ',' . $userEmail . ']]'
		], '', '&', PHP_QUERY_RFC3986) . '>';

		$this->message->getHeaders()->addTextHeader('List-Unsubscribe', $unsubEmailHeaderVal);

		return $this;
	}

	protected function applyVerp()
	{
		$verpAddress = $this->getVerpAddress($this->bounceHmac, $this->bounceVerpBase);
		if ($verpAddress)
		{
			try
			{
				$this->message->setReturnPath($verpAddress);
			}
			catch (\Swift_SwiftException $e)
			{
				$this->applySetupError($e);
			}
		}

		return $verpAddress;
	}

	protected function getVerpAddress($hmac, $verpBase, $to = null)
	{
		if (!$hmac || !$verpBase)
		{
			return null;
		}

		if (!$to)
		{
			$toAll = $this->message->getTo();
			if (!$toAll || count($toAll) > 1)
			{
				// 0 or 2+ to addresses, so we can't really do verp
				return null;
			}

			$to = key($toAll);
		}

		$verpValue = str_replace('@', '=', $to);
		$verpAddress = str_replace('@', "+{$hmac}+$verpValue@", $verpBase);
		$verpAddress = preg_replace('/["\'\s\\\\]/', '', $verpAddress);

		return $verpAddress;
	}

	public function setSender($sender, $name = null)
	{
		try
		{
			$this->message->setSender($sender, $name);
		}
		catch (\Swift_SwiftException $e)
		{
			$this->applySetupError($e);
		}

		return $this;
	}

	public function setId($id)
	{
		try
		{
			$this->message->setId($id);
		}
		catch (\Swift_SwiftException $e)
		{
			$this->applySetupError($e);
		}

		return $this;
	}

	public function addHeader($name, $value)
	{
		$this->message->getHeaders()->addTextHeader($name, $value);

		return $this;
	}

	public function setContent($subject, $htmlBody, $textBody = null)
	{
		$htmlBodyStr = strval($htmlBody);
		$textBodyStr = strval($textBody);

		if (!strlen($htmlBodyStr) && !strlen($textBodyStr))
		{
			throw new \InvalidArgumentException("Must provide at least one of the HTML and text bodies");
		}

		if ($textBody === null)
		{
			$textBodyStr = $this->mailer->generateTextBody($htmlBodyStr);
		}

		$subject = preg_replace('#[\r\n\t]\s*#', ' ', $subject);
		$subject = preg_replace('#( ){2,}#', ' ', $subject);
		$subject = trim($subject);

		$this->message->setSubject($subject);

		if (strlen($textBodyStr) && !strlen($htmlBodyStr))
		{
			$this->message->setBody($textBodyStr, 'text/plain', 'utf-8');
		}
		else
		{
			if (strlen($htmlBodyStr))
			{
				$this->message->addPart($htmlBodyStr, 'text/html', 'utf-8');
			}
			if (strlen($textBodyStr))
			{
				$this->message->addPart($textBodyStr, 'text/plain', 'utf-8');
			}
		}

		$this->templateName = null;
		$this->templateParams = [];

		return $this;
	}

	public function setTemplate($name, array $params = [])
	{
		$this->templateName = $name;
		$this->templateParams = $params;

		return $this;
	}

	public function getTemplateName()
	{
		return $this->templateName;
	}

	public function renderTemplate()
	{
		if (!$this->templateName)
		{
			throw new \LogicException("Cannot render an email template without one specified");
		}

		$output = $this->mailer->renderMailTemplate(
			$this->templateName, $this->templateParams, $this->language, $this->toUser
		);

		$this->setContent($output['subject'], $output['html'], $output['text']);

		if ($output['headers'])
		{
			$headers = $this->message->getHeaders();
			foreach ($output['headers'] AS $header => $value)
			{
				$headers->addTextHeader($header, $value);
			}
		}

		return $this;
	}

	public function setLanguage(\XF\Language $language = null)
	{
		$this->language = $language;

		return $this;
	}

	public function getLanguage()
	{
		return $this->language;
	}

	public function setAutoSubmitted(string $autoSubmitted)
	{
		$this->autoSubmitted = $autoSubmitted;

		return $this;
	}

	public function getAutoSubmitted(): string
	{
		return $this->autoSubmitted;
	}

	public function getFromAddress()
	{
		$from = $this->message->getFrom();

		if (!$from)
		{
			return null;
		}

		return is_array($from) ? key($from) : $from;
	}

	/**
	 * @return \Swift_Message
	 */
	public function getMessageObject()
	{
		return $this->message;
	}

	/**
	 * @return \Swift_Message
	 */
	public function getSendableMessage()
	{
		if ($this->templateName)
		{
			$this->renderTemplate();
		}

		return $this->message;
	}

	public function send(\Swift_Transport $transport = null, $allowRetry = true)
	{
		if ($this->setupError)
		{
			$this->logSetupError($this->setupError);
			return 0;
		}

		$message = $this->getSendableMessage();
		if (!$message->getTo())
		{
			return 0;
		}

		switch ($this->autoSubmitted)
		{
			case 'auto-generated':
			case 'auto-replied':
			case 'auto-notified':
				$message->getHeaders()->addTextHeader('Auto-Submitted', $this->autoSubmitted);
				break;
		}

		$dkimOptions = \XF::options()->emailDkim;
		if ($dkimOptions['enabled']
			&& extension_loaded('openssl')
			&& $dkimOptions['domain'] == substr(strrchr($this->getFromAddress(), '@'), 1)
		)
		{
			$keyFile = null;

			try
			{
				$path = 'internal-data://keys/' . $dkimOptions['privateKey'];
				$keyFile = \XF::fs()->read($path);
			}
			catch (\Exception $e)
			{
				\XF::logError("Email DKIM: Key not found at $path");
			}

			if ($keyFile)
			{
				$message->attachSigner(new \Swift_Signers_DKIMSigner($keyFile, $dkimOptions['domain'], 'xenforo'));
			}
		}

		return $this->mailer->send($message, $transport, null, $allowRetry);
	}

	public function queue()
	{
		if ($this->setupError)
		{
			$this->logSetupError($this->setupError);
			return false;
		}

		$message = $this->getSendableMessage();
		if (!$message->getTo())
		{
			return false;
		}

		return $this->mailer->queue($message);
	}

	/**
	 * Handles the application of the setup error. Throws the exception immediately in debug mode.
	 * (In normal execution, queues it for logging when the email is sent.)
	 *
	 * @param \Exception $e
	 * @throws \Exception
	 */
	protected function applySetupError(\Exception $e)
	{
		if (\XF::$debugMode)
		{
			throw $e;
		}

		$this->setupError = $e;
	}

	protected function logSetupError(\Exception $e)
	{
		$to = $this->message->getTo();
		$toEmails = $to ? implode(', ', array_keys($to)) : '[unknown]';

		\XF::logException($this->setupError, false, "Email to {$toEmails} failed setup:");
	}
}