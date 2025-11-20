local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MgrBase = require("Common/MgrBase")
local WidgetPoolMgr = require("UI/WidgetPoolMgr")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local MainPanelViewID = UIViewID.MainPanel

local EventID = _G.EventID
local SkillHandleMainUIBPPath = "MainSkillHandle/SkillHandleMain_UIBP"
local SkillMainUIBPPath = "MainSkillBtn/NewMainSkill_UIBP"
local ObjectGCType = require("Define/ObjectGCType")
local SettingsHandleDefine = require("Game/Settings/SettingsHandleDefine")

local HandleModeType = SettingsHandleDefine.HandleModeType
local HandleCustomActionType <const> = SettingsHandleDefine.HandleCustomActionType
local InValidInputAction <const> = SettingsHandleDefine.InValidInputAction

local Margin = UE.FMargin()
Margin.Left = 0
Margin.Top = 0
Margin.Right = 0
Margin.Bottom = 0

local Anchor = UE.FAnchors()
Anchor.Minimum = UE.FVector2D(0, 0)
Anchor.Maximum = UE.FVector2D(1, 1)

local SkillMode = {
    None = 0,
    Handle = 1,
    Normal = 2,
}


---@class SkillHandleMgr : MgrBase
local SkillHandleMgr = LuaClass(MgrBase)
function SkillHandleMgr:OnInit()
    rawset(self, "SkillMode", SkillMode.None)
    self.SkillMode = SkillMode
    self.GatherDrugSkillPanelVM = nil
    self.FunctionSkillInputAction = nil
end

function SkillHandleMgr:OnBegin()

end

function SkillHandleMgr:OnEnd()
end

function SkillHandleMgr:OnShutdown()

end

function SkillHandleMgr:OnRegisterNetMsg()
	
end

function SkillHandleMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MainPanelShow, self.OnMainPanelShow)
    self:RegisterGameEvent(EventID.GameHandleMode, self.OnGameHandleModeMotify)
	self:RegisterGameEvent(EventID.OnUpdateHandleCusAction, self.OnUpdateHandleCusAction)
    self:RegisterGameEvent(EventID.OnResetHandleCusAction, self.OnResetHandleCusAction)
end

function SkillHandleMgr:IsInHandleMode()
    return rawget(self, "SkillMode") == SkillMode.Handle
end

local function InitSkillMainView(ParentView, Slot, View)
    local LastView = Slot:GetChildAt(0)
    if LastView then
        WidgetPoolMgr:RecycleWidget(LastView)
    end

    Slot:ClearChildren()
    Slot:AddChildToCanvas(View)
    ParentView:AddSubView(View)
    UIUtil.CanvasSlotSetAnchors(View, Anchor)
    UIUtil.CanvasSlotSetOffsets(View, Margin)
    View:InitView()
    View:LoadView()

    if ParentView:IsVisible() then
        local MajorLogicData = _G.SkillLogicMgr.MajorLogicData
        View:OnEntityIDUpdate(MajorLogicData.EntityID, true, MajorLogicData:GetMapType())
        View:ShowView(nil, false)
    end 
end

function SkillHandleMgr:OnEnterHandleMode()
    local ParentView, Slot = self:GetParentPanelAndSlot()
    if ParentView then
        rawset(self, "bRequestEnterHandle", false)
        local SkillHandleMainView = WidgetPoolMgr:CreateWidgetSyncByName(SkillHandleMainUIBPPath, ObjectGCType.NoCache, false, false)
        if SkillHandleMainView then
            InitSkillMainView(ParentView, Slot, SkillHandleMainView)
            ParentView:OnExecuteHandleMode(true)
        else
            FLOG_ERROR("SkillHandlePanel load failed")
        end
    else
        rawset(self, "bRequestEnterHandle", true)
    end
    rawset(self, "SkillMode", SkillMode.Handle)
end

function SkillHandleMgr:OnExitHandleMode()
    local ParentView, Slot = self:GetParentPanelAndSlot()
    if ParentView then
        rawset(self, "bRequestExitHandle", false)
        local SkillMainView = WidgetPoolMgr:CreateWidgetSyncByName(SkillMainUIBPPath, ObjectGCType.NoCache, false, false)
        if SkillMainView then
            InitSkillMainView(ParentView, Slot, SkillMainView)
            --加个自动收起轮盘
            ParentView:OnExecuteHandleMode(false)
        else
            FLOG_ERROR("SkillMainPanel load failed")
        end
    else
        rawset(self, "bRequestExitHandle", true)
    end
    rawset(self, "SkillMode", SkillMode.Normal)
end

-- 手动创建pvp界面的
function SkillHandleMgr:InitPVPSkillMainView()
    --local _, Slot = self:GetPVPParentPanelAndSlot()
    -- local LastView = Slot:GetChildAt(0)
    -- if LastView then
    --     -- 已有技能面板，不执行重复创建逻辑
    --     return
    -- end
    local Mode = rawget(self, "SkillMode")
    if Mode == SkillMode.Handle then
        self:OnEnterHandleMode()
    elseif Mode == SkillMode.Normal then
        self:OnExitHandleMode()
    end
end

function SkillHandleMgr:OnHandleModeChanged(IsHandleMode)
    if IsHandleMode and rawget(self, "SkillMode") ~= SkillMode.Handle then
        self:OnEnterHandleMode()
    elseif not IsHandleMode and rawget(self, "SkillMode") ~= SkillMode.Normal then
        self:OnExitHandleMode()
    end
end

function SkillHandleMgr:OnGameHandleModeMotify(InHandleModeType)
    if InHandleModeType == HandleModeType.On and rawget(self, "SkillMode") ~= SkillMode.Handle then
        self:OnEnterHandleMode()
    elseif InHandleModeType == HandleModeType.Off and rawget(self, "SkillMode") ~= SkillMode.Normal then
        self:OnExitHandleMode()
    end
    --更新UI
    if self.GatherDrugSkillPanelVM then
       self.GatherDrugSkillPanelVM:UpdateSkillDrugPosition()
    end
    --捕鱼人UI
    _G.FishMgr:ShowFishBtnSit(self.IsInFishingState)
end

function SkillHandleMgr:OnMainPanelShow(Params)
    if Params.bShow == true then
        local Mode = rawget(self, "SkillMode")
        if Mode == SkillMode.None then
            FLOG_ERROR("SkillMode is None when show MainPanel")
            return
        end

        if Mode == SkillMode.Handle and rawget(self, "bRequestEnterHandle") then
            self:OnEnterHandleMode()
        elseif Mode == SkillMode.Normal and rawget(self, "bRequestExitHandle") then
            self:OnExitHandleMode()
        end
    end
end

function SkillHandleMgr:GetParentPanelAndSlot()
    if _G.PWorldMgr:CurrIsInPVPColosseum() then
       return self:GetPVPParentPanelAndSlot()
    end
    local MainPanelView = UIViewMgr:FindVisibleView(MainPanelViewID)
    if MainPanelView then
        local ParentPanel = MainPanelView.ControlPanel
        local Slot = ParentPanel.SkillPanelSlot
        return ParentPanel, Slot
    end
    return
end

function SkillHandleMgr:GetPVPParentPanelAndSlot()
    local MainPanelView = UIViewMgr:FindVisibleView(UIViewID.PVPColosseumMain)
    if MainPanelView then
        local ParentPanel = MainPanelView.MainControlPanel
        local Slot = ParentPanel.SkillPanelSlot
        return ParentPanel, Slot
    end
    return
end

function SkillHandleMgr:OnUpdateHandleCusAction(Params)
    if Params.CusActionIndex == HandleCustomActionType.FunctionSkill then
        --未初始化时存下职能技的InputAction
        self.FunctionSkillInputAction = Params.SaveKey
        if self.GatherDrugSkillPanelVM then
            self.GatherDrugSkillPanelVM.CurInputAction = Params.SaveKey
        end
    elseif self.FunctionSkillInputAction and self.FunctionSkillInputAction == Params.SaveKey then
        if Params.CusActionIndex == HandleCustomActionType.SkillEmpty then
            self.FunctionSkillInputAction = InValidInputAction
            if self.GatherDrugSkillPanelVM then
                self.GatherDrugSkillPanelVM.CurInputAction = InValidInputAction
            end
        end
    end
end

function SkillHandleMgr:OnResetHandleCusAction(Param)
    if Param == SettingsHandleDefine.HandleMainType.SkillType then
        self.FunctionSkillInputAction = _G.SettingsHandleMgr:GetHandleInputActionByCusAction(HandleCustomActionType.FunctionSkill)
        if nil == self.FunctionSkillInputAction then
            self.FunctionSkillInputAction = InValidInputAction
        end
        if self.GatherDrugSkillPanelVM then
            self.GatherDrugSkillPanelVM.CurInputAction = self.FunctionSkillInputAction
        end
    end
end

function SkillHandleMgr:ChangeHandleSpeedSkillFunc(IsInFishingState)
    if IsInFishingState then
        self.IsInFishingState = true
    else
        self.IsInFishingState = false
    end
    if self:IsInHandleMode() then
        _G.EventMgr:SendEvent(EventID.ChangeHandleSpeedSkillFunc, IsInFishingState)
    end
end

function SkillHandleMgr:GetIsInFishingState()
    return self.IsInFishingState
end

return SkillHandleMgr