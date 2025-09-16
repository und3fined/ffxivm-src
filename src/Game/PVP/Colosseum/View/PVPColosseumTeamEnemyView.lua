---
--- Author: peterxie
--- DateTime:
--- Description: 敌方队伍
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local PVPTeamVM = require("Game/PVP/Team/PVPTeamVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")


---@class PVPColosseumTeamEnemyView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelJob UFCanvasPanel
---@field TableViewJob UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPColosseumTeamEnemyView = LuaClass(UIView, true)

function PVPColosseumTeamEnemyView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelJob = nil
	--self.TableViewJob = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPColosseumTeamEnemyView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPColosseumTeamEnemyView:OnInit()
	self.AdpMemberTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewJob, nil, true)

	self.TeamBinders = {
		{ "EnemyMemberVMList", UIBinderUpdateBindableList.New(self, self.AdpMemberTableView) },
		{ "IsTeam", UIBinderValueChangedCallback.New(self, nil, self.TimerUpdate) },
	}
end

function PVPColosseumTeamEnemyView:OnDestroy()

end

function PVPColosseumTeamEnemyView:TimerUpdate()
	if self.TimerIDUpdateTeam then
		self:UnRegisterTimer(self.TimerIDUpdateTeam)
		self.TimerIDUpateTeam = nil
	end

	if not PVPTeamVM.IsTeam then
		return
	end

	self.TimerIDUpdateTeam = self:RegisterTimer(function()
		PVPTeamVM:OnTimerUpdateEnemy()
	end, 0.2, 1, 0)
end

function PVPColosseumTeamEnemyView:OnShow()

end

function PVPColosseumTeamEnemyView:OnHide()

end

function PVPColosseumTeamEnemyView:OnRegisterUIEvent()

end

function PVPColosseumTeamEnemyView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.TargetChangeMajor, self.OnGameEventTargetChangeMajor)
end

function PVPColosseumTeamEnemyView:OnRegisterBinder()
	self:RegisterBinders(PVPTeamVM, self.TeamBinders)
end

function PVPColosseumTeamEnemyView:OnGameEventTargetChangeMajor(TargetID)
	PVPTeamVM:UpdateEnemyTarget(TargetID)
end

return PVPColosseumTeamEnemyView