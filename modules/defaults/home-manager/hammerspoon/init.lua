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

hs.hotkey.bind({"alt", "shift"}, "F12", function()
  primary = hs.screen.primaryScreen()
  frame = primary:frame()
  hs.mouse.absolutePosition(primary:localToAbsolute({x = frame.w / 2, y = frame.h / 2}))
end)

-- causes eventtap to respond to *all* events that it can, except keyboard stuff
-- a = hs.eventtap.new({"all", hs.eventtap.event.types.flagsChanged, hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp}, function(e) print(e:getType()) end):start()

-- change space with ctrl+mouse button
hs.eventtap.new(
  {
    hs.eventtap.event.types.leftMouseDown,
    hs.eventtap.event.types.rightMouseDown
  },
  function(e)
    print('something')

    if e:getFlags()["ctrl"] == true then
      hs.eventtap.event.newKeyEvent(hs.keycodes.map.ctrl, true):post()
      if (e:getType() == hs.eventtap.event.types.leftMouseDown) then
        print('workspace left')
        hs.eventtap.event.newKeyEvent(hs.keycodes.map.left, true):post()
        hs.eventtap.event.newKeyEvent(hs.keycodes.map.left, false):post()
      elseif (e:getType() == hs.eventtap.event.types.rightMouseDown) then
        print('workspace right')
        hs.eventtap.event.newKeyEvent(hs.keycodes.map.right, true):post()
        hs.eventtap.event.newKeyEvent(hs.keycodes.map.right, false):post()
      end
      hs.eventtap.event.newKeyEvent(hs.keycodes.map.ctrl, false):post()
      return true
    end
  end
):start()

-- forward & backward mouse buttons
hs.eventtap.new({hs.eventtap.event.types.otherMouseDown}, function(e)
  local cases = {
    -- back button
    [3] = function()
      print('back')
      hs.eventtap.keyStroke({'cmd'}, '[')
    end,
    -- forward button
    [4] = function()
      print('forward')
      hs.eventtap.keyStroke({'cmd'}, ']')
    end,
  }

  local case = cases[e:getProperty(hs.eventtap.event.properties['mouseEventButtonNumber'])]

  if case then
    case()
    return true
  end
end):start()

-- local apple_music_binds = hs.hotkey.modal.new()
-- apple_music_binds:bind({}, hs.eventtap.event.types.otherMouseDown, function(e)
--   print(e:getProperty(hs.eventtap.event.properties['mouseEventButtonNumber']))
--   -- TODO: I think this is the back button?
--   if e:getProperty(hs.eventtap.event.properties['mouseEventButtonNumber']) == 3 then
--     hs.eventtap.keyStroke({'cmd'}, "[")
--   end
-- end)
-- apple_music_binds:bind({}, hs.eventtap.event.types.leftMouseDown, function(e)
--   print("leftclick")
-- end)
-- apple_music_binds:bind({}, 'f1', function(e)
--   print("f1")
-- end)

-- hs.window.filter.new('Music')
--     :subscribe(hs.window.filter.windowFocused, function()
--         print('enter')
--         apple_music_binds:enter()
--     end)
--     :subscribe(hs.window.filter.windowUnfocused, function()
--         print('exit')
--         apple_music_binds:exit()
--     end)





function indexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end
