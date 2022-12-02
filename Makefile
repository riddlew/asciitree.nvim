.PHONY: main
main: check lint

.PHONY: check
check:
	stylua lua/ test/*_spec.lua --config-path=.stylua.toml --check

.PHONY: fmt
fmt:
	stylua lua/ test/*_spec.lua --config-path=.stylua.toml

.PHONY: lint
lint:
	luacheck lua/ test/*_spec.lua

.PHONY: test
test:
	nvim --headless -c "PlenaryBustedFile test/*_spec.lua" -u 'test/minimal_init.vim'
