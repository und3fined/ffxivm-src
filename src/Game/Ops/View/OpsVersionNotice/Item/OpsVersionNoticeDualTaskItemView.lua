local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local OpsActivityMgr = require("Game/Ops/OpsActivityMgr")
local OpsVersionNoticeTaskItemVM = require("Game/Ops/VM/OpsVersionNoticeTaskItemVM")
local DataReportUtil = require("Utils/DataReportUtil")

---@class OpsVersionNoticeDualTaskItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn1 CommBtnSView
---@field Btn2 CommBtnSView
---@field PanelBtn1 UFCanvasPanel
---@field PanelBtn2 UFCanvasPanel
---@field PanelLock1 UFCanvasPanel
---@field PanelLock2 UFCanvasPanel
---@field TextQuantity1 UFTextBlock
---@field TextQuantity2 UFTextBlock
---@field TextTag UFTextBlock
---@field TextTask1 UFTextBlock
---@field TextTask2 UFTextBlock
---@field TextTime1 UFTextBlock
---@field TextTime2 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsVersionNoticeDualTaskItemView = LuaClass(UIView, true)

function OpsVersionNoticeDualTaskItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn1 = nil
	--self.Btn2 = nil
	--self.PanelBtn1 = nil
	--self.PanelBtn2 = nil
	--self.PanelLock1 = nil
	--self.PanelLock2 = nil
	--self.TextQuantity1 = nil
	--self.TextQuantity2 = nil
	--self.TextTag = nil
	--self.TextTask1 = nil
	--self.TextTask2 = nil
	--self.TextTime1 = nil
	--self.TextTime2 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsVersionNoticeDualTaskItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Btn1)
	self:AddSubView(self.Btn2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsVersionNoticeDualTaskItemView:OnInit()
	self.ViewModel = OpsVersionNoticeTaskItemVM.New()
	self.Binders = {
        {"TextTask1", UIBinderSetText.New(self, self.TextTask1)},
		{"TextTask2", UIBinderSetText.New(self, self.TextTask2)},
        {"TextQuantity1", UIBinderSetText.New(self, self.TextQuantity1)},
		{"TextQuantity2", UIBinderSetText.New(self, self.TextQuantity2)},
		{"TextTag", UIBinderSetText.New(self, self.TextTag)},
		{"TextBtn1", UIBinderSetText.New(self, self.Btn1.TextContent)},
		{"TextBtn2", UIBinderSetText.New(self, self.Btn2.TextContent)},
		{"Task1Finished", UIBinderSetIsVisible.New(self, self.Btn1, true)},
		{"Task2Finished", UIBinderSetIsVisible.New(self, self.Btn2, true)},
		{"PanelBtnVisiable1", UIBinderSetIsVisible.New(self, self.PanelBtn1)},
		{"PanelBtnVisiable1", UIBinderSetIsVisible.New(self, self.PanelLock1, true)},
        {"TextLockTime1", UIBinderSetText.New(self, self.TextTime1)},
		{"PanelBtnVisiable2", UIBinderSetIsVisible.New(self, self.PanelBtn2)},
		{"PanelBtnVisiable2", UIBinderSetIsVisible.New(self, self.PanelLock2, true)},
        {"TextLockTime2", UIBinderSetText.New(self, self.TextTime2)},
    }
end

function OpsVersionNoticeDualTaskItemView:OnDestroy()

end

function OpsVersionNoticeDualTaskItemView:OnShow()

end

function OpsVersionNoticeDualTaskItemView:OnHide()

end

function OpsVersionNoticeDualTaskItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn1, self.OnClickedBtnList1)
	UIUtil.AddOnClickedEvent(self, self.Btn2, self.OnClickedBtnList2)
end

function OpsVersionNoticeDualTaskItemView:OnRegisterGameEvent()

end

function OpsVersionNoticeDualTaskItemView:OnRegisterBinder()
	if nil == self.Params or nil == self.Params.Data then
		return
	end
	local ViewModel = self.Params.Data

	self.ViewModel = ViewModel

	self:RegisterBinders(ViewModel, self.Binders)
end

function OpsVersionNoticeDualTaskItemView:OnClickedBtnList1()
	if self.ViewModel  == nil then
		return
	end
	DataReportUtil.ReportActivityFlowData("ActivityClickFlow", self.ViewModel.ActivityID, 1, tostring(self.ViewModel.NodeID1))
	OpsActivityMgr:Jump(self.ViewModel.JumpType1, self.ViewModel.JumpParam1)
end

function OpsVersionNoticeDualTaskItemView:OnClickedBtnList2()
	if self.ViewModel  == nil then
		return
	end
	DataReportUtil.ReportActivityFlowData("ActivityClickFlow", self.ViewModel.ActivityID, 1, tostring(self.ViewModel.NodeID2))
	OpsActivityMgr:Jump(self.ViewModel.JumpType2, self.ViewModel.JumpParam2)
end

return OpsVersionNoticeDualTaskItemView