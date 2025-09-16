---
--- Author: ds_tianjiateng
--- DateTime: 2024-12-18 16:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local ProtoRes = require("Protocol/ProtoRes")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local RedDotDefine = require("Game/CommonRedDot/RedDotDefine")

---@class StoreNewPosterItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconTime UFImage
---@field ImgPoster UFImage
---@field ImgSelect UFImage
---@field PanelAlreadyOwned UFCanvasPanel
---@field PanelDiscountTag UFCanvasPanel
---@field PanelTime UFHorizontalBox
---@field RedDot CommonRedDotView
---@field TextName UFTextBlock
---@field TextTime UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StoreNewPosterItemView = LuaClass(UIView, true)

function StoreNewPosterItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconTime = nil
	--self.ImgPoster = nil
	--self.ImgSelect = nil
	--self.PanelAlreadyOwned = nil
	--self.PanelDiscountTag = nil
	--self.PanelTime = nil
	--self.RedDot = nil
	--self.TextName = nil
	--self.TextTime = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StoreNewPosterItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StoreNewPosterItemView:OnInit()

	self.Binders = {
		{ "GoodIcon", 				UIBinderSetBrushFromAssetPath.New(self, self.ImgPoster) },
		{ "ItemNameText", 			UIBinderSetText.New(self, self.TextName) },
		{ "GoodStateText", 			UIBinderSetText.New(self, self.TextAlreadyOwned) },
		{ "DiscountText", 			UIBinderSetText.New(self, self.FTextBlock_48) },
		{ "TimeSaleText", 			UIBinderSetText.New(self, self.TextTime) },
		{ "DiscountPanelVisible", 	UIBinderSetIsVisible.New(self, self.PanelDiscountTag) },
		{ "DeadlinePanelVisible", 	UIBinderSetIsVisible.New(self, self.PanelTime) },
		{ "StateTextVisible", 		UIBinderSetIsVisible.New(self, self.PanelAlreadyOwned) },
		{ "bSelected", 				UIBinderSetIsVisible.New(self, self.ImgSelect) },
		{ "IsNeedRegisterDisCountTimer", 	UIBinderValueChangedCallback.New(self, nil, self.OnDisCountTimer) },
	}

end

function StoreNewPosterItemView:OnDestroy()

end

function StoreNewPosterItemView:OnShow()
	self:UpdateRetDotInfo()
end

function StoreNewPosterItemView:UpdateRetDotInfo()
	if _G.StoreMainVM.CurrentSelectedTabType == ProtoRes.StoreMall.STORE_MALL_MYSTERYBOX then
		self.RedDot:SetStyle(RedDotDefine.RedDotStyle.TextStyle)
		self.RedDot:SetRedDotText(LSTR(1220001))	--- 新
		if _G.StoreMgr.RedDotPathList[self.ViewModel.GoodID] ~= nil and _G.StoreMgr:GetServerRedDotData(self.ViewModel.GoodID) == 1 then
			UIUtil.SetIsVisible(self.RedDot, true)
			self.RedDot:SetRedDotNameByString(_G.StoreMgr.RedDotPathList[self.ViewModel.GoodID])
		else
			UIUtil.SetIsVisible(self.RedDot, false)
		end
	else
		UIUtil.SetIsVisible(self.RedDot, false)
	end
end

function StoreNewPosterItemView:OnHide()

end

function StoreNewPosterItemView:OnDisCountTimer(NewValue)
	if self.DiscountEndTimerID ~= nil then
		self:UnRegisterTimer(self.DiscountEndTimerID)
	end
	if NewValue then
		self.DiscountEndTimerID = self:RegisterTimer(function() self.ViewModel:UpdateTimeSale(self.ViewModel.DiscountDurationEnd) end , 0, 1, self.ViewModel.DisCountTimerLoopNumber)	
	end
end

function StoreNewPosterItemView:OnRegisterUIEvent()

end

function StoreNewPosterItemView:OnSelectChanged(NewValue)
	UIUtil.SetIsVisible(self.ImgSelect, NewValue)
	if NewValue and _G.StoreMgr.RedDotPathList ~= nil and _G.StoreMgr.RedDotPathList[self.ViewModel.GoodID] ~= nil then
		_G.RedDotMgr:DelRedDotByName(_G.StoreMgr.RedDotPathList[self.ViewModel.GoodID])
		_G.StoreMgr.RedDotPathList[self.ViewModel.GoodID] = nil
		_G.StoreMgr:ChangeRedDotState(self.ViewModel.GoodID, 0)
		if table.is_nil_empty(_G.StoreMgr.RedDotPathList) then
			_G.RedDotMgr:DelRedDotByID(19)
		end
	end
end

function StoreNewPosterItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.StoreUpdateMysterBoxRedDot, self.UpdateRetDotInfo)
end

function StoreNewPosterItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end
	self.ViewModel = ViewModel
	self:RegisterBinders(ViewModel, self.Binders)
end

return StoreNewPosterItemView