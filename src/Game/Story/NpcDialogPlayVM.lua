--[[
Author: luojiewen_ds luojiewen@dasheng.tv
Date: 2024-04-15 15:24:53
LastEditors: luojiewen_ds luojiewen@dasheng.tv
LastEditTime: 2024-04-21 16:10:42
FilePath: \Script\Game\Story\NpcDialogPlayVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MajorUtil = require("Utils/MajorUtil")
local TimeUtil = require("Utils/TimeUtil")
local UIUtil = require("Utils/UIUtil")
local DialogueUtil = require("Utils/DialogueUtil")
local SaveKey = require("Define/SaveKey")
local CommonUtil = require("Utils/CommonUtil")
local StoryDefine = require("Game/Story/StoryDefine")
local ClientGlobalCfg = require("TableCfg/ClientGlobalCfg")
local ProtoRes = require("Protocol/ProtoRes")
local QuestDefine = require("Game/Quest/QuestDefine")

local USaveMgr = _G.UE.USaveMgr

---@class NpcDialogPlayVM : UIViewModel
local NpcDialogPlayVM = LuaClass(UIViewModel)

---Ctor
function NpcDialogPlayVM:Ctor()
	FLOG_INFO("NpcDialogPlayVM:Ctor()  1111")
	self.SpeedLevel = 1
end

function NpcDialogPlayVM:OnBegin()
	self:ResetVM()
end

function NpcDialogPlayVM:ResetVM()
	--对话标题*姓名
    self.SpeakerName = ""
    --对话内容
    self.TalkContent = ""
    --NpcTag
    --self.SpeakerTag = ""
	self.bIsDialogPlaying = false
	self.bIsDialogVisible = false
	self.DialogPlayIndex = 1
	self.bSpeedUp = false
	self.PanelViewVisible = false
	--自动播放
	self.bIsAutoPlay = false
	self.bShowSpeed = false
	self.RichTextLen = 0
	self.bTopButtonGroupVisible = false
	self.bPanelReviewVisible = true
	self.bPanelPlayVisible = true
	self.bHorizontalRightVisible = false
	self.bBackBtnVisible = false
	self.bClickVisible = false
	self.bTalkPanelVisible = false
	--对白相关
	self.IsDialogBranchIsPlay = false
	self.DialogBranchList = {}
	self.bChoicePanelVisible = false
	self.ChoiceMessage = ""

	self.DialogueStartTime = 0
	self.TouchWaitTime = StoryDefine.TouchWaitTimeMS
	self.AutoWaitTime = StoryDefine.AutoWaitTime
	local Cfg = ClientGlobalCfg:FindCfgByKey(ProtoRes.client_global_cfg_id.GLOBAL_CFG_TOUCH_WAIT_TIME)
	if (Cfg ~= nil) then
		self.TouchWaitTime = Cfg.Value[1]
	end

	self.IsArrowHide = false
	self.PreResumeParam = false

	self.DialogTexturePath = ""
	self.IsTextureShow = false
	
	if self.DialogPlayingStateTimer then
		_G.TimerMgr:CancelTimer(self.DialogPlayingStateTimer)
	end
end

function NpcDialogPlayVM:ShowDialog(Name, Post, Content, TexturePath)
    local DialogueUtil = require("Utils/DialogueUtil")
	local EffectUtil = require("Utils/EffectUtil")
	self.IsArrowHide = false
    --这里判断一下对话内容
    self.SpeakerName = Name
    self.SpeakerTag = Post
    self.TalkContent = ""
    local ConvertedContent = DialogueUtil.ParseLabel(Content)
	ConvertedContent = CommonUtil.GetTextFromStringWithSpecialCharacter(ConvertedContent)
    self.RichTextSplitter = _G.UE.FRichTextSplitter.Create(ConvertedContent)
    self.DialogPlayIndex = 1
	self.bIsDialogPlaying = true
	self.bSpeedUp = false    
	self.bIsDialogVisible = true
	self.MajorIsSing = false
	self.RichTextLen = self.RichTextSplitter:RichTextLen()
	local IsAutoPlayValue = USaveMgr.GetInt(SaveKey.IsAutoPlay, 1, true)
	if _G.LevelRecordMgr ~= nil and _G.LevelRecordMgr:InRecordState() then
		IsAutoPlayValue = 0
	end
	self.DialogTexturePath = TexturePath
	self.IsTextureShow = self.DialogTexturePath ~= "" and true or false
	self:SetAutoPlay(IsAutoPlayValue == 1)
	self:TimeFuncCallBack()
end

function NpcDialogPlayVM:SetTouchWaitTime(TouchWaitTime, AutoWaitTime)
	self.TouchWaitTime = TouchWaitTime
	self.AutoWaitTime = AutoWaitTime
end

--计时器CallBack挪到VM中
function NpcDialogPlayVM:TimeFuncCallBack()
    local TempText = self.RichTextSplitter:RichTextSub(self.RichTextSplitter:RichTextLen())
	self.bIsDialogPlaying = true
	self:AddAutoPlayTimer()
	if self.bIsSubtitle then
		self.SpeakerName = TempText
	else
        self.TalkContent = TempText
	end

	self.DialogPlayIndex = self.RichTextSplitter:RichTextLen() + 1

	if TempText ~= "" then
		self.PanelViewVisible = true
	else
		self.PanelViewVisible = false
	end
	self.DialogPlayingStateTimer = _G.TimerMgr:AddTimer(nil, function()
		self.bIsDialogPlaying = false
	end, self.RichTextLen * 0.01 / 2)
end

function NpcDialogPlayVM:AddAutoPlayTimer()
	if self.bIsAutoPlay then
		local MyView = _G.UIViewMgr:FindView(_G.UIViewID.NpcDialogueMainPanel)
		
		if MyView then
			local Time = self.TouchWaitTime / 1000
			local AutoPlayTime = DialogueUtil.GetAutoPlayTime(self.RichTextLen, self.SpeedLevel)
			local WaitTime = math.max(AutoPlayTime, Time)
			MyView:AddAutoPlayTimer(WaitTime)
		end
	end
end
-- --------------------------------------------------
-- View接口
-- --------------------------------------------------

function NpcDialogPlayVM:OnClickScreen()
	self:OnClickNextDialogContent()
end

function NpcDialogPlayVM:OnClickButtonSwitchAuto()
	self:SetAutoPlay(not self.bIsAutoPlay)
	self:AddAutoPlayTimer()
end
  
function NpcDialogPlayVM:OnClickButtonChangeSpeed()
	self.SpeedLevel = (self.SpeedLevel % 3) + 1
	USaveMgr.SetInt(SaveKey.AutoPlaySpeedLevel, self.SpeedLevel, true)
	--现在没有打字机效果，切换速度要重新加一个计时器
	self:AddAutoPlayTimer()
end

function NpcDialogPlayVM:OnClickNextDialogContent()	
	local CurTime = TimeUtil.GetLocalTimeMS()
	if CurTime - self.DialogueStartTime <= self.TouchWaitTime then
		return
	end
	if self.IsDialogBranchIsPlay then
		if _G.NpcDialogMgr:IsDialogPlaying() then
			_G.NpcDialogMgr:SpeedUpDialog()
		end
	else
		_G.EventMgr:SendEvent(_G.EventID.ClickNextDialog)
	end
end

function NpcDialogPlayVM:OnClickNextDialogContentAuto()
	local CurTime = TimeUtil.GetLocalTimeMS()
	if CurTime - self.DialogueStartTime <= self.TouchWaitTime then
		local MyView = _G.UIViewMgr:FindView(_G.UIViewID.NpcDialogueMainPanel)
		if MyView then
			local WaitTime = (self.TouchWaitTime - (CurTime - self.DialogueStartTime)) / 1000
			MyView:AddAutoPlayTimer(WaitTime)
		end
		return
	end
	if self.IsDialogBranchIsPlay then
		if _G.NpcDialogMgr:IsDialogPlaying() then
			_G.NpcDialogMgr:SpeedUpDialog()
		end
	else
		_G.EventMgr:SendEvent(_G.EventID.ClickNextDialog)
	end
end

function NpcDialogPlayVM:OnClickButtonJumpOver()
end

function NpcDialogPlayVM:SetAutoPlay(bAutoPlay)
	self.bIsAutoPlay = bAutoPlay
	self.bShowSpeed = bAutoPlay
	USaveMgr.SetInt(SaveKey.IsAutoPlay, bAutoPlay and 1 or 0, true)

	local SpeedLevelValue = USaveMgr.GetInt(SaveKey.AutoPlaySpeedLevel, 1, true)
	self.SpeedLevel = SpeedLevelValue
end

function NpcDialogPlayVM:SetSelfVisible(Visible)
	self.bTopButtonGroupVisible = Visible
	self.bTalkPanelVisible = Visible
	self.bClickVisible = Visible
end

function NpcDialogPlayVM:SetArrowHide(IsHide)
	self.IsArrowHide = IsHide
end

--隐藏或者显示自动速率
function NpcDialogPlayVM:SetContorllerButtonVisible(Visible)
	if self.bIsAutoPlay then
		self.bPanelPlayVisible = Visible
		self.bShowSpeed = Visible
	else
		self.bPanelPlayVisible = Visible
		self.bShowSpeed = false
	end	
end
--------------------------------------对白相关-------------------------------------
---对白开始或结束
function NpcDialogPlayVM:DialogBranchStartOrEnd(IsPlay)
	self.IsDialogBranchIsPlay = IsPlay
end

--保存当前对白信息
function NpcDialogPlayVM:SaveBranchCfg(Cfg)
	self.BranchCfg = Cfg
	self:DialogBranchStartOrEnd(true)
end

--设置选项
function NpcDialogPlayVM:SetSelfBranchList()
	--循环依赖了，函数挪到Mgr
	local TempUnitList = _G.NpcDialogMgr:GetBranchListItem(self.BranchCfg)
	self.DialogBranchList = TempUnitList
	self.ChoiceMessage = self.BranchCfg.DialogQuestion or ""
end

--设置对话显示
function NpcDialogPlayVM:SetDialogBranchVisible(Visible)
	self.bChoicePanelVisible = Visible
	self.IsArrowHide = Visible
	local MyView = _G.UIViewMgr:FindView(_G.UIViewID.NpcDialogueMainPanel)
	if MyView then
		UIUtil.SetIsVisible(MyView.TopButtonGroup, not Visible)
	end
end

--分支选择
function NpcDialogPlayVM:ChooseMenuChoice(Index)
	local QuestHelper = require("Game/Quest/QuestHelper")
	local ActorUtil = require("Utils/ActorUtil")
	--记录对白分支数据
	if self.BranchCfg and self.BranchCfg.ID ~= 0 then
		_G.QuestMgr:SetDialogBranchInfo(Index, self.BranchCfg.ID)
	end
	self.DialogBranchList = {}
	self.ChoiceMessage = ""
	self:DialogBranchStartOrEnd(false)
	self:SetDialogBranchVisible(false)
	local DialoglibID = 0
	if self.BranchCfg and self.BranchCfg.ChoiceList and self.BranchCfg.ChoiceList[Index] then
		DialoglibID = self.BranchCfg.ChoiceList[Index].DialogID or 0 
	end
	local function PlayDialogFunc()
        _G.NpcDialogMgr:PlayDialogLib(DialoglibID, nil)
    end

    local function PlaySeqFunc()
		local FadeViewID = _G.UIViewID.CommonFadePanel
		local Params = {}
		Params.FadeColorType = 3
		Params.Duration = 1
		Params.bAutoHide = false
		_G.UIViewMgr:ShowView(FadeViewID, Params)
		--进seq之前先兜底处理一次镜头
		_G.NpcDialogMgr:PreEndInteraction()
        QuestHelper.QuestPlaySequence(self.BranchCfg.ChoiceList[Index].DialogID, function(_)
			_G.NpcDialogMgr:CheckNeedEndInteraction()
			local QuestParam = _G.NpcDialogMgr.QuestDialogParams
			if QuestParam ~= nil then
				QuestMgr:OnQuestInteractionFinished(QuestParam)
				QuestParam = nil
			end
        end)
    end
	local MyView = _G.UIViewMgr:FindView(_G.UIViewID.NpcDialogueMainPanel)
	if DialoglibID == 0 then
		local MyView = _G.UIViewMgr:FindView(_G.UIViewID.NpcDialogueMainPanel)
		if MyView then
			UIUtil.SetIsVisible(MyView.Dialogue, false)
			UIUtil.SetIsVisible(MyView.BtnClick, false, true) 
			UIUtil.SetIsVisible(MyView.TopButtonGroup, false)
		end
		_G.QuestMgr:OnQuestInteractionFinished(_G.NpcDialogMgr.QuestDialogParams)
		_G.NpcDialogMgr:EndInteraction()
		return
	end
	local DType = QuestDefine.GetDialogueType(DialoglibID)
	if DType ~= QuestDefine.DialogueType.NpcDialog then
		UIUtil.SetIsVisible(MyView.Dialogue, false)
		UIUtil.SetIsVisible(MyView.BtnClick, false, true) 
		UIUtil.SetIsVisible(MyView.TopButtonGroup, false)
	end
	QuestHelper.PlayDialogOrSequence(DialoglibID, PlayDialogFunc, PlaySeqFunc)
end

function NpcDialogPlayVM:PauseAutoPlay()
	if self.bIsAutoPlay then
		self.PreResumeParam = true
	end
	self.bIsAutoPlay = false
end

function NpcDialogPlayVM:ResumeAutoPlay()
	if self.PreResumeParam then
		self.bIsAutoPlay = true
		self:AddAutoPlayTimer()
	end
	self.PreResumeParam = false
end

return NpcDialogPlayVM