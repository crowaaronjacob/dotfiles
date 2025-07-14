return {
  "yacineMTB/dingllm.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local system_prompt =
      'You should replace the code that you are sent, only following the comments. Do not talk at all. Only output valid code. Do not provide any backticks that surround the code. Never ever output backticks like this ```. Any comment that is asking you for something should be removed after you satisfy them. Other comments should left alone. Do not output backticks. Do not search the web. Do not use any external tools or web search. You must not make any mistakes. Only output fully correct, error-free code that is COMPLETELY clean and understandable. The code must be production-ready with no bugs or issues. NEVER add any new comments to the code unless explicitly asked to add comments. Do not add explanatory comments, do not add TODO comments, do not add any comments whatsoever unless specifically requested.'
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

    -- Custom Anthropic curl args with higher token limit
    local function make_anthropic_spec_curl_args_extended(opts, prompt)
      local api_key = os.getenv(opts.api_key_name)
      local data = {
        system = opts.system_prompt,
        messages = { { role = 'user', content = prompt } },
        model = opts.model,
        stream = true,
        max_tokens = 32768,
      }
      local args = { '-N', '-X', 'POST', '-H', 'Content-Type: application/json', '-d', vim.json.encode(data) }
      if api_key then
        table.insert(args, '-H')
        table.insert(args, 'x-api-key: ' .. api_key)
        table.insert(args, '-H')
        table.insert(args, 'anthropic-version: 2023-06-01')
      end
      table.insert(args, opts.url)
      return args
    end

    -- Claude Opus 4 replace
    vim.keymap.set({"n", "v"}, "<leader>d", function()
      dingllm.invoke_llm_and_stream_into_editor({
        url = 'https://api.anthropic.com/v1/messages',
        model = 'claude-opus-4-20250514',
        api_key_name = 'ANTHROPIC_API_KEY',
        system_prompt = system_prompt,
        replace = true,
      }, make_anthropic_spec_curl_args_extended, dingllm.handle_anthropic_spec_data)
    end, { desc = "Claude Opus 4 replace" })

    -- Claude Opus 4 help
    vim.keymap.set({"n", "v"}, "<leader>D", function()
      dingllm.invoke_llm_and_stream_into_editor({
        url = 'https://api.anthropic.com/v1/messages',
        model = 'claude-opus-4-20250514',
        api_key_name = 'ANTHROPIC_API_KEY',
        system_prompt = helpful_prompt,
        replace = false,
      }, make_anthropic_spec_curl_args_extended, dingllm.handle_anthropic_spec_data)
    end, { desc = "Claude Opus 4 help" })

    -- Custom OpenRouter curl args function
    local function make_openrouter_spec_curl_args(opts, prompt)
      local api_key = os.getenv(opts.api_key_name)
      if not api_key or api_key == "" then
        vim.notify("OpenRouter API key not found! Please set OPENROUTER_API_KEY environment variable.", vim.log.levels.ERROR)
        return nil
      end
      
      local data = {
        model = opts.model,
        messages = {
          { role = "system", content = opts.system_prompt },
          { role = "user", content = prompt }
        },
        stream = true,
        temperature = 0.7,
        max_tokens = 32768,
      }
      
      local args = {
        '-N',
        '-X', 'POST',
        '-H', 'Content-Type: application/json',
        '-H', 'Authorization: Bearer ' .. api_key,
        '-H', 'HTTP-Referer: https://github.com/yacineMTB/dingllm.nvim',
        '-H', 'X-Title: dingllm.nvim',
        '--no-buffer',
        '-d', vim.json.encode(data),
        opts.url
      }
      
      return args
    end

    -- Custom handler for OpenRouter responses
    local function handle_openrouter_data(data_stream)
      if data_stream == "[DONE]" then
        return
      end
      
      local ok, json = pcall(vim.json.decode, data_stream)
      if not ok then
        return
      end
      
      if json and json.choices and json.choices[1] and json.choices[1].delta then
        local delta = json.choices[1].delta
        
        -- Skip writing if this is just reasoning content (no actual content)
        -- Reasoning models like Grok-4 send reasoning updates before the actual response
        if delta.reasoning and (not delta.content or delta.content == "") then
          -- Skip pure reasoning updates
          return
        end
        
        -- Handle regular content
        if delta.content and delta.content ~= "" then
          dingllm.write_string_at_cursor(delta.content)
        end
      end
    end

    -- Grok-4 replace
    vim.keymap.set({"n", "v"}, "<leader>g", function()
      dingllm.invoke_llm_and_stream_into_editor({
        url = 'https://openrouter.ai/api/v1/chat/completions',
        model = 'x-ai/grok-4',
        api_key_name = 'OPENROUTER_API_KEY',
        system_prompt = system_prompt,
        replace = true,
      }, make_openrouter_spec_curl_args, handle_openrouter_data)
    end, { desc = "Grok-4 replace" })

    -- Grok-4 help
    vim.keymap.set({"n", "v"}, "<leader>G", function()
      dingllm.invoke_llm_and_stream_into_editor({
        url = 'https://openrouter.ai/api/v1/chat/completions',
        model = 'x-ai/grok-4',
        api_key_name = 'OPENROUTER_API_KEY',
        system_prompt = helpful_prompt,
        replace = false,
      }, make_openrouter_spec_curl_args, handle_openrouter_data)
    end, { desc = "Grok-4 help" })
  end,
}
