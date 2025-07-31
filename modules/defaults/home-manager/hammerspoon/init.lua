require('shortcuts/misc')
require('shortcuts/mouse-buttons')

-- causes eventtap to respond to *all* events that it can, except keyboard stuff
-- a = hs.eventtap.new({"all", hs.eventtap.event.types.flagsChanged, hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp}, function(e) print(e:getType()) end):start()

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
