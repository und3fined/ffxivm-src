---
--- Author: Administrator
--- DateTime: 2024-10-25 16:00
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local RedDotDefine = require("Game/CommonRedDot/RedDotDefine")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
---@class OpsCommTabChildItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconHourglass UFImage
---@field ImgIcon UFImage
---@field ImgNormal UFImage
---@field ImgSelect UFImage
---@field ImgUnlock UFImage
---@field PanelHot UFCanvasPanel
---@field PanelItem UFCanvasPanel
---@field RedDot CommonRedDotView
---@field SizeBox1 USizeBox
---@field TextHot UFTextBlock
---@field TextName UFTextBlock
---@field AnimCheck UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimUncheck UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsCommTabChildItemView = LuaClass(UIView, true)

function OpsCommTabChildItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconHourglass = nil
	--self.ImgIcon = nil
	--self.ImgNormal = nil
	--self.ImgSelect = nil
	--self.ImgUnlock = nil
	--self.PanelHot = nil
	--self.PanelItem = nil
	--self.RedDot = nil
	--self.SizeBox1 = nil
	--self.TextHot = nil
	--self.TextName = nil
	--self.AnimCheck = nil
	--self.AnimIn = nil
	--self.AnimUncheck = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsCommTabChildItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsCommTabChildItemView:OnInit()
	self.Binders = {
		{ "PageName", UIBinderSetText.New(self, self.TextName) },
		{ "PageNameColor", UIBinderSetColorAndOpacityHex.New(self, self.TextName) },
		{ "HotVisible", UIBinderSetIsVisible.New(self, self.PanelHot) },
		{ "HourglassVisible", UIBinderSetIsVisible.New(self, self.IconHourglass) },
	}
end

function OpsCommTabChildItemView:OnDestroy()

end

function OpsCommTabChildItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	self.RedDot:SetRedDotNameByString(_G.OpsActivityMgr:GetRedDotName(ViewModel.Activity.ClassifyID, ViewModel.ActivityID))
	local FirstRedName = _G.OpsActivityMgr:GetRedDotName(ViewModel.Activity.ClassifyID, ViewModel.ActivityID, "First")
	local FirstRedNode = _G.RedDotMgr:FindRedDotNodeByName(FirstRedName)
	if FirstRedNode then --如果是强提醒
		self.RedDot:SetStyle(RedDotDefine.RedDotStyle.SecondStyle)
	else
		self.RedDot:SetStyle(RedDotDefine.RedDotStyle.NormalStyle)
	end	
end

function OpsCommTabChildItemView:OnHide()

end

function OpsCommTabChildItemView:OnRegisterUIEvent()

end

function OpsCommTabChildItemView:OnRegisterGameEvent()

end

function OpsCommTabChildItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end


	local ViewModel = Params.Data
	self:RegisterBinders(ViewModel, self.Binders)
	self.TextHot:SetText(_G.LSTR(970007))
end


function OpsCommTabChildItemView:OnSelectChanged(IsSelected)
	local Params = self.Params
	if nil == Params then return end
		
	local ViewModel = Params.Data

	self.IsSelected = IsSelected
	UIUtil.SetIsVisible(self.ImgSelect, IsSelected)
	ViewModel.PageNameColor = IsSelected and "#fff4d0" or "#d5d5d5" 

	if IsSelected then
		_G.OpsActivityMgr:RecordRedDotClicked(ViewModel:GetKey(), _G.TimeUtil.GetServerLogicTime())
		self.RedDot:SetStyle(RedDotDefine.RedDotStyle.NormalStyle)
	end
	
end

return OpsCommTabChildItemView