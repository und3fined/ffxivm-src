---
--- Author: henghaoli
--- DateTime: 2023-11-22 14:59
--- Description:
---

local CrafterConfig = require("Define/CrafterConfig")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local LuaClass = require("Core/LuaClass")
local CrafterArmorerBlacksmithMainPanelViewBase = require("Game/Crafter/View/ArmorerBlacksmithBase/CrafterArmorerBlacksmithMainPanelViewBase")

---@class CrafterArmorerMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgMaterial1 UFImage
---@field ImgMaterial4 UFImage
---@field ImgProp1 UFImage
---@field ImgProp4 UFImage
---@field ImgWeapon1 UFImage
---@field ImgWeapon4 UFImage
---@field LeatherworkerSkill1 CrafterSkillItemView
---@field LeatherworkerSkill2 CrafterSkillItemView
---@field LeatherworkerSkill3 CrafterSkillItemView
---@field MakeNormalPanel UFCanvasPanel
---@field PanelSkill UFCanvasPanel
---@field Tap41 CrafterBlacksmithTapItem1View
---@field Tap42 CrafterBlacksmithTapItem3View
---@field Tap43 CrafterBlacksmithTapItem4View
---@field Tap44 CrafterBlacksmithTapItem6View
---@field TapPanel4 UFCanvasPanel
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
local CrafterArmorerMainPanelView = LuaClass(CrafterArmorerBlacksmithMainPanelViewBase, true)

function CrafterArmorerMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgMaterial1 = nil
	--self.ImgMaterial4 = nil
	--self.ImgProp1 = nil
	--self.ImgProp4 = nil
	--self.ImgWeapon1 = nil
	--self.ImgWeapon4 = nil
	--self.LeatherworkerSkill1 = nil
	--self.LeatherworkerSkill2 = nil
	--self.LeatherworkerSkill3 = nil
	--self.MakeNormalPanel = nil
	--self.PanelSkill = nil
	--self.Tap41 = nil
	--self.Tap42 = nil
	--self.Tap43 = nil
	--self.Tap44 = nil
	--self.TapPanel4 = nil
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

function CrafterArmorerMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.LeatherworkerSkill1)
	self:AddSubView(self.LeatherworkerSkill2)
	self:AddSubView(self.LeatherworkerSkill3)
	self:AddSubView(self.Tap41)
	self:AddSubView(self.Tap42)
	self:AddSubView(self.Tap43)
	self:AddSubView(self.Tap44)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CrafterArmorerMainPanelView:OnInit()
	-- 首先在Super:OnInit()前保证各个枚举已经被初始化
	local ArmorerCrafterConfig = CrafterConfig.ProfConfig[ProtoCommon.prof_type.PROF_TYPE_ARMOR]
	self.EPanelType = ArmorerCrafterConfig.EPanelType
	self.EHeatType = ArmorerCrafterConfig.EHeatType
	self.EItemType = ArmorerCrafterConfig.EItemType
	self.MaxTapNum = ArmorerCrafterConfig.MaxTapNum

	self.Super:OnInit()

	-- 铸甲的UI没有做6格子的Panel, 因此不注册相关的UI
	self.TapPanel6SubViewList = { }

	local EItemMainType = ProtoCommon.ItemMainType
	local EItemType = self.EItemType
	self.ItemTypeMap = {
		-- 盔甲
		[EItemMainType.ItemArmor]  = EItemType.Weapon,
		[EItemMainType.ItemArm] = EItemType.Weapon,

		-- 铁锭
		[EItemMainType.ItemMaterial] = EItemType.Material,
		[EItemMainType.ItemTool] = EItemType.Material,

		-- 螺丝钉
		[EItemMainType.ItemCollage] = EItemType.Prop,
		[EItemMainType.ItemHousing] = EItemType.Prop,
		[EItemMainType.ItemMiscellany] = EItemType.Prop,
	}

	self.SkillBuffID = 4403
end

function CrafterArmorerMainPanelView:OnDestroy()
	self.Super:OnDestroy()
end

function CrafterArmorerMainPanelView:OnShow()
	self.Super:OnShow()
end

function CrafterArmorerMainPanelView:OnHide()
	self.Super:OnHide()
end

function CrafterArmorerMainPanelView:OnRegisterUIEvent()
	self.Super:OnRegisterUIEvent()
end

function CrafterArmorerMainPanelView:OnRegisterGameEvent()
	self.Super:OnRegisterGameEvent()
end

function CrafterArmorerMainPanelView:OnRegisterBinder()
	self.Super:OnRegisterBinder()

	-- 铸甲的UI没有做6格子的Panel, 因此不注册相关的事件
	local Binders = {
		{"bIsTapPanel4Visible", UIBinderSetIsVisible.New(self, self.TapPanel4)},
		-- {"bIsTapPanel6Visible", UIBinderSetIsVisible.New(self, self.TapPanel6)},
	}
	self:RegisterBinders(self.CrafterArmorerBlacksmithVM, Binders)
end

return CrafterArmorerMainPanelView