local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local PVPInfoDefine = require("Game/PVP/PVPInfoDefine")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local SimpleProfInfoVM = require("Game/Profession/VM/SimpleProfInfoVM")
local PVPColosseumStarItemVM = require("Game/PVP/Record/VM/PVPColosseumStarItemVM")

local UIBindableList = require("UI/UIBindableList")

local PVPInfoMgr = _G.PVPInfoMgr
local LSTR = _G.LSTR

local RankingIconMap = {
    [1] = "Texture2D'/Game/UI/Texture/PVP/UI_PVP_BattleInfo_Img_First.UI_PVP_BattleInfo_Img_First'",
    [2] = "Texture2D'/Game/UI/Texture/PVP/UI_PVP_BattleInfo_Img_Second.UI_PVP_BattleInfo_Img_Second'",
    [3] = "Texture2D'/Game/UI/Texture/PVP/UI_PVP_BattleInfo_Img_Third.UI_PVP_BattleInfo_Img_Third'",
}

local BGMap = {
    [1] = "Texture2D'/Game/UI/Texture/PVP/UI_PVP_BattleInfo_Img_listBg1.UI_PVP_BattleInfo_Img_listBg1'",
    [2] = "Texture2D'/Game/UI/Texture/PVP/UI_PVP_BattleInfo_Img_listBg2.UI_PVP_BattleInfo_Img_listBg2'",
    [3] = "Texture2D'/Game/UI/Texture/PVP/UI_PVP_BattleInfo_Img_listBg3.UI_PVP_BattleInfo_Img_listBg3'",
    ["Other"] = "Texture2D'/Game/UI/Texture/PVP/UI_PVP_BattleInfo_Img_listBg4.UI_PVP_BattleInfo_Img_listBg4'",
    ["Self"] = "Texture2D'/Game/UI/Texture/PVP/UI_PVP_BattleInfo_Img_listBg5.UI_PVP_BattleInfo_Img_listBg5'",
}

---@class PVPCrystallineLeaderBoardItemVM : UIViewModel
local PVPCrystallineLeaderBoardItemVM = LuaClass(UIViewModel)

function PVPCrystallineLeaderBoardItemVM:Ctor()
    self.Ranking = nil
    self.BGIcon = nil
    self.RankingIcon = nil
    self.RoleID = nil
    self.IsScoreType = nil
    self.Score = nil
    self.ProfVMList = UIBindableList.New(SimpleProfInfoVM)
    self.StarVMList = UIBindableList.New(PVPColosseumStarItemVM)
    self.RankIcon = nil
    self.RankName = nil
    self.IsRankNone = nil
    self.WinCount = nil
    self.IsShowInfo = nil
    self.NotShowInfoText = nil
end

function PVPCrystallineLeaderBoardItemVM:UpdateVM(Params, UpdateParams)
    if Params == nil then return end
    local IsMajor = UpdateParams and UpdateParams.IsMajor
    local IsCurSeason = UpdateParams and UpdateParams.IsCurSeason

    local BattleCount = Params.BtlNum
    self:UpdateIsShowInfo(IsMajor, IsCurSeason, BattleCount)

    local Ranking = Params.Ranking
    self:UpdateRankingText(IsMajor, IsCurSeason, BattleCount, Ranking)
    self:UpdateRankingIcon(IsMajor, Ranking)
    self:UpdateBG(IsMajor, Ranking)
    self.RoleID = Params.RoleID

    self:UpdateProfList(Params.UsedProf)

    local Rank = Params.Rank
    local IsRankNone = PVPInfoMgr:GetCrystallineRankType(Rank) == ProtoRes.Game.pvp_rank_type.RT_None
    self.RankName = PVPInfoMgr:GetCrystallineRankName(Rank)
    if not IsRankNone then  -- 无段位没有图标
        self.RankIcon = PVPInfoDefine.RankIconMap[PVPInfoMgr:GetCrystallineRankType(Rank)]
    end
    self.IsRankNone = IsRankNone
    
    self:UpdateStarScore(Rank, Params.CrystalPoint)
    self.WinCount = Params.WinNum
end

function PVPCrystallineLeaderBoardItemVM:UpdateIsShowInfo(IsMajor, IsCurSeason, BattleCount)
    local IsShowInfo = true
    if IsCurSeason and IsMajor then
        local AtLeastBattleCount = PVPInfoMgr:GetCrystallineLeaderBoardAtLeastBattleCount()
        IsShowInfo = BattleCount >= AtLeastBattleCount

        if not IsShowInfo then
            self.NotShowInfoText = string.format(LSTR(130127), AtLeastBattleCount)
        end
    end
    self.IsShowInfo = IsShowInfo
end

function PVPCrystallineLeaderBoardItemVM:UpdateRankingText(IsMajor, IsCurSeason, BattleCount, Ranking)
    local Text = LSTR(130126)
    if not IsMajor then
        Text = Ranking
    else
        if IsCurSeason then
            local AtLeastBattleCount = PVPInfoMgr:GetCrystallineLeaderBoardAtLeastBattleCount()
            local IsShowInfo = BattleCount >= AtLeastBattleCount
            if IsShowInfo then
                Text = Ranking ~= -1 and Ranking or LSTR(130125)
            end
        else
            Text = Ranking ~= -1 and Ranking or LSTR(130125)
        end
    end
    self.Ranking = Text
end

function PVPCrystallineLeaderBoardItemVM:UpdateRankingIcon(IsMajor, Ranking)
    self.RankingIcon = (IsMajor ~= true) and RankingIconMap[Ranking] or ""
end

function PVPCrystallineLeaderBoardItemVM:UpdateBG(IsMajor, Ranking)
    if not IsMajor then
        self.BGIcon = BGMap[Ranking] or BGMap["Other"]
    else
        self.BGIcon = BGMap["Self"]
    end
end

function PVPCrystallineLeaderBoardItemVM:UpdateStarScore(Rank, Score)
    local IsScoreType = PVPInfoMgr:GetCrystallineRankScoreType(Rank) == ProtoRes.Game.pvp_rank_result_mode.RRM_CRYSTALSCORE

    if IsScoreType then
        self.Score = Score
    else
        local StarCount = PVPInfoMgr:GetCrystallineRankWinStar(Rank)
        local DataList = {}
        for Index = 1, PVPInfoMgr:GetCrystallineRankWinStarMax() do
            local IsGlow = StarCount >= Index
            table.insert(DataList, { IsGlow = IsGlow })
        end
        self.StarVMList:UpdateByValues(DataList)
    end

    self.IsScoreType = IsScoreType
end

function PVPCrystallineLeaderBoardItemVM:UpdateProfList(UsedProf)
    local DataList = {}
    for _, ProfID in ipairs(UsedProf or {}) do
        if ProfID ~= 0 then
            table.insert(DataList, { ProfID = ProfID })
        end
    end

    self.ProfVMList:UpdateByValues(DataList)
end

function PVPCrystallineLeaderBoardItemVM:IsEqualVM(Value)
    return true
end

return PVPCrystallineLeaderBoardItemVM