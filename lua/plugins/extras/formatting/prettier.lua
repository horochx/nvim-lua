---@diagnostic disable: inject-field
-- Prettier：流行的代码格式化工具，支持多种 Web 技术栈
if lazyvim_docs then
  -- 启用后仅在找到配置文件时使用 Prettier，避免意外格式化
  vim.g.lazyvim_prettier_needs_config = false
end

---@alias ConformCtx {buf: number, filename: string, dirname: string}
local M = {}

local supported = {
  "css",
  "graphql",
  "handlebars",
  "html",
  "javascript",
  "javascriptreact",
  "json",
  "jsonc",
  "less",
  "markdown",
  "markdown.mdx",
  "scss",
  "typescript",
  "typescriptreact",
  "vue",
  "yaml",
}

--- 检查是否存在 Prettier 配置文件
---@param ctx ConformCtx
function M.has_config(ctx)
  vim.fn.system({ "prettier", "--find-config-path", ctx.filename })
  return vim.v.shell_error == 0
end

--- 检查是否能推断出解析器
---@param ctx ConformCtx
function M.has_parser(ctx)
  local ft = vim.bo[ctx.buf].filetype --[[@as string]]
  -- 支持的文件类型直接返回 true
  if vim.tbl_contains(supported, ft) then
    return true
  end
  -- 否则尝试推断解析器
  local ret = vim.fn.system({ "prettier", "--file-info", ctx.filename })
  ---@type boolean, string?
  local ok, parser = pcall(function()
    return vim.fn.json_decode(ret).inferredParser
  end)
  return ok and parser and parser ~= vim.NIL
end

-- 缓存结果以提升性能
M.has_config = LazyVim.memoize(M.has_config)
M.has_parser = LazyVim.memoize(M.has_parser)

return {
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "prettier" } },
  },

  {
    "stevearc/conform.nvim",
    optional = true,
    ---@param opts ConformOpts
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      for _, ft in ipairs(supported) do
        opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
        table.insert(opts.formatters_by_ft[ft], "prettier")
      end

      opts.formatters = opts.formatters or {}
      opts.formatters.prettier = {
        -- 仅在能推断解析器且（不需要配置或找到配置）时启用
        condition = function(_, ctx)
          return M.has_parser(ctx) and (vim.g.lazyvim_prettier_needs_config ~= true or M.has_config(ctx))
        end,
      }
    end,
  },

  {
    "nvimtools/none-ls.nvim",
    optional = true,
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = opts.sources or {}
      table.insert(opts.sources, nls.builtins.formatting.prettier)
    end,
  },
}
