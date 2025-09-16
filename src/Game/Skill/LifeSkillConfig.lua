--参考 https://iwiki.woa.com/pages/viewpage.action?pageId=1162475628
local LifeSkillConfig = {
    CastSkillCallback = {}
}

function LifeSkillConfig.RegisterCastSkillCallback(Index, Listener, Callback)
    LifeSkillConfig.CastSkillCallback[Index] = {Listener = Listener, Callback = Callback}
end

function LifeSkillConfig.UnRegisterCastSkillCallback(Index)
    if Index then
        LifeSkillConfig.CastSkillCallback[Index] = nil
    end
end

function LifeSkillConfig.InvokeCastSkillCallback(Index, Params)
    if Index == nil then return false end
    local CastSkillCallback = LifeSkillConfig.CastSkillCallback[Index]
    if CastSkillCallback ~= nil then
        if CastSkillCallback.Listener == nil then
            return CastSkillCallback.Callback(Params)
        else
            return CastSkillCallback.Callback(CastSkillCallback.Listener, Params)
        end
    end
end

function LifeSkillConfig.GetAllRegisterProf()
    local Ret = {}
    for key, _ in pairs(LifeSkillConfig.CastSkillCallback) do
        table.insert(Ret, key)
    end
    return Ret
end

return LifeSkillConfig