local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local VRLib = require(ReplicatedStorage.Packages.VRLib)
local Promise = require(ReplicatedStorage.Packages.Promise)

Promise.all({
    VRLib.waitForUserCFrameAsync(Enum.UserCFrame.Head),
    VRLib.waitForUserCFrameAsync(Enum.UserCFrame.LeftHand),
    VRLib.waitForUserCFrameAsync(Enum.UserCFrame.RightHand),
}):expect()

local leftController = VRLib.Controllers.Quest2.new(VRLib.Hand.Left)
local rightController = VRLib.Controllers.Quest2.new(VRLib.Hand.Right)
local headset = VRLib.Headset.new()
local vrCamera = VRLib.VRCamera.new(headset)
local leftLaser = VRLib.LaserPointer.new(leftController)
leftLaser.Length = 32
leftLaser.Visible = false
local rightLaser = VRLib.LaserPointer.new(rightController)
rightLaser.Length = 32
rightLaser.Visible = false

local function goto(pos)
    local rawUserPos = headset.RawUserPosition
    vrCamera.WorldPosition = pos
    -- Set the UserCFrame to where the person is standing while keeping rotation
    headset.UserPositionOffset = Vector3.new(-rawUserPos.X, 0, -rawUserPos.Z)
end

leftController.Inputs.Thumbstick.Changed:Connect(function(loc)
    -- Without this check NaN values will be written to VRCamera
    if loc.Magnitude > 0 then
        local frontDir = vrCamera.HeadCFrame:VectorToWorldSpace(Vector3.new(loc.X, 0, -loc.Y))
        vrCamera.WorldPosition += Vector3.new(frontDir.X, 0, frontDir.Z).Unit * loc.Magnitude * 0.5
    end
end)

leftController.Inputs.IndexTrigger.FullyDown:Connect(function()
    leftLaser.Visible = true
end)

leftController.Inputs.IndexTrigger.Up:Connect(function()
    leftLaser.Visible = false
    if leftLaser.RaycastResult then
        goto(leftLaser.RaycastResult.Position)
    end
end)

rightController.Inputs.Thumbstick.EdgeEntered:Connect(function()
    local loc = rightController.Inputs.Thumbstick.Location
    local angle = math.deg(math.atan2(loc.X, loc.Y)) + 180

    if angle > 30 and angle < 150 then
        vrCamera.WorldCFrame *= CFrame.Angles(0, math.rad(30), 0)
    elseif angle > 210 and angle < 330 then
        vrCamera.WorldCFrame *= CFrame.Angles(0, math.rad(-30), 0)
    end
end)

rightController.Inputs.IndexTrigger.FullyDown:Connect(function()
    rightLaser.Visible = true
end)

rightController.Inputs.IndexTrigger.Up:Connect(function()
    rightLaser.Visible = false
    if rightLaser.RaycastResult then
        goto(rightLaser.RaycastResult.Position)
    end
end)

rightController.Inputs.Button2.Down:Connect(function()
    vrCamera.WorldCFrame = CFrame.new()
end)

-- Push the camera up if the controllers are below the floor
RunService.RenderStepped:Connect(function()
    local leftWorldPos = leftController.WorldPosition
    local rightWorldPos = rightController.WorldPosition
    local camWorldPos = vrCamera.WorldPosition

    if leftWorldPos.Y < camWorldPos.Y then
        vrCamera.Height += camWorldPos.Y - leftWorldPos.Y
    elseif rightWorldPos.Y < camWorldPos.Y then
        vrCamera.Height += camWorldPos.Y - rightWorldPos.Y
    end
end)
