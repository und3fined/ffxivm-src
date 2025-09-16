---
--- Author: peterxie
--- DateTime:
--- Description: 战场日志
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local LocalizationUtil = require("Utils/LocalizationUtil")
local PVPColosseumBattleLogVM = require("Game/PVP/Colosseum/VM/PVPColosseumBattleLogVM")
local UIAdapterCountDown = require("UI/Adapter/UIAdapterCountDown")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")


---@class PVPColosseumBattleLogView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EffectTimeBg UFImage
---@field ImgEarlyWarning UFImage
---@field ImgTimeBg UFImage
---@field PVPColosseumBattleLog1 PVPColosseumBattleLogItemView
---@field PVPColosseumBattleLog2 PVPColosseumBattleLogItemView
---@field PanelTime UFCanvasPanel
---@field RichTextContent URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPColosseumBattleLogView = LuaClass(UIView, true)

function PVPColosseumBattleLogView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EffectTimeBg = nil
	--self.ImgEarlyWarning = nil
	--self.ImgTimeBg = nil
	--self.PVPColosseumBattleLog1 = nil
	--self.PVPColosseumBattleLog2 = nil
	--self.PanelTime = nil
	--self.RichTextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPColosseumBattleLogView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PVPColosseumBattleLog1)
	self:AddSubView(self.PVPColosseumBattleLog2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPColosseumBattleLogView:OnInit()
	self.AdapterCountDownTime = UIAdapterCountDown.CreateAdapter(self, self.RichTextContent, nil, nil, self.TimeOutCallback, self.TimeUpdateCallback)

	self.Binders =
	{
		{ "CountDownVisible", UIBinderSetIsVisible.New(self, self.PanelTime) },
		{ "CountDownIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgEarlyWarning) },
		{ "CountDownBg", UIBinderSetBrushFromAssetPath.New(self, self.ImgTimeBg) },
		{ "CountDownBgEffect", UIBinderSetIsVisible.New(self, self.EffectTimeBg) },
		{ "CountDownEndTime", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedCountDownEndTime) },
	}
end

function PVPColosseumBattleLogView:OnDestroy()

end

function PVPColosseumBattleLogView:OnShow()
	if PVPColosseumBattleLogVM.CountDownVisible then
		-- 断线重连后，PVP主界面会重新显示，此时倒计时定时器会被重置，需要重新设置
		self:OnValueChangedCountDownEndTime()
	end
end

function PVPColosseumBattleLogView:OnHide()

end

function PVPColosseumBattleLogView:OnRegisterUIEvent()

end

function PVPColosseumBattleLogView:OnRegisterGameEvent()

end

function PVPColosseumBattleLogView:OnRegisterBinder()
	self:RegisterBinders(PVPColosseumBattleLogVM, self.Binders)
	self.PVPColosseumBattleLog1:SetViewModel(PVPColosseumBattleLogVM.LogVM1)
	self.PVPColosseumBattleLog2:SetViewModel(PVPColosseumBattleLogVM.LogVM2)
end

function PVPColosseumBattleLogView:OnValueChangedCountDownEndTime(Value)
	self.AdapterCountDownTime.StrFormat = PVPColosseumBattleLogVM.CountDownContent
	self.AdapterCountDownTime:Start(PVPColosseumBattleLogVM.CountDownEndTime, 1, true, true)
end

function PVPColosseumBattleLogView:TimeOutCallback()
	PVPColosseumBattleLogVM:HideCountDownInfo()
end

function PVPColosseumBattleLogView:TimeUpdateCallback(LeftTime)
	LeftTime = math.floor(LeftTime + 0.5)
	LeftTime = math.max(LeftTime, 1)
	return LocalizationUtil.GetCountdownTimeForSimpleTime(LeftTime, "s")
end

return PVPColosseumBattleLogView