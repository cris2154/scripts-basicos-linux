local M = {}
local git_tab

function M.open(use_current_directory)
  if git_tab and vim.api.nvim_tabpage_is_valid(git_tab) then
    vim.api.nvim_set_current_tabpage(git_tab)
    vim.cmd.startinsert()
    return
  end
  if vim.fn.executable("lazygit") ~= 1 then
    vim.notify("LazyGit is not installed", vim.log.levels.ERROR)
    return
  end
  local directory = use_current_directory and vim.fn.getcwd() or LazyVim.root.git()
  local origin_window = vim.api.nvim_get_current_win()
  vim.cmd.tabnew()
  local opened_tab = vim.api.nvim_get_current_tabpage()
  git_tab = opened_tab

  local function restore_workspace()
    vim.schedule(function()
      if git_tab == opened_tab then
        git_tab = nil
      end
      if vim.api.nvim_tabpage_is_valid(opened_tab) then
        local windows = vim.api.nvim_tabpage_list_wins(opened_tab)
        if #windows == 1 then
          local buffer = vim.api.nvim_win_get_buf(windows[1])
          if not vim.bo[buffer].modified
            and (vim.bo[buffer].buftype ~= "" or vim.api.nvim_buf_get_name(buffer) == "")
            and #vim.api.nvim_list_tabpages() > 1 then
            vim.api.nvim_set_current_tabpage(opened_tab)
            vim.cmd.tabclose()
          end
        end
      end
      if vim.api.nvim_win_is_valid(origin_window) then
        vim.api.nvim_set_current_win(origin_window)
      end
    end)
  end

  local opened, error_message = pcall(Snacks.lazygit.open, {
    cwd = directory,
    win = {
      position = "current",
      on_close = restore_workspace,
    },
  })
  if not opened then
    restore_workspace()
    vim.notify(tostring(error_message), vim.log.levels.ERROR)
  end
end

return M
