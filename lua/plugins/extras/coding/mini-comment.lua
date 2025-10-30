-- mini.comment：快速注释代码，自动识别文件类型选择合适的注释符号
return {
  {
    "nvim-mini/mini.comment",
    event = "VeryLazy",
    opts = {
      options = {
        -- 使用 treesitter 提供的上下文感知注释，在 JSX/TSX 等混合语法中更智能
        custom_commentstring = function()
          return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
        end,
      },
    },
  },
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = true,
    opts = {
      -- 禁用自动命令以与 mini.comment 集成，避免重复触发
      enable_autocmd = false,
    },
  },
}
