local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local MajorUtil = require("Utils/MajorUtil")

local PVPCrystallineRankRewardItemVM = require ("Game/PVP/Info/VM/PVPCrystallineRankRewardItemVM")

local UIBindableList = require("UI/UIBindableList")

local PVPInfoMgr = _G.PVPInfoMgr
local UVersionMgr = _G.UE.UVersionMgr
local LSTR = _G.LSTR

---@class PVPCrystallineRankRewardVM : UIViewModel
local PVPCrystallineRankRewardVM = LuaClass(UIViewModel)

function PVPCrystallineRankRewardVM:Ctor()
    self.RankingVMList = UIBindableList.New(PVPCrystallineRankRewardItemVM)
    self.RankVMList = UIBindableList.New(PVPCrystallineRankRewardItemVM)
    self:InitRewardVMList()
end

function PVPCrystallineRankRewardVM:InitRewardVMList()
    self:InitRankingVMList()
    self:InitRankVMList()
end

function PVPCrystallineRankRewardVM:InitRankingVMList()
    local Cfg = PVPInfoMgr:GetCurVersionSeriesMalmstoneCfg()
    if Cfg then
        local DataList = {}
        for Index = 1, 3 do
            local Data = {
                IsRanking = true,
                Rank = Index,
                LootID = Cfg.RankProof[Index].RewardID or 0,
            }
            table.insert(DataList, Data)
        end

        self.RankingVMList:UpdateByValues(DataList)
    end
end

function PVPCrystallineRankRewardVM:InitRankVMList()
    local Cfg = PVPInfoMgr:GetCurVersionSeriesMalmstoneCfg()
    if Cfg then
        local DataList = {}
        local RankTypeList = ProtoRes.Game.pvp_rank_type
        for _, Type in pairs(RankTypeList) do
            if Type ~= ProtoRes.Game.pvp_rank_type.RT_None then
                local Data = {
                    IsRanking = false,
                    Rank = Type,
                    LootID = Cfg.RankReward[Type] or 0,
                }
                table.insert(DataList, Data)
            end
        end

        local function SortFunction(Data1, Data2)
            return Data1.Rank > Data2.Rank
        end

        table.sort(DataList, SortFunction)
        self.RankVMList:UpdateByValues(DataList)
    end
end

return PVPCrystallineRankRewardVM