local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local OpsActivityMgr = require("Game/Ops/OpsActivityMgr")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local OpsVersionNoticeTaskItemVM = require("Game/Ops/VM/OpsVersionNoticeTaskItemVM")
local DataReportUtil = require("Utils/DataReportUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")

local ActivityNodeType = ProtoRes.Game.ActivityNodeType
---@class OpsVersionNoticeTaskItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn CommBtnSView
---@field PanelBtn UFCanvasPanel
---@field PanelLock UFCanvasPanel
---@field TextQuantity UFTextBlock
---@field TextTask UFTextBlock
---@field TextTime UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsVersionNoticeTaskItemView = LuaClass(UIView, true)

function OpsVersionNoticeTaskItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.PanelBtn = nil
	--self.PanelLock = nil
	--self.TextQuantity = nil
	--self.TextTask = nil
	--self.TextTime = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsVersionNoticeTaskItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Btn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsVersionNoticeTaskItemView:OnInit()
	self.ViewModel = OpsVersionNoticeTaskItemVM.New()
	self.Binders = {
        {"TextTask", UIBinderSetText.New(self, self.TextTask)},
        {"TextQuantity", UIBinderSetText.New(self, self.TextQuantity)},
		{"TextBtn", UIBinderSetText.New(self, self.Btn)},
		{"TaskFinished", UIBinderSetIsVisible.New(self, self.Btn, true)},
		{"PanelBtnVisiable", UIBinderSetIsVisible.New(self, self.PanelBtn)},
		{"PanelBtnVisiable", UIBinderSetIsVisible.New(self, self.PanelLock, true)},
        {"TextLockTime", UIBinderSetText.New(self, self.TextTime)},
    }
end

function OpsVersionNoticeTaskItemView:OnDestroy()

end

function OpsVersionNoticeTaskItemView:OnShow()

end

function OpsVersionNoticeTaskItemView:OnHide()

end

function OpsVersionNoticeTaskItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnClickBtn)
end

function OpsVersionNoticeTaskItemView:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.ShareOpsActivitySuccess, self.OnShareOpsActivitySuccess)
end

function OpsVersionNoticeTaskItemView:OnRegisterBinder()
	if nil == self.Params or nil == self.Params.Data then
		return
	end
	local ViewModel = self.Params.Data

	self.ViewModel = ViewModel

	self:RegisterBinders(ViewModel, self.Binders)
end

function OpsVersionNoticeTaskItemView:OnClickBtn()
	if self.ViewModel  == nil then
		return
	end
	local ShareNodeCfg = self.ViewModel.ShareNodeCfg

	if ShareNodeCfg then
		_G.ShareMgr:OpenShareActivityUI(ShareNodeCfg.ActivityID, ShareNodeCfg.Params[1])
	else
		DataReportUtil.ReportActivityFlowData("ActivityClickFlow", self.ViewModel.ActivityID, 1, tostring(self.ViewModel.NodeID))
		OpsActivityMgr:Jump(self.ViewModel.JumpType, self.ViewModel.JumpParam)
	end
end

function OpsVersionNoticeTaskItemView:OnShareOpsActivitySuccess(Param)
	if Param == nil then
		return
	end
	if self.ViewModel and self.ViewModel.ActivityID == Param.ActivityID then
		local ShareNodeCfg = ActivityNodeCfg:FindCfgByKey(self.ViewModel.NodeID)
		_G.OpsActivityMgr:SendActivityEventReport(ActivityNodeType.ActivityNodeTypePictureShare, ShareNodeCfg.Params)
	end
end

return OpsVersionNoticeTaskItemView