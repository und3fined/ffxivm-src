--[[
Author: zhangyuhao_ds zhangyuhao@dasheng.tv
Date: 2025-08-15 14:57:15
LastEditors: zhangyuhao_ds zhangyuhao@dasheng.tv
LastEditTime: 2025-08-15 14:57:57
FilePath: \Script\Game\Adventure\AdventureFateRecommendMgr.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local FateDynamicCfg = require("TableCfg/FateDynamicCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local MajorUtil = require("Utils/MajorUtil")
local MapUtil = require("Game/Map/MapUtil")
local ProtoCS = require("Protocol/ProtoCS")
local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.CS_FATE_CMD
local ClientGlobalCfg = require("TableCfg/ClientGlobalCfg")
local ProtoRes = require("Protocol/ProtoRes")

local AdventureFateRecommendMgr = LuaClass(MgrBase)

function AdventureFateRecommendMgr:Ctor()
    self.FateRewardCfg = {}
end

function AdventureFateRecommendMgr:OnBegin()
	local FateRewardCfg = ClientGlobalCfg:FindCfgByKey(ProtoRes.client_global_cfg_id.GLOBAL_CFG_ADVENTURE_FATE_REWARD)
	if FateRewardCfg then
        self.FateRewardCfg = FateRewardCfg.Value or {}
	end
end

function AdventureFateRecommendMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FATE, SUB_MSG_ID.CS_FATE_CMD_GET_MAP_SETTLE_WEIGHT, self.RspFateMapsWeight)
end

function AdventureFateRecommendMgr:SendGetFateMapsWeight(MapIDs)
    local MsgID = CS_CMD.CS_CMD_FATE
    local SubMsgID = SUB_MSG_ID.CS_FATE_CMD_GET_MAP_SETTLE_WEIGHT
    local MsgBody = {
        Cmd = SubMsgID,
        FateGetMapSettleWeight = {
            MapIDs = MapIDs
        }
    }
    _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function AdventureFateRecommendMgr:RspFateMapsWeight(MsgBody)
    if MsgBody and MsgBody.FateGetMapSettleWeight then
        _G.EventMgr:SendEvent(_G.EventID.AdventureFateMapsWeight, MsgBody.FateGetMapSettleWeight)
    end
end

function AdventureFateRecommendMgr:GetFateProfDropList()
    local MajorRoleDetail = _G.ActorMgr:GetMajorRoleDetail()
    local ProfDetailList = MajorRoleDetail.Prof and MajorRoleDetail.Prof.ProfList or {}
    local DropList = {}
    for k, v in pairs(ProfDetailList) do
        local ProfInfo = RoleInitCfg:FindCfgByKey(v.ProfID)
        local ProfType = ProfInfo.Specialization
        local ProfName = RoleInitCfg:FindRoleInitProfName(v.ProfID)
        if ProfType ~=  ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION then 
            local Data = {
                Level = v.Level,
                IconPath = ProfInfo.ProfIcon,
                Prof = v.ProfID,
                Name = string.format(_G.LSTR(520077), v.Level, ProfName),
                ImgIconColorbSameasText = true
            }
            table.insert(DropList, Data)
        end
    end

    local MajorProfID = MajorUtil.GetMajorProfID()
    table.sort(DropList, function(a, b)
        local SortA = a.Prof == MajorProfID and 999 or a.Level
        local SortB = b.Prof == MajorProfID and 999 or b.Level
        return SortA > SortB
    end)

    return DropList
end

function AdventureFateRecommendMgr:SendGetFateRecommendMapsDataByLevel(Level)
    local WEFateRecMapCfg = require("TableCfg/WEFateRecMapCfg")
	local FateCfg = WEFateRecMapCfg:FindCfgByKey(Level)
	if not FateCfg then return end
    local MapIDs = FateCfg.MapID

    if MapIDs and next(MapIDs) then
        self:SendGetFateMapsWeight(FateCfg.MapID)
    else
        FLOG_ERROR("Empty MapsIDs")
    end
end

function AdventureFateRecommendMgr:GetMapListDataByServerMapsWeight(MapsWeight, Level)
    local WEFateRecMapCfg = require("TableCfg/WEFateRecMapCfg")
	local FateCfg = WEFateRecMapCfg:FindCfgByKey(Level)
	if not FateCfg then return {} end

    local FateSort = {}
    for i, v in ipairs(FateCfg.MapID) do
        FateSort[v] = i
    end

    local IsAllAdapt = true
    local FateRecommendList = {}
    for MapID, Weight in pairs(MapsWeight) do
        local UIMapID = MapUtil.GetUIMapID(MapID) or 0
        local MapName = MapUtil.GetMapName(UIMapID) or ""
        local RealWidght = Weight >= 0 and Weight or 0
        local CfgSearchCond = string.format("LowerBound <= %s AND UpperBound > %s", RealWidght, RealWidght)
	    local FateWeightCfg = FateDynamicCfg:FindCfg(CfgSearchCond)
        if FateWeightCfg and next(FateWeightCfg) then
            local Data = {
                TextTitle = MapName,
                PlayerNum = FateWeightCfg.PlayerNums,
                BattleDes = FateWeightCfg.BattleIntensity,
                MapID = MapID,
                UIMapID = UIMapID,
            }

            if not FateSort[MapID] then
                IsAllAdapt = false
            end

            table.insert(FateRecommendList, Data)
        end
    end

    if IsAllAdapt then
        table.sort(FateRecommendList, function(a, b)
            local SortA = FateSort[a.MapID] or 4
            local SortB = FateSort[b.MapID] or 4
            return SortA < SortB
        end)
    end

    return FateRecommendList
end

return AdventureFateRecommendMgr