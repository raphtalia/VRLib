local Players = game:GetService("Players")

local TrackingBehavior = require(script.Parent.TrackingBehavior)
local Signal = require(script.Parent.Parent.Parent.Signal)
local Flipper = require(script.Parent.Parent.Parent.Flipper)
local t = require(script.Parent.Parent.Types).Panel

local fixSuperclass = require(script.Parent.Parent.Util.fixSuperclass)
local bindToRenderStep = require(script.Parent.Parent.Util.bindToRenderStep)
local setCFramePos = require(script.Parent.Parent.Util.setCFramePos)

local Constants = require(script.Parent.Parent.Constants)
local MIN_PART_SIZE = Constants.MIN_PART_SIZE

local LocalPlayer = Players.LocalPlayer

local function isPartInViewport(part)
    local cf = part.CFrame
    local halfSize = part.Size / 2

    local corners = {
        (cf * CFrame.new(-halfSize.X, halfSize.Y, 0)).Position,
        (cf * CFrame.new(halfSize.X, halfSize.Y, 0)).Position,
        (cf * CFrame.new(halfSize.X, -halfSize.Y, 0)).Position,
        (cf * CFrame.new(-halfSize.X, -halfSize.Y, 0)).Position,
    }

    for _,corner in ipairs(corners) do
        local _,isInViewport = workspace.CurrentCamera:WorldToViewportPoint(corner)

        if not isInViewport then
            return false
        end
    end

    return true
end

--[=[
    @class Panel
    WIP expansion for UI support, documentation to come
]=]
local Panel = {}
local PANEL_METATABLE = {}
function PANEL_METATABLE:__index(i)
    if i == "RootPart" then
        return rawget(self, "_rootPart")
    elseif i == "RootGui" then
        return rawget(self, "_rootGui")
    elseif i == "CFrame" then
        return rawget(self, "_cframe")
    elseif i == "Position" then
        return self.CFrame.Position
    elseif i == "Size" then
        return Vector2.new(self.RootPart.Size.X, self.RootPart.Size.Y)
    elseif i == "TrackingBehavior" then
        return rawget(self, "_trackingBehavior")
    elseif i == "DelayedTracking" then
        return rawget(self, "_delayedTracking")
    elseif i == "Destroying" then
        return rawget(self, "_destroying")
    else
        return PANEL_METATABLE[i] or error(i.. " is not a valid member of Panel", 2)
    end
end
function PANEL_METATABLE:__newindex(i, v)
    if i == "CFrame" then
        t.CFrame(v)
        rawset(self, "_cframe", v)
    elseif i == "Position" then
        t.Position(v)
        self.CFrame = setCFramePos(v, self.CFrame)
    elseif i == "Size" then
        t.Size(v)
        self.RootPart.Size = Vector3.new(v.X, v.Y, MIN_PART_SIZE)
    elseif i == "TrackingBehavior" then
        t.TrackingBehavior(v)
        rawset(self, "_trackingBehavior", v)
    elseif i == "DelayedTracking" then
        t.DelayedTracking(v)
        rawset(self, "_delayedTracking", v)
    else
        error(i.. " is not a valid member of Panel or is unassignable", 2)
    end
end

function Panel:constructor()
    -- roblox-ts compatibility
    fixSuperclass(self, Panel, PANEL_METATABLE)

    local rootPart = Instance.new("Part")
    rootPart.Name = "Panel"
    rootPart.Transparency = 1
    rootPart.Size = Vector3.new(1920 * 0.004, 1080 * 0.004, MIN_PART_SIZE)
    rootPart.CanCollide = false
    rootPart.CanTouch = false
    rootPart.Anchored = true
    rootPart.Parent = workspace.CurrentCamera
    local rootGui = Instance.new("SurfaceGui")
    rootGui.Name = "RootGui"
    rootGui.Adornee = rootPart
    rootGui.AlwaysOnTop = true
    rootGui.ResetOnSpawn = false
    rootGui.Face = Enum.NormalId.Back
    rootGui.Parent = LocalPlayer.PlayerGui

    rawset(self, "_rootPart", rootPart)
    rawset(self, "_rootGui", rootGui)
    rawset(self, "_cframe", CFrame.new(0, 0, -8))
    rawset(self, "_distance", 8)
    rawset(self, "_trackingBehavior", TrackingBehavior.HeadLocked)
    rawset(self, "_delayedTracking", false)
    rawset(self, "_destroying", Signal.new())

    local motors = Flipper.GroupMotor.new({
        Pitch = 0,
        Yaw = 0,
    })
    rawset(self, "RenderStepDisconnect", bindToRenderStep(Enum.RenderPriority.Last.Value, function(dt)
        local camera = workspace.CurrentCamera
        local panelBeavior = self.TrackingBehavior

        if panelBeavior ~= TrackingBehavior.Static then
            local values = motors:getValue()

            if panelBeavior == TrackingBehavior.HeadLocked then
                rootPart.CFrame = CFrame.new(camera.CFrame.Position)
                    * CFrame.Angles(0, values.Yaw, 0)
                    * CFrame.Angles(values.Pitch, 0, 0)
                    * self.CFrame
            elseif panelBeavior == TrackingBehavior.HorizontallyLocked then
                rootPart.CFrame = CFrame.new(camera.CFrame.Position)
                    * CFrame.Angles(0, values.Yaw, 0)
                    * self.CFrame
            end

            local pitch, yaw = camera:GetRenderCFrame():ToEulerAnglesYXZ()
            if self.DelayedTracking then
                if not isPartInViewport(rootPart) then
                    motors:setGoal({
                        Pitch = Flipper.Spring.new(pitch, { frequency = 0.5, dampingRatio = 1 }),
                        Yaw = Flipper.Spring.new(yaw, { frequency = 0.5, dampingRatio = 1 }),
                    })
                end
            else
                motors:setGoal({
                    Pitch = Flipper.Instant.new(pitch),
                    Yaw = Flipper.Instant.new(yaw),
                })
            end

            motors:step(dt)
        end
    end))
end

function Panel.new()
    local self = setmetatable({}, PANEL_METATABLE)
    Panel.constructor(self)

    return self
end

function PANEL_METATABLE:Destroy()
    self.Destroying:Fire()
    rawget(self, "RenderStepDisconnect")()
    self.RootPart:Destroy()
    self.RootGui:Destroy()
end

-- roblox-ts compatability
Panel.default = Panel
return Panel
