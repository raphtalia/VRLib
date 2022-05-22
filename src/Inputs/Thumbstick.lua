local Signal = require(script.Parent.Parent.Parent.Signal)
local t = require(script.Parent.Parent.Types).Thumbstick

local fixSuperclass = require(script.Parent.Parent.Util.fixSuperclass)

local Thumbstick = {}
local THUMBSTICK_METATABLE = {}
function THUMBSTICK_METATABLE:__index(i)
    if i == "RawLocation" then
        return rawget(self, "_rawLocation")
    elseif i == "Location" then
        if self.IsEdge then
            return self.RawLocation.Unit
        else
            return self.RawLocation
        end
    elseif i == "EdgeThreshold" then
        return rawget(self, "_edgeThreshold")
    elseif i == "IsDown" then
        return rawget(self, "_isDown")
    elseif i == "IsEdge" then
        return rawget(self, "_isEdge")
    elseif i == "Up" then
        return rawget(self, "_up")
    elseif i == "Down" then
        return rawget(self, "_down")
    elseif i == "Released" then
        return rawget(self, "_released")
    elseif i == "Changed" then
        return rawget(self, "_changed")
    elseif i == "EdgeEntered" then
        return rawget(self, "_edgeEntered")
    elseif i == "EdgeLeft" then
        return rawget(self, "_edgeLeft")
    else
        return THUMBSTICK_METATABLE[i] or error(i.. " is not a valid member of Thumbstick", 2)
    end
end
function THUMBSTICK_METATABLE:__newindex(i)
    error(i.. " is not a valid member of Thumbstick or is unassignable", 2)
end

function Thumbstick:constructor(edgeThreshold)
    t.new(edgeThreshold)

    -- roblox-ts compatibility
    fixSuperclass(self, Thumbstick, THUMBSTICK_METATABLE)

    rawset(self, "_rawLocation", Vector2.new())
    rawset(self, "_edgeThreshold", edgeThreshold or 0.95)
    rawset(self, "_isDown", false)
    rawset(self, "_isEdge", false)
    rawset(self, "_up", Signal.new())
    rawset(self, "_down", Signal.new())
    rawset(self, "_released", Signal.new())
    rawset(self, "_changed", Signal.new())
    rawset(self, "_edgeEntered", Signal.new())
    rawset(self, "_edgeLeft", Signal.new())
end

function Thumbstick.new(edgeThreshold)
    local self = setmetatable({}, THUMBSTICK_METATABLE)
    Thumbstick.constructor(self, edgeThreshold)

    return self
end

function THUMBSTICK_METATABLE:UpdateLocationAbsolute(loc)
    t.UpdateLocationAbsolute(loc)
    local delta = loc - self.RawLocation
    local mag = loc.Magnitude

    rawset(self, "_rawLocation", loc)
    if mag > self.EdgeThreshold then
        if not self.IsEdge then
            rawset(self, "_isEdge", true)
            self.EdgeEntered:Fire()
        end
    else
        if self.IsEdge then
            rawset(self, "_isEdge", false)
            self.EdgeLeft:Fire()
        end

        if mag == 0 then
            self.Released:Fire()
        end
    end

    if delta.Magnitude ~= 0 then
        self.Changed:Fire(loc, delta)
    end
end

function THUMBSTICK_METATABLE:UpdateLocationDelta(delta)
    t.UpdateLocationDelta(delta)
    self:UpdateLocationAbsolute(self.RawLocation + delta)
end

function THUMBSTICK_METATABLE:UpdateButton(isDown)
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

function THUMBSTICK_METATABLE:SetEdgeThreshold(edgeThreshold)
    t.SetThreshold(edgeThreshold)
    rawset(self, "_edgeThreshold", edgeThreshold)
    self:UpdateLocationAbsolute(self.Location)
end

-- roblox-ts compatability
Thumbstick.default = Thumbstick
return Thumbstick
