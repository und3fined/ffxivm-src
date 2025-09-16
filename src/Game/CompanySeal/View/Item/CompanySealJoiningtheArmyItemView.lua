---
--- Author: Administrator
--- DateTime: 2024-08-23 14:43
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CompanySealMgr = require("Game/CompanySeal/CompanySealMgr")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")

local GrandCompanyImg = {
	"Texture2D'/Game/UI/Texture/CompanySeal/UI_CompanySeal_Img_TheMaelstrom.UI_CompanySeal_Img_TheMaelstrom'",
	"Texture2D'/Game/UI/Texture/CompanySeal/UI_CompanySeal_Img_TheOrderoftheTwinAdder.UI_CompanySeal_Img_TheOrderoftheTwinAdder'",
	"Texture2D'/Game/UI/Texture/CompanySeal/UI_CompanySeal_Img_TheImmortalFlames.UI_CompanySeal_Img_TheImmortalFlames'",
}

---@class CompanySealJoiningtheArmyItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconMilitaryrank UFImage
---@field ImgArmy UFImage
---@field MI_DX_Common_CompanySeal_4_a UFImage
---@field MI_DX_Common_CompanySeal_5_a UFImage
---@field MI_DX_Common_CompanySeal_6_a UFImage
---@field PanelTipsYellow UFCanvasPanel
---@field RichTextBigTetleYellow URichTextBox
---@field ScaleBox_0 UScaleBox
---@field TextMilitaryRankAfterPromotion UFTextBlock
---@field AnimIn UWidgetAnimation
---@field DMI_Text MaterialInstanceDynamic
---@field Title text
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CompanySealJoiningtheArmyItemView = LuaClass(UIView, true)

function CompanySealJoiningtheArmyItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconMilitaryrank = nil
	--self.ImgArmy = nil
	--self.MI_DX_Common_CompanySeal_4_a = nil
	--self.MI_DX_Common_CompanySeal_5_a = nil
	--self.MI_DX_Common_CompanySeal_6_a = nil
	--self.PanelTipsYellow = nil
	--self.RichTextBigTetleYellow = nil
	--self.ScaleBox_0 = nil
	--self.TextMilitaryRankAfterPromotion = nil
	--self.AnimIn = nil
	--self.DMI_Text = nil
	--self.Title = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CompanySealJoiningtheArmyItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CompanySealJoiningtheArmyItemView:OnInit()

end

function CompanySealJoiningtheArmyItemView:OnDestroy()

end

function CompanySealJoiningtheArmyItemView:OnShow()
	self.GrandCompanyID = self.Params.GrandCompanyID or 1
	self.MilitaryLevel = self.Params.MilitaryLevel or 1
	self:UpdateInfo()
	local function DelayClose()
		CompanySealMgr.IsCanPromoted = true
		self:Hide()
	end
	self.DelayTimerID = self:RegisterTimer(DelayClose, 3.5, 0, 0)
end

function CompanySealJoiningtheArmyItemView:OnHide()

end

function CompanySealJoiningtheArmyItemView:OnRegisterUIEvent()

end

function CompanySealJoiningtheArmyItemView:OnRegisterGameEvent()

end

function CompanySealJoiningtheArmyItemView:OnRegisterBinder()

end

function CompanySealJoiningtheArmyItemView:UpdateInfo()
	UIUtil.SetIsVisible(self.MI_DX_Common_CompanySeal_5_a, self.GrandCompanyID == 1)
	UIUtil.SetIsVisible(self.MI_DX_Common_CompanySeal_6_a, self.GrandCompanyID == 2)
	UIUtil.SetIsVisible(self.MI_DX_Common_CompanySeal_4_a, self.GrandCompanyID == 3)
	local Name = ProtoEnumAlias.GetAlias(ProtoRes.grand_company_type, self.GrandCompanyID)
	if CompanySealMgr.CompanyRankList[self.GrandCompanyID] and CompanySealMgr.CompanyRankList[self.GrandCompanyID][self.MilitaryLevel] then
		local Cfg = CompanySealMgr.CompanyRankList[self.GrandCompanyID][self.MilitaryLevel]
		UIUtil.ImageSetBrushFromAssetPath(self.IconMilitaryrank, Cfg.Icon)
		UIUtil.ImageSetBrushFromAssetPath(self.ImgArmy, GrandCompanyImg[self.GrandCompanyID])
		self.RichTextBigTetleYellow:SetText(Name)
		self.TextMilitaryRankAfterPromotion:SetText(Cfg.RankName)

	else
		_G.FLOG_ERROR("CompanySealJoiningtheArmyItemView UpdateInfo cfg = nil")
	end
end

return CompanySealJoiningtheArmyItemView