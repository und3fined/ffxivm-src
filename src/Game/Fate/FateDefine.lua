local FateIconCfgTable = require("TableCfg/FateIconCfg")
local ProtoRes = require("Protocol/ProtoRes")

local FateDefine = {
    IconPath = {
        "Texture2D'/Game/UI/Texture/NewMain/UI_Main_Icon_Fate.UI_Main_Icon_Fate'"
    },
    HiddenCondiState = {
        Hide = 0,
        Cycle = 1,
        Complete = 2
    }
}

local FateTypeToIconTable = {}
FateTypeToIconTable[ProtoRes.Game.FATE_TYPE.FATE_TYPE_MONSTER] = ProtoRes.FateIconType.ICON_MONSTER
FateTypeToIconTable[ProtoRes.Game.FATE_TYPE.FATE_TYPE_BOSS] = ProtoRes.FateIconType.ICON_BOSS
FateTypeToIconTable[ProtoRes.Game.FATE_TYPE.FATE_TYPE_COLLECT] = ProtoRes.FateIconType.ICON_COLLECT
FateTypeToIconTable[ProtoRes.Game.FATE_TYPE.FATE_TYPE_ESCORT] = ProtoRes.FateIconType.ICON_ESCORT
FateTypeToIconTable[ProtoRes.Game.FATE_TYPE.FATE_TYPE_DEFENCE] = ProtoRes.FateIconType.ICON_DEFENCE

function FateDefine.GetIcon(IconType)
    local Cfg = FateIconCfgTable:FindCfg(string.format('Type = %d', IconType))
    if Cfg ~= nil then
        return Cfg.IconPath
    else
        return FateDefine.IconPath
    end
end

function FateDefine.GetIconByFateID(InFateID)
    local TargetCfg = _G.FateMgr:GetFateCfg(InFateID)
    if (TargetCfg == nil) then
        _G.FLOG_ERROR("无法获取 FATE 表格信息，将使用默认的FATE图标，FATE的 ID 是 %s", InFateID)
        return FateDefine.IconPath
    end

    if (TargetCfg.IsCelebrateFate and TargetCfg.IsCelebrateFate > 0) then
        -- 庆典活动，用庆典专用的
        return FateDefine.GetIcon(ProtoRes.FateIconType.ICON_FATE_ACTIVITY)
    else
        return FateDefine.GetIcon(FateTypeToIconTable[TargetCfg.Type])
    end
end

function FateDefine.ParseLocation(String)
    if String == nil then return nil end

    local SplitStr = string.split(String, ",")
    local X = tonumber(SplitStr[1])
    local Y = tonumber(SplitStr[2])
    local Z = tonumber(SplitStr[3])
    if X ~= nil and Y ~= nil and Z ~= nil then
        return _G.UE.FVector(X, Y, Z)
    end
end

function FateDefine.ParseRotation(String)
    if String == nil then return nil end

    local SplitStr = string.split(String, ",")
    local Yaw = tonumber(SplitStr[4])
    if Yaw ~= nil then
        return _G.UE.FRotator(0, Yaw, 0)
    end
end

return FateDefine