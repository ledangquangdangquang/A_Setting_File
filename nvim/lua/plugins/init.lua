return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
      "MeanderingProgrammer/render-markdown.nvim",
      name = "render-markdown",
      dependencies = { "nvim-treesitter/nvim-treesitter" },
      config = function()
        require("render-markdown").setup({})
      end,
      ft = "markdown",
  },
 {
  "xiyaowong/transparent.nvim",
  lazy = false,
  priority = 1001,
  config = function()
    require("transparent").setup({
      extra_groups = {
        "Normal", "NormalNC", "NormalFloat", "FloatBorder",
        "TelescopeNormal", "TelescopePromptNormal",
        "TelescopeResultsNormal", "TelescopePreviewNormal",
        "NeoTreeNormal", "LazyNormal", "MasonNormal",
        "NvimTreeNormal",  -- 👈 thêm dòng này
        "NvimTreeNormalNC", -- nếu cần
      },
    })
    vim.cmd("TransparentEnable")
  end,
},


  -- test new blink
  -- 
  -- { import = "nvchad.blink.lazyspec" },

  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },
}
