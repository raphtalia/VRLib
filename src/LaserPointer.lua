local StarterGui = game:GetService("StarterGui")
local CollectionService = game:GetService("CollectionService")

local Signal = require(script.Parent.Parent.Signal)
local t = require(script.Parent.Types).LaserPointer

local fixSuperclass = require(script.Parent.Util.fixSuperclass)
local bindToRenderStep = require(script.Parent.Util.bindToRenderStep)
local normalToFace = require(script.Parent.Util.normalToFace)

local Constants = require(script.Parent.Constants)
local PANEL_TAG = Constants.Tags.Panel

local function isPanel(raycastResult)
    return CollectionService:HasTag(raycastResult.Instance, PANEL_TAG)
        and normalToFace(raycastResult.Normal, raycastResult.Instance) == Enum.NormalId.Back
end

--[=[
    @class LaserPointer
    A substitute for Roblox's built-in laser pointer.
]=]
local LaserPointer = {}
local LASER_POINTER_METATABLE = {}
function LASER_POINTER_METATABLE:__index(i)
    if i == "Controller" then
        --[=[
            @within LaserPointer
            @prop Controller Quest2Controller
            Reference to the controller that the laser pointer is tracking.
        ]=]
        return rawget(self, "_controller")
    elseif i == "RootPart" then
        --[=[
            @within LaserPointer
            @readonly
            @prop RootPart BasePart
            The container for the effects of the laser pointer.
        ]=]
        return rawget(self, "_rootPart")
    elseif i == "Panel" then
        --[=[
            @within LaserPointer
            @readonly
            @prop Panel Panel
            The panel that the laser pointer is currently pointing at.
        ]=]
        return rawget(self, "_panel")
    elseif i == "Length" then
        --[=[
            @within LaserPointer
            @prop Length number
            The length of the laser pointer.
        ]=]
        return rawget(self, "_length")
    elseif i == "Visible" then
        --[=[
            @within LaserPointer
            @prop Visible boolean
            Whether the laser pointer is visible.
        ]=]
        return self.RootPart.Laser.Enabled
    elseif i == "PanelInteraction" then
        --[=[
            @within LaserPointer
            @prop PanelInteraction boolean
            Whether the laser pointer can interact with panels.
        ]=]
        return rawget(self, "_panelInteraction")
    elseif i == "RaycastParams" then
        --[=[
            @within LaserPointer
            @prop RaycastParams RaycastParams
            The parameters used to raycast with.
        ]=]
        return rawget(self, "_raycastParams")
    elseif i == "RaycastResult" then
        --[=[
            @within LaserPointer
            @readonly
            @prop RaycastResult RaycastResult
            The result of the last raycast.
        ]=]
        return rawget(self, "_raycastResult")
    elseif i == "Destroying" then
        --[=[
            @within LaserPointer
            @readonly
            @prop Destroying Signal<>
            Fires while `Destroy()` is executing.
        ]=]
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
    elseif i == "PanelInteraction" then
        t.PanelInteraction(v)
        rawset(self, "_panelInteraction", v)
        if not v then
            rawset(self, "_panel", nil)
        end
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
    rootPart.Size = Vector3.one
    rootPart.CanCollide = false
    rootPart.CanQuery = false
    rootPart.CanTouch = false
    rootPart.Anchored = true
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
    -- rawset(self, "_panel", nil)
    rawset(self, "_length", 8)
    rawset(self, "_panelInteraction", true)
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

        if self.PanelInteraction then
            if raycastResult then
                if isPanel(raycastResult) then
                    if self.Panel == raycastResult.Instance then
                        self.Panel.MouseMoved:Fire(raycastResult)
                    else
                        if self.Panel then
                            self.Panel.MouseLeave:Fire()
                        end

                        rawset(self, "_panel", raycastResult.Instance)
                        self.Panel.MouseEnter:Fire(raycastResult)
                    end
                end
            elseif self.Panel then
                self.Panel.MouseLeave:Fire()
                rawset(self, "_panel", nil)
            end
        end

        rawset(self, "_raycastResult", raycastResult)
    end))
end

--[=[
    @within LaserPointer
    @param controller Quest2Controller
    @return LaserPointer
]=]
function LaserPointer.new(controller)
    local self = setmetatable({}, LASER_POINTER_METATABLE)
    LaserPointer.constructor(self, controller)

    return self
end

--[=[
    @within LaserPointer
]=]
function LASER_POINTER_METATABLE:Destroy()
    self.Destroying:Fire()
    rawget(self, "RenderStepDisconnect")()
    self.RootPart:Destroy()
    if self.Panel then
        self.Panel.MouseLeave:Fire()
    end
end

-- roblox-ts compatability
LaserPointer.default = LaserPointer
return LaserPointer
