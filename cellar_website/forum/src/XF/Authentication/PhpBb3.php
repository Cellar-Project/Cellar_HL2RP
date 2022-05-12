<?php

namespace XF\Authentication;

use function is_string;

class PhpBb3 extends AbstractAuth
{
	public function generate($password)
	{
		throw new \LogicException('Cannot generate authentication for this type.');
	}

	public function authenticate($userId, $password)
	{
		if (!is_string($password) || $password === '' || empty($this->data))
		{
			return false;
		}

		$passwordHash = new PasswordHash(8, true);

		if ($this->isLegacyHash())
		{
			return $passwordHash->CheckPassword($password, $this->data['hash']);
		}
		else
		{
			return password_verify($password, $this->data['hash']);
		}
	}

	public function getAuthenticationName()
	{
		return 'XF:PhpBb3';
	}
}