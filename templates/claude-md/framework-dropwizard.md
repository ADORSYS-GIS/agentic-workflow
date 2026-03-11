## Dropwizard Conventions

### Project Structure
- Entry point: `Application` class extending `io.dropwizard.Application<AppConfiguration>`
- Configuration: `config.yml` mapped to a `Configuration` subclass
- Resources: `com.company.app.resources/` for JAX-RS resource classes
- Services: `com.company.app.service/` for business logic
- Models: `com.company.app.model/` for domain and database entities
- DAOs: `com.company.app.db/` for database access objects (JDBI or Hibernate)
- Health checks: `com.company.app.health/` for service health indicators

### Resource Patterns
- Use JAX-RS annotations: `@Path`, `@GET`, `@POST`, `@PUT`, `@DELETE`
- Validate request bodies with `@Valid` and Hibernate Validator annotations
- Return `Response` for explicit status codes; return entity directly for 200
- Use `@Auth` annotation for authenticated endpoints with an Authenticator
- Register resources in the `run()` method: `environment.jersey().register(new UserResource(dao))`

### Configuration
- Map YAML config to typed `Configuration` class fields
- Use nested config objects: `@Valid @NotNull DatabaseFactory database`
- Environment variable substitution: `${ENV_VAR:-default}` in YAML
- Validate configuration at startup with Bean Validation annotations
- Separate configuration by concern: database, server, logging, custom app config

### Database Access
- Use JDBI for simple SQL queries or Hibernate for complex domain models
- DAOs with JDBI: annotate interface methods with `@SqlQuery`, `@SqlUpdate`
- Register JDBI DAOs: `JdbiFactory.build(environment, config.getDatabase(), "db").onDemand(UserDao.class)`
- Use `@UnitOfWork` on resource methods for Hibernate session-per-request pattern
- Migrations: use `dropwizard-migrations` bundle wrapping Liquibase

### Health Checks
- Implement `HealthCheck` for every external dependency (database, cache, external API)
- Register in `run()`: `environment.healthChecks().register("database", new DatabaseHealthCheck(db))`
- Health endpoint is automatically available at `/healthcheck` on the admin port
- Use health checks for deployment readiness checks and monitoring

### Anti-Patterns to Avoid
- Do not put business logic in resource classes — keep them thin
- Do not skip health checks for external dependencies
- Do not use field injection — pass dependencies via constructor in `run()`
- Do not return Hibernate entities directly — use representation (DTO) classes
- Do not ignore configuration validation — startup failures are easier to debug than runtime ones
