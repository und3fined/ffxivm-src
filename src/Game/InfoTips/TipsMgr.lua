--
-- Author: anypkvcai
-- Date: 2020-10-27 20:10:37
-- Description:
--


local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local TimeUtil = require("Utils/TimeUtil")
local UIViewMgr = require("UI/UIViewMgr")
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")
local UIViewID = require("Define/UIViewID")
local NetworkMsgConfig = require("Define/NetworkMsgConfig")
local LoginNewDefine = require("Game/LoginNew/LoginNewDefine")

local CS_CMD = ProtoCS.CS_CMD
local GameNetworkMgr

---@class TipsMgr : MgrBase
local TipsMgr = LuaClass(MgrBase)

function TipsMgr:OnInit()
	--self.TimerID = nil
	self.LastTime = 0
	self.DelayTime = 0
	self.QueueTips = {}
	self.CurShowTip = nil
end

function TipsMgr:OnBegin()
	GameNetworkMgr = _G.GameNetworkMgr
end

function TipsMgr:OnEnd()
end

function TipsMgr:OnShutdown()

end

function TipsMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.AppEnterForeground, self.OnGameEventAppEnterForeground)
end

function TipsMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_ERR, 0, self.OnNetMsgError)
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_SYS_NOTICE, 0, self.OnNetMsgSysNotice)
end

function TipsMgr:OnGameEventAppEnterForeground()
	local View = UIViewMgr:FindView(UIViewID.ActiveSystemErrorTips)
	if View ~= nil then
		View:Hide()   -- 清一下可能存在的残留
		_G.UIViewMgr:RecycleView(View)
	end
end

function TipsMgr:OnNetMsgError(MsgBody)
	local Msg = MsgBody
	if nil == Msg then
		return
	end

	local ErrorCode = Msg.ErrCode
	if NetworkMsgConfig ~= nil and NetworkMsgConfig.GetErrorCodeConfig ~= nil then
		local Config = NetworkMsgConfig.GetErrorCodeConfig(Msg.Cmd, Msg.SubCmd)
		if nil ~= Config then
			if Config.bErrorCode then
				GameNetworkMgr:DispatchMsg(Msg.Cmd, Msg.SubCmd, { ErrorCode = ErrorCode })
			end

			if Config.bIgnoreTips then
				return
			end
		end
	end

	if ErrorCode > 0 and ErrorCode ~= LoginNewDefine.VersionErrCode then
		MsgTipsUtil.ShowTipsByID(ErrorCode, nil, table.unpack(Msg.ErrMsg))
	end

	EventMgr:SendEvent(EventID.ErrorCode, ErrorCode)
end

function TipsMgr:OnNetMsgSysNotice(MsgBody)
	if nil == MsgBody then
		return
	end
	local SysNoticeID = MsgBody.SysNoticeID
	local Params = MsgBody.Params

	MsgTipsUtil.ShowTipsByID(SysNoticeID, nil, table.unpack(Params)) 
end

function TipsMgr:OnRegisterTimer()
	--self.TimerID = self:RegisterTimer(self.OnTimer, 0, 0.1, 0)
	self:RegisterTimer(self.OnTimer, 0, 0.1, 0)
end

function TipsMgr:OnTimer()
	local TimeStamp = TimeUtil.GetLocalTimeMS()
	local LastTime = self.LastTime
	if TimeStamp - LastTime > self.DelayTime then
		local QueueTips = self.QueueTips
		local Item = QueueTips[1]
		if nil == Item then
			--self:UnRegisterTimer(self.TimerID)
			self.CurShowTip = nil
			return
		end
		self.CurShowTip = Item
		local ShowTime = Item.ShowTime
		self:ShowTipsInternal(Item.ViewID, Item.Content, ShowTime)
		self.LastTime = TimeStamp
		self.DelayTime = ShowTime * 1000 + 100
		table.remove(QueueTips, 1)
	end
end

function TipsMgr:ShowTipsView(ViewID, Content, ShowTime, SoundName)
	local NewTip = { ViewID = ViewID, Content = Content, ShowTime = ShowTime, SoundName = SoundName, SubmitTime = TimeUtil.GetLocalTimeMS() }
	local CheckRepeatedTime = TimeUtil.GetLocalTimeMS() - ShowTime
	
	local TempQueue = self.QueueTips
	local CurShowTip = self.CurShowTip
	if CurShowTip ~= nil then
		if CurShowTip.SubmitTime <= CheckRepeatedTime 
			and CurShowTip.Content == NewTip.Content 
			and NewTip.ViewID == CurShowTip.ViewID then
			return
		end
	end
	for i = #TempQueue, 1, -1 do
		local Tip = TempQueue[i]
		if Tip.SubmitTime > CheckRepeatedTime then
			break;
		end
		if Tip.Content == NewTip.Content and NewTip.ViewID == Tip.ViewID then
			return
		end
	end

	table.insert(self.QueueTips, NewTip)
end

function TipsMgr:ShowTipsInternal(ViewID, Content, ShowTime, SoundName)
	local Params = { Content = Content, ShowTime = ShowTime, SoundName = SoundName }
	UIViewMgr:ShowView(ViewID, Params)
end

return TipsMgr