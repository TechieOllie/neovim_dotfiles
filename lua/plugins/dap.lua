-- ============================================================
--  plugins/dap.lua — Python debugging (DAP)
--
--  nvim-dap + nvim-dap-ui, Python adapter via nvim-dap-python,
--  debugger itself (debugpy) installed through Mason.
-- ============================================================

return {
  -- ── mason-tool-installer: auto-install debugpy via Mason ──
  -- (mason-lspconfig's own ensure_installed only covers LSP servers,
  -- not debug adapters — this is the standard companion plugin for
  -- anything else Mason can install.)
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = { "debugpy" },
    },
  },

  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "mfussenegger/nvim-dap-python",
    },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup()

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn" })

      local python_path = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
      require("dap-python").setup(python_path)

      local map = vim.keymap.set
      map("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
      map("n", "<leader>dc", dap.continue, { desc = "Continue/start debugging" })
      map("n", "<leader>di", dap.step_into, { desc = "Step into" })
      map("n", "<leader>do", dap.step_over, { desc = "Step over" })
      map("n", "<leader>dO", dap.step_out, { desc = "Step out" })
      map("n", "<leader>dr", dap.repl.toggle, { desc = "Toggle REPL" })
      map("n", "<leader>dt", dap.terminate, { desc = "Terminate session" })
      map("n", "<leader>du", dapui.toggle, { desc = "Toggle DAP UI" })
    end,
  },
}
