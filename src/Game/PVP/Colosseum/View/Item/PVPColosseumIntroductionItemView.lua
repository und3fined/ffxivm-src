---
--- Author: peterxie
--- DateTime:
--- Description: 入场介绍界面，队伍展示
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CrystallineRankCfg = require("TableCfg/CrystallineRankCfg")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local PVPColosseumDefine = require("Game/PVP/Colosseum/PVPColosseumDefine")

---@class PVPColosseumIntroductionItemView : UIView
---@field ViewModel TeamMemberVM
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonPlayerPortrait CommonPlayerPortraitItemView
---@field IconJob UFImage
---@field ImgBg UFImage
---@field ImgDan UFImage
---@field PanelDan UFCanvasPanel
---@field TextDan UFTextBlock
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPColosseumIntroductionItemView = LuaClass(UIView, true)

function PVPColosseumIntroductionItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonPlayerPortrait = nil
	--self.IconJob = nil
	--self.ImgBg = nil
	--self.ImgDan = nil
	--self.PanelDan = nil
	--self.TextDan = nil
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
		{ "PVPRankID", UIBinderValueChangedCallback.New(self, nil, self.OnPVPRankIDChanged) },
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

function PVPColosseumIntroductionItemView:OnPVPRankIDChanged(RankID)
	-- 是否排位赛，如果不是，则不显示段位信息
	local IsPVPRank = _G.PWorldMgr:CurrIsInPVPColosseumRank()
	UIUtil.SetIsVisible(self.PanelDan, IsPVPRank)

	local RankInfo = self:GetPVPRankInfo(RankID)
	if RankInfo == nil then
		return
	end

	local RankType = RankInfo.Type
	local RankName = RankInfo.Name
	UIUtil.SetIsVisible(self.ImgDan, RankType > PVPColosseumDefine.ERankType.RT_None)
	self.TextDan:SetText(RankName)
	local RankIconPath = PVPColosseumDefine.RankIconPath[RankType] or ""
	UIUtil.ImageSetBrushFromAssetPath(self.ImgDan, RankIconPath)
end

---@type 获取段位信息
function PVPColosseumIntroductionItemView:GetPVPRankInfo(RankID)
	local Cfg = CrystallineRankCfg:FindCfgByKey(RankID)
	if Cfg == nil then
		return nil
	end
	local Info = {
		Type = Cfg.Type,
		Name = Cfg.RankName
	}
	return Info
end

return PVPColosseumIntroductionItemView