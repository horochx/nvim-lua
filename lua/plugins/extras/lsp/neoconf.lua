-- Neoconf：项目级 LSP 配置管理，支持 .neoconf.json 文件
return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "folke/neoconf.nvim",
        cmd = "Neoconf",
        opts = {},
      },
    },
  },
}
