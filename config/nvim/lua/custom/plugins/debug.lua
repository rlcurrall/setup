return {
  'mfussenegger/nvim-dap',
  build = function()
    require('custom.tools').install 'debugger'
  end,
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'mason-org/mason.nvim',
  },
  keys = {
    {
      '<F5>',
      function()
        require('dap').continue()
      end,
      desc = 'Debug: Start/Continue',
    },
    {
      '<F1>',
      function()
        require('dap').step_into()
      end,
      desc = 'Debug: Step Into',
    },
    {
      '<F2>',
      function()
        require('dap').step_over()
      end,
      desc = 'Debug: Step Over',
    },
    {
      '<F3>',
      function()
        require('dap').step_out()
      end,
      desc = 'Debug: Step Out',
    },
    {
      '<leader>db',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Debug: Toggle Breakpoint',
    },
    {
      '<leader>dB',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      desc = 'Debug: Conditional Breakpoint',
    },
    {
      '<F7>',
      function()
        require('dapui').toggle()
      end,
      desc = 'Debug: Toggle UI',
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'
    require('custom.tools').ensure 'debugger'
    dap.adapters.coreclr = {
      type = 'executable',
      command = require('custom.tools').debugger_path(),
      args = { '--interpreter=vscode' },
    }
    dap.configurations.cs = {
      {
        name = 'C#: Launch DLL',
        type = 'coreclr',
        request = 'launch',
        program = function()
          local root = vim.fs.root(0, function(name)
            return name:match '%.csproj$' ~= nil
          end) or vim.fn.getcwd()
          return vim.fn.input('Path to application DLL: ', root .. '/bin/Debug/', 'file')
        end,
        cwd = '${workspaceFolder}',
        stopAtEntry = false,
      },
      {
        name = 'C#: Attach to process',
        type = 'coreclr',
        request = 'attach',
        processId = require('dap.utils').pick_process,
      },
    }
    dap.adapters['pwa-node'] = {
      type = 'server',
      host = '127.0.0.1',
      port = '${port}',
      executable = { command = 'js-debug-adapter', args = { '${port}', '127.0.0.1' } },
    }
    dap.adapters.node = dap.adapters['pwa-node'] -- Existing VS Code launch configurations.
    for _, filetype in ipairs { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' } do
      dap.configurations[filetype] = {
        {
          name = 'Node: Launch current file',
          type = 'pwa-node',
          request = 'launch',
          program = '${file}',
          cwd = '${workspaceFolder}',
          stopOnEntry = true,
          sourceMaps = true,
          skipFiles = { '<node_internals>/**' },
          outFiles = { '${workspaceFolder}/**/*.js', '!**/node_modules/**' },
        },
        {
          name = 'Node: Attach to process',
          type = 'pwa-node',
          request = 'attach',
          processId = require('dap.utils').pick_process,
          cwd = '${workspaceFolder}',
          sourceMaps = true,
          skipFiles = { '<node_internals>/**' },
          outFiles = { '${workspaceFolder}/**/*.js', '!**/node_modules/**' },
        },
      }
    end
    -- nvim-dap reads .vscode/launch.json automatically for project-specific runners.
    dapui.setup()
    dap.listeners.after.event_initialized.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end
  end,
}
