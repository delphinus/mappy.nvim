local nvim_map_setter = require'mapper.nvim_map_setter'

local Map = {}

function Map.new(map_setter)
  local self = {
    Map = Map,
    buffer = false,
    funcs = {},
    funcs_var_name = ('__map_funcs_%d__'):format(vim.loop.now()),
    map_setter = map_setter or nvim_map_setter,
    map_methods = {
      map = {mode = '', noremap = false},
      nmap = {mode = 'n', noremap = false},
      vmap = {mode = 'v', noremap = false},
      xmap = {mode = 'x', noremap = false},
      smap = {mode = 's', noremap = false},
      omap = {mode = 'o', noremap = false},
      imap = {mode = 'i', noremap = false},
      lmap = {mode = 'l', noremap = false},
      cmap = {mode = 'c', noremap = false},
      tmap = {mode = 't', noremap = false},
      map_ = {mode = '!', noremap = false},
      noremap = {mode = '', noremap = true},
      nnoremap = {mode = 'n', noremap = true},
      vnoremap = {mode = 'v', noremap = true},
      xnoremap = {mode = 'x', noremap = true},
      snoremap = {mode = 's', noremap = true},
      onoremap = {mode = 'o', noremap = true},
      inoremap = {mode = 'i', noremap = true},
      lnoremap = {mode = 'l', noremap = true},
      cnoremap = {mode = 'c', noremap = true},
      tnoremap = {mode = 't', noremap = true},
      noremap_ = {mode = '!', noremap = true},
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
    return self:__map(m.mode, m.noremap)
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
      opts.buffer = nil
      this.map_setter.buf_set(0, mode, lhs, rhs, opts)
    else
      this.map_setter.set(mode, lhs, rhs, opts)
    end
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
    f()
    this.buffer = false
  end
end

return Map.new()
