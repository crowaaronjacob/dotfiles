return {
  "yacineMTB/dingllm.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local system_prompt =
      'You should replace the code that you are sent, only following the comments. Do not talk at all. Only output valid code. Do not provide any backticks that surround the code. Never ever output backticks like this ```. Any comment that is asking you for something should be removed after you satisfy them. Other comments should left alone. Do not output backticks'
    local helpful_prompt = 'You are a helpful assistant. What I have sent are my notes so far.'
    local dingllm = require 'dingllm'

    -- Override write_string_at_cursor to handle undojoin errors
    local original_write = dingllm.write_string_at_cursor
    dingllm.write_string_at_cursor = function(str)
      vim.schedule(function()
        local current_window = vim.api.nvim_get_current_win()
        local cursor_position = vim.api.nvim_win_get_cursor(current_window)
        local row, col = cursor_position[1], cursor_position[2]

        local lines = vim.split(str, '\n')

        -- Try undojoin, but don't fail if it errors
        pcall(vim.cmd, "undojoin")
        vim.api.nvim_put(lines, 'c', true, true)

        local num_lines = #lines
        local last_line_length = #lines[num_lines]
        vim.api.nvim_win_set_cursor(current_window, { row + num_lines - 1, col + last_line_length })
      end)
    end

    -- Claude Opus 4 replace
    vim.keymap.set({"n", "v"}, "<leader>d", function()
      dingllm.invoke_llm_and_stream_into_editor({
        url = 'https://api.anthropic.com/v1/messages',
        model = 'claude-opus-4-20250514',
        api_key_name = 'ANTHROPIC_API_KEY',
        system_prompt = system_prompt,
        replace = true,
      }, dingllm.make_anthropic_spec_curl_args, dingllm.handle_anthropic_spec_data)
    end, { desc = "Claude Opus 4 replace" })

    -- Claude Opus 4 help
    vim.keymap.set({"n", "v"}, "<leader>D", function()
      dingllm.invoke_llm_and_stream_into_editor({
        url = 'https://api.anthropic.com/v1/messages',
        model = 'claude-opus-4-20250514',
        api_key_name = 'ANTHROPIC_API_KEY',
        system_prompt = helpful_prompt,
        replace = false,
      }, dingllm.make_anthropic_spec_curl_args, dingllm.handle_anthropic_spec_data)
    end, { desc = "Claude Opus 4 help" })

    -- Grok-4 replace
    vim.keymap.set({"n", "v"}, "<leader>g", function()
      dingllm.invoke_llm_and_stream_into_editor({
        url = 'https://openrouter.ai/api/v1/chat/completions',
        model = 'x-ai/grok-4',
        api_key_name = 'OPENROUTER_API_KEY',
        system_prompt = system_prompt,
        replace = true,
      }, dingllm.make_openai_spec_curl_args, dingllm.handle_openai_spec_data)
    end, { desc = "Grok-4 replace" })

    -- Grok-4 help
    vim.keymap.set({"n", "v"}, "<leader>G", function()
      dingllm.invoke_llm_and_stream_into_editor({
        url = 'https://openrouter.ai/api/v1/chat/completions',
        model = 'x-ai/grok-4',
        api_key_name = 'OPENROUTER_API_KEY',
        system_prompt = helpful_prompt,
        replace = false,
      }, dingllm.make_openai_spec_curl_args, dingllm.handle_openai_spec_data)
    end, { desc = "Grok-4 help" })
  end,
}
