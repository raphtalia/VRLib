local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Signal = require(script.Parent.Parent.Signal)

local fixSuperclass = require(script.Parent.Util.fixSuperclass)

local Headset = {}
local HEADSET_METATABLE = {}
function HEADSET_METATABLE:__index(i)
    if i == "CFrame" then
        return UserInputService:GetUserCFrame(Enum.UserCFrame.Head)
    elseif i == "Position" then
        return self.CFrame.Position
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

    rawset(self, "_velocity", Vector3.new())
    rawset(self, "_destroying", Signal.new())

    local lastUserPos = self.Position
    rawset(self, "HeartbeatConnection", RunService.Heartbeat:Connect(function(dt)
        local userPos = self.Position
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
    rawget(self, "HeartbeatConnection"):Disconnect()
end

function HEADSET_METATABLE:Recenter()
    UserInputService:RecenterUserHeadCFrame()
end

function HEADSET_METATABLE:MoveTo(cframe)
    workspace.CurrentCamera.CFrame = cframe
end

-- roblox-ts compatability
Headset.default = Headset
return Headset
