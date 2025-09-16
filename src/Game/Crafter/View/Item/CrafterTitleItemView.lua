---
--- Author: henghaoli
--- DateTime: 2024-09-09 15:50
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local prof_type = ProtoCommon.prof_type

local CrafterTitleConfig = {
	[prof_type.PROF_TYPE_ALCHEMIST] = {
		Bg = "Texture2D'/Game/UI/Texture/Crafter/UI_Crafter_Icon_AlchemistBg.UI_Crafter_Icon_AlchemistBg'",
		Icon = "Texture2D'/Game/UI/Texture/Crafter/UI_Crafter_Icon_Alchemist.UI_Crafter_Icon_Alchemist'",
	},
	[prof_type.PROF_TYPE_ARMOR] = {
		Bg = "Texture2D'/Game/UI/Texture/Crafter/UI_Crafter_Icon_ArmorerBg.UI_Crafter_Icon_ArmorerBg'",
		Icon = "Texture2D'/Game/UI/Texture/Crafter/UI_Crafter_Icon_Armorer.UI_Crafter_Icon_Armorer'",
	},
	[prof_type.PROF_TYPE_BLACKSMITH] = {
		Bg = "Texture2D'/Game/UI/Texture/Crafter/UI_Crafter_Icon_BlacksmithBg.UI_Crafter_Icon_BlacksmithBg'",
		Icon = "Texture2D'/Game/UI/Texture/Crafter/UI_Crafter_Icon_Blacksmith.UI_Crafter_Icon_Blacksmith'",
	},
	[prof_type.PROF_TYPE_BOTANIST] = {
		Bg = "Texture2D'/Game/UI/Texture/Crafter/UI_Crafter_Icon_BotanistBg.UI_Crafter_Icon_BotanistBg'",
		Icon = "Texture2D'/Game/UI/Texture/Crafter/UI_Crafter_Icon_Botanist.UI_Crafter_Icon_Botanist'",
	},
	[prof_type.PROF_TYPE_CARPENTER] = {
		Bg = "Texture2D'/Game/UI/Texture/Crafter/UI_Crafter_Icon_CarpenterBg.UI_Crafter_Icon_CarpenterBg'",
		Icon = "Texture2D'/Game/UI/Texture/Crafter/UI_Crafter_Icon_Carpenter.UI_Crafter_Icon_Carpenter'",
	},
	[prof_type.PROF_TYPE_CULINARIAN] = {
		Bg = "Texture2D'/Game/UI/Texture/Crafter/UI_Crafter_Icon_CulinarianBg.UI_Crafter_Icon_CulinarianBg'",
		Icon = "Texture2D'/Game/UI/Texture/Crafter/UI_Crafter_Icon_Culinarian.UI_Crafter_Icon_Culinarian'",
	},
	[prof_type.PROF_TYPE_GOLDSMITH] = {
		Bg = "Texture2D'/Game/UI/Texture/Crafter/UI_Crafter_Icon_GoldsmithBg.UI_Crafter_Icon_GoldsmithBg'",
		Icon = "Texture2D'/Game/UI/Texture/Crafter/UI_Crafter_Icon_Goldsmith.UI_Crafter_Icon_Goldsmith'",
	},
	[prof_type.PROF_TYPE_LEATHER_WORK] = {
		Bg = "Texture2D'/Game/UI/Texture/Crafter/UI_Crafter_Icon_LeatherworkerBg.UI_Crafter_Icon_LeatherworkerBg'",
		Icon = "Texture2D'/Game/UI/Texture/Crafter/UI_Crafter_Icon_Leatherworker.UI_Crafter_Icon_Leatherworker'",
	},
	[prof_type.PROF_TYPE_MINER] = {
		Bg = "Texture2D'/Game/UI/Texture/Crafter/UI_Crafter_Icon_MinerBg.UI_Crafter_Icon_MinerBg'",
		Icon = "Texture2D'/Game/UI/Texture/Crafter/UI_Crafter_Icon_Miner.UI_Crafter_Icon_Miner'",
	},
	[prof_type.PROF_TYPE_WEAVER] = {
		Bg = "Texture2D'/Game/UI/Texture/Crafter/UI_Crafter_Icon_WeaverBg.UI_Crafter_Icon_WeaverBg'",
		Icon = "Texture2D'/Game/UI/Texture/Crafter/UI_Crafter_Icon_Weaver.UI_Crafter_Icon_Weaver'",
	}
}

---@class CrafterTitleItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgCrafterIcon UFImage
---@field ImgSidebarBg2 UFImage
---@field ImgSidebarBgLight UFImage
---@field PanelText UFCanvasPanel
---@field TextTitleName UFTextBlock
---@field AnimShow UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CrafterTitleItemView = LuaClass(UIView, true)

function CrafterTitleItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgCrafterIcon = nil
	--self.ImgSidebarBg2 = nil
	--self.ImgSidebarBgLight = nil
	--self.PanelText = nil
	--self.TextTitleName = nil
	--self.AnimShow = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CrafterTitleItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CrafterTitleItemView:OnInit()

end

function CrafterTitleItemView:OnDestroy()

end

function CrafterTitleItemView:OnShow() 
	local ProfID = MajorUtil.GetMajorProfID()
	if not ProfID then
		return
	end

	local Config = CrafterTitleConfig[ProfID]
	if not Config then
		return
	end

	UIUtil.ImageSetBrushFromAssetPath(self.ImgSidebarBg2, Config.Bg)
	UIUtil.ImageSetBrushFromAssetPath(self.ImgCrafterIcon, Config.Icon)
	UIUtil.ImageSetMaterialTextureFromAssetPathSync(self.ImgSidebarBgLight, Config.Bg, "MainTexture")
	self:PlayAnimation(self.AnimShow)
end

function CrafterTitleItemView:OnHide()

end

function CrafterTitleItemView:OnRegisterUIEvent()

end

function CrafterTitleItemView:OnRegisterGameEvent()

end

function CrafterTitleItemView:OnRegisterBinder()

end

function CrafterTitleItemView:SetTitleByProf()
	local ProfID = MajorUtil.GetMajorProfID()
	self.TextTitleName:SetText(ProtoEnumAlias.GetAlias(prof_type, ProfID))
end

function CrafterTitleItemView:SetTitle(Title)
	self.TextTitleName:SetText(Title)
end

return CrafterTitleItemView