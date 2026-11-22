local gitsigns = require("gitsigns")

local BAR_SIGN = "▎"
local DELETE_SIGN = ""
local TOP_DELETE_SIGN = ""

local function navigate_hunk(direction, diff_mode_keys)
  return function()
    if vim.wo.diff then
      vim.cmd.normal({ diff_mode_keys, bang = true })
      return
    end
    gitsigns.nav_hunk(direction)
  end
end

local function blame_line_in_full()
  gitsigns.blame_line({ full = true })
end

local function diff_against_previous_commit()
  gitsigns.diffthis("~")
end

local function map_hunk_keys(buffer)
  local function map(modes, keys, action, description)
    vim.keymap.set(modes, keys, action, { buffer = buffer, silent = true, desc = description })
  end
  map("n", "]h", navigate_hunk("next", "]c"), "Next Hunk")
  map("n", "[h", navigate_hunk("prev", "[c"), "Prev Hunk")
  map("n", "]H", function()
    gitsigns.nav_hunk("last")
  end, "Last Hunk")
  map("n", "[H", function()
    gitsigns.nav_hunk("first")
  end, "First Hunk")
  map({ "n", "x" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
  map({ "n", "x" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
  map("n", "<leader>ghS", gitsigns.stage_buffer, "Stage Buffer")
  map("n", "<leader>ghR", gitsigns.reset_buffer, "Reset Buffer")
  map("n", "<leader>ghp", gitsigns.preview_hunk_inline, "Preview Hunk Inline")
  map("n", "<leader>ghb", blame_line_in_full, "Blame Line")
  map("n", "<leader>ghB", gitsigns.blame, "Blame Buffer")
  map("n", "<leader>ghd", gitsigns.diffthis, "Diff This")
  map("n", "<leader>ghD", diff_against_previous_commit, "Diff This ~")
  map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select Hunk")
end

gitsigns.setup({
  signs = {
    add = { text = BAR_SIGN },
    change = { text = BAR_SIGN },
    delete = { text = DELETE_SIGN },
    topdelete = { text = TOP_DELETE_SIGN },
    changedelete = { text = BAR_SIGN },
    untracked = { text = BAR_SIGN },
  },
  signs_staged = {
    add = { text = BAR_SIGN },
    change = { text = BAR_SIGN },
    delete = { text = DELETE_SIGN },
    topdelete = { text = TOP_DELETE_SIGN },
    changedelete = { text = BAR_SIGN },
  },
  on_attach = map_hunk_keys,
})
