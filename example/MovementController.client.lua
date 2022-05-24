local ReplicatedStorage = game:GetService("ReplicatedStorage")

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

leftController.ThumbstickChanged:Connect(function(loc)
    -- Without this check NaN values will be written to VRCamera
    if loc.Magnitude > 0 then
        local moveDir = vrCamera.HeadCFrame:VectorToWorldSpace(Vector3.new(loc.X, 0, -loc.Y))
        vrCamera.WorldPosition += Vector3.new(moveDir.X, 0, moveDir.Z).Unit * loc.Magnitude * 0.5
    end
end)

leftController.IndexTriggerFullyDown:Connect(function()
    leftLaser.Visible = true
end)

leftController.IndexTriggerUp:Connect(function()
    leftLaser.Visible = false
    if leftLaser.RaycastResult then
        vrCamera.WorldPosition = leftLaser.RaycastResult.Position
    end
end)

rightController.ThumbstickEdgeEntered:Connect(function()
    local loc = rightController.ThumbstickLocation
    local angle = math.deg(math.atan2(loc.X, loc.Y)) + 180

    if angle > 30 and angle < 150 then
        vrCamera.WorldCFrame *= CFrame.Angles(0, math.rad(30), 0)
    elseif angle > 210 and angle < 330 then
        vrCamera.WorldCFrame *= CFrame.Angles(0, math.rad(-30), 0)
    end
end)

rightController.IndexTriggerFullyDown:Connect(function()
    rightLaser.Visible = true
end)

rightController.IndexTriggerUp:Connect(function()
    rightLaser.Visible = false
    if rightLaser.RaycastResult then
        vrCamera.WorldPosition = rightLaser.RaycastResult.Position
    end
end)

rightController.Button2Down:Connect(function()
    vrCamera.WorldCFrame = CFrame.new()
end)
