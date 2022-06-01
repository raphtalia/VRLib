---
sidebar_position: 1
---

# Getting Started

VRLib aims to eventually standardize and simplify interfacing with VR hardware and user interfaces.

## Installation

VRLib can be installed with [Wally](https://wally.run) by adding it to the `[dependencies]` section of your
`wally.toml` file.

```toml
[package]
name = "your_name/your_project"
version = "0.1.0"
registry = "https://github.com/UpliftGames/wally-index"
realm = "shared"

[dependencies]
VRLib = "raphtalia/vrlib@^1"
```

## Usage

Below is an example of an extremely simple movement controller for the Quest 2.

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VRLib = require(ReplicatedStorage.Packages.VRLib)

-- Wait for the VR devices to be ready (turn them on and connect them)
VRLib.waitForUserCFrameAsync(Enum.UserCFrame.Head):expect()
VRLib.waitForUserCFrameAsync(Enum.UserCFrame.LeftHand):expect()
VRLib.waitForUserCFrameAsync(Enum.UserCFrame.RightHand):expect()

-- Create the interfaces for the VR devices
local leftController = VRLib.Controllers.Quest2.new(VRLib.Hand.Left)
local rightController = VRLib.Controllers.Quest2.new(VRLib.Hand.Right)
local headset = VRLib.Headset.new()

-- Override Roblox's default VR camera
local vrCamera = VRLib.VRCamera.new(headset)

-- Create the lasers and make them invisible by default
local leftLaser = VRLib.LaserPointer.new(leftController)
leftLaser.Visible = false
local rightLaser = VRLib.LaserPointer.new(rightController)
rightLaser.Visible = false

--[[
    Holding down the index triggers on the controllers toggle a laser pointer
    that teleport the player to where the laser hits.
]]
leftController.Inputs.IndexTrigger.FullyDown:Connect(function()
    leftLaser.Visible = true
end)
leftController.Inputs.IndexTrigger.Up:Connect(function()
    leftLaser.Visible = false
    if leftLaser.RaycastResult then
        vrCamera.WorldPosition = leftLaser.RaycastResult.Position
    end
end)

rightController.Inputs.IndexTrigger.FullyDown:Connect(function()
    rightLaser.Visible = true
end)

rightController.Inputs.IndexTrigger.Up:Connect(function()
    rightLaser.Visible = false
    if rightLaser.RaycastResult then
        vrCamera.WorldPosition = rightLaser.RaycastResult.Position
    end
end)
```

## Controller Support

Headset support should work across the board while the controller support is more difficult due to different input schemes and varying levels of support from Roblox themselves.

-   :white_check_mark: - Fully supported
-   :warning: - Partially supported
-   :soon: - Not yet supported
-   :x: - Will not be supported

| Controllers  |       Status       | Notes                                             |
| :----------: | :----------------: | ------------------------------------------------- |
| Oculus Touch | :white_check_mark: |                                                   |
| Valve Index  |     :warning:      | Roblox maps the grip pressure sensors to buttons. |
|   HTC Vive   |       :soon:       | Completely untested.                              |
