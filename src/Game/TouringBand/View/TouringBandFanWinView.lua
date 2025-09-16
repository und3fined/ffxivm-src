---
--- Author: Administrator
--- DateTime: 2024-07-08 10:32
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class TouringBandFanWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonThroughFrameS_UIBP CommonThroughFrameSView
---@field IconActionUnlock UFImage
---@field IconExteriorUnlock UFImage
---@field IconPetUnlock UFImage
---@field PanelAction UFHorizontalBox
---@field PanelExterior UFHorizontalBox
---@field PanelPet UFHorizontalBox
---@field PopUpBG CommonPopUpBGView
---@field Poster TouringBandPosterItemView
---@field RichText URichTextBox
---@field TextAction UFTextBlock
---@field TextCondition UFTextBlock
---@field TextEPet UFTextBlock
---@field TextExterior UFTextBlock
---@field AnimHide UWidgetAnimation
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TouringBandFanWinView = LuaClass(UIView, true)

function TouringBandFanWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonThroughFrameS_UIBP = nil
	--self.IconActionUnlock = nil
	--self.IconExteriorUnlock = nil
	--self.IconPetUnlock = nil
	--self.PanelAction = nil
	--self.PanelExterior = nil
	--self.PanelPet = nil
	--self.PopUpBG = nil
	--self.Poster = nil
	--self.RichText = nil
	--self.TextAction = nil
	--self.TextCondition = nil
	--self.TextEPet = nil
	--self.TextExterior = nil
	--self.AnimHide = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TouringBandFanWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonThroughFrameS_UIBP)
	self:AddSubView(self.PopUpBG)
	self:AddSubView(self.Poster)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TouringBandFanWinView:OnInit()
end

function TouringBandFanWinView:OnDestroy()

end

function TouringBandFanWinView:OnShow()
	-- LSTR string: 成为粉丝
	self.CommonThroughFrameS_UIBP.TextTitle:SetText(_G.LSTR(450007))
	-- LSTR string: 达成互动条件：
	self.TextCondition:SetText(_G.LSTR(450008))
	-- LSTR string: 关  闭
	self.CommonThroughFrameS_UIBP.BtnClose2:SetBtnName(_G.LSTR(450009))
	-- LSTR string: 查  看
	self.CommonThroughFrameS_UIBP.BtnCheck2:SetBtnName(_G.LSTR(450010))
end

function TouringBandFanWinView:OnHide()
	UIUtil.SetIsVisible(self.CommonThroughFrameS_UIBP, false)
end

function TouringBandFanWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.CommonThroughFrameS_UIBP.BtnClose2, self.OnBtnCloseClicked)
	UIUtil.AddOnClickedEvent(self, self.CommonThroughFrameS_UIBP.BtnCheck2, self.OnBtnCheckClicked)
end

function TouringBandFanWinView:OnRegisterGameEvent()

end

function TouringBandFanWinView:OnRegisterBinder()
	self.ViewModel = _G.TouringBandMgr:GetFanWinVM()
	local Binders = {
		{ "TextContent", UIBinderSetText.New(self, self.RichText) },
		{ "TextExterior", UIBinderSetText.New(self, self.TextExterior) },
		{ "TextEPet", UIBinderSetText.New(self, self.TextEPet) },
		{ "TextAction", UIBinderSetText.New(self, self.TextAction) },
		{ "IsShowExterior", UIBinderSetIsVisible.New(self, self.PanelExterior) },
		{ "IsShowEPet", UIBinderSetIsVisible.New(self, self.PanelPet) },
		{ "IsShowAction", UIBinderSetIsVisible.New(self, self.PanelAction) },
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

function TouringBandFanWinView:OnBtnCloseClicked()
	self:Hide()
end

function TouringBandFanWinView:OnBtnCheckClicked()
	_G.TouringBandMgr:OpenTouringBandView()
	self:Hide()
end

function TouringBandFanWinView:PlayAnimIn()
	self.Poster:PlayPosterAnim()
	self:PlayAnimation(self.AnimIn)
	self:RegisterTimer(self.PlayAnimInNext, 2.2)
end

function TouringBandFanWinView:PlayAnimInNext()
	local AudioUtil = require("Utils/AudioUtil")
	AudioUtil.LoadAndPlayUISound("AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/New/Play_UI_Band_Badge_Generator_pop.Play_UI_Band_Badge_Generator_pop'")
	UIUtil.SetIsVisible(self.CommonThroughFrameS_UIBP, true)
	UIUtil.SetIsVisible(self.PopUpBG, false)
end

return TouringBandFanWinView