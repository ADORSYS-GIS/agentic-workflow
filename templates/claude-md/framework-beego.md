## Beego Conventions

### Project Structure
- Follow Beego MVC structure: `controllers/`, `models/`, `routers/`, `views/`, `conf/`
- Entry point: `main.go` with `beego.Run()`
- Configuration: `conf/app.conf` with INI-style settings
- Controllers: `controllers/{resource}.go` extending `beego.Controller`
- Models: `models/{resource}.go` using Beego ORM
- Routers: `routers/router.go` for route registration
- Static files: `static/`; views: `views/`

### Controller Patterns
- Extend `beego.Controller` for all controllers
- Override HTTP methods: `func (c *UserController) Get()`, `Post()`, `Put()`, `Delete()`
- Access params: `c.GetString("name")`, `c.GetInt("id")`, `c.Ctx.Input.Param(":id")`
- Parse JSON body: `json.Unmarshal(c.Ctx.Input.RequestBody, &req)`
- Respond: `c.Data["json"] = data; c.ServeJSON()` for JSON responses
- Template rendering: `c.TplName = "user/index.tpl"` with `c.Data["users"] = users`

### Router Patterns
- Namespace routing: `beego.NewNamespace("/api/v1", beego.NSRouter("/users", &controllers.UserController{}))`
- Auto router: `beego.AutoRouter(&controllers.UserController{})` maps methods to routes automatically
- RESTful router: `beego.Router("/api/users/:id", &controllers.UserController{}, "get:GetOne;put:Update;delete:Delete")`
- Filter (middleware): `beego.InsertFilter("/api/*", beego.BeforeRouter, authFilter)`

### ORM Patterns
- Register models: `orm.RegisterModel(new(User))` in `init()`
- Use QuerySeter for queries: `o.QueryTable("user").Filter("active", true).All(&users)`
- Raw SQL: `o.Raw("SELECT * FROM user WHERE id = ?", id).QueryRow(&user)`
- Transactions: `o.Begin(); ...; o.Commit()` with `o.Rollback()` on error
- Relations: define with `orm:"rel(fk)"`, `orm:"reverse(many)"` struct tags
- Migrations: use `orm.RunSyncdb("default", false, true)` for development; manual migrations for production

### Configuration
- Access config: `beego.AppConfig.String("key")` or `beego.AppConfig.Int("port")`
- Environment-specific config: `runmode = dev|prod|test` in `app.conf`
- Section-based config: `[dev]`, `[prod]` sections in `app.conf`
- Use environment variables: `${ENV_VAR||default}` syntax in config files

### Anti-Patterns to Avoid
- Do not use `AutoRouter` in production APIs — explicit routing is safer and more predictable
- Do not use Beego ORM's `RunSyncdb` for production database changes — use proper migrations
- Do not put business logic in controllers — delegate to model methods or service functions
- Do not use global ORM instance — create per-request or use connection pooling
- Do not skip input validation — validate all user input before passing to ORM queries
