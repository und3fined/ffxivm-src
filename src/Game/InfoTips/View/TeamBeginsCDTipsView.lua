---
--- Author: ds_tianjiateng
--- DateTime: 2024-03-06 10:51
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TimeUtil = require("Utils/TimeUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MsgTipsID = require("Define/MsgTipsID")
local AudioUtil = require("Utils/AudioUtil")

--- 设置生效音效
local SoundNameSetBegin = "AkAudioEvent'/Game/WwiseAudio/Events/sound/battle/etc/SE_Bt_Etc_BattleStart/Play_SE_Bt_Etc_BattleStart.Play_SE_Bt_Etc_BattleStart'"
--- 倒计时每秒音效
local SoundNameCountDown = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/Play_SE_UI_SE_UI_CFTimeCount.Play_SE_UI_SE_UI_CFTimeCount'"
--- 开始音效
local SoundNameStart = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_INGAME/Play_boolean_new.Play_boolean_new'"

---@class TeamBeginsCDTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field HorizontalBegins UFHorizontalBox
---@field HorizontalBeginsScale UFHorizontalBox
---@field HorizontalTips UFHorizontalBox
---@field PanelBegins UFCanvasPanel
---@field PanelTips UFCanvasPanel
---@field TextBegins URichTextBox
---@field TextBeginsScale URichTextBox
---@field TextCountDown URichTextBox
---@field TextName UFTextBlock
---@field TextTips UFTextBlock
---@field AnimBegins UWidgetAnimation
---@field AnimCountDown UWidgetAnimation
---@field AnimTips UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamBeginsCDTipsView = LuaClass(UIView, true)

function TeamBeginsCDTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.HorizontalBegins = nil
	--self.HorizontalBeginsScale = nil
	--self.HorizontalTips = nil
	--self.PanelBegins = nil
	--self.PanelTips = nil
	--self.TextBegins = nil
	--self.TextBeginsScale = nil
	--self.TextCountDown = nil
	--self.TextName = nil
	--self.TextTips = nil
	--self.AnimBegins = nil
	--self.AnimCountDown = nil
	--self.AnimTips = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TeamBeginsCDTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamBeginsCDTipsView:OnInit()
end

function TeamBeginsCDTipsView:OnDestroy()

end

function TeamBeginsCDTipsView:OnShow()
	_G.RoleInfoMgr:QueryRoleSimple(self.Params.SponsorRoleID, 
		function(View, ViewModel)
			local Name = ViewModel.Name
			self:CountDownBegin(Name)
		end,
		self, true
	)
	UIUtil.SetIsVisible(self.PanelTips, true)
	UIUtil.SetIsVisible(self.TextName, true)
	UIUtil.SetIsVisible(self.HorizontalTips, true)
	self.Flag = true
end

function TeamBeginsCDTipsView:OnHide()
	self:UnRegisterAllTimer()
	_G.SignsMgr.IsDuringCountDown = false
	UIUtil.SetIsVisible(self.PanelTips, true)
	_G.EventMgr:SendEvent(_G.EventID.TeamBtnStateChanged)
	self:Hide()
end

function TeamBeginsCDTipsView:OnRegisterUIEvent()

end

function TeamBeginsCDTipsView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.TeamUpdateMember, self.OnGameEventPWorldTeamMemUpd)
end

function TeamBeginsCDTipsView:OnRegisterBinder()
end

function TeamBeginsCDTipsView:CountDownBegin(Name)
	local Params = self.Params
	if Params == nil then
		return
	end
	self.TextName:SetText(Name)
	local SeverTime = TimeUtil.GetServerTime()
	local EndTime = Params.EndTime

	self.SettingTime = math.ceil(EndTime / 1000) - SeverTime
	local CountDownBeginText = string.format("%s%d%s", LSTR("距离开始战斗还有"), self.SettingTime, LSTR("秒"))
	AudioUtil.LoadAndPlayUISound(SoundNameSetBegin)

	self.TextTips:SetText(CountDownBeginText)
	_G.ChatMgr:AddSysChatMsg(CountDownBeginText)
	_G.ChatMgr:AddSysChatMsg(string.format("%s%s%s", "(", Name, ")"))

	self:PlayAnimation(self.AnimTips)

	UIUtil.SetIsVisible(self.PanelBegins, false)
	UIUtil.SetIsVisible(self.TextCountDown, false)

	local Delay = self.AnimTips:GetEndTime()

	--- 设置时特殊处理   提前结束AnimTips
	if self.SettingTime == 5 then
		Delay = 1
	end
	self.RemainningTime = math.modf(self.SettingTime - Delay)
	self:RegisterTimer(self.CountDownTimer, Delay, 1, 0)
end

function TeamBeginsCDTipsView:CountDownTimer()
	if self.RemainningTime < 0  then
		return
	end
	UIUtil.SetIsVisible(self.PanelTips, self.SettingTime ~= 5)
	if self.RemainningTime % 5 == 0 and self.SettingTime - self.RemainningTime >= 5 and self.RemainningTime > 5 then
		local TipsText = string.format("%s%d%s", LSTR("距离开始战斗还有"), self.RemainningTime, LSTR("秒"))
		self.TextTips:SetText(TipsText)
		_G.ChatMgr:AddSysChatMsg(TipsText)
		self:PlayAnimation(self.AnimTips)
		UIUtil.SetIsVisible(self.TextName, false)
	elseif self.RemainningTime <= 5 then
		UIUtil.SetIsVisible(self.TextCountDown, true)
		self.TextCountDown:SetText(self.RemainningTime)
		self:PlayAnimation(self.AnimCountDown)
		AudioUtil.LoadAndPlayUISound(SoundNameCountDown)
		if self.RemainningTime <= 0 and self.Flag then
			self.Flag = false
			UIUtil.SetIsVisible(self.TextCountDown, false)
			self.TimerBegin = self:RegisterTimer(
				function()
					local Delay = self.AnimBegins:GetEndTime()
					UIUtil.SetIsVisible(self.PanelBegins, true)
					self:PlayAnimation(self.AnimBegins)
					AudioUtil.LoadAndPlayUISound(SoundNameStart)
					self:RegisterTimer(self.OnHide, Delay, 1, 1)
					_G.ChatMgr:AddSysChatMsg(LSTR("战斗开始！"))
				end, 
			0, 1)
		end
	end
	
	self.RemainningTime = math.modf(self.RemainningTime - 1)
end

--- 队伍成员变更时取消当前倒计时
function TeamBeginsCDTipsView:OnGameEventPWorldTeamMemUpd()
	MsgTipsUtil.ShowTipsByID(MsgTipsID.TeamMemUpdCancleCountDown)
	self:OnHide()
end

return TeamBeginsCDTipsView