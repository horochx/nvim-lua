-- Smear Cursor：为光标移动添加拖尾效果，提供炫酷的视觉体验
return {
  -- Smear Cursor：为光标移动添加平滑的拖尾动画效果
  -- 让光标移动更具视觉冲击力，但不会影响编辑性能
  "sphamba/smear-cursor.nvim",
  event = "VeryLazy",
  cond = vim.g.neovide == nil,
  opts = {
    hide_target_hack = true,
    cursor_color = "none",
  },
  specs = {
    -- 禁用 mini.animate 的光标动画以避免冲突
    {
      "nvim-mini/mini.animate",
      optional = true,
      opts = {
        cursor = { enable = false },
      },
    },
  },
}
