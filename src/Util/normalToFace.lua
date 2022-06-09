-- https://devforum.roblox.com/t/how-do-you-find-the-side-of-a-part-using-raycasting/655452/2

--[[**
    This function returns a vector representing the normal for the given
    face of the given part.

    @param part (BasePart) The part for which to find the normal of the given face.
    @param normalId (Enum.NormalId) The face to find the normal of.

    @returns (Vector3) The normal for the given face.
**--]]
function getNormalFromFace(part, normalId)
    return part.CFrame:VectorToWorldSpace(Vector3.FromNormalId(normalId))
end

--[[**
   This function returns the face that we hit on the given part based on
   an input normal. If the normal vector is not within a certain tolerance of
   any face normal on the part, we return nil.

    @param normalVector (Vector3) The normal vector we are comparing to the normals of the faces of the given part.
    @param part (BasePart) The part in question.

    @return (Enum.NormalId) The face we hit.
**--]]
return function(normalVector, part)
    local TOLERANCE_VALUE = 1 - 0.001
    for _,normalId in ipairs(Enum.NormalId:GetEnumItems()) do
        -- If the two vectors are almost parallel,
        if getNormalFromFace(part, normalId):Dot(normalVector) > TOLERANCE_VALUE then
            return normalId -- We found it!
        end
    end
    return nil -- None found within tolerance.
end
