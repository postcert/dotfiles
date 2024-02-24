-- User configuration
--
vim.g.nvim_tree_respect_buf_cwd = 1
if true then
  return {
    -- -- Use <tab> for completion and snippets (supertab)
    -- -- first: disable default <tab> and <s-tab> behavior in LuaSnip
    -- {
    --   "L3MON4D3/LuaSnip",
    --   keys = function()
    --     return {}
    --   end,
    -- },
    -- -- then: setup supertab in cmp
    -- {
    --   "hrsh7th/nvim-cmp",
    --   dependencies = {
    --     "hrsh7th/cmp-emoji",
    --   },
    --   ---@param opts cmp.ConfigSchema
    --   opts = function(_, opts)
    --     local has_words_before = function()
    --       unpack = unpack or table.unpack
    --       local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    --       return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
    --     end
    --
    --     local luasnip = require("luasnip")
    --     local cmp = require("cmp")
    --
    --     opts.mapping = vim.tbl_extend("force", opts.mapping, {
    --       ["<Tab>"] = cmp.mapping(function(fallback)
    --         if cmp.visible() then
    --           cmp.select_next_item()
    --         -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
    --         -- this way you will only jump inside the snippet region
    --         elseif luasnip.expand_or_jumpable() then
    --           luasnip.expand_or_jump()
    --         elseif has_words_before() then
    --           cmp.complete()
    --         else
    --           fallback()
    --         end
    --       end, { "i", "s" }),
    --       ["<S-Tab>"] = cmp.mapping(function(fallback)
    --         if cmp.visible() then
    --           cmp.select_prev_item()
    --         elseif luasnip.jumpable(-1) then
    --           luasnip.jump(-1)
    --         else
    --           fallback()
    --         end
    --       end, { "i", "s" }),
    --     })
    --   end,
    -- },
    -- hardtime.nvim
    {
      "m4xshen/hardtime.nvim",
      dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
      opts = {
        hint = true,
      },
    },
    -- vim-tmux-navigator
    {
      "christoomey/vim-tmux-navigator",
      cmd = {
        "TmuxNavigateLeft",
        "TmuxNavigateDown",
        "TmuxNavigateUp",
        "TmuxNavigateRight",
        "TmuxNavigatePrevious",
      },
      keys = {
        { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
        { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
        { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
        { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
        { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
      },
    },
    -- neorg
    {
      "nvim-neorg/neorg",
      build = ":Neorg sync-parsers",
      -- tag = "*",
      dependencies = { "nvim-lua/plenary.nvim" },
      config = function()
        require("neorg").setup({
          load = {
            ["core.defaults"] = {}, -- Loads default behaviour
            ["core.concealer"] = {}, -- Adds pretty icons to your documents
            ["core.dirman"] = { -- Manages Neorg workspaces
              config = {
                workspaces = {
                  notes = "~/notes",
                },
                default_workspace = "notes",
              },
            },
          },
        })
      end,
      keys = {
        { "<leader>ni", "<cmd>Neorg index<cr>", desc = "Index" },
        { "<leader>njt", "<cmd>Neorg journal today<cr>", desc = "Journal Today" },
        { "<leader>njT", "<cmd>Neorg journal tempplate<cr>", desc = "Journal Template" },
      },
    },
    -- catppuccin
    {
      "catppuccin/nvim",
      lazy = true,
      name = "catppuccin",
      priority = 1000,
      opts = {
        flavour = "frappe",
        transparent_background = true,
        dim_inactive = {
          enabled = false,
          shade = "light",
          percentage = 0.15,
        },
        no_italic = false,
        styles = {
          comments = { "italic" }, -- Change the style of comments
          conditionals = { "italic" },
          loops = {},
          functions = {},
          keywords = {},
          strings = {},
          variables = {},
          numbers = {},
          booleans = {},
          properties = {},
          types = {},
          operators = {},
        },
        integrations = {
          aerial = true,
          alpha = true,
          cmp = true,
          dashboard = true,
          flash = true,
          gitsigns = true,
          headlines = true,
          illuminate = true,
          indent_blankline = { enabled = true },
          leap = true,
          lsp_trouble = true,
          mason = true,
          markdown = true,
          mini = true,
          native_lsp = {
            enabled = true,
            underlines = {
              errors = { "undercurl" },
              hints = { "undercurl" },
              warnings = { "undercurl" },
              information = { "undercurl" },
            },
          },
          navic = { enabled = true, custom_bg = "lualine" },
          neotest = true,
          neotree = true,
          noice = true,
          notify = true,
          semantic_tokens = true,
          telescope = true,
          treesitter = true,
          treesitter_context = true,
          which_key = true,
        },
      },
    },
    {
      "LazyVim/LazyVim",
      opts = {
        colorscheme = "catppuccin",
      },
    },
    -- Golang
    -- {
    --   "ray-x/go.nvim",
    --   dependencies = { -- optional packages
    --     "ray-x/guihua.lua",
    --     "neovim/nvim-lspconfig",
    --     "nvim-treesitter/nvim-treesitter",
    --   },
    --   config = function()
    --     require("go").setup()
    --   end,
    --   event = { "CmdlineEnter" },
    --   ft = { "go", "gomod" },
    --   -- build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
    -- },
    -- Go playground
    {
      "jeniasaigak/goplay.nvim",
      config = function()
        require("goplay").setup()
      end,
    },
    -- Treesitter.textobjects features
    {
      "nvim-treesitter/nvim-treesitter",
      opts = {
        textobjects = {
          swap = {
            enable = true,
            swap_next = {
              ["ga"] = "@parameter.inner",
            },
            swap_previous = {
              ["gA"] = "@parameter.inner",
            },
          },
        },
      },
    },
    {
      "leoluz/nvim-dap-go",
      opts = {
        delve = {
          build_flags = { "-gcflags=all=-N -l" },
        },
      },
    },
    {
      "epwalsh/obsidian.nvim",
      version = "*", -- recommended, use latest release instead of latest commit
      lazy = true,
      ft = "markdown",
      -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
      -- event = {
      --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
      --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
      --   "BufReadPre path/to/my-vault/**.md",
      --   "BufNewFile path/to/my-vault/**.md",
      -- },
      dependencies = {
        -- Required.
        "nvim-lua/plenary.nvim",

        -- see below for full list of optional dependencies 👇
      },
      opts = {
        workspaces = {
          {
            name = "personal",
            path = "~/Dropbox/personal",
          },
        },

        -- see below for full list of options 👇
      },
    },
    { "danilshvalov/org-modern.nvim" },
    {
      "nvim-orgmode/orgmode",
      dependencies = {
        { "nvim-treesitter/nvim-treesitter", lazy = true },
      },
      event = "VeryLazy",
      config = function()
        -- Load treesitter grammar for org
        require("orgmode").setup_ts_grammar()

        -- Setup treesitter
        require("nvim-treesitter.configs").setup({
          highlight = {
            enable = true,
          },
          ensure_installed = { "org" },
        })

        local Menu = require("org-modern.menu")
        -- Setup orgmode
        require("orgmode").setup({
          org_agenda_files = "~/Dropbox/personal/org/**/*",
          org_default_notes_file = "~/Dropbox/personal/org/refile.org",
          ui = {
            menu = {
              handler = function(data)
                Menu:new({
                  window = {
                    margin = { 1, 0, 1, 0 },
                    padding = { 0, 1, 0, 1 },
                    title_pos = "center",
                    border = "single",
                    zindex = 1000,
                  },
                  icons = {
                    separator = "➜",
                  },
                }):open(data)
              end,
            },
          },
        })
      end,
    },
  }
end
