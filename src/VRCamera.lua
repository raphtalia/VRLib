local Signal = require(script.Parent.Parent.Signal)
local t = require(script.Parent.Types).VRCamera

local fixSuperclass = require(script.Parent.Util.fixSuperclass)
local bindToRenderStep = require(script.Parent.Util.bindToRenderStep)
local setCFramePos = require(script.Parent.Util.setCFramePos)

--[=[
    @class VRCamera
    Substitute for using `Camera.HeadLocked` with more control for developers.
    If a laser pointer is needed you must use `VRLib.LaserPointer` as Roblox's
    built-in laser pointer does not work without `Camera.HeadLocked`.
]=]
local VRCamera = {}
local VR_CAMERA_METATABLE = {}
function VR_CAMERA_METATABLE:__index(i)
    if i == "Headset" then
        --[=[
            @within VRCamera
            @prop Headset Headset
            Reference to the headset that the camera is tracking.
        ]=]
        return rawget(self, "_headset")
    elseif i == "Height" then
        --[=[
            @within VRCamera
            @prop Height number
            The vertical offset used to match the in-game floor to the
            real-life floor. This is not always the same as the height of the
            person.
        ]=]
        return rawget(self, "_height")
    elseif i == "WorldCFrame" then
        --[=[
            @within VRCamera
            @prop WorldCFrame CFrame
            The in-game rotation and floor position of the camera. This can be
            thought of as the location of the base of the camera.
        ]=]
        return rawget(self, "_worldCFrame")
    elseif i == "WorldPosition" then
        --[=[
            @within VRCamera
            @prop WorldPosition Vector3
            The in-game floor position of the camera.
        ]=]
        return self.WorldCFrame.Position
    elseif i == "HeadCFrame" then
        --[=[
            @within VRCamera
            @unreleased
            @prop HeadCFrame CFrame
            The in-game rotation and position of the headset. This is
            `CFrame.new(0, VRCamera.Height, 0) * VRCamera.WorldCFrame * VRCamera.Headset.UserCFrame`.
        ]=]
        return CFrame.new(0, self.Height, 0) * self.WorldCFrame * self.Headset.UserCFrame
    elseif i == "HeadPosition" then
        --[=[
            @within VRCamera
            @unreleased
            @prop HeadPosition Vector3
            The in-game position of the headset.
        ]=]
        return self.HeadCFrame.Position
    elseif i == "Destroying" then
        --[=[
            @within VRCamera
            @prop Destroying Signal<>
            Fires while `Destroy()` is executing.
        ]=]
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
        self.WorldCFrame = setCFramePos(v, self.WorldCFrame)
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

--[=[
    @within VRCamera
    @param headset Headset
    @return VRCamera
]=]
function VRCamera.new(headset)
    local self = setmetatable({}, VR_CAMERA_METATABLE)
    VRCamera.constructor(self, headset)

    return self
end

--[=[
    @within VRCamera
]=]
function VR_CAMERA_METATABLE:Destroy()
    self.Destroying:Fire()
    rawget(self, "RenderStepDisconnect")()
    workspace.CurrentCamera.HeadLocked = true
end

-- roblox-ts compatability
VRCamera.default = VRCamera
return VRCamera
