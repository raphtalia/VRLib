local UserInputService = game:GetService("UserInputService")
local HapticService = game:GetService("HapticService")
local VRService = game:GetService("VRService")

local Signal = require(script.Parent.Parent.Parent.Signal)
local Promise = require(script.Parent.Parent.Parent.Promise)
local t = require(script.Parent.Parent.Types).Controller

local Button = require(script.Parent.Parent.Inputs.Button)
local Thumbstick = require(script.Parent.Parent.Inputs.Thumbstick)
local Trigger = require(script.Parent.Parent.Inputs.Trigger)

local fixSuperclass = require(script.Parent.Parent.Util.fixSuperclass)
local bindToRenderStep = require(script.Parent.Parent.Util.bindToRenderStep)

local Constants = require(script.Parent.Parent.Constants)
local CONTROLLER_KEYCODES = Constants.CONTROLLER_KEYCODES
local HAND_VIBRATION_MOTOR_MAP = Constants.HAND_VIBRATION_MOTOR_MAP
local HAND_USER_CFRAME_MAP = Constants.HAND_USER_CFRAME_MAP
local HAND_VR_TOUCHPAD_MAP = Constants.HAND_VR_TOUCHPAD_MAP

-- Doesn't filter out all controllers but better than assuming its just Gamepad1
local function getOculusControllerGamepadNum()
    local gamepadNums = UserInputService:GetConnectedGamepads()

    for _,gamepadNum in ipairs(gamepadNums) do
        --[[
            Check for controllers with vibration motors due to GamepadSupports()
            returning false for all Oculus controller KeyCodes
        ]]
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

    -- Return Gamepad1 if we couldn't find a controller
    return Enum.UserInputType.Gamepad1
end

--[=[
    @class Quest2Controller
]=]
local Quest2Controller = {}
local QUEST2_CONTROLLER_METATABLE = {}
function QUEST2_CONTROLLER_METATABLE:__index(i)
    if i == "UserCFrame" then
        --[=[
            @within Quest2Controller
            @readonly
            @prop UserCFrame CFrame
            The real-life position and rotation of the controller.
        ]=]
        return UserInputService:GetUserCFrame(HAND_USER_CFRAME_MAP[self.Hand])
    elseif i == "UserPosition" then
        --[=[
            @within Quest2Controller
            @readonly
            @prop UserPosition Vector3
            The real-life position of the controller.
        ]=]
        return self.UserCFrame.Position
    elseif i == "WorldCFrame" then
        --[=[
            @within Quest2Controller
            @readonly
            @prop WorldCFrame CFrame
            The in-game rotation and position of the controller.
        ]=]
        local camera = workspace.CurrentCamera

        if camera.HeadLocked then
            return camera.CFrame * self.UserCFrame
        else
            return camera:GetRenderCFrame()
                * UserInputService:GetUserCFrame(Enum.UserCFrame.Head):Inverse()
                * self.UserCFrame
        end
    elseif i == "WorldPosition" then
        --[=[
            @within Quest2Controller
            @readonly
            @prop WorldPosition Vector3
            The in-game position of the controller.
        ]=]
        return self.WorldCFrame.Position
    elseif i == "Velocity" then
        --[=[
            @within Quest2Controller
            @readonly
            @prop Velocity Vector3
            Controller's change in position over time.
        ]=]
        return rawget(self, "_velocity")
    elseif i == "Hand" then
        --[=[
            @within Quest2Controller
            @readonly
            @prop Hand Hand
            The hand the controller is tracking.
        ]=]
        return rawget(self, "_hand")
    elseif i == "GamepadNum" then
        --[=[
            @within Quest2Controller
            @prop GamepadNum UserInputType
            The ID of the gamepad the controller is identified as.
        ]=]
        return rawget(self, "_gamepadNum")
    elseif i == "TouchpadMode" then
        --[=[
            @within Quest2Controller
            @prop TouchpadMode VRTouchpadMode
            The mode of the controller's touchpad.
        ]=]
        return VRService:GetTouchpadMode(HAND_VR_TOUCHPAD_MAP[self.Hand])
    elseif i == "Inputs" then
        --[=[
            @within Quest2Controller
            @interface Inputs
            @field GripTrigger Trigger
            @field IndexTrigger Trigger
            @field Thumbstick Thumbstick
            @field Button1 Button
            @field Button2 Button
            Table of input objects tied to the controller.
        ]=]
        return rawget(self, "_inputs")
    elseif i == "VibrationValue" then
        --[=[
            @within Quest2Controller
            @readonly
            @prop VibrationValue number
            The vibration intensity of the controller on a scale of 0 to 1.
        ]=]
        return HapticService:GetMotor(self.GamepadNum, HAND_VIBRATION_MOTOR_MAP[self.Hand])
    elseif i == "Destroying" then
        --[=[
            @within Quest2Controller
            @readonly
            @prop Destroying Signal<>
            Fires while `Destroy()` is executing.
        ]=]
        return rawget(self, "_destroying")
    else
        return QUEST2_CONTROLLER_METATABLE[i] or error(i.. " is not a valid member of Quest2Controller", 2)
    end
end
function QUEST2_CONTROLLER_METATABLE:__newindex(i, v)
    if i == "GamepadNum" then
        t.GamepadNum(v)
        rawset(self, "_gamepadNum", v)
    elseif i == "TouchpadMode" then
        t.TouchpadMode(v)
        VRService:SetTouchpadMode(HAND_VR_TOUCHPAD_MAP[self.Hand], v)
    else
        error(i.. " is not a valid member of Quest2Controller or is unassignable", 2)
    end
end

function Quest2Controller:constructor(hand, gamepadNum)
    t.new(hand, gamepadNum)

    if not VRService:GetUserCFrameEnabled(HAND_USER_CFRAME_MAP[hand]) then
        error(hand.Name.. " Controller not detected", 2)
    end

    -- roblox-ts compatibility
    fixSuperclass(self, Quest2Controller, QUEST2_CONTROLLER_METATABLE)

    rawset(self, "_velocity", Vector3.new())
    rawset(self, "_hand", hand)
    rawset(self, "_gamepadNum", gamepadNum or getOculusControllerGamepadNum())
    rawset(self, "_inputs", table.freeze({
        GripTrigger = Trigger.new(0.9),
        IndexTrigger = Trigger.new(0.9),
        Thumbstick = Thumbstick.new(0.975),
        Button1 = Button.new(),
        Button2 = Button.new(),
    }))
    rawset(self, "_destroying", Signal.new())

    local lastUserPos = self.UserPosition
    rawset(self, "RenderStepDisconnect", bindToRenderStep(Enum.RenderPriority.Input.Value, function(dt)
        local userPos = self.UserPosition
        rawset(self, "_velocity", (userPos - lastUserPos) / dt)
        lastUserPos = userPos
    end))

    rawset(self, "InputBeganConnection", UserInputService.InputBegan:Connect(function(inputObj)
        if inputObj.UserInputType == self.GamepadNum then
            local keyCode = inputObj.KeyCode
            local keyCodeMap = CONTROLLER_KEYCODES[self.Hand]

            if keyCode == keyCodeMap.GripTrigger then
                self.Inputs.GripTrigger:UpdateTriggerAbsolute(1)
            elseif keyCode == keyCodeMap.IndexTrigger then
                self.Inputs.IndexTrigger:UpdateTriggerAbsolute(1)
            elseif keyCode == keyCodeMap.ThumbstickButton then
                self.Inputs.Thumbstick:UpdateButton(true)
            elseif keyCode == keyCodeMap.Button1 then
                self.Inputs.Button1:UpdateButton(true)
            elseif keyCode == keyCodeMap.Button2 then
                self.Inputs.Button2:UpdateButton(true)
            end
        end
    end))

    rawset(self, "InputEndedConnection", UserInputService.InputEnded:Connect(function(inputObj)
        if inputObj.UserInputType == self.GamepadNum then
            local keyCode = inputObj.KeyCode
            local keyCodeMap = CONTROLLER_KEYCODES[self.Hand]

            if keyCode == keyCodeMap.GripTrigger then
                self.Inputs.GripTrigger:UpdateTriggerAbsolute(0)
            elseif keyCode == keyCodeMap.IndexTrigger then
                self.Inputs.IndexTrigger:UpdateTriggerAbsolute(0)
            elseif keyCode == keyCodeMap.Thumbstick then
                self.Inputs.Thumbstick:UpdateLocationAbsolute(Vector2.new())
            elseif keyCode == keyCodeMap.ThumbstickButton then
                self.Inputs.Thumbstick:UpdateButton(false)
            elseif keyCode == keyCodeMap.Button1 then
                self.Inputs.Button1:UpdateButton(false)
            elseif keyCode == keyCodeMap.Button2 then
                self.Inputs.Button2:UpdateButton(false)
            end
        end
    end))

    rawset(self, "InputChangedConnection", UserInputService.InputChanged:Connect(function(inputObj)
        if inputObj.UserInputType == self.GamepadNum then
            local keyCode = inputObj.KeyCode
            local delta = inputObj.Delta
            local keyCodeMap = CONTROLLER_KEYCODES[self.Hand]

            if keyCode == keyCodeMap.GripTrigger then
                self.Inputs.GripTrigger:UpdateTriggerDelta(delta.Z)
            elseif keyCode == keyCodeMap.IndexTrigger then
                self.Inputs.IndexTrigger:UpdateTriggerDelta(delta.Z)
            elseif keyCode == keyCodeMap.Thumbstick then
                self.Inputs.Thumbstick:UpdateLocationDelta(Vector2.new(delta.X, delta.Y))
            end
        end
    end))
end

--[=[
    @within Quest2Controller
    @param hand Hand
    @param gamepadNum UserInputType?
    @return Quest2Controller
]=]
function Quest2Controller.new(hand, gamepadNum)
    local self = setmetatable({}, QUEST2_CONTROLLER_METATABLE)
    Quest2Controller.constructor(self, hand, gamepadNum)

    return self
end

--[=[
    @within Quest2Controller
]=]
function QUEST2_CONTROLLER_METATABLE:Destroy()
    self.Destroying:Fire()
    rawget(self, "RenderStepDisconnect")()
    rawget(self, "InputBeganConnection"):Disconnect()
    rawget(self, "InputEndedConnection"):Disconnect()
    rawget(self, "InputChangedConnection"):Disconnect()
end

--[=[
    @within Quest2Controller
    @param vibrationValue number
    Updates the controller's vibration intensity.
]=]
function QUEST2_CONTROLLER_METATABLE:SetMotor(vibrationValue)
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

--[=[
    @within Quest2Controller
    @param vibrationValue number
    @param duration number
    @return Promise<void>
    Vibrates the controller for a limited amount of time, can be cancelled from
    the returned promise.
]=]
function QUEST2_CONTROLLER_METATABLE:Vibrate(vibrationValue, duration)
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
Quest2Controller.default = Quest2Controller
return Quest2Controller
