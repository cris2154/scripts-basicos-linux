local function transparent_tabline()
  for _, group in ipairs({ "TabLine", "TabLineFill", "TabLineSel" }) do
    local highlight = vim.api.nvim_get_hl(0, { name = group, link = false })
    highlight.bg = nil
    highlight.ctermbg = nil
    if group == "TabLineSel" then
      highlight.fg = 0xA78BFA
      highlight.bold = true
    end
    vim.api.nvim_set_hl(0, group, highlight)
  end
end

local function set_visual_selection()
  local selection = { bg = "#7C3AED", fg = "#FFFFFF", bold = true }
  vim.api.nvim_set_hl(0, "Visual", selection)
  vim.api.nvim_set_hl(0, "VisualNOS", selection)
end

-- Carpetas e iconos de carpeta en violeta (explorador de snacks, oil, neo-tree)
local function set_explorer_colors()
  vim.api.nvim_set_hl(0, "Directory", { fg = "#C4B5FD", bold = true })
  vim.api.nvim_set_hl(0, "SnacksPickerDirectory", { link = "Directory" })
  vim.api.nvim_set_hl(0, "SnacksPickerTree", { fg = "#4C1D95" })
  vim.api.nvim_set_hl(0, "SnacksPickerPathHidden", { fg = "#8A8FA3" })
  vim.api.nvim_set_hl(0, "SnacksPickerTitle", { fg = "#FFFFFF", bg = "#7C3AED", bold = true })
  vim.api.nvim_set_hl(0, "SnacksPickerPrompt", { fg = "#A78BFA", bold = true })
  vim.api.nvim_set_hl(0, "SnacksPickerMatch", { fg = "#C4B5FD", bold = true })
  vim.api.nvim_set_hl(0, "SnacksPickerBorder", { fg = "#6D28D9" })
  vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#6D28D9" })
  vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#4C1D95" })
  vim.api.nvim_set_hl(0, "MiniIconsPurple", { fg = "#C4B5FD" })
end

return {
  {
    -- Icono de carpeta en violeta (mini.icons es el proveedor de iconos de LazyVim)
    "nvim-mini/mini.icons",
    optional = true,
    opts = { default = { directory = { hl = "MiniIconsPurple" } } },
  },
  {
    "nvim-lualine/lualine.nvim",
    init = function()
      vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
        group = vim.api.nvim_create_augroup("GentlemanTransparentTabline", { clear = true }),
        callback = function() vim.schedule(function()
          transparent_tabline()
          set_visual_selection()
          set_explorer_colors()
        end) end,
      })
    end,
    opts = function(_, opts)
      transparent_tabline()
      set_visual_selection()
      set_explorer_colors()
      local theme = vim.deepcopy(require("lualine.themes.gentleman-kanagawa-blur"))
      local modes = {
        normal = "#7C3AED",
        insert = "#8B5CF6",
        visual = "#A78BFA",
        replace = "#BE185D",
        command = "#6D28D9",
        terminal = "#5B21B6",
      }
      for mode, background in pairs(modes) do
        theme[mode] = {
          a = { fg = "#FFFFFF", bg = background, gui = "bold" },
          b = { fg = "#C4B5FD", bg = "NONE" },
          c = { fg = "#F3F6F9", bg = "NONE" },
          x = { fg = "#C4B5FD", bg = "NONE" },
          y = { fg = "#EDE9FE", bg = "#241A45" },
          z = { fg = "#FFFFFF", bg = background, gui = "bold" },
        }
      end
      theme.inactive = {
        a = { fg = "#C4B5FD", bg = "NONE" },
        b = { fg = "#C4B5FD", bg = "NONE" },
        c = { fg = "#8A8FA3", bg = "NONE" },
      }
      opts.options = opts.options or {}
      opts.options.theme = theme

      local buffer_component = require("lualine.components.buffers.buffer")
      buffer_component.configure_mouse_click = function(buffer, name)
        return string.format(
          '%%%s@LualineSwitchBuffer@%s%%T%%%s@LualineCloseBuffer@ × %%T',
          buffer.bufnr,
          name,
          buffer.bufnr
        )
      end
      vim.cmd([[
        function! LualineCloseBuffer(bufnr, mouseclicks, mousebutton, modifiers)
          if a:mousebutton ==# 'l'
            execute 'bdelete ' . a:bufnr
          endif
        endfunction
      ]])
      opts.tabline = {
        lualine_a = {
          {
            "buffers",
            mode = 0,
            show_filename_only = true,
            hide_filename_extension = false,
            icons_enabled = true,
            show_modified_status = true,
            use_mode_colors = false,
            max_length = function() return math.floor(vim.o.columns * 0.62) end,
            buffers_color = {
              active = { fg = "#FFFFFF", bg = "#7C3AED", gui = "bold" },
              inactive = { fg = "#C4B5FD", bg = "#241A45" },
            },
            symbols = { modified = " ●", alternate_file = "", directory = " " },
            filetype_names = {
              snacks_dashboard = "Home",
              ["neo-tree"] = "Files",
            },
            fmt = function(name, context)
              local filename = vim.api.nvim_buf_get_name(context.bufnr)
              if vim.bo[context.bufnr].buftype == "terminal" then
                if filename:find("lazygit", 1, true) then return "LazyGit" end
                if filename:find("ranger", 1, true) then return "Ranger" end
                return "Terminal"
              end
              local visible_name_limit = 20
              if vim.fn.strchars(name) > visible_name_limit then
                return vim.fn.strcharpart(name, 0, visible_name_limit - 1) .. "…"
              end
              return name
            end,
            padding = { left = 1, right = 1 },
            separator = nil,
            section_separators = { left = "", right = "" },
            component_separators = { left = "│", right = "│" },
          },
        },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {
          {
            "tabs",
            mode = 0,
            cond = function() return #vim.api.nvim_list_tabpages() > 1 end,
            tabs_color = {
              active = { fg = "#FFFFFF", bg = "#7C3AED", gui = "bold" },
              inactive = { fg = "#C4B5FD", bg = "#241A45" },
            },
            separator = nil,
            section_separators = { left = "│", right = "│" },
            component_separators = { left = "│", right = "│" },
            padding = { left = 2, right = 2 },
          },
        },
      }
      vim.o.showtabline = 2
    end,
  },
}
