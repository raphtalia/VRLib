local Signal = require(script.Parent.Parent.Parent.Signal)
local t = require(script.Parent.Parent.Types).Button

local fixSuperclass = require(script.Parent.Parent.Util.fixSuperclass)

--[=[
    @class Button
    A binary switch.
]=]
local Button = {}
local BUTTON_METATABLE = {}
function BUTTON_METATABLE:__index(i)
    if i == "IsDown" then
        --[=[
            @within Button
            @readonly
            @prop IsDown boolean
            If the button is currently down.
        ]=]
        return rawget(self, "_isDown")
    elseif i == "Up" then
        --[=[
            @within Button
            @readonly
            @prop Up Signal<>
            Fires when the button is released.
        ]=]
        return rawget(self, "_up")
    elseif i == "Down" then
        --[=[
            @within Button
            @prop Down Signal<>
            Fires when the button is pressed.
        ]=]
        return rawget(self, "_down")
    else
        return BUTTON_METATABLE[i] or error(i.. " is not a valid member of Button", 2)
    end
end
function BUTTON_METATABLE:__newindex(i)
    error(i.. " is not a valid member of Button or is unassignable", 2)
end

function Button:constructor()
    -- roblox-ts compatibility
    fixSuperclass(self, Button, BUTTON_METATABLE)

    rawset(self, "_isDown", false)
    rawset(self, "_up", Signal.new())
    rawset(self, "_down", Signal.new())
end

--[=[
    @within Button
    @return Button
]=]
function Button.new()
    local self = setmetatable({}, BUTTON_METATABLE)
    Button.constructor(self)

    return self
end

--[=[
    @within Button
    @param isDown boolean
    Updates the button's state.
]=]
function BUTTON_METATABLE:UpdateButton(isDown)
    t.UpdateButton(isDown)

    if isDown ~= self.IsDown then
        rawset(self, "_isDown", isDown)

        if isDown then
            self.Down:Fire()
        else
            self.Up:Fire()
        end
    end
end

-- roblox-ts compatability
Button.default = Button
return Button
