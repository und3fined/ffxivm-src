---
--- Author: henghaoli
--- DateTime: 2024-01-04 15:37
--- Description:
---

local LuaClass = require("Core/LuaClass")
local CrafterSkillItemView = require("Game/Crafter/View/Item/CrafterSkillItemView")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetTextFormat = require("Binder/UIBinderSetTextFormat")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIUtil = require("Utils/UIUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MsgTipsID = require("Define/MsgTipsID")
local CrafterConfig = require("Define/CrafterConfig")
local ErrorCode_CulinarianPracticeNotValid <const> = CrafterConfig.SkillCheckErrorCode.CulinarianPracticeNotValid

---@class CrafterCulinarianSkillItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSkill UFButton
---@field ImgIcon UFImage
---@field MainPanel UFCanvasPanel
---@field TextInfo UFTextBlock
---@field AnimInspirationStormHide UWidgetAnimation
---@field AnimInspirationStormShow UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field ButtonIndex int
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CrafterCulinarianSkillItemView = LuaClass(CrafterSkillItemView, true)

function CrafterCulinarianSkillItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSkill = nil
	--self.ImgIcon = nil
	--self.MainPanel = nil
	--self.TextInfo = nil
	--self.AnimInspirationStormHide = nil
	--self.AnimInspirationStormShow = nil
	--self.AnimLoop = nil
	--self.ButtonIndex = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CrafterCulinarianSkillItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CrafterCulinarianSkillItemView:OnRegisterBinder()
	local Binders = {
		{ "SkillIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIcon) },
		{ "SkillIcon", UIBinderValueChangedCallback.New(self, nil, self.OnSkillIconPathChanged) },
		{ "bCommonMask", UIBinderValueChangedCallback.New(self, nil, self.OnCommonMaskChanged) },
		{ "bLevelText", UIBinderSetIsVisible.New(self, self.TextInfo) },
		{ "bLockedByLevel", UIBinderValueChangedCallback.New(self, nil, self.OnLevelTextVisibleChanged) },
		{ "LevelText", UIBinderSetTextFormat.New(self, self.TextInfo, _G.LSTR(170061)) },  -- %d级
		{ "bIsVisible", UIBinderSetIsVisible.New(self, self.BtnSkill, false, true, true ) },
	}

	local BaseBtnVM = self.BaseBtnVM
	BaseBtnVM.bIsVisible = true

	self:RegisterBinders(self.BaseBtnVM, Binders)
end

function CrafterCulinarianSkillItemView:OnShow()
	self.Super:OnShow()
	self:OnLevelTextVisibleChanged(self.BaseBtnVM.bLockedByLevel)
end

function CrafterCulinarianSkillItemView:CheckCanCastSkill()
	if self.MaskFlag ~= 0 then
		local ParentVM = self.ParentView.CrafterCulinarianVM
		local Name = self.Object:GetName()
		if not ParentVM.bHasAfflatus and Name == "BtnImpulse" then
			-- MsgTipsUtil.ShowTips(LSTR("使用技能'实践'前, 请先使用技能'灵感'!"))
			MsgTipsUtil.ShowTipsByID(MsgTipsID.CulinarianPracticeNotValid)
		end
		return false, ErrorCode_CulinarianPracticeNotValid
	end
	return true, nil
end

function CrafterCulinarianSkillItemView:OnClickBtnSkill()
	-- # TODO - LuaClass已知问题, 通过function直接调用不会改变__Current
	self.__Current = self.__BaseType
	self.Super:OnClickBtnSkill()
end

function CrafterCulinarianSkillItemView:OnSkillIconPathChanged(IconPath)
	self.IconPath = IconPath
end

function CrafterCulinarianSkillItemView:OnCommonMaskChanged(bCommonMask)
	local AssetPath
	if bCommonMask then
		AssetPath = string.gsub(self.IconPath, "_Useable_", "_Disable_")
	else
		AssetPath = self.IconPath
	end
	UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, AssetPath)
end

function CrafterCulinarianSkillItemView:OnLevelTextVisibleChanged(bIsLevelTextVisible)
	local Name = self.Object:GetName()
	if Name == "BtnMemory" then
		-- 如果未学会技能, 不显示
		self.BaseBtnVM.bIsVisible = not bIsLevelTextVisible
	end
end

return CrafterCulinarianSkillItemView