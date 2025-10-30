-- Mini.animate：为 Neovim 添加平滑动画效果
return {
  -- 启用 animate 时禁用 snacks scroll 以避免冲突
  {
    "snacks.nvim",
    opts = {
      scroll = { enabled = false },
    },
  },

  -- Mini.animate：为滚动、光标移动、窗口调整等操作添加平滑动画
  -- 提升视觉体验，让编辑器操作更流畅自然
  {
    "nvim-mini/mini.animate",
    event = "VeryLazy",
    cond = vim.g.neovide == nil,
    opts = function(_, opts)
      -- 鼠标滚动时禁用动画（鼠标滚动通常需要立即响应）
      local mouse_scrolled = false
      for _, scroll in ipairs({ "Up", "Down" }) do
        local key = "<ScrollWheel" .. scroll .. ">"
        vim.keymap.set({ "", "i" }, key, function()
          mouse_scrolled = true
          return key
        end, { expr = true })
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "grug-far",
        callback = function()
          vim.b.minianimate_disable = true
        end,
      })

      -- 延迟设置键映射以覆盖 keymaps.lua 中的默认映射
      -- keymaps.lua 是 VeryLazy 事件中最后执行的，需要用 schedule 确保覆盖
      vim.schedule(function()
        Snacks.toggle({
          name = "Mini Animate",
          get = function()
            return not vim.g.minianimate_disable
          end,
          set = function(state)
            vim.g.minianimate_disable = not state
          end,
        }):map("<leader>ua")
      end)

      local animate = require("mini.animate")
      return vim.tbl_deep_extend("force", opts, {
        resize = {
          timing = animate.gen_timing.linear({ duration = 50, unit = "total" }),
        },
        scroll = {
          timing = animate.gen_timing.linear({ duration = 150, unit = "total" }),
          subscroll = animate.gen_subscroll.equal({
            predicate = function(total_scroll)
              if mouse_scrolled then
                mouse_scrolled = false
                return false
              end
              return total_scroll > 1
            end,
          }),
        },
      })
    end,
  },
}
