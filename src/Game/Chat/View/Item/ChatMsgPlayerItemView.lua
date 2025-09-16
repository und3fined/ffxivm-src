---
--- Author: anypkvcai
--- DateTime: 2021-11-10 10:03
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ChatUtil = require("Game/Chat/ChatUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ChatDefine = require("Game/Chat/ChatDefine")
local ChatVM = require("Game/Chat/ChatVM")
local ChatSetting = require("Game/Chat/ChatSetting")
local VoiceMgr = require("Game/Voice/VoiceMgr")
local ArmyMgr = require("Game/Army/ArmyMgr")
local EventID = require("Define/EventID")
local GroupMemberCategoryCfg = require("TableCfg/GroupMemberCategoryCfg")
local PersonInfoDefine = require("Game/PersonInfo/PersonInfoDefine")
local ChatGifCfg = require("TableCfg/ChatGifCfg")
local CommonUtil = require("Utils/CommonUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
  
-- 由在线状态引入
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local OnlineStatusUtil = require("Game/OnlineStatus/OnlineStatusUtil")
---

local LSTR = _G.LSTR
local FVector2D = _G.UE.FVector2D
local ChatChannel = ChatDefine.ChatChannel
local ChatMsgType = ChatDefine.ChatMsgType
local SimpleViewSource = PersonInfoDefine.SimpleViewSource

---@class ChatMsgPlayerItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnTranslateVoice UFButton
---@field ButtonGifBg UFButton
---@field ButtonMsg UFButton
---@field ButtonVoice UFButton
---@field ButtonVoiceBg UFButton
---@field ChatPanel UFCanvasPanel
---@field FImgGif UFImage
---@field GifNode USizeBox
---@field ImageRank UFImage
---@field ImageStatus UFImage
---@field ImageTag UFImage
---@field MsgNode UFHorizontalBox
---@field MsgTips UFCanvasPanel
---@field PanelChannel UFCanvasPanel
---@field PanelTime UFCanvasPanel
---@field PlayerHeadSlot CommPlayerHeadSlotView
---@field RichTextMsg URichTextBox
---@field RichTextMsgTips URichTextBox
---@field RichTextName URichTextBox
---@field RichTextRank URichTextBox
---@field RichTextSeconds URichTextBox
---@field RichTextTime URichTextBox
---@field RichTextTranslate URichTextBox
---@field SizeBoxRank USizeBox
---@field SizeBoxServer USizeBox
---@field SizeBoxStatus USizeBox
---@field TaskShareItem ChatMsgTaskShareItemView
---@field TeamRecruitItem ChatMsgTeamRecruitItemView
---@field TextChannel UFTextBlock
---@field VoiceNode USizeBox
---@field AnimSpeakLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChatMsgPlayerItemView = LuaClass(UIView, true)

function ChatMsgPlayerItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnTranslateVoice = nil
	--self.ButtonGifBg = nil
	--self.ButtonMsg = nil
	--self.ButtonVoice = nil
	--self.ButtonVoiceBg = nil
	--self.ChatPanel = nil
	--self.FImgGif = nil
	--self.GifNode = nil
	--self.ImageRank = nil
	--self.ImageStatus = nil
	--self.ImageTag = nil
	--self.MsgNode = nil
	--self.MsgTips = nil
	--self.PanelChannel = nil
	--self.PanelTime = nil
	--self.PlayerHeadSlot = nil
	--self.RichTextMsg = nil
	--self.RichTextMsgTips = nil
	--self.RichTextName = nil
	--self.RichTextRank = nil
	--self.RichTextSeconds = nil
	--self.RichTextTime = nil
	--self.RichTextTranslate = nil
	--self.SizeBoxRank = nil
	--self.SizeBoxServer = nil
	--self.SizeBoxStatus = nil
	--self.TaskShareItem = nil
	--self.TeamRecruitItem = nil
	--self.TextChannel = nil
	--self.VoiceNode = nil
	--self.AnimSpeakLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChatMsgPlayerItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PlayerHeadSlot)
	self:AddSubView(self.TaskShareItem)
	self:AddSubView(self.TeamRecruitItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChatMsgPlayerItemView:OnInit()
	self.BindersParamVM = {
		{ "TimeText", UIBinderSetText.New(self, self.RichTextTime) },
		{ "TimeVisible", UIBinderSetIsVisible.New(self, self.PanelTime) },

		{ "Content", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedContent) },
		{ "Extend",  UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedExtend) },
		{ "MsgType", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedMsgType) },
	}

	self.BindersChatVM = {
		{ "CurChannel", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedCurChannel) }
	}

	self.BindersRoleVM = {
		{ "Name", 		UIBinderSetText.New(self, self.RichTextName) },
		{ "HeadInfo", 	UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedHeadInfo) },
		{ "HeadFrameID", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedHeadFrameID) },
	}
end

function ChatMsgPlayerItemView:OnDestroy()
	rawset(self, "IsViewDestoryed", true)
	if ChatVM.CurClickedMsgItem == self then
		ChatVM:SetCurClickedMsgItem(nil)
	end
end

function ChatMsgPlayerItemView:OnShow()
	rawset(self, "IsViewDestoryed", false)
end

function ChatMsgPlayerItemView:OnHide()
	self:StopAllAnimations()
end

function ChatMsgPlayerItemView:OnRegisterUIEvent()
	UIUtil.AddOnHyperlinkClickedEvent(self, self.RichTextMsg, self.OnHyperlinkClicked)

	UIUtil.AddOnClickedEvent(self, self.ButtonMsg, 			self.OnClickedButtonMsg)
	UIUtil.AddOnClickedEvent(self, self.ButtonVoiceBg, 		self.OnClickedButtonVoiceBg)
	UIUtil.AddOnClickedEvent(self, self.ButtonGifBg, 		self.OnClickedButtonGifBg)
	UIUtil.AddOnClickedEvent(self, self.ButtonVoice, 		self.OnClickedButtonVoice)
	UIUtil.AddOnClickedEvent(self, self.BtnTranslateVoice, 	self.OnClickedBtnTranslateVoice)
end

function ChatMsgPlayerItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.ChatUpdateColor, self.OnEventUpdateColor)
	self:RegisterGameEvent(EventID.GVoiceRecordPlayStart, self.OnEventPlayRecordStart) 	-- 开始播放录音
	self:RegisterGameEvent(EventID.GVoiceRecordPlayDone, self.OnEventPlayRecordDone) 	-- 录音播放完成
	self:RegisterGameEvent(EventID.GVoiceSpeechFileToTextComplete, self.OnGameEventVoiceFileTranslateComplete) -- 语音转文字完成
end

function ChatMsgPlayerItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params or nil == Params.Data then
		return
	end

	local ViewModel = Params.Data
	self.ViewModel = ViewModel
	self.Channel = ViewModel:GetChannel()
	self.ChannelID = ViewModel:GetChannelID()

	self:RegisterBinders(ViewModel, self.BindersParamVM)
	self:RegisterBinders(ChatVM, self.BindersChatVM)

	local RoleID = Params.Data.Sender
	self.RoleID = RoleID

	if RoleID then
		self.PlayerHeadSlot:SetBaseInfo(RoleID, SimpleViewSource.Chat)
	end

	local RoleVM = _G.RoleInfoMgr:FindRoleVM(RoleID)
	if RoleVM then
		self:RegisterBinders(RoleVM, self.BindersRoleVM)
	end
end

function ChatMsgPlayerItemView:OnValueChangedContent( Content )
	local RTMsg = self.RichTextMsg
	local RTTranslate = self.RichTextTranslate
	local IsEmptyContent = string.isnilorempty(Content)
	if IsEmptyContent then
		UIUtil.SetIsVisible(RTMsg, false)
		UIUtil.SetIsVisible(RTTranslate, false)

	else
		RTMsg:SetText(Content)
		RTTranslate:SetText(Content)

		UIUtil.SetIsVisible(RTMsg, true)
		UIUtil.SetIsVisible(RTTranslate, true)
	end

	-- local ViewModel = self.ViewModel
	-- if nil == ViewModel then
	-- 	return
	-- end

	-- local MsgType = ViewModel:GetMsgType()
	-- if MsgType == ChatMsgType.Voice then
	-- 	UIUtil.SetIsVisible(self.BtnTranslateVoice, true, IsEmptyContent)
	-- end
end

function ChatMsgPlayerItemView:OnValueChangedExtend( Extend )
	local ExtendData = ChatUtil.ParseMsgExtendData(Extend) or {}

	--设置公会信息
	self:SetArmyInfo(ExtendData.ArmyRankID)

	--设置状态信息
	self:SetStatusInfo(ExtendData.Status)

	-- 异服标识
	self:SetDiffServerInfo(ExtendData.CurWorldID)
end

--- 设置公会信息
function ChatMsgPlayerItemView:SetArmyInfo(CategoryID)
	UIUtil.SetIsVisible(self.RichTextRank, false)
	UIUtil.SetIsVisible(self.SizeBoxRank, false)

	if nil == CategoryID or ChatVM.CurChannel ~= ChatChannel.Army then
		return
	end

	local Info = ArmyMgr:GetCategoryDataByID(CategoryID)
	if nil == Info then
		return
	end

	local Name = Info.Name
	if not string.isnilorempty(Name) then
		self.RichTextRank:SetText(Name)
		UIUtil.SetIsVisible(self.RichTextRank, true)
	end

	local Icon = GroupMemberCategoryCfg:GetCategoryIconByID(Info.IconID)
	if not string.isnilorempty(Icon) then
		UIUtil.ImageSetBrushFromAssetPath(self.ImageRank, Icon)
		UIUtil.SetIsVisible(self.SizeBoxRank, true)
	end
end

---更新状态图标
function ChatMsgPlayerItemView:SetStatusInfo(Status)
	if nil == Status or #Status < 3 then
		UIUtil.SetIsVisible(self.SizeBoxStatus, false)
		return
	end

	local Channel = self.Channel
	if Channel == ChatChannel.Person then
		UIUtil.SetIsVisible(self.SizeBoxStatus, false)
		return
	end

	local Icon = ChatUtil.GetStatusIcon(Channel, Status[1], Status[2], Status[3])
	if Icon then
		UIUtil.SetIsVisible(self.SizeBoxStatus, true)
		UIUtil.ImageSetBrushFromAssetPath(self.ImageStatus, Icon)

	else
		UIUtil.SetIsVisible(self.SizeBoxStatus, false)
	end
end

--- 异服标识(和Major相比)
function ChatMsgPlayerItemView:SetDiffServerInfo(CurWorldID)
	if nil == CurWorldID or CurWorldID <= 0 then
		UIUtil.SetIsVisible(self.SizeBoxServer, false)
		return
	end

	if self.Channel == ChatChannel.Person then
		UIUtil.SetIsVisible(self.SizeBoxServer, false)
		return
	end

	local ViewModel = self.ViewModel
	if nil == ViewModel or ViewModel.IsMajor then
		UIUtil.SetIsVisible(self.SizeBoxServer, false)
		return
	end

	UIUtil.SetIsVisible(self.SizeBoxServer, CurWorldID ~= _G.PWorldMgr:GetCurrWorldID())
end

function ChatMsgPlayerItemView:OnValueChangedMsgType( MsgType )
	local ViewModel = self.ViewModel
	if nil == ViewModel then
		return
	end

	local IsMsg 		= nil 
	local IsTaskShare	= nil
	local IsVoice 		= nil
	local IsGif 		= nil
	local IsTeamRecruit = nil

	if MsgType == ChatMsgType.Msg then -- 普通消息 
		IsMsg = true

	elseif MsgType == ChatMsgType.TaskShare then -- 任务分享 
		IsTaskShare = true

		self.TaskShareItem:RefreshUI(ViewModel.TaskMsg, ViewModel.IsMajor)

	elseif MsgType == ChatMsgType.Voice then -- 语音 
		IsVoice = true
		self.VoiceID = ViewModel.VoiceID 
		self.VoiceLanguage = ViewModel.VoiceLanguage

		local VoiceLength = ViewModel.VoiceLength

		--语音背景宽度调整
		local Size = UIUtil.CanvasSlotGetSize(self.ButtonVoice)
		if Size ~= nil then
			local Width = ChatUtil.GetVoiceMsgBgWidth(VoiceLength)
			UIUtil.CanvasSlotSetSize(self.ButtonVoice, FVector2D(Width, Size.Y))
		end

		--秒
		self.RichTextSeconds:SetText(string.format("%s\"", VoiceLength))

	elseif MsgType == ChatMsgType.Gif then -- Gif表情
		IsGif = true

		local Icon = ChatGifCfg:GetIcon(ViewModel.GifID)
		if not string.isnilorempty(Icon) then
			UIUtil.ImageSetBrushFromAssetPath(self.FImgGif, Icon)
		end

	elseif MsgType == ChatMsgType.TeamRecruit then -- 队伍招募
		IsTeamRecruit = true

		self.TeamRecruitItem:RefreshUI(ViewModel.TeamRecruitMsg, ViewModel.IsMajor)

	elseif MsgType == ChatMsgType.Location then -- 位置分享 
		IsMsg = true
	end

	UIUtil.SetIsVisible(self.MsgNode, 			IsMsg)
	UIUtil.SetIsVisible(self.TaskShareItem, 	IsTaskShare)
	UIUtil.SetIsVisible(self.VoiceNode, 		IsVoice)
	UIUtil.SetIsVisible(self.GifNode, 			IsGif)
	UIUtil.SetIsVisible(self.TeamRecruitItem, 	IsTeamRecruit)
end

function ChatMsgPlayerItemView:UpdateColor()
	local Color = ChatSetting.GetChannelColor(self.Channel, self.ChannelID)
	UIUtil.ImageSetColorAndOpacityHex(self.ImageTag, Color)
end

function ChatMsgPlayerItemView:OnValueChangedCurChannel()
	if ChatVM.CurChannel == ChatChannel.Comprehensive then
		local Name = ChatVM:GetChannelRealName(self.Channel, self.ChannelID) 
		if string.isnilorempty(Name) then
			UIUtil.SetIsVisible(self.PanelChannel, false)
		else
			self.TextChannel:SetText(Name or "")
			UIUtil.SetIsVisible(self.PanelChannel, true)
			
			self:UpdateColor()
		end
	else
		UIUtil.SetIsVisible(self.PanelChannel, false)
	end
end

function ChatMsgPlayerItemView:OnValueChangedHeadInfo(NewValue)
	if NewValue then
		self.PlayerHeadSlot:UpdateIcon()
	end
end

function ChatMsgPlayerItemView:OnValueChangedHeadFrameID(NewValue)
	self.PlayerHeadSlot:UpdateFrame()
end

function ChatMsgPlayerItemView:GetClickNode()
	local MsgType = nil

	if self.ViewModel then
		MsgType = self.ViewModel.MsgType
	end

	if MsgType == ChatMsgType.Voice then 
		return self.VoiceNode

	elseif MsgType == ChatMsgType.Gif then 
		return self.GifNode

	else
		return self.MsgNode
	end
end

function ChatMsgPlayerItemView:GetNodeViewportPosition()
	local Node = self:GetClickNode() 
	local SrcLocalPos = UIUtil.CanvasSlotGetPosition(Node)
	local Pos = UIUtil.LocalToViewport(self.ChatPanel, SrcLocalPos)
	return Pos
end

function ChatMsgPlayerItemView:GetNodeSize()
	local Node = self:GetClickNode() 
	return UIUtil.GetLocalSize(Node)
end

-------------------------------------------------------------------------------------------------------
---Client Event CallBack 

function ChatMsgPlayerItemView:OnEventUpdateColor()
	self:UpdateColor()
end

--- 开始播放录音
---@param Params FEventParams @参数，Params.StringParam1, file ID
function ChatMsgPlayerItemView:OnEventPlayRecordStart( Params )
	local VoiceID = self.VoiceID
	if nil == VoiceID or nil == Params or VoiceID ~= Params.StringParam1 then
		return
	end

	--播放动效
	self:PlayAnimation(self.AnimSpeakLoop, 0, 0)
end

--- 录音播放完成
---@param Params FEventParams @参数，Params.StringParam1, file ID
function ChatMsgPlayerItemView:OnEventPlayRecordDone( Params )
	local VoiceID = self.VoiceID
	if nil == VoiceID or nil == Params or VoiceID ~= Params.StringParam1 then
		return
	end

	--停止动效
	self:StopAnimation(self.AnimSpeakLoop)
end

---@param Params FEventParams
---Params.StringParam1, voice file ID 
---Params.StringParam2, the translation result 
function ChatMsgPlayerItemView:OnGameEventVoiceFileTranslateComplete( Params )
	if nil == Params then
		return
	end

	local ViewModel = self.ViewModel
	if nil == ViewModel then
		return
	end

	if ViewModel:GetChannel() ~= ChatChannel.Person then
		return
	end

	local VoiceID = ViewModel.VoiceID
	if string.isnilorempty(VoiceID) then
		return
	end

	local FileID = Params.StringParam1
	if VoiceID ~= FileID then
		return
	end

	local TranslateText = CommonUtil.RemoveSpecialChars(Params.StringParam2)
	if string.isnilorempty(TranslateText) then
		MsgTipsUtil.ShowTips(LSTR(50041)) -- "未识别到有效信息"

		_G.FLOG_WARNING("OnGameEventVoiceFileTranslateComplete: translate text is nil or empty.")
		return
	end

	if string.isnilorempty(FileID) then
		MsgTipsUtil.ShowTips(LSTR(50041)) -- "未识别到有效信息"

		_G.FLOG_WARNING("OnGameEventVoiceFileTranslateComplete: voice file ID is nil or empty.")
		return
	end

	ViewModel:SetVoiceTranslateText(TranslateText)
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function ChatMsgPlayerItemView:OnHyperlinkClicked(_, LinkID)
	ChatVM:HrefClicked(self.ViewModel, tonumber(LinkID))
end

function ChatMsgPlayerItemView:OnClickedButtonMsg()
	self:UpdateClicked()
end

function ChatMsgPlayerItemView:OnClickedButtonVoiceBg()
	self:UpdateClicked()
end

function ChatMsgPlayerItemView:OnClickedButtonGifBg()
	self:UpdateClicked()
end

function ChatMsgPlayerItemView:OnClickedButtonVoice()
	if string.isnilorempty(self.VoiceID) then
		return
	end

	VoiceMgr:PlayVoice(self.VoiceID, self.Channel == ChatChannel.Person)
end

function ChatMsgPlayerItemView:OnClickedBtnTranslateVoice()
	if string.isnilorempty(self.VoiceID) then
		return
	end

	VoiceMgr:TranslateVoiceToText(self.VoiceID, self.VoiceLanguage, self.Channel == ChatChannel.Person)
end

function ChatMsgPlayerItemView:UpdateClicked()
	if rawget(self, "IsViewDestoryed") then
		return
	end

	ChatVM:SetCurClickedMsgItem(self)
end

return ChatMsgPlayerItemView