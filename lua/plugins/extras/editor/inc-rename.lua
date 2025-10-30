-- inc-rename：带实时预览的 LSP 重命名
return {

  -- 增量重命名：使用 Neovim 的命令预览功能
  -- 在重命名前实时预览所有更改，避免意外修改
  recommended = true,
  desc = "Incremental LSP renaming based on Neovim's command-preview feature",
  {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    opts = {},
  },

  -- LSP Keymaps
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ["*"] = {
          keys = {
            {
              "<leader>cr",
              function()
                local inc_rename = require("inc_rename")
                return ":" .. inc_rename.config.cmd_name .. " " .. vim.fn.expand("<cword>")
              end,
              expr = true,
              desc = "Rename (inc-rename.nvim)",
              has = "rename",
            },
          },
        },
      },
    },
  },

  -- Noice 集成：在命令行显示重命名预览
  {
    "folke/noice.nvim",
    optional = true,
    opts = {
      presets = { inc_rename = true },
    },
  },
}
