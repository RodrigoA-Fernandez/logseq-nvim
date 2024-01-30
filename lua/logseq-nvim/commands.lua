local referencer = require("logseq-nvim.referencer")

vim.api.nvim_create_user_command("LogseqCopyReference", referencer.copiar_referencia_bloque_actual, {})
