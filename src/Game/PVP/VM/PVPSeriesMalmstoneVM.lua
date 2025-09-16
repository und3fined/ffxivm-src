local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoCS = require("Protocol/ProtoCS")
local TimeUtil = require("Utils/TimeUtil")
local DateTimeTools = require("Common/DateTimeTools")
local SeriesMalmstoneRewardCfg = require("TableCfg/SeriesMalmstoneRewardCfg")
local SeriesMalmstoneSeasonCfg = require("TableCfg/SeriesMalmstoneSeasonCfg")
local SeriesMalmstoneGetExpCfg = require("TableCfg/SeriesMalmstoneGetExpCfg")
local PVPSeriesMalmstoneRewardItemVM = require ("Game/PVP/VM/PVPSeriesMalmstoneRewardItemVM")

local UIBindableList = require("UI/UIBindableList")

local PVPInfoMgr = _G.PVPInfoMgr

---@class PVPSeriesMalmstoneVM : UIViewModel
local PVPSeriesMalmstoneVM = LuaClass(UIViewModel)

function PVPSeriesMalmstoneVM:Ctor()
    self.IsLevelMax = false
    self.RewardVMList = UIBindableList.New(PVPSeriesMalmstoneRewardItemVM)
    self.GetExpCfgList = self:InitGetExpList()
end

function PVPSeriesMalmstoneVM:UpdateVM(Params)

end

function PVPSeriesMalmstoneVM:InitGetExpList()
    local Cfgs = SeriesMalmstoneGetExpCfg:FindAllCfg()
    return Cfgs ~= nil and Cfgs or {}
end

function PVPSeriesMalmstoneVM:CheckLevelMax()
    local CurSeasonCfg = PVPInfoMgr:GetCurSeasonSeriesMalmstoneCfg()
    if CurSeasonCfg == nil then return end

    local CurLevel = PVPInfoMgr:GetSeriesMalmstoneLevel()
    self.IsLevelMax = CurLevel >= CurSeasonCfg.LevelMax
end

function PVPSeriesMalmstoneVM:ShowCurSeasonRewards()
    local CurSeasonCfg = PVPInfoMgr:GetCurSeasonSeriesMalmstoneCfg()
    if CurSeasonCfg == nil then return end

    self:ShowRewards(CurSeasonCfg.SeasonID)
end

function PVPSeriesMalmstoneVM:ShowRewards(Season)
    local SeasonCfg = SeriesMalmstoneSeasonCfg:FindCfgByKey(Season)
    if SeasonCfg == nil then return end

    local SearchCondition = string.format("GroupID == %d", SeasonCfg.LevelGroup)
    local RewardCfgs = SeriesMalmstoneRewardCfg:FindAllCfg(SearchCondition)
    if RewardCfgs == nil then return end

    self.RewardVMList:UpdateByValues(RewardCfgs)
end

return PVPSeriesMalmstoneVM