return {
  "jonroosevelt/gemini-cli.nvim",
  -- Deshabilitado: Gemini CLI no está instalado y el plugin preguntaba
  -- "Install it now? (y/n)" al abrir nvim. Quitar esta línea para reactivarlo.
  enabled = false,
  config = function()
    require("gemini").setup()
  end,
}
