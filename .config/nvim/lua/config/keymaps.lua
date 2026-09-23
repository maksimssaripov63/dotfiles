-- Умная прошивка PlatformIO для любой папки (Dunaj 5.2)
vim.keymap.set("n", "<leader>pu", function()
  -- 1. Находим имя папки, в которой лежит текущий открытый файл C++
  local current_dir = vim.fn.expand("%:p:h")
  local folder_name = vim.fn.fnamemodify(current_dir, ":t")

  -- 2. Если мы внутри подпапки (например, 'functions'), поднимаемся на шаг выше,
  -- чтобы захватить весь скетч целиком вместе с его библиотеками
  if folder_name == "functions" then
    local parent_dir = vim.fs.dirname(current_dir)
    folder_name = vim.fn.fnamemodify(parent_dir, ":t")
  end

  -- 3. Формируем команду динамического фильтра через переменную окружения
  -- Это легальный консольный способ заставить PlatformIO скомпилировать только одну подпапку!
  local target_filter = "-<*> +<**/" .. folder_name .. "/**>"
  local pio_cmd = string.format(
    "split | terminal export PLATFORMIO_BUILD_SRC_FILTER='%s' && pio run -t upload --upload-port /dev/ttyUSB0",
    target_filter
  )

  -- 4. Запускаем терминал внутри Neovim
  vim.cmd(pio_cmd)
  vim.cmd("startinsert")
end, { desc = "PlatformIO: Upload Current Sketch Folder" })
