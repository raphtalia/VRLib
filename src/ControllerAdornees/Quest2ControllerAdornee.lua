local Hand = require(script.Parent.Parent.Hand)
local Signal = require(script.Parent.Parent.Parent.Signal)
local t = require(script.Parent.Parent.Types).ControllerAdornee

local fixSuperclass = require(script.Parent.Parent.Util.fixSuperclass)
local bindToRenderStep = require(script.Parent.Parent.Util.bindToRenderStep)

local Constants = require(script.Parent.Parent.Constants)
local HAND_CONTROLLER_NAME_MAP = Constants.HAND_CONTROLLER_NAME_MAP

local ControllerAdornee = {}
local CONTROLLER_ADORNEE_METATABLE = {}
function CONTROLLER_ADORNEE_METATABLE:__index(i)
    if i == "Controller" then
        return rawget(self, "_controller")
    elseif i == "Model" then
        return rawget(self, "_model")
    elseif i == "RootPart" then
        return self.Model.PrimaryPart
    elseif i == "Destroying" then
        return rawget(self, "_destroying")
    else
        return CONTROLLER_ADORNEE_METATABLE[i] or error(i.. " is not a valid member of Controller", 2)
    end
end
function CONTROLLER_ADORNEE_METATABLE:__newindex(i, v)
    if i == "Controller" then
        t.Controller(v)
        rawset(self, "_hand", v)
    else
        error(i.. " is not a valid member of Controller or is unassignable", 2)
    end
end

function ControllerAdornee:constructor(controller, controllers)
    t.new(controller, controllers)

    -- roblox-ts compatibility
    fixSuperclass(self, ControllerAdornee, CONTROLLER_ADORNEE_METATABLE)

    local camera = workspace.CurrentCamera
    local model = controllers[HAND_CONTROLLER_NAME_MAP[controller.Hand]]:Clone()
    model.Parent = camera
    for _,bone in ipairs(model.PrimaryPart.Root:GetChildren()) do
        local cfValue = Instance.new("CFrameValue")
        cfValue.Value = bone.CFrame
        cfValue.Name = "OriginalCFrame"
        cfValue.Parent = bone
    end

    rawset(self, "_controller", controller)
    rawset(self, "_model", model)
    rawset(self, "_destroying", Signal.new())

    rawset(self, "RenderStepDisconnect", bindToRenderStep(Enum.RenderPriority.Character.Value, function()
        -- Moving the controllers to their virtual position relative to camera
        local adorneeModel = self.Model
        -- local oldCF = adorneeModel:GetPivot()
        local newCF = self.Controller.WorldCFrame

        -- if (newCF.Position - oldCF.Position).Magnitude < 1 then
        --     -- Reduces jitter
        --     newCF = oldCF:Lerp(newCF, 0.2)
        -- end

        adorneeModel:PivotTo(newCF)

        -- Animating the buttons
        local con = self.Controller
        local root = self.RootPart.Root
        local hand = con.Hand

        root.Thumbstick.CFrame = root.Thumbstick.OriginalCFrame.Value * CFrame.new(0, if con:IsThumbstickDown() then -0.005 else 0, 0) * CFrame.Angles(math.rad(con.ThumbstickLocation.Y * 20), 0, math.rad(con.ThumbstickLocation.X * 20))
        root.HandTrigger.CFrame = root.HandTrigger.OriginalCFrame.Value * CFrame.new(0, -con.GripTriggerPosition * 0.015, 0)
        root.IndexTrigger.CFrame = root.IndexTrigger.OriginalCFrame.Value * CFrame.Angles(math.rad(con.IndexTriggerPosition * 20), 0, 0)

        if hand == Hand.Left then
            root.ButtonY.CFrame = root.ButtonY.OriginalCFrame.Value * CFrame.new(0, if con:IsButton1Down() then -0.005 else 0, 0)
            root.ButtonX.CFrame = root.ButtonX.OriginalCFrame.Value * CFrame.new(0, if con:IsButton2Down() then -0.005 else 0, 0)
        elseif hand == Hand.Right then
            root.ButtonB.CFrame = root.ButtonB.OriginalCFrame.Value * CFrame.new(0, if con:IsButton1Down() then -0.005 else 0, 0)
            root.ButtonA.CFrame = root.ButtonA.OriginalCFrame.Value * CFrame.new(0, if con:IsButton2Down() then -0.005 else 0, 0)
        end
    end))
end

function ControllerAdornee.new(controller, controllers)
    -- Rojo currently doesn't support syncing in meshes so we pass in the controllers as an argument
    local self = setmetatable({}, CONTROLLER_ADORNEE_METATABLE)
    ControllerAdornee.constructor(self, controller, controllers)

    return self
end

function CONTROLLER_ADORNEE_METATABLE:Destroy()
    self.Destroying:Fire()
    rawget(self, "RenderStepDisconnect")()
end

-- roblox-ts compatability
ControllerAdornee.default = ControllerAdornee
return ControllerAdornee
