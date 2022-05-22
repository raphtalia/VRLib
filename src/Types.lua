local t = require(script.Parent.Parent.t)

local Hand = require(script.Parent.Hand)

local Controller = {
    CFrame = t.CFrame,
    Position = t.Vector3,
    Velocity = t.Vector3,
    GamepadNum = t.enum(Enum.UserInputType),
    HandTriggerPosition = t.number,
    IndexTriggerPosition = t.number,
    ThumbstickLocation = t.Vector2,
}
local ControllerInterface = t.interface(Controller)

return {
    Headset = {
        Height = function(v)
            assert(t.numberPositive(v))
        end,

        MoveTo = function(cf, addHeight)
            assert(t.tuple(t.union(t.CFrame, t.Vector3), t.optional(t.boolean))(cf, addHeight))
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
}
