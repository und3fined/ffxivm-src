---
--- Author: sammrli
--- DateTime: 2024-02-13 16:37
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local EventID = require("Define/EventID")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require ("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class TravelLogTaksItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn1 UFButton
---@field Btn2 UFButton
---@field CommonRedDot2_UIBP CommonRedDot2View
---@field CommonRedDot2_UIBP_61 CommonRedDot2View
---@field IconPrefixFocus1 UFImage
---@field IconPrefixFocus_1 UFImage
---@field IconPrefixNormal1 UFImage
---@field IconPrefixNormal_1 UFImage
---@field IconTask1 UFImage
---@field IconTask2 UFImage
---@field ImgFocusBg1 UFImage
---@field ImgFocusBg2 UFImage
---@field ImgFocusShadow1 UFImage
---@field ImgFocusShadow2 UFImage
---@field ImgNormalBg1 UFImage
---@field ImgNormalBg2 UFImage
---@field ImgNormalShadow1 UFImage
---@field ImgNormalShadow2 UFImage
---@field ImgNull1 UFImage
---@field ImgTask1 UFImage
---@field ImgTask2 UFImage
---@field Info1 UFHorizontalBox
---@field Info2 UFHorizontalBox
---@field PanelBg1 UFCanvasPanel
---@field PanelBg2 UFCanvasPanel
---@field PanelPrefix1 UFCanvasPanel
---@field PanelPrefix2 UFCanvasPanel
---@field Taks1 UFCanvasPanel
---@field Taks2 UFCanvasPanel
---@field TextLevel1 UFTextBlock
---@field TextLevel2 UFTextBlock
---@field TextTask1 UFTextBlock
---@field TextTask2 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TravelLogTaksItemView = LuaClass(UIView, true)

function TravelLogTaksItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn1 = nil
	--self.Btn2 = nil
	--self.CommonRedDot2_UIBP = nil
	--self.CommonRedDot2_UIBP_61 = nil
	--self.IconPrefixFocus1 = nil
	--self.IconPrefixFocus_1 = nil
	--self.IconPrefixNormal1 = nil
	--self.IconPrefixNormal_1 = nil
	--self.IconTask1 = nil
	--self.IconTask2 = nil
	--self.ImgFocusBg1 = nil
	--self.ImgFocusBg2 = nil
	--self.ImgFocusShadow1 = nil
	--self.ImgFocusShadow2 = nil
	--self.ImgNormalBg1 = nil
	--self.ImgNormalBg2 = nil
	--self.ImgNormalShadow1 = nil
	--self.ImgNormalShadow2 = nil
	--self.ImgNull1 = nil
	--self.ImgTask1 = nil
	--self.ImgTask2 = nil
	--self.Info1 = nil
	--self.Info2 = nil
	--self.PanelBg1 = nil
	--self.PanelBg2 = nil
	--self.PanelPrefix1 = nil
	--self.PanelPrefix2 = nil
	--self.Taks1 = nil
	--self.Taks2 = nil
	--self.TextLevel1 = nil
	--self.TextLevel2 = nil
	--self.TextTask1 = nil
	--self.TextTask2 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TravelLogTaksItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot2_UIBP)
	self:AddSubView(self.CommonRedDot2_UIBP_61)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TravelLogTaksItemView:OnInit()
	self.VMBinders1 = {
		{"ImgTask", UIBinderSetBrushFromAssetPath.New(self, self.ImgTask1) },
		{"TextLevel", UIBinderSetText.New(self, self.TextLevel1)},
		{"TextTask", UIBinderSetText.New(self, self.TextTask1)},
		{"IconTaskPath", UIBinderSetBrushFromAssetPath.New(self, self.IconTask1)},
		{"IsSelected", UIBinderSetIsVisible.New(self, self.ImgNormalBg1, true)},
		{"IsSelected", UIBinderSetIsVisible.New(self, self.ImgNormalShadow1, true)},
		{"IsSelected", UIBinderSetIsVisible.New(self, self.ImgFocusBg1)},
		{"IsSelected", UIBinderSetIsVisible.New(self, self.ImgFocusShadow1)},
		{"IsPrefixVisible", UIBinderSetIsVisible.New(self, self.PanelPrefix1)},
		{"IsPrefixFinish", UIBinderSetIsVisible.New(self, self.IconPrefixNormal1, true)},
		{"IsPrefixFinish", UIBinderSetIsVisible.New(self, self.IconPrefixFocus1)},
	}
	self.VMBinders2 = {
		{"ImgTask", UIBinderSetBrushFromAssetPath.New(self, self.ImgTask2) },
		{"TextLevel", UIBinderSetText.New(self, self.TextLevel2)},
		{"TextTask", UIBinderSetText.New(self, self.TextTask2)},
		{"IconTaskPath", UIBinderSetBrushFromAssetPath.New(self, self.IconTask2)},
		{"IsSelected", UIBinderSetIsVisible.New(self, self.ImgNormalBg2, true)},
		{"IsSelected", UIBinderSetIsVisible.New(self, self.ImgNormalShadow2, true)},
		{"IsSelected", UIBinderSetIsVisible.New(self, self.ImgFocusBg2)},
		{"IsSelected", UIBinderSetIsVisible.New(self, self.ImgFocusShadow2)},
		{"IsPrefixVisible", UIBinderSetIsVisible.New(self, self.PanelPrefix2)},
		{"IsPrefixFinish", UIBinderSetIsVisible.New(self, self.IconPrefixNormal_1, true)},
		{"IsPrefixFinish", UIBinderSetIsVisible.New(self, self.IconPrefixFocus_1)},
	}
end

function TravelLogTaksItemView:OnDestroy()
end

function TravelLogTaksItemView:OnShow()
	if nil == self.Params then return end

	---@type TravelLogTaskItemVM
	self.ViewModel = self.Params.Data

	if self.ViewModel.ItemVM1 and self.ViewModel.ItemVM1.ChapterID then
		UIUtil.SetIsVisible(self.Btn1, true, true)
		UIUtil.SetIsVisible(self.Info1, true)
		UIUtil.SetIsVisible(self.PanelBg1, true)
		local RedDotName = _G.TravelLogMgr:GetChildRedDotName(self.ViewModel.ItemVM1.ChapterID)
		self.CommonRedDot2_UIBP:SetRedDotNameByString(RedDotName)
	else
		UIUtil.SetIsVisible(self.Btn1, false)
		UIUtil.SetIsVisible(self.Info1, false)
		UIUtil.SetIsVisible(self.PanelBg1, false)
		UIUtil.SetIsVisible(self.PanelPrefix1, false)
		self.CommonRedDot2_UIBP:SetRedDotNameByString("")
	end

	if self.ViewModel.ItemVM2 and self.ViewModel.ItemVM2.ChapterID then
		UIUtil.SetIsVisible(self.Btn2, true, true)
		UIUtil.SetIsVisible(self.Info2, true)
		UIUtil.SetIsVisible(self.PanelBg2, true)
		local RedDotName = _G.TravelLogMgr:GetChildRedDotName(self.ViewModel.ItemVM2.ChapterID)
		self.CommonRedDot2_UIBP_61:SetRedDotNameByString(RedDotName)
	else
		UIUtil.SetIsVisible(self.Btn2, false)
		UIUtil.SetIsVisible(self.Info2, false)
		UIUtil.SetIsVisible(self.PanelBg2, false)
		UIUtil.SetIsVisible(self.PanelPrefix2, false)
		self.CommonRedDot2_UIBP_61:SetRedDotNameByString("")
	end
end

function TravelLogTaksItemView:OnHide()
end

function TravelLogTaksItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn1, self.OnBtnClick1)
	UIUtil.AddOnClickedEvent(self, self.Btn2, self.OnBtnClick2)
end

function TravelLogTaksItemView:OnRegisterGameEvent()
end

function TravelLogTaksItemView:OnRegisterBinder()
	if nil == self.Params then return end

	---@type TravelLogTaskItemVM
	self.ViewModel = self.Params.Data

	if self.ViewModel.ItemVM1 and self.ViewModel.ItemVM1.ChapterID then
		self:RegisterBinders(self.ViewModel.ItemVM1, self.VMBinders1)
	end

	if self.ViewModel.ItemVM2 and self.ViewModel.ItemVM2.ChapterID then
		self:RegisterBinders(self.ViewModel.ItemVM2, self.VMBinders2)
	end
end

function TravelLogTaksItemView:OnBtnClick1()
	if self.ViewModel.ItemVM1 then
		local LogID = self.ViewModel.ItemVM1.LogID
		local RedDotName = _G.TravelLogMgr:GetChildRedDotName(LogID)
		_G.RedDotMgr:DelRedDotByName(RedDotName)
		_G.EventMgr:SendEvent(EventID.SelectTravelLogItem, LogID)
	end
end

function TravelLogTaksItemView:OnBtnClick2()
	if self.ViewModel.ItemVM2 then
		local LogID = self.ViewModel.ItemVM2.LogID
		local RedDotName = _G.TravelLogMgr:GetChildRedDotName(LogID)
		_G.RedDotMgr:DelRedDotByName(RedDotName)
		_G.EventMgr:SendEvent(EventID.SelectTravelLogItem, LogID)
	end
end

return TravelLogTaksItemView