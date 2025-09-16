---
--- Author: henghaoli
--- DateTime: 2023-11-22 15:56
--- Description:
---

local LuaClass = require("Core/LuaClass")
local CrafterConfig = require("Define/CrafterConfig")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local CrafterArmorerBlacksmithMainPanelViewBase = require("Game/Crafter/View/ArmorerBlacksmithBase/CrafterArmorerBlacksmithMainPanelViewBase")

---@class CrafterBlacksmithMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgMaterial1 UFImage
---@field ImgMaterial4 UFImage
---@field ImgMaterial6 UFImage
---@field ImgProp1 UFImage
---@field ImgProp4 UFImage
---@field ImgProp6 UFImage
---@field ImgWeapon1 UFImage
---@field ImgWeapon4 UFImage
---@field ImgWeapon6 UFImage
---@field LeatherworkerSkill1 CrafterSkillItemView
---@field LeatherworkerSkill2 CrafterSkillItemView
---@field LeatherworkerSkill3 CrafterSkillItemView
---@field MakeNormalPanel UFCanvasPanel
---@field PanelSkill UFCanvasPanel
---@field Tap1 CrafterBlacksmithTapItem1View
---@field Tap2 CrafterBlacksmithTapItem2View
---@field Tap3 CrafterBlacksmithTapItem3View
---@field Tap4 CrafterBlacksmithTapItem4View
---@field Tap41 CrafterBlacksmithTapItem1View
---@field Tap42 CrafterBlacksmithTapItem3View
---@field Tap43 CrafterBlacksmithTapItem4View
---@field Tap44 CrafterBlacksmithTapItem6View
---@field Tap5 CrafterBlacksmithTapItem5View
---@field Tap6 CrafterBlacksmithTapItem6View
---@field TapPanel4 UFCanvasPanel
---@field TapPanel6 UFCanvasPanel
---@field TextTips UFTextBlock
---@field AnimCool UWidgetAnimation
---@field AnimHeat UWidgetAnimation
---@field AnimHotOver UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimSkillSwitchOff UWidgetAnimation
---@field AnimSkillSwitchOn UWidgetAnimation
---@field ButtonIndex_Normal int
---@field ButtonIndex_HotForge int
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CrafterBlacksmithMainPanelView = LuaClass(CrafterArmorerBlacksmithMainPanelViewBase, true)

function CrafterBlacksmithMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgMaterial1 = nil
	--self.ImgMaterial4 = nil
	--self.ImgMaterial6 = nil
	--self.ImgProp1 = nil
	--self.ImgProp4 = nil
	--self.ImgProp6 = nil
	--self.ImgWeapon1 = nil
	--self.ImgWeapon4 = nil
	--self.ImgWeapon6 = nil
	--self.LeatherworkerSkill1 = nil
	--self.LeatherworkerSkill2 = nil
	--self.LeatherworkerSkill3 = nil
	--self.MakeNormalPanel = nil
	--self.PanelSkill = nil
	--self.Tap1 = nil
	--self.Tap2 = nil
	--self.Tap3 = nil
	--self.Tap4 = nil
	--self.Tap41 = nil
	--self.Tap42 = nil
	--self.Tap43 = nil
	--self.Tap44 = nil
	--self.Tap5 = nil
	--self.Tap6 = nil
	--self.TapPanel4 = nil
	--self.TapPanel6 = nil
	--self.TextTips = nil
	--self.AnimCool = nil
	--self.AnimHeat = nil
	--self.AnimHotOver = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimSkillSwitchOff = nil
	--self.AnimSkillSwitchOn = nil
	--self.ButtonIndex_Normal = nil
	--self.ButtonIndex_HotForge = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CrafterBlacksmithMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.LeatherworkerSkill1)
	self:AddSubView(self.LeatherworkerSkill2)
	self:AddSubView(self.LeatherworkerSkill3)
	self:AddSubView(self.Tap1)
	self:AddSubView(self.Tap2)
	self:AddSubView(self.Tap3)
	self:AddSubView(self.Tap4)
	self:AddSubView(self.Tap41)
	self:AddSubView(self.Tap42)
	self:AddSubView(self.Tap43)
	self:AddSubView(self.Tap44)
	self:AddSubView(self.Tap5)
	self:AddSubView(self.Tap6)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CrafterBlacksmithMainPanelView:OnInit()
	-- 首先在Super:OnInit()前保证各个枚举已经被初始化
	local BlacksmithCrafterConfig = CrafterConfig.ProfConfig[ProtoCommon.prof_type.PROF_TYPE_BLACKSMITH]
    self.EPanelType = BlacksmithCrafterConfig.EPanelType
    self.EHeatType = BlacksmithCrafterConfig.EHeatType
    self.EItemType = BlacksmithCrafterConfig.EItemType
    self.MaxTapNum = BlacksmithCrafterConfig.MaxTapNum

	self.Super:OnInit()

	local EItemMainType = ProtoCommon.ItemMainType
	local EItemType = self.EItemType
	self.ItemTypeMap = {
		-- 剑
		[EItemMainType.ItemArm]  = EItemType.Weapon,
		[EItemMainType.ItemTool] = EItemType.Weapon,

		-- 铁锭
		[EItemMainType.ItemMaterial] = EItemType.Material,

		-- 螺丝钉
		[EItemMainType.ItemCollage] = EItemType.Prop,
		[EItemMainType.ItemHousing] = EItemType.Prop,
	}

	self.SkillBuffID = 4303
end

function CrafterBlacksmithMainPanelView:OnDestroy()
	self.Super:OnDestroy()
end

function CrafterBlacksmithMainPanelView:OnShow()
	self.Super:OnShow()
end

function CrafterBlacksmithMainPanelView:OnHide()
	self.Super:OnHide()
end

function CrafterBlacksmithMainPanelView:OnRegisterUIEvent()
	self.Super:OnRegisterUIEvent()
end

function CrafterBlacksmithMainPanelView:OnRegisterGameEvent()
	self.Super:OnRegisterGameEvent()
end

function CrafterBlacksmithMainPanelView:OnRegisterBinder()
	self.Super:OnRegisterBinder()

	local Binders = {
		{"bIsTapPanel4Visible", UIBinderSetIsVisible.New(self, self.TapPanel4)},
		{"bIsTapPanel6Visible", UIBinderSetIsVisible.New(self, self.TapPanel6)},
	}
	self:RegisterBinders(self.CrafterArmorerBlacksmithVM, Binders)
end

return CrafterBlacksmithMainPanelView