test:
	nvim --headless --noplugin -u scripts/load_plenary.lua -c "lua require('plenary.test_harness').test_directory('tests/k8s', { minimal_init = 'tests/minimal_init.lua' })"
