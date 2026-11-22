return {
  "harrisoncramer/gitlab.nvim",
  enabled = true,
  dependencies = {
    "MunifTanjim/nui.nvim",
    "dlyongemallo/diffview-plus.nvim",
    "stevearc/dressing.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  build = function()
    require("gitlab.server").build(true)
  end,
  opts = {},

  -- Adicione o bloco de teclas aqui:
  keys = {
    -- Registra o nome do sub-menu no which-key
    { "<leader>gl", "", desc = "+GitLab", mode = { "n", "v" } },

    -- Principais fluxos de trabalho
    { "<leader>glm", "<cmd>lua require('gitlab').choose_merge_request()<cr>", desc = "Escolher Merge Request" },
    { "<leader>glr", "<cmd>lua require('gitlab').review()<cr>", desc = "Iniciar Revisão (MR atual)" },
    { "<leader>gls", "<cmd>lua require('gitlab').summary()<cr>", desc = "Ver Resumo do MR" },

    -- Comentários e Discussões
    { "<leader>glc", "<cmd>lua require('gitlab').create_comment()<cr>", desc = "Criar Comentário" },
    { "<leader>gld", "<cmd>lua require('gitlab').toggle_discussions()<cr>", desc = "Alternar Painel de Discussões" },

    -- Ações de Gerenciamento
    { "<leader>gla", "<cmd>lua require('gitlab').approve()<cr>", desc = "Aprovar MR" },
    { "<leader>glA", "<cmd>lua require('gitlab').add_reviewer()<cr>", desc = "Adicionar Revisor" },
    { "<leader>glp", "<cmd>lua require('gitlab').pipeline()<cr>", desc = "Ver Status do Pipeline" },
  },
}
