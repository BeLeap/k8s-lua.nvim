test:
	nvim --headless --noplugin -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/k8s/ { minimal_init = 'tests/minimal_init.lua' }"
