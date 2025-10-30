-- GitUI：终端 Git TUI 客户端集成，提供更美观的 Git 界面
return {

  -- 安装 GitUI 工具
  -- GitUI：使用 Rust 编写的快速 Git 终端界面，替代 lazygit
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "gitui" } },
    keys = {
      {
        "<leader>gG",
        function()
          Snacks.terminal({ "gitui" })
        end,
        desc = "GitUi (cwd)",
      },
      {
        "<leader>gg",
        function()
          Snacks.terminal({ "gitui" }, { cwd = LazyVim.root.get() })
        end,
        desc = "GitUi (Root Dir)",
      },
    },
    init = function()
      -- 删除 lazygit 的文件历史键映射（使用 GitUI 替代）
      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimKeymaps",
        once = true,
        callback = function()
          pcall(vim.keymap.del, "n", "<leader>gf")
          pcall(vim.keymap.del, "n", "<leader>gl")
        end,
      })
    end,
  },
}
