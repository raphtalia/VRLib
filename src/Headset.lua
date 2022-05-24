local UserInputService = game:GetService("UserInputService")
local VRService = game:GetService("VRService")

local Signal = require(script.Parent.Parent.Signal)
-- local t = require(script.Parent.Types).Headset

local fixSuperclass = require(script.Parent.Util.fixSuperclass)
local bindToRenderStep = require(script.Parent.Util.bindToRenderStep)

local Headset = {}
local HEADSET_METATABLE = {}
function HEADSET_METATABLE:__index(i)
    if i == "UserCFrame" then
        return UserInputService:GetUserCFrame(Enum.UserCFrame.Head)
    elseif i == "UserPosition" then
        return self.UserCFrame.Position
    elseif i == "Velocity" then
        return rawget(self, "_velocity")
    elseif i == "Destroying" then
        return rawget(self, "_destroying")
    else
        return HEADSET_METATABLE[i] or error(i.. " is not a valid member of Headset", 2)
    end
end
function HEADSET_METATABLE:__newindex(i)
    error(i.. " is not a valid member of Headset or is unassignable", 2)
end

function Headset:constructor()
    -- roblox-ts compatibility
    fixSuperclass(self, Headset, HEADSET_METATABLE)

    if not VRService:GetUserCFrameEnabled(Enum.UserCFrame.Head) then
        error("Headset not detected", 2)
    end

    rawset(self, "_velocity", Vector3.new())
    rawset(self, "_destroying", Signal.new())

    local lastUserPos = self.UserPosition
    rawset(self, "RenderStepDisconnect", bindToRenderStep(Enum.RenderPriority.Input.Value, function(dt)
        local userPos = self.UserPosition
        rawset(self, "_velocity", (userPos - lastUserPos) / dt)
        lastUserPos = userPos
    end))
end

function Headset.new()
    local self = setmetatable({}, HEADSET_METATABLE)
    Headset.constructor(self)

    return self
end

function HEADSET_METATABLE:Destroy()
    self.Destroying:Fire()
    rawget(self, "RenderStepDisconnect")()
end

function HEADSET_METATABLE:Recenter()
    UserInputService:RecenterUserHeadCFrame()
end

-- roblox-ts compatability
Headset.default = Headset
return Headset
