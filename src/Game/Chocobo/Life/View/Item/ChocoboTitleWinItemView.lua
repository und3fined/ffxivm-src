---
--- Author: Administrator
--- DateTime: 2023-12-14 15:18
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ChocoboDefine = require("Game/Chocobo/ChocoboDefine")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local ProtoRes = require("Protocol/ProtoRes")
local ScoreMgr = require("Game/Score/ScoreMgr")

---@class ChocoboTitleWinItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGet CommBtnSView
---@field BtnGo CommBtnSView
---@field ImgIcon UFImage
---@field PanelUnFinishAlreadyGet UFCanvasPanel
---@field Reward01 ChocoboWinRewardItemView
---@field Reward02 ChocoboWinRewardItemView
---@field Reward03 ChocoboWinRewardItemView
---@field RichTextDescription URichTextBox
---@field TextContent UFTextBlock
---@field TextUnFinishAlreadyGet UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboTitleWinItemView = LuaClass(UIView, true)

function ChocoboTitleWinItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.BtnGet = nil
    --self.BtnGo = nil
    --self.ImgIcon = nil
    --self.PanelUnFinishAlreadyGet = nil
    --self.Reward01 = nil
    --self.Reward02 = nil
    --self.Reward03 = nil
    --self.RichTextDescription = nil
    --self.TextContent = nil
    --self.TextUnFinishAlreadyGet = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboTitleWinItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.BtnGet)
    self:AddSubView(self.BtnGo)
    self:AddSubView(self.Reward01)
    self:AddSubView(self.Reward02)
    self:AddSubView(self.Reward03)
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboTitleWinItemView:OnInit()

end

function ChocoboTitleWinItemView:OnDestroy()

end

function ChocoboTitleWinItemView:OnShow()
    self.Reward03.CommSlot:SetIconImg(ScoreMgr:GetScoreIconName(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE))
    UIUtil.SetIsVisible(self.Reward01, false)
    UIUtil.SetIsVisible(self.Reward02, false)
    UIUtil.SetIsVisible(self.Reward03, true)

    -- LSTR string: 升  级
    self.BtnGet:SetText(_G.LSTR(420033))
    -- LSTR string: 前  往
    self.BtnGo:SetText(_G.LSTR(420032))
    -- LSTR string: 已领取
    self.TextUnFinishAlreadyGet:SetText(_G.LSTR(420031))
end

function ChocoboTitleWinItemView:OnHide()

end

function ChocoboTitleWinItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnGet, self.OnClickBtnGet)
    UIUtil.AddOnClickedEvent(self, self.BtnGo, self.OnClickBtnGo)
end

function ChocoboTitleWinItemView:OnRegisterBinder()
    local Params = self.Params
    if nil == Params then
        return
    end

    local Data = Params.Data
    if nil == Data then
        return
    end

    local ViewModel = Data
    self.VM = ViewModel

    local Binders = {
        { "IconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
        { "TextContent", UIBinderSetText.New(self, self.TextContent) },
        { "TextProgress", UIBinderSetText.New(self, self.RichTextDescription) },
        { "TextNum", UIBinderSetText.New(self, self.Reward03.CommSlot.RichTextNum) },
        { "IsShowNum", UIBinderSetIsVisible.New(self, self.Reward03.CommSlot.RichTextNum) },
        { "IsRewardGet", UIBinderSetIsVisible.New(self, self.Reward03.ImgGet) },
        { "IsShowMask", UIBinderSetIsVisible.New(self, self.Reward03.ImgMask) },
        { "ButtonState", UIBinderValueChangedCallback.New(self, nil, self.OnButtonStateChanged) },
    }
    self:RegisterBinders(ViewModel, Binders)
end

function ChocoboTitleWinItemView:OnButtonStateChanged(NewValue, OldValue)
    if NewValue == ChocoboDefine.TITLE_REWARD_STATE.GO_ON then
        UIUtil.SetIsVisible(self.BtnGet, false)
        UIUtil.SetIsVisible(self.BtnGo, true)
        self.BtnGo:SetIsDisabledState(true, false)
        UIUtil.SetIsVisible(self.PanelUnFinishAlreadyGet, false)
    elseif NewValue == ChocoboDefine.TITLE_REWARD_STATE.CAN_REWARD then
        UIUtil.SetIsVisible(self.BtnGet, true)
        self.BtnGet:SetIsNormalState(false)
        UIUtil.SetIsVisible(self.BtnGo, false)
        UIUtil.SetIsVisible(self.PanelUnFinishAlreadyGet, false)
    elseif NewValue == ChocoboDefine.TITLE_REWARD_STATE.ALREADY_GET then
        UIUtil.SetIsVisible(self.BtnGet, false)
        UIUtil.SetIsVisible(self.BtnGo, false)
        UIUtil.SetIsVisible(self.PanelUnFinishAlreadyGet, true)
    end
end

function ChocoboTitleWinItemView:OnClickBtnGet()
    local Title = self.VM.ID
    local Mission = self.VM.Index - 1
    _G.ChocoboMgr:ReqGetMissionAward(Title, Mission)
end

function ChocoboTitleWinItemView:OnClickBtnGo()
    if self.VM == nil then
        return
    end
    
    local MissionType = self.VM.Type
    local MISSIONS = ProtoRes.CHOCOBO_MISSION_TYPE
    if MissionType == MISSIONS.CHOCOBO_MISSION_TYPE_RACE_PARTICIPATE or
            MissionType == MISSIONS.CHOCOBO_MISSION_TYPE_RACE_WIN or
            MissionType == MISSIONS.CHOCOBO_MISSION_TYPE_RACE_FIRST_PLACE then
        _G.ChocoboMgr:OpenChocoboMatchPanel()
    elseif MissionType == MISSIONS.CHOCOBO_MISSION_TYPE_OWN_LEVEL or
            MissionType == MISSIONS.CHOCOBO_MISSION_TYPE_OWN_GENERATION or
            MissionType == MISSIONS.CHOCOBO_MISSION_TYPE_OWN_STAR then
        if _G.UIViewMgr:IsViewVisible(_G.UIViewID.ChocoboTitleWinView) then
            _G.UIViewMgr:HideView(_G.UIViewID.ChocoboTitleWinView)
        end
    elseif MissionType == MISSIONS.CHOCOBO_MISSION_TYPE_COLLECT_SKILLS then
        if _G.UIViewMgr:IsViewVisible(_G.UIViewID.ChocoboMainPanelView) then
            local View = _G.UIViewMgr:FindView(_G.UIViewID.ChocoboMainPanelView)
            if View then
                View:ChangePage(ChocoboDefine.PAGE_INDEX.SKILL_PAGE)
            end
        end
        if _G.UIViewMgr:IsViewVisible(_G.UIViewID.ChocoboTitleWinView) then
            _G.UIViewMgr:HideView(_G.UIViewID.ChocoboTitleWinView)
        end
    elseif MissionType == MISSIONS.CHOCOBO_MISSION_TYPE_COLLECT_ARMOR_PARTS or
            MissionType == MISSIONS.CHOCOBO_MISSION_TYPE_COMPLETE_ARMOR_SETS then
        _G.ChocoboCodexArmorMgr:OpenChocoboCodexArmorPanel()
    end
end

return ChocoboTitleWinItemView