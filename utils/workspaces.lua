local M = {}

-- Default workspaces configuration
M.config = {
  -- you can set the activated workspace here, the default should be the first of list
  activated = {"Arch"}, 
  spaces = {
    {
      name = "default",
      path = os.getenv("HOME"),
    },
    {
      name = "Arch",
      domain = { DomainName = 'WSL:Arch' },
      default_prog = { "zsh" },
      tabs = {"WSL"}
      -- path = "/home/orz",
    },

    {
      name = "raspi",
      domain = { DomainName = 'RasberryPi'},
      default_prog = { "zsh" },
      -- path = "/home/orz",
    },
    -- Add your projects here:
    -- {
    --   name = "dotfiles",
    --   path = os.getenv("HOME") .. "/.dotfiles"
    -- },
    -- {
    --   name = "work",
    --   path = os.getenv("HOME") .. "/Work",
    --   tabs = { "frontend", "backend", "docs" }
    -- },
  }
}

return M