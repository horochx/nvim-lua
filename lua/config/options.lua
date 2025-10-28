-- 配置文件由 plugins.core 自动加载
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- 启用自动保存功能
vim.g.autoformat = true

-- Snacks 动画效果
-- 设置为 false 以全局禁用所有 Snacks 动画
vim.g.snacks_animate = true

-- LazyVim 文件选择器配置
-- 可选值：telescope, fzf, "auto"（自动选择已启用的）
vim.g.lazyvim_picker = "auto"

-- LazyVim 补全引擎配置
-- 可选值：nvim-cmp, blink.cmp, "auto"（自动选择已启用的）
vim.g.lazyvim_cmp = "auto"

-- 如果补全引擎支持AI源，使用AI内联建议
vim.g.ai_cmp = true

-- LazyVim 根目录检测规则
-- 每项可以是：
-- * 检测函数名称如 'lsp' 或 'cwd'
-- * 文件/目录模式如 '.git' 或 'lua'
-- * 签名为 function(buf) -> string|string[] 的自定义函数
vim.g.root_spec = { "lsp", { ".git", "lua" }, "cwd" }

-- 可选配置终端使用环境
-- 支持 pwsh 和 powershell 的额外配置
-- LazyVim.terminal.setup("pwsh")

-- LSP根目录检测时忽略的服务器
vim.g.root_lsp_ignore = { "copilot" }

-- 禁用弃用警告
vim.g.deprecation_warnings = false

-- 在 lualine 显示 Trouble 文档符号位置
-- 可通过设置 vim.b.trouble_lualine = false 在缓冲区级别禁用
vim.g.trouble_lualine = true

local opt = vim.opt

-- 自动保存修改的缓冲区
opt.autowrite = true
-- 仅在非SSH环境下使用系统剪贴板（确保OSC 52集成正常工作）
opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus"
opt.completeopt = "menu,menuone,noselect"
-- 隐蔽级别2：隐藏**和__周围的标记，但保留替换标记
opt.conceallevel = 2
-- 保存修改的缓冲区时需要确认
opt.confirm = true
-- 高亮显示光标所在行
opt.cursorline = true
-- 使用空格而非制表符进行缩进
opt.expandtab = true
opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}
opt.foldlevel = 99
-- 按缩进折叠
opt.foldmethod = "indent"
-- 不使用默认折叠文本显示
opt.foldtext = ""
-- 使用Lua函数进行格式化
opt.formatexpr = "v:lua.LazyVim.format.formatexpr()"
-- 格式化选项（j去除注释, c自动注释, r换行继续注释, o进入继续注释, q允许格式化注释, l不重新排列已长行, n识别列表, t按textwidth换行）
opt.formatoptions = "jcroqlnt"
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
-- 搜索时忽略大小写
opt.ignorecase = true
-- 显示增量替换预览
opt.inccommand = "nosplit"
opt.jumpoptions = "view"
-- 使用全局状态栏（而不是每个窗口一个）
opt.laststatus = 3
-- 在便利点换行文本
opt.linebreak = true
-- 显示不可见字符（制表符等）
opt.list = true
-- 启用鼠标支持
opt.mouse = "a"
-- 显示行号
opt.number = true
-- 补全菜单的混合度（透明度）
opt.pumblend = 10
-- 补全菜单最多显示条数
opt.pumheight = 10
-- 显示相对行号
opt.relativenumber = true
-- 禁用默认标尺
opt.ruler = false
-- 垂直滚动时保留的屏幕行数
opt.scrolloff = 4
-- 会话选项：保存缓冲区、工作目录、标签页、窗口大小等
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
-- 缩进四舍五入到倍数
opt.shiftround = true
-- 缩进宽度
opt.shiftwidth = 2
opt.shortmess:append({ W = true, I = true, c = true, C = true })
-- 不显示当前模式（因为已有状态栏）
opt.showmode = false
-- 水平滚动时保留的屏幕列数
opt.sidescrolloff = 8
-- 始终显示标记列（避免文本抖动）
opt.signcolumn = "yes"
-- 大小写混合时不忽略大小写
opt.smartcase = true
-- 自动缩进
opt.smartindent = true
-- 光滑滚动
opt.smoothscroll = true
-- 拼写检查语言
opt.spelllang = { "en" }
-- 新分割窗口出现在下方
opt.splitbelow = true
opt.splitkeep = "screen"
-- 新分割窗口出现在右方
opt.splitright = true
-- 自定义状态列显示
opt.statuscolumn = [[%!v:lua.LazyVim.statuscolumn()]]
-- 制表符对应的空格数
opt.tabstop = 2
-- 启用真彩色
opt.termguicolors = true
-- 键入延迟（VS Code环境设置更长延迟以快速触发which-key）
opt.timeoutlen = vim.g.vscode and 1000 or 300
-- 启用撤销文件持久化
opt.undofile = true
-- 撤销步骤限制
opt.undolevels = 10000
-- 更新间隔（影响交换文件保存和CursorHold事件）
opt.updatetime = 200
-- 视觉块模式下允许光标移动到无文本区域
opt.virtualedit = "block"
-- 命令行补全模式
opt.wildmode = "longest:full,full"
-- 最小窗口宽度
opt.winminwidth = 5
-- 禁用行换行
opt.wrap = false

-- 修复markdown缩进设置
vim.g.markdown_recommended_style = 0

-- 自定义配置：浅色背景
vim.o.background = "light"
