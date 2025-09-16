---
--- Author: skysong
--- DateTime: 2023-12-11 15:33
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MainPanelVM = require("Game/Main/MainPanelVM")
local MainPanelConfig = require("Game/Main/MainPanelConfig")
local MajorUtil = require("Utils/MajorUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local EventID = require("Define/EventID")
local TimeUtil = require("Utils/TimeUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local PWorldStagePanelVM = require("Game/PWorld/Warning/PWorldStagePanelVM")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local LocalizationUtil = require("Utils/LocalizationUtil")
local PWorldHelper = require("Game/PWorld/PWorldHelper")

---@class PWorldStagePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnFold UToggleButton
---@field BtnQuestMenu UFButton
---@field BtnSwitch UFButton
---@field CommTextSlide CommTextSlideView
---@field ImgDown UFImage
---@field ImgPWorldType UFImage
---@field ImgProBarBG UFImage
---@field ImgUp UFImage
---@field PanelBoss UFCanvasPanel
---@field PanelPWorld UFCanvasPanel
---@field PanelProbar UFCanvasPanel
---@field PanelQuestProBar UFCanvasPanel
---@field PanelStageInfo UFCanvasPanel
---@field PanelTitle UFCanvasPanel
---@field ProBar UProgressBar
---@field TableViewSkillCD UTableView
---@field TextSlide CommTextSlideView
---@field TextSwitch UFTextBlock
---@field TextTime UFTextBlock
---@field AnimChangeContent UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimMissionPartSuccess UWidgetAnimation
---@field AnimUnfold UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldStagePanelView = LuaClass(UIView, true)

local PWorldWarringMgr = _G.PWorldWarningMgr

local ProgressBarColor = {
    "FFBEC0FF","fff9b2FF"
}

local ProgressBarBG =
{
    IconNormal = "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Team_Probar_Normal02_png.UI_Main_Team_Probar_Normal02_png'",
    IconDanger = "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main_Team_Probar_Danger_png.UI_Main_Team_Probar_Danger_png'",
}
function PWorldStagePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnFold = nil
	--self.BtnQuestMenu = nil
	--self.BtnSwitch = nil
	--self.CommTextSlide = nil
	--self.ImgDown = nil
	--self.ImgPWorldType = nil
	--self.ImgProBarBG = nil
	--self.ImgUp = nil
	--self.PanelBoss = nil
	--self.PanelPWorld = nil
	--self.PanelProbar = nil
	--self.PanelQuestProBar = nil
	--self.PanelStageInfo = nil
	--self.PanelTitle = nil
	--self.ProBar = nil
	--self.TableViewSkillCD = nil
	--self.TextSlide = nil
	--self.TextSwitch = nil
	--self.TextTime = nil
	--self.AnimChangeContent = nil
	--self.AnimIn = nil
	--self.AnimMissionPartSuccess = nil
	--self.AnimUnfold = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldStagePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommTextSlide)
	self:AddSubView(self.TextSlide)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldStagePanelView:OnInit()
    self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSkillCD, nil, false)
    self.Binders = {
        {"WarningSkillCDItemList", UIBinderUpdateBindableList.New(self, self.TableViewAdapter)},
        {"bToggleCheck", UIBinderSetIsVisible.New(self, self.PanelPWorld, true)},
        {"bToggleCheck", UIBinderSetIsVisible.New(self, self.BtnSwitch, true)},
        {"bToggleCheck", UIBinderValueChangedCallback.New(self, nil, function(_, V)
            V = V or false
            self.BtnFold:SetCheckedState(V and _G.UE.EToggleButtonState.Checked or _G.UE.EToggleButtonState.Unchecked)
            if V then
                self:PlayAnimation(self.AnimUnfold)
            end
            MainPanelVM:SetFunctionVisible(V, MainPanelConfig.TopRightInfoType.PWorldStage)
        end)},
        {"PWorldIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgPWorldType)},
		{ "SettingVisible", UIBinderSetIsVisible.New(self, self.BtnQuestMenu, false, true)},
        -- {"SettingVisible", UIBinderValueChangedCallback.New(self, nil, function (_, V, OldV)
        --     -- #TODO DELETE WHEN BUG IS FIXED
        --     print(string.sformat("TRACE-SettingVisible %s<-%s, ispworld:%s, pworldid:%s, trace: %s", V,OldV, 
        --          _G.PWorldMgr:CurrIsInDungeon(),_G.PWorldMgr:GetCurrPWorldResID(), debug.traceback()))
        -- end)}
    }
    self.CurrMapResID = nil
end

function PWorldStagePanelView:OnShow()
    PWorldStagePanelVM:Clear()
    self:UpdateStageInfo()

    -- UIUtil.SetIsVisible(self.PanelQuestProBar, true)

    -- check state
    PWorldStagePanelVM.bToggleCheck = nil
    PWorldStagePanelVM.bToggleCheck = false

    if _G.PWorldMgr.BaseInfo ~= nil then
        if _G.PWorldMgr.BaseInfo.MapCountDownTime > 0 then
            self:OnPWorldMapEndTimeSwitch()
        end
    end
end

function PWorldStagePanelView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnQuestMenu, function()
        _G.PWorldQuestMgr:ShowPWQuestView()
    end)

    UIUtil.AddOnClickedEvent(self,self.BtnSwitch,function()
        -- nothing now
    end)

    UIUtil.AddOnClickedEvent(self, self.BtnFold, self.OnToggleBtnFold)
end

function PWorldStagePanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.PWorldStageInfoUpdate, self.UpdateStageInfo)
    self:RegisterGameEvent(EventID.NetStateUpdate, self.OnNetStateUpdate)
    --self:RegisterGameEvent(EventID.PWorldWarningDuring, self.OnPWorldWarningDuring)
    --self:RegisterGameEvent(EventID.PWorldWarningEnd, self.OnPWorldWarningEnd)
    self:RegisterGameEvent(EventID.PWorldMapEndTimeSwitch, self.OnPWorldMapEndTimeSwitch)
    self:RegisterGameEvent(EventID.SelectMainStageButtonSwitch, self.OnSelectMainStageButtonSwitch)
end

function PWorldStagePanelView:OnRegisterBinder()
    self:RegisterBinders(PWorldStagePanelVM, self.Binders)
end

function PWorldStagePanelView:OnPWorldWarningDuring(Params)
    local AttrComp = MajorUtil.GetMajorAttributeComponent()
    ---_G.FLOG_INFO("kof PWorldStagePanelView:OnPWorldWarningDuring")


    if AttrComp ~= nil then
        local EarlyWarningItems = PWorldWarringMgr:GetWarningItems(AttrComp:GetClassType())
        if #EarlyWarningItems == 0 then
            self:OnPWorldWarningEnd()
        else
            self.TableViewSkillCD:SetVisibility(_G.UE.ESlateVisibility.Visible)

            local ServerTime = TimeUtil.GetServerTimeMS()
            local StartTime = PWorldWarringMgr:GetStartTime()
            local ShowEarlyWaringItems = {}

            for _,WarningItem in pairs(EarlyWarningItems) do
                local fRemainTime = (StartTime + (WarningItem.StartTime + WarningItem.LastTime) * 1000 - ServerTime) / 1000.0
                fRemainTime = (fRemainTime - fRemainTime%0.1)
                local fPercent = fRemainTime / WarningItem.LastTime
                table.insert(ShowEarlyWaringItems,{IconID=WarningItem.Param,Percent=fPercent,RemainTime=fRemainTime,Name=WarningItem.Name,MultilingualID=WarningItem.MultilingualID})
            end
            PWorldStagePanelVM:UpdateWaringItems(ShowEarlyWaringItems)
            for _,v in pairs(ShowEarlyWaringItems) do
                local WarningSkillCDItemVM = PWorldStagePanelVM.WarningSkillCDItemList:Get(_)
                if WarningSkillCDItemVM ~= nil then
                    WarningSkillCDItemVM:UpdateVM(v)
                end
            end
        end
    end
end

function PWorldStagePanelView:OnPWorldWarningEnd(Params)
    PWorldStagePanelVM:Clear()
    self.TableViewSkillCD:SetVisibility(_G.UE.ESlateVisibility.Collapsed)
end

function PWorldStagePanelView:OnNetStateUpdate(Params)
    local EntityID = Params.ULongParam1
    if not MajorUtil.IsMajor(EntityID) then
        return
    end

    local StateType = Params.IntParam1
    if StateType ~= ProtoCommon.CommStatID.COMM_STAT_COMBAT then
        return
    end
end

function PWorldStagePanelView:OnToggleBtnFold()
    PWorldStagePanelVM:Toggle()
end

function PWorldStagePanelView:UpdateStageInfo()
    local StageInfoList = _G.PWorldStageMgr.StageInfoList
    local CurrStage = _G.PWorldStageMgr.CurrStage
    local CurrProcess = _G.PWorldStageMgr.CurrProcess

    local CurrMapTableCfg = _G.PWorldMgr:GetCurrMapTableCfg()
    if (CurrMapTableCfg) then
        self.TextSlide:ShowSliderText(CurrMapTableCfg.DisplayName)
    else
        self.TextSlide:ShowSliderText(LSTR(50007))
    end

    PWorldStagePanelVM:UpdateStatus()

    local CurrMapResID = _G.PWorldMgr:GetCurrMapResID()
    --副本ID没变的话就不去控制PanelProbar的显隐
    if self.CurrMapResID ~= CurrMapResID then
        UIUtil.SetIsVisible(self.PanelProbar, false)
        self.CurrMapResID = CurrMapResID
    end

    -- StageInfoList为nil,副本进度表没有填
    if StageInfoList ~= nil and StageInfoList[CurrStage] ~= nil then
        UIUtil.SetIsVisible(self.PanelQuestProBar, true)
        local StateText = StageInfoList[CurrStage].Text
        local MaxProgress = StageInfoList[CurrStage].MaxProgress
        if type(StateText) == 'string' and #StateText > 0 then
            self.CommTextSlide:ShowSliderText(string.sformat("%s: %d/%d", StateText, CurrProcess,MaxProgress), nil)
        else
            self.CommTextSlide:ShowSliderText(PWorldHelper.pformat("PWORD_STAGE_DEFAULT", CurrProcess,MaxProgress), nil)
        end
    else
        UIUtil.SetIsVisible(self.PanelQuestProBar, false)
    end
end

function PWorldStagePanelView:OnRegisterTimer()
    self.TimerIDNormal = self:RegisterTimer(self.UpdateLeftTime, 0, 1, 0)
end

function PWorldStagePanelView:UpdateLeftTime()
    local LeftTimeStr = LocalizationUtil.GetCountdownTimeForShortTime(math.max(_G.PWorldMgr.BaseInfo.EndTime - _G.TimeUtil.GetServerTime(), 0), "mm:ss") or ""
    self.TextTime:SetText(LeftTimeStr)
end

function PWorldStagePanelView:OnPWorldMapEndTimeSwitch()
    --值为0的话是要还原为本来的副本倒计时
    if(_G.PWorldMgr.BaseInfo.MapCountDownTime == 0) then
        self:UnRegisterTimer(self.TimerIDNormal)
        self.TimerIDNormal = self:RegisterTimer(self.UpdateLeftTime, 0, 1, 0)
    else
        self:UnRegisterTimer(self.TimerIDNormal)
        self.TimerIDNormal = nil
        self:UnRegisterTimer(self.TimerIDCountDown)
        self.TimerIDCountDown = self:RegisterTimer(self.UpdateEndTime, 0, 1, 0)
    end
end

function PWorldStagePanelView:UpdateEndTime()
    local LeftTimeStr = LocalizationUtil.GetCountdownTimeForShortTime(math.max(_G.PWorldMgr.BaseInfo.MapCountDownTime - _G.TimeUtil.GetServerTime(), 0), "mm:ss") or ""
    self.TextTime:SetText(LeftTimeStr)
end

function PWorldStagePanelView:OnSelectMainStageButtonSwitch()
    PWorldStagePanelVM.bToggleCheck = true
end

function PWorldStagePanelView:OnBattleProgressSlot(Name,CurValue,MaxValue)
    UIUtil.SetIsVisible(self.PanelProbar, true)
    local ResultString = Name.. CurValue .. "/" .. MaxValue
    self.TextSwitch:SetText(ResultString)

    local Progress = CurValue / MaxValue
    self.ProBar:SetPercent(Progress)

    if CurValue <= 30 then
        UIUtil.ImageSetBrushFromAssetPath(self.ImgProBarBG, ProgressBarBG.IconDanger)
        _G.UE.UUIUtil.SetBrushTintColorHex(self.ProBar.WidgetStyle.FillImage, ProgressBarColor[1])
    else
        UIUtil.ImageSetBrushFromAssetPath(self.ImgProBarBG, ProgressBarBG.IconNormal)
        _G.UE.UUIUtil.SetBrushTintColorHex(self.ProBar.WidgetStyle.FillImage, ProgressBarColor[2])
    end
end

return PWorldStagePanelView