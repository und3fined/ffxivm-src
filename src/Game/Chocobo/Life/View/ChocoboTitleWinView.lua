---
--- Author: Administrator
--- DateTime: 2023-12-14 10:54
--- Description:
---

local UIUtil = require("Utils/UIUtil")
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView =  require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local ChocoboDefine = require("Game/Chocobo/ChocoboDefine")
local ProtoRes = require("Protocol/ProtoRes")
local ScoreMgr = require("Game/Score/ScoreMgr")

local ChocoboMainVM = nil

---@class ChocoboTitleWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameLView
---@field BtnGet CommBtnSView
---@field BtnGo CommBtnSView
---@field PanelUnFinishAlreadyGet UFCanvasPanel
---@field Reward01 ChocoboWinRewardItemView
---@field Reward02 ChocoboWinRewardItemView
---@field Reward03 ChocoboWinRewardItemView
---@field RichTextDescription URichTextBox
---@field RichTextGetTitle URichTextBox
---@field TableViewNude UTableView
---@field TextContent UFTextBlock
---@field TextUnFinishAlreadyGet UFTextBlock
---@field TreeViewList UFTreeView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboTitleWinView = LuaClass(UIView, true)

function ChocoboTitleWinView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnGet = nil
	--self.BtnGo = nil
	--self.PanelUnFinishAlreadyGet = nil
	--self.Reward01 = nil
	--self.Reward02 = nil
	--self.Reward03 = nil
	--self.RichTextDescription = nil
	--self.RichTextGetTitle = nil
	--self.TableViewNude = nil
	--self.TextContent = nil
	--self.TextUnFinishAlreadyGet = nil
	--self.TreeViewList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboTitleWinView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnGet)
	self:AddSubView(self.BtnGo)
	self:AddSubView(self.Reward01)
	self:AddSubView(self.Reward02)
	self:AddSubView(self.Reward03)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboTitleWinView:OnInit()
    ChocoboMainVM = _G.ChocoboMainVM
    self.TitleNodeAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewNude, nil, nil)
    self.TitleMissionAdapter = UIAdapterTableView.CreateAdapter(self, self.TreeViewList, nil, nil)
    self.TitleNodeAdapter:SetOnSelectChangedCallback(self.OnTitleNodeAdapterChange)
end

function ChocoboTitleWinView:OnDestroy()

end

function ChocoboTitleWinView:OnShow()
    self:InitConstInfo()
    UIUtil.SetIsVisible(self.Reward01, false)
    UIUtil.SetIsVisible(self.Reward02, false)
    UIUtil.SetIsVisible(self.Reward03, true)
    self.ViewModel:UpdateTitleData()
    self.ViewModel:UpdateNode()
    self.ViewModel:UpdateContent()

    self.TitleNodeAdapter:ScrollIndexIntoView(self.ViewModel.SelectNodeIndex)
    self.TitleNodeAdapter:SetSelectedIndex(self.ViewModel.SelectNodeIndex)
end

function ChocoboTitleWinView:InitConstInfo()
    if self.IsInitConstInfo then
        return
    end

    self.IsInitConstInfo = true

    -- LSTR string: 骑士荣誉
    self.Bg:SetTitleText(_G.LSTR(420056))
    -- LSTR string: 当前等级：
    self.RichTextGetTitle:SetText(_G.LSTR(420030))
    -- LSTR string: 升  级
    self.BtnGet:SetText(_G.LSTR(420033))
    -- LSTR string: 未达成
    self.BtnGo:SetText(_G.LSTR(420057))
    -- LSTR string: 已领取
    self.TextUnFinishAlreadyGet:SetText(_G.LSTR(420031))
end

function ChocoboTitleWinView:OnHide()

end

function ChocoboTitleWinView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnGet, self.OnClickBtnGet)
end

function ChocoboTitleWinView:OnRegisterGameEvent()

end

function ChocoboTitleWinView:OnRegisterBinder()
    self.ViewModel = ChocoboMainVM:GetTitlePanelVM()
    local Binders = {
        { "TitleNodeVMList", UIBinderUpdateBindableList.New(self, self.TitleNodeAdapter) },
        { "TitleMissionVMList", UIBinderUpdateBindableList.New(self, self.TitleMissionAdapter) },
        { "TextContent", UIBinderSetText.New(self, self.TextContent) },
        { "TextProgress", UIBinderSetText.New(self, self.RichTextDescription) },
        { "TextNum", UIBinderSetText.New(self, self.Reward03.CommSlot.RichTextNum) },
        { "IsShowNum", UIBinderSetIsVisible.New(self, self.Reward03.CommSlot.RichTextNum) },
        { "IsRewardGet", UIBinderSetIsVisible.New(self, self.Reward03.ImgGet) },
        { "IsShowMask", UIBinderSetIsVisible.New(self, self.Reward03.ImgMask) },
        { "TitleProgressText", UIBinderSetText.New(self, self.RichTextGetTitle) },
        { "CurTitleState", UIBinderValueChangedCallback.New(self, nil, self.OnButtonStateChanged) },
        { "RewardID", UIBinderValueChangedCallback.New(self, nil, self.OnRewardIDChange) },
    }
    self:RegisterBinders(self.ViewModel, Binders)
end

function ChocoboTitleWinView:OnTitleNodeAdapterChange(Index, ItemData, ItemView)
    self.ViewModel:SetSelectNodeIndex(Index)
    self.ViewModel:UpdateContent()
end

function ChocoboTitleWinView:OnRewardIDChange(ResID)
    local ItemCfg = require("TableCfg/ItemCfg")
    local ItemUtil = require("Utils/ItemUtil")
    local Cfg = ItemCfg:FindCfgByKey(ResID)
    local ImgPath = ItemCfg.GetIconPath(Cfg.IconID or 0) or ""
    self.Reward03.CommSlot:SetIconImg(ImgPath)
    self.Reward03.CommSlot:SetQualityImg(ItemUtil.GetItemColorIcon(ResID))
end

function ChocoboTitleWinView:OnButtonStateChanged(NewValue, OldValue)
    if NewValue == ChocoboDefine.TITLE_REWARD_STATE.LAST_NOT_COMPLETED then
        UIUtil.SetIsVisible(self.BtnGet, false)
        UIUtil.SetIsVisible(self.BtnGo, true)
        self.BtnGo:SetIsDisabledState(true, false)
        UIUtil.SetIsVisible(self.PanelUnFinishAlreadyGet, false)
    elseif NewValue == ChocoboDefine.TITLE_REWARD_STATE.GO_ON then
        UIUtil.SetIsVisible(self.BtnGet, false)
        UIUtil.SetIsVisible(self.BtnGo, true)
        self.BtnGo:SetIsDisabledState(true, false)
        UIUtil.SetIsVisible(self.PanelUnFinishAlreadyGet, false)
    elseif NewValue == ChocoboDefine.TITLE_REWARD_STATE.CAN_REWARD then
        UIUtil.SetIsVisible(self.BtnGet, true)
        self.BtnGet:SetIsEnabled(true, true)
        self.BtnGo:SetIsNormalState(false)
        UIUtil.SetIsVisible(self.BtnGo, false)
        UIUtil.SetIsVisible(self.PanelUnFinishAlreadyGet, false)
    elseif NewValue == ChocoboDefine.TITLE_REWARD_STATE.ALREADY_GET then
        UIUtil.SetIsVisible(self.BtnGet, false)
        UIUtil.SetIsVisible(self.BtnGo, false)
        UIUtil.SetIsVisible(self.PanelUnFinishAlreadyGet, true)
    end
end

function ChocoboTitleWinView:OnClickBtnGet()
    _G.ChocoboMgr:ReqGetTitleAward(self.ViewModel.CurSelectTitleID)
end

return ChocoboTitleWinView