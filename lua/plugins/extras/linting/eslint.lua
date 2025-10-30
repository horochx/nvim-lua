-- ESLint：JavaScript/TypeScript 代码检查工具，强制代码质量和风格规范
if lazyvim_docs then
  -- 设为 false 可禁用自动格式化
  vim.g.lazyvim_eslint_auto_format = true
end

local auto_format = vim.g.lazyvim_eslint_auto_format == nil or vim.g.lazyvim_eslint_auto_format

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      ---@type table<string, vim.lsp.Config>
      servers = {
        eslint = {
          settings = {
            -- 自动查找工作目录中的 eslintrc，支持 monorepo 结构
            workingDirectories = { mode = "auto" },
            format = auto_format,
          },
        },
      },
      setup = {
        eslint = function()
          if not auto_format then
            return
          end

          -- 注册为次要格式化器，让其他格式化工具优先
          local formatter = LazyVim.lsp.formatter({
            name = "eslint: lsp",
            primary = false,
            priority = 200,
            filter = "eslint",
          })

          LazyVim.format.register(formatter)
        end,
      },
    },
  },
}
