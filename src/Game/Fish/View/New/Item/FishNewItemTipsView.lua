---
--- Author: Administrator
--- DateTime: 2024-01-22 09:47
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local FishReleaseTipVM = require("Game/Fish/ItemVM/FishReleaseTipVM")
local FishDefine = require("Game/Fish/FishDefine")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetActiveWidgetIndex = require("Binder/UIBinderSetActiveWidgetIndex")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class FishNewItemTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn1 UFButton
---@field Btn2 UFButton
---@field PanelTips UFCanvasPanel
---@field SwitchBtn UFWidgetSwitcher
---@field TextBtn UFTextBlock
---@field TextBtn_2 UFTextBlock
---@field TextLevel UFTextBlock
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishNewItemTipsView = LuaClass(UIView, true)

function FishNewItemTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn1 = nil
	--self.Btn2 = nil
	--self.PanelTips = nil
	--self.SwitchBtn = nil
	--self.TextBtn = nil
	--self.TextBtn_2 = nil
	--self.TextLevel = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishNewItemTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishNewItemTipsView:OnInit()
	self.FishReleaseTipVM = FishReleaseTipVM.New()
	self.ItemView = nil
	self.FishID = nil

	self.Binder = {
		{ "ReleaseFishName", UIBinderSetText.New(self, self.TextName) },
		{ "ReleaseFishLevel", UIBinderSetTextFormat.New(self, self.TextLevel, FishDefine.FishNewItemTipsText.TextLevel)},
		{ "AutoReleaseIndex", 	UIBinderSetActiveWidgetIndex.New(self, self.SwitchBtn) },
		{ "BtnText", UIBinderSetText.New(self, self.TextBtn) },
		{ "bHasFish",UIBinderSetIsVisible.New(self, self.SwitchBtn, false, true)},
		{ "bIsknown",UIBinderSetIsVisible.New(self, self.TextLevel, false, true)},
	}
end

function FishNewItemTipsView:OnDestroy()

end

function FishNewItemTipsView:OnShow()
	local Params = self.Params
	if Params then
		local Item = Params.Item
		if Item then
			self.FishReleaseTipVM:UpdateReleaseFishData(Item)
			self.FishID = Item.ResID
		end
		local PosData = Params.PosData
		if PosData then
			self:UpdatePanelPos(PosData)
		end
		local View = Params.ItemView
		if View then
			self.ItemView = View
		end
	end
end

function FishNewItemTipsView:OnHide()

end

function FishNewItemTipsView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn1, self.OnClickBtnRelease)
end

function FishNewItemTipsView:OnRegisterGameEvent()

end

function FishNewItemTipsView:OnRegisterBinder()
	self:RegisterBinders(self.FishReleaseTipVM,self.Binder)
end

function FishNewItemTipsView:UpdateItem(Item,PosData,ItemView)
	self.FishReleaseTipVM:UpdateReleaseFishData(Item)
	self:UpdatePanelPos(PosData)
	if ItemView then
		self.ItemView = ItemView
	end
	if Item then
		self.FishID = Item.ResID
	end
end

function FishNewItemTipsView:UpdatePanelPos(PosData)
	if PosData then
		UIUtil.AdjustTipsPosition(self.PanelTips, PosData.SelectedWidget, PosData.Offset)
	end
end

function FishNewItemTipsView:OnClickBtnRelease()
	self.FishReleaseTipVM:UpdateAutoRelease()
	_G.UIViewMgr:FindVisibleView(_G.UIViewID.FishMainPanel):StorageReleaseFishData(self.FishID)
end

return FishNewItemTipsView