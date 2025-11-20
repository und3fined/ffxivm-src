---
--- Author: Administrator
--- DateTime: 2025-08-08 14:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PVPColosseumRecordInsideVM = require("Game/PVP/Colosseum/VM/PVPColosseumRecordInsideVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local CrystallineRankCfg = require("TableCfg/CrystallineRankCfg")
local PVPColosseumDefine = require("Game/PVP/Colosseum/PVPColosseumDefine")

---@class PVPColosseumRecordInsideItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnName UFButton
---@field IconJob UFImage
---@field ImgLight UFImage
---@field PanelKDA UFCanvasPanel
---@field PanelRecord UFCanvasPanel
---@field TextA UFTextBlock
---@field TextD UFTextBlock
---@field TextDan UFTextBlock
---@field TextHurt UFTextBlock
---@field TextInTreatment UFTextBlock
---@field TextInjured UFTextBlock
---@field TextK UFTextBlock
---@field TextName UFTextBlock
---@field TextTime UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPColosseumRecordInsideItemView = LuaClass(UIView, true)

function PVPColosseumRecordInsideItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnName = nil
	--self.IconJob = nil
	--self.ImgLight = nil
	--self.PanelKDA = nil
	--self.PanelRecord = nil
	--self.TextA = nil
	--self.TextD = nil
	--self.TextDan = nil
	--self.TextHurt = nil
	--self.TextInTreatment = nil
	--self.TextInjured = nil
	--self.TextK = nil
	--self.TextName = nil
	--self.TextTime = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPColosseumRecordInsideItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPColosseumRecordInsideItemView:OnInit()
	self.Binders =
	{
		{ "Name", UIBinderSetText.New(self, self.TextName) },
		{ "ProfID", UIBinderSetProfIcon.New(self, self.IconJob) },

		{ "KillCount", UIBinderSetText.New(self, self.TextK) },
		{ "DeadCount", UIBinderSetText.New(self, self.TextD) },
		{ "AssistCount", UIBinderSetText.New(self, self.TextA) },
		{ "EscortTime", UIBinderSetText.New(self, self.TextTime) },

		{ "Damage", UIBinderSetText.New(self, self.TextHurt) },
		{ "Damaged", UIBinderSetText.New(self, self.TextInjured) },
		{ "Heal", UIBinderSetText.New(self, self.TextInTreatment) },

		{ "IsMajor", UIBinderSetIsVisible.New(self, self.ImgLight) },

		{ "ShowLikeCount", UIBinderSetIsVisible.New(self, self.TextGood) },
		{ "LikeCount", UIBinderSetText.New(self, self.TextGood) },
		{ "IconLikePath", UIBinderSetBrushFromAssetPath.New(self, self.IconGood) },
		{ "ShowBtnLike", UIBinderSetIsVisible.New(self, self.BtnGood, nil, true) },
		{ "PVPRankID", UIBinderValueChangedCallback.New(self, nil, self.OnPVPRankIDChanged) },
	}

	self.BindersShowData =
	{
		{ "ShowData", UIBinderSetIsVisible.New(self, self.PanelRecord) },
		{ "ShowData", UIBinderSetIsVisible.New(self, self.PanelKDA, true) },
	}
end

function PVPColosseumRecordInsideItemView:OnDestroy()

end

function PVPColosseumRecordInsideItemView:OnShow()

end

function PVPColosseumRecordInsideItemView:OnHide()

end

function PVPColosseumRecordInsideItemView:OnRegisterUIEvent()
	--UIUtil.AddOnClickedEvent(self, self.BtnGood, self.OnClickedBtnGood)
end

function PVPColosseumRecordInsideItemView:OnRegisterGameEvent()

end

function PVPColosseumRecordInsideItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end
	self.ViewModel = ViewModel
	self:RegisterBinders(self.ViewModel, self.Binders)
	self:RegisterBinders(PVPColosseumRecordInsideVM, self.BindersShowData)
end


function PVPColosseumRecordInsideItemView:OnPVPRankIDChanged(RankID)
	-- 是否排位赛，如果不是，则不显示段位信息
	local IsPVPRank = _G.PWorldMgr:CurrIsInPVPColosseumRank()
	UIUtil.SetIsVisible(self.TextDan, IsPVPRank)

	local RankInfo = self:GetPVPRankInfo(RankID)
	if RankInfo == nil then
		return
	end

	local RankName = RankInfo.Name
	self.TextDan:SetText(RankName)
end

---@type 获取段位信息
function PVPColosseumRecordInsideItemView:GetPVPRankInfo(RankID)
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

return PVPColosseumRecordInsideItemView