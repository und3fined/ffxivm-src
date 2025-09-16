---
--- Author: v_hggzhang
--- DateTime: 2023-02-03 14:02
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetImageBrushByResFunc = require("Binder/UIBinderSetImageBrushByResFunc")
local PWorldHelper = require("Game/PWorld/PWorldHelper")
local ProfUtil = require("Game/Profession/ProfUtil")

---@class PWorldMatchDetailItemView : UIView
---@field VM PWorldMatchItemVM
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCancel CommBtnMView
---@field CommSingleBox_UIBP CommSingleBoxView
---@field FTextBlock_99 UFTextBlock
---@field ImgJob UFImage
---@field ImgPWorldType UFImage
---@field JobSlot CommPlayerSimpleJobSlotView
---@field PanelDetail UFCanvasPanel
---@field PanelEmpty UFCanvasPanel
---@field TextEmpty UFTextBlock
---@field TextExpect UFTextBlock
---@field TextPWorldName UFTextBlock
---@field TextSort UFTextBlock
---@field TextStatus UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldMatchDetailItemView = LuaClass(UIView, true)

function PWorldMatchDetailItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCancel = nil
	--self.CommSingleBox_UIBP = nil
	--self.FTextBlock_99 = nil
	--self.ImgJob = nil
	--self.ImgPWorldType = nil
	--self.JobSlot = nil
	--self.PanelDetail = nil
	--self.PanelEmpty = nil
	--self.TextEmpty = nil
	--self.TextExpect = nil
	--self.TextPWorldName = nil
	--self.TextSort = nil
	--self.TextStatus = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldMatchDetailItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.CommSingleBox_UIBP)
	self:AddSubView(self.JobSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldMatchDetailItemView:OnPostInit()
	self.Binders = {
		{ "Name", 		UIBinderSetText.New(self, self.TextPWorldName) },
		{ "Order", UIBinderSetText.New(self, self.TextSort, function (V)
			if V and V > 0 then
				return PWorldHelper.pformat("MATCH_ORDER", V)
			end
			return _G.LSTR(1320100)
		end)},
		{ "Icon", 		UIBinderSetBrushFromAssetPath.New(self, self.ImgPWorldType) },
		{ "Lv", 		UIBinderSetText.New(self, self.JobSlot.TextLevel) },
		{ "Prof", 		UIBinderSetProfIcon.New(self, self.JobSlot.ImgJob) },
		{ "IsShowProf", UIBinderSetIsVisible.New(self, self.JobSlot) },
		{ "IsShowStatus", UIBinderSetIsVisible.New(self, self.TextStatus) },
		{ "IsShowTextSort", 	UIBinderSetIsVisible.New(self, self.TextSort) },

		{ "Enable", 	UIBinderSetIsVisible.New(self, self.PanelDetail) },
		{ "Enable", 	UIBinderSetIsVisible.New(self, self.PanelEmpty, true) },
		{ "CanOp", UIBinderValueChangedCallback.New(self, nil, function(_, V)
			self.BtnCancel:SetIsEnabled(V)
		end) },
		{ "EstimateWaitTimeDesc", UIBinderSetText.New(self, self.TextExpect)},
		{ "CancelText", UIBinderSetText.New(self, self.BtnCancel)},

		{ "bShowRobotMatchCheck", UIBinderSetIsVisible.New(self, self.CommSingleBox_UIBP)},
		{ "bUseRobotMatch", UIBinderValueChangedCallback.New(self, nil, self.OnUseRobotCheckChanged)},
		{ "bShowOrder", UIBinderSetIsVisible.New(self, self.TextSort)},
		{ "bShowLackProf", UIBinderSetIsVisible.New(self, self.ImgJob)},
		{ "bShowLackProf", UIBinderSetIsVisible.New(self, self.FTextBlock_99)},
		{ "LackProf", UIBinderSetImageBrushByResFunc.NewByResFunc(ProfUtil.LackProfFunc2IconForMatch, self, self.ImgJob)},
	}

	self.CommSingleBox_UIBP:SetStateChangedCallback(self, self.OnCheckRobotMatch)

	self.TextSort:SetText(_G.LSTR(1320149))
	self.TextEmpty:SetText(_G.LSTR(1320202))
	self.FTextBlock_99:SetText(_G.LSTR(1320219))
end

function PWorldMatchDetailItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCancel.Button, self.OnClicekCancel)
end

function PWorldMatchDetailItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PWorldMatchTimeUpdate, self.OnUpdatePWorldMatch)
	self:RegisterGameEvent(_G.EventID.TeamCaptainChanged, self.OnCaptainChanged)
end

function PWorldMatchDetailItemView:OnRegisterBinder()
	local Data = self.Params and self.Params.Data
	if nil == Data then
		return
	end

	self.VM = Data
	self:UpdateVM()
	self:RegisterBinders(self.VM, self.Binders)
end

function PWorldMatchDetailItemView:OnShow()
	if self.TextStatus then
		UIUtil.SetIsVisible(self.TextStatus, false)
	end
end

function PWorldMatchDetailItemView:OnClicekCancel()
	if _G.TeamMgr:IsInTeam() and not _G.TeamMgr:IsCaptain() then
		local MsgTipsID = require("Define/MsgTipsID")
		_G.MsgTipsUtil.ShowTipsByID(MsgTipsID.PWorldMatchJoinOrCancelNoCaptain, nil)
		return
	end

	if self.VM then
		_G.PWorldMatchMgr:ReqCancelMatch(self.VM.EntType, self.VM.EntID)
	end
end

function PWorldMatchDetailItemView:OnUpdatePWorldMatch()
	if self.VM then
		self.VM:UpdateMatchTime()
	end
end

function PWorldMatchDetailItemView:OnCaptainChanged()
	if self.VM then
		self.VM:UpdateOp()
	end
end

function PWorldMatchDetailItemView:UpdateVM()
	if self.VM then
		self.VM:UpdateMatchTime()
		self.VM:UpdateOp()
	end
end

function PWorldMatchDetailItemView:OnUseRobotCheckChanged(Value)
	self.CommSingleBox_UIBP:SetChecked(Value == true, false)
end

function PWorldMatchDetailItemView:OnCheckRobotMatch(bChecked)
	if self.VM then
		self.VM:SetRobotMatchChecked(bChecked)
	end
end

return PWorldMatchDetailItemView