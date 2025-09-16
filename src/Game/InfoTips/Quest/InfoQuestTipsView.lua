---
--- Author: ashyuan
--- DateTime: 2024-08-28 16:08
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local InfoTipsBaseView = require("Game/InfoTips/InfoTipsBaseView")
local UIBinderSetMaterialTextureFromAssetPath = require("Binder/UIBinderSetMaterialTextureFromAssetPath")
local UIBinderSetBrushFromAssetPath =  require("Binder/UIBinderSetBrushFromAssetPath")
local InfoQuestTipsVM = require("Game/InfoTips/Quest/InfoQuestTipsVM")
local QuestHelper = require("Game/Quest/QuestHelper")
local QuestGenreCfg = require("TableCfg/QuestGenreCfg")

local LSTR = _G.LSTR

---@class InfoQuestTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgMask UFImage
---@field ImgQuest UFImage
---@field PanelQuest UFCanvasPanel
---@field TextQuestTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field T_DX_Mask_InfoTips_Quest_Important Texture2D
---@field T_DX_Mask_InfoTips_Quest_Main Texture2D
---@field T_DX_Mask_InfoTips_Quest_Newbie Texture2D
---@field T_DX_Mask_InfoTips_Quest_Side Texture2D
---@field T_DX_Mask_InfoTips_Quest_Tribal Texture2D
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local InfoQuestTipsView = LuaClass(InfoTipsBaseView, true)

function InfoQuestTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgMask = nil
	--self.ImgQuest = nil
	--self.PanelQuest = nil
	--self.TextQuestTitle = nil
	--self.AnimIn = nil
	--self.T_DX_Mask_InfoTips_Quest_Important = nil
	--self.T_DX_Mask_InfoTips_Quest_Main = nil
	--self.T_DX_Mask_InfoTips_Quest_Newbie = nil
	--self.T_DX_Mask_InfoTips_Quest_Side = nil
	--self.T_DX_Mask_InfoTips_Quest_Tribal = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function InfoQuestTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function InfoQuestTipsView:OnInit()

end

function InfoQuestTipsView:OnDestroy()

end

function InfoQuestTipsView:OnShow()
	self.Super:OnShow()

	-- 判断使命类型
	local TitleText = self.Params.Content
	self.TextQuestTitle:SetText(TitleText)

	local ChapterCfgItem = QuestHelper.GetChapterCfgItem(self.Params.ChapterID)
	if ChapterCfgItem then
		local GenreType = math.floor(ChapterCfgItem.QuestGenreID / 10000)
		if GenreType == 1 then
			InfoQuestTipsVM.IconPath = "Texture2D'/Game/UI/Texture/InfoTips/Quest/UI_InfoTips_Img_Quest_Main.UI_InfoTips_Img_Quest_Main'"
			InfoQuestTipsVM.MaskPath = "Texture2D'/Game/UMG/UI_Effect/Texture/Mask/T_DX_Mask_InfoTips_Quest_Main.T_DX_Mask_InfoTips_Quest_Main'"
		elseif GenreType == 2 then
			InfoQuestTipsVM.IconPath = "Texture2D'/Game/UI/Texture/InfoTips/Quest/UI_InfoTips_Img_Quest_Important.UI_InfoTips_Img_Quest_Important'"
			InfoQuestTipsVM.MaskPath = "Texture2D'/Game/UMG/UI_Effect/Texture/Mask/T_DX_Mask_InfoTips_Quest_Important.T_DX_Mask_InfoTips_Quest_Important'"
		else
			InfoQuestTipsVM.IconPath = "Texture2D'/Game/UI/Texture/InfoTips/Quest/UI_InfoTips_Img_Quest_Side.UI_InfoTips_Img_Quest_Side'"
			InfoQuestTipsVM.MaskPath = "Texture2D'/Game/UMG/UI_Effect/Texture/Mask/T_DX_Mask_InfoTips_Quest_Side.T_DX_Mask_InfoTips_Quest_Side'"
		end
	end
end

function InfoQuestTipsView:OnHide()
	if self.Params and self.Params.Callback then
		self.Params.Callback()
	end
end

function InfoQuestTipsView:OnRegisterUIEvent()

end

function InfoQuestTipsView:OnRegisterGameEvent()

end

function InfoQuestTipsView:OnRegisterTimer()
	self.Super:OnRegisterTimer()
end

function InfoQuestTipsView:OnRegisterBinder()
	local Binders = {
		{ "IconPath", UIBinderSetBrushFromAssetPath.New(self, self.ImgQuest) },
		{ "MaskPath", UIBinderSetMaterialTextureFromAssetPath.New(self, self.ImgMask, "Mask") },
	}

	self:RegisterBinders(InfoQuestTipsVM, Binders)
end

return InfoQuestTipsView