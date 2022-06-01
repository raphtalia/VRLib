--[=[
    @class Hand

    Roblox Enums provides similar and sometimes redundant EnumItems when
    referring to the left and right hand controllers. For the purpose of this
    library this custom Enum simplifies the use by internally translating to
    the corresponding EnumItem.
]=]
--[=[
    @within Hand
    @prop Left EnumItem
    * `UserCFrame.LeftHand`
    * `VRTouchpad.Left`
    * `VibrationMotor.LeftHand`
]=]
--[=[
    @within Hand
    @prop Right EnumItem
    * `UserCFrame.RightHand`
    * `VRTouchpad.Right`
    * `VibrationMotor.RightHand`
]=]
return require(script.Parent.Parent.EnumList).new("Hand", {
    "Left",
    "Right",
})
