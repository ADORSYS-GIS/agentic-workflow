## Symfony Conventions

### Project Structure
- Follow Symfony Flex structure: `src/`, `config/`, `templates/`, `public/`, `tests/`
- Controllers: `src/Controller/{Feature}Controller.php`
- Entities: `src/Entity/` for Doctrine entities
- Repositories: `src/Repository/` for Doctrine repositories
- Services: `src/Service/` for business logic
- DTOs: `src/DTO/` for data transfer objects
- Events: `src/Event/` and `src/EventListener/` for event-driven patterns
- Configuration: `config/packages/` for bundle configuration (YAML/PHP)

### Controller Patterns
- Extend `AbstractController` for standard controllers with shortcuts
- Use attributes for routing: `#[Route('/api/users', name: 'user_list', methods: ['GET'])]`
- Inject services via constructor or method-level `#[Autowire]`
- Use `#[MapRequestPayload]` (Symfony 6.3+) for automatic request body mapping
- Return `JsonResponse` for APIs; use Serializer component for complex serialization
- Keep controllers thin: validate, call service, return response

### Dependency Injection
- Autowiring is enabled by default — type-hint interfaces in constructors
- Define services in `config/services.yaml` or use PHP attributes
- Use `#[Autowire]` for named or configured services
- Use `#[TaggedIterator]` for collections of tagged services
- Prefer constructor injection; avoid container access in services

### Doctrine ORM Patterns
- Entities: `#[ORM\Entity(repositoryClass: UserRepository::class)]`
- Use migrations: `php bin/console doctrine:migrations:diff` and `:migrate`
- Repository custom queries: `createQueryBuilder('u')->where('u.active = :active')`
- Always use DQL or QueryBuilder — never concatenate user input into queries
- Use DTOs for API responses; never serialize entities with all relations loaded

### Form and Validation
- Form types: `src/Form/` for Symfony Form component (web) or manual DTO validation (API)
- Validation constraints: `#[Assert\NotBlank]`, `#[Assert\Email]`, `#[Assert\Length(max: 255)]`
- Validate in controllers: `$errors = $validator->validate($dto)` or use `#[MapRequestPayload]`
- Custom validators: implement `ConstraintValidator` for domain-specific rules

### Security
- Use Symfony Security bundle: firewalls, authenticators, voters
- Voters: `src/Security/Voter/` for fine-grained authorization decisions
- Use `#[IsGranted('ROLE_ADMIN')]` or `$this->denyAccessUnlessGranted()` in controllers
- Authenticators: implement custom auth with `AbstractAuthenticator` or use built-in (JWT, API key)

### Anti-Patterns to Avoid
- Do not inject the `Container` into services — use explicit dependency injection
- Do not skip Doctrine migrations — manual schema changes cause drift
- Do not put business logic in controllers or entities — use services
- Do not return Doctrine entities directly from API endpoints — use DTOs and serialization groups
- Do not use `find()` in loops — batch load with DQL or `findBy(['id' => $ids])`
