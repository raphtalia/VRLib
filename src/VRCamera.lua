local Signal = require(script.Parent.Parent.Signal)
local t = require(script.Parent.Types).VRCamera

local fixSuperclass = require(script.Parent.Util.fixSuperclass)
local bindToRenderStep = require(script.Parent.Util.bindToRenderStep)

local VRCamera = {}
local VR_CAMERA_METATABLE = {}
function VR_CAMERA_METATABLE:__index(i)
    if i == "Headset" then
        return rawget(self, "_headset")
    elseif i == "Height" then
        return rawget(self, "_height")
    elseif i == "WorldCFrame" then
        return rawget(self, "_worldCFrame")
    elseif i == "WorldPosition" then
        return self.WorldCFrame.Position
    elseif i == "HeadCFrame" then
        return CFrame.new(0, self.Height, 0) * self.WorldCFrame * self.Headset.UserCFrame
    elseif i == "HeadPosition" then
        return self.HeadCFrame.Position
    elseif i == "Destroying" then
        return rawget(self, "_destroying")
    else
        return VR_CAMERA_METATABLE[i] or error(i.. " is not a valid member of VRCamera", 2)
    end
end
function VR_CAMERA_METATABLE:__newindex(i, v)
    if i == "Headset" then
        t.Headset(v)
        rawset(self, "_headset", v)
    elseif i == "Height" then
        t.Height(v)
        rawset(self, "_height", v)
    elseif i == "WorldCFrame" then
        t.WorldCFrame(v)
        rawset(self, "_worldCFrame", v)
    elseif i == "WorldPosition" then
        t.WorldPosition(v)
        self.WorldCFrame = CFrame.new(v - self.WorldPosition) * self.WorldCFrame
    elseif i == "HeadCFrame" then
        t.HeadCFrame(v)
        -- TODO: Implement
    elseif i == "HeadPosition" then
        t.HeadPosition(v)
        -- TODO: Implement
    else
        error(i.. " is not a valid member of VRCamera or is unassignable", 2)
    end
end

function VRCamera:constructor(headset)
    t.new(headset)

    -- roblox-ts compatibility
    fixSuperclass(self, VRCamera, VR_CAMERA_METATABLE)

    rawset(self, "_headset", headset)
    rawset(self, "_height", 5)
    rawset(self, "_worldCFrame", CFrame.new())
    rawset(self, "_destroying", Signal.new())

    rawset(self, "RenderStepDisconnect", bindToRenderStep(Enum.RenderPriority.Camera.Value, function()
        local camera = workspace.CurrentCamera
        camera.HeadLocked = false
        camera.CFrame = self.HeadCFrame
    end))
end

function VRCamera.new(headset)
    local self = setmetatable({}, VR_CAMERA_METATABLE)
    VRCamera.constructor(self, headset)

    return self
end

function VR_CAMERA_METATABLE:Destroy()
    self.Destroying:Fire()
    rawget(self, "RenderStepDisconnect")()
    workspace.CurrentCamera.HeadLocked = true
end

-- roblox-ts compatability
VRCamera.default = VRCamera
return VRCamera
