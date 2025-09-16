---
--- Author: Administrator
--- DateTime: 2024-01-22 16:21
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local FishTimerPanelVM = require("Game/Fish/ItemVM/FishTimerPanelVM")
local FishDefine = require("Game/Fish/FishDefine")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderIsLoopAnimPlay = require("Binder/UIBinderIsLoopAnimPlay")
local UIBinderUpdateCountDown = require("Binder/UIBinderUpdateCountDown")
local UIAdapterCountDown = require("UI/Adapter/UIAdapterCountDown")

---@class FishNewTimeItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgMask UFImage
---@field Probar UProgressBar
---@field TextBite UFTextBlock
---@field TextThrow UFTextBlock
---@field TextTime UFTextBlock
---@field AnimBiteIn UWidgetAnimation
---@field AnimBiteLoop UWidgetAnimation
---@field AnimHide UWidgetAnimation
---@field AnimShow UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishNewTimeItemView = LuaClass(UIView, true)

local TimerUpdatedelta = 0.1
local DisappearDelayTime = 2

function FishNewTimeItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgMask = nil
	--self.Probar = nil
	--self.TextBite = nil
	--self.TextThrow = nil
	--self.TextTime = nil
	--self.AnimBiteIn = nil
	--self.AnimBiteLoop = nil
	--self.AnimHide = nil
	--self.AnimShow = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishNewTimeItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishNewTimeItemView:OnInit()
	self.FishTimerPanelVM = FishTimerPanelVM.New()
	self.AdapterBiteCountDownTime = UIAdapterCountDown.CreateAdapter(self, self.TextTime, nil, nil, self.OnFishBite, self.BiteTimeUpdateCallback)
	self.DisappearTimer = nil
	self.ClearTimer = nil

	self.Binder = {
		{ "ThrowTime", UIBinderUpdateCountDown.New(self, self.AdapterBiteCountDownTime, 0.1, false, false)},
		{ "IsThrowing",UIBinderSetIsVisible.New(self, self.TextThrow, false, true)},
		{ "IsBite",UIBinderSetIsVisible.New(self, self.TextBite, false, true)},
		{ "IsStop",UIBinderSetIsVisible.New(self, self.ImgMask, false, true)},
		{ "ThrowTimePercent", UIBinderSetPercent.New(self, self.Probar)},
		{ "PlayBiteAnim", UIBinderIsLoopAnimPlay.New(self, nil,self.AnimBiteLoop,true) },
	}
	self:OnSetText()
end

function FishNewTimeItemView:OnDestroy()

end

function FishNewTimeItemView:OnShow()

end

function FishNewTimeItemView:OnHide()

end

function FishNewTimeItemView:OnRegisterUIEvent()

end

function FishNewTimeItemView:OnRegisterGameEvent()

end

function FishNewTimeItemView:OnRegisterBinder()
	self:RegisterBinders(self.FishTimerPanelVM,self.Binder)
end

function FishNewTimeItemView:OnSetText()
	local FishNewTimeItemText = FishDefine.FishNewTimeItemText
	self.TextThrow:SetText(FishNewTimeItemText.TextThrow)
	self.TextBite:SetText(FishNewTimeItemText.TextBite)
end
 
function FishNewTimeItemView:OnFishDrop(BiteTime)
	-- 清理计时面板延时消失的计时器，防止延时消失的逻辑影响到下一次钓鱼
	if self.DisappearTimer then
		self:UnRegisterTimer(self.DisappearTimer)
		self.DisappearTimer = nil
	end
	self.FishTimerPanelVM:ClearVM()
	self:ShowPanel(true)
	self.FishTimerPanelVM:OnFishDrop(BiteTime)
end

function FishNewTimeItemView:OnFishBite()
	self.FishTimerPanelVM:OnFishBite()
	self:PlayAnimation(self.AnimBiteIn)
end

function FishNewTimeItemView:OnFishLift()
	self.FishTimerPanelVM:OnFishLift()
	if nil == self.DisappearTimer then
		self.DisappearTimer = self:RegisterTimer(self.ClearFishData,DisappearDelayTime, 0.2, 1)
	end
end

function FishNewTimeItemView:OnFishEnd()
	if nil == self.DisappearTimer and self.FishTimerPanelVM:IsFishing() then
		-- 计时面板延时消失
		self.DisappearTimer = self:RegisterTimer(self.ClearFishData,DisappearDelayTime, 0.2, 1)
	end
	self.FishTimerPanelVM:OnFishEnd()
end


function FishNewTimeItemView:ClearFishData()
	if not self.FishTimerPanelVM:IsFishing() then
		self:ShowPanel(false)
		self.ClearTimer = self:RegisterTimer(self.ClearFishVM,0.2,0.2,1)
	end
	self.DisappearTimer = nil
end

function FishNewTimeItemView:ShowPanel(bShow)
	if bShow then
		self:PlayAnimation(self.AnimShow)
	else
		self:PlayAnimation(self.AnimHide)
	end
end

function FishNewTimeItemView:BiteTimeUpdateCallback(LeftTime)
	return self.FishTimerPanelVM:BiteTimeUpdateCallback(LeftTime)
end

function FishNewTimeItemView:ClearFishVM()
	self.FishTimerPanelVM:ClearVM()
	self.ClearTimer = nil
end

-- MainPanel隐藏时清理进度条逻辑，因为UI已经Hide所以不能使用定时器，立刻触发逻辑
function FishNewTimeItemView:HideClearData()
	self.FishTimerPanelVM:OnFishEnd()
	self:ShowPanel(false)
	self:ClearFishVM()
end

return FishNewTimeItemView