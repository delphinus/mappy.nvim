local nvim_map_setter = require'mapper.nvim_map_setter'

local Map = {}

function Map.new(map_setter)
  local self = {
    Map = Map,
    buffer = false,
    funcs = {},
    funcs_var_name = ('__map_funcs_%d__'):format(vim.loop.now()),
    map_setter = map_setter or nvim_map_setter,
    mapped = {
      global = {
        n = {}, v = {}, x = {}, s = {}, o = {}, i = {}, l = {}, c = {}, t = {},
      },
      buffer = {
        n = {}, v = {}, x = {}, s = {}, o = {}, i = {}, l = {}, c = {}, t = {},
      },
    },
    map_methods = {
      map = {mode = ''},
      map_ = {mode = '!'},
      nmap = {mode = 'n'},
      vmap = {mode = 'v'},
      xmap = {mode = 'x'},
      smap = {mode = 's'},
      omap = {mode = 'o'},
      imap = {mode = 'i'},
      lmap = {mode = 'l'},
      cmap = {mode = 'c'},
      tmap = {mode = 't'},
      noremap = {mode = '', noremap = true},
      noremap_ = {mode = '!', noremap = true},
      nnoremap = {mode = 'n', noremap = true},
      vnoremap = {mode = 'v', noremap = true},
      xnoremap = {mode = 'x', noremap = true},
      snoremap = {mode = 's', noremap = true},
      onoremap = {mode = 'o', noremap = true},
      inoremap = {mode = 'i', noremap = true},
      lnoremap = {mode = 'l', noremap = true},
      cnoremap = {mode = 'c', noremap = true},
      tnoremap = {mode = 't', noremap = true},
      unmap = {mode = '', delete = true},
      unmap_ = {mode = '!', delete = true},
      nunmap = {mode = 'n', delete = true},
      vunmap = {mode = 'v', delete = true},
      xunmap = {mode = 'x', delete = true},
      sunmap = {mode = 's', delete = true},
      ounmap = {mode = 'o', delete = true},
      iunmap = {mode = 'i', delete = true},
      lunmap = {mode = 'l', delete = true},
      cunmap = {mode = 'c', delete = true},
      tunmap = {mode = 't', delete = true},
    },
    special_mode = {
      [''] = {'n', 'v', 'o'},
      ['!'] = {'i', 'c'},
    },
  }
  _G[self.funcs_var_name]= self.funcs
  return setmetatable(self, {__index = Map._index})
end

function Map:_index(key)
  if self.Map[key] then
    return self.Map[key]
  elseif key == 'bind' then
    return self:__bind(true)
  elseif key == 'rbind' then
    return self:__bind()
  elseif key == 'add_buffer_maps' then
    return self:__add_buffer_maps()
  end
  local m = self.map_methods[key]
  if m then
    return m.delete and self:__unmap(m.mode) or self:__map(m.mode, m.noremap)
  end
 error('unknown method: '..key)
end

function Map:__bind(noremap)
  local this = self
  return function(...)
    local opts = {}
    local modes = ''
    local lhs = ''
    local rhs = ''
    if select('#', ...) == 4 then
      modes, opts, lhs, rhs = select(1, ...)
      vim.validate{
        opts = {opts, 'table'},
        modes = {modes, function(v)
          return type(v) == 'string' and v:match'^[nvxsoilct!]+$'
        end, 'mode string'},
        lhs = {lhs, function(v)
          return type(v) == 'string' or type(v) == 'table'
        end},
        rhs = {rhs, function(v)
          return type(v) == 'string' or type(v) == 'function'
        end, 'string or function'},
      }
    elseif select('#', ...) == 3 then
      modes, lhs, rhs = select(1, ...)
      vim.validate{
        modes = {modes, 'string'},
        lhs = {lhs, function(v)
          return type(v) == 'string' or type(v) == 'table'
        end},
        rhs = {rhs, function(v)
          return type(v) == 'string' or type(v) == 'function'
        end, 'string or function'},
      }
    else
      error'bind, rbind need (mode, lhs, rhs) atleast'
    end
    local lhss = type(lhs) == 'string' and {lhs} or lhs
    for _, l in ipairs(lhss) do
      if modes == '' then
        this:__map('', noremap)(opts, l, rhs)
      else
        for m in modes:gmatch'.' do
          this:__map(m, noremap)(opts, l, rhs)
        end
      end
    end
  end
end

function Map:__map(mode, noremap)
  local this = self
  return function(...)
    local opts_list, lhs, rhs
    if select('#', ...) == 3 then
      opts_list = (select(1, ...))
      lhs = (select(2, ...))
      rhs = self:__rhs((select(3, ...)))
    elseif select('#', ...) == 2 then
      opts_list = {}
      lhs = (select(1, ...))
      rhs = self:__rhs((select(2, ...)))
    else
      error'map funcs needs (lhs, rhs) at least'
    end
    local opts = {}
    for _, v in ipairs(opts_list) do
       opts[v] = true
    end
    if noremap then
       opts.noremap = noremap
    end
    if this.buffer or opts.buffer then
      this:__clean_up(mode, lhs, {buffer = true, value = true})
      opts.buffer = nil
      this.map_setter.buf_set(0, mode, lhs, rhs, opts)
    else
      this:__clean_up(mode, lhs, {value = true})
      this.map_setter.set(mode, lhs, rhs, opts)
    end
  end
end

function Map:__unmap(mode)
  local this = self
  return function(...)
    local opts_list, lhs
    if select('#', ...) == 2 then
      opts_list = (select(1, ...))
      lhs = (select(2, ...))
    else
      opts_list = {}
      lhs = (select(1, ...))
    end
    local opts = {}
    for _, v in ipairs(opts_list) do
      opts[v] = true
    end
    this:__clean_up(mode, lhs, opts)
  end
end

function Map:__clean_up(mode, lhs, opts)
  local real_modes = self.special_mode[mode] or {mode}
  for _, m in ipairs(real_modes) do
    local mapped = self.mapped[opts.buffer and 'buffer' or 'global']
    if mapped[m][lhs] then
      local ok, err
      if opts.buffer then
        ok, err = pcall(self.map_setter.buf_del, 0, m, lhs)
      else
        ok, err = pcall(self.map_setter.del, m, lhs)
      end
      -- raise the error when it is not E31: No such mapping.
      if not ok and not err:match'E31: ' then
        error(err)
      end
    end
    mapped[m][lhs] = opts.value
  end
end

function Map:__rhs(candidate)
  if type(candidate) == 'string' then
    return candidate
  end
  self.funcs[#self.funcs + 1] = candidate
  return ('<Cmd>lua %s[%d]()<CR>'):format(self.funcs_var_name, #self.funcs)
end

function Map:__add_buffer_maps()
  local this = self
  return function(f)
    vim.validate{
      f = {f, 'function'},
    }
    this.buffer = true
    local ok, err = pcall(f)
    this.buffer = false
    if not ok then
      error(err)
    end
  end
end

return Map.new()
