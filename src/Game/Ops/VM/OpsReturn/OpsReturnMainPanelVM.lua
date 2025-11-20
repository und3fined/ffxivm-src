--
-- Author: ZhengJanChuan
-- Date: 2025-07-17 14:38
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIBindableList = require("UI/UIBindableList")
local OpsReturnDefine = require("Game/Ops/View/OpsReturn/OpsReturnDefine")
local ActivityCfg = require("TableCfg/ActivityCfg")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")

---@class OpsReturnMainPanelVM : UIViewModel
local OpsReturnMainPanelVM = LuaClass(UIViewModel)

---Ctor
function OpsReturnMainPanelVM:Ctor()
	self.Title = ""
	self.WelfarePanelVisible = false
	self.ContentpushPanelVisible = false
	self.TaskPanelVisible = false
	self.HelpID = nil
end

function OpsReturnMainPanelVM:OnInit()
end

function OpsReturnMainPanelVM:OnBegin()
end

function OpsReturnMainPanelVM:OnEnd()
end

function OpsReturnMainPanelVM:OnShutdown()
end

-- 更新基本信息
function OpsReturnMainPanelVM:UpdateBaseData(ActivityID)
	local Cfg =  ActivityCfg:FindCfgByKey(ActivityID)
    if Cfg == nil then return end
	self.HelpID = Cfg.ChinaActivityHelpInfoID
end

function OpsReturnMainPanelVM:OpenWelfarePanel()
	self.WelfarePanelVisible = true
	self.ContentpushPanelVisible = false
	self.TaskPanelVisible = false
	self:UpdateTitle(OpsReturnDefine.PageType.Welfare)
end

function OpsReturnMainPanelVM:OpenContentPushPanel()
	self.WelfarePanelVisible = false
	self.ContentpushPanelVisible = true
	self.TaskPanelVisible = false 
	self:UpdateTitle(OpsReturnDefine.PageType.ContentPush)
end

function OpsReturnMainPanelVM:OpenTaskPanel()
	self.WelfarePanelVisible = false
	self.ContentpushPanelVisible = false
	self.TaskPanelVisible = true
	self:UpdateTitle(OpsReturnDefine.PageType.Task)
end

function OpsReturnMainPanelVM:UpdateTitle(ID)
	self.Title = _G.LSTR(OpsReturnDefine.PageTitle[ID])
end


--要返回当前类
return OpsReturnMainPanelVM