local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VRLib = require(ReplicatedStorage.Packages.VRLib)

local panel = VRLib.UI.Panel.new()
panel.TrackingBehavior = VRLib.UI.TrackingBehavior.HorizontallyLocked
panel.DelayedTracking = true
