---@diagnostic disable: missing-fields
-- 使用 Neovim 0.12+ 原生内联补全功能集成 Copilot，提供更流畅的体验
if lazyvim_docs then
  -- 原生内联补全不支持作为常规补全源
  vim.g.ai_cmp = false
end

if LazyVim.has_extra("ai.copilot-native") then
  if vim.fn.has("nvim-0.12") == 0 then
    LazyVim.error("You need Neovim >= 0.12 to use the `ai.copilot-native` extra.")
    return {}
  end
  -- 避免与 copilot.lua 插件冲突
  if LazyVim.has_extra("ai.copilot") then
    LazyVim.error("Please disable the `ai.copilot` extra if you want to use `ai.copilot-native`")
    return {}
  end
end

vim.g.ai_cmp = false
local status = {} ---@type table<number, "ok" | "error" | "pending">

return {
  desc = "Native Copilot LSP integration. Requires Neovim >= 0.12",
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        copilot = {
          -- stylua: ignore
          keys = {
            {
              "<M-]>",
              function() vim.lsp.inline_completion.select({ count = 1 }) end,
              desc = "Next Copilot Suggestion",
              mode = { "i", "n" },
            },
            {
              "<M-[>",
              function() vim.lsp.inline_completion.select({ count = -1 }) end,
              desc = "Prev Copilot Suggestion",
              mode = { "i", "n" },
            },
          },
        },
      },
      setup = {
        copilot = function()
          -- 延迟启用以确保 LSP 完全初始化
          vim.schedule(function()
            vim.lsp.inline_completion.enable()
          end)
          -- 注册接受动作以支持统一的快捷键
          LazyVim.cmp.actions.ai_accept = function()
            return vim.lsp.inline_completion.get()
          end

          -- 仅在未启用 Sidekick 时配置状态处理器
          if not LazyVim.has_extra("ai.sidekick") then
            vim.lsp.config("copilot", {
              handlers = {
                didChangeStatus = function(err, res, ctx)
                  if err then
                    return
                  end
                  status[ctx.client_id] = res.kind ~= "Normal" and "error" or res.busy and "pending" or "ok"
                  if res.status == "Error" then
                    LazyVim.error("Please use `:LspCopilotSignIn` to sign in to Copilot")
                  end
                end,
              },
            })
          end
        end,
      },
    },
  },

  -- 显示 Copilot 状态以便监控服务可用性
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    event = "VeryLazy",
    opts = function(_, opts)
      -- Sidekick 已处理状态显示
      if LazyVim.has_extra("ai.sidekick") then
        return
      end
      table.insert(
        opts.sections.lualine_x,
        2,
        LazyVim.lualine.status(LazyVim.config.icons.kinds.Copilot, function()
          local clients = vim.lsp.get_clients({ name = "copilot", bufnr = 0 })
          return #clients > 0 and status[clients[1].id] or nil
        end)
      )
    end,
  },
}
