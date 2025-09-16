---
--- Author: muyanli
--- DateTime: 2024-08-22 10:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProfMgr = require("Game/Profession/ProfMgr")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local ProfUtil = require("Game/Profession/ProfUtil")

---@class InfoJobNulockTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconJob UFImage
---@field IconJobEFF UFImage
---@field IconSmall UFImage
---@field ImgColor UFImage
---@field ModelToImage CommonModelToImageView
---@field PopUpBG CommonPopUpBGView
---@field RichText URichTextBox
---@field TextJob UFTextBlock
---@field TextHint UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local InfoJobNulockTipsView = LuaClass(UIView, true)

function InfoJobNulockTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconJob = nil
	--self.IconJobEFF = nil
	--self.IconSmall = nil
	--self.ImgColor = nil
	--self.ModelToImage = nil
	--self.PopUpBG = nil
	--self.RichText = nil
	--self.TextHint = nil
	--self.TextJob = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function InfoJobNulockTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ModelToImage)
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function InfoJobNulockTipsView:OnInit()

end

function InfoJobNulockTipsView:OnDestroy()

end

function InfoJobNulockTipsView:OnShow()
    if ProfMgr:GetCurUnlockProfID() ~= nil then
		local ProfID=ProfMgr:GetCurUnlockProfID()
		local ProfCfgData = RoleInitCfg:FindCfgByKey(ProfID)
		local ProfClass = RoleInitCfg:FindProfClass(ProfID)

		if not ProfCfgData or not ProfClass then
			return
		end
		self.TextHint:SetText(LSTR(1070001))
		UIUtil.SetIsVisible(self.TextHint, true)
		local Title = ProfMgr.GetProfClassName(ProfClass)
		local ProfClassIcon = ProfUtil.GetProfClassIcon(ProfClass)
		local IconPath = string.format("Texture2D'/Game/Assets/Icon/900000/%s.%s'", ProfClassIcon, ProfClassIcon)
		UIUtil.ImageSetBrushFromAssetPath(self.IconSmall, IconPath)

		local BgColor=ProfUtil.GetProfBgColor(ProfCfgData.Function)
		local ColorBgPath = string.format("Texture2D'/Game/UI/Texture/InfoTips/Job/UI_InfoTips_Img_JobUnlock_%s_BG.UI_InfoTips_Img_JobUnlock_%s_BG'",BgColor,BgColor)
		UIUtil.ImageSetBrushFromAssetPath(self.ImgColor, ColorBgPath)

		self.RichText:SetText(Title..LSTR(170152))
		local Name = RoleInitCfg:FindRoleInitProfName(ProfID)
		self.TextJob:SetText(Name)
		
        -- local ProfIcon = RoleInitCfg:FindRoleInitProfIcon(ProfID)
		local ProfIcon = string.format("Texture2D'/Game/UI/Texture/InfoTips/Job/UI_InfoTips_Icon_JobUnlock_%s.UI_InfoTips_Icon_JobUnlock_%s'",
		ProfCfgData.ProfAssetAbbr, ProfCfgData.ProfAssetAbbr)
        UIUtil.ImageSetBrushFromAssetPath(self.IconJob, ProfIcon)
		UIUtil.ImageSetBrushFromAssetPath(self.IconJobEFF, ProfIcon)
	

		ProfMgr:SetCurUnlockProfID(nil)
    end
end


function InfoJobNulockTipsView:OnHide()
	UIUtil.SetIsVisible(self.TextHint, false)
end

function InfoJobNulockTipsView:OnRegisterUIEvent()
	self.PopUpBG:SetCallback(self,self.SkipSeq)
end

function InfoJobNulockTipsView:OnRegisterGameEvent()

end

function InfoJobNulockTipsView:OnRegisterBinder()

end

function InfoJobNulockTipsView:SkipSeq()
	if self.Params and self.Params.IsOnDirectUpState then
        _G.BusinessUIMgr:ShowMainPanel(_G.UIViewID.MainPanel)
		_G.UpgradeMgr:ShowReward()
	else
		_G.StoryMgr:StopSequence()
	end
end

return InfoJobNulockTipsView