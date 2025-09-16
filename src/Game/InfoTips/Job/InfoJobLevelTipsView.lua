---
--- Author: zimuyi
--- DateTime: 2024-08-27 10:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local RoleInitCfg = require("TableCfg/RoleInitCfg")
local ProtoCommon = require("Protocol/ProtoCommon")

local ProfFunctionType = ProtoCommon.function_type

---@class InfoJobLevelTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgJob UFImage
---@field ImgMask UFImage
---@field TextJob UFTextBlock
---@field TextLevel UFTextBlock
---@field AnimInBlue UWidgetAnimation
---@field AnimInGreen UWidgetAnimation
---@field AnimInRed UWidgetAnimation
---@field AnimInWhite UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local InfoJobLevelTipsView = LuaClass(UIView, true)

function InfoJobLevelTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgJob = nil
	--self.ImgMask = nil
	--self.TextJob = nil
	--self.TextLevel = nil
	--self.AnimInBlue = nil
	--self.AnimInGreen = nil
	--self.AnimInRed = nil
	--self.AnimInWhite = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function InfoJobLevelTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function InfoJobLevelTipsView:OnInit()

end

function InfoJobLevelTipsView:OnDestroy()

end

function InfoJobLevelTipsView:OnShow()
	if nil == self.Params then
		return
	end
	
	if nil ~= self.Params.Prof then
		-- 文本
		local ProfCfgData = RoleInitCfg:FindCfgByKey(self.Params.Prof)
		if nil ~= ProfCfgData then
			local ProfName = ProfCfgData.ProfName
			local LevelUpText = string.format(_G.LSTR(930003), ProfName)
			self.TextJob:SetText(LevelUpText)
			-- 图标
			local IconPath = string.format("Texture2D'/Game/UI/Texture/InfoTips/Job/UI_InfoTips_Img_Job_%s.UI_InfoTips_Img_Job_%s'",
				ProfCfgData.ProfAssetAbbr, ProfCfgData.ProfAssetAbbr)
			UIUtil.ImageSetBrushFromAssetPath(self.ImgJob, IconPath)
			local MaskPath = string.format("Texture2D'/Game/UMG/UI_Effect/Texture/Mask/T_DX_Mask_Job_%s.T_DX_Mask_Job_%s'",
				ProfCfgData.ProfAssetAbbr, ProfCfgData.ProfAssetAbbr)
			UIUtil.ImageSetMaterialTextureFromAssetPathSync(self.ImgMask, MaskPath, "Mask")
			-- 动效
			local Function = ProfCfgData.Function
			local AnimToPlay = nil
			if Function == ProfFunctionType.FUNCTION_TYPE_ATTACK then
				AnimToPlay = self.AnimInRed
			elseif Function == ProfFunctionType.FUNCTION_TYPE_GUARD then
				AnimToPlay = self.AnimInBlue
			elseif Function == ProfFunctionType.FUNCTION_TYPE_RECOVER then
				AnimToPlay = self.AnimInGreen
			else
				AnimToPlay = self.AnimInWhite
			end
			self:PlayAnimation(AnimToPlay)
			self:RegisterTimer(function() self:Hide() end, AnimToPlay:GetEndTime())
		end
	end

	if nil ~= self.Params.Level then
		self.TextLevel:SetText(tostring(self.Params.Level))
	end
end

function InfoJobLevelTipsView:OnHide()
end

function InfoJobLevelTipsView:OnRegisterUIEvent()

end

function InfoJobLevelTipsView:OnRegisterGameEvent()

end

function InfoJobLevelTipsView:OnRegisterBinder()

end

return InfoJobLevelTipsView