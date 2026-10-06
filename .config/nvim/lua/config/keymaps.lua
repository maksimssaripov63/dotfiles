-- ---- 🤖 ИНТЕЛЛЕКТУАЛЬНЫЕ КОМАНДЫ СБОРКИ PLATFORMIO ДЛЯ MONOREPO ----

-- Функция-помощник: вычисляет имя текущей папки и строит фильтр для PlatformIO
local function get_pio_src_filter()
  local current_dir = vim.fn.expand("%:p:h")
  local folder_name = vim.fn.fnamemodify(current_dir, ":t")

  -- Если мы внутри подпапки (например, 'functions'), поднимаемся на шаг выше
  if folder_name == "functions" or folder_name == "IBT-2" then
    local parent_dir = vim.fs.dirname(current_dir)
    folder_name = vim.fn.fnamemodify(parent_dir, ":t")
    if folder_name == "IBT-2" then
      current_dir = vim.fs.dirname(current_dir)
      folder_name = vim.fn.fnamemodify(current_dir, ":t")
    end
  end

  -- Формируем маску динамического фильтра исходников
  local target_filter = string.format("-<*> +<./**> -<**/src/**> +<**/%s/**>", folder_name)
  return folder_name, target_filter
end

-- 1. 🛠️ [Пробел + p + b] — ТОЛЬКО СКОМПИЛИРОВАТЬ ТЕКУЩУЮ ПАПКУ (Build)
vim.keymap.set("n", "<leader>pb", function()
  local folder_name, target_filter = get_pio_src_filter()
  LazyVim.terminal({ "pio", "run" }, {
    ctrl_space = true,
    desc = "PlatformIO: Build " .. folder_name,
    env = { PLATFORMIO_BUILD_SRC_FILTER = target_filter },
  })
end, { desc = "PlatformIO: Build Current Sketch Folder" })

-- 2. 🚀 [Пробел + p + u] — СКОМПИЛИРОВАТЬ И ЗАЛИТЬ ТЕКУЩУЮ ПАПКУ (Upload)
vim.keymap.set("n", "<leader>pu", function()
  local folder_name, target_filter = get_pio_src_filter()
  LazyVim.terminal({ "pio", "run", "-t", "upload", "--upload-port", "/dev/ttyUSB0" }, {
    ctrl_space = true,
    desc = "PlatformIO: Upload " .. folder_name,
    env = { PLATFORMIO_BUILD_SRC_FILTER = target_filter },
  })
end, { desc = "PlatformIO: Upload Current Sketch Folder" })

-- 3. 🧹 [Пробел + p + c] — ПОЛНОСТЬЮ ОЧИСТИТЬ КЭШ СБОРОК ВСЕГО ПРОЕКТА (Clean)
vim.keymap.set("n", "<leader>pc", function()
  LazyVim.terminal({ "pio", "run", "-t", "clean" }, {
    ctrl_space = true,
    desc = "PlatformIO: Clean Project",
  })
end, { desc = "PlatformIO: Clean Whole Project" })
