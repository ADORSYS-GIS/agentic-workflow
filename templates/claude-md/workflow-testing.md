## Testing Conventions

**Test Frameworks:** {{TEST_FRAMEWORKS}}

### Test File Naming and Location
- Test files live alongside source files or in a parallel `tests/`/`__tests__` directory — follow the established project convention
- Name test files to match the module they test: `user-service.test.ts`, `test_user_service.py`, `UserServiceTest.java`
- Group integration tests separately from unit tests (e.g., `tests/integration/`, `tests/unit/`)

### Test Structure (AAA Pattern)
- Every test follows **Arrange / Act / Assert**:
  - **Arrange**: Set up test data, mocks, and preconditions
  - **Act**: Execute the single operation under test
  - **Assert**: Verify the expected outcome
- Separate the three sections with blank lines for readability
- Each test should have exactly one reason to fail — test one behavior per test function

### What to Test
- All public API methods and functions
- Business logic and domain rules
- Edge cases: empty inputs, boundary values, null/undefined, max/min values
- Error paths: invalid input, missing data, network failures, permission denied
- State transitions and side effects

### What NOT to Test
- Framework internals or third-party library behavior
- Private methods directly (test through the public interface)
- Trivial getters/setters with no logic
- Auto-generated code (ORM models, protobuf stubs)
- Implementation details that may change without affecting behavior

### Mocking Philosophy
- Mock external dependencies (HTTP clients, databases, file system, third-party APIs)
- Do NOT mock the unit under test or its direct collaborators (prefer real objects)
- Use dependency injection to make mocking straightforward
- Prefer fakes/stubs over complex mock frameworks when possible
- Assert on behavior (was the method called with correct args?) not implementation
- Reset mocks between tests to prevent state leakage

### Coverage Expectations
- Aim for 80%+ line coverage on business logic and domain code
- 100% coverage on critical paths (authentication, authorization, payment, data validation)
- Do not chase 100% coverage everywhere — diminishing returns on glue code and configuration
- Coverage gates in CI should block PRs that reduce coverage on changed files

### Integration vs Unit Test Boundaries
- **Unit tests**: fast, isolated, no I/O, no network, no database — run in milliseconds
- **Integration tests**: test real interactions between components (API routes, database queries, message queues)
- Integration tests use dedicated test databases/containers, not production-like data
- Run unit tests on every commit; run integration tests in CI pipeline
- Use test containers (Testcontainers, Docker Compose) for integration test infrastructure

### Test Quality
- Tests must be deterministic — no flaky tests; fix or quarantine immediately
- Tests must be independent — no reliance on execution order or shared mutable state
- Use descriptive test names that read as specifications: `should return 404 when user not found`
- Use test data builders or factories to reduce boilerplate setup
- Clean up test resources in teardown/afterEach hooks
