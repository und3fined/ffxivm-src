--
-- Author: peterxie
-- Date:
-- Description: 战场日志，包括预警倒计时、战场事件、击杀信息等
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local TimeUtil = require("Utils/TimeUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local PVPTeamMgr = require("Game/PVP/Team/PVPTeamMgr")
local PVPColosseumDefine = require("Game/PVP/Colosseum/PVPColosseumDefine")
local ColosseumTeam = PVPColosseumDefine.ColosseumTeam
local ColosseumLogType = PVPColosseumDefine.ColosseumLogType
local ColosseumLogIcon = PVPColosseumDefine.ColosseumLogIcon
local ColosseumLogInfoID = PVPColosseumDefine.ColosseumLogInfoID

local LSTR = _G.LSTR
local FLOG_INFO = _G.FLOG_INFO

local LogMaxLimitShowTime = 3000 -- 最大显示时间
local LogMinLimitShowTime = 1000 -- 最小显示时间
local bDisableLog = false -- 是否禁用日志


---@class BattleLogObj 战场日志对象
local BattleLogObj = LuaClass()

function BattleLogObj:Ctor()
	self.LogType = 0 -- 战场日志类型

	self.KillerRoleID = 0 -- 击杀日志的参数
	self.DeatherRoleID = 0
	self.KOCount = 0

	self.HasShow = false -- 标记该对象是否已经显示过
	self.LogID = 0 -- 战场日志ID，用于标记唯一性
end

function BattleLogObj:LogInfo()
	if bDisableLog then
		return
	end

	local Info = string.format("LogType=%d", self.LogType)

	if self.LogType == ColosseumLogType.MKS_LOG_TYPE_KNOCKOUT then
		local KillRoleName = ""
		local KillerMemberVM = PVPTeamMgr:FindMemberVMByRoleID(self.KillerRoleID)
		if KillerMemberVM then
			KillRoleName = KillerMemberVM.Name
		end

		local DeatherRoleName = ""
		local DeatherMemberVM = PVPTeamMgr:FindMemberVMByRoleID(self.DeatherRoleID)
		if DeatherMemberVM then
			DeatherRoleName = DeatherMemberVM.Name
		end

		Info = string.format("%s Killer(RoleID=%s, Name=%s), Deather(RoleID=%s, Name=%s), KOCount=%s"
			, Info, self.KillerRoleID, KillRoleName, self.DeatherRoleID, DeatherRoleName, self.KOCount)
	end

	FLOG_INFO("[PVPColosseumBattleLogVM] BattleLogObj LogID=%d %s", self.LogID, Info)
end



---@class BattleLogVM 战场日志VM，包括事件提示和击杀提示
---@field LogObj BattleLogObj
local BattleLogVM = LuaClass(UIViewModel)

function BattleLogVM:Ctor()
	self.LogObj = nil -- 显示的战场日志对象
	self.Visible = false -- 是否显示
	self.ShowTime = 0 -- 开始显示时间戳

	self.VisibleEvent = false -- 是否显示Event节点
	self.VisibleKO = false -- 是否显示KO节点
	self.VisibleCommand = false -- 是否显示Command节点

	self.Event_Icon = "" -- 事件图标
	self.Event_Str = "" -- 事件内容
	self.Event_Bg = "" -- 事件背景图
	self.Event_BgEffect = false -- 事件背景特效

	self.KO_Name = "" -- Killer名称
	self.KO_Count = "" -- Killer连杀次数
	self.KO_IsMajor = false -- Killer是否主角自己
	self.KO_ProfBg1 = "" -- Killer职业背景
	self.KO_ProfBg2 = "" -- Deather职业背景
	self.KO_ProfID1 = 0 -- Killer职业
	self.KO_ProfID2 = 0 -- Deather职业

	self.VMInstID = 0 -- 实例ID，用于调试
	self.CopyShow = false -- 是否是拷贝显示
	self.LogID = 0 -- 战场日志ID，用于标记唯一性
end

---隐藏日志
function BattleLogVM:ResetVM()
	self:LogInfo("ResetVM")
	self.LogObj = nil
	self.Visible = false
	self.ShowTime = 0

	self.VisibleEvent = false
	self.VisibleKO = false
	self.VisibleCommand = false

	self.CopyShow = false
	self.LogID = 0
end

---显示一个战场日志对象
---@param LogObj BattleLogObj
function BattleLogVM:ShowLogObj(LogObj)
	if LogObj == nil then
		return
	end

	self.LogObj = LogObj
	self.Visible = true
	self.ShowTime = TimeUtil.GetServerTimeMS()
	LogObj.HasShow = true

	if LogObj.LogType == ColosseumLogType.MKS_LOG_TYPE_KNOCKOUT then
		self:ShowLogKnockOut()
	else
		self:ShowLogEvent()
	end

	self.CopyShow = false
	self.LogID = LogObj.LogID
	self:LogInfo("ShowLogObj")
end

---拷贝显示另一个战场日志VM
---@param OtherLogVM BattleLogVM
function BattleLogVM:CopyShowLogVM(OtherLogVM)
	if OtherLogVM == nil then
		return
	end

	self.LogObj = OtherLogVM.LogObj
	self.Visible = OtherLogVM.Visible
	self.ShowTime = OtherLogVM.ShowTime

	self.VisibleEvent = OtherLogVM.VisibleEvent
	self.VisibleKO = OtherLogVM.VisibleKO
	self.VisibleCommand = OtherLogVM.VisibleCommand

	self.Event_Icon = OtherLogVM.Event_Icon
	self.Event_Str = OtherLogVM.Event_Str
	self.Event_Bg = OtherLogVM.Event_Bg
	self.Event_BgEffect = OtherLogVM.Event_BgEffect

	self.KO_Name = OtherLogVM.KO_Name
	self.KO_Count = OtherLogVM.KO_Count
	self.KO_IsMajor = OtherLogVM.KO_IsMajor
	self.KO_ProfBg1 = OtherLogVM.KO_ProfBg1
	self.KO_ProfBg2 = OtherLogVM.KO_ProfBg2
	self.KO_ProfID1 = OtherLogVM.KO_ProfID1
	self.KO_ProfID2 = OtherLogVM.KO_ProfID2

	self.CopyShow = true
	self.LogID = OtherLogVM.LogID
	self:LogInfo("CopyShowLogVM")
end

function BattleLogVM:LogInfo(Msg, ...)
	if bDisableLog then
		return
	end

	if not self.LogObj then
		return
	end

	local Info = string.format(Msg, ...)
	FLOG_INFO("[PVPColosseumBattleLogVM] BattleLogVM VMInstID=%d LogID=%d %s", self.VMInstID, self.LogID, Info)
end

---显示战场事件日志
function BattleLogVM:ShowLogEvent()
	self.VisibleEvent = true
	self.VisibleKO = false

	local EventBg = ColosseumLogIcon.LeftTipsGrey
	local EventBgEffect = false
	local EventStr = ""
	local EventStrOutlineColor = "#0000007f"

	local LogType = self.LogObj.LogType
	if LogType == ColosseumLogType.MKS_LOG_TYPE_CRYSTAL_UNLOCKED then
		self.Event_Icon = ColosseumLogIcon.PVPCOLOSSEUM_LOG_ICON_CRYSTAL_UNLOCKED_2
		EventStr = LSTR(810015)

	elseif LogType == ColosseumLogType.MKS_LOG_TYPE_PASS_CHECKPOINT_TEAM_1 then
		if _G.PVPColosseumMgr:GetTeamIndex() == ColosseumTeam.COLOSSEUM_TEAM_2 then
			self.Event_Icon = ColosseumLogIcon.PVPCOLOSSEUM_LOG_ICON_PASS_CHECKPOINT_RED
			EventBg = ColosseumLogIcon.LeftTipsRed
			EventBgEffect = true
			EventStrOutlineColor = "#ba2a447f"
		else
			self.Event_Icon = ColosseumLogIcon.PVPCOLOSSEUM_LOG_ICON_PASS_CHECKPOINT_BLUE
		end
		EventStr = LSTR(810019)

	elseif LogType == ColosseumLogType.MKS_LOG_TYPE_PASS_CHECKPOINT_TEAM_2 then
		if _G.PVPColosseumMgr:GetTeamIndex() == ColosseumTeam.COLOSSEUM_TEAM_2 then
			self.Event_Icon = ColosseumLogIcon.PVPCOLOSSEUM_LOG_ICON_PASS_CHECKPOINT_BLUE
		else
			self.Event_Icon = ColosseumLogIcon.PVPCOLOSSEUM_LOG_ICON_PASS_CHECKPOINT_RED
			EventBg = ColosseumLogIcon.LeftTipsRed
			EventBgEffect = true
			EventStrOutlineColor = "#ba2a447f"
		end
		EventStr = LSTR(810020)

	elseif LogType == ColosseumLogType.MKS_LOG_TYPE_ERUPTION_EXEC then
		self.Event_Icon = ColosseumLogIcon.PVPCOLOSSEUM_LOG_ICON_ERUPTION
		EventStr = LSTR(810016)

	elseif LogType == ColosseumLogType.MKS_LOG_TYPE_TORNADO_EXEC then
		self.Event_Icon = ColosseumLogIcon.PVPCOLOSSEUM_LOG_ICON_TORNADO
		EventStr = LSTR(810017)

	elseif LogType == ColosseumLogType.MKS_LOG_TYPE_FESTIVAL_EXEC then
		self.Event_Icon = ColosseumLogIcon.PVPCOLOSSEUM_LOG_ICON_FESTIVAL
		EventStr = LSTR(810018)
	end

	self.Event_Str = RichTextUtil.GetText(EventStr, nil, EventStrOutlineColor)
	self.Event_Bg = EventBg
	self.Event_BgEffect = EventBgEffect
end

---显示战场击杀日志
function BattleLogVM:ShowLogKnockOut()
	self.VisibleEvent = false
	self.VisibleKO = true

	self.KO_Count = string.format(LSTR(810033), self.LogObj.KOCount)

	local KillerMemberVM = PVPTeamMgr:FindMemberVMByRoleID(self.LogObj.KillerRoleID)
	if KillerMemberVM then
		self.KO_ProfID1 = KillerMemberVM.ProfID
		self.KO_Name = KillerMemberVM.Name

		local bIsMyTeam = _G.PVPColosseumMgr:IsMyTeamByCampID(KillerMemberVM.CampID)
		if bIsMyTeam then
			self.KO_ProfBg1 = ColosseumLogIcon.ProfBlueBg
			self.KO_ProfBg2 = ColosseumLogIcon.ProfRedBg
		else
			self.KO_ProfBg1 = ColosseumLogIcon.ProfRedBg
			self.KO_ProfBg2 = ColosseumLogIcon.ProfBlueBg
		end
	end

	local DeatherMemberVM = PVPTeamMgr:FindMemberVMByRoleID(self.LogObj.DeatherRoleID)
	if DeatherMemberVM then
		self.KO_ProfID2 = DeatherMemberVM.ProfID
	end
end


---@class PVPColosseumBattleLogVM : UIViewModel
local PVPColosseumBattleLogVM = LuaClass(UIViewModel)

function PVPColosseumBattleLogVM:Ctor()
	-- 倒计时提示 --
	self.CountDownVisible = false -- 倒计时节点是否可见
	self.CountDownEndTime = 0 -- 倒计时结束时间戳
	self.CountDownContent = "" -- 倒计时提示内容
	self.CountDownIcon = ""
	self.CountDownBg = ""
	self.CountDownBgEffect = false

	-- 战场日志显示，要考虑动效表现 --
	self.LogVM1 = BattleLogVM:New()
	self.LogVM1.VMInstID = 1
	self.LogVM2 = BattleLogVM:New()
	self.LogVM2.VMInstID = 2

	-- 战场日志对象队列
	self.LogObjQueue = {}
	self.UpdateQueueTimerID = 0
	self.UniqueLogID = 0
end

function PVPColosseumBattleLogVM:BattleStart()
	self.CountDownVisible = false
	self.CountDownEndTime = 0
	self.CountDownContent = ""

	self.LogVM1:ResetVM()
	self.LogVM2:ResetVM()

	table.clear(self.LogObjQueue)
	self.UpdateQueueTimerID = _G.TimerMgr:AddTimer(self, self.OnTimer, 0, 0.5, 0)
	self.UniqueLogID = 0
end

function PVPColosseumBattleLogVM:Reset()
	_G.TimerMgr:CancelTimer(self.UpdateQueueTimerID)
end

---显示战场预警倒计时
---@param LogInfoID number 倒计时类型
---@param EndTime number 倒计时结束时间戳
function PVPColosseumBattleLogVM:SetCountDownInfo(LogInfoID, EndTime)
	local RemainTime = EndTime - TimeUtil.GetServerTimeMS()
	local RemainSec = RemainTime / 1000
	if RemainSec < 1 then
		self.CountDownVisible = false
		return
	end

	local Content -- 倒计时提示内容
	local Icon
	local Bg = ColosseumLogIcon.LeftTipsRed
	local BgEffect = true
	local ContentColor = "#ba2a447f"

	if LogInfoID == ColosseumLogInfoID.PVPCOLOSSEUM_LOG_INFO_ID_CRYSTAL then
		Content = LSTR(810011)
		Icon = ColosseumLogIcon.PVPCOLOSSEUM_LOG_ICON_CRYSTAL_UNLOCKED
		Bg = ColosseumLogIcon.LeftTipsGrey
		BgEffect = false
		ContentColor = "#0000007f"

	elseif LogInfoID == ColosseumLogInfoID.PVPCOLOSSEUM_LOG_INFO_ID_ERUPTION_EXEC then
		Content = LSTR(810012)
		Icon = ColosseumLogIcon.PVPCOLOSSEUM_LOG_ICON_ERUPTION

	elseif LogInfoID == ColosseumLogInfoID.PVPCOLOSSEUM_LOG_INFO_ID_TORNADO_EXEC then
		Content = LSTR(810013)
		Icon = ColosseumLogIcon.PVPCOLOSSEUM_LOG_ICON_TORNADO

	elseif LogInfoID == ColosseumLogInfoID.PVPCOLOSSEUM_LOG_INFO_ID_FESTIVAL_EXEC then
		Content = LSTR(810014)
		Icon = ColosseumLogIcon.PVPCOLOSSEUM_LOG_ICON_FESTIVAL
	end

	self.CountDownIcon = Icon
	self.CountDownBg = Bg
	self.CountDownBgEffect = BgEffect
	self.CountDownContent = RichTextUtil.GetText(Content, nil, ContentColor)
	self.CountDownEndTime = EndTime
	self.CountDownVisible = true
end

---隐藏战场预警倒计时
function PVPColosseumBattleLogVM:HideCountDownInfo()
	self.CountDownVisible = false
end


---显示战场事件日志
---@param LogType ColosseumLogType
function PVPColosseumBattleLogVM:PushLogEvent(LogType)
	local LogObj = BattleLogObj:New()
	self.UniqueLogID = self.UniqueLogID + 1
	LogObj.LogID = self.UniqueLogID
	LogObj.LogType = LogType

	LogObj:LogInfo()

	table.insert(self.LogObjQueue, LogObj)
	-- 队列有更新，立即执行一次
	self:OnTimer()
end

---显示战场击杀日志
---@param KillerRoleID number 击杀人
---@param DeatherRoleID number 死亡人
---@param KOCount number 连续击杀次数
function PVPColosseumBattleLogVM:PushLogKnockOut(KillerRoleID, DeatherRoleID, KOCount)
	local LogObj = BattleLogObj:New()
	self.UniqueLogID = self.UniqueLogID + 1
	LogObj.LogID = self.UniqueLogID
	LogObj.LogType = ColosseumLogType.MKS_LOG_TYPE_KNOCKOUT

	LogObj.KillerRoleID = KillerRoleID
	LogObj.DeatherRoleID = DeatherRoleID
	LogObj.KOCount = KOCount

	LogObj:LogInfo()

	-- 从左侧战斗日志区域去掉，换成tips表现
	--table.insert(self.LogObjQueue, LogObj)
	--self:OnTimer()
	MsgTipsUtil.ShowPVPColosseumKillTips(LogObj)
end


function PVPColosseumBattleLogVM:GetUnVisibleVM()
	if not self.LogVM1.Visible then
		return self.LogVM1
	end

	if not self.LogVM2.Visible then
		return self.LogVM2
	end
end

function PVPColosseumBattleLogVM:OnTimer()
	local CurrentLogObj = self.LogObjQueue[1] ---@type BattleLogObj

	if self.LogVM1.Visible then
		local HasShowTime = TimeUtil.GetServerTimeMS() - self.LogVM1.ShowTime
		if HasShowTime > LogMaxLimitShowTime then
			-- 显示时间到期
			if self.LogVM2.Visible then
				self.LogVM1:CopyShowLogVM(self.LogVM2) -- 更新显示位置
				self.LogVM2:ResetVM()
			else
				self.LogVM1:ResetVM()
			end

		elseif HasShowTime > LogMinLimitShowTime and CurrentLogObj then
			if self.LogVM2.Visible then
				--self.LogVM1:ResetVM() -- 被顶下去
				self.LogVM1:CopyShowLogVM(self.LogVM2) -- 更新显示位置
				self.LogVM2:ResetVM()
			end
		end
	end

	if CurrentLogObj then
		local LogVM = self:GetUnVisibleVM()
		if LogVM then
			LogVM:ShowLogObj(CurrentLogObj)
		end
	end

	if CurrentLogObj and CurrentLogObj.HasShow then
		table.remove(self.LogObjQueue, 1)
	end
end


return PVPColosseumBattleLogVM