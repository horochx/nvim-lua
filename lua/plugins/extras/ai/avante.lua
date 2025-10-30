-- Avante：AI 驱动的智能编程助手，提供对话式代码编辑和重构能力
return {
  -- UI 组件库，为 Avante 提供美观的对话界面
  { "MunifTanjim/nui.nvim", lazy = true },

  {
    "yetone/avante.nvim",
    -- 根据操作系统选择编译方式以确保二进制依赖正确构建
    build = vim.fn.has("win32") ~= 0 and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
      or "make",
    event = "VeryLazy",
    opts = {
      provider = "copilot",
      selection = {
        -- 禁用提示显示以减少视觉干扰
        hint_display = "none",
      },
      behaviour = {
        -- 手动设置快捷键以避免与现有配置冲突
        auto_set_keymaps = false,
      },
    },
    cmd = {
      "AvanteAsk",
      "AvanteBuild",
      "AvanteChat",
      "AvanteClear",
      "AvanteEdit",
      "AvanteFocus",
      "AvanteHistory",
      "AvanteModels",
      "AvanteRefresh",
      "AvanteShowRepoMap",
      "AvanteStop",
      "AvanteSwitchProvider",
      "AvanteToggle",
    },
    keys = {
      { "<leader>aa", "<cmd>AvanteAsk<CR>", desc = "Ask Avante" },
      { "<leader>ac", "<cmd>AvanteChat<CR>", desc = "Chat with Avante" },
      { "<leader>ae", "<cmd>AvanteEdit<CR>", desc = "Edit Avante" },
      { "<leader>af", "<cmd>AvanteFocus<CR>", desc = "Focus Avante" },
      { "<leader>ah", "<cmd>AvanteHistory<CR>", desc = "Avante History" },
      { "<leader>am", "<cmd>AvanteModels<CR>", desc = "Select Avante Model" },
      { "<leader>an", "<cmd>AvanteChatNew<CR>", desc = "New Avante Chat" },
      { "<leader>ap", "<cmd>AvanteSwitchProvider<CR>", desc = "Switch Avante Provider" },
      { "<leader>ar", "<cmd>AvanteRefresh<CR>", desc = "Refresh Avante" },
      { "<leader>as", "<cmd>AvanteStop<CR>", desc = "Stop Avante" },
      { "<leader>at", "<cmd>AvanteToggle<CR>", desc = "Toggle Avante" },
    },
  },

  -- 支持直接粘贴图片到对话中，便于视觉化讨论代码问题
  {
    "HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    optional = true,
    opts = {
      default = {
        -- 使用文件引用而非 base64 以减小文件体积
        embed_image_as_base64 = false,
        prompt_for_file_name = false,
        drag_and_drop = {
          insert_mode = true,
        },
        -- Windows 需要绝对路径以正确处理文件引用
        use_absolute_path = true,
      },
    },
  },

  -- 渲染 Avante 对话窗口中的 Markdown 内容以提升可读性
  {
    "MeanderingProgrammer/render-markdown.nvim",
    optional = true,
    opts = {
      file_types = { "markdown", "Avante" },
    },
    ft = { "markdown", "Avante" },
  },

  -- 将 Avante 集成为 blink.cmp 补全源，在补全菜单中提供 AI 建议
  {
    "saghen/blink.cmp",
    optional = true,
    specs = { "Kaiser-Yang/blink-cmp-avante" },
    opts = {
      sources = {
        default = { "avante" },
        providers = { avante = { module = "blink-cmp-avante", name = "Avante" } },
      },
    },
  },
}
