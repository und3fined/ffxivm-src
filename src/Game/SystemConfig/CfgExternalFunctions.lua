
local EffectUtil = require("Utils/EffectUtil")
local CommonDefine = require("Define/CommonDefine")
local SaveKey = require("Define/SaveKey")
local CfgExternalFunctions = {

}

function CfgExternalFunctions.FrameNumber(_, Index, Name)
    FLOG_INFO("[SystemConfig]FrameNumber")
end

function CfgExternalFunctions.RenderingAccuracy(_, Index, Name)
    FLOG_INFO("[SystemConfig]RenderingAccuracy")
end

function CfgExternalFunctions.ScreenPeopleNumber(Value)
    FLOG_INFO("[SystemConfig]ScreenPeopleNumber")
end

function CfgExternalFunctions.AntiAliasing(Value)
    FLOG_INFO("[SystemConfig]AntiAliasing")
end

function CfgExternalFunctions.QualityLevel(_, Index, Name)
    FLOG_INFO("[SystemConfig]QualityLevel, Index：" .. Index .. "  Name：".. tostring(Name))

    local GameplayStaticsUtil = require("Utils/GameplayStaticsUtil")
    local PlayerController = GameplayStaticsUtil.GetPlayerController()
    local Text = string.format("SCALABILITY %d", Index)
    PlayerController:ConsoleCommand(Text, true)

    EffectUtil.SetQualityLevelFXLOD(Index)
    EffectUtil.SetQualityLevelFXMaxCount(Index)
    local LODOffset = CommonDefine.QualityLevelActorLOD[Index]
    _G.UE.UActorManager:Get():SetActorLODOffsetConfig(LODOffset.Major, LODOffset.Player, LODOffset.Boss, LODOffset.Monster, LODOffset.NPC)
end

function CfgExternalFunctions.CombatFX(_, Index, _, CfgData)
    local CfgSaveKey = CfgData.SaveKey
    local Type = CfgSaveKey - SaveKey.CombatFXSelf
    EffectUtil.SetCombatFXLOD(Index, Type)
end

function CfgExternalFunctions.ForceFeedbackSwitch(Value)
    CommonDefine.bEnableForceFeedback = Value
end

function CfgExternalFunctions.SetSpeedConst(_, Index, Name)
    if Index == 0 then
        _G.UE.AMajorController:OpenSpeedConst()
	else
        _G.UE.AMajorController:CloseSpeedConst()
	end
end

function CfgExternalFunctions.SetBlindSpeedConst(_, Index, Name)
    if Index == 0 then
        _G.UE.AMajorController:OpenBlindSpeedConst()
	else
        _G.UE.AMajorController:CloseBlindSpeedConst()
	end
end

function CfgExternalFunctions.ShowEffectAxis(Value)
    _G.UE.USkillUtil.SetShowEffectAxis(Value)
end

function CfgExternalFunctions.SetFootstepEffect(_, Index, Name)
    local VisionActorList = _G.UE.UActorManager:Get():GetAllActors()
	local ActorCnt = VisionActorList:Length()
    for i = 1, ActorCnt, 1 do
		local BaseCharacter = VisionActorList:Get(i)
		if BaseCharacter ~= nil then
            BaseCharacter:SetFootstepEffectState(Index)
        end
	end
    
end

return CfgExternalFunctions
