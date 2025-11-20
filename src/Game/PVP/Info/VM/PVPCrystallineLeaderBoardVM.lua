local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoCS = require("Protocol/ProtoCS")
local MajorUtil = require("Utils/MajorUtil")

local SeriesMalmstoneSeasonCfg = require("TableCfg/SeriesMalmstoneSeasonCfg")
local PVPCrystallineLeaderBoardItemVM = require ("Game/PVP/Info/VM/PVPCrystallineLeaderBoardItemVM")

local UIBindableList = require("UI/UIBindableList")

local PVPInfoMgr = _G.PVPInfoMgr
local UVersionMgr = _G.UE.UVersionMgr
local LSTR = _G.LSTR

---@class PVPCrystallineLeaderBoardVM : UIViewModel
local PVPCrystallineLeaderBoardVM = LuaClass(UIViewModel)

function PVPCrystallineLeaderBoardVM:Ctor()
    self.MajorInfoVM = PVPCrystallineLeaderBoardItemVM.New()
    self.InfoVMList = UIBindableList.New(PVPCrystallineLeaderBoardItemVM)
    self.SeasonList = self:InitSeasonList()
    self.CurShowSeasonID = 0
    self.CurShowEmpty = nil
end

function PVPCrystallineLeaderBoardVM:UpdateVM(Params)

end

function PVPCrystallineLeaderBoardVM:InitSeasonList()
    local SeasonList = {}
    local Cfgs = SeriesMalmstoneSeasonCfg:FindAllCfg()
    for _, Cfg in pairs(Cfgs or {}) do
        local Season = Cfg.Season
        if Season ~= 0 then
            local BeginVersion = Cfg.BeginVersion
            if not string.isnilorempty(BeginVersion) and UVersionMgr.IsBelowOrEqualGameVersion(BeginVersion) then
                local Name = string.format(LSTR(130079), Cfg.Season)
                local ItemData = {
                    SeasonID = Cfg.SeasonID,
                    Season = Season
                }
                table.insert(SeasonList, { Name = Name, ItemData = ItemData})
            end
        end
    end
    
    local function SortBySeason(Data1, Data2)
        local Season1 = ((Data1 or {}).ItemData or {}).Season or 0
        local Season2 = ((Data2 or {}).ItemData or {}).Season or 0

        return Season1 > Season2
    end
    table.sort(SeasonList, SortBySeason)
    return SeasonList
end

function PVPCrystallineLeaderBoardVM:ShowSeasonInfo(SeasonID)
    self.CurShowSeasonID = SeasonID
    local Info = PVPInfoMgr:GetCrystallineRankingInfo(SeasonID)
    local DataList = {}

    for Ranking, RoleInfo in ipairs(Info or {}) do
        local Data = {
            Ranking = Ranking,
            RoleID = RoleInfo.RoleID,
            UsedProf = RoleInfo.UsedProf.UsedProfs,
            Rank = RoleInfo.Rank,
            CrystalPoint = RoleInfo.CrystalPoint,
            WinNum = RoleInfo.WinNum,
        }
        table.insert(DataList, Data)
    end

    local IsEmpty = #DataList <= 0
    self.CurShowEmpty = IsEmpty

    if not IsEmpty then
        self.InfoVMList:UpdateByValues(DataList)

        local SelfData = PVPInfoMgr:GetCrystallineRankingInfoSelf(SeasonID)
        if SelfData then 
            local CurVersionCfg = PVPInfoMgr:GetCurVersionSeriesMalmstoneCfg()
            local IsCurSeason = CurVersionCfg and SeasonID == CurVersionCfg.SeasonID
            local RankData = SelfData.Rank
            local MajorData = {
                Ranking = SelfData.SelfRankNo,
                RoleID = RankData.RoleID,
                UsedProf = RankData.UsedProf.UsedProfs,
                Rank = RankData.Rank,
                CrystalPoint = RankData.CrystalPoint,
                WinNum = RankData.WinNum,
                BtlNum = SelfData.BtlNum,
            }
            self.MajorInfoVM:UpdateVM(MajorData, { IsMajor = true, IsCurSeason = IsCurSeason })
        end
    end
end

return PVPCrystallineLeaderBoardVM