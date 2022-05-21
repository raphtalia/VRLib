local Hand = require(script.Parent.Hand)

return {
    GAMEPAD_KEYCODES = {
        [Hand.Left] = {
            Enum.KeyCode.ButtonL1,
            Enum.KeyCode.ButtonL2,
            Enum.KeyCode.Thumbstick1,
            Enum.KeyCode.ButtonY,
            Enum.KeyCode.ButtonX,
        },
        [Hand.Right] = {
            Enum.KeyCode.ButtonR1,
            Enum.KeyCode.ButtonR2,
            Enum.KeyCode.Thumbstick2,
            Enum.KeyCode.ButtonB,
            Enum.KeyCode.ButtonA,
        }
    },
    GAMEPAD_KEYCODES_MAP = {
        [Hand.Left] = {
            HandTrigger = Enum.KeyCode.ButtonL1,
            IndexTrigger = Enum.KeyCode.ButtonL2,
            Thumbstick = Enum.KeyCode.Thumbstick1,
        },
        [Hand.Right] = {
            HandTrigger = Enum.KeyCode.ButtonR1,
            IndexTrigger = Enum.KeyCode.ButtonR2,
            Thumbstick = Enum.KeyCode.Thumbstick2,
        },
    },
    HAND_USER_CFRAME_MAP = {
        [Hand.Left] = Enum.UserCFrame.LeftHand,
        [Hand.Right] = Enum.UserCFrame.RightHand,
    },
    HAND_CONTROLLER_NAME_MAP = {
        [Hand.Left] = "LController",
        [Hand.Right] = "RController",
    },
}
