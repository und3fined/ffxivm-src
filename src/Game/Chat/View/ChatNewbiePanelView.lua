---
--- Author: xingcaicao
--- DateTime: 2024-11-27 19:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local NewbieMgr = require("Game/Newbie/NewbieMgr")
local OnlineStatusUtil = require("Game/OnlineStatus/OnlineStatusUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local GlobalCfg = require("TableCfg/GlobalCfg")
local MajorUtil = require("Utils/MajorUtil")
local ChatVM = require("Game/Chat/ChatVM")
local ChatDefine = require("Game/Chat/ChatDefine")

local LSTR = _G.LSTR
local FLOG_ERROR = _G.FLOG_ERROR
local OnlineStatusIdentify = ProtoRes.OnlineStatusIdentify
local ClientSetupKey = ProtoCS.ClientSetupKey
local NewbieChannelLowestLevel = ChatDefine.NewbieChannelLowestLevel
local ChatChannel = ChatDefine.ChatChannel

---@class ChatNewbiePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AcceptAassessPanel UFCanvasPanel
---@field BannerPanel UFCanvasPanel
---@field BeInvitedPanel UFCanvasPanel
---@field BtnAcceptAassess CommBtnMView
---@field BtnGoToInvite CommBtnMView
---@field BtnJoin CommBtnMView
---@field CDPanel UFCanvasPanel
---@field FCanvasPanel2 UFCanvasPanel
---@field GuiderNumPanel UFCanvasPanel
---@field ImgManifesto UFImage
---@field JoinPanel UFCanvasPanel
---@field RichTextBeInvitedTips URichTextBox
---@field RichTextCD URichTextBox
---@field RichTextCDTips URichTextBox
---@field RichTextGuiderNum URichTextBox
---@field RichTextJoinTips URichTextBox
---@field RichTextNewbieIntroduction URichTextBox
---@field RichTextUnlockGuiderNum URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChatNewbiePanelView = LuaClass(UIView, true)

function ChatNewbiePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AcceptAassessPanel = nil
	--self.BannerPanel = nil
	--self.BeInvitedPanel = nil
	--self.BtnAcceptAassess = nil
	--self.BtnGoToInvite = nil
	--self.BtnJoin = nil
	--self.CDPanel = nil
	--self.FCanvasPanel2 = nil
	--self.GuiderNumPanel = nil
	--self.ImgManifesto = nil
	--self.JoinPanel = nil
	--self.RichTextBeInvitedTips = nil
	--self.RichTextCD = nil
	--self.RichTextCDTips = nil
	--self.RichTextGuiderNum = nil
	--self.RichTextJoinTips = nil
	--self.RichTextNewbieIntroduction = nil
	--self.RichTextUnlockGuiderNum = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChatNewbiePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnAcceptAassess)
	self:AddSubView(self.BtnGoToInvite)
	self:AddSubView(self.BtnJoin)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChatNewbiePanelView:OnInit()
	self.IsInitConstInfo = false 
end

function ChatNewbiePanelView:OnDestroy()

end

function ChatNewbiePanelView:OnShow()
	self:InitConstInfo()
	self:UpdateNewbiePanel()
end

function ChatNewbiePanelView:OnHide()
	self:StopTimer()
end

function ChatNewbiePanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnAcceptAassess, self.OnClickButtonAcceptAassess)
	UIUtil.AddOnClickedEvent(self, self.BtnJoin, self.OnClickButtonJoin)
	UIUtil.AddOnClickedEvent(self, self.BtnGoToInvite, self.OnClickButtonGoToInvite)
end

function ChatNewbiePanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.ChatNewbieGuiderNumChanged, self.OnEventNewbieGuiderNumChanged)
	self:RegisterGameEvent(EventID.ClientSetupPost, self.OnEventClientSetupPost)
    self:RegisterGameEvent(EventID.ChatIsJoinNewbieChannelChanged, self.OnEventIsJoinNewbieChannelChanged)
    self:RegisterGameEvent(EventID.NewBieChannelInviterChange, self.OnEventNewBieChannelInviterChange)
end

function ChatNewbiePanelView:OnRegisterBinder()

end

function ChatNewbiePanelView:InitConstInfo()
	if self.IsInitConstInfo then
		return
	end

	self.IsInitConstInfo = true

	-- 考核
	self.BtnAcceptAassess:SetText(LSTR(50042)) -- "参与考核"

	-- 服务器指导者人数要求
	-- "服务器指导者玩家人数达<span color="#d1ba8eff">%d</>解锁"
	local Value = GlobalCfg:FindValue(ProtoRes.global_cfg_id.GLOBAL_CFG_KICK_NEWBIE_CHANNEL_GUIDE_NUM, "Value") or {}
	local NeedGuiderNum = tonumber(Value[1]) or 0
	self.RichTextUnlockGuiderNum:SetText(string.format(LSTR(50045), NeedGuiderNum))

	-- CD Tips
	self.RichTextCDTips:SetText(LSTR(50046)) -- "暂时无法加入频道"

	-- 加入
	self.BtnJoin:SetText(LSTR(50067)) -- "加入频道"

	-- 被邀请
	self.BtnGoToInvite:SetText(LSTR(50071)) -- "查看邀请"
end

function ChatNewbiePanelView:UpdateNewbiePanel()
	UIUtil.SetIsVisible(self.AcceptAassessPanel, false)
	UIUtil.SetIsVisible(self.GuiderNumPanel, false)
	UIUtil.SetIsVisible(self.CDPanel, false)
	UIUtil.SetIsVisible(self.JoinPanel, false)
	UIUtil.SetIsVisible(self.BeInvitedPanel, false)

	if NewbieMgr:IsInNewbieChannel() then
		-- case 1：已在新人频道中，但需要考核
		if NewbieMgr:QueryNewChannelSpeechAssessment() then
			UIUtil.SetIsVisible(self.AcceptAassessPanel, true)
		end

		self:SetBannerPanelVisible(false)
		return

	else
		self:SetBannerPanelVisible(true)
	end

	-- case 2：指导者数量是否达到要求
	local IsChannelOpen = NewbieMgr:IsNewbieChannelOpen()
	if not IsChannelOpen then
		local CurNum = NewbieMgr:GetCurrentServerGuideNum() or 0
		self.RichTextGuiderNum:SetText(string.format(LSTR(50044), CurNum)) -- "当前指导者人数:<span color="#89bd88ff">%d</>"

		UIUtil.SetIsVisible(self.GuiderNumPanel, true)

		-- 请求当前服务器中指导者数量
		NewbieMgr:SendGetGuiderNumReq()
		return
	end

	-- case 3: 是否处于加入新人频道冷却CD中
	local CDTime = NewbieMgr:GetJoinNewbieChannelCDTime()
	if CDTime > 0 then
		self:StartJoinTimer(CDTime)
		UIUtil.SetIsVisible(self.CDPanel, true)
		return
	end

	-- case 4：被邀请加入新人频道
	local InviterInfo = NewbieMgr:QueryLastInviterInfo()
	if InviterInfo then
		-- 资深冒险者<span color="#6fb1e9ff">%s</>邀请你加入
		local TextTips = string.format(LSTR(50070), InviterInfo.InviteRoleName or "")
		self.RichTextBeInvitedTips:SetText(TextTips)

		UIUtil.SetIsVisible(self.BeInvitedPanel, true)
		return
	end
	
	-- case 5：各身份要求（新人、回归者、指导者）
	UIUtil.SetIsVisible(self.JoinPanel, true)

	local TextTips = ""
    local Identity = OnlineStatusUtil.QueryMentorRelatedIdentity((MajorUtil.GetMajorRoleVM() or {}).Identity)
	if Identity == OnlineStatusIdentify.OnlineStatusIdentifyNewHand
		or Identity == OnlineStatusIdentify.OnlineStatusIdentifyReturner then -- 新人、回归者
		-- "新人需要等级达到<span color="#B09F7CFF">%s</>级后，被指导者玩家邀请加入"
		TextTips = string.format(LSTR(50068), NewbieChannelLowestLevel) 
		UIUtil.SetIsVisible(self.BtnJoin, false)

	elseif Identity == OnlineStatusIdentify.OnlineStatusIdentifyMentor then -- 指导者
		UIUtil.SetIsVisible(self.BtnJoin, true, true)

	else 
		UIUtil.SetIsVisible(self.BtnJoin, false)

		--"新人、回归者、指导者可加入该频道"
		TextTips = LSTR(50069)
	end

	self.RichTextJoinTips:SetText(TextTips)
end

function ChatNewbiePanelView:SetBannerPanelVisible(b)
	UIUtil.SetIsVisible(self.BannerPanel, b)

	local Img = self.ImgManifesto
	if b and not UIUtil.IsVisible(Img) then
		-- 宣传图
		local NewbieManifestoImg = "Texture2D'/Game/UI/Texture/ChatNew/UI_Chat_Img_NewBanner.UI_Chat_Img_NewBanner'"
		if UIUtil.ImageSetBrushFromAssetPath(Img, NewbieManifestoImg) then
			UIUtil.SetIsVisible(Img, true)
		end

		-- 频道介绍
		local GetStatusIconRT = function(Status) 
			local Icon = OnlineStatusUtil.GetStatusRes(Status)
			if string.isnilorempty(Icon) then
				return
			end

			return RichTextUtil.GetTexture(Icon, 40, 40, -10) or ""
		end

		local StatusRes = ProtoRes.OnlineStatus
		local NewHandIconRT = GetStatusIconRT(StatusRes.OnlineStatusNewHand) 
		local ReturnerIconRT = GetStatusIconRT(StatusRes.OnlineStatusReturner) 
		local MentorIconRT = GetStatusIconRT(StatusRes.OnlineStatusMentor) 

		-- "%s新人、%s回归者、%s指导者玩家专属交流沟通频道，相互帮助，答疑解惑，请大家文明交流，积极发言！"
		local Desc = string.format(LSTR(50043), NewHandIconRT, ReturnerIconRT, MentorIconRT)
		self.RichTextNewbieIntroduction:SetText(Desc)
	end
end

function ChatNewbiePanelView:StartJoinTimer(Time)
	self:StopTimer()

    self.TimerID = self:RegisterTimer(function(_, CoutDown, ElapsedTime)
		local Rts = CoutDown - ElapsedTime
		if Rts <= 0 then
			self:StopTimer()
			self:UpdateNewbiePanel()
			return
		end

		local Fmt = self.CDFmt
		if nil == Fmt then
			Fmt = LSTR(50047) -- "<span color="#d1ba8eff">%s</>时间后可再次加入"
			self.CDFmt = Fmt 
		end

		self.RichTextCD:SetText(string.format(Fmt, math.ceil(Rts / 60)))
	end, 0, 2, 0, Time)
end

function ChatNewbiePanelView:StopTimer()
	local TimerID = self.TimerID
	if TimerID then
		self:UnRegisterTimer(TimerID)
		self.TimerID = nil
	end
end

-------------------------------------------------------------------------------------------------------
---Client Event CallBack 

function ChatNewbiePanelView:OnEventNewbieGuiderNumChanged()
	self:UpdateNewbiePanel()
end

function ChatNewbiePanelView:OnEventClientSetupPost(EventParams)
	if nil == EventParams then
		return
	end

	-- 新人频道,答题完毕
	if NewbieMgr:IsInNewbieChannel() then
		local SetupKey = EventParams.IntParam1
		if SetupKey == ClientSetupKey.NewbieChannel then
			self:UpdateNewbiePanel()
			ChatVM:UpdateChatBarVisible()
		end
	end
end

function ChatNewbiePanelView:OnEventIsJoinNewbieChannelChanged()
	if ChatVM.CurChannel == ChatChannel.Newbie then
		self:UpdateNewbiePanel()
	end
end

function ChatNewbiePanelView:OnEventNewBieChannelInviterChange()
	self:UpdateNewbiePanel()
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function ChatNewbiePanelView:OnClickButtonAcceptAassess()
	NewbieMgr:StartNewbieSpeakEvaluation()
end

function ChatNewbiePanelView:OnClickButtonJoin()
	NewbieMgr:JoinChannelReq()
end

function ChatNewbiePanelView:OnClickButtonGoToInvite()
	local InviterInfo = NewbieMgr:QueryLastInviterInfo()
	if InviterInfo then
		NewbieMgr:OpenChatInvitationWinPanel(InviterInfo)
	else
		self:UpdateNewbiePanel()
	end
end

return ChatNewbiePanelView