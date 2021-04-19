# mappy.nvim

A tiny utility to call any `*map` commands.

## What's this?

In Vimscript, we can do this.

```vim
nmap <C-u> :echo 'Hello, World!'<CR>
imap <C-t> <buffer> <expr> strftime('%FT%T') 
```

In addition to this, Neovim has two functions for Lua -- `nvim_set_keymap`, `nvim_buf_set_keymap` --, and they are so annoying.

```lua
vim.api.nvim_set_keymap('n', '<C-u>', [[:echo 'Hello, World!']], {})
vim.api.nvim_buf_set_keymap(0, '<C-t>', [[strftime('%FT%T')]], {expr = true})
```

Too complex and too long syntax. mappy.nvim solves this.

```lua
local mappy = require'mappy'
mappy.nmap('<C-u>', [[:echo 'Hello, World!']])
mappy.imap({'expr', 'buffer'}, [[strftime('%FT%T')]])
```

So simple!

## Features

### map functions

mappy.nvim supplies functions below.

<details><summary>All functions</summary>

<table>
<thead>
<tr><th>mappy.nvim</th><th>equivalent in Vimscript</th></tr>
</thead>
<tbody>
<tr><td><code>map</code></td><td><code>map</code></td></tr>
<tr><td><code>map_</code></td><td><code>map!</code></td></tr>
<tr><td><code>nmap</code></td><td><code>nmap</code></td></tr>
<tr><td><code>vmap</code></td><td><code>vmap</code></td></tr>
<tr><td><code>xmap</code></td><td><code>xmap</code></td></tr>
<tr><td><code>smap</code></td><td><code>smap</code></td></tr>
<tr><td><code>omap</code></td><td><code>omap</code></td></tr>
<tr><td><code>imap</code></td><td><code>imap</code></td></tr>
<tr><td><code>lmap</code></td><td><code>lmap</code></td></tr>
<tr><td><code>cmap</code></td><td><code>cmap</code></td></tr>
<tr><td><code>tmap</code></td><td><code>tmap</code></td></tr>
<tr><td><code>noremap</code></td><td><code>noremap</code></td></tr>
<tr><td><code>noremap_</code></td><td><code>noremap!</code></td></tr>
<tr><td><code>nnoremap</code></td><td><code>nnoremap</code></td></tr>
<tr><td><code>vnoremap</code></td><td><code>vnoremap</code></td></tr>
<tr><td><code>xnoremap</code></td><td><code>xnoremap</code></td></tr>
<tr><td><code>snoremap</code></td><td><code>snoremap</code></td></tr>
<tr><td><code>onoremap</code></td><td><code>onoremap</code></td></tr>
<tr><td><code>inoremap</code></td><td><code>inoremap</code></td></tr>
<tr><td><code>lnoremap</code></td><td><code>lnoremap</code></td></tr>
<tr><td><code>cnoremap</code></td><td><code>cnoremap</code></td></tr>
<tr><td><code>tnoremap</code></td><td><code>tnoremap</code></td></tr>
<tr><td><code>unmap</code></td><td><code>unmap</code></td></tr>
<tr><td><code>unmap_</code></td><td><code>unmap!</code></td></tr>
<tr><td><code>nunmap</code></td><td><code>nunmap</code></td></tr>
<tr><td><code>vunmap</code></td><td><code>vunmap</code></td></tr>
<tr><td><code>xunmap</code></td><td><code>xunmap</code></td></tr>
<tr><td><code>sunmap</code></td><td><code>sunmap</code></td></tr>
<tr><td><code>ounmap</code></td><td><code>ounmap</code></td></tr>
<tr><td><code>iunmap</code></td><td><code>iunmap</code></td></tr>
<tr><td><code>lunmap</code></td><td><code>lunmap</code></td></tr>
<tr><td><code>cunmap</code></td><td><code>cunmap</code></td></tr>
<tr><td><code>tunmap</code></td><td><code>tunmap</code></td></tr>
</tbody>
</table>
</details>

Names of functions are almost the same as Vimscript's ones. An exception for this exists. It is `map!` (and `noremap!`, `unmap!`) -- in mappy.nvim, you can use `map_` (and `noremap_`, `unmap_`) for that.

### map to Lua functions

mappy.nvim can map keys to Lua functions! This cannot do with the original `nvim_set_keymap`, `nvim_buf_set_keymap`.

```lua
mappy.imap({'buffer'}, '<C-t>', function()
  print'Hello, World!'
end)
```

#### Limitation

Lua functions cannot be mapped to `<expr>` mappings.

### Utility functions to map one to multiple keys

You can use `bind()` for this.

```lua
mappy.bind('nit', {'buffer'}, '<A-t>', function()
  print(os.date('%FT%T'))
end)
```

This can call the function with `<A-t>` in normal, insert, and terminal modes.

`bind()` does mappings with `noremap = true`. You can use recursive mappings with `rbind()`.

```lua
mappy.rbind('nv', {'buffer'}, '<C-t>', 'n')
```

### Utility function to map for buffers

`add_buffer_maps()` calls functions to run mappy with `{'buffer'}`.

```lua
mappy.add_buffer_maps(function()
  mappy.imap({'expr'}, '<C-t>', [[strftime("%FT%T")]])
end)
```

This adds `{'buffer'}` and call `nvim_buf_set_keymap` automatically.

## See also

<dl>
<dt><a href="https://github.com/svermeulen/vimpeccable">svermeulen/vimpeccable</a></dt>
<dd>Actually, this plugin is a subset of vimpeccable. I imitated the mapping feature only from it.</dd>
<dt><a href="https://en.wikipedia.org/wiki/Mappy">Mappy - Wikipedia</a></dt>
<dd>Mappy is a great game. (no related for this plugin ;)</dd>
</dl>
