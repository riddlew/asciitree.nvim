.PHONY: main
main: check lint

.PHONY: check
check:
	@echo "Checking format (stylua)..."
	@stylua lua/ --config-path=.stylua.toml --check

.PHONY: fmt
fmt:
	@echo "Formatting (stylua)..."
	@stylua lua/ --config-path=.stylua.toml

.PHONY: lint
lint:
	@echo "Linting (luacheck)..."
	@luacheck lua/
