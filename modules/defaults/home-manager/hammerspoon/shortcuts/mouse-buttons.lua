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
