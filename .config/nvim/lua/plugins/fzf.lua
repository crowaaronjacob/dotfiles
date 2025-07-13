return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons", "nvim-lua/plenary.nvim" },
  config = function()
    vim.keymap.set("n", "<leader>f", function() require("fzf-lua").files() end, { desc = "FZF Files" })
  end,
}

