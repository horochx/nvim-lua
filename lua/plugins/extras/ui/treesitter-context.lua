-- Treesitter Context：在顶部显示当前函数/类的上下文
return {
  -- Treesitter Context：在窗口顶部固定显示当前代码块的上下文
  -- 当函数很长时，始终显示函数名和签名，避免迷失在代码中
  "nvim-treesitter/nvim-treesitter-context",
  event = "LazyFile",
  opts = function()
    local tsc = require("treesitter-context")
    Snacks.toggle({
      name = "Treesitter Context",
      get = tsc.enabled,
      set = function(state)
        if state then
          tsc.enable()
        else
          tsc.disable()
        end
      end,
    }):map("<leader>ut")
    return { mode = "cursor", max_lines = 3 }
  end,
}
