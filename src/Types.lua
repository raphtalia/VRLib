local t = require(script.Parent.Parent.t)

local Hand = require(script.Parent.Hand)
local TrackingBehavior = require(script.Parent.UI.TrackingBehavior)

local Headset = {
    UserCFrame = t.CFrame,
    UserPosition = t.Vector3,
    Velocity = t.Vector3,
}
local HeadsetInterface = t.interface(Headset)
local Controller = {
    UserCFrame = t.CFrame,
    UserPosition = t.Vector3,
    Velocity = t.Vector3,
    GamepadNum = t.enum(Enum.UserInputType),
}
local ControllerInterface = t.interface(Controller)
local Threshold = t.numberConstrainedExclusive(0, 1)

return {
    Headset = {
        UserCFrameOffset = function(v)
            assert(t.CFrame(v))
        end,

        UserPositionOffset = function(v)
            assert(t.Vector3(v))
        end,
    },
    Controller = {
        Hand = function(v)
            assert(Hand:BelongsTo(v), "Expected Hand EnumItem")
        end,

        GamepadNum = function(v)
            assert(Controller.GamepadNum(v))
        end,

        new = function(hand, gamepadNum)
            assert(Hand:BelongsTo(hand), "Expected Hand EnumItem")
            assert(t.optional(Controller.GamepadNum)(gamepadNum))
        end,

        SetMotor = function(vibrationValue)
            assert(t.numberConstrained(0, 1)(vibrationValue))
        end,

        Vibrate = function(vibrationValue, duration)
            assert(t.tuple(t.numberConstrained(0, 1), t.optional(t.number))(vibrationValue, duration))
        end,
    },
    ControllerAdornee = {
        new = function(controller, controllers)
            assert(t.tuple(ControllerInterface, t.children({
                LController = t.instanceOf("Model"),
                RController = t.instanceOf("Model"),
            }))(controller, controllers))
        end,
    },
    Button = {
        UpdateButton = function(isDown)
            assert(t.boolean(isDown))
        end,
    },
    Thumbstick = {
        new = function(edgeThreshold)
            assert(Threshold(edgeThreshold))
        end,

        UpdateLocationAbsolute = function(loc)
            assert(t.Vector2(loc))
        end,

        UpdateLocationDelta = function(delta)
            assert(t.Vector2(delta))
        end,

        UpdateButton = function(isDown)
            assert(t.boolean(isDown))
        end,

        SetEdgeThreshold = function(edgeThreshold)
            assert(Threshold(edgeThreshold))
        end,
    },
    Trigger = {
        new = function(threshold)
            assert(Threshold(threshold))
        end,

        UpdateTriggerAbsolute = function(pos)
            assert(t.number(pos))
        end,

        UpdateTriggerDelta = function(delta)
            assert(t.number(delta))
        end,

        SetTriggerThreshold = function(threshold)
            assert(Threshold(threshold))
        end,
    },
    VRCamera = {
        Headset = function(v)
            assert(HeadsetInterface(v))
        end,

        Height = function(v)
            assert(t.number(v))
        end,

        WorldCFrame = function(v)
            assert(t.CFrame(v))
        end,

        WorldPosition = function(v)
            assert(t.Vector3(v))
        end,

        HeadCFrame = function(v)
            assert(t.CFrame(v))
        end,

        HeadPosition = function(v)
            assert(t.Vector3(v))
        end,

        new = function(headset)
            assert(HeadsetInterface(headset))
        end,
    },
    LaserPointer = {
        Controller = function(v)
            assert(ControllerInterface(v))
        end,

        Length = function(v)
            assert(t.numberPositive(v))
        end,

        Visible = function(v)
            assert(t.boolean(v))
        end,

        RaycastParams = function(v)
            assert(t.RaycastParams(v))
        end,

        new = function(controller)
            assert(ControllerInterface(controller))
        end,
    },
    Panel = {
        CFrame = function(v)
            assert(t.CFrame(v))
        end,

        Position = function(v)
            assert(t.Vector3(v))
        end,

        Size = function(v)
            assert(t.Vector2(v))
        end,

        TrackingBehavior = function(v)
            assert(TrackingBehavior:BelongsTo(v), "Expected TrackingBehavior EnumItem")
        end,

        DelayedTracking = function(v)
            assert(t.boolean(v))
        end,
    }
}
