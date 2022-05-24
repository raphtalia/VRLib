local StarterGui = game:GetService("StarterGui")

local Signal = require(script.Parent.Parent.Signal)
local t = require(script.Parent.Types).LaserPointer

local fixSuperclass = require(script.Parent.Util.fixSuperclass)
local bindToRenderStep = require(script.Parent.Util.bindToRenderStep)

local LaserPointer = {}
local LASER_POINTER_METATABLE = {}
function LASER_POINTER_METATABLE:__index(i)
    if i == "Controller" then
        return rawget(self, "_controller")
    elseif i == "RootPart" then
        return rawget(self, "_rootPart")
    elseif i == "Length" then
        return rawget(self, "_length")
    elseif i == "Visible" then
        return self.RootPart.Laser.Enabled
    elseif i == "RaycastParams" then
        return rawget(self, "_raycastParams")
    elseif i == "RaycastResult" then
        return rawget(self, "_raycastResult")
    elseif i == "Destroying" then
        return rawget(self, "_destroying")
    else
        return LASER_POINTER_METATABLE[i] or error(i.. " is not a valid member of LaserPointer", 2)
    end
end
function LASER_POINTER_METATABLE:__newindex(i, v)
    if i == "Controller" then
        t.Controller(v)
        rawset(self, "_controller", v)
    elseif i == "Length" then
        t.Length(v)
        rawset(self, "_length", v)
    elseif i == "Visible" then
        t.Visible(v)
        self.RootPart.Laser.Enabled = v
        self.RootPart.Cursor.Visible = v
    elseif i == "RaycastParams" then
        t.RaycastParams(v)
        rawset(self, "_raycastParams", v)
    else
        error(i.. " is not a valid member of LaserPointer or is unassignable", 2)
    end
end

function LaserPointer:constructor(controller)
    t.new(controller)

    -- roblox-ts compatibility
    fixSuperclass(self, LaserPointer, LASER_POINTER_METATABLE)

    StarterGui:SetCore("VRLaserPointerMode", "Disabled")

    local rootPart = Instance.new("Part")
    rootPart.Name = "LaserPointer"
    rootPart.Transparency = 1
    rootPart.Size = Vector3.new(1, 1, 1)
    rootPart.CanCollide = false
    rootPart.CanQuery = false
    rootPart.CanTouch = false
    rootPart.Anchored = false
    local attachment0 = Instance.new("Attachment")
    attachment0.CFrame = CFrame.new(0, 0, -0.1)
    attachment0.Parent = rootPart
    local attachment1 = Instance.new("Attachment")
    attachment1.Parent = rootPart
    local beam = Instance.new("Beam")
    beam.Name = "Laser"
    beam.Transparency = NumberSequence.new(0, 1)
    beam.Attachment0 = attachment0
    beam.Attachment1 = attachment1
    beam.FaceCamera = true
    beam.Segments = 1
    beam.Width0 = 0.01
    beam.Width1 = 0.01
    beam.Parent = rootPart
    local cursor = Instance.new("SphereHandleAdornment")
    cursor.Name = "Cursor"
    cursor.Color3 = Color3.new(1, 1, 1)
    cursor.Radius = 0.025
    cursor.Adornee = rootPart
    cursor.Parent = rootPart
    rootPart.Parent = workspace.CurrentCamera

    rawset(self, "_controller", controller)
    rawset(self, "_rootPart", rootPart)
    rawset(self, "_length", 8)
    rawset(self, "_visible", true)
    rawset(self, "_raycastParams", RaycastParams.new())
    rawset(self, "_destroying", Signal.new())

    rawset(self, "RenderStepDisconnect", bindToRenderStep(Enum.RenderPriority.Character.Value, function()
        local worldCF = self.Controller.WorldCFrame
        rootPart.CFrame = worldCF

        local raycastResult = workspace:Raycast(worldCF.Position, worldCF.LookVector * self.Length, self.RaycastParams)
        if self.Visible then
            if raycastResult then
                local cf = CFrame.new(0, 0, -raycastResult.Distance)
                attachment1.CFrame = cf
                cursor.Visible = true
                cursor.CFrame = cf
            else
                attachment1.CFrame = CFrame.new(0, 0, -self.Length)
                cursor.Visible = false
            end
        end

        rawset(self, "_raycastResult", raycastResult)
    end))
end

function LaserPointer.new(controller)
    local self = setmetatable({}, LASER_POINTER_METATABLE)
    LaserPointer.constructor(self, controller)

    return self
end

function LASER_POINTER_METATABLE:Destroy()
    self.Destroying:Fire()
    rawget(self, "RenderStepDisconnect")()
    self.RootPart:Destroy()
end

-- roblox-ts compatability
LaserPointer.default = LaserPointer
return LaserPointer
