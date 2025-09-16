---
--- Author: peterxie
--- DateTime:
--- Description: 我方队伍 复用已有的队伍列表显示，成员展示信息有部分内容差异
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local SignsMgr = require("Game/Signs/SignsMgr")
local EventID = require("Define/EventID")
local PVPTeamVM = require("Game/PVP/Team/PVPTeamVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")


---@class PVPColosseumTeamView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnPlayer UFButton
---@field BtnScene UFButton
---@field TableViewList UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPColosseumTeamView = LuaClass(UIView, true)

function PVPColosseumTeamView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnPlayer = nil
	--self.BtnScene = nil
	--self.TableViewList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPColosseumTeamView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPColosseumTeamView:OnInit()
	self.AdpMemberTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewList, nil, true)

	self.TeamBinders = {
		{ "BindableListMember", UIBinderUpdateBindableList.New(self, self.AdpMemberTableView) },
		{ "IsTeam", UIBinderValueChangedCallback.New(self, nil, self.TimerUpdate) },
	}
end

function PVPColosseumTeamView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnPlayer, self.OnClickBtnTargetSigns)
	UIUtil.AddOnClickedEvent(self, self.BtnScene, self.OnClickBtnScenMark)
end

function PVPColosseumTeamView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.TargetChangeMajor, self.OnGameEventTargetChangeMajor)
end

function PVPColosseumTeamView:OnRegisterBinder()
	self:RegisterBinders(PVPTeamVM, self.TeamBinders)
end

function PVPColosseumTeamView:OnGameEventTargetChangeMajor(TargetID)
	PVPTeamVM:UpdateTarget(TargetID)
end


---目标标记点击回调
function PVPColosseumTeamView:OnClickBtnTargetSigns()
	SignsMgr:ShowTargetSignsPanel()
end

---场景标记点击回调
function PVPColosseumTeamView:OnClickBtnScenMark()
	SignsMgr:ShowSceneMarkersPanel()
end

function PVPColosseumTeamView:TimerUpdate()
	if self.TimerIDUpdateTeam then
		self:UnRegisterTimer(self.TimerIDUpdateTeam)
		self.TimerIDUpdateTeam = nil
	end

	if not PVPTeamVM.IsTeam then
		return
	end

	self.TimerIDUpdateTeam = self:RegisterTimer(function()
		PVPTeamVM:OnTimerUpdate()
	end, 0.2, 1, 0)
end

return PVPColosseumTeamView