local Signal = require(script.Parent.Parent.Parent.Signal)
local t = require(script.Parent.Parent.Types).Thumbstick

local fixSuperclass = require(script.Parent.Parent.Util.fixSuperclass)

--[=[
    @class Thumbstick
    An analog stick that includes a binary switch.
]=]
local Thumbstick = {}
local THUMBSTICK_METATABLE = {}
function THUMBSTICK_METATABLE:__index(i)
    if i == "RawLocation" then
        --[=[
            @within Thumbstick
            @readonly
            @prop RawLocation Vector2
            The unprocessed location of the thumbstick. This means the location
            could have a negative magnitude or greater than 1.
        ]=]
        return rawget(self, "_rawLocation")
    elseif i == "Location" then
        --[=[
            @within Thumbstick
            @readonly
            @prop Location Vector2
            Location is garunteed to have a magnitude of 0 when at rest and a
            magnitude of 1 when past the edge threshold.
        ]=]
        if self.IsEdge then
            return self.RawLocation.Unit
        else
            -- We don't bother clamping the lower bound as its auto reset to 0
            return math.min(self.RawLocation, 1)
        end
    elseif i == "EdgeThreshold" then
        --[=[
            @within Thumbstick
            @readonly
            @prop EdgeThreshold number
            The threshold at which the thumbstick is considered to be at the
            edge.
        ]=]
        return rawget(self, "_edgeThreshold")
    elseif i == "IsDown" then
        --[=[
            @within Thumbstick
            @readonly
            @prop IsDown boolean
            If the thumbstick is currently down.
        ]=]
        return rawget(self, "_isDown")
    elseif i == "IsEdge" then
        --[=[
            @within Thumbstick
            @readonly
            @prop IsEdge boolean
            If the thumbstick is at the edge.
        ]=]
        return rawget(self, "_isEdge")
    elseif i == "Up" then
        --[=[
            @within Thumbstick
            @readonly
            @prop Up Signal<>
            Fires when the thumbstick's is released as a button.
        ]=]
        return rawget(self, "_up")
    elseif i == "Down" then
        --[=[
            @within Thumbstick
            @readonly
            @prop Down Signal<>
            Fires when the thumbstick's is pressed as a button.
        ]=]
        return rawget(self, "_down")
    elseif i == "Released" then
        --[=[
            @within Thumbstick
            @readonly
            @prop Released Signal<>
            Fires when the thumbstick returns to center.
        ]=]
        return rawget(self, "_released")
    elseif i == "Changed" then
        --[=[
            @within Thumbstick
            @readonly
            @prop Changed Signal<(loc: Vector2, delta: Vector2)>
            Fires when the thumbstick's location changes.
        ]=]
        return rawget(self, "_changed")
    elseif i == "EdgeEntered" then
        --[=[
            @within Thumbstick
            @readonly
            @prop EdgeEntered Signal<>
            Fires when the thumbstick enters the edge.
        ]=]
        return rawget(self, "_edgeEntered")
    elseif i == "EdgeLeft" then
        --[=[
            @within Thumbstick
            @readonly
            @prop EdgeLeft Signal<>
            Fires when the thumbstick leaves the edge.
        ]=]
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

--[=[
    @within Thumbstick
    @param edgeThreshold number
    @return Thumbstick
]=]
function Thumbstick.new(edgeThreshold)
    local self = setmetatable({}, THUMBSTICK_METATABLE)
    Thumbstick.constructor(self, edgeThreshold)

    return self
end

--[=[
    @within Thumbstick
    @param loc Vector2
    Updates the location of the thumbstick by an absolute value.
]=]
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

--[=[
    @within Thumbstick
    @param delta Vector2
    Updates the location of the thumbstick by a relative value.
]=]
function THUMBSTICK_METATABLE:UpdateLocationDelta(delta)
    t.UpdateLocationDelta(delta)
    self:UpdateLocationAbsolute(self.RawLocation + delta)
end

--[=[
    @within Thumbstick
    @param isDown boolean
    Updates the state of the thumbstick as a button.
]=]
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

--[=[
    @within Thumbstick
    @param edgeThreshold number
    Updates the edge threshold of the thumbstick.
]=]
function THUMBSTICK_METATABLE:SetEdgeThreshold(edgeThreshold)
    t.SetThreshold(edgeThreshold)
    rawset(self, "_edgeThreshold", edgeThreshold)
    self:UpdateLocationAbsolute(self.Location)
end

-- roblox-ts compatability
Thumbstick.default = Thumbstick
return Thumbstick
