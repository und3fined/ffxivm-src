---
--- Author: Administrator
--- DateTime: 2024-01-09 15:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderCommBtnUpdateImage = require("Binder/UIBinderCommBtnUpdateImage")

---@class BattlePassTaskItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn CommBtnMView
---@field Rewards CommRewardsSlotView
---@field TextContent UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BattlePassTaskItemView = LuaClass(UIView, true)

function BattlePassTaskItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.Rewards = nil
	--self.TextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BattlePassTaskItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Btn)
	self:AddSubView(self.Rewards)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BattlePassTaskItemView:OnInit()
	self.Binders = {
		{ "TaskName", UIBinderSetText.New(self, self.TextContent)},
		{ "Num", UIBinderSetText.New(self, self.Rewards.RichTextNum)},
		{ "NumVisible", UIBinderSetIsVisible.New(self, self.Rewards.RichTextNum)},
		{ "BtnText", UIBinderSetText.New(self, self.Btn)},
		{ "BtnColor", UIBinderCommBtnUpdateImage.New(self, self.Btn)},
	}

end

function BattlePassTaskItemView:OnDestroy()

end

function BattlePassTaskItemView:OnShow()

end

function BattlePassTaskItemView:OnHide()

end

function BattlePassTaskItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnClickedBtn)
end

function BattlePassTaskItemView:OnRegisterGameEvent()
end

function BattlePassTaskItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	local VM = Params.Data
	if nil == VM then
		return
	end
	self.ViewModel = VM
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function BattlePassTaskItemView:OnClickedBtn()
	if self.ViewModel == nil then
		return
	end

	local ID = self.ViewModel.TaskID
	if ID == nil then
		return
	end

	local Task, TaskType, CanGetNum = _G.BattlePassMgr:GetTaskCanGetByID(ID)
	if Task ~= nil and CanGetNum then
		_G.BattlePassMgr:SendBattlePassGetTaskRewardReq(ID, TaskType)
	elseif Task ~= nil and not CanGetNum then
		--打开界面
		_G.BattlePassMgr:JumpView(ID)
	end
end

return BattlePassTaskItemView