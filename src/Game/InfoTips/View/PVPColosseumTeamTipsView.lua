---
--- Author: peterxie
--- DateTime:
--- Description: 水晶冲突队伍提示
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local InfoTipsBaseView = require("Game/InfoTips/InfoTipsBaseView")


---@class PVPColosseumTeamTipsView : InfoTipsBaseView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBg UFImage
---@field ImgBgFrame UFImage
---@field RichTextContent URichTextBox
---@field AnimBlueIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimRedIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPColosseumTeamTipsView = LuaClass(InfoTipsBaseView, true)

function PVPColosseumTeamTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBg = nil
	--self.ImgBgFrame = nil
	--self.RichTextContent = nil
	--self.AnimBlueIn = nil
	--self.AnimOut = nil
	--self.AnimRedIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPColosseumTeamTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPColosseumTeamTipsView:OnInit()

end

function PVPColosseumTeamTipsView:OnDestroy()

end

function PVPColosseumTeamTipsView:OnShow()
	self.Super:OnShow()

	local Params = self.Params
	if Params then
		local OutlineColor
		if Params.IsBlueTeam then
			UIUtil.ImageSetBrushFromAssetPath(self.ImgBg, "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPMain_Img_CommandBlueBg.UI_PVPMain_Img_CommandBlueBg'")
			UIUtil.ImageSetBrushFromAssetPath(self.ImgBgFrame, "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPMain_Img_CommandBlue1.UI_PVPMain_Img_CommandBlue1'")
			OutlineColor = "184bb97f"
			self:PlayAnimation(self.AnimBlueIn)
		else
			UIUtil.ImageSetBrushFromAssetPath(self.ImgBg, "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPMain_Img_CommandRedBg.UI_PVPMain_Img_CommandRedBg'")
			UIUtil.ImageSetBrushFromAssetPath(self.ImgBgFrame, "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPMain_Img_CommandRed1.UI_PVPMain_Img_CommandRed1'")
			OutlineColor = "ba2a447f"
			self:PlayAnimation(self.AnimRedIn)
		end

		local RichText = RichTextUtil.GetText(Params.Content, nil, OutlineColor)
		self.RichTextContent:SetText(RichText)
	end
end

function PVPColosseumTeamTipsView:OnHide()

end

function PVPColosseumTeamTipsView:OnRegisterUIEvent()

end

function PVPColosseumTeamTipsView:OnRegisterGameEvent()

end

function PVPColosseumTeamTipsView:OnRegisterBinder()

end

function PVPColosseumTeamTipsView:OnRegisterTimer()
	self.Super:OnRegisterTimer()
end

return PVPColosseumTeamTipsView