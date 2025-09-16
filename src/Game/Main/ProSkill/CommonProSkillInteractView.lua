---
--- Author: chaooren
--- DateTime: 2022-08-25 09:44
--- Description:
---

local UIUtil = require("Utils/UIUtil")
local LuaClass = require("Core/LuaClass")
local MainSkillBaseView = require("Game/MainSkillBtn/MainSkillBaseView")
local SkillButtonStateMgr = require("Game/Skill/SkillButtonStateMgr")
local SkillBtnState = SkillButtonStateMgr.SkillBtnState
local EventID = require("Define/EventID")

local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class CommonProSkillInteractView : MainSkillBaseView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Icon_Skill UFImage
---@field NamedSlotChild UNamedSlot
---@field AnimCDFinish UWidgetAnimation
---@field ButtonIndex int
---@field SupportRecharge bool
---@field SupportCD bool
---@field IconVisible bool
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommonProSkillInteractView = LuaClass(MainSkillBaseView, true)

function CommonProSkillInteractView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Icon_Skill = nil
	--self.NamedSlotChild = nil
	--self.AnimCDFinish = nil
	--self.ButtonIndex = nil
	--self.SupportRecharge = nil
	--self.SupportCD = nil
	--self.IconVisible = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommonProSkillInteractView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommonProSkillInteractView:OnInit()
	if self.ButtonIndex > -1 then
		self.Super:OnInit()
		self.HasReChargeConfig = self.SupportRecharge
		self.HasCDConfig = self.SupportCD
	end
end

function CommonProSkillInteractView:OnDestroy()

end

function CommonProSkillInteractView:OnShow()
	if self.ButtonIndex > -1 then
		self.Super:OnShow()
	end
end

function CommonProSkillInteractView:OnHide()
	self.Super:OnHide()
end

function CommonProSkillInteractView:OnRegisterUIEvent()

end

function CommonProSkillInteractView:OnRegisterGameEvent()
	if self.ButtonIndex > -1 then
		self.Super:OnRegisterGameEvent()
		if self.HasReChargeConfig then
			self:RegisterGameEvent(EventID.SkillChargeUpdateLua, self.OnSkillChargeUpdate)
			self:RegisterGameEvent(EventID.SkillMaxChargeCountChange, self.OnSkillMaxChargeCountChange)
		end
	end
end

function CommonProSkillInteractView:OnRegisterBinder()
	local VM = self.BaseBtnVM
	if not VM then
		return
	end
	if self.IconVisible then
		local Binders = {
			{"SkillIcon", UIBinderSetBrushFromAssetPath.New(self, self.Icon_Skill)},
		}
		UIUtil.SetIsVisible(self.Icon_Skill, true)
		self:RegisterBinders(VM, Binders)
	end
	if self.ExtraBinders then
		self:RegisterBinders(VM, self.ExtraBinders)
	end
end

function CommonProSkillInteractView:UpdateView(Params)
	self:SetParams(Params)

	self:OnShow()

	local SubViews = self.SubViews
	if nil == SubViews then
		return
	end

	for i = 1, #SubViews do
		local v = SubViews[i]
		if v:IsVisible() then
			local Fun = v.UpdateView
			if nil ~= Fun then
				Fun(v, rawget(self, "Params"))
			end
		end
	end
end

function CommonProSkillInteractView:RegisterNormalCDObj(View, Callback)
	self.CDView = View
	self.UpdateCD = Callback
end

function CommonProSkillInteractView:OnSkillCDUpdate(Params)
	--支持CD的话会调用到这里
	local SkillID = Params.SkillID
	if SkillID ~= self.BtnSkillID then
		return
	end

	local CurCD = Params.SkillCD
	self.SkillCD = CurCD
	if self.UpdateCD ~= nil then
		self.UpdateCD(self.CDView, Params)
	end

	if Params.SkillCD == 0 then
		self:PlayAnimationToEndTime(self.AnimCDFinish)
	end
end

function CommonProSkillInteractView:ClearCDMask(_)
	self.SkillCD = 0
	if self.UpdateCD ~= nil then
		self.UpdateCD(self.CDView, {SkillID = self.BtnSkillID, BaseCD = 1, SkillCD = 0})
	end
end

function CommonProSkillInteractView:RegisterRechargeObj(View, Callback, InitCallback)
	self.ChargeView = View
	self.UpdateCharge = Callback
	self.InitChargeCount = InitCallback
end

function CommonProSkillInteractView:RegisterOnSkillReplace(View, Callback)
	self.OnSkillReplaceView = View
	self.OnSkillReplaceCallback = Callback
end

function CommonProSkillInteractView:RegisterOnMajorUseSkill(View, Callback)
	self.OnMajorUseSkillView = View
	self.OnMajorUseSkillCallback = Callback
end

function CommonProSkillInteractView:OnGameEventMajorUseSkill(Params)
	if self.OnMajorUseSkillView and self.OnMajorUseSkillCallback then
		self.OnMajorUseSkillCallback(self.OnMajorUseSkillView, Params)
	end
end

function CommonProSkillInteractView:OnSkillReplace(Params)
	self.Super:OnSkillReplace(Params)
	if self.OnSkillReplaceView and self.OnSkillReplaceCallback then
		self.OnSkillReplaceCallback(self.OnSkillReplaceView, Params)
	end
end

function CommonProSkillInteractView:OnSkillChargeUpdate(Params)
	--如果支持充能的话，会调用到这里
	local SkillID = Params.SkillID
	if SkillID ~= self.BtnSkillID then
		return
	end

	if self.UpdateCharge ~= nil then
		self.UpdateCharge(self.ChargeView, Params)
	end
end

function CommonProSkillInteractView:OnSkillMaxChargeCountChange(Params)
	if Params.SkillID == self.BtnSkillID then
		self:InitRechargeInfo(Params.SkillID)
	end
end

function CommonProSkillInteractView:InitRechargeInfo(SkillID)
	if self.HasReChargeConfig and self.InitChargeCount then
		--充能CD替换
		local CurChargeCount, MaxChargeCount = _G.SkillCDMgr:GetSkillChargeCount(SkillID)
		self.InitChargeCount(self.ChargeView, SkillID, CurChargeCount, MaxChargeCount)
	end
end

function CommonProSkillInteractView:SetExtraBinders(Binders)
	self.ExtraBinders = Binders
end

function CommonProSkillInteractView:OnSkillReplaceDisplay(Params)
	self:InitRechargeInfo(Params.SkillID)
	self.Super:OnSkillReplaceDisplay(Params)
end

return CommonProSkillInteractView