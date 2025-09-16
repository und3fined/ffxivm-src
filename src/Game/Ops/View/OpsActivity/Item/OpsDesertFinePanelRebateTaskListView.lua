---
--- Author: Administrator
--- DateTime: 2025-01-09 14:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")

---@class OpsDesertFinePanelRebateTaskListView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn CommBtnSView
---@field TextTaskTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsDesertFinePanelRebateTaskListView = LuaClass(UIView, true)

function OpsDesertFinePanelRebateTaskListView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.TextTaskTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsDesertFinePanelRebateTaskListView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Btn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsDesertFinePanelRebateTaskListView:OnInit()
	self.Binders = {
		{"TaskDescText", UIBinderSetText.New(self, self.TextTaskTitle)},
		{"BtnText", UIBinderSetText.New(self, self.Btn.TextContent)},
		{"BtnEnable", UIBinderSetIsEnabled.New(self, self.Btn)},
	}
end

function OpsDesertFinePanelRebateTaskListView:OnDestroy()

end

function OpsDesertFinePanelRebateTaskListView:OnShow()
	
end


function OpsDesertFinePanelRebateTaskListView:OnHide()

end

function OpsDesertFinePanelRebateTaskListView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnClickBtn)
end

function OpsDesertFinePanelRebateTaskListView:OnRegisterGameEvent()

end

function OpsDesertFinePanelRebateTaskListView:OnRegisterBinder()
	local ViewModel = self.Params.Data

	if nil == ViewModel then
		return
	end

	self.ViewModel = ViewModel

	self:RegisterBinders(ViewModel, self.Binders)
end

function OpsDesertFinePanelRebateTaskListView:OnClickBtn()
	local ViewModel = self.Params.Data

    if nil == ViewModel or ViewModel.JumpID == nil or ViewModel.JumpID < 1 then
        return
    end
	_G.OpsActivityMgr:Jump(ViewModel.JumpType, ViewModel.JumpID)
	
end



return OpsDesertFinePanelRebateTaskListView