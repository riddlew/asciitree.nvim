main: check lint

check:
	@echo "Checking format (stylua)..."
	@stylua lua/ --config-path=.stylua.toml --check

fmt:
	@echo "Formatting (stylua)..."
	@stylua lua/ --config-path=.stylua.toml

lint:
	@echo "Linting (luacheck)..."
	@luacheck lua/
