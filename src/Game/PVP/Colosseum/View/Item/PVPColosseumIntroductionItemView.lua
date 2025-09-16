---
--- Author: peterxie
--- DateTime:
--- Description: 入场介绍界面，队伍展示
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")


---@class PVPColosseumIntroductionItemView : UIView
---@field ViewModel TeamMemberVM
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonPlayerPortrait CommonPlayerPortraitItemView
---@field IconJob UFImage
---@field ImgBg UFImage
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPColosseumIntroductionItemView = LuaClass(UIView, true)

function PVPColosseumIntroductionItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonPlayerPortrait = nil
	--self.IconJob = nil
	--self.ImgBg = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPColosseumIntroductionItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonPlayerPortrait)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPColosseumIntroductionItemView:OnInit()
	self.Binders = {
		{ "Name", UIBinderSetText.New(self, self.TextName) },
		{ "ProfID", UIBinderSetProfIcon.New(self, self.IconJob) },
	}
end

function PVPColosseumIntroductionItemView:OnDestroy()

end

function PVPColosseumIntroductionItemView:OnShow()
	local MemberVM = self.ViewModel
	if nil == MemberVM then
		return
	end

	-- 队伍成员所属红蓝方背景
	local BlueBgPath = "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPColosseum_Img_PortraitBlue.UI_PVPColosseum_Img_PortraitBlue'"
	local RedBgPath = "Texture2D'/Game/UI/Texture/PVPMain/UI_PVPColosseum_Img_PortraitRed.UI_PVPColosseum_Img_PortraitRed'"
	local bIsMyTeam = _G.PVPColosseumMgr:IsMyTeamByCampID(MemberVM.CampID)
	local BgPath = bIsMyTeam and BlueBgPath or RedBgPath
	UIUtil.ImageSetBrushFromAssetPath(self.ImgBg, BgPath)
end

function PVPColosseumIntroductionItemView:OnHide()

end

function PVPColosseumIntroductionItemView:OnRegisterUIEvent()

end

function PVPColosseumIntroductionItemView:OnRegisterGameEvent()

end

function PVPColosseumIntroductionItemView:OnRegisterBinder()
	local ViewModel = self.Params and self.Params.Data or nil
	if not ViewModel then
		return
	end
	self.ViewModel = ViewModel
	self:RegisterBinders(self.ViewModel, self.Binders)
end

return PVPColosseumIntroductionItemView