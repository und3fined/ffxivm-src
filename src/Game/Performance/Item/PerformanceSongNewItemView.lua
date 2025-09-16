---
--- Author: moodliu
--- DateTime: 2024-04-30 15:38
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback =  require("Binder/UIBinderValueChangedCallback")
local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")


---@class PerformanceSongNewItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgNormalBg UFImage
---@field ImgNoteNormal UFImage
---@field ImgSelect UFImage
---@field PanelNoteLight UFCanvasPanel
---@field RedDot2 CommonRedDot2View
---@field TextName UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimNoteLightLoop UWidgetAnimation
---@field AnimNoteLightStop UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PerformanceSongNewItemView = LuaClass(UIView, true)


local TextColor =
{
	Default = "c8c3c3",
	Selected = "fff4d0",
}

function PerformanceSongNewItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgNormalBg = nil
	--self.ImgNoteNormal = nil
	--self.ImgSelect = nil
	--self.PanelNoteLight = nil
	--self.RedDot2 = nil
	--self.TextName = nil
	--self.AnimIn = nil
	--self.AnimNoteLightLoop = nil
	--self.AnimNoteLightStop = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.RedDotName = nil
end

function PerformanceSongNewItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PerformanceSongNewItemView:OnInit()
end

function PerformanceSongNewItemView:OnDestroy()

end

function PerformanceSongNewItemView:OnShow()
	if self.Params.Data and self.Params.Data.Cfg then
		self.VM.TextName = self.Params.Data.Cfg.Name

		self.RedDotName = string.format("Root/Performance/%s", self.Params.Data.Cfg.Name)
		self.RedDot2:SetRedDotNameByString(self.RedDotName)
	end
end

function PerformanceSongNewItemView:OnHide()

end

function PerformanceSongNewItemView:OnRegisterUIEvent()
	--UIUtil.AddOnClickedEvent(self, self.BtnClick, self.OnBtnClick)
end

function PerformanceSongNewItemView:OnRegisterGameEvent()

end

function PerformanceSongNewItemView:OnRegisterBinder()
	self.VM = self.Params.Data and self.Params.Data.VM
	local Binders = {
		{ "TextName", UIBinderSetText.New(self, self.TextName) },
		{ "ImgSelectVisible", UIBinderSetIsVisible.New(self, self.ImgSelect, false, true) },
		{ "IsSelected", UIBinderValueChangedCallback.New(self, nil, self.SetSelected) },
	}

	self:RegisterBinders(self.VM, Binders)
end

function PerformanceSongNewItemView:SetSelected(bSelected, IsByClick)
	--策划需求只要点击就消红点，各选中无关
	if IsByClick then
		RedDotMgr:DelRedDotByName(self.RedDotName)
	end

	if self.VM.ImgSelectVisible ~= bSelected then
		self.VM.ImgSelectVisible = bSelected
		if bSelected then
			self:PlayAnimation(self.AnimNoteLightLoop, 0, 0)
			UIUtil.SetColorAndOpacityHex(self.TextName, TextColor.Selected)
		else
			self:StopAnimation(self.AnimNoteLightLoop)
			self:PlayAnimation(self.AnimNoteLightStop)
			UIUtil.SetColorAndOpacityHex(self.TextName, TextColor.Default)
		end
	end
end

function PerformanceSongNewItemView:OnSelectChanged(IsSelected, IsByClick)
	self:SetSelected(IsSelected, IsByClick)
end

return PerformanceSongNewItemView