fmt:
	echo "===> Formatting"
	stylua lua/ --config-path=.stylua.toml

lint:
	echo "===> Linting"
	luacheck lua/ --globals vim

test:
	echo "===> Testing"
	nvim --headless --noplugin -u scripts/tests/minimal.vim \
        -c "PlenaryBustedDirectory lua/vim-apm {minimal_init = 'scripts/tests/minimal.vim'}"

clean:
	echo "===> Cleaning"
	rm /tmp/lua_*

pr-ready: fmt lint test

