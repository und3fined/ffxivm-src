---
--- Author: peterxie
--- DateTime:
--- Description: 水晶冲突击杀提示
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local InfoTipsBaseView = require("Game/InfoTips/InfoTipsBaseView")
local PVPTeamMgr = require("Game/PVP/Team/PVPTeamMgr")
local MajorUtil = require("Utils/MajorUtil")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local LSTR = _G.LSTR

local KillConfig =
{
	BgPath = "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPMain_Img_KOTips.UI_PVPMain_Img_KOTips'",
	MajorBgPath = "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPMain_Img_KOTips2.UI_PVPMain_Img_KOTips2'",

	ProfBlueBg = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMain_Icon_KillBlue_png.UI_PVPMain_Icon_KillBlue_png'",
	ProfRedBg = "PaperSprite'/Game/UI/Atlas/PVPMain/Frames/UI_PVPMain_Icon_KillRed_png.UI_PVPMain_Icon_KillRed_png'",

	[1] =
	{
		Flag = "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPMain_Img_KOGreen.UI_PVPMain_Img_KOGreen'",
		FlagBg = "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPMain_Img_KOGreenBg.UI_PVPMain_Img_KOGreenBg'",
		OutlineColor = "4d85b4",
	},

	[2] =
	{
		Flag = "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPMain_Img_KOPurple.UI_PVPMain_Img_KOPurple'",
		FlagBg = "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPMain_Img_KOPurpleBg.UI_PVPMain_Img_KOPurpleBg'",
		OutlineColor = "744aad",
	},

	[3] =
	{
		Flag = "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPMain_Img_KOYellow.UI_PVPMain_Img_KOYellow'",
		FlagBg = "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPMain_Img_KOYellowBg.UI_PVPMain_Img_KOYellowBg'",
		OutlineColor = "bd8213",
	},
}


---@class PVPColosseumKillTipsView : InfoTipsBaseView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BlueKillFlagEffect UFCanvasPanel
---@field GoldKillFlagEffect UFCanvasPanel
---@field IconKill UFImage
---@field ImgBg UFImage
---@field ImgJob1 UFImage
---@field ImgJob2 UFImage
---@field ImgJobBg1 UFImage
---@field ImgJobBg2 UFImage
---@field ImgKill1 UFImage
---@field ImgKill2 UFImage
---@field PanelKO UFCanvasPanel
---@field PurpleKillFlagEffect UFCanvasPanel
---@field TextInfo UFTextBlock
---@field TextKillNum UFTextBlock
---@field TextName UFTextBlock
---@field AnimEnemyKO UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimOwnKO UWidgetAnimation
---@field AnimTeamKO UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPColosseumKillTipsView = LuaClass(InfoTipsBaseView, true)

function PVPColosseumKillTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BlueKillFlagEffect = nil
	--self.GoldKillFlagEffect = nil
	--self.IconKill = nil
	--self.ImgBg = nil
	--self.ImgJob1 = nil
	--self.ImgJob2 = nil
	--self.ImgJobBg1 = nil
	--self.ImgJobBg2 = nil
	--self.ImgKill1 = nil
	--self.ImgKill2 = nil
	--self.PanelKO = nil
	--self.PurpleKillFlagEffect = nil
	--self.TextInfo = nil
	--self.TextKillNum = nil
	--self.TextName = nil
	--self.AnimEnemyKO = nil
	--self.AnimOut = nil
	--self.AnimOwnKO = nil
	--self.AnimTeamKO = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPColosseumKillTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPColosseumKillTipsView:OnInit()

end

function PVPColosseumKillTipsView:OnDestroy()

end

function PVPColosseumKillTipsView:OnShow()
	self.Super:OnShow()

	self:ShowLogKnockOut()
end

function PVPColosseumKillTipsView:OnHide()

end

function PVPColosseumKillTipsView:OnRegisterUIEvent()

end

function PVPColosseumKillTipsView:OnRegisterGameEvent()

end

function PVPColosseumKillTipsView:OnRegisterBinder()

end

function PVPColosseumKillTipsView:OnRegisterTimer()
	self.Super:OnRegisterTimer()
end

function PVPColosseumKillTipsView:ShowLogKnockOut()
	local Params = self.Params
	if not Params then
		return
	end

	local LogObj = Params.KillParams ---@type BattleLogObj

	local KillerMemberVM = PVPTeamMgr:FindMemberVMByRoleID(LogObj.KillerRoleID)
	local DeatherMemberVM = PVPTeamMgr:FindMemberVMByRoleID(LogObj.DeatherRoleID)
	if not KillerMemberVM or not DeatherMemberVM then
		return
	end

	local KillerProfID = KillerMemberVM.ProfID
	local KillerName = KillerMemberVM.Name
	local DeatherProfID = DeatherMemberVM.ProfID
	local DeatherName = DeatherMemberVM.Name

	-- 击杀职业背景
	local KillerProfBg
	local DeatherProfBg
	local bKillerIsMyTeam = _G.PVPColosseumMgr:IsMyTeamByCampID(KillerMemberVM.CampID)
	if bKillerIsMyTeam then
		KillerProfBg = KillConfig.ProfBlueBg
		DeatherProfBg = KillConfig.ProfRedBg
	else
		KillerProfBg = KillConfig.ProfRedBg
		DeatherProfBg = KillConfig.ProfBlueBg
	end
	UIUtil.ImageSetBrushFromAssetPath(self.ImgJobBg1, KillerProfBg)
	UIUtil.ImageSetBrushFromAssetPath(self.ImgJobBg2, DeatherProfBg)

	-- 击杀职业
	local KillerProfIcon = RoleInitCfg:FindRoleInitProfIconSimple2nd(KillerProfID)
	if not string.isnilorempty(KillerProfIcon) then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgJob1, KillerProfIcon)
	end
	local DeatherProfIcon = RoleInitCfg:FindRoleInitProfIconSimple2nd(DeatherProfID)
	if not string.isnilorempty(DeatherProfIcon) then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgJob2, DeatherProfIcon)
	end

	local bKillerIsMajor = MajorUtil.IsMajorByRoleID(LogObj.KillerRoleID)
	local bDeatherIsMajor = MajorUtil.IsMajorByRoleID(LogObj.DeatherRoleID)

	-- 击杀名称
	local Content = KillerName
	UIUtil.TextBlockSetOutlineColorAndOpacityHex(self.TextInfo, "ba2a44")
	if bKillerIsMajor then
		-- 你将xxx击败
		Content = string.format(LSTR(810034), DeatherName)
		UIUtil.TextBlockSetOutlineColorAndOpacityHex(self.TextInfo, "215dce")
	elseif bDeatherIsMajor then
		-- 你被xxx击败
		Content = string.format(LSTR(810035), KillerName)
	end
	self.TextName:SetText(Content)
	self.TextInfo:SetText(LSTR(810033))

	-- 击杀背景
	local BgPath = KillConfig.BgPath
	if bKillerIsMajor then
		BgPath = KillConfig.MajorBgPath
	end
	UIUtil.ImageSetBrushFromAssetPath(self.ImgBg, BgPath)

	-- 击杀次数，划分等级
	local KOCount = LogObj.KOCount
	local KillLevel
	if KOCount > 4 then
		KillLevel = 3
	elseif KOCount > 2 then
		KillLevel = 2
	else
		KillLevel = 1
	end
	UIUtil.ImageSetBrushFromAssetPath(self.IconKill, KillConfig[KillLevel].Flag)
	--UIUtil.ImageSetBrushFromAssetPath(self.IconKillFlag, KillConfig[KillLevel].FlagBg)
	self.TextKillNum:SetText(KOCount)
	UIUtil.TextBlockSetOutlineColorAndOpacityHex(self.TextKillNum, KillConfig[KillLevel].OutlineColor)

	UIUtil.SetIsVisible(self.BlueKillFlagEffect, false)
	UIUtil.SetIsVisible(self.PurpleKillFlagEffect, false)
	UIUtil.SetIsVisible(self.GoldKillFlagEffect, false)
	if KillLevel == 3 then
		UIUtil.SetIsVisible(self.GoldKillFlagEffect, true)
	elseif KillLevel == 2 then
		UIUtil.SetIsVisible(self.PurpleKillFlagEffect, true)
	else
		UIUtil.SetIsVisible(self.BlueKillFlagEffect, true)
	end

	if bKillerIsMyTeam then
		if bKillerIsMajor then
			self:PlayAnimation(self.AnimOwnKO)
		else
			self:PlayAnimation(self.AnimTeamKO)
		end
	else
		self:PlayAnimation(self.AnimEnemyKO)
	end
end

return PVPColosseumKillTipsView