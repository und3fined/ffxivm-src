---
--- Author: Administrator
--- DateTime: 2023-11-21 18:20
--- Description:  
---    1. 触发特效加成动画 绑定的Vm需要有如下成员及对应的值： OriginalNum IncrementedNum PlayAddEffect  
---		  注：多行的时候会存在上下滑动自己需要注意下你传如的VM被复用的情况 可以关注下IsEqualVM的判断条件
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText =  require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback =  require("Binder/UIBinderValueChangedCallback")

---@class CommRewardItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm152Slot CommBackpack152SlotView
---@field FCanvasPanel_60 UFCanvasPanel
---@field ImgArrowUp UFImage
---@field PanelUp UFCanvasPanel
---@field TextName UFTextBlock
---@field TextUpNumber UFTextBlock
---@field AnimAdditionUpNumber UWidgetAnimation
---@field AnimIn_1 UWidgetAnimation
---@field CurveAddition CurveFloat
---@field ValueAddition float
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommRewardItemView = LuaClass(UIView, true)

function CommRewardItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm152Slot = nil
	--self.FCanvasPanel_60 = nil
	--self.ImgArrowUp = nil
	--self.PanelUp = nil
	--self.TextName = nil
	--self.TextUpNumber = nil
	--self.AnimAdditionUpNumber = nil
	--self.AnimIn_1 = nil
	--self.CurveAddition = nil
	--self.ValueAddition = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommRewardItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm152Slot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommRewardItemView:OnInit()
	self.Binders = {
		{ "ItemNameVisible", UIBinderSetIsVisible.New(self, self.TextName) },
		{ "ItemName", UIBinderSetText.New(self, self.TextName) },
		{ "Name", UIBinderValueChangedCallback.New(self, nil, self.OnNameChanged) }, 
		{ "PlayAddEffect", UIBinderSetIsVisible.New(self, self.PanelUp) },   

		-- RewardItemPlayAnimIn  是用于CommRewardPanelView方便控制 CommRewardItemView 入场动画播放，不需要自己去控制播放
		{ "RewardItemPlayAnimIn", UIBinderValueChangedCallback.New(self, nil, self.OnRewardItemPlayAnimInChanged) }, 
	}
	UIUtil.SetIsVisible(self.Comm152Slot.RichTextQuantity, false)
end

function CommRewardItemView:OnDestroy()

end

function CommRewardItemView:PanelUpSetupAnimation(PlayBackCompletion)
	local ViewModel = self.ViewModel
	if ViewModel and ViewModel.PlayAddEffect ~= nil then
		UIUtil.SetIsVisible(self.Comm152Slot.RichTextQuantity, false)
		self.Comm152Slot:AddRemoveBinder("NumVisible", false)
		if PlayBackCompletion then
			-- 播放结束后的显示状态
			UIUtil.SetRenderOpacity(self.ImgArrowUp, 1)
			self.TextUpNumber:SetText(ItemUtil.GetItemNumText( ViewModel.IncrementedNum or 0))
		else
			-- 播放前的准备状态
			self.TextUpNumber:SetText(ItemUtil.GetItemNumText( ViewModel.OriginalNum or 0))
			UIUtil.SetRenderOpacity(self.ImgArrowUp, 0)
		end
	end
end

function CommRewardItemView:OnShow()
	local RewardPanel = _G.UIViewMgr:FindView(_G.UIViewID.CommonRewardPanel)
	if RewardPanel ~= nil then
		if RewardPanel.PlayedAnimFirstIn then
			UIUtil.SetRenderOpacity(self.FCanvasPanel_60, 0)
			self:PanelUpSetupAnimation(false)
		else
			self:PanelUpSetupAnimation(true)
		end
	end
end

function CommRewardItemView:OnHide()
	local ViewModel = self.ViewModel 
	if nil ~= self.AnimIn_1 and self:IsAnimationPlaying(self.AnimIn_1) then 
		self:PlayAnimationToEndTime(self.AnimIn_1)
		if ViewModel then
			ViewModel.RewardItemPlayAnimIn = nil
		end
	end
	
	if ViewModel and ViewModel.PlayAddEffect ~= nil then 
		self.Comm152Slot:AddRemoveBinder("NumVisible", true)
	end

	UIUtil.SetRenderOpacity(self.FCanvasPanel_60, 1)
end

function CommRewardItemView:OnRegisterUIEvent()

end

function CommRewardItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.StoreMysteryAnimEvent, self.OnStoreMysteryAnimEvent)
end

function CommRewardItemView:OnRegisterBinder()
	local Params = self.Params
	if Params == nil then
			return
	end
	local ViewModel = Params.Data
	if ViewModel == nil then
			return
	end
	self.ViewModel = ViewModel
	self:RegisterBinders(ViewModel, self.Binders)
end

function CommRewardItemView:OnNameChanged(NewValue)
	-- 由于有些是临时调用通用奖励界面没有自己vm,用的ItemVM 所以需要保留这个"Name"。  “ItemName” 和 “Name” 同时存在 显示ItemName
	local ViewModel = self.ViewModel 
	if ViewModel and (ViewModel.ItemName or "") ~= "" then
		return
	end
	if (NewValue or "") == "" then
		self.TextName:SetText("")
	else
		self.TextName:SetText(NewValue)
	end
end

function CommRewardItemView:OnAnimationFinished(Animation)
	local ViewModel = self.ViewModel 
	if Animation == self.AnimIn_1 and ViewModel then
		if ViewModel.PlayAddEffect then
			self:PlayAnimation(self.AnimAdditionUpNumber)
		end
		if ViewModel.RewardItemPlayAnimIn then 
			ViewModel.RewardItemPlayAnimIn = nil
		end
	end

	if Animation == self.AnimAdditionUpNumber and ViewModel and ViewModel.IncrementedNum then
		self.TextUpNumber:SetText(ItemUtil.GetItemNumText(ViewModel.IncrementedNum))
	end
end

function CommRewardItemView:SequenceEvent_SetUpNumber()
	local ViewModel = self.ViewModel 
	if ViewModel and ViewModel.PlayAddEffect then
		local OriginalNum = ViewModel.OriginalNum or 0
		local IncrementedNum = ViewModel.IncrementedNum or 0
		local ShowValue = math.floor(self.ValueAddition * (IncrementedNum - OriginalNum) + OriginalNum + 0.5)
		self.TextUpNumber:SetText(ItemUtil.GetItemNumText(ShowValue))
    end
end

function CommRewardItemView:OnStoreMysteryAnimEvent(Index)
	if self.Params.Index == Index then
		self.Comm152Slot:PlayAnimation(self.Comm152Slot.AnimTurn)
	end
end

function CommRewardItemView:OnRewardItemPlayAnimInChanged(NewValue)
	if NewValue then 
		self:PlayAnimation(self.AnimIn_1)
	end
end

return CommRewardItemView