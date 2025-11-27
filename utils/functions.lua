local wezterm = require("wezterm")
local action = wezterm.action
local colors = require("utils.colors")

local M = {}

-- File utilities
function M.file_exists(name)
  local file = io.open(name, "r")
  if file then
    io.close(file)
    return true
  end
  return false
end

function M.basename(path)
  return string.gsub(path, '(.*[/\\])(.*)', '%2')
end

-- Tab utilities
function M.get_tab_title(tab_info)
  local title = tab_info.tab_title
  if title and #title > 0 then
    return title
  end
  return tab_info.active_pane.title:gsub("^Copy mode: ", "")
end

function M.get_cwd(pane, max_width)
  local cwd = pane:get_current_working_dir()
  if not cwd then return "" end

  if type(cwd) == "userdata" then
    cwd = cwd.path
  end

  local home = os.getenv("HOME")
  if home then
    cwd = cwd:gsub("^" .. home, "~")
  end

  if max_width and #cwd > max_width then
    cwd = ".." .. cwd:sub(-(max_width - 2))
  end

  return cwd
end

function M.get_remote_info(pane, max_len)
  local uri = pane:get_current_working_dir()
  -- wezterm.log_info("URI:", uri, "type:", type(uri))

  if type(uri) ~= "string" then
    uri = ""
  end

  local user, host, path =
    string.match(uri, "^file://([^@]+)@([^/]+)(/.+)$")

  if not user then
    local distro
    distro, path = string.match(uri, "^wsl://([^/]+)(/.+)$")
    if distro then
      host = distro
      user = os.getenv("USER") or os.getenv("USERNAME") or "user"
    end
  end

  if not user then
    host = wezterm.hostname()
    user = os.getenv("USER") or os.getenv("USERNAME") or "user"
    path = uri:match("^file:///(.+)$") or os.getenv("HOME") or "~"
  end

  if max_len and path and #path > max_len then
    path = "…" .. path:sub(-max_len)
  end

  return path, user, host
end

-- Workspace management
function M.switch_workspace(window, pane, workspace)
  local current = window:active_workspace()
  if current == workspace then return end

  window:perform_action(action.SwitchToWorkspace({ name = workspace }), pane)
  wezterm.GLOBAL.previous_workspace = current
end

function M.switch_previous_workspace(window, pane)
  local previous = wezterm.GLOBAL.previous_workspace
  if not previous or previous == window:active_workspace() then
    return
  end
  M.switch_workspace(window, pane, previous)
end

-- Visual effects
function M.flash_screen(window)
  return
end

return M