--[[
Author: zhangyuhao_ds zhangyuhao@dasheng.tv
Date: 2025-04-01 10:56:24
LastEditors: zhangyuhao_ds zhangyuhao@dasheng.tv
LastEditTime: 2025-04-07 19:53:34
FilePath: \Script\Game\Ops\VM\OpsActivityWhaleMonutItemVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local TaskItemVM = require("Game/Ops/VM/OpsActivityTaskItemVM")
local WhaleMonutItemVM = LuaClass(TaskItemVM)
local ProtoCS = require("Protocol/ProtoCS")
local JumpUtil = require("Utils/JumpUtil")
local OpsActivityMgr = require("Game/Ops/OpsActivityMgr")
local ProtoRes = require("Protocol/ProtoRes")
local OPS_JUMP_TYPE = ProtoRes.Game.OPS_JUMP_TYPE

function WhaleMonutItemVM:Ctor()
    self.Super.Ctor(self)
    self.RedDotName = nil
    self.LineVisible = false
end

function WhaleMonutItemVM:UpdateVM(TaskItem)
    self.Locked = TaskItem.Locked
    self.JumpID = TaskItem.JumpID
    self.JumpType = TaskItem.JumpType
    self.JumpButton = TaskItem.JumpButton
    self.Super.UpdateVM(self, TaskItem)
    self.RedDotName = TaskItem.RedDotName
    self.LineVisible = TaskItem.TotalNum ~= TaskItem.IndexInList
end

function WhaleMonutItemVM:OnClickedGoHandle()
    if self.Locked then
        _G.MsgTipsUtil.ShowTips(_G.LSTR(100042))
        return
    end

    if self.TaskState == ProtoCS.Game.Activity.RewardStatus.RewardStatusNo and self.JumpID then
        OpsActivityMgr:Jump(self.JumpType, self.JumpID)
        if OPS_JUMP_TYPE.TABLE_JUMP == self.JumpType and JumpUtil.IsCurJumpIDCanJump(self.JumpID) then
            local JumpCfg = require("TableCfg/JumpCfg")
            local JumpData = JumpCfg:FindCfgByKey(self.JumpID) or {}
            if JumpData.JumpType and JumpData.JumpType ~= JumpUtil.JumpType.ActivityPicShare then
                _G.UIViewMgr:HideView(_G.UIViewID.OpsActivityMainPanel)
            end
        end
	elseif self.TaskState == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
		OpsActivityMgr:SendActivityNodeGetReward(self.NodeID)
    else

	end
end

function WhaleMonutItemVM:RefreshBtnGoText()
    if self.Locked then
        self.TextBtnGo = LSTR(100043)
        return
    end

    if self.TaskState == ProtoCS.Game.Activity.RewardStatus.RewardStatusNo and self.JumpID ~= 0 then
        local Text = string.isnilorempty(self.JumpButton) and LSTR(100035) or self.JumpButton
		self.TextBtnGo = Text
	elseif self.TaskState == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
		self.TextBtnGo = LSTR(100036)
	elseif self.TaskState == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone then
        self.TextBtnGo = LSTR(100037)
    else
        self.TextBtnGo = LSTR(100044)
	end
end

function WhaleMonutItemVM:SetBtnState(BtnWidget)
    if not BtnWidget then return end
        
    if self.Locked then
        BtnWidget:SetIsDisabledState(true, true)
        return
    end
    
    if self.TaskState == ProtoCS.Game.Activity.RewardStatus.RewardStatusNo and self.JumpID ~= 0 then
		BtnWidget:SetIsNormalState(true)
	elseif self.TaskState == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
		BtnWidget:SetIsRecommendState(true)
	elseif self.TaskState == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone then
		BtnWidget:SetIsDoneState(true, LSTR(100037))
    else
        BtnWidget:SetIsDoneState(true, LSTR(100044))
	end
end

return WhaleMonutItemVM