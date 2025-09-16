---
--- Author: kofhuang
--- DateTime: 2025-04-10 10:41
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local DialogCfgTable = require("TableCfg/DialogCfg")
local StoryDefine = require("Game/Story/StoryDefine")
local ScenarioTextCfgTable = require("TableCfg/ScenarioTextCfg")
local FunctionCustomTalk = require("Game/Interactive/FunctionItem/FunctionCustomTalk")
local CustomDialogOptionCfg = require("TableCfg/CustomDialogOptionCfg")
local CustomDialogAnswerCfg = require("TableCfg/CustomDialogAnswerCfg")
local FunctionNpcQuit = require("Game/Interactive/FunctionItem/FunctionNpcQuit")
local DialogueBranchCfg = require("TableCfg/DialogueBranchCfg")
local QuestCfgTable = require("TableCfg/QuestCfg")
local QuestMainVM = require("Game/Quest/VM/QuestMainVM")
local JumboCactpotDefine = require("Game/JumboCactpot/JumboCactpotDefine")
local QuestHelper = require("Game/Quest/QuestHelper")

local AnswerContentIDList = JumboCactpotDefine.AnswerContentIDList
local NpcDialogMgr = _G.NpcDialogMgr
local UIViewID = _G.UIViewID
local UIViewMgr = _G.UIViewMgr
local GMMgr = _G.GMMgr
local TimerMgr = _G.TimerMgr
local UE = _G.UE
local QuestMgr = _G.QuestMgr


local GMType = {
	NPCDialogue = 1,
	AnimatedText = 2,
	TaskTracking = 3,
	CustomTalk = 4,
	DialogueBranch = 5
}

---@class NarrativeTestPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bg_2 UFImage
---@field Bg_3 UFImage
---@field Bg_4 UFImage
---@field BtnContinue UFButton
---@field BtnDrag UFButton
---@field BtnStart UFButton
---@field CloseBtn CommonCloseBtnView
---@field CurText UFTextBlock
---@field CustomTalk URichTextBox
---@field Dialogue UFCanvasPanel
---@field Dialogue_1 UFCanvasPanel
---@field FHorizontalBox_1 UFHorizontalBox
---@field ImgBG UFImage
---@field ImgDecoShadow UFImage
---@field ImgLIne UFImage
---@field LeftPanel UFCanvasPanel
---@field Maximum UEditableText
---@field Minimum UEditableText
---@field MovePanel UFCanvasPanel
---@field Runnum UFTextBlock
---@field TexTitle URichTextBox
---@field TextContent URichTextBox
---@field TextMinimize UFTextBlock
---@field Timeinterval UEditableText
---@field TitleText UFTextBlock
---@field TitleText_1 UFTextBlock
---@field IsDrag bool
---@field MovePanelSlot CanvasPanelSlot
---@field Offset Vector2D
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NarrativeTestPanelView = LuaClass(UIView, true)

function NarrativeTestPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bg_2 = nil
	--self.Bg_3 = nil
	--self.Bg_4 = nil
	--self.BtnContinue = nil
	--self.BtnDrag = nil
	--self.BtnStart = nil
	--self.CloseBtn = nil
	--self.CurText = nil
	--self.CustomTalk = nil
	--self.Dialogue = nil
	--self.Dialogue_1 = nil
	--self.FHorizontalBox_1 = nil
	--self.ImgBG = nil
	--self.ImgDecoShadow = nil
	--self.ImgLIne = nil
	--self.LeftPanel = nil
	--self.Maximum = nil
	--self.Minimum = nil
	--self.MovePanel = nil
	--self.Runnum = nil
	--self.TexTitle = nil
	--self.TextContent = nil
	--self.TextMinimize = nil
	--self.Timeinterval = nil
	--self.TitleText = nil
	--self.TitleText_1 = nil
	--self.IsDrag = nil
	--self.MovePanelSlot = nil
	--self.Offset = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.GMStartIndex = 0
	self.GMEndIndex = 0
end

function NarrativeTestPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CloseBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NarrativeTestPanelView:OnInit()

end

function NarrativeTestPanelView:OnDestroy()
	if self.GMTimer ~= nil then
		TimerMgr:CancelTimer(self.GMTimer)
		self.GMTimer = nil
	end
	UIViewMgr:HideView(UIViewID.InteractiveMainPanel)
	_G.InteractiveMgr:ShowOrHideMainPanel(true)
	_G.InteractiveMgr:ShowEntrances()
    _G.InteractiveMgr:ExitInteractive()
	_G.NpcDialogMgr:EndInteraction()
end

function NarrativeTestPanelView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end
	UIUtil.SetIsVisible(self.Dialogue, false)
	self.CustomTalk:SetText("")

	self.ViewType = Params.ViewType

	self.Runnum:SetText("")
	self.CurText:SetText(self.ViewType)

	if self.ViewType == LSTR("NPC对话") then
		self.GMType = GMType.NPCDialogue
	elseif self.ViewType == LSTR("动画文本") then
		self.GMType = GMType.AnimatedText
	elseif self.ViewType == LSTR("任务追踪") then
		self.GMType = GMType.TaskTracking
	elseif self.ViewType == LSTR("CustomTalk") then
		self.GMType = GMType.CustomTalk
	elseif self.ViewType == LSTR("对话选项") then
		self.GMType = GMType.DialogueBranch
	end
end

function NarrativeTestPanelView:OnHide()
	if self.GMTimer ~= nil then
		TimerMgr:CancelTimer(self.GMTimer)
		self.GMTimer = nil
	end
	if self.GMType == GMType.CustomTalk then
		UIViewMgr:HideView(UIViewID.InteractiveMainPanel)
		_G.InteractiveMgr:ShowOrHideMainPanel(true)
	elseif self.GMType == GMType.DialogueBranch then
		_G.EventMgr:SendEvent(EventID.ClickNextDialog)
	end

end

function NarrativeTestPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnStart, self.OnBtnStartClicked)
end

function NarrativeTestPanelView:OnRegisterGameEvent()

end

function NarrativeTestPanelView:OnRegisterBinder()

end

function NarrativeTestPanelView:OnBtnStartClicked()
	self.GMStartIndex = tonumber(self.Minimum:GetText())
	self.GMStartIndex = math.max(1,self.GMStartIndex)
	self.GMEndIndex = tonumber(self.Maximum:GetText())
	self.IntervalTime = tonumber(self.Timeinterval:GetText())

	if self.GMType == GMType.NPCDialogue then
		UIUtil.SetIsVisible(self.Dialogue, true)
		self:OnNPCDialogueStart()
	elseif self.GMType == GMType.AnimatedText then
		UIUtil.SetIsVisible(self.Dialogue, true)
		self:OnAnimatedTextStart()
	elseif self.GMType == GMType.TaskTracking then
		UIUtil.SetIsVisible(self.Dialogue, false)
		self:OnQuestStart()
	elseif self.GMType == GMType.CustomTalk then
		UIUtil.SetIsVisible(self.Dialogue, false)
		self:OnCustomTalkStart()
	elseif self.GMType == GMType.DialogueBranch then
		UIUtil.SetIsVisible(self.Dialogue, false)
		self:OnDialogueBranchStart(self.IntervalTime)		
	end
end

function NarrativeTestPanelView:OnNPCDialogueStart()
	local CfgTable = DialogCfgTable:FindAllCfg() or {}

	self.GMEndIndex = math.min(#CfgTable,self.GMEndIndex)

	-- FLOG_INFO(string.format("koff self.GMEndIndex:%s", self.GMEndIndex))

	self.PreDialogLibID = 0
	local function DialogCallBack()
		self.GMStartIndex = self.GMStartIndex + 1
		if self.GMStartIndex > self.GMEndIndex then
			TimerMgr:CancelTimer(self.GMTimer)
			self.GMTimer = nil
			return
		end
		self.Runnum:SetText(self.GMStartIndex - 1)

		local DialogID = CfgTable[self.GMStartIndex].DialogID
		local DialogLibID = CfgTable[self.GMStartIndex].DialogLibID

		self.DialogLib = _G.NpcDialogMgr:ReadDialogLib(DialogLibID, nil)
		if DialogLibID == self.PreDialogLibID and self.PreDialogLibIndex < #self.DialogLib[DialogLibID][1] then
			self.PreDialogLibIndex = self.PreDialogLibIndex + 1
		else
			self.PreDialogLibIndex = 1
		end

		local PreCutName, DialogContent = _G.NpcDialogMgr:PreCutDialogString(self.DialogLib[DialogLibID][1][self.PreDialogLibIndex].DialogContent)
		local Name = string.format("多语言ID:%d", DialogID)
		self.TexTitle:SetText(Name)
		self.TextContent:SetText(DialogContent)

		self.PreDialogLibID = DialogLibID
	end

	if self.GMTimer ~= nil then
		TimerMgr:CancelTimer(self.GMTimer)
		self.GMTimer = nil
	end

	self.GMTimer = TimerMgr:AddTimer(self, DialogCallBack, 0, self.IntervalTime, 0, nil)
end

function NarrativeTestPanelView:OnAnimatedTextStart()
	self.GMStartIndex = math.max(1,self.GMStartIndex)

	local CfgTable = ScenarioTextCfgTable:FindAllCfg() or {}

	self.GMEndIndex = math.min(#CfgTable,self.GMEndIndex)

	-- FLOG_INFO(string.format("koff self.GMEndIndex:%s", self.GMEndIndex))

	local DialogCallBack = function ()
		if self.GMStartIndex > self.GMEndIndex then
			TimerMgr:CancelTimer(self.GMTimer)
			self.GMTimer = nil
			return
		end
		self.Runnum:SetText(self.GMStartIndex)

		local TextID = CfgTable[self.GMStartIndex].TextID
		local MessageCfg = ScenarioTextCfgTable:FindCfgByTextKey(TextID)
		if (MessageCfg ~= nil) then
			local Name = string.format("TEXTID:%s", TextID)
			self.TexTitle:SetText(Name)
			self.TextContent:SetText(MessageCfg.Content)
		end

		self.GMStartIndex = self.GMStartIndex + 1
	end

	if self.GMTimer ~= nil then
		TimerMgr:CancelTimer(self.GMTimer)
		self.GMTimer = nil
	end

	self.GMTimer = TimerMgr:AddTimer(self, DialogCallBack, 0, self.IntervalTime, 0, nil)
end

function NarrativeTestPanelView:OnQuestStart()
	self.GMStartIndex = math.max(1,self.GMStartIndex)

	local CfgTable = QuestCfgTable:FindAllCfg() or {}

	self.GMEndIndex = math.min(#CfgTable,self.GMEndIndex)

	local DialogCallBack = function ()
		if self.GMStartIndex > self.GMEndIndex then
			TimerMgr:CancelTimer(self.GMTimer)
			self.GMTimer = nil
			return
		end

		local QuestCfg = CfgTable[self.GMStartIndex]
		if QuestCfg == nil then
			return 
		end
		self.Runnum:SetText(self.GMStartIndex)

		self.CurQuestID = QuestCfg.id
		self.CurQuestID = tonumber(self.CurQuestID)

		local GMText = string.format("role quest finishall %s", self.CurQuestID)
		GMMgr:ReqGM(GMText)

		FLOG_INFO(string.format("role quest finishall %s", self.CurQuestID))

		local function ShowQuestLogMainPanel()
			local View = UIViewMgr:ShowView(_G.UIViewID.QuestLogMainPanel, { QuestID = self.CurQuestID })
			-- local View = UIViewMgr:ShowView(_G.UIViewID.QuestLogMainPanel)
			View:UpdateQuestTypeSelection(nil)
		end

		TimerMgr:AddTimer(self, ShowQuestLogMainPanel, self.IntervalTime/2, 1, 1, nil)

		local function HideQuestLogMainPanel()
			UIViewMgr:HideView(_G.UIViewID.QuestLogMainPanel)

			local count = 0
			for _ in pairs(QuestMgr.ChapterMap) do
				count = count + 1
			end

			-- FLOG_INFO(string.format("koff #QuestMgr.ChapterMap: %s", count))

			if count > 2 then
				-- QuestMgr:ClearQuests()
				GMMgr:ReqGM("role quest clear")
			else
				GMText = string.format("role quest do")
				GMMgr:ReqGM(GMText)
			end
		end

		TimerMgr:AddTimer(self, HideQuestLogMainPanel, math.max(1,self.IntervalTime), 1, 1, nil)

		self.GMStartIndex = self.GMStartIndex + 1
	end

	if self.GMTimer ~= nil then
		TimerMgr:CancelTimer(self.GMTimer)
		self.GMTimer = nil
	end

	self.GMTimer = TimerMgr:AddTimer(self, DialogCallBack, 0, self.IntervalTime, 0, nil)
end

function NarrativeTestPanelView:OnCustomTalkStart()
	self.GMStartIndex = math.max(1,self.GMStartIndex)

	local CfgTable = CustomDialogOptionCfg:FindAllCfg() or {}

	self.GMEndIndex = math.min(#CfgTable,self.GMEndIndex)

	-- FLOG_INFO(string.format("koff self.GMEndIndex:%s", self.GMEndIndex))

	local DialogCallBack = function ()
		if self.GMStartIndex > self.GMEndIndex then
			TimerMgr:CancelTimer(self.GMTimer)
			self.GMTimer = nil
			return
		end

		self.Cfg = CfgTable[self.GMStartIndex]
		if self.Cfg == nil then
			return 
		end
		self.Runnum:SetText(self.GMStartIndex)


		local CustomTalkID = CfgTable[self.GMStartIndex].CustomTalkID
		local GMText = string.format("话题标题:%s,CustomTalkID:%s", CfgTable[self.GMStartIndex].Title,CustomTalkID)

		self.CustomTalk:SetText(GMText)
	
		local OptionFunctionList = self:GenCustomTalkOptions(CustomTalkID)
	
		local Offset = math.min(630,#OptionFunctionList * 100)
		local Position = UE.FVector2D(400, 720 - Offset)
		UIUtil.CanvasSlotSetPosition(self.CustomTalk,Position)
		-- self.CustomTalk:SetPosition(Position)
	
		-- FLOG_INFO(string.format("koff OptionFunctionList:%s", #OptionFunctionList))
		-- FLOG_INFO(string.format("koff Position.Y:%s", Position.Y))
	
		_G.InteractiveMgr:SetFunctionList(OptionFunctionList)

		self.GMStartIndex = self.GMStartIndex + 1
	end

	if self.GMTimer ~= nil then
		TimerMgr:CancelTimer(self.GMTimer)
		self.GMTimer = nil
	end

	self.GMTimer = TimerMgr:AddTimer(self, DialogCallBack, 0, self.IntervalTime, 0, nil)
end

function NarrativeTestPanelView:GenCustomTalkOptions(CustomTalkID)
	self.Cfg = CustomDialogOptionCfg:FindCfgByKey(CustomTalkID)

    if self.Cfg == nil then
        return 
    end

    local FunctionList = {}

    local Options = self.Cfg.Options
    for i = 1, #Options do
        if Options[i] ~= nil and Options[i].Title ~= "" then
            local Option = Options[i]
            local Answers = string.split(Option.AnswerID, ';')
            local AnswerContentID = 0
            local TrueCustomTalkID = 0
            for AnswerIdx = 1, #Answers do
                local AnswerCfg = CustomDialogAnswerCfg:FindCfgByKey(Answers[AnswerIdx])
                if AnswerCfg ~= nil and AnswerCfg.ContentID ~= 0 then
                    AnswerContentID = tonumber(AnswerCfg.ContentID)
                    break
                elseif AnswerCfg ~= nil then
                    if AnswerCfg.FuncID ~= 0 then
                        AnswerContentID = tonumber(AnswerCfg.AnswerID)
                        break
                    elseif AnswerCfg.CustomTalkID ~= 0 then
                        AnswerContentID = tonumber(AnswerCfg.AnswerID)
                        TrueCustomTalkID = AnswerCfg.CustomTalkID
                    end
                end
            end
            if AnswerContentID > 0 then
                --嵌套CustomTalk且无ContentID在这里处理一下
                local IFuncUnit = FunctionCustomTalk.New()
                IFuncUnit:Init(Option.Title,
                {FuncValue = AnswerContentID, EntityID = 0, ResID = 0,
                IsCustomTalk = TrueCustomTalkID ~= 0, TrueCustomTalkID = TrueCustomTalkID, NeedInsertHistory = true})
                local IconPath = Option.IconPath or ""
                if _G.JumboCactpotMgr:IsJumboAnswer(Answers) and tonumber(Answers[1]) == AnswerContentIDList.Buy then
                    IFuncUnit:SetIconPath(_G.JumboCactpotMgr:GetDialogJumboIconPath())
                end
                if IconPath and IconPath ~= "" then
                    IFuncUnit:SetIconPath(IconPath)
                end
                if IFuncUnit then
                    table.insert(FunctionList, IFuncUnit)
                end
            elseif AnswerContentID == 0 and _G.JumboCactpotMgr:IsJumboAnswer(Answers) then
            else
                local IFuncUnit = FunctionNpcQuit.New()
                IFuncUnit:Init(Option.Title,
                {FuncValue = AnswerContentID, EntityID = 0, ResID = 0})

                if IFuncUnit then
                    table.insert(FunctionList, IFuncUnit)
                end
            end
        end
    end

    if #FunctionList == 1 and FunctionList[1].FuncType == LuaFuncType.NPCQUIT_FUNC then
        FunctionList = {}
    end

    return FunctionList
end

function NarrativeTestPanelView:OnDialogueBranchStart(DialogLibID)
	self.GMStartIndex = math.max(1,self.GMStartIndex)

	local CfgTable = DialogueBranchCfg:FindAllCfg() or {}

	self.GMEndIndex = math.min(#CfgTable,self.GMEndIndex)

	-- FLOG_INFO(string.format("koff OnDialogueBranchStart self.GMEndIndex:%s", self.GMEndIndex))

	local DialogCallBack = function ()
		if self.GMStartIndex > self.GMEndIndex then
			TimerMgr:CancelTimer(self.GMTimer)
			self.GMTimer = nil
			return
		end

		self.BranchCfg = CfgTable[self.GMStartIndex]
		if self.BranchCfg == nil then
			return 
		end
		self.Runnum:SetText(self.GMStartIndex)

		local ID = CfgTable[self.GMStartIndex].ID
		local DialogID = CfgTable[self.GMStartIndex].DialogID
		local GMText = string.format("ID:%s", ID)

		self.CustomTalk:SetText(GMText)
	
		local TempUnitList = _G.NpcDialogMgr:GetBranchListItem(self.BranchCfg)
	
		local Offset = math.min(630,#TempUnitList * 100)
		local Position = UE.FVector2D(500, 700 - Offset)
		UIUtil.CanvasSlotSetPosition(self.CustomTalk,Position)
	
		-- FLOG_INFO(string.format("koff ID:%s,DialogID:%s", ID,DialogID))


		UIViewMgr:ShowView(_G.UIViewID.NpcDialogueMainPanel,{ViewType = StoryDefine.UIType.NpcDialog})
		NpcDialogMgr:NarrativeTest(DialogID)



		self.GMStartIndex = self.GMStartIndex + 1
	end

	if self.GMTimer ~= nil then
		TimerMgr:CancelTimer(self.GMTimer)
		self.GMTimer = nil
	end

	self.GMTimer = TimerMgr:AddTimer(self, DialogCallBack, 0, self.IntervalTime, 0, nil)
end

return NarrativeTestPanelView