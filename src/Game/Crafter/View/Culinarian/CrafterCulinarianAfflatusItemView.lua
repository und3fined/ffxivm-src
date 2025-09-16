---
--- Author: henghaoli
--- DateTime: 2024-01-04 15:37
--- Description:
---

local LuaClass = require("Core/LuaClass")
local CrafterSkillItemView = require("Game/Crafter/View/Item/CrafterSkillItemView")
local MajorUtil = require("Utils/MajorUtil")
local UIUtil = require("Utils/UIUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MsgTipsID = require("Define/MsgTipsID")

local CrafterConfig = require("Define/CrafterConfig")
local ProtoCommon = require("Protocol/ProtoCommon")

local PracticeShowDelay <const> = 0.5  -- 实践技能元素变化需要配合动画有一个延迟
local PracticeSkillID <const> = CrafterConfig.ProfConfig[ProtoCommon.prof_type.PROF_TYPE_CULINARIAN].PracticeSkillID
local ErrorCode_CulinarianAfflatusIndexLockMask <const> = CrafterConfig.SkillCheckErrorCode.CulinarianAfflatusIndexLock

---@class CrafterCulinarianAfflatusItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSkill UFButton
---@field Element CrafterCulinarianElementItemView
---@field ElementDrop CrafterCulinarianElementItemView
---@field ImgBg UFImage
---@field ImgDropLight UFImage
---@field ImgLight UFImage
---@field ImgMask UFImage
---@field ImgRefresh UFImage
---@field ImgRefreshMask UFImage
---@field RefreshPanel UFCanvasPanel
---@field AnimDrop UWidgetAnimation
---@field AnimLight UWidgetAnimation
---@field AnimMask UWidgetAnimation
---@field AnimNormal UWidgetAnimation
---@field ButtonIndex int
---@field AfflatusIndex int
---@field ElementItemColor1 LinearColor
---@field ElementItemColor2 LinearColor
---@field ElementItemColor3 LinearColor
---@field ElementItemColor4 LinearColor
---@field ElementItemColor5 LinearColor
---@field ElementItemColor6 LinearColor
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CrafterCulinarianAfflatusItemView = LuaClass(CrafterSkillItemView, true)

function CrafterCulinarianAfflatusItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSkill = nil
	--self.Element = nil
	--self.ElementDrop = nil
	--self.ImgBg = nil
	--self.ImgDropLight = nil
	--self.ImgLight = nil
	--self.ImgMask = nil
	--self.ImgRefresh = nil
	--self.ImgRefreshMask = nil
	--self.RefreshPanel = nil
	--self.AnimDrop = nil
	--self.AnimLight = nil
	--self.AnimMask = nil
	--self.AnimNormal = nil
	--self.ButtonIndex = nil
	--self.AfflatusIndex = nil
	--self.ElementItemColor1 = nil
	--self.ElementItemColor2 = nil
	--self.ElementItemColor3 = nil
	--self.ElementItemColor4 = nil
	--self.ElementItemColor5 = nil
	--self.ElementItemColor6 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CrafterCulinarianAfflatusItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Element)
	self:AddSubView(self.ElementDrop)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CrafterCulinarianAfflatusItemView:OnShow()
	self.Super:OnShow()
end

function CrafterCulinarianAfflatusItemView:OnRegisterGameEvent()
	self.Super:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.CrafterSkillRsp, self.OnEventCrafterSkillRsp)
end

function CrafterCulinarianAfflatusItemView:OnRegisterBinder()
	local Binders = {
		{ "bCommonMask", UIBinderValueChangedCallback.New(self, nil, self.OnCommonMaskChanged) },
		{ "bRefreshPanelVisible", UIBinderSetIsVisible.New(self, self.RefreshPanel) },
		{ "BgState", UIBinderValueChangedCallback.New(self, nil, self.OnBgStateChanged) },
	}

	local BaseBtnVM = self.BaseBtnVM
	if BaseBtnVM.bRefreshPanelVisible == nil then
		BaseBtnVM.bRefreshPanelVisible = false
	end
	if BaseBtnVM.BgState == nil then
		BaseBtnVM.BgState = 0
	end

	self:RegisterBinders(BaseBtnVM, Binders)
end

function CrafterCulinarianAfflatusItemView:OnCommonMaskChanged(bCommonMask)
	UIUtil.SetIsVisible(self.ImgRefreshMask, bCommonMask)
	UIUtil.SetIsVisible(self.ImgRefresh, not bCommonMask)
end

local HasElementMask = 1 << 0
local TripleMask = 1 << 1

function CrafterCulinarianAfflatusItemView:OnBgStateChanged(State)
	self:StopAllAnimations()
	if State == 0 then
		self:PlayAnimation(self.AnimMask)
	elseif (State & TripleMask) > 0 then
		self:PlayAnimation(self.AnimLight)
	else
		self:PlayAnimation(self.AnimNormal)
	end
end

function CrafterCulinarianAfflatusItemView:BgStateUpdateMask(Mask, Flag)
	local BaseBtnVM = self.BaseBtnVM
	if BaseBtnVM then
		local BgState = BaseBtnVM.BgState
		if BgState == nil then
			return
		end

		if Flag then
			BaseBtnVM.BgState = BgState | Mask
		else
			BaseBtnVM.BgState = BgState & ~Mask
		end
	end
end

function CrafterCulinarianAfflatusItemView:SetHasElement(bHasElement)
	return self:BgStateUpdateMask(HasElementMask, bHasElement)
end

function CrafterCulinarianAfflatusItemView:SetIsTriple(bIsTriple)
	return self:BgStateUpdateMask(TripleMask, bIsTriple)
end

function CrafterCulinarianAfflatusItemView:CheckViewCorrespondingToSkill(Index, SkillID, ExtraParams)
	if not self.Super:CheckViewCorrespondingToSkill(Index, SkillID) then
		return false
	end
	if ExtraParams.CulinarySecretIndex ~= self.AfflatusIndex then
		return false
	end
	return true
end

function CrafterCulinarianAfflatusItemView:CheckCanCastSkill()
	local MaskFlag = self.MaskFlag
	local EMaskType = self:GetEMaskType()
	if MaskFlag ~= 0 then
		if (MaskFlag & (1 << EMaskType.AfflatusInspireStorm)) ~= 0 then
			MsgTipsUtil.ShowTipsByID(MsgTipsID.CrafterAfflatusInspireStormMask)
		elseif (MaskFlag & (1 << EMaskType.AfflatusLock)) ~= 0 then
			-- MsgTipsUtil.ShowTips(LSTR("只能对同一位置使用技能'秘技'!"))
			MsgTipsUtil.ShowTipsByID(MsgTipsID.CulinarianAfflatusIndexLockMask)
		end
		return false, ErrorCode_CulinarianAfflatusIndexLockMask
	end

	return true, nil
end

function CrafterCulinarianAfflatusItemView:OnClickBtnSkill()
	local ParentVM = self.ParentView.CrafterCulinarianVM
	self.__Current = self.__BaseType
	if self.Super:OnClickBtnSkill({ CulinarySecretIndex = self.AfflatusIndex }) then
		ParentVM.AfflatusLockIndex = self.AfflatusIndex
	end
end

function CrafterCulinarianAfflatusItemView:OnEventCrafterSkillRspInternal(MsgBody)
	local MajorEntityID = MajorUtil.GetMajorEntityID()
	if MajorEntityID == MsgBody.ObjID then
		local Culinary = MsgBody.CrafterSkill.Culinary
		if nil == Culinary then
			return
		end

		local ElementVM = self.ElementVM
		-- lua下标从1开始, 所以Index需要加1
		local ElementType = Culinary.InspireElement[self.AfflatusIndex + 1]
		ElementVM.ElementType = ElementType
		self:SetHasElement(ElementType ~= 0)

		local ElementItemColor = self["ElementItemColor" .. tostring(ElementType)]
		if ElementItemColor then
			self.ImgDropLight:SetColorAndOpacity(ElementItemColor)
		end
		local DropVM = self.ElementDrop.VM
		if DropVM then
			DropVM.ElementType = ElementType
		end
	end
end

function CrafterCulinarianAfflatusItemView:OnEventCrafterSkillRsp(MsgBody)
	if MsgBody and MsgBody.CrafterSkill then
		if MsgBody.LifeSkillID == PracticeSkillID then
			self:RegisterTimer(self.OnEventCrafterSkillRspInternal, PracticeShowDelay, 0, 1, MsgBody)
		else
			self:OnEventCrafterSkillRspInternal(MsgBody)
		end
	end
end

return CrafterCulinarianAfflatusItemView