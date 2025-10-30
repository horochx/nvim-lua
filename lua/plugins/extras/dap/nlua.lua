-- nlua：调试 Neovim Lua 插件和配置的专用调试适配器
return {
  "mfussenegger/nvim-dap",
  dependencies = {
    {
      "jbyuki/one-small-step-for-vimkind",
      config = function()
        local dap = require("dap")
        -- 配置 Lua 调试适配器
        dap.adapters.nlua = function(callback, conf)
          local adapter = {
            type = "server",
            host = conf.host or "127.0.0.1",
            port = conf.port or 8086,
          }
          -- 如需启动新 Neovim 实例进行调试
          if conf.start_neovim then
            local dap_run = dap.run
            -- 临时替换 dap.run 以捕获端口信息
            dap.run = function(c)
              adapter.port = c.port
              adapter.host = c.host
            end
            require("osv").run_this()
            dap.run = dap_run
          end
          callback(adapter)
        end
        dap.configurations.lua = {
          {
            type = "nlua",
            request = "attach",
            name = "Run this file",
            -- 启动新 Neovim 实例以调试当前文件
            start_neovim = {},
          },
          {
            type = "nlua",
            request = "attach",
            name = "Attach to running Neovim instance (port = 8086)",
            port = 8086,
          },
        }
      end,
    },
  },
}
