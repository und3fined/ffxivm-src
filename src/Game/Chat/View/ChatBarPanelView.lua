---
--- Author: anypkvcai
--- DateTime: 2021-11-10 09:54
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local ChatVM = require("Game/Chat/ChatVM")
local ProtoCS = require("Protocol/ProtoCS")
local MajorUtil = require("Utils/MajorUtil")
local ChatMgr = require("Game/Chat/ChatMgr")
local VoiceMgr = require("Game/Voice/VoiceMgr")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local ChatDefine = require("Game/Chat/ChatDefine")
local CommonUtil = require("Utils/CommonUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIBinderSetActiveWidgetIndex = require("Binder/UIBinderSetActiveWidgetIndex")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local VoiceDefine = require("Game/Voice/VoiceDefine")
local UIViewID = require("Define/UIViewID")
local ItemUtil = require("Utils/ItemUtil")
local ChatUtil = require("Game/Chat/ChatUtil")
local TeamVoiceMgr = require("Game/Team/TeamVoiceMgr")

local LSTR = _G.LSTR
local FLOG_INFO = _G.FLOG_INFO
local FLOG_ERROR = _G.FLOG_ERROR
local FLOG_WARNING = _G.FLOG_WARNING
local PARAM_TYPE_DEFINE = ProtoCS.PARAM_TYPE_DEFINE

local ChatMacros = ChatDefine.ChatMacros
local HyperlinkLocationFlag = ChatDefine.HyperlinkLocationFlag 
local BarWidgetIndex = ChatDefine.BarWidgetIndex
local ChatChannel = ChatDefine.ChatChannel

local MaxRecordTime = VoiceDefine.MaxRecordTime
local GCloudVoiceCompleteCode = VoiceDefine.GCloudVoiceCompleteCode

---@class ChatBarPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClosePanelRecordText UFButton
---@field BtnConvertToText UFButton
---@field BtnConvertToVoice UFButton
---@field BtnEmoj UFButton
---@field BtnHideRecordTextPanel UFButton
---@field BtnKeyboard UFButton
---@field BtnKeyboardInput UFButton
---@field BtnRecord UFButton
---@field BtnRecordCancel UFButton
---@field BtnRecordSend UFButton
---@field BtnRecordSure UFButton
---@field BtnRecordToText UFButton
---@field BtnSend UFButton
---@field BtnVoice UFButton
---@field ComRedDotEmoj CommonRedDotView
---@field ContentPanel UFCanvasPanel
---@field FHorBox UFHorizontalBox
---@field InputBoxChat CommInputBoxView
---@field MI_DX_SoundColumn_Chat_1 UFImage
---@field MultiLineEditText UMultiLineEditableText
---@field PanelCancel UFCanvasPanel
---@field PanelRecordText UFCanvasPanel
---@field SwitcherInput UFWidgetSwitcher
---@field TextKeyBoardInput UFTextBlock
---@field TextRecordToText UFTextBlock
---@field TextRecording UFTextBlock
---@field TextVoice UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChatBarPanelView = LuaClass(UIView, true)

function ChatBarPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClosePanelRecordText = nil
	--self.BtnConvertToText = nil
	--self.BtnConvertToVoice = nil
	--self.BtnEmoj = nil
	--self.BtnHideRecordTextPanel = nil
	--self.BtnKeyboard = nil
	--self.BtnKeyboardInput = nil
	--self.BtnRecord = nil
	--self.BtnRecordCancel = nil
	--self.BtnRecordSend = nil
	--self.BtnRecordSure = nil
	--self.BtnRecordToText = nil
	--self.BtnSend = nil
	--self.BtnVoice = nil
	--self.ComRedDotEmoj = nil
	--self.ContentPanel = nil
	--self.FHorBox = nil
	--self.InputBoxChat = nil
	--self.MI_DX_SoundColumn_Chat_1 = nil
	--self.MultiLineEditText = nil
	--self.PanelCancel = nil
	--self.PanelRecordText = nil
	--self.SwitcherInput = nil
	--self.TextKeyBoardInput = nil
	--self.TextRecordToText = nil
	--self.TextRecording = nil
	--self.TextVoice = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChatBarPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ComRedDotEmoj)
	self:AddSubView(self.InputBoxChat)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChatBarPanelView:OnInit()
	self.Content = nil
	self.HrefList = {}

	self.Binders = {
		{ "ChatBarWidgetVisible", 	UIBinderSetIsVisible.New(self, self.ContentPanel) },
		{ "CurBarWidgetIndex", 		UIBinderSetActiveWidgetIndex.New(self, self.SwitcherInput) },
		{ "CurBarWidgetIndex", 		UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedCurBarWidgetIndex) },
		{ "CurChannel", 			UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedCurChannel) },
		{ "CurChannelID", 			UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedCurChannelID) },
		{ "IsPublicChat", 			UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedIsPublicChat) },
	}

	self.InputBoxChat:SetCallback(self, self.OnTextChangedChat)
end

function ChatBarPanelView:OnDestroy()

end

function ChatBarPanelView:OnShow()
	self.CurItemHyperlinkNum = 0
	self.RecordElapsedTime = 0

	self:InitConstText()
	self:SetRecordText("")
	self:SetChatText(self.Content)
end

function ChatBarPanelView:OnHide()
	self:Clear()

	self:SetChatText(self.Content)
	self:ResetCurBarWidgetIndex(true)
end

function ChatBarPanelView:ResetCurBarWidgetIndex(IsHide)
	local CurIndex = ChatVM.CurBarWidgetIndex
	if nil == CurIndex then
		return
	end

	local NewIndex = CurIndex
	if CurIndex == BarWidgetIndex.Input and IsHide then 
		local Text = self:GetChatText()
		if string.isnilorempty(Text) then 
			NewIndex = BarWidgetIndex.KeyboardInit
		end

	elseif CurIndex == BarWidgetIndex.Recroding then
		NewIndex = ChatVM.LastBarWidgetIndex
	end

	ChatVM:UpdateCurBarWidgetIndex(NewIndex)
end

function ChatBarPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSend, 	self.OnClickedBtnSend)
	UIUtil.AddOnClickedEvent(self, self.BtnEmoj, 	self.OnClickedBtnEmoj)
	UIUtil.AddOnClickedEvent(self, self.BtnKeyboard,self.OnClickedBtnKeyboard)
	UIUtil.AddOnClickedEvent(self, self.BtnRecord, 	self.OnClickedBtnRecord)

	UIUtil.AddOnClickedEvent(self, self.BtnKeyboardInput, 	self.OnClickedBtnKeyboardInput)
	UIUtil.AddOnClickedEvent(self, self.BtnRecordToText, 	self.OnClickedBtnRecordToText)
	UIUtil.AddOnClickedEvent(self, self.BtnVoice, 			self.OnClickedBtnVoice)
	UIUtil.AddOnClickedEvent(self, self.BtnConvertToVoice, 	self.OnClickedBtnConvertToVoice)
	UIUtil.AddOnClickedEvent(self, self.BtnConvertToText, 	self.OnClickedBtnConvertToText)

	-- 录音
	UIUtil.AddOnClickedEvent(self, self.BtnRecordCancel,		self.OnClickedBtnRecordCancel)
	UIUtil.AddOnClickedEvent(self, self.BtnRecordSure, 			self.OnClickedBtnRecordSure)
	UIUtil.AddOnClickedEvent(self, self.BtnRecordSend, 			self.OnClickedBtnRecordSend)
	UIUtil.AddOnClickedEvent(self, self.BtnClosePanelRecordText,self.OnClickedBtnClosePanelRecordText)
	UIUtil.AddOnTextChangedEvent(self, self.MultiLineEditText, 	self.OnTextChangedRecord)
	UIUtil.AddOnClickedEvent(self, self.BtnHideRecordTextPanel,	self.OnClickedBtnHideRecordTextPanel)

	UIUtil.AddOnFocusReceivedEvent(self, self.InputBoxChat.InputText, self.OnInputBoxTextFocusReceived)
end

function ChatBarPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.GVoiceRSTTComplete, self.OnEventRSTTComplete) -- 实时语言转文字完成
	self:RegisterGameEvent(EventID.GVoiceUploadComplete, self.OnGameEventUploadComplete) 	-- 录音文件上传完成

	self:RegisterGameEvent(EventID.ChatInsertInputText, 			self.OnEventInsertInputText)
    self:RegisterGameEvent(EventID.ChatHyperLinkSelectGoods, 		self.OnEventHyperLinkSelectGoods)
    self:RegisterGameEvent(EventID.ChatHyperLinkAddLocation, 		self.OnEventHyperLinkAddLocation)
    self:RegisterGameEvent(EventID.ChatHyperLinkSelectHistoryItem, 	self.OnEventHyperLinkSelectHistoryItem)
end

function ChatBarPanelView:OnRegisterBinder()
	self:RegisterBinders(ChatVM, self.Binders)
end

function ChatBarPanelView:InitConstText()
	if self.IsInitConstText then
		return
	end

	self.IsInitConstText = true

	self.TextKeyBoardInput:SetText(LSTR(50080)) -- "键盘输入"
	self.TextRecordToText:SetText(LSTR(50081)) -- "录音转文字"
	self.TextVoice:SetText(LSTR(50082)) -- "语音"
end

function ChatBarPanelView:Clear()
	self.RecordChannel = nil 
	self.RecordChannelID = nil 
	self.WaitSendVoiceAndWordsInfo = nil 

	self:SetRecordText("")
	self:StopRecord()
	UIUtil.SetIsVisible(self.PanelRecordText, false)
end

function ChatBarPanelView:SetChatText(Text)
	if nil == Text then
		return
	end

	self.InputBoxChat:SetText(Text)

	if #Text > 0 then
		ChatVM:UpdateCurBarWidgetIndex(BarWidgetIndex.Input)
	end
end

function ChatBarPanelView:GetChatText()
	return self.InputBoxChat:GetText()
end

function ChatBarPanelView:OnClickedBtnSend()
	self:OnClickedBtnClosePanelRecordText()

	if not ChatVM:CheckSendTimeCD() then
		return
	end

	local Channel, ChannelID = ChatVM:GetSendMsgChannelAndChannelID()
	local ChannelVM = ChatVM:FindChannelVM(Channel, ChannelID)
	if nil == ChannelVM then
		self:SetChatText("")
		FLOG_ERROR("[ChatBarPanelView] ChannelVM is nil (CurChannel=%s, CurChannelID=%s)", tostring(Channel), tostring(ChannelID))
		return
	end

	local Text = self:GetChatText()
	if string.len(Text) <= 0 then
		-- 50038("发送内容不能为空")
		MsgTipsUtil.ShowTips(LSTR(50038))
		return
	end

	local RichText, ParamList = self:GenerateChatMsg(Text)

	self:SetChatText("")

	self.HrefList = {}
	self.CurItemHyperlinkNum = 0

	ChatMgr:SendChatMsgPushMessage(ChannelVM:GetChannel(), ChannelVM:GetChannelID(), RichText, 0, ParamList)

	ChatVM:UpdateSendTimeCD(Channel, ChannelID)
end

function ChatBarPanelView:OnClickedBtnEmoj()
	self:OnClickedBtnClosePanelRecordText()

	self:TryStopRecording()
	UIViewMgr:ShowView(UIViewID.ChatHyperlinkPanel)
end

function ChatBarPanelView:OnClickedBtnKeyboard()
	ChatVM:UpdateCurBarWidgetIndex(BarWidgetIndex.KeyboardInit)
end

function ChatBarPanelView:OnClickedBtnRecord()
	self:OnClickedBtnClosePanelRecordText()

	ChatVM:UpdateCurBarWidgetIndex(BarWidgetIndex.RecordToText)
end

function ChatBarPanelView:OnClickedBtnKeyboardInput()
	ChatVM:UpdateCurBarWidgetIndex(BarWidgetIndex.Input)

	self.InputBoxChat:SetFocus()
end

function ChatBarPanelView:OnClickedBtnRecordToText()
	if self:StartRecord() then
		self:SetRecordText("")
		self:SetChatText("")
		ChatVM:UpdateCurBarWidgetIndex(BarWidgetIndex.Recroding)
	end
end

function ChatBarPanelView:OnClickedBtnVoice()
	if self:StartRecord() then
		self:SetRecordText("")
		self:SetChatText("")
		ChatVM:UpdateCurBarWidgetIndex(BarWidgetIndex.Recroding)
	end
end

function ChatBarPanelView:OnClickedBtnConvertToVoice()
	ChatVM:UpdateCurBarWidgetIndex(BarWidgetIndex.Voice)
end

function ChatBarPanelView:OnClickedBtnConvertToText()
	ChatVM:UpdateCurBarWidgetIndex(BarWidgetIndex.RecordToText)
end

function ChatBarPanelView:RemoveIllegalChars(Text)
	if string.isnilorempty(Text) then
		return "" 
	end

	return CommonUtil.RemoveSpecialChars(string.gsub(Text, "[<>]", ""))
end

function ChatBarPanelView:OnTextChangedChat(Text)
	local NewText = self:RemoveIllegalChars(Text)
	if NewText ~= Text then
		self:SetChatText(NewText)
		return
	end

	-- 内容为空是发送按钮不显示
	UIUtil.SetIsVisible(self.BtnSend, #Text > 0, true)

	if self.Content == Text then
		return
	end

	local IsPass, TrimText = ChatVM:CheckInputMsgLengthLimit(Text)
	if not IsPass then
		self:SetChatText(TrimText)
		return
	end

	-- 检查宏
	self:CheckMacros(Text)

	self:UpdateHref(Text)
	self.Content = Text 
end

function ChatBarPanelView:CheckMacros(Text)
	if string.find(Text, ChatMacros.TeamRecruit) then -- 队伍招募超链接
		self:AddTeamRecruitHref()
	end
end

function ChatBarPanelView:GenerateChatMsg(Text)
	local ParamList = {}
	local Num = 0

	for i, v in ipairs(self.HrefList) do
		local RichText
		local Data = v.Data
		local ParamType = Data.Type
		if ParamType == PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_ITEM then
			local Color = ItemUtil.GetItemQualityColorByResID((Data.Item or {}).ResID)
			RichText = RichTextUtil.GetHyperlink(v.HrefText, i, Color, nil, nil, nil, nil, nil, false)

		elseif ParamType == PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_MAP then
			RichText = RichTextUtil.GetHyperlink(v.HrefText, i, "#A4FFFFFF", nil, nil, nil, nil, nil, false)

		else
			RichText = v.HrefText
		end

		Text, Num = string.gsub(Text, v.Key, RichText, 1)
		if Num > 0 then
			local ChatParams = table.clone(Data)
			ChatParams.Type = nil

			local Param = ChatMgr:EncodeChatParams(ChatParams)
			local Params = { Type = ParamType, Direct = true, Param = Param }

			if ParamType == PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_TEAM_RECRUIT then -- 队伍招募超链接
				ParamList = table.pack(Params)
				return v.HrefText, ParamList

			else
				table.insert(ParamList, Params)
			end
		end
	end

	return Text, ParamList
end

function ChatBarPanelView:OnValueChangedCurBarWidgetIndex(Index)
	if self:IsRecording() then
		self:StopRecord()
	end
	
	local RecordVisible = Index == BarWidgetIndex.KeyboardInit or Index == BarWidgetIndex.Input
	UIUtil.SetIsVisible(self.BtnRecord, RecordVisible, true)
	UIUtil.SetIsVisible(self.BtnKeyboard, not RecordVisible, true)

	if Index == BarWidgetIndex.Recroding then
		local LastIsVoice = ChatVM.LastBarWidgetIndex == BarWidgetIndex.Voice
		UIUtil.SetIsVisible(self.BtnRecordSure, not LastIsVoice, true)
		UIUtil.SetIsVisible(self.BtnRecordSend, LastIsVoice, true)
	end
end

function ChatBarPanelView:OnValueChangedCurChannel( )
	self:ResetCurBarWidgetIndex()

	local MaxLen = ChatVM:GetCurInputMsgMaxLength()
	self.InputBoxChat:SetMaxNum(MaxLen)

	self:Clear()
end

function ChatBarPanelView:OnValueChangedCurChannelID( )
	self:ResetCurBarWidgetIndex()
	self:Clear()
end

-- 公聊、私聊切换
function ChatBarPanelView:OnValueChangedIsPublicChat(NewValue)
	self:ResetCurBarWidgetIndex()
	self:Clear()
end

function ChatBarPanelView:OnEventInsertInputText(Text)
	if string.isnilorempty(Text) then
		return
	end

	self:SetChatText(self:GetChatText() .. Text)
	self.InputBoxChat:SetCursorToEnd()
end

-------------------------------------------------------------------------------------------------
---超链接

function ChatBarPanelView:CheckItemHyperlinkNum()
	if self.CurItemHyperlinkNum < ChatDefine.MaxHyperlinkNum then
		return true 
	end

	-- 10039("超链接数量超过上限")
	MsgTipsUtil.ShowTips(LSTR(50039))

	return false 
end

function ChatBarPanelView:UpdateHref(Content)
	local Num = #self.HrefList

	for i = Num, 1, -1 do
		local Href = self.HrefList[i]
		if nil ~= Href and not string.find(Content, Href.Key) then
			table.remove(self.HrefList, i)

			local Data = Href.Data 
			if Data and Data.Type == PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_ITEM then
				self.CurItemHyperlinkNum = math.max(0, self.CurItemHyperlinkNum - 1)
			end
		end
	end
end

function ChatBarPanelView:AddHref(Text, SimpleHref)
	if string.isnilorempty(Text) then
		return
	end

	local Key
	local HrefText 

	local Type = SimpleHref.Type
	if Type == PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_ITEM then -- 物品/装备 
		Key = string.revisePattern(string.format("[%s]", Text))
		HrefText = string.format("[%s]", Text)

		if table.find_item(self.HrefList, Key, "Key") then
			return nil, true
		end

		if not self:CheckItemHyperlinkNum() then
			return
		end

		self.CurItemHyperlinkNum = self.CurItemHyperlinkNum + 1

	else
		Key = Text
		HrefText = Text

		if table.find_item(self.HrefList, Key, "Key") then
			return nil, true
		end
	end

	local Href = { Key = Key, HrefText = HrefText, Data = SimpleHref }
	table.insert(self.HrefList, Href)

	return HrefText
end

function ChatBarPanelView:OnEventHyperLinkSelectGoods( ItemVM )
	if nil == ItemVM then
		return
	end

	local Text = ItemVM.Name 
	if string.isnilorempty(Text) then
		return
	end

	local Href = {
		Type = PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_ITEM,
		Item = { 
			GID 	= ItemVM.GID, 
			ResID 	= ItemVM.ResID,
			RoleID 	= MajorUtil.GetMajorRoleID()
		}
	}

	local IsSameHref = nil
	Text, IsSameHref = self:AddHref(Text, Href)
	if nil == Text then
		ChatVM:UpdateCurBarWidgetIndex(BarWidgetIndex.Input)

		if IsSameHref then
			if ItemUtil.CheckIsEquipmentByResID(ItemVM.ResID) then
				MsgTipsUtil.ShowTips(LSTR(50188)) -- 50188("当前输入栏中已有同名装备")
			else
				MsgTipsUtil.ShowTips(LSTR(50189)) -- 50189("当前输入栏中已有同名道具")
			end
		end

		return
	end

	local Content = self:GetChatText() .. Text
	self:SetChatText(Content)

	self.Content = Content
	self.InputBoxChat:SetCursorToEnd()
end

function ChatBarPanelView:OnEventHyperLinkAddLocation(MapID, Position)
	if nil == MapID or nil == Position then
		return
	end

	local Text = HyperlinkLocationFlag 

	local Href = {
		Type = PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_MAP,
		Map = { 
			MapID 	= MapID, 
			X 		= Position.X or 0,
			Y 		= Position.Y or 0,
		}
	}

	local IsSameHref = nil
	Text, IsSameHref = self:AddHref(Text, Href)
	if nil == Text then
		ChatVM:UpdateCurBarWidgetIndex(BarWidgetIndex.Input)

		if IsSameHref then
			MsgTipsUtil.ShowTips(LSTR(50190)) -- 50188("当前输入栏中已存在位置坐标")
		end

		return
	end

	local Content = self:GetChatText() .. Text
	self:SetChatText(Content)

	self.Content = Content
	self.InputBoxChat:SetCursorToEnd()
end

function ChatBarPanelView:OnEventHyperLinkSelectHistoryItem( HistoryItemVM )
	if nil == HistoryItemVM then
		return
	end

	self.HrefList = {}
	self.CurItemHyperlinkNum = 0

	local ParamList = HistoryItemVM.ParamList
	local Content = HistoryItemVM.RawContent or ""
	if nil == ParamList or #ParamList <= 0 then
		self:SetChatText(Content)
		return
	end

	local TextList = {}

	for k, _ in string.gmatch(Content, ">(.-)</>") do
		if string.len(k) > 0 then
			table.insert(TextList, k)
		end
	end

	for k, v in ipairs(ParamList) do
		local SimpleHref = ChatMgr:DecodeChatParams(v.Param)
		if SimpleHref ~= nil then
			local Type = v.Type
			if Type == PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_ITEM then -- 物品
				local Item = SimpleHref.Item
				if Item ~= nil then
					local Text = TextList[k]
					local GoodsName = Text
					GoodsName = string.gsub(GoodsName, "^%[", "")
					GoodsName = string.gsub(GoodsName, "%]$", "")

					local HrefText = self:AddHref(GoodsName, {Type = Type, Item = Item})
					Content = self:GetHistoryInputText(Content, Text, HrefText)
				end

			elseif Type == PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_MAP then -- 位置
				local Map = SimpleHref.Map
				if Map then
					local HrefText = self:AddHref(HyperlinkLocationFlag, {Type = Type, Map = Map})
					Content = self:GetHistoryInputText(Content, TextList[k], HrefText)
				end

			elseif Type == PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_GIF then -- Gif表情 
				local Gif = SimpleHref.Gif
				if Gif then
					return ChatMgr:SendGif(Gif.ID)
				end

			elseif Type == PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_TEAM_RECRUIT then -- 队伍招募 
				local Recruit = SimpleHref.TeamRecruit
				if Recruit then
					local Channel, ChannelID = ChatVM:GetSendMsgChannelAndChannelID()
					ChatMgr:ShareTeamRecruit(Channel, Recruit.ID, Recruit.ResID, Recruit.IconIDs, Recruit.LocList, Recruit.TaskLimit, ChannelID)

					UIViewMgr:HideView(UIViewID.ChatHyperlinkPanel, true)
					return
				end
			end
		end
	end

	if nil == Content then
		return
	end

	self:SetChatText(Content)

	self.Content = Content
	self.InputBoxChat:SetCursorToEnd()
end

function ChatBarPanelView:GetHistoryInputText(SrcText, SrcPartText, HrefText)
	if nil == HrefText then
		return SrcText 
	end

	local Str = string.format("(<a .-%s</>)", string.revisePattern(SrcPartText))
	Str = string.match(SrcText, Str)
	Str = string.revisePattern(Str)
	if nil == Str then
		return SrcText 
	end

	local Ret = string.gsub(SrcText, Str, HrefText)
	return nil == Ret and SrcText or Ret
end

function ChatBarPanelView:AddTeamRecruitHref()
	local TeamRecruitUtil = require("Game/TeamRecruit/TeamRecruitUtil")
	local Href = TeamRecruitUtil.GenChatRecruitShareHref(_G.TeamRecruitMgr:GetClipboard())
	if Href == nil then
		return
	end

	self:AddHref(ChatMacros.TeamRecruit, Href)
end

-------------------------------------------------------------------------------------------------
---录音

function ChatBarPanelView:SetRecordText(Text)
	self.MultiLineEditText:SetText(Text)
end

function ChatBarPanelView:OnClickedBtnRecordCancel( )
	self:StopRecord()

	ChatVM:UpdateCurBarWidgetIndex(ChatVM.LastBarWidgetIndex)
end

function ChatBarPanelView:OnClickedBtnRecordSure()
	self:StopRecord()
end

function ChatBarPanelView:OnClickedBtnRecordSend( )
	self:StopRecord()
end

function ChatBarPanelView:OnClickedBtnClosePanelRecordText( )
	UIUtil.SetIsVisible(self.PanelRecordText, false)
	self:SetRecordText("")
end

function ChatBarPanelView:OnClickedBtnHideRecordTextPanel( )
	UIUtil.SetIsVisible(self.PanelRecordText, false)
	self:SetRecordText("")
end

function ChatBarPanelView:OnInputBoxTextFocusReceived()
	self:OnClickedBtnClosePanelRecordText()
end

---@param Params FEventParams
---Params.StringParam1, the translation result 
function ChatBarPanelView:OnEventRSTTComplete( Params )
	local Channel, ChannelID = ChatVM:GetSendMsgChannelAndChannelID()
	if Channel ~= self.RecordChannel or ChannelID ~= self.RecordChannelID then
		FLOG_INFO("[ChatBarPanelView] OnEventRSTTComplete, the channel has changed.")
		return
	end

	if nil == Params then
		FLOG_WARNING("[ChatBarPanelView] OnEventRSTTComplete, Params is nil.")
		return
	end

	local Text = self:RemoveIllegalChars(Params.StringParam1)

	local LastIndex = ChatVM.LastBarWidgetIndex 
	if LastIndex == BarWidgetIndex.Voice then
		self:SendVoiceAndWords(Channel, ChannelID, Text)

		ChatVM:UpdateCurBarWidgetIndex(LastIndex)
		UIUtil.SetIsVisible(self.PanelRecordText, false)

	elseif LastIndex == BarWidgetIndex.RecordToText then
		ChatVM:UpdateCurBarWidgetIndex(BarWidgetIndex.Input)
		UIUtil.SetIsVisible(self.PanelRecordText, true)

		self:SetRecordText(Text)

		-- TLOG数据埋点
		ChatUtil.ReportVoiceData(Channel, 1, string.isnilorempty(Text) and 0 or 1)
	end

	self.RecordChannel = nil 
	self.RecordChannelID = nil 
end

function ChatBarPanelView:OnTextChangedRecord(_, Text)
	if not UIUtil.IsVisible(self.PanelRecordText) then
		return
	end

	local NewText = self:RemoveIllegalChars(Text)
	if NewText ~= Text then
		self:SetRecordText(NewText)
		return
	end

	local TempText, Num = string.gsub(Text, "[\n\r\t]", "") 
	if Num > 0 then
		self:SetRecordText(TempText)
		return
	end

	local IsPass, TrimText = ChatVM:CheckInputMsgLengthLimit(Text)
	if not IsPass then
		self:SetRecordText(TrimText)
		return
	end

	-- 同步文本
	self.InputBoxChat:SetText(Text)
	self.InputBoxChat:SetCursorToEnd()
end

function ChatBarPanelView:IsRecording()
	return self.RecordElapsedTime ~= nil and self.RecordElapsedTime > 0
end

function ChatBarPanelView:TryStopRecording( )
	if self:IsRecording() then
		self:OnClickedBtnRecordCancel()
	end
end

---开始录音
function ChatBarPanelView:StartRecord( )
	-- 队伍实时语音是否开麦
	if TeamVoiceMgr:IsUsingMic() then
		MsgTipsUtil.ShowTips(LSTR(1300079)) -- 50084("请先关闭队伍语音，再进行语音录制")
		return
	end

	if self:IsRecording() then
		FLOG_WARNING("[ChatBarPanelView] StartRecord, is recording")
		return
	end

	if self:IsSendingVoice() then
		FLOG_WARNING("[ChatBarPanelView] StartRecord, is sending voice")
		return
	end

	--测试麦克风
	if not VoiceMgr:CheckMicrophone() then
		return false
	end

	local Channel, ChannelID = ChatVM:GetSendMsgChannelAndChannelID()
	self.RecordChannel = Channel
	self.RecordChannelID = ChannelID

	self:SetMicLevelValue(0)
	self:SetRecordCountDownText(MaxRecordTime)

	self.RecordElapsedTime = 0
	self:CloseRecordTimer()
	self.RecordTimer = _G.TimerMgr:AddTimer(self, self.OnRecordTimerCallback, 0, 0.1, -1)

	return true
end

function ChatBarPanelView:OnRecordTimerCallback(Params, ElapsedTime)
	if self.RecordElapsedTime <= 0 then
		local bSuc = VoiceMgr:StartRecording(ChatVM:IsPrivateChatCurrent())
		if not bSuc then
			self:StopRecord()
			return

		else
			ChatMgr.IsRecording = true
			VoiceMgr:CloseSomeAudios()
		end
	end

	self.RecordElapsedTime = ElapsedTime

	if nil == self.IsMobile then
		self.IsMobile = CommonUtil.IsMobilePlatform()
	end

	-- 设置麦克风音量
	local Volume = VoiceMgr:GetMicVolume()
	if self.IsMobile then
		Volume = Volume * 1.5 -- 在移动平台返回的值较小，为了麦的波纹变化大点, 把数值放大点
	end

	self:SetMicLevelValue(Volume)

	if self.RecordElapsedTime >= MaxRecordTime then
		self:SetRecordCountDownText(0)
		self:StopRecord()

		return
	end

	self:SetRecordCountDownText(math.ceil(MaxRecordTime - self.RecordElapsedTime))
end

function ChatBarPanelView:SetMicLevelValue(WholeNumber)
	local Value = math.max(0, WholeNumber)

	if nil == self.MicMaxVolume then
		self.MicMaxVolume = VoiceMgr:GetMicMaxVolume()
	end

	self:SetSoundImgMatParamMax(Value / self.MicMaxVolume)
end

function ChatBarPanelView:SetRecordCountDownText( Second )
	if nil == self.CountDownFmt then
		self.CountDownFmt = LSTR(50083) -- 录音中%ds
	end

	local Text = string.format(self.CountDownFmt, Second) -- 10070("%s秒")
	self.TextRecording:SetText(Text)
end

function ChatBarPanelView:CloseRecordTimer()
	if self.RecordTimer ~= nil then
		_G.TimerMgr:CancelTimer(self.RecordTimer)
		self.RecordTimer = nil
	end
end

function ChatBarPanelView:StopRecord( )
	self:CloseRecordTimer()
	self:SetMicLevelValue(0)
	VoiceMgr:StopRecording()
	VoiceMgr:RecoverBeClosedAudios()

	self.RecordElapsedTime = 0
	ChatMgr.IsRecording = false 
end

function ChatBarPanelView:IsSendingVoice()
	return self.WaitSendVoiceAndWordsInfo ~= nil
end

--发送语音和翻译文本至当前频道
function ChatBarPanelView:SendVoiceAndWords(Channel, ChannelID, Text)
	local ChannelVM = ChatVM:FindChannelVM(Channel, ChannelID)
	if nil == ChannelVM then
		return
	end

	VoiceMgr:UploadRecordedFile(Channel == ChatChannel.Person)

	self.WaitSendVoiceAndWordsInfo = {
		Channel 	= ChannelVM:GetChannel(),
		ChannelID 	= ChannelVM:GetChannelID(),
		Content 	= Text,
	}
end

---@param Params FEventParams
---Params.BoolParam1, whether the upload was successful
---Params.ULongParam1, GCloudVoiceCompleteCode code
---Params.StringParam1, file ID
---Params.FloatParam1, the voice's length (s)
function ChatBarPanelView:OnGameEventUploadComplete(Params)
	if nil == Params then
		FLOG_WARNING("[ChatBarPanelView] OnGameEventUploadComplete, Params is nil.")
		self.WaitSendVoiceAndWordsInfo = nil
		return
	end

	local Code = Params.ULongParam1
	local IsSuccess = Params.BoolParam1
	if not IsSuccess then
		FLOG_WARNING("[ChatBarPanelView] OnGameEventUploadComplete, upload failed.")
		self.WaitSendVoiceAndWordsInfo = nil

		if Code == GCloudVoiceCompleteCode.GV_ON_UPLOAD_FILEID_CIVIL_FAILED then
			MsgTipsUtil.ShowTips(LSTR(50126)) -- 50084("本次上传的语音消息审核不通过，请重新录制！")
		end

		return
	end

    FLOG_INFO("[ChatBarPanelView] OnGameEventUploadComplete 录音文件上传完成, FileID=%s Length=%s Code=0x%X", Params.StringParam1, Params.FloatParam1, Code)

	local Info = self.WaitSendVoiceAndWordsInfo 
	if table.is_nil_empty(Info) then
		FLOG_INFO("[ChatBarPanelView] WaitSendVoiceAndWordsInfo is nil or empty")
		self.WaitSendVoiceAndWordsInfo = nil
		return
	end

	local voiceLength = math.min(math.ceil(Params.FloatParam1), MaxRecordTime) 
	if voiceLength <= 0 then
		FLOG_WARNING("[ChatBarPanelView] OnGameEventUploadComplete, voice length is invalid.")
		self.WaitSendVoiceAndWordsInfo = nil
		return
	end

	local VoiceHref = { }
	VoiceHref.ID = Params.StringParam1 
	VoiceHref.Length = voiceLength 
	VoiceHref.Language = VoiceMgr:GetCurSpeechLanguageType()

	local ExtraParams = { }
	ExtraParams.Type 	= PARAM_TYPE_DEFINE.PARAM_TYPE_DEFINE_VOICE
	ExtraParams.Direct 	= true
	ExtraParams.Param 	= ChatMgr:EncodeChatParams({Voice = VoiceHref})

	local Channel, ChannelID = Info.Channel, Info.ChannelID
	ChatMgr:SendChatMsgPushMessage(Channel, ChannelID, Info.Content or "", 0, table.pack(ExtraParams))

	self.WaitSendVoiceAndWordsInfo = nil

	-- TLOG数据埋点
	ChatUtil.ReportVoiceData(Channel, 2)
end
return ChatBarPanelView