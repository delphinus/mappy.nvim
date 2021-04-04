local mapper = require'mapper'

local Tester = {}

function Tester.new(map_setter)
  local self = setmetatable({
    results = {global = {}, buf = {}},
  }, {__index = Tester})
  map_setter = map_setter or {
    set = function(...) self:save({}, ...) end,
    buf_set = function(...) self:save({buf = true}, ...) end,
  }
  self.m = mapper.Map.new(map_setter)
  return self
end

function Tester:save(opts, ...)
  opts = opts or {}
  local r = {}
  for n = 1, select('#', ...) do
    table.insert(r, (select(n, ...)) or 'nil')
  end
  table.insert(self.results[opts.buf and 'buf' or 'global'], r)
end

describe('mapper', function()

  local t
  before_each(function() t = Tester.new() end)

  describe('map()', function()

    describe('with 2 arguments', function()

      describe('and no mode', function()

        describe('and no noremap', function()

          it('calls nvim_set_keymap() with valid arguments', function()
            t.m.map('<C-j>', [[<Cmd>echo 'hoge'<CR>]])
            assert.are.same({
               global = {
                  {'', '<C-j>', [[<Cmd>echo 'hoge'<CR>]], {}},
               },
               buf = {},
            }, t.results)
          end)
        end)

        describe('and with noremap', function()

          it('calls nvim_set_keymap() with valid arguments', function()
            t.m.noremap('<C-j>', [[<Cmd>echo 'hoge'<CR>]])
            assert.are.same({
               global = {
                  {'', '<C-j>', [[<Cmd>echo 'hoge'<CR>]], {noremap = true}},
               },
               buf = {},
            }, t.results)
          end)
        end)
      end)

      describe('with a mode', function()

        describe('and no noremap', function()

          it('calls nvim_set_keymap() with valid arguments', function()
            t.m.nmap('<C-j>', [[<Cmd>echo 'hoge'<CR>]])
            assert.are.same({
               global = {
                  {'n', '<C-j>', [[<Cmd>echo 'hoge'<CR>]], {}},
               },
               buf = {},
            }, t.results)
          end)
        end)

        describe('and noremap', function()

          it('calls nvim_set_keymap() with valid arguments', function()
            t.m.nnoremap('<C-j>', [[<Cmd>echo 'hoge'<CR>]])
            assert.are.same({
               global = {
                  {'n', '<C-j>', [[<Cmd>echo 'hoge'<CR>]], {noremap = true}},
               },
               buf = {},
            }, t.results)
          end)
        end)
      end)
    end)

    describe('with 3 arguments', function()

      describe('and no buffer', function()

        it('calls nvim_set_keymap() with valid arguments', function()
          t.m.nnoremap({'expr'}, '<C-g>', [[3 + 3]])
          assert.are.same({
             global = {
                {'n', '<C-g>', [[3 + 3]], {expr = true, noremap = true}},
             },
             buf = {},
          }, t.results)
        end)
      end)

      describe('and with buffer', function()

        it('calls nvim_buf_set_keymap() with valid arguments', function()
          t.m.nnoremap({'buffer', 'expr'}, '<C-g>', [[3 + 3]])
          assert.are.same({
             global = {},
             buf = {
                {0, 'n', '<C-g>', [[3 + 3]], {expr = true, noremap = true}},
             },
          }, t.results)
        end)
      end)
    end)

    describe('with a function', function()

      it('calls nvim_set_keymap() and enable to call it', function()
        local func_str
        t = Tester.new{
          set = function(...) func_str = (select(3, ...)) end,
        }
        local foo
        t.m.nnoremap('<C-g>', function() foo = 'bar' end)
        vim.cmd(func_str)
        assert.are.same('bar', foo)
      end)
    end)

    describe('with 1 or >=4 arguments', function()

      it('has errors', function()
        assert.has.errors(function() t.m.map('<C-g>') end)
        assert.has.errors(function() t.m.map({}, '<C-g>', [[echo 'hoge']], {}) end)
      end)
    end)
  end)

  describe('bind()', function()

    describe('when with 3 arguments', function()

      it('calls nvim_set_keymap() with valid arguments', function()
        t.m.bind('nvc', '<C-g>', [[<Cmd>echo 'hoge'<CR>]])
        assert.are.same({
          global = {
            {'n', '<C-g>', [[<Cmd>echo 'hoge'<CR>]], {noremap = true}},
            {'v', '<C-g>', [[<Cmd>echo 'hoge'<CR>]], {noremap = true}},
            {'c', '<C-g>', [[<Cmd>echo 'hoge'<CR>]], {noremap = true}},
          },
          buf = {},
        }, t.results)
      end)
    end)

    describe('when with 4 arguments', function()

      describe('and no buffer', function()
        it('calls nvim_set_keymap() with valid arguments', function()
          t.m.bind({'expr'}, 'nvc', '<C-g>', [[3 + 3]])
          assert.are.same({
            global = {
              {'n', '<C-g>', [[3 + 3]], {expr = true, noremap = true}},
              {'v', '<C-g>', [[3 + 3]], {expr = true, noremap = true}},
              {'c', '<C-g>', [[3 + 3]], {expr = true, noremap = true}},
            },
            buf = {},
          }, t.results)
        end)
      end)

      describe('and buffer', function()
        it('calls nvim_buf_set_keymap() with valid arguments', function()
          t.m.bind({'buffer', 'expr'}, 'nvc', '<C-g>', [[3 + 3]])
          assert.are.same({
            global = {},
            buf = {
              {0, 'n', '<C-g>', [[3 + 3]], {expr = true, noremap = true}},
              {0, 'v', '<C-g>', [[3 + 3]], {expr = true, noremap = true}},
              {0, 'c', '<C-g>', [[3 + 3]], {expr = true, noremap = true}},
            },
          }, t.results)
        end)
      end)
    end)

    describe('when with 2 or >=5 arguments', function()

      it('has errors', function()
        assert.has.errors(function() t.m.bind('<C-g>', [[echo 'hoge']]) end)
        assert.has.errors(function() t.m.bind({}, 'n', '<C-g>', [[echo 'hoge']], {}) end)
      end)
    end)
  end)

  describe('rbind()', function()

    describe('when with 4 arguments', function()

      describe('and buffer', function()

        it('calls nvim_buf_set_keymap() with valid arguments', function()
          t.m.rbind({'buffer', 'expr'}, 'nvc', '<C-g>', [[3 + 3]])
          assert.are.same({
            global = {},
            buf = {
              {0, 'n', '<C-g>', [[3 + 3]], {expr = true}},
              {0, 'v', '<C-g>', [[3 + 3]], {expr = true}},
              {0, 'c', '<C-g>', [[3 + 3]], {expr = true}},
            },
          }, t.results)
        end)
      end)
    end)
  end)
end)
