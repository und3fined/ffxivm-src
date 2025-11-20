---
--- Author: rock
--- DateTime: 2025-09-07 15:21
--- Description:翅膀改良-升级的本系列中的翅膀列表数据(右边4个翅膀) Item 
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback =  require("Binder/UIBinderValueChangedCallback")
local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local SaveKey = require("Define/SaveKey")
local ESlateVisibility = _G.UE.ESlateVisibility

local USaveMgr

---@class FashionDecoAmeliorateSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSelect UFButton
---@field ImgCheck UFImage
---@field ImgItem UFImage
---@field ImgLock UFImage
---@field ImgNormal UFImage
---@field ImgSelect UFImage
---@field MI_DX_Common_FashionDeco_5 UFImage
---@field PanelItemLight UFCanvasPanel
---@field PanelSelect UFCanvasPanel
---@field RedDot CommonRedDotView
---@field TextName UFTextBlock
---@field AnimChecked UWidgetAnimation
---@field AnimUnchecked UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FashionDecoAmeliorateSlotView = LuaClass(UIView, true)

function FashionDecoAmeliorateSlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSelect = nil
	--self.ImgCheck = nil
	--self.ImgItem = nil
	--self.ImgLock = nil
	--self.ImgNormal = nil
	--self.ImgSelect = nil
	--self.MI_DX_Common_FashionDeco_5 = nil
	--self.PanelItemLight = nil
	--self.PanelSelect = nil
	--self.RedDot = nil
	--self.TextName = nil
	--self.AnimChecked = nil
	--self.AnimUnchecked = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FashionDecoAmeliorateSlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FashionDecoAmeliorateSlotView:OnInit()
	USaveMgr = _G.UE.USaveMgr
end

function FashionDecoAmeliorateSlotView:OnDestroy()

end

function FashionDecoAmeliorateSlotView:OnShow()
	
end

function FashionDecoAmeliorateSlotView:OnHide()
	--关闭面板时，new红点则为消失
	self:OnIsClick(true)
end

function FashionDecoAmeliorateSlotView:OnRegisterUIEvent()

end

function FashionDecoAmeliorateSlotView:OnRegisterGameEvent()

end

function FashionDecoAmeliorateSlotView:OnRegisterBinder()
	--self.ViewModel 是 FashionDecoAmeliorateSlotVM
	if self.Params and self.Params.Data then
		self.ViewModel = self.Params.Data
	end
	if nil == self.ViewModel then
		return
	end

	local Binders = {
		{ "LastName", UIBinderSetText.New(self, self.TextName) },
		{ "ImgItemIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgItem) },
		{ "IsSelect", UIBinderSetIsVisible.New(self, self.ImgSelect)},
		{ "IsEquip", UIBinderSetIsVisible.New(self, self.ImgCheck)},
		{ "IsUnlock", UIBinderSetIsVisible.New(self, self.ImgLock, true)},

		{ "IsSelect", UIBinderValueChangedCallback.New(self, nil, self.OnSetSelected) },
		{ "IsClick", UIBinderValueChangedCallback.New(self, nil, self.OnIsClick) },
		-- { "Id", UIBinderValueChangedCallback.New(self, nil, self.OnChangeId) },
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

function FashionDecoAmeliorateSlotView:PostShowView()
	--此ID改变侦听写在PostShowView而不写在OnRegisterBinder的原因：是因为每次打开此主界面的时候，和红点CommonRedDotView存在先后顺序，导致红点没显示出来
	--逻辑顺序：第1步、如果在OnRegisterBinder里面侦听的OnChangeId，会立刻执行OnUpdateRedDot()，再执行了红点SetRedDotUIIsShow(true)显示
	--		    第2步、然后，红点那在显示(CommonRedDotView:OnShow())的时候又会隐藏
	local Binders = {
		{ "Id", UIBinderValueChangedCallback.New(self, nil, self.OnChangeId) },
	}
	self:RegisterBinders(self.ViewModel, Binders)
end

function FashionDecoAmeliorateSlotView:OnChangeId(bSelected, IsByClick)
	if self.ViewModel ~= nil then
		-- 设置红点命名
		self.RedDotName = string.format("Root/Menu/FashionDeco/Wing/Ameliorate/SeriesType%s/%s", self.ViewModel.SeriesType, self.ViewModel.Id)
		self.RedDot:SetRedDotNameByString(self.RedDotName) --设置红点名字
		self:OnUpdateRedDot()
	end
end

function FashionDecoAmeliorateSlotView:OnSetSelected(bSelected, IsByClick)
	
end


function FashionDecoAmeliorateSlotView:OnUpdateRedDot()
	-- 母体没有红点显示
	if self.ViewModel.AmeliorateWingData.IsFirst then
		_G.RedDotMgr:DelRedDotByName(self.RedDotName)
	else
		if not self.ViewModel.AmeliorateWingData.IsUnlock and self.ViewModel.AmeliorateWingData.IsOwnedLast and self.ViewModel.AmeliorateWingData.IsBagEnoughCost then
			--为当前可升级的翅膀、拥有上一级、材料足够, 显示样式1 "!"
			self.RedDot:SetRedDotUIIsShow(true)
			self.RedDot:SetStyle(1)
			_G.RedDotMgr:AddRedDotByName(self.RedDotName, nil, true)
		else
			local IsBeenSave = self:IsSaveRedDotByWingId(self.ViewModel.Id)--检查本地是否普点击过
			if not IsBeenSave and self.ViewModel.AmeliorateWingData.IsOwnedFirst then
				--未曾点击、母体已解锁,显示样式4 "新"
				self.RedDot:SetRedDotUIIsShow(true)
				self.RedDot:SetStyle(4)
				_G.RedDotMgr:DelRedDotByName(self.RedDotName)--刷新向上红点，解决向上层传递更新红点(比如材料用完时，切换到其他系列，其他系列有new红点显示的情况)
			else
				self.RedDot:SetRedDotUIIsShow(false)
				_G.RedDotMgr:DelRedDotByName(self.RedDotName)
			end
		end
	end
end

function FashionDecoAmeliorateSlotView:OnIsClick(IsClick)
	--策划需求只要点击就消红点，和选中无关
	if IsClick then
		self:SaveRedDotByWingId(self.ViewModel.Id)
		self:OnUpdateRedDot()
	end
end

---New样式红点，是否已曾点击保存过
function FashionDecoAmeliorateSlotView:IsSaveRedDotByWingId(InWingId)
    local HideRedDotIdStr = USaveMgr.GetString(SaveKey.FashionDecoAmeliorateReadRedDot, "", true)
	local HideRedDotIdList = string.split(HideRedDotIdStr,",")
	local IsSave = false
	for key, value in pairs(HideRedDotIdList) do
		if tonumber(value) == InWingId then
			IsSave = true
			break
		end
	end
	return IsSave
end

---New样式红点，保存
function FashionDecoAmeliorateSlotView:SaveRedDotByWingId(InWingId)
	local IsSave = self:IsSaveRedDotByWingId(InWingId)
	--此ID已经保存过了
	if IsSave then
		return
	end
	local HideRedDotIdStr = USaveMgr.GetString(SaveKey.FashionDecoAmeliorateReadRedDot, "", true)
	HideRedDotIdStr = string.format("%s,%s", HideRedDotIdStr, InWingId)
	USaveMgr.SetString(SaveKey.FashionDecoAmeliorateReadRedDot, HideRedDotIdStr, true)
end

return FashionDecoAmeliorateSlotView