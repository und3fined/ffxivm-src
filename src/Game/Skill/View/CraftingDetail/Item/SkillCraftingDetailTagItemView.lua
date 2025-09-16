---
--- Author: henghaoli
--- DateTime: 2024-04-18 11:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local SkillTagCfg = require("TableCfg/SkillTagCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")

local ESkillTagType <const> = ProtoRes.ESkillTagType



---@class SkillCraftingDetailTagItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FImgYellow UFImage
---@field TextOutput UFTextBlock
---@field TypeOutput UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillCraftingDetailTagItemView = LuaClass(UIView, true)

function SkillCraftingDetailTagItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FImgYellow = nil
	--self.TextOutput = nil
	--self.TypeOutput = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillCraftingDetailTagItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillCraftingDetailTagItemView:OnInit()

end

function SkillCraftingDetailTagItemView:OnDestroy()

end

function SkillCraftingDetailTagItemView:OnShow()
	UIUtil.SetIsVisible(self.TypeOutput, false)
	local Params = self.Params
	if not Params then
		return
	end
	local Data = Params.Data
	if not Data then
		return
	end

	if Data.ChocoboSkillTypePath and Data.ChocoboSkillTypeText then
		UIUtil.SetIsVisible(self.TypeOutput, true)
		UIUtil.ImageSetBrushFromAssetPath(self.FImgYellow, Data.ChocoboSkillTypePath)
		self.TextOutput:SetText(Data.ChocoboSkillTypeText)
		return
	end
	
	local TagType = Data[1]
	if not TagType then
		self:SetCommSkillTips()
		return
	end

	UIUtil.SetIsVisible(self.TypeOutput, true)
	local AssetColorPath = SkillTagCfg:FindValue(TagType, "BgImgPath")
	UIUtil.ImageSetBrushFromAssetPath(self.FImgYellow, AssetColorPath or "")

	local TagName = ProtoEnumAlias.GetAlias(ESkillTagType, TagType)
	self.TextOutput:SetText(TagName)
end

function SkillCraftingDetailTagItemView:OnHide()

end

function SkillCraftingDetailTagItemView:OnRegisterUIEvent()

end

function SkillCraftingDetailTagItemView:OnRegisterGameEvent()

end

function SkillCraftingDetailTagItemView:OnRegisterBinder()

end

function SkillCraftingDetailTagItemView:SetCommSkillTips()
	if self.Params.Data.bIsMountActionItem == true and nil ~= self.Params.Data.Tag then
		UIUtil.SetIsVisible(self.TypeOutput, true)
		local TagName = self.Params.Data.Tag
		self.TextOutput:SetText(TagName)
	end
end

return SkillCraftingDetailTagItemView