local t = require(script.Parent.Parent.t)

local Hand = require(script.Parent.Hand)

return {
    Headset = {

    },
    Controller = {
        Hand = function(v)
            assert(Hand:BelongsTo(v), "Expected Hand EnumItem")
        end,

        GamepadNum = function(v)
            assert(t.enum(Enum.UserInputType)(v))
        end,

        new = function(hand)
            assert(Hand:BelongsTo(hand), "Expected Hand EnumItem")
        end,
    },
    ControllerAdornee = {
        new = function(controller, controllers)

        end,
    },
}
