local LuaClass = require("Core/LuaClass")
local TaskItemVM = require("Game/Ops/VM/OpsActivityTaskItemVM")
local OpsCrystalSunmmoingTaskItemVM = LuaClass(TaskItemVM)
local ProtoCS = require("Protocol/ProtoCS")
local JumpUtil = require("Utils/JumpUtil")
local OpsActivityMgr = require("Game/Ops/OpsActivityMgr")

function OpsCrystalSunmmoingTaskItemVM:RefreshBtnGoText()
    if self.TaskState == ProtoCS.Game.Activity.RewardStatus.RewardStatusNo then
		if self.JumpType and self.JumpParam then
			self.TextBtnGo = LSTR(100045)
		else
			self.TextBtnGo = LSTR(100044)
		end
	elseif self.TaskState == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
		self.TextBtnGo = LSTR(100036)
	elseif self.TaskState == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone then
        self.TextBtnGo = LSTR(100037)
    else
        self.TextBtnGo = LSTR(100044)
	end
end

function OpsCrystalSunmmoingTaskItemVM:UpdateVM(TaskItem)
	self.RealIndex = TaskItem.RealIndex
	self.BgVisible = self.RealIndex % 2 == 0
	self.Super.UpdateVM(self, TaskItem)
end

function OpsCrystalSunmmoingTaskItemVM:SetBtnState(BtnWidget)
	if not BtnWidget then return end

    if self.TaskState == ProtoCS.Game.Activity.RewardStatus.RewardStatusNo then
		if self.JumpType and self.JumpParam then
			BtnWidget:SetIsNormalState(true)
		else
			BtnWidget:SetIsDoneState(true, LSTR(100044))
		end
	elseif self.TaskState == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
		BtnWidget:SetIsRecommendState(true)
	elseif self.TaskState == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone then
		BtnWidget:SetIsDoneState(true, LSTR(100037))
	end
end

return OpsCrystalSunmmoingTaskItemVM