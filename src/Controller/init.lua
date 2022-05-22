local RunService = game:GetService("RunService")
local HapticService = game:GetService("HapticService")
local UserInputService = game:GetService("UserInputService")

local Signal = require(script.Parent.Parent.Signal)
local Promise = require(script.Parent.Parent.Promise)
local t = require(script.Parent.Types).Controller

local Button = require(script.Button)
local Thumbstick = require(script.Thumbstick)
local Trigger = require(script.Trigger)

local fixSuperclass = require(script.Parent.Util.fixSuperclass)

local Constants = require(script.Parent.Constants)
local CONTROLLER_KEYCODES = Constants.CONTROLLER_KEYCODES
local HAND_VIBRATION_MOTOR_MAP = Constants.HAND_VIBRATION_MOTOR_MAP
local HAND_USER_CFRAME_MAP = Constants.HAND_USER_CFRAME_MAP

-- Doesn't filter out all controllers but better than assuming its just Gamepad1
local function getOculusControllerGamepadNum()
    local gamepadNums = UserInputService:GetConnectedGamepads()

    for _,gamepadNum in ipairs(gamepadNums) do
        -- Check for controllers with vibration motors due to GamepadSupports() returning false for all Oculus controller KeyCodes
        local valid = true

        for _,vibrationMotor in ipairs(HAND_VIBRATION_MOTOR_MAP) do
           if HapticService:IsMotorSupported(gamepadNum, vibrationMotor) then
               valid = false
               break
           end
        end

        if valid then
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
    elseif i == "Controls" then
        return rawget(self, "_controls")
    elseif i == "HandTriggerPosition" then
        return self.Controls.HandTrigger.Position
    elseif i == "IndexTriggerPosition" then
        return self.Controls.IndexTrigger.Position
    elseif i == "ThumbstickLocation" then
        return self.Controls.Thumbstick.Location
    elseif i == "VibrationValue" then
        return HapticService:GetMotor(self.GamepadNum, HAND_VIBRATION_MOTOR_MAP[self.Hand])
    elseif i == "Button1Down" then
        return self.Controls.Button1.Down
    elseif i == "Button1Up" then
        return self.Controls.Button1.Up
    elseif i == "Button2Down" then
        return self.Controls.Button2.Down
    elseif i == "Button2Up" then
        return self.Controls.Button2.Up
    elseif i == "HandTriggerUp" then
        return self.Controls.HandTrigger.Up
    elseif i == "HandTriggerDown" then
        return self.Controls.HandTrigger.Down
    elseif i == "HandTriggerFullyUp" then
        return self.Controls.HandTrigger.FullyUp
    elseif i == "HandTriggerFullyDown" then
        return self.Controls.HandTrigger.FullyDown
    elseif i == "IndexTriggerUp" then
        return self.Controls.IndexTrigger.Up
    elseif i == "IndexTriggerDown" then
        return self.Controls.IndexTrigger.Down
    elseif i == "IndexTriggerFullyUp" then
        return self.Controls.IndexTrigger.FullyUp
    elseif i == "IndexTriggerFullyDown" then
        return self.Controls.IndexTrigger.FullyDown
    elseif i == "ThumbstickUp" then
        return self.Controls.Thumbstick.Up
    elseif i == "ThumbstickDown" then
        return self.Controls.Thumbstick.Down
    elseif i == "ThumbstickReleased" then
        return self.Controls.Thumbstick.Released
    elseif i == "ThumbstickEdgeEntered" then
        return self.Controls.Thumbstick.EdgeEntered
    elseif i == "ThumbstickEdgeLeft" then
        return self.Controls.Thumbstick.EdgeLeft
    elseif i == "HandTriggerChanged" then
        return self.Controls.HandTrigger.Changed
    elseif i == "IndexTriggerChanged" then
        return self.Controls.IndexTrigger.Changed
    elseif i == "ThumbstickChanged" then
        return self.Controls.Thumbstick.Changed
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

function Controller:constructor(hand, gamepadNum)
    t.new(hand, gamepadNum)

    -- roblox-ts compatibility
    fixSuperclass(self, Controller, CONTROLLER_METATABLE)

    rawset(self, "_velocity", Vector3.new())
    rawset(self, "_hand", hand)
    rawset(self, "_gamepadNum", gamepadNum or getOculusControllerGamepadNum())
    rawset(self, "_controls", {
        HandTrigger = Trigger.new(),
        IndexTrigger = Trigger.new(),
        Thumbstick = Thumbstick.new(),
        Button1 = Button.new(),
        Button2 = Button.new(),
    })
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
                self.Controls.HandTrigger:UpdateTriggerAbsolute(1)
            elseif keyCode == keyCodeMap.IndexTrigger then
                self.Controls.IndexTrigger:UpdateTriggerAbsolute(1)
            elseif keyCode == keyCodeMap.ThumbstickButton then
                self.Controls.Thumbstick:UpdateButton(true)
            elseif keyCode == keyCodeMap.Button1 then
                self.Controls.Button1:UpdateButton(true)
            elseif keyCode == keyCodeMap.Button2 then
                self.Controls.Button2:UpdateButton(true)
            end
        end
    end))

    rawset(self, "InputEndedConnection", UserInputService.InputEnded:Connect(function(inputObj)
        if inputObj.UserInputType == self.GamepadNum then
            local keyCode = inputObj.KeyCode
            local keyCodeMap = CONTROLLER_KEYCODES[self.Hand]

            if keyCode == keyCodeMap.HandTrigger then
                self.Controls.HandTrigger:UpdateTriggerAbsolute(0)
            elseif keyCode == keyCodeMap.IndexTrigger then
                self.Controls.IndexTrigger:UpdateTriggerAbsolute(0)
            elseif keyCode == keyCodeMap.Thumbstick then
                self.Controls.Thumbstick:UpdateLocationAbsolute(Vector2.new())
            elseif keyCode == keyCodeMap.ThumbstickButton then
                self.Controls.Thumbstick:UpdateButton(false)
            elseif keyCode == keyCodeMap.Button1 then
                self.Controls.Button1:UpdateButton(false)
            elseif keyCode == keyCodeMap.Button2 then
                self.Controls.Button2:UpdateButton(false)
            end
        end
    end))

    rawset(self, "InputChangedConnection", UserInputService.InputChanged:Connect(function(inputObj)
        if inputObj.UserInputType == self.GamepadNum then
            local keyCode = inputObj.KeyCode
            local delta = inputObj.Delta
            local keyCodeMap = CONTROLLER_KEYCODES[self.Hand]

            if keyCode == keyCodeMap.HandTrigger then
                self.Controls.HandTrigger:UpdateTriggerDelta(delta.Z)
            elseif keyCode == keyCodeMap.IndexTrigger then
                self.Controls.IndexTrigger:UpdateTriggerDelta(delta.Z)
            elseif keyCode == keyCodeMap.Thumbstick then
                self.Controls.Thumbstick:UpdateLocationDelta(Vector2.new(delta.X, delta.Y))
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

function CONTROLLER_METATABLE:SetMotor(vibrationValue)
    local vibrationPromise = rawget(self, "VibrationPromise")
    if vibrationPromise then
        vibrationPromise:cancel()
        -- Wait for promise to finish cancelling
        task.delay(nil, function()
            HapticService:SetMotor(self.GamepadNum, HAND_VIBRATION_MOTOR_MAP[self.Hand], vibrationValue)
        end)
    else
        HapticService:SetMotor(self.GamepadNum, HAND_VIBRATION_MOTOR_MAP[self.Hand], vibrationValue)
    end
end

function CONTROLLER_METATABLE:Vibrate(vibrationValue, duration)
    duration = duration or 0.1

    local promise = Promise.new(function(resolve, _, onCancel)
        local vibrationStartTick = tick()
        self:SetMotor(vibrationValue)

        repeat
            task.wait()
        until onCancel() or tick() - vibrationStartTick >= duration

        HapticService:SetMotor(self.GamepadNum, HAND_VIBRATION_MOTOR_MAP[self.Hand], 0)
        rawset(self, "VibrationPromise", nil)
        resolve()
    end)


    rawset(self, "VibrationPromise", promise)
    return promise
end

-- roblox-ts compatability
Controller.default = Controller
return Controller
