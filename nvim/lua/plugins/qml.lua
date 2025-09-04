return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        qmlls = {
          cmd = { "qmlls" },
          filetypes = { "qml", "qmljs" },
          root_dir = function(fname)
            return require("lspconfig.util").find_git_ancestor(fname)
          end,
          single_file_support = true,
        },
      },
    },
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "qmlls",
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "qmljs",
      })
    end,
  },
}