-- Antigravity CLI (`agy`) en una sesión de tmux persistente por proyecto.
-- <leader>ag abre/oculta. Si cierras nvim o la terminal, agy SIGUE corriendo
-- en tmux; al volver a abrir se reengancha a la misma conversación.
-- <leader>aK mata la sesión de este proyecto (agy deja de correr).
local function session_name()
  local project = vim.fn.fnamemodify(vim.fn.getcwd(), ":t"):gsub("[^%w_-]", "_")
  return "agy-" .. project
end

return {
  "folke/snacks.nvim",
  keys = {
    {
      "<leader>ag",
      function()
        local name = session_name()
        -- env -u TMUX: permite tmux dentro de tmux; status off: sin barra doble.
        local cmd = { "env", "-u", "TMUX", "tmux", "new-session", "-A", "-s", name, "-c", vim.fn.getcwd(), "agy", ";", "set", "status", "off" }
        Snacks.terminal(cmd, { cwd = vim.fn.getcwd(), win = { position = "float", border = "rounded" } })
      end,
      desc = "Antigravity (agy, persistente)",
      mode = { "n", "t" },
    },
    {
      "<leader>aK",
      function()
        local name = session_name()
        vim.fn.system({ "tmux", "kill-session", "-t", name })
        -- Cierra también la ventana flotante si quedó abierta.
        for _, terminal in ipairs(Snacks.terminal.list()) do
          if terminal:buf_valid() and vim.api.nvim_buf_get_name(terminal.buf):find(name, 1, true) then
            terminal:close()
          end
        end
        vim.notify("Sesión " .. name .. " terminada")
      end,
      desc = "Matar Antigravity (agy)",
    },
  },
}
