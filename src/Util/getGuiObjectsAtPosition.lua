local function filter(array: Array<any>, callback: (any, number, Array<any>) -> boolean): Array<any>
    local newArray = {}

    for i,v in ipairs(array) do
        if callback(v, i, array) then
            table.insert(newArray, v)
        end
    end

    return newArray
end

local function flat(array: Array<any>, depth: number): Array<any>
    depth = depth or 1

    local newArray = {}

    for _,value in ipairs(array) do
        if type(value) == "table" and depth > 0 then
            for _,v in ipairs(flat(value, depth - 1)) do
                table.insert(newArray, v)
            end
        else
            table.insert(newArray, value)
        end
    end

    return newArray
end

local function getVisibleGuiObjects(parent, guiObjects)
    guiObjects = guiObjects or {}

    for _,child in ipairs(parent:GetChildren()) do
        if child:IsA("GuiObject") and child.Visible then
            table.insert(guiObjects, child)
            getVisibleGuiObjects(child, guiObjects)
        elseif child:IsA("Folder") then
            getVisibleGuiObjects(child, guiObjects)
        end
    end

    return table.sort(guiObjects, function(a, b)
        return a.ZIndex < b.ZIndex
    end)
end

return function(parent, pos)
    return filter(flat(getVisibleGuiObjects(parent), math.huge), function(guiObject)
        local absPos = guiObject.AbsolutePosition
        local absSize = guiObject.AbsoluteSize
        return pos.X > absPos.X and pos.X < absPos.X + absSize.X and pos.Y > absPos.Y and pos.Y < absPos.Y + absSize.Y
    end)
end
