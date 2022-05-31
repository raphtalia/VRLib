return function(pos, cf)
    return CFrame.new(pos - cf.Position) * cf
end
