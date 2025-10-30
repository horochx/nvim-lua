-- vim-startuptime：测量 Neovim 启动时间，帮助优化性能
return {
  -- vim-startuptime：分析启动时间，识别慢速插件
  -- 运行多次测试（默认10次）以获得准确的性能数据
  "dstein64/vim-startuptime",
  cmd = "StartupTime",
  config = function()
    vim.g.startuptime_tries = 10
  end,
}
