local function open_ranger(open_in_new_tab)
  if vim.fn.executable("ranger") ~= 1 then
    vim.notify("Ranger is not installed", vim.log.levels.ERROR)
    return
  end

  local origin_window = vim.api.nvim_get_current_win()
  local start_directory = vim.fn.getcwd()
  if vim.bo.filetype == "neo-tree" then
    local state = require("neo-tree.sources.manager").get_state("filesystem")
    local node = state.tree and state.tree:get_node()
    if node and node.type == "directory" then
      start_directory = node:get_id()
    elseif node then
      start_directory = vim.fs.dirname(node:get_id())
    end
  elseif vim.bo.buftype == "" then
    local buffer_path = vim.api.nvim_buf_get_name(0)
    if buffer_path ~= "" then
      start_directory = vim.fs.dirname(buffer_path)
    end
  end
  if vim.fn.isdirectory(start_directory) ~= 1 then
    start_directory = vim.fn.getcwd()
  end

  local temporary_directory = vim.fn.tempname()
  vim.fn.mkdir(temporary_directory, "p", 448)
  local selected_file_path = temporary_directory .. "/file"
  local selected_directory_path = temporary_directory .. "/directory"
  vim.cmd.tabnew()
  local terminal_buffer = vim.api.nvim_get_current_buf()
  local terminal_window = vim.api.nvim_get_current_win()
  local palette = require("gentleman_kanagawa_blur.palette")
  local terminal_colors = {
    palette.gray1, palette.red, palette.green, palette.yellow,
    palette.blue, "#A855F7", palette.cyan, palette.fg,
    palette.selection, palette.bright_red, palette.bright_green, palette.bright_yellow,
    palette.bright_blue, "#C084FC", palette.bright_cyan, palette.fg,
  }
  for index, color in ipairs(terminal_colors) do
    vim.b["terminal_color_" .. (index - 1)] = color
  end
  vim.api.nvim_set_hl(0, "GentlemanRangerNormal", { fg = palette.fg, bg = "NONE" })
  vim.api.nvim_set_hl(0, "GentlemanRangerBorder", { fg = palette.gray3, bg = "NONE" })
  vim.wo[terminal_window].winhighlight = "Normal:GentlemanRangerNormal,NormalNC:GentlemanRangerNormal,EndOfBuffer:GentlemanRangerNormal,WinSeparator:GentlemanRangerBorder"
  vim.wo[terminal_window].number = false
  vim.wo[terminal_window].relativenumber = false
  vim.wo[terminal_window].signcolumn = "no"
  vim.wo[terminal_window].statuscolumn = ""
  vim.wo[terminal_window].winbar = ""
  local function finish(exit_code)
    local function read_path(path)
      if vim.fn.filereadable(path) == 1 then
        return vim.fn.readfile(path)[1]
      end
    end
    local selected_file = read_path(selected_file_path)
    local selected_directory = read_path(selected_directory_path)
    vim.fn.delete(temporary_directory, "rf")
    if vim.api.nvim_win_is_valid(terminal_window) and vim.api.nvim_win_is_valid(origin_window) then
      vim.api.nvim_win_close(terminal_window, true)
    end
    if vim.api.nvim_buf_is_valid(terminal_buffer) then
      vim.api.nvim_buf_delete(terminal_buffer, { force = true })
    end
    if vim.api.nvim_win_is_valid(origin_window) then
      vim.api.nvim_set_current_win(origin_window)
    end
    if exit_code ~= 0 then
      vim.notify("Ranger exited with code " .. exit_code, vim.log.levels.WARN)
      return
    end
    local directory = selected_directory or start_directory
    if selected_file and vim.fn.filereadable(selected_file) == 1 then
      directory = vim.fs.dirname(selected_file)
      if open_in_new_tab then
        vim.cmd.tabnew()
      end
      -- Reuse the dashboard instead of leaving it beside the selected file.
      if vim.bo.filetype == "neo-tree" then
        local editing_window
        for _, window in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          local buffer = vim.api.nvim_win_get_buf(window)
          local filetype = vim.bo[buffer].filetype
          if vim.api.nvim_win_get_config(window).relative == ""
            and (vim.bo[buffer].buftype == "" or filetype == "snacks_dashboard"
              or filetype == "dashboard" or filetype == "alpha") then
            editing_window = window
            break
          end
        end
        if editing_window then
          vim.api.nvim_set_current_win(editing_window)
        else
          vim.cmd.vnew()
        end
      end
      if vim.bo.modified then
        vim.cmd.split()
      end
      local opened, error_message = pcall(vim.api.nvim_cmd, {
        cmd = "edit", args = { selected_file },
      }, {})
      if not opened then
        vim.notify(tostring(error_message), vim.log.levels.ERROR)
        return
      end
      for _, window in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buffer = vim.api.nvim_win_get_buf(window)
        local filetype = vim.bo[buffer].filetype
        if window ~= vim.api.nvim_get_current_win()
          and (filetype == "snacks_dashboard" or filetype == "dashboard" or filetype == "alpha")
          and not vim.bo[buffer].modified then
          vim.api.nvim_win_close(window, false)
        end
      end
    end
    if vim.fn.isdirectory(directory) == 1 then
      vim.api.nvim_cmd({ cmd = "tcd", args = { directory } }, {})
      if selected_file then
        require("neo-tree.command").execute({
          action = "show",
          source = "filesystem",
          position = "left",
          dir = directory,
          reveal_file = selected_file,
        })
      else
        require("neo-tree.command").execute({
          source = "filesystem",
          position = "left",
          action = "focus",
          dir = directory,
        })
      end
    end
  end
  local job = vim.fn.jobstart({
    "ranger",
    "--confdir=" .. vim.fn.stdpath("config") .. "/ranger",
    "--choosefile=" .. selected_file_path,
    "--choosedir=" .. selected_directory_path,
    "--cmd=map q quit!",
    start_directory,
  }, {
    term = true,
    on_exit = function(_, exit_code)
      vim.schedule(function() finish(exit_code) end)
    end,
  })
  if job <= 0 then
    finish(1)
    return
  end
  vim.cmd.startinsert()
end

return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    keys = {
      { "<leader>ra", function() open_ranger(false) end, desc = "Ranger (current tab)" },
      { "<leader>re", function() open_ranger(true) end, desc = "Ranger (open file in new tab)" },
    },
    opts = function(_, opts)
      opts.window = opts.window or {}
      opts.window.mappings = opts.window.mappings or {}
      opts.window.mappings["Y"] = {
        function(state)
          local node = state.tree:get_node()
          if not node then
            vim.notify("No file or directory selected", vim.log.levels.WARN)
            return
          end

          vim.fn.setreg("+", node:get_id())
          vim.notify("Path copied: " .. node:get_id(), vim.log.levels.INFO)
        end,
        desc = "Copy absolute path",
      }
    end,
  },
}
