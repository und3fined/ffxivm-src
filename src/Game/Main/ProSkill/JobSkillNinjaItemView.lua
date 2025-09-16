---
--- Author: chaooren
--- DateTime: 2022-12-21 11:09
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")

local NinjaHutonImgConfig = {
	["Day"] = {
		ImgSymbol    = "PaperSprite'/Game/UI/Atlas/JobSkill/Ninja/Frames/UI_Ninja_Img_SymbolDay_png.UI_Ninja_Img_SymbolDay_png'",
		ProBarSymbol = "Texture2D'/Game/UI/Texture/JobSkill/UI_Ninja_Img_SymbolDay.UI_Ninja_Img_SymbolDay'",
		ImgColorBkg  = "PaperSprite'/Game/UI/Atlas/JobSkill/Ninja/Frames/UI_Ninja_Img_ColorDayBkg_png.UI_Ninja_Img_ColorDayBkg_png'",
	},
	["Land"] = {
		ImgSymbol    = "PaperSprite'/Game/UI/Atlas/JobSkill/Ninja/Frames/UI_Ninja_Img_Symbolland_png.UI_Ninja_Img_Symbolland_png'",
		ProBarSymbol = "Texture2D'/Game/UI/Texture/JobSkill/UI_Ninja_Img_Symbolland.UI_Ninja_Img_Symbolland'",
		ImgColorBkg  = "PaperSprite'/Game/UI/Atlas/JobSkill/Ninja/Frames/UI_Ninja_Img_ColorlandBkg_png.UI_Ninja_Img_ColorlandBkg_png'",
	},
	["People"] = {
		ImgSymbol    = "PaperSprite'/Game/UI/Atlas/JobSkill/Ninja/Frames/UI_Ninja_Img_SymbolPeople_png.UI_Ninja_Img_SymbolPeople_png'",
		ProBarSymbol =  "Texture2D'/Game/UI/Texture/JobSkill/UI_Ninja_Img_SymbolPeople.UI_Ninja_Img_SymbolPeople'",
		ImgColorBkg  = "PaperSprite'/Game/UI/Atlas/JobSkill/Ninja/Frames/UI_Ninja_Img_ColorPeopleBkg_png.UI_Ninja_Img_ColorPeopleBkg_png'",
	},
}

local SealBuffID = 1250  -- 结印的BuffID

---@class JobSkillNinjaItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Common_ProSkillInteract_UIBP CommonProSkillInteractView
---@field FButton_80 UFButton
---@field FCanvasPanel UFCanvasPanel
---@field ImgCircle UFImage
---@field ImgColorBkg UFImage
---@field ImgSymbol UFImage
---@field ProBarSymbol UProgressBar
---@field TextLevel UFTextBlock
---@field AnimClickDay UWidgetAnimation
---@field AnimClickLand UWidgetAnimation
---@field AnimClickPeople UWidgetAnimation
---@field AnimEnergy0 UWidgetAnimation
---@field AnimEnergy1 UWidgetAnimation
---@field AnimReadyDay UWidgetAnimation
---@field AnimReadyLand UWidgetAnimation
---@field AnimReadyPeople UWidgetAnimation
---@field ButtonIndex int
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JobSkillNinjaItemView = LuaClass(UIView, true)

function JobSkillNinjaItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Common_ProSkillInteract_UIBP = nil
	--self.FButton_80 = nil
	--self.FCanvasPanel = nil
	--self.ImgCircle = nil
	--self.ImgColorBkg = nil
	--self.ImgSymbol = nil
	--self.ProBarSymbol = nil
	--self.TextLevel = nil
	--self.AnimClickDay = nil
	--self.AnimClickLand = nil
	--self.AnimClickPeople = nil
	--self.AnimEnergy0 = nil
	--self.AnimEnergy1 = nil
	--self.AnimReadyDay = nil
	--self.AnimReadyLand = nil
	--self.AnimReadyPeople = nil
	--self.ButtonIndex = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JobSkillNinjaItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Common_ProSkillInteract_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JobSkillNinjaItemView:OnInit()
	local CommonView = self.Common_ProSkillInteract_UIBP
	CommonView:RegisterRechargeObj(self, self.RechargeUpdate, self.RechargeInit)
	CommonView:RegisterNormalCDObj(self, self.OnCDUpdate)
	CommonView:RegisterOnSkillReplace(self, self.OnSkillReplace)
	CommonView:RegisterOnMajorUseSkill(self, self.OnMajorUseSkill)

	local Binders = {
		{ "bTextRechargeTimes", UIBinderSetIsVisible.New(nil, self.TextLevel) },
		{ "RechargeTimeText", UIBinderSetText.New(nil, self.TextLevel) },
		{ "ChargeCDPercent", UIBinderSetPercent.New(nil, self.ProBarSymbol) },
		{ "bCommonMask", UIBinderSetIsVisible.New(nil, self.ImgMask) },
	}
	CommonView:SetExtraBinders(Binders)
end

function JobSkillNinjaItemView:InitHutonType(HutonType)
	self.HutonType = HutonType

	local HutonImgMap = NinjaHutonImgConfig[HutonType]
	UIUtil.ImageSetBrushFromAssetPath(self.ImgSymbol, HutonImgMap.ImgSymbol)
	UIUtil.ImageSetBrushFromAssetPath(self.ImgColorBkg, HutonImgMap.ImgColorBkg)
	UIUtil.ProgressBarSetFillImage(self.ProBarSymbol, HutonImgMap.ProBarSymbol)
end

function JobSkillNinjaItemView:OnDestroy()

end

function JobSkillNinjaItemView:OnShow()

end

function JobSkillNinjaItemView:UpdateView(Params)
	self.Common_ProSkillInteract_UIBP:UpdateView(Params)
end

function JobSkillNinjaItemView:OnHide()
	self.bHasEnergy = nil
end

function JobSkillNinjaItemView:OnRegisterUIEvent()

end

function JobSkillNinjaItemView:OnRegisterGameEvent()
	local EventID = _G.EventID
	self:RegisterGameEvent(EventID.RemoveBuff, self.OnRemoveBuff)
end

function JobSkillNinjaItemView:OnRegisterBinder()
	local SkillVM = self.Common_ProSkillInteract_UIBP.BaseBtnVM
	if SkillVM then
		SkillVM.bTextRechargeTimes = true
		SkillVM.ChargeCDPercent = 1
	end
end

function JobSkillNinjaItemView:OnRemoveBuff(Params)
	local BuffID = Params.IntParam1
	local EntityID = Params.ULongParam1

	if EntityID ~= MajorUtil.GetMajorEntityID() then
		return
	end

	if BuffID == SealBuffID then
		self:PlayAnimation(self.AnimWaitClickOut)
	end
end

function JobSkillNinjaItemView:OnEntityIDUpdate(EntityID, bMajor)
	self.Common_ProSkillInteract_UIBP:OnEntityIDUpdate(EntityID, bMajor)
end

function JobSkillNinjaItemView:UpdateTextVisible()
	local MaxChargeCount = self.MaxChargeCount or 0
	local bIsInSeal = self.bIsInSeal

	local SkillVM = self.Common_ProSkillInteract_UIBP.BaseBtnVM
	if not SkillVM then
		return
	end

	if not bIsInSeal and MaxChargeCount > 1 then
		SkillVM.bTextRechargeTimes = true
	else
		SkillVM.bTextRechargeTimes = false
	end
end


function JobSkillNinjaItemView:OnSkillReplace(Params)
	local SkillID = Params.SkillID
	local SkillVM = self.Common_ProSkillInteract_UIBP.BaseBtnVM
	if not SkillVM or not SkillID or SkillID == 0 then
		return
	end

	if not self.OriginSkillID then
		self.OriginSkillID = SkillID
	end

	-- 说明技能替换成了结印的技能
	if SkillID ~= self.OriginSkillID then
		SkillVM.ChargeCDPercent = 1
		self:SetEnergyState(true)
		self.bIsInSeal = true
		self.Common_ProSkillInteract_UIBP.ReChargeCD = 0
	else
		self.bIsInSeal = false
	end
	self:UpdateTextVisible()
end

function JobSkillNinjaItemView:OnMajorUseSkill(Params)
	self:PlayAnimation(self["AnimClick" .. self.HutonType])
	self:PlayAnimation(self.AnimWaitClickIn)
end

function JobSkillNinjaItemView:RechargeUpdate(Params)
	local CommonView = self.Common_ProSkillInteract_UIBP
	local SkillVM = CommonView.BaseBtnVM
	SkillVM.ChargeCDPercent = 1 - Params.MaskPercent

	local ChargeData = Params.ChargeData
	self.MaxChargeCount = ChargeData.MaxChargeCount
	self:UpdateTextVisible()

	CommonView.ReChargeCD = 0
	local CurChargeCount = ChargeData.CurChargeCount
	if CurChargeCount < 1 then
		CommonView.ReChargeCD = ChargeData.ReChargeCD
	end

	self:OnChargeCountChanged(CurChargeCount)
end

function JobSkillNinjaItemView:OnCDUpdate(Params)
	-- 非结印技能不更新
	if not self.bIsInSeal then
		return
	end

	local CurrentCD = Params.SkillCD
	local BaseCD = Params.BaseCD

	local CDPercent = math.clamp(CurrentCD / BaseCD, 0, 1)
	local SkillVM = self.Common_ProSkillInteract_UIBP.BaseBtnVM
	SkillVM.ChargeCDPercent = 1 - CDPercent
end

function JobSkillNinjaItemView:RechargeInit(_, CurChargeCount, MaxChargeCount)
	if not CurChargeCount then
		return
	end

	self.MaxChargeCount = MaxChargeCount
	self:UpdateTextVisible()
	self:OnChargeCountChanged(CurChargeCount)
end

-- 更新金色/灰色的显示
-- # TODO - 如果后面变得复杂, 用VM控制
function JobSkillNinjaItemView:SetEnergyState(bHasEnergy)
	if self.IsShowView then
		self.ParentView:SetEnergyState(bHasEnergy)
	end

	if self.bHasEnergy == bHasEnergy then
		return
	end

	if bHasEnergy then
		self:PlayAnimation(self.AnimEnergy1)
	else
		self:PlayAnimation(self.AnimEnergy0)
	end
	self.bHasEnergy = bHasEnergy
end

function JobSkillNinjaItemView:UpdateEnergyState(NewChargeCount)
	if NewChargeCount >= 1 then
		self:SetEnergyState(true)
	end

	if NewChargeCount == 0 then
		self:SetEnergyState(false)
	end
end

function JobSkillNinjaItemView:OnChargeCountChanged(NewChargeCount)
	local SkillVM = self.Common_ProSkillInteract_UIBP.BaseBtnVM
	local LastChargeCount = tonumber(SkillVM.RechargeTimeText)
	local CurChargeCount = NewChargeCount
	SkillVM.RechargeTimeText = tostring(CurChargeCount)

	if CurChargeCount < 1 then
		UIUtil.TextBlockSetColorAndOpacity(self.TextLevel, 1, 0, 0, 1)
	else
		UIUtil.TextBlockSetColorAndOpacity(self.TextLevel, 1, 1, 1, 1)
	end

	self:UpdateEnergyState(CurChargeCount)

	if nil == LastChargeCount then
		return
	end

	-- 层数加1, 播放Ready动效
	if CurChargeCount - LastChargeCount == 1 then
		self:PlayAnimation(self["AnimReady" .. self.HutonType])
	end
end

return JobSkillNinjaItemView