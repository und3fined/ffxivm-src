---
--- Author: Administrator
--- DateTime: 2023-08-22 12:40
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetItemNumFormat = require("Binder/UIBinderSetItemNumFormat")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderSetIsAllowDoubleClick = require("Binder/UIBinderSetIsAllowDoubleClick")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local ItemCfg = require("TableCfg/ItemCfg")
local TimeUtil = require("Utils/TimeUtil")

local BagMgr
---@class BagSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSlot UFButton
---@field CommonRedDot2 CommonRedDot2View
---@field IconEuipImprove UFImage
---@field IconExpired UFImage
---@field IconLimitedTime UFImage
---@field ImgGlamours UFImage
---@field ImgIcon UFImage
---@field ImgMask UFImage
---@field ImgQuality UFImage
---@field ImgRadialCDBG URadialImage
---@field ImgSelect UFImage
---@field ImgSuit UFImage
---@field ImgWearable UFImage
---@field PanelBag UFCanvasPanel
---@field PanelEquipment UFCanvasPanel
---@field PanelMedicine UFCanvasPanel
---@field PanelMultiChoice UFCanvasPanel
---@field RichTextNum URichTextBox
---@field TextMedicineCD UFTextBlock
---@field AnimCD UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BagSlotView = LuaClass(UIView, true)

function BagSlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSlot = nil
	--self.CommonRedDot2 = nil
	--self.IconEuipImprove = nil
	--self.IconExpired = nil
	--self.IconLimitedTime = nil
	--self.ImgGlamours = nil
	--self.ImgIcon = nil
	--self.ImgMask = nil
	--self.ImgQuality = nil
	--self.ImgRadialCDBG = nil
	--self.ImgSelect = nil
	--self.ImgSuit = nil
	--self.ImgWearable = nil
	--self.PanelBag = nil
	--self.PanelEquipment = nil
	--self.PanelMedicine = nil
	--self.PanelMultiChoice = nil
	--self.RichTextNum = nil
	--self.TextMedicineCD = nil
	--self.AnimCD = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BagSlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BagSlotView:OnInit()
	self.Binders = {
		{ "ItemQualityIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgQuality) },
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
	
		{ "IsNew", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedRedDotVisible) },

		{ "Num", UIBinderSetItemNumFormat.New(self, self.RichTextNum) },
		{ "NumVisible", UIBinderSetIsVisible.New(self, self.RichTextNum) },

		{ "CDRadialProcess", UIBinderSetPercent.New(self, self.ImgRadialCDBG) },
		{ "ItemCD", UIBinderSetTextFormat.New(self, self.TextMedicineCD, "%d") },
		{ "ItemCDShow", UIBinderSetIsVisible.New(self, self.TextMedicineCD) },
		{ "IsCD", UIBinderSetIsVisible.New(self, self.PanelMedicine) },
		{ "IsMask", UIBinderSetIsVisible.New(self, self.ImgMask) },
		{ "IsSelect", UIBinderSetIsVisible.New(self, self.ImgSelect) },
		{ "IsInScheme", UIBinderSetIsVisible.New(self, self.ImgSuit) },

		{ "IsLimitedTime", UIBinderSetIsVisible.New(self, self.IconLimitedTime) },
		{ "IsExpired", UIBinderSetIsVisible.New(self, self.IconExpired) },

		{"PanelBagVisible", UIBinderSetIsVisible.New(self, self.PanelBag)},

		{ "GlamoursImgVisible", UIBinderSetIsVisible.New(self, self.ImgGlamours) },

		{ "LeftCornerFlagImgIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgWearable) },
		{ "LeftCornerFlagImgVisible", UIBinderSetIsVisible.New(self, self.ImgWearable) },

		--回收选中
		{ "PanelMultiChoiceVisible", UIBinderSetIsVisible.New(self, self.PanelMultiChoice) },

		{ "IsAllowDoubleClick", UIBinderSetIsAllowDoubleClick.New(self, self.BtnSlot) },

		--可改良
		{ "CanImprove", UIBinderSetIsVisible.New(self, self.IconEuipImprove) },

	}
	self.CommonRedDot2:SetIsCustomizeRedDot(true)
	BagMgr = _G.BagMgr
end

function BagSlotView:OnDestroy()

end

function BagSlotView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	local Item = ViewModel.Item
	if nil == Item then
		return
	end

	local Cfg = ItemCfg:FindCfgByKey(ViewModel.ResID)
	if nil == Cfg then
		return
	end
	
	--BagMgr:SetShowCount()

	local IsCD = BagMgr.FreezeCDTable[Cfg.FreezeGroup] ~= nil
	ViewModel.IsCD = IsCD
	if IsCD then
		local CurTime = TimeUtil.GetServerTime()
		local EndFreezeTime = BagMgr.FreezeCDTable[Cfg.FreezeGroup].EndTime
		local FreezeCD = BagMgr.FreezeCDTable[Cfg.FreezeGroup].FreezeCD
		if EndFreezeTime - CurTime > 0 and FreezeCD > 0 then
			local CDTime = math.floor(EndFreezeTime - CurTime)
			local ProgressAnimDuration = self:GetProgressAnimDuration()
			local Speed = ProgressAnimDuration / FreezeCD
			local EndAnimTime = ProgressAnimDuration * (1 - CDTime / FreezeCD)
			self:PlayAnimationTimeRange(self.AnimCD, EndAnimTime < 0.001 and EndAnimTime or EndAnimTime - 0.001, EndAnimTime, 1, nil, Speed, false)
			ViewModel.CDRadialProcess = 1 - CDTime / FreezeCD
			ViewModel.ItemCD = CDTime
			ViewModel.ItemCDShow = CDTime <= 3600 --- 超过3600s不显示
		else
			ViewModel.IsCD = false
			ViewModel.CDRadialProcess = nil
		end
	else
		ViewModel.CDRadialProcess = nil
	end

	if Item.ExpireTime  and Item.ExpireTime  > 0 then
		local LeftTime = _G.TimeUtil:GetServerLogicTime() - Item.ExpireTime
		if LeftTime > 0 and self.TimerID == nil then
			self.TimerID = _G.TimerMgr:AddTimer(self, self.UpdateTimeLimit, 0.5, LeftTime, 1)
		end
	end 

end

function BagSlotView:UpdateTimeLimit()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end
	ViewModel:UpdateLimitedTime()
	if self.TimerID then
		_G.TimerMgr:CancelTimer(self.TimerID)
		self.TimerID = nil
	end
end


function BagSlotView:OnHide()
	if self.TimerID then
		_G.TimerMgr:CancelTimer(self.TimerID)
		self.TimerID = nil
	end
end

function BagSlotView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSlot, self.OnClickButtonItem)
	UIUtil.AddOnDoubleClickedEvent(self, self.BtnSlot, self.OnDoubleClickButtonItem)
end

function BagSlotView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.BagFreezeCD, self.OnFreezeCD)
end

function BagSlotView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	
	self:RegisterBinders(ViewModel, self.Binders)
end

function BagSlotView:OnClickButtonItem()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end

	Adapter:OnItemClicked(self, Params.Index)

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end
	ViewModel:ClickedItemVM()
end

function BagSlotView:OnDoubleClickButtonItem()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end

	Adapter:OnItemDoubleClicked(self, Params.Index)
end

function BagSlotView:OnValueChangedRedDotVisible(IsVisible)
	self.CommonRedDot2:SetRedDotUIIsShow(IsVisible)
end

--药品cd
function BagSlotView:OnFreezeCD(GroupID, EndFreezeTime, FreezeCD)
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	local Cfg = ItemCfg:FindCfgByKey(ViewModel.ResID)
	if nil == Cfg then
		return
	end
 
	if GroupID ~= Cfg.FreezeGroup then -- 非同一冷却组的道具不进行更新
		return
	end

	local IsCD = BagMgr.FreezeCDTable[Cfg.FreezeGroup] ~= nil
	ViewModel.IsCD = IsCD
	if IsCD then
		local CurTime = TimeUtil.GetServerTime()
		if EndFreezeTime - CurTime > 0 and FreezeCD > 0 then
			local CDTime = math.floor(EndFreezeTime - CurTime)
			local Percent = 1 - CDTime / FreezeCD
			local NextPercent = 1
			if CDTime > BagMgr.CDInterval then
				NextPercent = 1 - (CDTime - BagMgr.CDInterval) / FreezeCD
			end
		
			local ProgressAnimDuration = self:GetProgressAnimDuration()
			local Speed = ProgressAnimDuration / FreezeCD
			local StartTime = ProgressAnimDuration * Percent
			local EndAnimTime = ProgressAnimDuration * NextPercent
			if EndAnimTime > 0 then
				self:PlayAnimationTimeRange(self.AnimCD, StartTime, EndAnimTime, 1, nil, Speed, false)
			end
			ViewModel.CDRadialProcess = Percent
			ViewModel.ItemCD = CDTime
			ViewModel.ItemCDShow = CDTime <= 3600 --- 超过3600s不显示
		else
			ViewModel.IsCD = false
			ViewModel.CDRadialProcess = nil
		end
	else
		ViewModel.CDRadialProcess = nil
	end

end

function BagSlotView:GetProgressAnimDuration()
	if self.AnimCD then
		return self.AnimCD:GetEndTime()
	end
	return 0
end



return BagSlotView