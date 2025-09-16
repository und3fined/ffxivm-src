local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local LSTR = _G.LSTR
---@class OpsDesertFineRebateTaskItemVM : UIViewModel
local OpsDesertFineRebateTaskItemVM = LuaClass(UIViewModel)

---Ctor
function OpsDesertFineRebateTaskItemVM:Ctor()
	self.TaskDescText = nil
	self.BtnText = nil
	self.BtnEnable = nil
	self.NodeData = nil
end

function OpsDesertFineRebateTaskItemVM:UpdateVM(NodeData)
	self.NodeData = NodeData
	local NodeID = NodeData.Head.NodeID
	local Extra = NodeData.Extra
	local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID)
    if ActivityNode then
		local Progress = Extra.Progress.Value or 0
		self.JumpType = ActivityNode.JumpType
		self.TaskDescText  = string.format("%s(%d/%d)", ActivityNode.NodeDesc or "", Progress, ActivityNode.Target)
		if NodeData.Head.Finished == true then
			self.BtnText = LSTR(100094)
			self.BtnEnable = false
			self.JumpID = 0
		else
			self.BtnText = ActivityNode.JumpButton
			self.JumpID = tonumber(ActivityNode.JumpParam) or 0
			self.BtnEnable = self.JumpID > 0
		end
	end
end

function OpsDesertFineRebateTaskItemVM:IsEqualVM(Value)
	return nil ~= Value and Value.Head.NodeID == self.NodeData.Head.NodeID
end


return OpsDesertFineRebateTaskItemVM