local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Signal = require(script.Parent.Parent.Signal)
local t = require(script.Parent.Types).Controller

local fixSuperclass = require(script.Parent.Util.fixSuperclass)

local Constants = require(script.Parent.Constants)
local GAMEPAD_KEYCODES = Constants.GAMEPAD_KEYCODES
local GAMEPAD_KEYCODES_MAP = Constants.GAMEPAD_KEYCODES_MAP
local HAND_USER_CFRAME_MAP = Constants.HAND_USER_CFRAME_MAP

-- Doesn't filter out all controllers but better than assuming its just Gamepad1
local function getOculusControllerGamepadNum()
    local gamepadNums = UserInputService:GetConnectedGamepads()

    for _,gamepadNum in ipairs(gamepadNums) do
        for _,keycode in ipairs(GAMEPAD_KEYCODES) do
            if not UserInputService:GamepadSupports(gamepadNum, keycode) then
                break
            end

            return gamepadNum
        end
    end
end

local Controller = {}
local CONTROLLER_METATABLE = {}
function CONTROLLER_METATABLE:__index(i)
    if i == "CFrame" then
        return UserInputService:GetUserCFrame(HAND_USER_CFRAME_MAP[self.Hand])
    elseif i == "Position" then
        return self.CFrame.Position
    elseif i == "Velocity" then
        return rawget(self, "_velocity")
    elseif i == "Hand" then
        return rawget(self, "_hand")
    elseif i == "GamepadNum" then
        return rawget(self, "_gamepadNum")
    elseif i == "HandTriggerPosition" then
        return rawget(self, "_handTriggerPosition")
    elseif i == "IndexTriggerPosition" then
        return rawget(self, "_indexTriggerPosition")
    elseif i == "ThumbstickLocation" then
        return rawget(self, "_thumbstickLocation")
    elseif i == "ButtonDown" then
        return rawget(self, "_buttonDown")
    elseif i == "ButtonUp" then
        return rawget(self, "_buttonUp")
    elseif i == "HandTriggerChanged" then
        return rawget(self, "_handTriggerChanged")
    elseif i == "IndexTriggerChanged" then
        return rawget(self, "_indexTriggerChanged")
    elseif i == "ThumbstickChanged" then
        return rawget(self, "_thumbstickChanged")
    elseif i == "Destroying" then
        return rawget(self, "_destroying")
    else
        return CONTROLLER_METATABLE[i] or error(i.. " is not a valid member of Controller", 2)
    end
end
function CONTROLLER_METATABLE:__newindex(i, v)
    if i == "GamepadNum" then
        t.GamepadNum(v)
        rawset(self, "_gamepadNum", v)
    else
        error(i.. " is not a valid member of Controller or is unassignable", 2)
    end
end

function Controller:constructor(hand)
    t.new(hand)

    -- roblox-ts compatibility
    fixSuperclass(self, Controller, CONTROLLER_METATABLE)

    rawset(self, "_velocity", Vector3.new())
    rawset(self, "_hand", hand)
    rawset(self, "_gamepadNum", Enum.UserInputType.Gamepad1)
    rawset(self, "_handTriggerPosition", 0)
    rawset(self, "_indexTriggerPosition", 0)
    rawset(self, "_thumbstickLocation", Vector2.new(0, 0))
    rawset(self, "_buttonDown", Signal.new())
    rawset(self, "_buttonUp", Signal.new())
    rawset(self, "_handTriggerChanged", Signal.new())
    rawset(self, "_indexTriggerChanged", Signal.new())
    rawset(self, "_thumbstickChanged", Signal.new())
    rawset(self, "_destroying", Signal.new())

    local lastUserPos = self.Position
    rawset(self, "HeartbeatConnection", RunService.Heartbeat:Connect(function(dt)
        local userPos = self.Position
        rawset(self, "_velocity", (userPos - lastUserPos) / dt)
        lastUserPos = userPos
    end))

    rawset(self, "InputBeganConnection", UserInputService.InputBegan:Connect(function(inputObj)
        if inputObj.UserInputType == self.GamepadNum then
            local keyCode = inputObj.KeyCode

            if table.find(GAMEPAD_KEYCODES[self.Hand], keyCode) then
                self._buttonDown:Fire(keyCode)
            end
        end
    end))

    rawset(self, "InputEndedConnection", UserInputService.InputEnded:Connect(function(inputObj)
        if inputObj.UserInputType == self.GamepadNum then
            local keyCode = inputObj.KeyCode

            if table.find(GAMEPAD_KEYCODES[self.Hand], keyCode) then
                self._buttonUp:Fire(keyCode)
            end
        end
    end))

    rawset(self, "InputChangedConnection", UserInputService.InputChanged:Connect(function(inputObj)
        if inputObj.UserInputType == self.GamepadNum then
            local keyCode = inputObj.KeyCode
            local delta = inputObj.Delta

            if keyCode == GAMEPAD_KEYCODES_MAP[self.Hand].HandTrigger then
                rawset(self, "_handTriggerPosition", rawget(self, "_handTriggerPosition") + delta.Z)
                self.HandTriggerChanged:Fire(self.HandTriggerPosition, delta.Z)
            elseif keyCode == GAMEPAD_KEYCODES_MAP[self.Hand].IndexTrigger then
                rawset(self, "_indexTriggerPosition", rawget(self, "_indexTriggerPosition") + delta.Z)
                self.IndexTriggerChanged:Fire(self.IndexTriggerPosition, delta.Z)
            elseif keyCode == GAMEPAD_KEYCODES_MAP[self.Hand].Thumbstick then
                local vec2Delta = Vector2.new(delta.X, delta.Y)
                rawset(self, "_thumbstickLocation", rawget(self, "_thumbstickLocation") + vec2Delta)
                self.ThumbstickChanged:Fire(self.ThumbstickLocation, vec2Delta)
            end
        end
    end))
end

function Controller.new(hand)
    local self = setmetatable({}, CONTROLLER_METATABLE)
    Controller.constructor(self, hand)

    return self
end

function CONTROLLER_METATABLE:Destroy()
    self.Destroying:Fire()
    rawget(self, "HeartbeatConnection"):Disconnect()
    rawget(self, "InputBeganConnection"):Disconnect()
    rawget(self, "InputEndedConnection"):Disconnect()
    rawget(self, "InputChangedConnection"):Disconnect()
end

function CONTROLLER_METATABLE:IsButtonDown(gamepadKeyCode)
    return UserInputService:IsGamepadButtonDown(self.GamepadNum, gamepadKeyCode)
end

-- roblox-ts compatability
Controller.default = Controller
return Controller
