local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Signal = require(script.Parent.Parent.Signal)
local t = require(script.Parent.Types).Controller

local fixSuperclass = require(script.Parent.Util.fixSuperclass)

local Constants = require(script.Parent.Constants)
local GAMEPAD_KEYCODES = Constants.GAMEPAD_KEYCODES
local CONTROLLER_KEYCODES = Constants.CONTROLLER_KEYCODES
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
    elseif i == "Button1Down" then
        return rawget(self, "_button1Down")
    elseif i == "Button1Up" then
        return rawget(self, "_button1Up")
    elseif i == "Button2Down" then
        return rawget(self, "_button2Down")
    elseif i == "Button2Up" then
        return rawget(self, "_button2Up")
    elseif i == "HandTriggerUp" then
        return rawget(self, "_handTriggerUp")
    elseif i == "HandTriggerDown" then
        return rawget(self, "_handTriggerDown")
    elseif i == "IndexTriggerUp" then
        return rawget(self, "_indexTriggerUp")
    elseif i == "IndexTriggerDown" then
        return rawget(self, "_indexTriggerDown")
    elseif i == "ThumbstickUp" then
        return rawget(self, "_thumbstickUp")
    elseif i == "ThumbstickDown" then
        return rawget(self, "_thumbstickDown")
    elseif i == "ThumbstickReleased" then
        return rawget(self, "_thumbstickReleased")
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
    rawset(self, "_button1Down", Signal.new())
    rawset(self, "_button1Up", Signal.new())
    rawset(self, "_button2Down", Signal.new())
    rawset(self, "_button2Up", Signal.new())
    rawset(self, "_handTriggerUp", Signal.new())
    rawset(self, "_handTriggerDown", Signal.new())
    rawset(self, "_indexTriggerUp", Signal.new())
    rawset(self, "_indexTriggerDown", Signal.new())
    rawset(self, "_thumbstickUp", Signal.new())
    rawset(self, "_thumbstickDown", Signal.new())
    rawset(self, "_thumbstickReleased", Signal.new())
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
            local keyCodeMap = CONTROLLER_KEYCODES[self.Hand]

            if keyCode == keyCodeMap.HandTrigger then
                self.HandTriggerDown:Fire()
                rawset(self, "_handTriggerPosition", 1)
            elseif keyCode == keyCodeMap.IndexTrigger then
                self.IndexTriggerDown:Fire()
                rawset(self, "_indexTriggerPosition", 1)
            elseif keyCode == keyCodeMap.ThumbstickButton then
                self.ThumbstickDown:Fire()
            elseif keyCode == keyCodeMap.Button1 then
                self.Button1Down:Fire()
            elseif keyCode == keyCodeMap.Button2 then
                self.Button2Down:Fire()
            end
        end
    end))

    rawset(self, "InputEndedConnection", UserInputService.InputEnded:Connect(function(inputObj)
        if inputObj.UserInputType == self.GamepadNum then
            local keyCode = inputObj.KeyCode
            local keyCodeMap = CONTROLLER_KEYCODES[self.Hand]

            if keyCode == keyCodeMap.HandTrigger then
                self.HandTriggerDown:Fire()
                rawset(self, "_handTriggerPosition", 0)
            elseif keyCode == keyCodeMap.IndexTrigger then
                self.IndexTriggerDown:Fire()
                rawset(self, "_indexTriggerPosition", 0)
            elseif keyCode == keyCodeMap.Thumbstick then
                self.ThumbstickReleased:Fire()
                rawset(self, "_thumbstickLocation", Vector2.new(0, 0))
            elseif keyCode == keyCodeMap.ThumbstickButton then
                self.ThumbstickUp:Fire()
            elseif keyCode == keyCodeMap.Button1 then
                self.Button1Down:Fire()
            elseif keyCode == keyCodeMap.Button2 then
                self.Button2Down:Fire()
            end
        end
    end))

    rawset(self, "InputChangedConnection", UserInputService.InputChanged:Connect(function(inputObj)
        if inputObj.UserInputType == self.GamepadNum then
            local keyCode = inputObj.KeyCode
            local delta = inputObj.Delta
            local keyCodeMap = CONTROLLER_KEYCODES[self.Hand]

            if keyCode == keyCodeMap.HandTrigger then
                rawset(self, "_handTriggerPosition", rawget(self, "_handTriggerPosition") + delta.Z)
                self.HandTriggerChanged:Fire(self.HandTriggerPosition, delta.Z)
            elseif keyCode == keyCodeMap.IndexTrigger then
                rawset(self, "_indexTriggerPosition", rawget(self, "_indexTriggerPosition") + delta.Z)
                self.IndexTriggerChanged:Fire(self.IndexTriggerPosition, delta.Z)
            elseif keyCode == keyCodeMap.Thumbstick then
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

function CONTROLLER_METATABLE:IsThumbstickDown()
    return UserInputService:IsGamepadButtonDown(self.GamepadNum, CONTROLLER_KEYCODES[self.Hand].ThumbstickButton)
end

function CONTROLLER_METATABLE:IsButton1Down()
    return UserInputService:IsGamepadButtonDown(self.GamepadNum, CONTROLLER_KEYCODES[self.Hand].Button1)
end

function CONTROLLER_METATABLE:IsButton2Down()
    return UserInputService:IsGamepadButtonDown(self.GamepadNum, CONTROLLER_KEYCODES[self.Hand].Button2)
end

-- roblox-ts compatability
Controller.default = Controller
return Controller
