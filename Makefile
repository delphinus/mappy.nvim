test:
	nvim --headless --noplugin -u tests/minimal.vim -c 'PlenaryBustedFile tests/mapper_spec.lua'
