---@diagnostic disable: inject-field
-- Biome：快速的 Web 项目格式化和 linting 工具，作为 Prettier + ESLint 的替代方案
if lazyvim_docs then
  -- 启用此选项以避免与 Prettier 冲突
  vim.g.lazyvim_prettier_needs_config = true
end

-- Biome 支持的文件类型列表
local supported = {
  "astro",
  "css",
  "graphql",
  "javascript",
  "javascriptreact",
  "json",
  "jsonc",
  "svelte",
  "typescript",
  "typescriptreact",
  "vue",
}

return {
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "biome" } },
  },

  {
    "stevearc/conform.nvim",
    optional = true,
    ---@param opts ConformOpts
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      for _, ft in ipairs(supported) do
        opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
        table.insert(opts.formatters_by_ft[ft], "biome")
      end

      opts.formatters = opts.formatters or {}
      opts.formatters.biome = {
        -- 仅在项目根目录有 biome 配置文件时启用
        require_cwd = true,
      }
    end,
  },

  {
    "nvimtools/none-ls.nvim",
    optional = true,
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = opts.sources or {}
      table.insert(opts.sources, nls.builtins.formatting.biome)
    end,
  },
}
