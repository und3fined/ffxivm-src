---
--- Author: v_hggzhang
--- DateTime: 2023-09-20 15:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")


---@class CommRewardsSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClick UFButton
---@field ImgGot UFImage
---@field ImgIcon UFImage
---@field ImgJob UFImage
---@field ImgMask UFImage
---@field ImgQuality UFImage
---@field ImgWaiting UFImage
---@field PanelFunction UFCanvasPanel
---@field RichTextNum URichTextBox
---@field TextDaily UFTextBlock
---@field TextFristPass UFTextBlock
---@field TextResult UFTextBlock
---@field AnimGot UWidgetAnimation
---@field AnimResult UWidgetAnimation
---@field AnimUpLoop UWidgetAnimation
---@field AnimWaiting UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommRewardsSlotView = LuaClass(UIView, true)

function CommRewardsSlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClick = nil
	--self.ImgGot = nil
	--self.ImgIcon = nil
	--self.ImgJob = nil
	--self.ImgMask = nil
	--self.ImgQuality = nil
	--self.ImgWaiting = nil
	--self.PanelFunction = nil
	--self.RichTextNum = nil
	--self.TextDaily = nil
	--self.TextFristPass = nil
	--self.TextResult = nil
	--self.AnimGot = nil
	--self.AnimResult = nil
	--self.AnimUpLoop = nil
	--self.AnimWaiting = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommRewardsSlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommRewardsSlotView:OnInit()
	local RewardTypeBinder = UIBinderValueChangedCallback.New(self, nil, self.OnRewardTypeChanged)

	self.Binders = self.Binders or {
		{ "HasGot", 			UIBinderSetIsVisible.New(self, self.ImgGot) },
		{ "HasGot", 			UIBinderSetIsVisible.New(self, self.ImgMask) },
		{ "ShowFunc", 			UIBinderSetIsVisible.New(self, self.PanelFunction) },
		{ "ShowTipDaily", 		RewardTypeBinder },
		{ "bWeekly", 			RewardTypeBinder },
		{ "ShowTipFirst", 		UIBinderSetIsVisible.New(self, self.TextFristPass) },
		{ "ShowNum", 		    UIBinderSetIsVisible.New(self, self.RichTextNum) },
		{ "Num",                UIBinderSetTextFormat.New(self, self.RichTextNum, "%d") },
		{ "QuaImgVisible", 		UIBinderSetIsVisible.New(self, self.ImgQuality)},
		
		{ "QuaImg", 			UIBinderSetBrushFromAssetPath.New(self, self.ImgQuality) },
		{ "Icon", 				UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
		{ "FuncImg", 			UIBinderSetBrushFromAssetPath.New(self, self.ImgJob) },
		{ "IsShowTextNum", 		UIBinderSetIsVisible.New(self, self.RichTextNum) },
		{ "TextNum", 			UIBinderSetText.New(self, self.RichTextNum) },

		-- Roll点
		{ "IsMask", 			UIBinderSetIsVisible.New(self, self.ImgMask) },
		{ "TextDes", 			UIBinderSetText.New(self, self.TextResult) },
		{ "IsWait", 			UIBinderValueChangedCallback.New(self, nil, self.OnAwardValueChangeCallback) },
		{ "Obtained", 			UIBinderValueChangedCallback.New(self, nil, self.OnAwardValueChangeCallback) },
		{ "NotObtained", 		UIBinderValueChangedCallback.New(self, nil, self.OnAwardValueChangeCallback) },
		{ "IsOperated", 		UIBinderValueChangedCallback.New(self, nil, self.OnAwardValueChangeCallback) },

		-- 数量
		{ "Num", 				UIBinderSetText.New(self, self.RichTextNum)},
		{ "NumVisible", 		UIBinderSetIsVisible.New(self, self.RichTextNum)},

	}

	self.TextFristPass:SetText(_G.LSTR(1320143))
end

function CommRewardsSlotView:OnDestroy()

end

function CommRewardsSlotView:OnShow()
	
end

function CommRewardsSlotView:OnHide()

end

function CommRewardsSlotView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnClick, self.OnClick)
end

function CommRewardsSlotView:OnRegisterGameEvent()

end

function CommRewardsSlotView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Data = Params.Data
	if nil == Data then
		return
	end

	local ViewModel = Data
	self.VM = ViewModel

	self:RegisterBinders(ViewModel, self.Binders)
	-- print("zhg PWorldRewardVM:UpdateVM : " .. table.tostring_block(self.VM, 10))

end

function CommRewardsSlotView:OnClick()
	local Params = self.Params
    if nil == Params then
        return
    end
    local Adapter = Params.Adapter
	if nil == Adapter then
		local OnClick = Params.OnClick
		if OnClick then
			OnClick(self, Params)
		end
	else
		Adapter:OnItemClicked(self, Params.Index)
    end
end

--- Roll点   奖励状态
function CommRewardsSlotView:OnAwardValueChangeCallback()
	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end
	UIUtil.SetIsVisible(self.TextResult, true)
	if ViewModel.IsWait then
		UIUtil.SetIsVisible(self.ImgWaiting, true)
		UIUtil.SetIsVisible(self.ImgMask, true)
		self:PlayAnimation(self.AnimRollWaiting)
	else
		UIUtil.SetIsVisible(self.ImgWaiting, false)
		self:StopAnimation(self.AnimRollWaiting)
	end
	if ViewModel.IsRecommend then				-- 职业提升
		UIUtil.SetIsVisible(self.PanelFunction, true)
		self:PlayAnimation(self.AnimUpLoop, 0, 0)
	else
		UIUtil.SetIsVisible(self.PanelFunction, false)
		self:StopAnimation(self.AnimUpLoop)
	end
	if ViewModel.IsOperated then				-- 已操作
		self:StopAnimation(self.AnimUpLoop)
		UIUtil.SetIsVisible(self.PanelFunction, false)
	end
	if ViewModel.Obtained then					-- 已获得
		UIUtil.SetIsVisible(self.ImgGot, true)
		UIUtil.SetIsVisible(self.ImgMask, true)
		UIUtil.SetIsVisible(self.TextResult, false)
		self:PlayAnimation(self.AnimGot)
	else
		UIUtil.SetIsVisible(self.ImgGot, false)
	end
	if ViewModel.NotObtained then				-- 未获得
		self:PlayAnimation(self.AnimResult)
	else
		self:StopAnimation(self.AnimResult)
	end
end

function CommRewardsSlotView:OnRewardTypeChanged()
	if self.VM == nil then
		UIUtil.SetIsVisible(self.TextDaily, false)
		return
	end

	local bShow = self.VM.ShowTipDaily or self.VM.bWeekly
	UIUtil.SetIsVisible(self.TextDaily, bShow)
	if self.VM.ShowTipDaily then
		self.TextDaily:SetText(_G.LSTR(1320142))
	elseif self.VM.bWeekly then
		self.TextDaily:SetText(_G.LSTR(1320231))
	end	
end

return CommRewardsSlotView