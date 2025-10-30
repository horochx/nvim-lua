-- none-ls (原 null-ls)：将非 LSP 工具（linter、formatter）桥接为 LSP 服务器
return {
  {
    "nvimtools/none-ls.nvim",
    event = "LazyFile",
    dependencies = { "mason.nvim" },
    init = function()
      LazyVim.on_very_lazy(function()
        -- 注册为 LazyVim 格式化器，优先级高于 conform
        LazyVim.format.register({
          name = "none-ls.nvim",
          priority = 200,
          primary = true,
          format = function(buf)
            return LazyVim.lsp.format({
              bufnr = buf,
              filter = function(client)
                return client.name == "null-ls"
              end,
            })
          end,
          sources = function(buf)
            local ret = require("null-ls.sources").get_available(vim.bo[buf].filetype, "NULL_LS_FORMATTING") or {}
            return vim.tbl_map(function(source)
              return source.name
            end, ret)
          end,
        })
      end)
    end,
    opts = function(_, opts)
      local nls = require("null-ls")
      -- 智能查找项目根目录
      opts.root_dir = opts.root_dir
        or require("null-ls.utils").root_pattern(".null-ls-root", ".neoconf.json", "Makefile", ".git")
      -- 默认启用的内置源
      opts.sources = vim.list_extend(opts.sources or {}, {
        nls.builtins.formatting.fish_indent,
        nls.builtins.diagnostics.fish,
        nls.builtins.formatting.stylua,
        nls.builtins.formatting.shfmt,
      })
    end,
  },
}
