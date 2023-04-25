test:
	nvim --headless --noplugin -u scripts/preload.lua -c "lua require('plenary.test_harness').test_directory('tests/k8s', { minimal_init = 'tests/minimal_init.lua' })"

format:
	stylua lua scripts tests
