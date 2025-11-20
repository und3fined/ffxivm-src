local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local ItemVM = require("Game/Item/ItemVM")
local ItemUtil = require("Utils/ItemUtil")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")

local LootMappingCfg = require("TableCfg/LootMappingCfg")
local CrystallineParamCfg = require("TableCfg/CrystallineParamCfg")

local UIBindableList = require("UI/UIBindableList")

local RankType = ProtoRes.Game.pvp_rank_type
local PVPInfoMgr = _G.PVPInfoMgr
local LSTR = _G.LSTR

local RankingRewardIconMap = {
    [1] = {
        ["ItemBG"] = "Texture2D'/Game/UI/Texture/PVP/UI_PVP_BattleInfo_Img_Flag1.UI_PVP_BattleInfo_Img_Flag1'",
        ["FrameBG"] = "Texture2D'/Game/UI/Texture/PersonPortrait/UI_PersonPortrait_Img_190403A.UI_PersonPortrait_Img_190403A'",
        ["FrameBorder"] = "Texture2D'/Game/UI/Texture/PersonPortrait/UI_PersonPortrait_Img_190403B.UI_PersonPortrait_Img_190403B'",
        ["FrameIcon"] = "Texture2D'/Game/UI/Texture/PersonPortrait/UI_PersonPortrait_Img_190403C.UI_PersonPortrait_Img_190403C'",
    },
    [2] = {
        ["ItemBG"] = "Texture2D'/Game/UI/Texture/PVP/UI_PVP_BattleInfo_Img_Flag2.UI_PVP_BattleInfo_Img_Flag2'",
        ["FrameBG"] = "Texture2D'/Game/UI/Texture/PersonPortrait/UI_PersonPortrait_Img_190404A.UI_PersonPortrait_Img_190404A'",
        ["FrameBorder"] = "Texture2D'/Game/UI/Texture/PersonPortrait/UI_PersonPortrait_Img_190404B.UI_PersonPortrait_Img_190404B'",
        ["FrameIcon"] = "Texture2D'/Game/UI/Texture/PersonPortrait/UI_PersonPortrait_Img_190404C.UI_PersonPortrait_Img_190404C'",
    },
    [3] = {
        ["ItemBG"] = "Texture2D'/Game/UI/Texture/PVP/UI_PVP_BattleInfo_Img_Flag3.UI_PVP_BattleInfo_Img_Flag3'",
        ["FrameBG"] = "Texture2D'/Game/UI/Texture/PersonPortrait/UI_PersonPortrait_Img_190405A.UI_PersonPortrait_Img_190405A'",
        ["FrameBorder"] = "Texture2D'/Game/UI/Texture/PersonPortrait/UI_PersonPortrait_Img_190405B.UI_PersonPortrait_Img_190405B'",
        ["FrameIcon"] = "Texture2D'/Game/UI/Texture/PersonPortrait/UI_PersonPortrait_Img_190405C.UI_PersonPortrait_Img_190405C'",
    },
}

local RankRewardIconMap = {
    [RankType.RT_BRONZE] = {
        ["ItemBG"] = "Texture2D'/Game/UI/Texture/PVP/UI_PVP_BattleInfo_Img_Flag4.UI_PVP_BattleInfo_Img_Flag4'",
        ["FrameBG"] = "Texture2D'/Game/UI/Texture/PersonPortrait/UI_PersonPortrait_Img_190406A.UI_PersonPortrait_Img_190406A'",
        ["FrameBorder"] = "Texture2D'/Game/UI/Texture/PersonPortrait/UI_PersonPortrait_Img_190406B.UI_PersonPortrait_Img_190406B'",
        ["FrameIcon"] = "Texture2D'/Game/UI/Texture/PersonPortrait/UI_PersonPortrait_Img_190406C.UI_PersonPortrait_Img_190406C'",
    },
    [RankType.RT_SILVER] = {
        ["ItemBG"] = "Texture2D'/Game/UI/Texture/PVP/UI_PVP_BattleInfo_Img_Flag4.UI_PVP_BattleInfo_Img_Flag4'",
        ["FrameBG"] = "Texture2D'/Game/UI/Texture/PersonPortrait/UI_PersonPortrait_Img_190407A.UI_PersonPortrait_Img_190407A'",
        ["FrameBorder"] = "Texture2D'/Game/UI/Texture/PersonPortrait/UI_PersonPortrait_Img_190407B.UI_PersonPortrait_Img_190407B'",
        ["FrameIcon"] = "Texture2D'/Game/UI/Texture/PersonPortrait/UI_PersonPortrait_Img_190407C.UI_PersonPortrait_Img_190407C'",
    },
    [RankType.RT_GOLD] = {
        ["ItemBG"] = "Texture2D'/Game/UI/Texture/PVP/UI_PVP_BattleInfo_Img_Flag4.UI_PVP_BattleInfo_Img_Flag4'",
        ["FrameBG"] = "Texture2D'/Game/UI/Texture/PersonPortrait/UI_PersonPortrait_Img_190408A.UI_PersonPortrait_Img_190408A'",
        ["FrameBorder"] = "Texture2D'/Game/UI/Texture/PersonPortrait/UI_PersonPortrait_Img_190408B.UI_PersonPortrait_Img_190408B'",
        ["FrameIcon"] = "Texture2D'/Game/UI/Texture/PersonPortrait/UI_PersonPortrait_Img_190408C.UI_PersonPortrait_Img_190408C'",
    },
    [RankType.RT_BIRKIN] = {
        ["ItemBG"] = "Texture2D'/Game/UI/Texture/PVP/UI_PVP_BattleInfo_Img_Flag4.UI_PVP_BattleInfo_Img_Flag4'",
        ["FrameBG"] = "Texture2D'/Game/UI/Texture/PersonPortrait/UI_PersonPortrait_Img_190409A.UI_PersonPortrait_Img_190409A'",
        ["FrameBorder"] = "Texture2D'/Game/UI/Texture/PersonPortrait/UI_PersonPortrait_Img_190409B.UI_PersonPortrait_Img_190409B'",
        ["FrameIcon"] = "Texture2D'/Game/UI/Texture/PersonPortrait/UI_PersonPortrait_Img_190409C.UI_PersonPortrait_Img_190409C'",
    },
    [RankType.RT_DIAMOND] = {
        ["ItemBG"] = "Texture2D'/Game/UI/Texture/PVP/UI_PVP_BattleInfo_Img_Flag4.UI_PVP_BattleInfo_Img_Flag4'",
        ["FrameBG"] = "Texture2D'/Game/UI/Texture/PersonPortrait/UI_PersonPortrait_Img_190410A.UI_PersonPortrait_Img_190410A'",
        ["FrameBorder"] = "Texture2D'/Game/UI/Texture/PersonPortrait/UI_PersonPortrait_Img_190410B.UI_PersonPortrait_Img_190410B'",
        ["FrameIcon"] = "Texture2D'/Game/UI/Texture/PersonPortrait/UI_PersonPortrait_Img_190410C.UI_PersonPortrait_Img_190410C'",
    },
    [RankType.RT_CRYSTALE] = {
        ["ItemBG"] = "Texture2D'/Game/UI/Texture/PVP/UI_PVP_BattleInfo_Img_Flag4.UI_PVP_BattleInfo_Img_Flag4'",
        ["FrameBG"] = "Texture2D'/Game/UI/Texture/PersonPortrait/UI_PersonPortrait_Img_190411A.UI_PersonPortrait_Img_190411A'",
        ["FrameBorder"] = "Texture2D'/Game/UI/Texture/PersonPortrait/UI_PersonPortrait_Img_190411B.UI_PersonPortrait_Img_190411B'",
        ["FrameIcon"] = "Texture2D'/Game/UI/Texture/PersonPortrait/UI_PersonPortrait_Img_190411C.UI_PersonPortrait_Img_190411C'",
    },
}

---@class PVPCrystallineRankRewardItemVM : UIViewModel
local PVPCrystallineRankRewardItemVM = LuaClass(UIViewModel)

function PVPCrystallineRankRewardItemVM:Ctor()
    self.BG = nil
    self.FrameBG = nil
    self.FrameBorder = nil
    self.FrameIcon = nil
    self.Desc = nil
    self.RewardVMList = UIBindableList.New(ItemVM, { IsCanBeSelected = false })
end

function PVPCrystallineRankRewardItemVM:UpdateVM(Params)
    self:UpdateIcon(Params)
    self:UpdateDesc(Params)
    self:UpdateRewardList(Params.LootID)
end

function PVPCrystallineRankRewardItemVM:UpdateIcon(Params)
    local Rank = Params and Params.Rank or 0
    local IsRanking = Params and Params.IsRanking
    local RewardIconMap = IsRanking and RankingRewardIconMap or RankRewardIconMap
    local IconMap = RewardIconMap and RewardIconMap[Rank]
    if IconMap then
        self.BG = IconMap.ItemBG
        self.FrameBG = IconMap.FrameBG
        self.FrameBorder = IconMap.FrameBorder
        self.FrameIcon = IconMap.FrameIcon
    end
end

function PVPCrystallineRankRewardItemVM:UpdateDesc(Params)
    local IsRanking = Params and Params.IsRanking
    local Rank = Params and Params.Rank or 0
    local Desc = ""
    if IsRanking then
        if Rank == 1 then
            local Cfg = CrystallineParamCfg:FindCfgByKey(ProtoRes.Game.game_pvpcolosseum_params_id.PVPCOLOSSEUM_SEASON_RESULT_RANK1)
            if Cfg then
                Desc = string.format(LSTR(130092), Cfg.Value[1])
            end
        elseif Rank == 2 then
            local Cfg = CrystallineParamCfg:FindCfgByKey(ProtoRes.Game.game_pvpcolosseum_params_id.PVPCOLOSSEUM_SEASON_RESULT_RANK2)
            if Cfg then
                Desc = string.format(LSTR(130093), Cfg.Value[1], Cfg.Value[2])
            end
        elseif Rank == 3 then
            local Cfg = CrystallineParamCfg:FindCfgByKey(ProtoRes.Game.game_pvpcolosseum_params_id.PVPCOLOSSEUM_SEASON_RESULT_RANK3)
            if Cfg then
                Desc = string.format(LSTR(130094), Cfg.Value[1], Cfg.Value[2])
            end
        else
            Desc = ""
        end
    else
        Desc = ProtoEnumAlias.GetAlias(RankType, Rank)
    end

    self.Desc = Desc
end

function PVPCrystallineRankRewardItemVM:UpdateRewardList(LootID)
    local DataList = {}
    local LootCfg = LootMappingCfg:FindCfg(string.format("ID=%d", LootID))
    if LootCfg then
        for _, Program in pairs(LootCfg.Programs or {}) do
            local RewardItemList = ItemUtil.GetLootItems(Program.ID)
            if RewardItemList then
                table.merge_table(DataList, RewardItemList)
            end
        end
    end

    self.RewardVMList:UpdateByValues(DataList)
end

return PVPCrystallineRankRewardItemVM