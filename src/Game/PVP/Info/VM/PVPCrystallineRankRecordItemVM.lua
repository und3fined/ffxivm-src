local LuaClass = require("Core/LuaClass")
local ProtoRes = require("Protocol/ProtoRes")
local UIViewModel = require("UI/UIViewModel")
local LocalizationUtil = require("Utils/LocalizationUtil")
local TimeUtil = require("Utils/TimeUtil")
local PVPInfoDefine = require("Game/PVP/PVPInfoDefine")

local SeriesMalmstoneSeasonCfg = require("TableCfg/SeriesMalmstoneSeasonCfg")

local RankType = ProtoRes.Game.pvp_rank_type
local PVPInfoMgr = _G.PVPInfoMgr
local LSTR = _G.LSTR

local RankRecordDefaultBG = "Texture2D'/Game/UI/Texture/PVP/UI_PVP_BattleInfo_Img_FlagExpectation.UI_PVP_BattleInfo_Img_FlagExpectation'"
local RankRecordBGMap = {
    [RankType.RT_None] = "Texture2D'/Game/UI/Texture/PVP/UI_PVP_BattleInfo_Img_FlagNo.UI_PVP_BattleInfo_Img_FlagNo'",
    [RankType.RT_BRONZE] = "Texture2D'/Game/UI/Texture/PVP/UI_PVP_BattleInfo_Img_FlagBronze.UI_PVP_BattleInfo_Img_FlagBronze'",
    [RankType.RT_SILVER] = "Texture2D'/Game/UI/Texture/PVP/UI_PVP_BattleInfo_Img_FlagSilver.UI_PVP_BattleInfo_Img_FlagSilver'",
    [RankType.RT_BIRKIN] = "Texture2D'/Game/UI/Texture/PVP/UI_PVP_BattleInfo_Img_FlagPlatinum.UI_PVP_BattleInfo_Img_FlagPlatinum'",
    [RankType.RT_DIAMOND] = "Texture2D'/Game/UI/Texture/PVP/UI_PVP_BattleInfo_Img_FlagDiamond.UI_PVP_BattleInfo_Img_FlagDiamond'",
    [RankType.RT_CRYSTALE] = "Texture2D'/Game/UI/Texture/PVP/UI_PVP_BattleInfo_Img_FlagCrystal.UI_PVP_BattleInfo_Img_FlagCrystal'",
}

---@class PVPCrystallineRankRecordItemVM : UIViewModel
local PVPCrystallineRankRecordItemVM = LuaClass(UIViewModel)

function PVPCrystallineRankRecordItemVM:Ctor()
    self.SeasonID = nil
    self.Season = nil
    self.SeasonTime = nil
    self.RankName = nil
    self.RankBP = nil
    self.BG = nil
end

function PVPCrystallineRankRecordItemVM:UpdateVM(Params)
    if Params == nil then return end

    local SeasonID = Params.SeasonID
    self.SeasonID = SeasonID
    self:UpdateSeasonTime(SeasonID)

    local Data = PVPInfoMgr:GetCrystallineRankRecordData(SeasonID)
    local Rank = Data and Data.RankID
    self.RankName = PVPInfoMgr:GetCrystallineRankName(Rank)
    self:UpdateRankIcon(Rank)
    
end

function PVPCrystallineRankRecordItemVM:UpdateSeasonTime(SeasonID)
    local Cfg = SeriesMalmstoneSeasonCfg:FindCfgByKey(SeasonID)
    if Cfg then
        self.Season = Cfg.Season

        local BeginTime = TimeUtil.GetTimeFromServerZoneString(Cfg.BeginTime)
        local BeginTimeString = LocalizationUtil.LocalizeStringDate_Timestamp_YMD(BeginTime)
        local EndTime = TimeUtil.GetTimeFromServerZoneString(Cfg.EndTime)
        local EndTimeString = LocalizationUtil.LocalizeStringDate_Timestamp_YMD(EndTime)
        self.SeasonTime = string.format(LSTR(130097), BeginTimeString, EndTimeString)
    end
end

function PVPCrystallineRankRecordItemVM:UpdateRankIcon(Rank)
    local RankType = PVPInfoMgr:GetCrystallineRankType(Rank)
    if RankType == nil then return end

    self.RankBP = PVPInfoDefine.RankBPMap[RankType]
    self.BG = RankRecordBGMap[RankType] or RankRecordDefaultBG
end

return PVPCrystallineRankRecordItemVM