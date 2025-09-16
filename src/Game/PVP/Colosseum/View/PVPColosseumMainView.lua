---
--- Author: peterxie
--- DateTime:
--- Description: 水晶冲突主界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PVPColosseumHeaderVM = require("Game/PVP/Colosseum/VM/PVPColosseumHeaderVM")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local MainPanelVM = require("Game/Main/MainPanelVM")


---@class PVPColosseumMainView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field MainActorInfoPanel MainActorInfoPanelView
---@field MainControlPanel MainControlPanelView
---@field MainMajorInfoPanel MainMajorInfoPanelView
---@field PVPColosseumBattleLog PVPColosseumBattleLogView
---@field PVPColosseumHeader PVPColosseumHeaderView
---@field PVPColosseumTeam PVPColosseumTeamView
---@field PVPColosseumTeamEnemy PVPColosseumTeamEnemyView
---@field PVPMapPanel PVPMapPanelView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPColosseumMainView = LuaClass(UIView, true)

function PVPColosseumMainView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.MainActorInfoPanel = nil
	--self.MainControlPanel = nil
	--self.MainMajorInfoPanel = nil
	--self.PVPColosseumBattleLog = nil
	--self.PVPColosseumHeader = nil
	--self.PVPColosseumTeam = nil
	--self.PVPColosseumTeamEnemy = nil
	--self.PVPMapPanel = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPColosseumMainView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.MainActorInfoPanel)
	self:AddSubView(self.MainControlPanel)
	self:AddSubView(self.MainMajorInfoPanel)
	self:AddSubView(self.PVPColosseumBattleLog)
	self:AddSubView(self.PVPColosseumHeader)
	self:AddSubView(self.PVPColosseumTeam)
	self:AddSubView(self.PVPColosseumTeamEnemy)
	self:AddSubView(self.PVPMapPanel)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPColosseumMainView:OnInit()
	self.Binders =
	{
		{ "HeaderPanelVisible", UIBinderSetIsVisible.New(self, self.PVPColosseumHeader) },
	}

	self.MainPanelBinders = {
		{ "ControlPanelVisible", UIBinderSetIsVisible.New(self, self.MainControlPanel) },
	}
end

function PVPColosseumMainView:OnDestroy()

end

function PVPColosseumMainView:OnShow()
	_G.GMMgr:OpenGMPanel()
end

function PVPColosseumMainView:OnHide()

end

function PVPColosseumMainView:OnRegisterUIEvent()

end

function PVPColosseumMainView:OnRegisterGameEvent()

end

function PVPColosseumMainView:OnRegisterBinder()
	self:RegisterBinders(PVPColosseumHeaderVM, self.Binders)
	self:RegisterBinders(MainPanelVM, self.MainPanelBinders)
end

return PVPColosseumMainView