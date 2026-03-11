## Exposed (Kotlin ORM) Conventions

### Project Structure
- Tables: `db/tables/` defining table objects extending `Table` or `IdTable`
- Entities: `db/entities/` for DAO-style entity classes (if using DAO API)
- Repositories: `repositories/` wrapping Exposed queries behind clean interfaces
- Migrations: `db/migrations/` for schema migration scripts (use Flyway or Liquibase alongside)
- Configuration: database connection setup in a dedicated `DatabaseFactory.kt`

### DSL vs DAO API
- **DSL API** (preferred for most cases): type-safe SQL queries, more control, better performance
- **DAO API**: Active Record pattern with entity classes, convenience for simple CRUD
- Choose one style per project for consistency — do not mix DSL and DAO in the same repository
- DSL example: `Users.select { Users.email eq email }.map { it.toUser() }`
- DAO example: `User.find { Users.email eq email }.firstOrNull()`

### Table Definitions (DSL)
- Define tables as `object`: `object Users : UUIDTable("users") { val email = varchar("email", 255).uniqueIndex() }`
- Use appropriate column types: `varchar`, `integer`, `bool`, `uuid`, `datetime`
- Add indexes: `.index()`, `.uniqueIndex()` on columns
- References: `val userId = reference("user_id", Users)` for foreign keys
- Use `UUIDTable`, `LongIdTable`, or `IntIdTable` for auto-generated primary keys

### Transaction Management
- All database operations MUST be wrapped in `transaction { }` or `newSuspendedTransaction { }`
- Use `newSuspendedTransaction` in coroutine contexts (Ktor, Spring WebFlux)
- Configure transaction isolation level when needed: `transaction(transactionIsolation = ...) { }`
- Keep transactions short — do not include HTTP calls or heavy computation inside them
- Use `TransactionManager.current()` only within an active transaction block

### Query Patterns
- Filter: `Users.select { (Users.active eq true) and (Users.age greater 18) }`
- Join: `Users.innerJoin(Orders).select { Orders.amount greater 100 }`
- Aggregate: `Users.slice(Users.id.count()).selectAll().first()[Users.id.count()]`
- Insert: `Users.insert { it[email] = "user@example.com"; it[name] = "Alice" }`
- Update: `Users.update({ Users.id eq userId }) { it[name] = "Bob" }`
- Batch operations: `Users.batchInsert(userList) { user -> this[Users.name] = user.name }`

### Connection Management
- Use `Database.connect()` with HikariCP connection pool for production
- Configure pool size based on expected concurrency (typically 2x CPU cores)
- Initialize the database connection at application startup, not per-request
- Close the connection pool gracefully on application shutdown

### Anti-Patterns to Avoid
- Do not perform database operations outside of `transaction { }` blocks — it will throw
- Do not use `selectAll()` without limits on large tables — always paginate
- Do not map Exposed `ResultRow` to domain objects in the table definition — use repository layer
- Do not hold transactions open during external I/O (HTTP calls, file operations)
- Do not use raw SQL strings when the DSL can express the query type-safely
