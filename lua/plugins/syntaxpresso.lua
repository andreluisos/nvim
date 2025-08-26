return {
  "syntaxpresso/syntaxpresso.nvim",
  dir = "/var/home/andreluis/Documents/projects/syntaxpresso/syntaxpresso.nvim",
  config = function()
    require("syntaxpresso").setup({
      executable_path = "/var/home/andreluis/Documents/projects/syntaxpresso/core/build/native/nativeCompile/core"
    })
  end,
  dependencies = {
    'grapp-dev/nui-components.nvim',
    'MunifTanjim/nui.nvim',
  }

}
