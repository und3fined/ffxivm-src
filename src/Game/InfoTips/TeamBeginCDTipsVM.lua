
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MsgTipsID = require("Define/MsgTipsID")
local TimeUtil = require("Utils/TimeUtil")
local TimerMgr = require("Timer/TimerMgr")
local AudioUtil = require("Utils/AudioUtil")
local UIUtil = require("Utils/UIUtil")

--- 设置生效音效
local SoundNameSetBegin = "AkAudioEvent'/Game/WwiseAudio/Events/sound/battle/etc/SE_Bt_Etc_BattleStart/Play_SE_Bt_Etc_BattleStart.Play_SE_Bt_Etc_BattleStart'"
--- 倒计时每秒音效
local SoundNameCountDown = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Play_SE_UI_SE_UI_CFTimeCount.Play_SE_UI_SE_UI_CFTimeCount'"
--- 开始音效
local SoundNameStart = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_INGAME/Play_boolean_new.Play_boolean_new'"

---@class TeamBeginCDTipsVM : UIViewModel
local TeamBeginCDTipsVM = LuaClass(UIViewModel)

function TeamBeginCDTipsVM:Ctor()
	self.CDTimerID = nil
	self.Flag = false			--- 每次设置倒计时生效时设置为true
	self.CountDownNum = nil
	self.SubTitleText = nil
	self.PanelVisible = true
	self.StartTime = 0
	self.EndTime = 0
end

function TeamBeginCDTipsVM:OnInit()
end

function TeamBeginCDTipsVM:OnBegin()
end

function TeamBeginCDTipsVM:OnEnd()
end

function TeamBeginCDTipsVM:OnShutdown()
end

function TeamBeginCDTipsVM:OnBeginCountDown(CountDown)
	local SeverTime = TimeUtil.GetServerTime()
	local CountDownEndTime = CountDown.EndTime / 1000 - SeverTime
	local SponsorRoleID = CountDown.SponsorRoleID
	_G.RoleInfoMgr:QueryRoleSimple(SponsorRoleID, 
	function(_, ViewModel)
		self.Flag = true
		AudioUtil.LoadAndPlayUISound(SoundNameSetBegin)
		local Name = ViewModel.Name
		local EndTime = math.floor(CountDownEndTime)
		self:CountDownBegin(Name, EndTime)
		end,
		self, true
	)
end

function TeamBeginCDTipsVM:CountDownBegin(Name, EndTime)
	self.SettingTime = EndTime
	local Params = {}
	Params.BindVM = self
	Params.SubTitleText = Name
	Params.TextSubTitleVisible = true
	self.CountDownNum = string.format(LSTR(1240050), EndTime)	--- "距离开始战斗还有%d秒"
	_G.ChatMgr:AddSysChatMsg(self.CountDownNum)
	_G.ChatMgr:AddSysChatMsg(string.format("%s%s%s", "(", Name, ")"))
	self.PanelVisible = true
	local TempView1 = _G.UIViewMgr:ShowView(_G.UIViewID.InfoCountdownTipsView, Params)
	TempView1:PlayAnimIn()
	self.InitTimerID = TimerMgr:AddTimer(self, function()
		self:UnRegisterTimer(self.InitTimerID)
	end, 3, 1, 1)
	self.CDTimerID = TimerMgr:AddTimer(self, function()
		EndTime = EndTime - 1
		self.CountDownNum = EndTime
		if EndTime % 5 == 0 and self.SettingTime - EndTime >= 5 and EndTime > 5 then
			self.PanelVisible = true
			Params.TextSubTitleVisible = false
			local TempView2 = _G.UIViewMgr:ShowView(_G.UIViewID.InfoCountdownTipsView, Params)
			TempView2:PlayAnimIn()
			self.CountDownNum = string.format(LSTR(1240050), EndTime)	--- "距离开始战斗还有%d秒"
			self.SubTitleText = ""
			_G.ChatMgr:AddSysChatMsg(self.CountDownNum)
		elseif EndTime <= 5 then
			self.PanelVisible = true
			if EndTime == 5 then
				Params.TextSubTitleVisible = false
				local TempView3 = _G.UIViewMgr:ShowView(_G.UIViewID.InfoCountdownTipsView, Params)
				TempView3:PlayAnimIn()
			end
			self.SubTitleText = ""
			AudioUtil.LoadAndPlayUISound(SoundNameCountDown)
			if EndTime <= 0 and self.Flag then
				self.Flag = false
				AudioUtil.LoadAndPlayUISound(SoundNameStart)
				self.CountDownNum = LSTR(1240049)	--- "战斗开始"
				_G.ChatMgr:AddSysChatMsg(self.CountDownNum)
				self.EndCDTimerID = TimerMgr:AddTimer(self, function()
					_G.UIViewMgr:HideView(_G.UIViewID.InfoCountdownTipsView)
					_G.SignsMgr.IsDuringCountDown = false
					_G.EventMgr:SendEvent(_G.EventID.TeamBtnStateChanged)
					self:UnRegisterTimer(self.EndCDTimerID)
				end, 1 , 1)
				self:UnRegisterTimer(self.CDTimerID)
			end
		else
			-- TempView:PlayAnimOut()
			self.PanelVisible = false
		end
	end, 3, 1, EndTime)
end

function TeamBeginCDTipsVM:OnCancleCountDown(CountDown)
	_G.RoleInfoMgr:QueryRoleSimple(CountDown.SponsorRoleID, 
	function(_, ViewModel)
		local Name = ViewModel.Name
		MsgTipsUtil.ShowTipsByID(MsgTipsID.TeamCancleCountDown, nil, Name)
		if self.CDTimerID then
			self:UnRegisterTimer(self.CDTimerID)
			_G.UIViewMgr:HideView(_G.UIViewID.InfoCountdownTipsView)
		end
	end,
	self, true)
end

function TeamBeginCDTipsVM:UnRegisterTimer(TimerID)
	if TimerID then
		TimerMgr:CancelTimer(TimerID)
		TimerMgr:UnRegisterTimer(TimerID)
	end
end
return TeamBeginCDTipsVM