-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- 🎯 Автоматически включаем подписи аргументов функций (Inlay Hints)
if vim.lsp.inlay_hint then
  vim.lsp.inlay_hint.enable(true)
end

-- ---- 🎯 СИЛОВОЙ ЗАПУСК ПОДСКАЗОК ПАРАМЕТРОВ (INLAY HINTS) ----
-- Этот автоскрипт заставит LSP выводить подписи аргументов при открытии любого C++ файла!
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    -- Проверяем, поддерживает ли ваш языковой сервер (clangd) вывод подсказок
    if client and client.supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
    end
  end,
})
