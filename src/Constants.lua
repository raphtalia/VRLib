local Hand = require(script.Parent.Hand)

return {
    CONTROLLER_KEYCODES = {
        [Hand.Left] = {
            HandTrigger = Enum.KeyCode.ButtonL1,
            IndexTrigger = Enum.KeyCode.ButtonL2,
            Thumbstick = Enum.KeyCode.Thumbstick1,
            ThumbstickButton = Enum.KeyCode.ButtonL3,
            Button1 = Enum.KeyCode.ButtonY,
            Button2 = Enum.KeyCode.ButtonX,
        },
        [Hand.Right] = {
            HandTrigger = Enum.KeyCode.ButtonR1,
            IndexTrigger = Enum.KeyCode.ButtonR2,
            Thumbstick = Enum.KeyCode.Thumbstick2,
            ThumbstickButton = Enum.KeyCode.ButtonR3,
            Button1 = Enum.KeyCode.ButtonB,
            Button2 = Enum.KeyCode.ButtonA,
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
