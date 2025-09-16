--
-- Author: sammrli
-- Date: 2025-5-28 15:14
-- Description: 副本游戏-守护天节
--

local LuaClass = require("Core/LuaClass")
local OpsGameplayBase = require("Game/OpsGameplay/OpsGameplayBase")

local EventID = require("Define/EventID")
local UIViewID = require("Define/UIViewID")

local OpsGameplayHalloweenVM = require("Game/OpsGameplay/Halloween/OpsGameplayHalloweenVM")

local SceneClueCfg = require("TableCfg/SceneClueCfg")
local OpsGameplayProgressCfg = require("TableCfg/OpsGameplayProgressCfg")
local SceneClueTrueorfalseCfg = require("TableCfg/SceneClueTrueorfalseCfg")

local UIUtil = require("Utils/UIUtil")
local CommonUtil = require("Utils/CommonUtil")

---@class ClueData
---@field ID number
---@field ClueText string
---@field Truth boolean
---@field Discovery boolean
---@field IsFixedOrder boolean
---@field Order number | nil

---@class OpsGameplayHalloween : OpsGameplayBase
local OpsGameplayHalloween = LuaClass(OpsGameplayBase)

local InteractiveOrder = 0

function OpsGameplayHalloween:OnInit()
    self.ClueCfgMap = {} --table<RegisterID, SceneClueCfg>
    self.ClueTruthCfgMap = {} --table<RegisterID, ClueTrueOrFalseMap>

    local AllSceneClueCfg = SceneClueCfg:FindAllCfg()
    if AllSceneClueCfg then
        for _, Cfg in ipairs(AllSceneClueCfg) do
            local RegisterID = Cfg.RegisterID or 0
            if RegisterID > 0 then
                self.ClueCfgMap[RegisterID] = Cfg
            end
        end
    end

    local AllSceneClueTrueorfalseCfg = SceneClueTrueorfalseCfg:FindAllCfg()
    if AllSceneClueTrueorfalseCfg then
        for _, Cfg in ipairs(AllSceneClueTrueorfalseCfg) do
            local RegisterID = Cfg.RegisterID or 0
            if RegisterID > 0 then
                self.ClueTruthCfgMap[RegisterID] = Cfg
            end
        end
    end
end

function OpsGameplayHalloween:OnBegin()
    self.HalloweenViewModel = OpsGameplayHalloweenVM.New()

    ---@type table<RegisterID, table<ClueData>>
    self.ClueDataMap = {}

    --拉取变量列表
    _G.PWorldMgr:SendPullVariableList()
end

function OpsGameplayHalloween:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
    self:RegisterGameEvent(EventID.PWorldVariableDataChange, self.OnGameEventPWorldVariableDataChange)
    self:RegisterGameEvent(EventID.ShowUI, self.OnGameEventUIShow)
end

function OpsGameplayHalloween:OnRegisterTimer()
    self:RegisterTimer(self.OnLateUpdateTeamViewBinder, 0.01) --延迟一帧
end

function OpsGameplayHalloween:OnEnd()
    self.HalloweenViewModel = nil
end

local function GetInteractiveOrder()
    InteractiveOrder = InteractiveOrder - 1
    return InteractiveOrder
end

local function SortByInteractive(Left, Right)
    local O1 = Left.Order or 0
    local O2 = Right.Order or 0
    if O1 == O2 then
        return Left.ID < Right.ID
    end
    return O1 < O2
end

function OpsGameplayHalloween:OnGameEventLoginRes(Params)
    if Params.bReconnect then
        if not CommonUtil.IsShipping() then
            FLOG_INFO("[Halloween] Reconnect")
        end

        --拉取变量列表
        _G.PWorldMgr:SendPullVariableList()
    end
end

function OpsGameplayHalloween:OnGameEventPWorldVariableDataChange(Variables)
    if nil == Variables then
        return
    end
    for _, Param in ipairs(Variables) do
        local ID = Param.ID
        local Value = Param.Value
        local OpsGameplayProgressCfgItem = OpsGameplayProgressCfg:FindCfgByKey(ID)
        if OpsGameplayProgressCfgItem then
            self:UpdateProgress(OpsGameplayProgressCfgItem, Value)
        end

        local ClueCfg = self.ClueCfgMap[ID]
        if ClueCfg then -- 线索的寄存器
            if Value > 0 then
                self:UpdateClueDiscovery(ClueCfg)
            end
        end

        local ClueTruthCfg = self.ClueTruthCfgMap[ID]
        if ClueTruthCfg then -- 线索真假信息
            if Value > 0 then
                self:UpdateClueTruth(ClueTruthCfg)
            end
        end
    end
end

function OpsGameplayHalloween:UpdateProgress(OpsGameplayProgressCfgItem, Val)
    local HalloweenViewModel = self.HalloweenViewModel
    if not HalloweenViewModel then
        FLOG_ERROR("[OpsGameplayHalloween] HalloweenViewModel is nil")
        return
    end

    HalloweenViewModel.Title = OpsGameplayProgressCfgItem.Title
    HalloweenViewModel.TaskDesc = string.format("%s (%s/%s)", OpsGameplayProgressCfgItem.Desc, Val, OpsGameplayProgressCfgItem.Total)

    self:SetBtnInfoAndIconNeedVisable(true)

    local ClueDataList = self.ClueDataMap[OpsGameplayProgressCfgItem.RegisterID]
    if ClueDataList then
        return
    end

    if not self.ClueCfgMap then
        return
    end

    ClueDataList = {}

    local BelongTaskRegisterID = OpsGameplayProgressCfgItem.RegisterID
    for _, Cfg in pairs(self.ClueCfgMap) do
        if Cfg.BelongTaskRegisterID == BelongTaskRegisterID then
            ---@type ClueData
            local ClueData = {}
            ClueData.ID = Cfg.ID
            ClueData.ClueText = Cfg.ClueText
            if Cfg.IsFixedOrder == 1 then
                ClueData.IsFixedOrder = true
                ClueData.Order = 100
            end
            table.insert(ClueDataList, ClueData)
        end
    end

    --[[
    if #ClueDataList > 0 then
        local VaildList = self:SortAndSkipList(ClueDataList, OpsGameplayProgressCfgItem.ClueNum)
        HalloweenViewModel.ClueList:UpdateByValues(VaildList)
        HalloweenViewModel.ClueTitle = _G.LSTR(1560026) --1560026("线索收集")
    else
        HalloweenViewModel.ClueList:Clear()
        HalloweenViewModel.ClueTitle = ""
    end
    ]]

    self.ClueDataMap[OpsGameplayProgressCfgItem.RegisterID] = ClueDataList

    self:UpdateClueListView(BelongTaskRegisterID)
end

function OpsGameplayHalloween:SortAndSkipList(List, Num)
    Num = Num or 0
    table.sort(List, SortByInteractive)
    local Temp = {}
    local MinNum = math.min(#List, Num)
    for i=1, MinNum do
        table.insert(Temp,  List[i])
    end
    return Temp
end

function OpsGameplayHalloween:UpdateClueDiscovery(ClueCfg)
    local ClueDataMap = self.ClueDataMap
    if not ClueDataMap then
        return
    end
    local ClueDataList = ClueDataMap[ClueCfg.BelongTaskRegisterID]
    if not ClueDataList then
        return
    end
    local ClueID = ClueCfg.ID
    for _, ClueData in ipairs(ClueDataList) do
        if ClueData.ID == ClueID then
            ClueData.Discovery = true
            if not ClueData.IsFixedOrder then
                ClueData.Order = GetInteractiveOrder()
            else
                ClueData.Order = ClueCfg.Order
            end
            --self:UpdateClueItemVM(ClueData)
            break
        end
    end
    self:UpdateClueListView(ClueCfg.BelongTaskRegisterID)
end

function OpsGameplayHalloween:UpdateClueTruth(ClueTruthCfg)
    local ClueDataMap = self.ClueDataMap
    if not ClueDataMap then
        return
    end
    local ClueID = ClueTruthCfg.BindClue
    local ClueCfg = SceneClueCfg:FindCfgByKey(ClueID)
    if not ClueCfg then
        return
    end
    local ClueDataList = ClueDataMap[ClueCfg.BelongTaskRegisterID]
    if not ClueDataList then
        return
    end
    for _, ClueData in ipairs(ClueDataList) do
        if ClueData.ID == ClueID then
            ClueData.Truth = ClueTruthCfg.IsTrue == 1
            --self:UpdateClueItemVM(ClueData)
            break
        end
    end
    self:UpdateClueListView(ClueCfg.BelongTaskRegisterID)
end

function OpsGameplayHalloween:RegisterBinders()
    local MainPanelView = _G.UIViewMgr:FindView(UIViewID.MainPanel)
    if MainPanelView then
        local TeamPanelView = MainPanelView.MainTeamPanel
        if TeamPanelView then
            TeamPanelView:SetShowHalloween()
            TeamPanelView:RegisterHalloweenBinder(self.HalloweenViewModel)
            UIUtil.SetIsVisible(TeamPanelView.BtnInfo, false)
            UIUtil.SetIsVisible(TeamPanelView.IconNeed, false)
        end
    end
end

function OpsGameplayHalloween:SetBtnInfoAndIconNeedVisable(IsVisable)
    local MainPanelView = _G.UIViewMgr:FindView(UIViewID.MainPanel)
    if MainPanelView then
        local TeamPanelView = MainPanelView.MainTeamPanel
        if TeamPanelView then
            UIUtil.SetIsVisible(TeamPanelView.BtnInfo, false)
            UIUtil.SetIsVisible(TeamPanelView.IconNeed, IsVisable)
        end
    end
end

function OpsGameplayHalloween:OnLateUpdateTeamViewBinder()
    self:RegisterBinders()
end

function OpsGameplayHalloween:UpdateClueListView(TaskRegisterID)
    local OpsGameplayProgressCfgItem = OpsGameplayProgressCfg:FindCfgByKey(TaskRegisterID)
    if not OpsGameplayProgressCfgItem then
       return
    end
    local HalloweenViewModel = self.HalloweenViewModel
    local ClueDataList = self.ClueDataMap[TaskRegisterID]
    if ClueDataList and #ClueDataList > 0 then
        local VaildList = self:SortAndSkipList(ClueDataList, OpsGameplayProgressCfgItem.ClueNum)
        HalloweenViewModel.ClueList:UpdateByValues(VaildList)
        HalloweenViewModel.ClueTitle = _G.LSTR(1560026) --1560026("线索收集")
    else
        HalloweenViewModel.ClueList:Clear()
        HalloweenViewModel.ClueTitle = ""
    end
end

function OpsGameplayHalloween:UpdateClueItemVM(ClueData)
    local PredicateFun = function(Item)
		return Item.ID == ClueData.ID
	end
    local ClueList = self.HalloweenViewModel.ClueList
    local ItemVM = ClueList:GetItemByPredicate(PredicateFun)
    if ItemVM then
        ItemVM:UpdateVM(ClueData)
    end
    ClueList:Sort(SortByInteractive)
end

function OpsGameplayHalloween:OnGameEventUIShow(InViewID)
    if InViewID == UIViewID.MainPanel then
        self:RegisterBinders()
    end
end

return OpsGameplayHalloween