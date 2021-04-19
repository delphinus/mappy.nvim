test:
	nvim --headless --noplugin -u tests/minimal.vim -c 'PlenaryBustedFile tests/mappy_spec.lua'
