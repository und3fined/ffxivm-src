---
--- Author: chunfengluo
--- DateTime: 2021-08-23 12:44
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local UIViewID = require("Define/UIViewID")
local DialogueUtil = require("Utils/DialogueUtil")

---@class NPCTalkMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Dialogue NPCTalkDialogPanelView
---@field FBtn_ClickArea UFButton
---@field TaskTips NPCTalkTaskTipsView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NPCTalkMainPanelView = LuaClass(UIView, true)

function NPCTalkMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Dialogue = nil
	--self.FBtn_ClickArea = nil
	--self.TaskTips = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NPCTalkMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Dialogue)
	self:AddSubView(self.TaskTips)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
	UIUtil.SetIsVisible(self.Dialogue, false, false)
end

function NPCTalkMainPanelView:OnInit()
	self:Reset()
	self.DialogPlayIndex = 1
	self.bIsDialogPlaying = false
	self.bIsDialogVisible = false
	self.bSpeedUp = false

end

function NPCTalkMainPanelView:OnDestroy()
end

function NPCTalkMainPanelView:OnShow()
    self.MajorIsSing = false
end

function NPCTalkMainPanelView:OnHide()

end

function NPCTalkMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.FBtn_ClickArea, self.OnClickDialogue)
	UIUtil.AddOnClickedEvent(self.Dialogue, self.Dialogue.BtnContinue, self.OnClickDialogue)
end

function NPCTalkMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.WorldPreLoad, self.Reset)
    self:RegisterGameEvent(EventID.MajorSingBarBegin, self.OnMajorSingBarBegin)
    self:RegisterGameEvent(EventID.MajorSingBarOver, self.OnMajorSingBarOver)
end

function NPCTalkMainPanelView:OnRegisterTimer()

end

function NPCTalkMainPanelView:OnRegisterBinder()

end

function NPCTalkMainPanelView:Reset()
	UIUtil.SetIsVisible(self.Dialogue, false)
	UIUtil.SetIsVisible(self.TaskTips, false)
	UIUtil.SetIsVisible(self.FBtn_ClickArea, false)
end

function NPCTalkMainPanelView:ShowDialog(Name, Post, Content)
	FLOG_INFO("Interactive ShowDialog")
	
	UIUtil.SetIsVisible(self.Dialogue, true)
	UIUtil.SetIsVisible(self.FBtn_ClickArea, true, true)

	-- self.Dialogue:PlayDialog(Name, Post, Content)
	----------------- PlayDialog展开
	if self.Dialogue.RichTextNPCName then
		UIUtil.SetIsVisible(self.Dialogue.RichTextNPCName, true)
		self.Dialogue.RichTextNPCName:SetText(Name)
	end
	if self.Dialogue.RichTextNPCTag then
		UIUtil.SetIsVisible(self.Dialogue.RichTextNPCTag, true)
		self.Dialogue.RichTextNPCTag:SetText(Post)
	end
	if self.Dialogue.RichTextNPCDialog then
		UIUtil.SetIsVisible(self.Dialogue.RichTextNPCDialog, true)
		self.Dialogue.RichTextNPCDialog:SetText("")
	end

	if self.Dialogue.TagSpecial then
		UIUtil.SetIsVisible(self.Dialogue.TagSpecial, (#Post ~= 0) and true or false,
		(#Post ~= 0) and _G.UE.ESlateVisibility.SelfHitTestInvisible or _G.UE.ESlateVisibility.Collapsed)
	end
	self.ConvertedContent = DialogueUtil.ParseLabel(Content)
	-- self.ConvertedContent = DialogueUtil.ReplaceParam(Content)
	self.RichTextSplitter = _G.UE.FRichTextSplitter.Create(self.ConvertedContent)
	self.DialogPlayIndex = 1
	self.bIsDialogPlaying = true
	self.bSpeedUp = false

	if self.Timer ~= nil then
		self:UnRegisterTimer(self.Timer)
		self.Timer = nil
	end

	local function SetDialog()
		local Text = nil
		if self.RichTextSplitter:RichTextLen() >= self.DialogPlayIndex then
			Text = self.RichTextSplitter:RichTextSub(self.DialogPlayIndex)
		else
			Text = self.RichTextSplitter:RichTextSub(self.RichTextSplitter:RichTextLen())
			self.bIsDialogPlaying = false
			if self.Timer ~= nil then
				self:UnRegisterTimer(self.Timer)
				self.Timer = nil
			end
		end

		if self.bIsSubtitle then
			self.Dialogue.RichTextSubtitle:SetText(Text)
		else
			self.Dialogue.RichTextNPCDialog:SetText(Text)
		end

		if self.bSpeedUp then
			self.DialogPlayIndex = self.DialogPlayIndex + 5
		else
			self.DialogPlayIndex = self.DialogPlayIndex + 1
		end
	end

	if self.bIsSubtitle then
		self.bIsDialogPlaying = false
		self.Dialogue.RichTextSubtitle:SetText(self.ConvertedContent)
	else
		self.Timer = self:RegisterTimer(SetDialog, 0, 0.05, 0)
	end
	---------------- PlayDialog展开
	_G.UIViewMgr:HideView(UIViewID.EmotionMainPanel)
	_G.BusinessUIMgr:HideMainPanel(UIViewID.MainPanel)
	InteractiveMgr:HideMainPanel()
	CommonUtil.HideJoyStick()

	if nil ~= self.Dialogue.AnimLoop then
		self.Dialogue:PlayAnimation(self.Dialogue.AnimLoop, 0, 0)
	end
	self.bIsDialogVisible = true
end


function NPCTalkMainPanelView:StopDialog()
	if nil ~= self.Dialogue and nil ~= self.Dialogue.AnimLoop then
		self.Dialogue:StopAnimation(self.Dialogue.AnimLoop)
	end

	UIUtil.SetIsVisible(self.FBtn_ClickArea, false)
	UIUtil.SetIsVisible(self.Dialogue, false)
	
	_G.BusinessUIMgr:ShowMainPanel(_G.UIViewID.MainPanel)
	self.bIsDialogVisible = false
end

function NPCTalkMainPanelView:HideDialog()
	FLOG_INFO("Interactive HideDialog")
	self:StopDialog()

	--该恢复到一级入口
	TimerMgr:AddTimer(nil, function()
		if not self.MajorIsSing then
			InteractiveMgr:ShowMainPanel()
		end
	end, 0.8, 0, 1)
end

function NPCTalkMainPanelView:IsDialogPlaying()
	return self.bIsDialogPlaying
end

function NPCTalkMainPanelView:IsDialogVisible()
	return self.bIsDialogVisible
end

function NPCTalkMainPanelView:SpeedUp()
	self.bSpeedUp = true;
end

function NPCTalkMainPanelView:SwitchStyle(StyleID)
	if (self.Dialogue ~= nil and _G.CommonUtil.IsObjectValid(self.Dialogue)) then
		_G.NpcDialogMgr.DoSwitchStyle(self.Dialogue, self, StyleID)
	end
end

function NPCTalkMainPanelView:OnMajorSingBarBegin()
    self.MajorIsSing = true
end

function NPCTalkMainPanelView:OnMajorSingBarOver()
    self.MajorIsSing = false
	-- InteractiveMgr:ShowMainPanel()
end

function NPCTalkMainPanelView:ShowFuncMenu()

end


function NPCTalkMainPanelView:OnClickDialogue()
	_G.FLOG_INFO("Interactive NPCTalkMainPanelView:OnClickDialogue")
	_G.EventMgr:SendEvent(EventID.ClickNextDialog)
end

return NPCTalkMainPanelView