local UserInputService = game:GetService("UserInputService")
local VRService = game:GetService("VRService")

local Signal = require(script.Parent.Parent.Signal)
local t = require(script.Parent.Types).Headset

local fixSuperclass = require(script.Parent.Util.fixSuperclass)
local bindToRenderStep = require(script.Parent.Util.bindToRenderStep)
local setCFramePos = require(script.Parent.Util.setCFramePos)

--[=[
    @class Headset
]=]
local Headset = {}
local HEADSET_METATABLE = {}
function HEADSET_METATABLE:__index(i)
    if i == "RawUserCFrame" then
        --[=[
            @within Headset
            @readonly
            @prop RawUserCFrame CFrame
            The raw (unaffected by `Headset.UserCFrameOffset`) real-life
            position and rotation of the headset.
        ]=]
        return UserInputService:GetUserCFrame(Enum.UserCFrame.Head)
    elseif i == "UserCFrame" then
        --[=[
            @within Headset
            @readonly
            @prop UserCFrame CFrame
            The real-life position and rotation of the headset.
        ]=]
        return self.UserCFrameOffset
            * UserInputService:GetUserCFrame(Enum.UserCFrame.Head)
    elseif i == "RawUserPosition" then
        --[=[
            @within Headset
            @readonly
            @prop RawUserPosition Vector3
            The raw (unaffected by `Headset.UserPositionOffset`) real-life
            position of the headset.
        ]=]
        return self.RawUserCFrame.Position
    elseif i == "UserPosition" then
        --[=[
            @within Headset
            @readonly
            @prop UserPosition Vector3
            The real-life position of the headset.
        ]=]
        return self.UserCFrame.Position
    elseif i == "UserCFrameOffset" then
        --[=[
            @within Headset
            @prop UserCFrameOffset CFrame
            Offset applied before `Headset.UserCFrame` is returned.
        ]=]
        return rawget(self, "_userCFrameOffset")
    elseif i == "UserPositionOffset" then
        --[=[
            @within Headset
            @prop UserPositionOffset Vector3
            Offset applied before `Headset.UserPosition` is returned.
        ]=]
        return self.UserCFrameOffset.Position
    elseif i == "Velocity" then
        --[=[
            @within Headset
            @readonly
            @prop Velocity Vector3
            Headset's change in position over time.
        ]=]
        return rawget(self, "_velocity")
    elseif i == "Destroying" then
        --[=[
            @within Headset
            @readonly
            @prop Destroying Signal<>
            Fires while `Destroy()` is executing.
        ]=]
        return rawget(self, "_destroying")
    else
        return HEADSET_METATABLE[i] or error(i.. " is not a valid member of Headset", 2)
    end
end
function HEADSET_METATABLE:__newindex(i, v)
    if i == "UserCFrameOffset" then
        t.UserCFrameOffset(v)
        rawset(self, "_userCFrameOffset", v)
    elseif i == "UserPositionOffset" then
        t.UserPositionOffset(v)
        self.UserCFrameOffset = setCFramePos(v, self.UserCFrameOffset)
    else
        error(i.. " is not a valid member of Headset or is unassignable", 2)
    end
end

function Headset:constructor()
    -- roblox-ts compatibility
    fixSuperclass(self, Headset, HEADSET_METATABLE)

    if not VRService:GetUserCFrameEnabled(Enum.UserCFrame.Head) then
        error("Headset not detected", 2)
    end

    rawset(self, "_userCFrameOffset", CFrame.new())
    rawset(self, "_velocity", Vector3.zero)
    rawset(self, "_destroying", Signal.new())

    local lastUserPos = self.UserPosition
    rawset(self, "RenderStepDisconnect", bindToRenderStep(Enum.RenderPriority.Input.Value, function(dt)
        local userPos = self.UserPosition
        rawset(self, "_velocity", (userPos - lastUserPos) / dt)
        lastUserPos = userPos
    end))
end

--[=[
    @within Headset
    @return Headset
]=]
function Headset.new()
    local self = setmetatable({}, HEADSET_METATABLE)
    Headset.constructor(self)

    return self
end

--[=[
    @within Headset
]=]
function HEADSET_METATABLE:Destroy()
    self.Destroying:Fire()
    rawget(self, "RenderStepDisconnect")()
end

--[=[
    @within Headset
    Equivalent to `UserInputService:RecenterUserHeadCFrame()` and
    `VRService:RecenterUserHeadCFrame()`.
]=]
function HEADSET_METATABLE:Recenter()
    UserInputService:RecenterUserHeadCFrame()
end

-- roblox-ts compatability
Headset.default = Headset
return Headset
