local ActorUtil = require("Utils/ActorUtil")

local UE = _G.UE
local LuaFuncInSeq = {}

---@param Params TArray<FString>
function LuaFuncInSeq.NpcVisible(Params)
    local ParamNum = Params:Length()
    if ParamNum >= 2 then
        local ResID = tonumber(Params:Get(1)) or 0
        local bVisible = (Params:Get(2) == "true")
        local NpcActor = ActorUtil.GetActorByResID(ResID)
        if NpcActor then
            print("Setting visibility of NPC " .. ResID .. " to " .. tostring(bVisible))
            NpcActor:SetActorHiddenInGame(not bVisible)
        end
    end
end

function LuaFuncInSeq.PlayBGM(Params)
    local ParamNum = Params:Length()
    if ParamNum >= 1 then
        local BgmID = tonumber(Params:Get(1)) or 0
        if BgmID == 0 then
            UE.UAudioMgr.Get():StopBGMAtChannel(UE.EBGMChannel.Cutscene)
        else
            UE.UAudioMgr.Get():PlayBGM(BgmID, UE.EBGMChannel.Cutscene)
        end
    end
end

function LuaFuncInSeq.ChangeBGMVolume(Params)
    local ParamNum = Params:Length()
    if ParamNum >= 1 then
        local VolumeRate = tonumber(Params:Get(1)) or 1 -- [0,1]
        local FadeTime = 1
        if ParamNum >= 2 then
            local FadeBaseSpeed = tonumber(Params:Get(2)) or 30 -- [0,1800]
            FadeTime = FadeTime * FadeBaseSpeed / 30
        end
        UE.UBGMMgr.Get():ChangeBGMVolume(VolumeRate, FadeTime)
    end
end

return LuaFuncInSeq