local VRLib = {
    Hand = require(script.Hand),
    Headset = require(script.Headset),
    Controllers = {
        Quest2 = require(script.Controllers.Quest2Controller)
    },
    ControllerAdornees = {
        Quest2 = require(script.ControllerAdornees.Quest2ControllerAdornee)
    },
}

return VRLib
