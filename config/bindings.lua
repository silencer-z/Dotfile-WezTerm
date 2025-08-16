local wezterm = require("wezterm")
local action = wezterm.action
local functions = require("utils.functions")
local colors = require("utils.colors")

local M = {}

M.SUPER = 'ALT'
M.SUPER_REV = 'ALT|CTRL'

-- Configuration
local TIMEOUT = { key = 3000, leader = 1500 }

function M.apply(config)
  config.disable_default_key_bindings = true
  config.leader = { key = "Space", mods = M.SUPER_REV, timeout_milliseconds = TIMEOUT.leader }
  config.keys = M.get_keys()
  config.key_tables = M.get_key_tables()
end

function M.get_keys()
  local keys = {
    -- Key table modes
    -- { key = "F1", mods = "NONE", action = M.activate_table("open") },
    -- { key = "F2", mods = "NONE", action = M.activate_table("move") },
    -- { key = "F3", mods = "NONE", action = M.activate_table("resize") },
    -- { key = "F4", mods = "NONE", action = M.activate_table("copy") },

    { key = "F1", mods = "NONE", action = action.ShowLauncherArgs { flags = "FUZZY|LAUNCH_MENU_ITEMS" } },
    -- { key = "d", mods = "LEADER", action = action.ShowDebugOverlay },
    { key = "F2", mods = "NONE", action = action.ActivateCommandPalette },
    { key = "F3", mods = "NONE", action = action.ActivateCopyMode },

    -- Clipboard
    { key = "v", mods = "CTRL", action = action.PasteFrom("Clipboard") },
    { key = "c", mods = "CTRL", action = action.Multiple {
        action.CopyTo("ClipboardAndPrimarySelection"),
        action.ClearSelection
      }
    },

    -- Application
    { key = "q", mods = "CTRL", action = action.QuitApplication },
    { key = "/", mods = "CTRL", action = action.Search { CaseInSensitiveString = "" } },
    -- Font size
    { key = "0", mods = "CTRL", action = action.ResetFontSize },
    { key = "-", mods = "CTRL", action = action.DecreaseFontSize },
    { key = "=", mods = "CTRL", action = action.IncreaseFontSize },

    -- Tab management


    -- Pane operations Pane 操作依赖于ALT
    { key = "v", mods = "ALT", action = action.SplitVertical { domain = "CurrentPaneDomain" } },
    { key = "h", mods = "ALT", action = action.SplitHorizontal { domain = "CurrentPaneDomain" } },
    { key = "z", mods = "ALT", action = action.TogglePaneZoomState },
    { key = "q", mods = "ALT", action = action.CloseCurrentPane { confirm = false } },
    -- Navigation
    { key = "LeftArrow", mods = "ALT", action = action.ActivatePaneDirection("Left") },
    { key = "RightArrow", mods = "ALT", action = action.ActivatePaneDirection("Right") },
    { key = "UpArrow", mods = "ALT", action = action.ActivatePaneDirection("Up") },
    { key = "DownArrow", mods = "ALT", action = action.ActivatePaneDirection("Down") },


    -- Tab navigation TAB操作依赖于CTRL SHIFT
    { key = "t", mods = "CTRL", action = action.SpawnTab("DefaultDomain") },
    { key = "[", mods = "CTRL|SHIFT", action = action.ActivateTabRelative(-1) },
    { key = "]", mods = "CTRL|SHIFT", action = action.ActivateTabRelative(1) },
    { key = "r", mods = "CTRL|SHIFT", action = M.rename_tab_prompt() },
    { key = "t", mods = "CTRL|SHIFT", action = action.ShowLauncherArgs { flags = "TABS" } },


    -- Workspace
    { key = "l", mods = "CTRL|ALT", action = wezterm.action_callback(function(window, pane)
        functions.switch_previous_workspace(window, pane)
        window:perform_action(action.EmitEvent "set-previous-workspace", pane)
      end)
    },
    { key = "s", mods = "CTRL|ALT", action = action.Multiple {
        action.ShowLauncherArgs { flags = "FUZZY|WORKSPACES" },
        action.EmitEvent "set-previous-workspace"
      }
    },
    { key = "[", mods = "CTRL|ALT", action = action.Multiple {
        action.SwitchWorkspaceRelative(-1), action.EmitEvent "set-previous-workspace" }
    },
    { key = "]", mods = "CTRL|ALT", action = action.Multiple {
        action.SwitchWorkspaceRelative(1), action.EmitEvent "set-previous-workspace" }
    },
    { key = "r", mods = "CTRL|ALT", action = M.rename_workspace_prompt() },

    -- Vim-style scrolling
    -- { key = "k", mods = "ALT", action = action.ScrollByLine(-1) },     -- Scroll up one line
    -- { key = "j", mods = "ALT", action = action.ScrollByLine(1) },      -- Scroll down one line
    -- { key = "u", mods = "ALT", action = action.ScrollByPage(-0.5) },   -- Scroll up half page
    -- { key = "d", mods = "ALT", action = action.ScrollByPage(0.5) },    -- Scroll down half page
    -- { key = "b", mods = "ALT", action = action.ScrollByPage(-1) },     -- Scroll up full page
    -- { key = "f", mods = "ALT", action = action.ScrollByPage(1) },      -- Scroll down full page
    -- { key = "g", mods = "ALT", action = action.ScrollToTop },          -- Jump to top
    -- { key = "g", mods = "ALT|SHIFT", action = action.ScrollToBottom }, -- Jump to bottom

  }

  -- Number keys for tab activation
  for i = 1, 9 do
    table.insert(keys, { key = tostring(i), mods = "CTRL", action = action.ActivateTab(i - 1) })
  end

  return keys
end

-- 为自定义的模式设置对应的快捷键
function M.get_key_tables()
  return {
    copy = {
      { key = "b", action = action.EmitEvent "copy-buffer-from-pane" },
      { key = "p", action = action.EmitEvent "copy-text-from-pane" },
      { key = "l", action = M.copy_line_action() },
      { key = "r", action = M.copy_regex_action() },
    },

    move = {
      { key = "r", action = action.RotatePanes 'CounterClockwise' },
      { key = "s", action = action.PaneSelect },
      { key = "Enter", action = "PopKeyTable" },
      { key = "Escape", action = "PopKeyTable" },
      { key = "LeftArrow", mods = "SHIFT", action = action.MoveTabRelative(-1) },
      { key = "RightArrow", mods = "SHIFT", action = action.MoveTabRelative(1) },
    },

    resize = {
      { key = "DownArrow", action = action.AdjustPaneSize { "Down", 1 } },
      { key = "LeftArrow", action = action.AdjustPaneSize { "Left", 1 } },
      { key = "RightArrow", action = action.AdjustPaneSize { "Right", 1 } },
      { key = "UpArrow", action = action.AdjustPaneSize { "Up", 1 } },
      { key = "Enter", action = "PopKeyTable" },
      { key = "Escape", action = "PopKeyTable" },
    },

    open = {
      { key = "p", action = M.spawn_command("Finder", { "open", "." }) },
      { key = "c", action = M.spawn_command("VS Code", { "zsh", "-lc", "code ." }) },
      { key = "u", action = M.open_url_action() },
    }
  }
end

-- Helper functions
function M.activate_table(name)
  return action.ActivateKeyTable {
    name = name,
    one_shot = false,
    until_unknown = name ~= "move",
    timeout_milliseconds = TIMEOUT.key
  }
end

function M.spawn_command(label, args)
  return action.SpawnCommandInNewWindow { label = label, args = args }
end

function M.copy_line_action()
  return action.QuickSelectArgs {
    label = "COPY LINE",
    patterns = { "^.*\\S+.*$" },
    scope_lines = 1,
    action = action.Multiple {
      action.CopyTo("ClipboardAndPrimarySelection"),
      action.ClearSelection
    }
  }
end

function M.copy_regex_action()
  return action.QuickSelectArgs {
    label = "COPY REGEX",
    patterns = {
      "(\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}(?:/\\d{1,2})?)",
      "((?:[[:xdigit:]]{0,4}:){2,7}[[:xdigit:]]{0,4}(?:/\\d{1,3})?)",
      "[[:xdigit:]]{2}:[[:xdigit:]]{2}:[[:xdigit:]]{2}:[[:xdigit:]]{2}:[[:xdigit:]]{2}:[[:xdigit:]]{2}",
      "\\S+@\\S+\\.\\S+",
      "[[:xdigit:]]{12}",
      "\\S+/\\S+:\\S+",
      "[[:xdigit:]]{7,}",
      "(?:https?|s?ftp)://\\S+"
    },
    action = action.Multiple {
      action.CopyTo("ClipboardAndPrimarySelection"),
      action.ClearSelection
    }
  }
end

function M.open_url_action()
  return action.QuickSelectArgs {
    label = "Open URL",
    patterns = { "https?://\\S+" },
    scope_lines = 30,
    action = wezterm.action_callback(function(window, pane)
      local url = window:get_selection_text_for_pane(pane)
      wezterm.open_with(url)
    end)
  }
end

function M.rename_tab_prompt()
  return action.PromptInputLine {
    description = wezterm.format {
      { Attribute = { Intensity = "Bold" } },
      { Foreground = { Color = colors.fg() } },
      { Text = "Rename tab:" }
    },
    action = wezterm.action_callback(function(window, _, line)
      if line then window:active_tab():set_title(line) end
    end),
  }
end

function M.rename_workspace_prompt()
  return action.PromptInputLine {
    description = wezterm.format {
      { Attribute = { Intensity = "Bold" } },
      { Foreground = { Color = colors.fg() } },
      { Text = "Rename workspace:" }
    },
    action = wezterm.action_callback(function(_, _, line)
      if line then
        local mux = wezterm.mux
        mux.rename_workspace(mux.get_active_workspace(), line)
      end
    end),
  }
end

return M
