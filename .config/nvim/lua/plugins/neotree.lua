return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        bind_to_cwd = true,
        follow_current_file = { enabled = true },
        filtered_items = {
          visible = true, -- Делает скрытые элементы видимыми
          show_hidden_count = true, -- Показывать счетчик скрытых файлов
          hide_dotfiles = false, -- ОТКЛЮЧАЕТ скрытие файлов, начинающихся с точки
          hide_gitignored = false, -- ОТКЛЮЧАЕТ скрытие файлов из .gitignore (опционально)
        },
      },
    },
  },

  -- Настраиваем Snacks, чтобы стрелочки фолдинга горели ВСЕГДА и везде
  {
    "folke/snacks.nvim",
    opts = {
      statuscolumn = {
        folds = {
          open = true, -- ПРИНУДИТЕЛЬНО ПОКАЗЫВАТЬ СТРЕЛОЧКИ ДЛЯ ОТКРЫТЫХ БЛОКОВ!
        },
      },
      picker = {
        sources = {
          projects = {
            confirm = function(picker, item)
              picker:close()
              if item and item.text then
                local path = vim.fn.expand(item.text)
                vim.api.nvim_set_current_dir(path)
                vim.schedule(function()
                  vim.cmd("Neotree show left dir=" .. vim.fn.fnameescape(path))
                end)
              end
            end,
          },
        },
      },
    },
  },
}
