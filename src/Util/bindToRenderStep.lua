local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

return function(priority, func)
    local uuid = HttpService:GenerateGUID(false)

    RunService:BindToRenderStep(uuid, priority, func)

    -- TODO: Update to behave more like a RBXScriptConnection
    return function()
        RunService:UnbindFromRenderStep(uuid)
    end
end
