--[=[
    @class VRLib
]=]
local VRLib = {}

--[=[
    @within VRLib
    @prop Hand Hand
]=]
VRLib.Hand = require(script.Hand)

--[=[
    @within VRLib
    @prop Headset Headset
]=]
VRLib.Headset = require(script.Headset)

--[=[
    @within VRLib
    @interface Controllers
    @field Quest2 Quest2Controller
]=]
VRLib.Controllers = {
    Quest2 = require(script.Controllers.Quest2Controller)
}

--[=[
    @within VRLib
    @interface ControllerAdornees
    @field Quest2 Quest2ControllerAdornee
]=]
VRLib.ControllerAdornees = {
    Quest2 = require(script.ControllerAdornees.Quest2ControllerAdornee)
}

--[=[
    @within VRLib
    @interface UI
    @field TrackingBehavior TrackingBehavior
    @field Panel Panel
]=]
VRLib.UI = {
    TrackingBehavior = require(script.UI.TrackingBehavior),
    Panel = require(script.UI.Panel),
}

--[=[
    @within VRLib
    @prop VRCamera VRCamera
]=]
VRLib.VRCamera = require(script.VRCamera)

--[=[
    @within VRLib
    @prop LaserPointer LaserPointer
]=]
VRLib.LaserPointer = require(script.LaserPointer)

--[=[
    @within VRLib
    @function waitForUserCFrameAsync
    @param userCFrame UserCFrame
    @return Promise<void>
]=]
VRLib.waitForUserCFrameAsync = require(script.Util.waitForUserCFrameAsync)

return VRLib
