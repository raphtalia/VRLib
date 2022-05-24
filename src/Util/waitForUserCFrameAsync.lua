local VRService = game:GetService("VRService")

local Promise = require(script.Parent.Parent.Parent.Promise)

return function(userCFrame)
    return Promise.new(function(resolve, reject)
        if not VRService.VREnabled then
            reject("VR is not enabled")
        end

        if not VRService:GetUserCFrameEnabled(userCFrame) then
            repeat
                task.wait()
            until VRService:GetUserCFrameEnabled(userCFrame)
        end

        resolve()
    end)
end
