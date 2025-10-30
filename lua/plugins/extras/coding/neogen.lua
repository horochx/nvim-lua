-- Neogen：自动生成函数、类等的文档注释，支持多种语言的注释风格
return {
  "danymat/neogen",
  dependencies = LazyVim.has("mini.snippets") and { "mini.snippets" } or {},
  cmd = "Neogen",
  keys = {
    {
      "<leader>cn",
      function()
        require("neogen").generate()
      end,
      desc = "Generate Annotations (Neogen)",
    },
  },
  opts = function(_, opts)
    if opts.snippet_engine ~= nil then
      return
    end

    -- 自动检测已安装的代码片段引擎并配置
    local map = {
      ["LuaSnip"] = "luasnip",
      ["mini.snippets"] = "mini",
      ["nvim-snippy"] = "snippy",
      ["vim-vsnip"] = "vsnip",
    }

    for plugin, engine in pairs(map) do
      if LazyVim.has(plugin) then
        opts.snippet_engine = engine
        return
      end
    end

    -- Neovim 0.10+ 内置 snippet 支持
    if vim.snippet then
      opts.snippet_engine = "nvim"
    end
  end,
}
