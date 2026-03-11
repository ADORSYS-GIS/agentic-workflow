## Python Conventions

### Naming
- Variables, functions, methods: `snake_case`
- Classes: `PascalCase`
- Constants: `SCREAMING_SNAKE_CASE`
- Modules and packages: `snake_case`, short, lowercase
- Private attributes/methods: single leading underscore `_private_method`
- Name-mangled attributes: double leading underscore `__internal` (use sparingly)
- Files: `snake_case.py` — never use hyphens in module names

### Type Safety
- Use type hints for all function signatures (parameters and return types)
- Use `from __future__ import annotations` for forward references (Python 3.7-3.9)
- Prefer `str | None` over `Optional[str]` (Python 3.10+)
- Use `TypedDict` for dictionary shapes, `dataclass` or `Pydantic` models for structured data
- Run `mypy` or `pyright` in CI with strict mode enabled
- Use `Protocol` for structural subtyping instead of ABC when possible

### Import Organization
- Order: (1) standard library, (2) third-party, (3) local — separated by blank lines
- Use `isort` to enforce import ordering automatically
- Prefer absolute imports over relative imports
- Never use wildcard imports (`from module import *`)
- Import modules, not individual names, when the module is well-known (e.g., `import os`, not `from os import path`)

### Error Handling
- Catch specific exceptions, never bare `except:` or `except Exception:`
- Use custom exception classes inheriting from a project-level base exception
- Use `raise ... from err` to preserve exception chains
- Context managers (`with`) for all resource management (files, connections, locks)
- Validate inputs at function boundaries; raise `ValueError`/`TypeError` early

### Patterns and Idioms
- Use f-strings for string formatting (not `%` or `.format()`)
- Use list/dict/set comprehensions over `map()`/`filter()` for readability
- Prefer `pathlib.Path` over `os.path` for file system operations
- Use `dataclasses` or `attrs` for data containers; `Pydantic` for validation
- Use `enum.Enum` for fixed sets of values
- Prefer `collections.defaultdict` and `collections.Counter` over manual dict manipulation
- Use generators and `yield` for large data processing to conserve memory

### Common Pitfalls
- Never use mutable default arguments (`def f(items=[])`); use `None` and initialize inside
- Beware of late binding in closures and lambdas
- Do not modify a list while iterating over it; create a new list or use a copy
- Avoid circular imports by restructuring modules or using deferred imports
- Use `is` for `None` checks (`if x is None`), not `==`
- Remember that `dict.keys()` returns a view, not a list, in Python 3
