-- Set catppuccin flavor from nixCats extra
local ok, nixCats_extra = pcall(function() return require('nixCats').extra end)
if ok and nixCats_extra and nixCats_extra.catppuccin_flavour then
  vim.g.catppuccin_flavour = nixCats_extra.catppuccin_flavour
end

local function setup_cmp()
  require 'luasnip'
  require 'blink.cmp'.setup({
    snippets = { preset = 'luasnip' },
    keymap = {
      preset = 'default',
      ['<C-space>'] = {},
    },
    sources = {
      default = { 'lsp', 'path', 'snippets' },
    },
    completion = {
      keyword = { range = 'full' },
      accept = { auto_brackets = { enabled = false }, },
      menu = { auto_show = false, },
      ghost_text = { enabled = true },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
      }
    },
    signature = { enabled = true },
  })
end

local function setup_treesitter()
  require 'nvim-treesitter'.setup {
    playground = {
      enable = true,
      disable = {},
      updatetime = 25,
      persist_queries = false
    },
    highlight = {
      disable = { "sql" },
      enable = true, -- false will disable the whole extension
    },
    indent = {
      enable = true,
    },
    refactor = {
      highlight_definitions = { enable = true },
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "gnn",
        node_incremental = "gnn",
        scope_incremental = "grc",
        node_decremental = "gnp",
      },
    },
    textobjects = {
      select = {
        enable = true,
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ["<leader>ts"] = "@parameter.inner",
        },
        swap_previous = {
          ["<leader>tS"] = "@parameter.inner",
        },
      }
    },
  }
  require 'nvim-treesitter-textobjects'.setup {
  }
end

local function bootstrap()
  require 'conf/options'.setup()
  require 'crates'.setup {}
  setup_cmp()
  require 'conf/lsp'.setup()

  vim.diagnostic.config({
    -- Use the default configuration
    virtual_lines = true
  })
  setup_treesitter()
  require 'conf/autocommands'.setup()
  require 'conf/user_commands'.setup()

  require 'lspkind'.init()
  require 'trouble'.setup {}
  require 'bufferline'.setup {}

  require 'catppuccin'.setup {}
  require 'fidget'.setup {}
  require 'treesj'.setup {}

  require 'oil'.setup {}

  require 'snacks'.setup({
    picker = {
      grep = {
        finder = 'rg',
      },
      layout = {
        preset = 'ivy',
      },
      sources = {
        explorer = {
          hidden = true,
          ignored = false
        },
      },
    },
    indent = {},
    input = {},
    notifier = {},
  })
  require 'conf/mappings'.setup()
  require('neoscroll').setup({
    -- All these keys will be mapped to their corresponding scrolling methods
    mappings = { '<C-u>', '<C-d>', '<C-b>', '<C-f>',
      '<C-e>' },
    hide_cursor = true,            -- Hide cursor while scrolling
    stop_eof = true,               -- Stop at <EOF> when scrolling downwards
    use_local_scrolloff = false,   -- Use the local scope of scrolloff instead of the global scope
    respect_scrolloff = false,     -- Stop scrolling when the cursor reaches the scrolloff limit
    cursor_scrolls_alone = true,   -- The cursor will keep on scrolling even if the window cannot scroll further
    easing_function = 'quadratic', -- Default easing function
    pre_hook = nil,                -- Function to run before the scrolling animation starts
    post_hook = nil,               -- Function to run after the scrolling animation ends
  })

  -- Smear cursor setup
  require('smear_cursor').setup({
    cursor_color = "#d3869b", -- Change to your preferred color or keep default
    stiffness = 0.6,          -- Controls how fast the cursor catches up (lower is smearier)
    trail_length = 0.3,       -- Length of the smear trail
    trailing_delay = 0.02,    -- Delay before the tail starts following
  })
end

bootstrap()
