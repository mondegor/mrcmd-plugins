<?php

// https://www.doctrine-project.org/projects/doctrine-orm/en/2.14/reference/xml-mapping.html

declare(strict_types=1);

namespace App\Users\Domain\Entity;

use App\Shared\Domain\Service\UlidService;

class User
{
    private string $id;
    private string $email;
    private ?string $password = null;

    public function __construct(string $email)
    {
        $this->id = UlidService::generate();
        $this->email = $email;
    }

    public function getId(): string
    {
        return $this->id;
    }

    public function getEmail(): string
    {
        return $this->email;
    }

    public function getPassword(): ?string
    {
        return $this->password;
    }

    public function getRoles(): array
    {
        return [
            'ROLE_USER',
        ];
    }

    public function eraseCredentials(): void
    {
        // TODO: Implement eraseCredentials() method.
    }

    public function getUserIdentifier(): string
    {
        return $this->email;
    }

    public function setPassword(
        ?string $password,
        UserPasswordHasherInterface $passwordHasher
    ): void {
        if (is_null($password)) {
            $this->password = null;
        }

        $this->password = $passwordHasher->hash($this, $password);
    }

}