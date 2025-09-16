--
--Author: HugoWong
--Date: 2024-09-20 10:55
--Description:
--

--全局Mgr需要在GameMgrConfig中配置, 具体说明参考下面wiki
--https://iwiki.woa.com/pages/viewpage.action?pageId=991668849

--避免滥用全局变量或全局函数。尽量用local定义变量，以免被误操作为全局变量，污染命名空间。
--Lua不加local修饰默认是global的全局变量，每次调用是通过传入的变量名作为key去全局表中获取。而local变量是直接通过Lua的堆栈访问，访问效率较高。
--全局变量也尽量在当前文件存为local变量, 直接访问全局变量时要以“_G”开头, 例如: _G.LSTR

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require ("Protocol/ProtoCS")
local EventID = require("Define/EventID")
local PworldStepCfg = require("TableCfg/PworldStepCfg")

local MainPanelVM = require("Game/Main/MainPanelVM")
local ExclusiveBattleQuestVM = require ("Game/ExclusiveBattleQuest/VM/ExclusiveBattleQuestVM")

local CS_CMD = ProtoCS.CS_CMD
local CS_PWORLD_CMD = ProtoCS.CS_PWORLD_CMD
--local ProtoCS = require("Protocol/ProtoCS")
--local UIViewID = require("Define/UIViewID")

--local LSTR
--local GameNetworkMgr
--local EventMgr
--local UIViewMgr
local PWorldMgr

---@class ExclusiveBattleQuestMgr : MgrBase
local ExclusiveBattleQuestMgr = LuaClass(MgrBase)

---OnInit
function ExclusiveBattleQuestMgr:OnInit()
	--只初始化自身模块的数据，不能引用其他的同级模块
	self.CurStep = 0
	self.ProgressList = nil
end

---OnBegin
function ExclusiveBattleQuestMgr:OnBegin()
	--可以引用其他同级模块的数据，这里初始化的数据，同级模块的OnInit中是不能访问的（相当于模块的私有数据）
	--其他Mgr、全局对象 建议在OnBegin函数里初始化
	--LSTR = _G.LSTR
	--GameNetworkMgr = _G.GameNetworkMgr
	--EventMgr = _G.EventMgr
	--UIViewMgr = _G.UIViewMgr
    PWorldMgr = _G.PWorldMgr
end

function ExclusiveBattleQuestMgr:OnEnd()
	--和OnBegin对应 在OnBegin中初始化的数据（相当于模块的私有数据），需要在这里清除
end

function ExclusiveBattleQuestMgr:OnShutdown()
	--和OnInit对应 在OnInit中模块自身的数据，需要在这里清除
end

function ExclusiveBattleQuestMgr:OnRegisterNetMsg()
	--示例代码先注释 以免影响正常逻辑
	--self:RegisterGameNetMsg(CS_CMD.CS_CMD_CHATC, SUB_MSG_ID.CS_CHAT_CMD_MSG_PUSH, self.OnNetMsgChatMsgPush)
    -- self:RegisterGameNetMsg(CS_CMD.CS_CMD_PWORLD, CS_PWORLD_CMD.CS_PWORLD_CMD_ENTER, self.OnPWorldRespEnter)--进入副本
    -- self:RegisterGameNetMsg(CS_CMD.CS_CMD_PWORLD, CS_PWORLD_CMD.CS_PWORLD_CMD_LEAVE, self.OnPWorldRespLeave) --退出副本
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_PWORLD, CS_PWORLD_CMD.CS_PWORLD_CMD_PROGRESS, self.OnNetRspPWorldProgress)--副本进度
end

function ExclusiveBattleQuestMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnPWorldMapEnter)
end

---OnPWorldMapEnter
---@param Params any
function ExclusiveBattleQuestMgr:OnPWorldMapEnter(Params)
	--C++侧发送的事件 Params类型为 FEventParams
	--Lua侧发送的事件 Params类型由SendEvent时指定
    local CurPWOrldCfg = PWorldMgr:GetCurrPWorldTableCfg()
    if CurPWOrldCfg then
        local IsInPhaseMap = CurPWOrldCfg.FunctionUIType == 1
        MainPanelVM:SetExclusiveBattleQuestVisible(IsInPhaseMap)

        if IsInPhaseMap then
			self:InitPworldStepCfg(CurPWOrldCfg.ID)
		end
    end
end

function ExclusiveBattleQuestMgr:OnNetRspPWorldProgress(MsgBody)
    local CurPWOrldCfg = PWorldMgr:GetCurrPWorldTableCfg()
    if CurPWOrldCfg then
        local IsInPhaseMap = CurPWOrldCfg.FunctionUIType == 1
		
		if IsInPhaseMap then
			local BaseInfo = PWorldMgr.BaseInfo
			local Progress = MsgBody.Progress
			if (BaseInfo.CurrPWorldResID == Progress.PWorldResID) then
				self.CurStep = Progress.CurStep
				if self.ProgressList == nil then
					self:InitPworldStepCfg(Progress.PworldResID)
				end
				local Info = {
					QuestName = CurPWOrldCfg.PWorldName,
					Progress = Progress.CurProgress,
					MaxProgress = self.ProgressList and self.ProgressList[Progress.CurStep].MaxProgress or 0
				}
				ExclusiveBattleQuestVM:ShowInfo(Info)
			end
        end
	end
end

--尽量都加上文档注释，调用时可以智能提示，也方便他人查看
---GetXXX
---@param ID number
---@return table
function ExclusiveBattleQuestMgr:GetXXX(ID)
end

function ExclusiveBattleQuestMgr:InitPworldStepCfg(PworldResID)
	local PworldStepTableCfg = PworldStepCfg:FindCfgByKey(PworldResID)
	if PworldStepTableCfg == nil then return end

	local ProgressList = {}
    local StageCount = 10 --目前最多10个阶段
    for i = 1, StageCount do
        local PworldStepInfo = PworldStepTableCfg.Steps[i]
        if (PworldStepInfo ~= nil) then
            if (PworldStepInfo.Text ~= "" and PworldStepInfo.MaxProgress > 0) then
                local StageUnit = {}
                StageUnit.Text = PworldStepInfo.Text
                StageUnit.MaxProgress = PworldStepInfo.MaxProgress
                table.insert(ProgressList, StageUnit)
            end
        end
    end

    self.ProgressList = ProgressList
end

--要返回当前类
return ExclusiveBattleQuestMgr
