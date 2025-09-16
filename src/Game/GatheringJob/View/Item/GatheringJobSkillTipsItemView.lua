---
--- Author: v_vvxinchen
--- DateTime: 2023-12-08 17:43
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class GatheringJobSkillTipsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBG UFImage
---@field TextLable UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GatheringJobSkillTipsItemView = LuaClass(UIView, true)

function GatheringJobSkillTipsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBG = nil
	--self.TextLable = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GatheringJobSkillTipsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GatheringJobSkillTipsItemView:OnInit()

end

function GatheringJobSkillTipsItemView:OnDestroy()

end

function GatheringJobSkillTipsItemView:OnShow()
	if self.Params and self.Params.Data then
		local TagType = self.Params.Data.TagType or 3
		local TagBg = ""
		if TagType == 1 then
			TagBg = "PaperSprite'/Game/UI/Atlas/Skill/Frames/UI_GatheringJob_Img_Label_Blue_png.UI_GatheringJob_Img_Label_Blue_png'"
		elseif TagType == 2 then
			TagBg = "PaperSprite'/Game/UI/Atlas/Skill/Frames/UI_GatheringJob_Img_Label_Red_png.UI_GatheringJob_Img_Label_Red_png'"
		else
			TagBg = "PaperSprite'/Game/UI/Atlas/Skill/Frames/UI_GatheringJob_Img_Label_Green_png.UI_GatheringJob_Img_Label_Green_png'"
		end

		UIUtil.ImageSetBrushFromAssetPath(self.ImgBG, TagBg)

		local TagName = self.Params.Data.TagName or ""
		self.TextLable:SetText(TagName)
	end
end

function GatheringJobSkillTipsItemView:OnHide()

end

function GatheringJobSkillTipsItemView:OnRegisterUIEvent()

end

function GatheringJobSkillTipsItemView:OnRegisterGameEvent()

end

function GatheringJobSkillTipsItemView:OnRegisterBinder()

end

return GatheringJobSkillTipsItemView