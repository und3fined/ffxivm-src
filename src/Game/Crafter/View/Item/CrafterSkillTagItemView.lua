---
--- Author: chriswang
--- DateTime: 2023-08-31 17:26
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local SkillTagCfg = require("TableCfg/SkillTagCfg")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")

local ESkillTagType <const> = ProtoRes.ESkillTagType

---@class CrafterSkillTagItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgColorBg UFImage
---@field SkillTagPanel UFCanvasPanel
---@field TextTypes UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CrafterSkillTagItemView = LuaClass(UIView, true)

function CrafterSkillTagItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgColorBg = nil
	--self.SkillTagPanel = nil
	--self.TextTypes = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CrafterSkillTagItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CrafterSkillTagItemView:OnInit()

end

function CrafterSkillTagItemView:OnDestroy()

end

function CrafterSkillTagItemView:OnShow()
	if self.Params and self.Params.Data then
		local TagType = self.Params.Data[1]
		local AssetColorPath = SkillTagCfg:FindValue(TagType, "BgImgPath")
		UIUtil.ImageSetBrushFromAssetPath(self.ImgColorBg, AssetColorPath or "")

		local TagName = ProtoEnumAlias.GetAlias(ESkillTagType, TagType)
		self.TextTypes:SetText(TagName)
	end

end

function CrafterSkillTagItemView:OnHide()

end

function CrafterSkillTagItemView:OnRegisterUIEvent()

end

function CrafterSkillTagItemView:OnRegisterGameEvent()

end

function CrafterSkillTagItemView:OnRegisterBinder()

end

return CrafterSkillTagItemView