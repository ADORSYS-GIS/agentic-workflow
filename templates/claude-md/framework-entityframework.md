## Entity Framework Core Conventions

### Project Structure
- DbContext: `Data/{ProjectName}DbContext.cs` with entity `DbSet<T>` properties
- Entity configurations: `Data/Configurations/{Entity}Configuration.cs` implementing `IEntityTypeConfiguration<T>`
- Entities: `Models/Entities/` for database-mapped classes
- Migrations: generated in `Data/Migrations/` via `dotnet ef migrations add`
- Repositories: `Data/Repositories/` if using repository pattern over raw DbContext
- DTOs: `Models/DTOs/` for request/response shapes (never expose entities directly)

### DbContext Patterns
- Register as scoped service: `builder.Services.AddDbContext<AppDbContext>(options => options.UseNpgsql(connectionString))`
- Keep DbContext focused — one per bounded context in large applications
- Use `DbSet<T>` for each aggregate root; related entities are navigated through relationships
- Override `OnModelCreating` to apply configurations: `modelBuilder.ApplyConfigurationsFromAssembly(typeof(AppDbContext).Assembly)`
- Never use `DbContext` as a singleton — it is not thread-safe

### Entity Configuration
- Use Fluent API in `IEntityTypeConfiguration<T>` over data annotations for complex mappings
- Configure: table name, primary key, indexes, relationships, constraints, value conversions
- Always configure cascade delete behavior explicitly — defaults can cause unintended data loss
- Use `HasIndex` with `.IsUnique()` for unique constraints
- Use value converters for enum-to-string mapping: `.HasConversion<string>()`
- Use owned types for value objects: `builder.OwnsOne(e => e.Address)`

### Query Patterns
- Use `AsNoTracking()` for read-only queries — significant performance improvement
- Use `Include()` and `ThenInclude()` for eager loading to avoid N+1 queries
- Use `Select()` projections to load only needed columns
- Use `AsSplitQuery()` for queries with multiple collection includes (prevents Cartesian explosion)
- Filter at the database level: chain `Where()` before `ToListAsync()`
- Use `IQueryable<T>` for composable queries; materialize with `ToListAsync()` at the boundary

### Migration Patterns
- Generate: `dotnet ef migrations add MigrationName`
- Apply: `dotnet ef database update` (development) or `context.Database.Migrate()` (startup)
- Never edit generated migration files unless fixing an error
- Review migration SQL before applying to production: `dotnet ef migrations script`
- Use idempotent scripts for production: `dotnet ef migrations script --idempotent`

### Performance
- Use `AsNoTracking()` for all read operations that do not need change tracking
- Batch operations: use `ExecuteUpdateAsync()` / `ExecuteDeleteAsync()` (EF Core 7+) for bulk updates
- Use compiled queries for hot paths: `EF.CompileAsyncQuery<TContext, TResult>(...)`
- Avoid loading entire entities for updates — load, modify, save only changed properties
- Configure connection pooling via the connection string

### Anti-Patterns to Avoid
- Do not expose `IQueryable<T>` outside the data layer — materialize to `IEnumerable<T>` or `List<T>`
- Do not return EF entities from API controllers — always map to DTOs
- Do not use `Find()` in loops — batch lookups with `Where(e => ids.Contains(e.Id))`
- Do not call `SaveChanges()` inside loops — batch changes and save once
- Do not ignore migration conflicts — resolve before merging to main
