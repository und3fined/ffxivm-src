local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local SceneEnterCfg = require("TableCfg/SceneEnterCfg")
local SceneEnterDailyRandomCfg = require("TableCfg/SceneEnterDailyRandomCfg")
local SceneEnterTypeCfg = require("TableCfg/SceneEnterTypeCfg")
local PworldCfg = require("TableCfg/PworldCfg")
local LocalizationUtil = require("Utils/LocalizationUtil")
local GameGlobalCfg = require("TableCfg/GameGlobalCfg")
local ProtoRes = require("Protocol/ProtoRes")
local PWorldHelper = require("Game/PWorld/PWorldHelper")
local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")

local MATCH_ITEM_TYPE =
{
    NULL = 1,
    NORMAL = 2,
    DAILY_RANDOM = 3,
    CHOCOBO = 4,
    CHOCOBO_RANDOM_TRACK = 5,
    CRYSTALLINE = 6,
}

---@class PWorldMatchItemVM: UIViewModel
local PWorldMatchItemVM = LuaClass(UIViewModel)

function PWorldMatchItemVM:Ctor()
    self.Enable = false
    self.Icon = ""
    self.Name = ""
    self.Prof = 1
    self.Lv = 0
    self.Order = 0
    self.EstimateWaitTimeDesc = ""
    self.CanOp = true
    self.CancelText = ""
    self.IsShowProf = true
    self.IsShowStatus = true
    self.IsShowTextSort = true      --#TODO DELETE IT
    self.bUseRobotMatch = false
    self.bShowRobotMatchCheck = false
    self.bShowOrer = false
    self.bShowLackProf = false
    self.LackProf = 0
end

function PWorldMatchItemVM:IsEqualVM(Value)
    return Value and Value.EntID == self.EntID  and self.EntID
end

function PWorldMatchItemVM:UpdateVM(Value)
    self.Enable = Value.Enable
    if not self.Enable then
        return
    end

    local PWorldMatchMgr = _G.PWorldMatchMgr
    self.EntID = Value.EntID

    if not self.EntID then
        self.bShowRobotMatchCheck = false
        self.bUseRobotMatch = false
        self.bShowOrer = false
        self.bShowLackProf = false
        return
    end

    self:UpdateMatchTime()

    do
        self.bShowRobotMatchCheck = _G.PWorldMatchMgr.IsRobotMatchNeed(self.EntID)
        self.bUseRobotMatch =  self.bShowRobotMatchCheck
        if self.bShowRobotMatchCheck then
            _G.PWorldMatchMgr:SetUseRobotMatch(self.EntID, true)
        end
        local bNormalEntrance = false
        local ECfg = SceneEnterCfg:FindCfgByKey(self.EntID)
        if ECfg and (ECfg.TypeID or 0) <= 4 and (ECfg.TypeID or 0) > 0 then
            bNormalEntrance = true
        else
            if SceneEnterDailyRandomCfg:FindCfgByKey(self.EntID) ~= nil then
                bNormalEntrance = true
            end
        end

        self.bShowOrer = bNormalEntrance
        self.bShowLackProf = bNormalEntrance
        self:UpdateLackProf()
    end
    
    local MatchItemType = MATCH_ITEM_TYPE.NULL
    local Item = PWorldMatchMgr:GetMatchItem(self.EntID)
    if Item then
        MatchItemType = MATCH_ITEM_TYPE.NORMAL
        local IsDailyRandom = PWorldMatchMgr:IsDailyRandomStat()
        if IsDailyRandom then
            MatchItemType = MATCH_ITEM_TYPE.DAILY_RANDOM
        end
    else
        Item = PWorldMatchMgr:GetMatchChocoboItem(self.EntID)
        if Item then
            if Item.IsRandom then
                MatchItemType = MATCH_ITEM_TYPE.CHOCOBO_RANDOM_TRACK
            else
                MatchItemType = MATCH_ITEM_TYPE.CHOCOBO
            end
        end

        Item = PWorldMatchMgr:GetCrystallineItem(self.EntID)
        if Item then
            MatchItemType = MATCH_ITEM_TYPE.CRYSTALLINE
        end
    end
    
    if MatchItemType == MATCH_ITEM_TYPE.NULL then
        _G.FLOG_ERROR(string.format("PWorldVoteVM:UpdateVM has not Item SceneID = %s", tostring(self.EntID)))
        return
    end

    local Cfg = nil
    if MatchItemType == MATCH_ITEM_TYPE.DAILY_RANDOM then
        Cfg = SceneEnterDailyRandomCfg:FindCfgByKey(self.EntID)
    elseif MatchItemType == MATCH_ITEM_TYPE.CHOCOBO_RANDOM_TRACK then
        local GlobalCfgValue = GameGlobalCfg:FindValue(ProtoRes.Game.game_global_cfg_id.GAME_CFG_CHOCOBO_RACE_MAP_ID_RANGE, "Value")
        local ChocoboRaceMapResID = GlobalCfgValue and GlobalCfgValue[1] or 1216001
        Cfg = SceneEnterCfg:FindCfgByKey(ChocoboRaceMapResID)
    else
        Cfg = SceneEnterCfg:FindCfgByKey(self.EntID)
    end
    
    if Cfg == nil then
        _G.FLOG_ERROR("PWorldMatchItemVM UpdateVM Cfg = nil!")
        return
    end
    
    if MatchItemType == MATCH_ITEM_TYPE.CHOCOBO_RANDOM_TRACK then
        -- LSTR string: 陆行鸟竞赛 随机赛道
        self.Name = _G.LSTR(430008)
    elseif MatchItemType == MATCH_ITEM_TYPE.CRYSTALLINE then
        if PWorldEntUtil.IsCrystallineExercise(Cfg.TypeID) then
            self.Name = _G.LSTR(1320137)
        elseif PWorldEntUtil.IsCrystallineRank(Cfg.TypeID) then
            self.Name = _G.LSTR(1320138)
        else
            local PCfg = PworldCfg:FindCfgByKey(self.EntID)
            self.Name = PCfg and PCfg.PWorldName or ""
        end
    else
        if MatchItemType == MATCH_ITEM_TYPE.DAILY_RANDOM then
            self.Name = Cfg.Name
        else
            local PCfg = PworldCfg:FindCfgByKey(self.EntID)
            if not PCfg then
                _G.FLOG_ERROR("PWorldMatchItemVM UpdateVM PworldCfg = nil!")
                return
            end
            self.Name = PCfg.PWorldName
        end
    end
    
    self.EntType = Cfg.TypeID
    local TypeCfg = SceneEnterTypeCfg:FindCfgByKey(self.EntType)
    if not TypeCfg then
        _G.FLOG_ERROR("PWorldMatchItemVM UpdateVM TypeCfg = nil! EntTypeID = " .. tostring(self.EntType))
    end

    self.Icon = TypeCfg and TypeCfg.Icon or nil
    
    if MatchItemType == MATCH_ITEM_TYPE.NORMAL or MatchItemType == MATCH_ITEM_TYPE.DAILY_RANDOM then
        self.IsShowProf = true
        self.IsShowStatus = true
        self.Prof = Item.Prof
        self.Lv = Item.Level
        self:SetOrder(0)
    elseif MatchItemType == MATCH_ITEM_TYPE.CRYSTALLINE then
        self.IsShowProf = true
        self.IsShowStatus = false
        self.Prof = Item.Prof
        self.Lv = Item.Level
        self.IsShowTextSort = false
    else
        self.IsShowProf = false
        self.IsShowStatus = false
        self.IsShowTextSort = false
    end

    self:UpdateOp()
end

---@private
function PWorldMatchItemVM:SetOrder(V)
    self.IsShowTextSort = V and V > 0       --#TODO DELETE
    self.Order = V
end

function PWorldMatchItemVM:UpdateMatchRank()
    if not self.Enable then
        return
    end

    self:SetOrder(_G.PWorldMatchMgr:GetMatchRank(self.EntID, self.EntType))
end

function PWorldMatchItemVM:UpdateMatchTime()
    if self.EntID == nil then
        return 
     end

     local MatchTimeData = _G.PWorldMatchMgr:GetMatchTimeDataElement(self.EntID)
     if MatchTimeData then
        self.EstimateWaitTimeDesc = string.sformat(LSTR(1320117), MatchTimeData.EstDesc)
        if self.CanOp then
            self.CancelText = PWorldHelper.pformat("PWORLD_MATCH_CANCEL_REMAIN", LocalizationUtil.GetCountdownTimeForShortTime(MatchTimeData.TotalWaitTime, "mm:ss"))
        else
            self.CancelText = _G.LSTR(1320008) 
        end
    else
        self.EstimateWaitTimeDesc = ""
        if self.CanOp then
            self.CancelText = _G.LSTR(1320007)
        else
            self.CancelText = _G.LSTR(1320008) 
        end
    end
end

function PWorldMatchItemVM:UpdateOp()
    if _G.TeamMgr:IsInTeam() and not _G.TeamMgr:IsCaptain() then
        self.CanOp = false
    else
        self.CanOp = true
    end
end

function PWorldMatchItemVM:SetRobotMatchChecked(bChecked)
    if self.bShowRobotMatchCheck then
       self.bUseRobotMatch = bChecked 
       _G.PWorldMatchMgr:SetUseRobotMatch(self.EntID, bChecked)
    end
end

function PWorldMatchItemVM:UpdateLackProf()
    self.LackProf = _G.PWorldMatchMgr:GetLackProfFunc(self.EntID)
end

return PWorldMatchItemVM
