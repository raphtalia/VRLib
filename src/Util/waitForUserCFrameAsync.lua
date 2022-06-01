local VRService = game:GetService("VRService")

local Promise = require(script.Parent.Parent.Parent.Promise)

return function(userCFrame)
    return Promise.new(function(resolve, reject)
        if not VRService.VREnabled then
            reject("VR is not enabled")
        end

        if VRService:GetUserCFrameEnabled(userCFrame) then
            resolve()
            return
        end

        local connection
        connection = VRService.UserCFrameEnabled:Connect(function(type, enabled)
            if enabled and type == userCFrame then
                connection:Disconnect()
                resolve()
            end
        end)
    end)
end
