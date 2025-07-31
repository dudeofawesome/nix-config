-- type out clipboard contents
hs.hotkey.bind({"cmd", "ctrl", "alt", "shift"}, "V", function()
  hs.eventtap.keyStrokes(hs.pasteboard.getContents())
  return true
end)

-- toggle dark mode
hs.hotkey.bind({"cmd", "alt", "shift"}, "D", function()
  hs.osascript.applescript('tell app "System Events" to tell appearance preferences to set dark mode to not dark mode')
  -- hs.osascript.applescript('tell app "System Events" to tell appearance preferences to set dark mode to auto')
  return true
end)

-- turn off & lock screen
hs.hotkey.bind({"ctrl", "shift"}, "F12", function()
  hs.caffeinate.systemSleep()
  return true
end)

-- move mouse to center of primary monitor
hs.hotkey.bind({"alt", "shift"}, "F12", function()
  primary = hs.screen.primaryScreen()
  frame = primary:frame()
  hs.mouse.absolutePosition(primary:localToAbsolute({x = frame.w / 2, y = frame.h / 2}))
end)
