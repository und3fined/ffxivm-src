---
--- Author: Administrator
--- DateTime: 2023-09-04 10:15
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local LSTR = _G.LSTR

local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local FLOG_INFO = _G.FLOG_INFO

---@class AetherCurrentDetailItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBG UFImage
---@field ImgExplore UFImage
---@field ImgTask UFImage
---@field PanelFinish UFCanvasPanel
---@field PanelMapDetailItem UFCanvasPanel
---@field PanelNoFinish UFCanvasPanel
---@field PanelRight UFCanvasPanel
---@field TableViewExplore UTableView
---@field TableViewTask UTableView
---@field TextFinish UFTextBlock
---@field TextNoFinish UFTextBlock
---@field TextPlace UFTextBlock
---@field ToggleButton_244 UToggleButton
---@field AnimComplete UWidgetAnimation
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local AetherCurrentDetailItemView = LuaClass(UIView, true)

function AetherCurrentDetailItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBG = nil
	--self.ImgExplore = nil
	--self.ImgTask = nil
	--self.PanelFinish = nil
	--self.PanelMapDetailItem = nil
	--self.PanelNoFinish = nil
	--self.PanelRight = nil
	--self.TableViewExplore = nil
	--self.TableViewTask = nil
	--self.TextFinish = nil
	--self.TextNoFinish = nil
	--self.TextPlace = nil
	--self.ToggleButton_244 = nil
	--self.AnimComplete = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function AetherCurrentDetailItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function AetherCurrentDetailItemView:InitConstStringInfo()
	self.TextFinish:SetText(LSTR(310025))
	self.TextNoFinish:SetText(LSTR(310026))
end

function AetherCurrentDetailItemView:OnInit()
	self.TableViewTaskAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewTask, nil, true, false, true)
	self.TableViewExploreAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewExplore, nil, true, false, true)
	self.Binders = {
		{"MapName", UIBinderSetText.New(self, self.TextPlace)},
		{"bFinished", UIBinderSetIsVisible.New(self, self.PanelFinish)},
		{"bFinished", UIBinderSetIsVisible.New(self, self.PanelNoFinish, true)},
		{"QuestMarkItems", UIBinderUpdateBindableList.New(self, self.TableViewTaskAdapter)},
		{"InteractMarkItems", UIBinderUpdateBindableList.New(self, self.TableViewExploreAdapter)},
		{"bSelfChecked", UIBinderSetIsChecked.New(self, self.ToggleButton_244)},
		{"BannerPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgBG, false, true)},
		{"bFinished", UIBinderValueChangedCallback.New(self, nil, self.OnAllPointActiveFinished)},
		--{"AnimInSwitch", UIBinderValueChangedCallback.New(self, nil, self.OnPlayAnimNotify)},
		--{"bRootPanelVisible", UIBinderSetIsVisible.New(self, self.PanelMapDetailItem, nil, true)},
	}
	self:InitConstStringInfo()
end

function AetherCurrentDetailItemView:OnDestroy()

end

function AetherCurrentDetailItemView:OnShow()
	--FLOG_INFO("AetherCurrentDetailItemView:OnShow OnTableItemShow")
	UIUtil.SetIsVisible(self.ImgTask, false)
	UIUtil.SetIsVisible(self.TableViewTask, false)
end

function AetherCurrentDetailItemView:OnHide()
	--FLOG_INFO("AetherCurrentDetailItemView:OnHide OnTableItemHide")
end

function AetherCurrentDetailItemView:OnRegisterUIEvent()

end

function AetherCurrentDetailItemView:OnRegisterGameEvent()

end

function AetherCurrentDetailItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

--- 定义此方法，满足TableViewAdapter中的调用来改变select状态
function AetherCurrentDetailItemView:OnSelectChanged(bSelected)
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end

	ViewModel.bSelfChecked = bSelected
end

function AetherCurrentDetailItemView:OnAllPointActiveFinished(NewValue)
	if NewValue then
		self:PlayAnimation(self.AnimComplete)
	end
end

--[[function AetherCurrentDetailItemView:OnPlayAnimNotify(_, OldValue)
	local Params = self.Params
	if Params == nil then
		return
	end

	local ViewModel = Params.Data
	if ViewModel == nil then
		return
	end
	
	ViewModel.bRootPanelVisible = true
	self:PlayAnimation(self.AnimIn1)
	print("Check The Anim Times")
end--]]

return AetherCurrentDetailItemView