--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2024-12-02 18:51:33
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2024-12-04 10:32:58
FilePath: \Client\Source\Script\Game\CraftingLog\View\CraftingLogSetCraftTimesWinView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
---
--- Author: ghnvbnvb
--- DateTime: 2023-04-24 10:45
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local CraftingLogSetCraftTimesWinVM = require("Game/CraftingLog/CraftingLogSetCraftTimesWinVM")
local CraftingLogDefine = require("Game/CraftingLog/CraftingLogDefine")
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID

---@class CraftingLogSetCraftTimesWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bg Comm2FrameMView
---@field BtnFinish CommBtnLView
---@field BtnStop CommBtnLView
---@field Comm2FrameS_UIBP Comm2FrameSView
---@field CommEditQuantity CommEditQuantityItemView
---@field SliderHorizontal CommSliderHorizontalView
---@field TextNumber01 UFTextBlock
---@field TextNumber02 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CraftingLogSetCraftTimesWinView = LuaClass(UIView, true)

function CraftingLogSetCraftTimesWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bg = nil
	--self.BtnFinish = nil
	--self.BtnStop = nil
	--self.Comm2FrameS_UIBP = nil
	--self.CommEditQuantity = nil
	--self.SliderHorizontal = nil
	--self.TextNumber01 = nil
	--self.TextNumber02 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CraftingLogSetCraftTimesWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Bg)
	self:AddSubView(self.BtnFinish)
	self:AddSubView(self.BtnStop)
	self:AddSubView(self.Comm2FrameS_UIBP)
	self:AddSubView(self.CommEditQuantity)
	self:AddSubView(self.SliderHorizontal)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CraftingLogSetCraftTimesWinView:OnInit()
	self.SliderHorizontal:SetValueChangedCallback(
		function(v)
			self:OnValueChangedCallback(v)
		end
	)
end

function CraftingLogSetCraftTimesWinView:OnValueChangedCallback(Value)
	-- 四舍五入
	local ChoiceNumber = math.floor(Value + 0.5)
	if (ChoiceNumber == 0) then
		ChoiceNumber = CraftingLogDefine.NormalLowestMakeCount
	end

	self:SetSliderValue(ChoiceNumber)
	self.CommEditQuantity:SetCurValue(ChoiceNumber)
end

function CraftingLogSetCraftTimesWinView:OnDestroy()
end

function CraftingLogSetCraftTimesWinView:OnShow()
	if _G.CraftingLogMgr.NowPropData.CanHQ == 0 then
		self.Comm2FrameS_UIBP:SetTitleText(_G.LSTR(80053)) --简易制作
	else
		self.Comm2FrameS_UIBP:SetTitleText(_G.LSTR(80072)) --快速制作80072)
	end
	self.BtnStop:SetText(_G.LSTR(10003)) --取  消
	self.BtnFinish:SetText(_G.LSTR(80054)) --开  始

	self.MaxMakeCount = _G.CrafterMgr:GetMaxSimpleMakeCount()
	_G.CrafterMgr:SetNowSimpleMakeCount(self.MaxMakeCount)
	self.TextNumber02:SetText(self.MaxMakeCount)
	local LowestMakeCount = CraftingLogDefine.NormalLowestMakeCount

	--Slider Init
	self.SliderHorizontal.Slider:SetMaxValue(self.MaxMakeCount)
	self.SliderHorizontal.Slider:SetMinValue(LowestMakeCount)
	self:SetSliderValue(LowestMakeCount)

	---CommEditor Init
	self.CommEditQuantity:SetInputUpperLimit(self.MaxMakeCount)
	self.CommEditQuantity:SetInputLowerLimit(LowestMakeCount)
	self.CommEditQuantity:SetCurValue(LowestMakeCount)
	self.CommEditQuantity:SetModifyValueCallback(function (MakeCount)
		self:SetSliderValue(MakeCount)
	end)
end

function CraftingLogSetCraftTimesWinView:OnHide()
end


function CraftingLogSetCraftTimesWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnStop, self.OnMakeAmountBtnClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnFinish, self.OnFinishBtnClicked)
	UIUtil.AddOnClickedEvent(self, self.Bg.ButtonClose, self.OnCloseBtnOnClicked)
end

function CraftingLogSetCraftTimesWinView:OnCloseBtnOnClicked()
	UIViewMgr:HideView(UIViewID.CraftingLogSetCraftTimesWinView)
end

function CraftingLogSetCraftTimesWinView:OnMakeAmountBtnClicked()
	UIViewMgr:HideView(UIViewID.CraftingLogSetCraftTimesWinView)
end

function CraftingLogSetCraftTimesWinView:OnFinishBtnClicked()
	if _G.MountMgr:IsInRide() then
		-- 坐骑
		local MajorUtil = require("Utils/MajorUtil")
		local Major = MajorUtil.GetMajor()
		if Major:IsRideFlying() then 
			_G.MsgTipsUtil.ShowTips(_G.LSTR(80073)) --坐骑飞行中，无法制作80073
			return
		end
		if _G.ChocoboTransportMgr:GetIsTransporting() then
			_G.MsgTipsUtil.ShowTipsByID(109700)
			return
		end
		_G.MountMgr:ForceSendMountCancelCall(function()
			_G.CraftingLogMgr:SendStartSimpleMakeReq()
		end)
	else
		--开始制作，并进入制作状态
		_G.CraftingLogMgr:SendStartSimpleMakeReq()
		UIViewMgr:HideView(UIViewID.CraftingLogSetCraftTimesWinView, true)
	end
end


function CraftingLogSetCraftTimesWinView:OnRegisterGameEvent()
end

function CraftingLogSetCraftTimesWinView:OnRegisterBinder()
	self.Binders = {
		{"MakeAmount", UIBinderSetTextFormat.New(self, self.TextAmount, "%d") },
	}
	self:RegisterBinders(CraftingLogSetCraftTimesWinVM, self.Binders)
end


function CraftingLogSetCraftTimesWinView:SetSliderValue(Value)
	_G.CrafterMgr:SetNowSimpleMakeCount(Value)
	CraftingLogSetCraftTimesWinVM:SetMakeAmount(Value)

	if self.MaxMakeCount == 1 and Value == 1 then
		self.SliderHorizontal.ProgressBar:SetPercent(1)
	else
		self.SliderHorizontal.ProgressBar:SetPercent((Value - 1) / (self.MaxMakeCount - 1))
	end
	self.SliderHorizontal.Slider:SetValue(Value)
	self.SliderHorizontal.LastValue = Value
end

return CraftingLogSetCraftTimesWinView
