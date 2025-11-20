local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local TimeUtil = require("Utils/TimeUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local DialogueUtil = require("Utils/DialogueUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")
local MailUtil = require("Game/Mail/MailUtil")
local UIBindableList = require("UI/UIBindableList")
local MailDefine = require("Game/Mail/MailDefine")
local MailSlotItemViewVM = require("Game/Mail/View/Item/MailSlotItemViewVM")
local MailListItemViewVM = require("Game/Mail/View/Item/MailListItemViewVM")
local StoreDefine = require("Game/Store/StoreDefine")
local StoreUtil = require("Game/Store/StoreUtil")
local UIViewID = require("Define/UIViewID")

local MailTypeInfo = MailDefine.MailTypeInfo
--local MailType = MailDefine.MailType
local LSTR
local MailMgr

---@class MailMainVM : UIViewModel
local MailMainVM = LuaClass(UIViewModel)

---Ctor
function MailMainVM:Ctor()
	self.MailTitle = ""
	self.MailContent = ""
	self.MaturityDayText = ""
	self.SendTimeText = ""
	self.SenderName = ""
	self.TextSubtitle = ""
	self.PanelEmptyText = ""
	self.TopCenterIconPath = ""
	self.SpineLetterInStyle = "Common"
	self.TopCenterIconVisible = false
	self.TextTItleTipsVisible = false

	self.BtnGetAllIsEnabled =true
	self.MainPanelContentVisible = false
	self.PanelEmptyVisible = false
	self.BtnGetVisible = false
	self.BtnDeleteMailVisible = false
	self.ContentPanelVisible = false
	self.AttachContentPanelVisible = false
	self.LittleAttachPanelVisible = false
	self.LargeAttachPanelVisible = false
	self.MaturityDayVisible = false
	self.SenderNameVisible = false
	self.ModelToImageVisible = false

	self.MailListDelChanged = false

	self.AttachsInfoList = UIBindableList.New( MailSlotItemViewVM )
	self.MailList = UIBindableList.New( MailListItemViewVM )
	self.CurrentMailType = 1
	self.CurrentMailID = 0
	self.CurrentMailBoxType = MailDefine.MailBoxType.InBox

	self.HaveMailAnim = true
	self.MailAllAttchList = {}
	self.MailListLastSelectIndex = 1
	self.MapHyperLink = {}

	--商城赠礼
	self.GiftPageVisible = false
	self.ReceiverName = ""
	self.GiftToggleGroupIndex = 0
	self.GiftMailEnvelopeVisible = true
	self.PanelGiftMailContentVisible = false
	self.GiftTextFromName = ""
	self.GiftMailBtnCheckVisible = true

	self.FirstPickMailID = nil
end

function MailMainVM:OnInit()

end

function MailMainVM:OnBegin()
	LSTR = _G.LSTR
	MailMgr = _G.MailMgr
	self.HaveMailAnim = true
end

function MailMainVM:OnEnd()
end

function MailMainVM:OnShutdown()
end

function MailMainVM:SetGiftPageVisible(GiftPageVisible)
	self.GiftPageVisible = GiftPageVisible
end

function MailMainVM:SetFirstPickMailID(FirstPickMailID)
	self.FirstPickMailID = FirstPickMailID
end

function MailMainVM:SetMailListLastSelectIndex(MailListLastSelectIndex)
	self.MailListLastSelectIndex = MailListLastSelectIndex
end

function MailMainVM:SetHaveMailAnim(HaveMailAnim)
	self.HaveMailAnim = HaveMailAnim
end

function MailMainVM:SetCurrentMailBoxType(CurrentMailBoxType)
	self.CurrentMailBoxType = CurrentMailBoxType
end

function MailMainVM:SetGiftToggleGroupIndex(Index)
	if self.GiftToggleGroupIndex == Index then return end
	self.GiftToggleGroupIndex = Index
	if Index == 1 then
		self.CurrentMailBoxType = MailDefine.MailBoxType.InBox
		self:SelectMailTab( MailDefine.MailType.Gift, true)
	elseif Index == 2 then
		self.CurrentMailBoxType = MailDefine.MailBoxType.OutBox
		self:SelectMailTab( MailDefine.MailType.Gift, true)
	end

	-- 商城TLOG上报
	local MailTabType = Index == 1 and StoreDefine.MailTabType.GiftInbox or StoreDefine.MailTabType.GiftRecord
	StoreUtil.ReportMailFlow(MailTabType)
end

function MailMainVM:SetHaveMails(HaveMails, MailListData)
	local IsGiftMail = self.CurrentMailType == MailDefine.MailType.Gift     --赠礼邮件
	local IsInBox = self.CurrentMailBoxType == MailDefine.MailBoxType.InBox       --收件箱
	local IsOutBox = not IsInBox												  --发件箱

	self.MainPanelContentVisible = (not IsGiftMail) and HaveMails
	self.ModelToImageVisible = not (IsGiftMail and HaveMails)

	if IsInBox then
		self.PanelEmptyText = MailTypeInfo[self.CurrentMailType].PanelEmptyText
	else
		self.PanelEmptyText = MailTypeInfo[self.CurrentMailType].OutBoxPanelEmptyText
	end

	if HaveMails and IsGiftMail then
		local FirstMailReaded = MailListData[1].Readed or false					--首封邮件已读
		self.PanelGiftMailContentVisible = IsOutBox or FirstMailReaded
		self.GiftMailEnvelopeVisible = IsInBox and ( not FirstMailReaded )
	else
		self.PanelGiftMailContentVisible = false
		self.GiftMailEnvelopeVisible = false
	end

	self.PanelEmptyVisible = not HaveMails
	self.GiftPageVisible = IsGiftMail
end

---@param MailType
function MailMainVM:SelectMailTab(MailType, IsSort)
	local MailTotalNum = MailMgr:GetMailTotalNum(MailType)
	self.CurrentMailType = MailType

	local MailListData = {}
	local CurrentMailCount
	if self.CurrentMailBoxType == MailDefine.MailBoxType.InBox then
		MailListData = MailMgr:GetCacheMailList(MailType, IsSort)
		self.MailAllAttchList = MailMgr:GetMailAllAttchList(MailListData) or {}
		self.BtnGetAllIsEnabled = #(self.MailAllAttchList) > 0
	elseif self.CurrentMailBoxType == MailDefine.MailBoxType.OutBox then 
		MailListData = MailMgr:GetSendMailList(MailDefine.MailType.Gift)
	end
	CurrentMailCount = #(MailListData)
	
	self.MailList:UpdateByValues(MailListData, nil)
	self:SetHaveMails( CurrentMailCount > 0, MailListData)

	local CurrentCountText
	if CurrentMailCount >= MailTotalNum  then
		CurrentCountText = RichTextUtil.GetText(tostring(CurrentMailCount), "dc5868" )
		self.TextTItleTipsVisible = true
	elseif  CurrentMailCount >= math.floor( MailTotalNum * 0.8 ) then
		CurrentCountText = RichTextUtil.GetText(tostring(CurrentMailCount), "d1906d" )
		self.TextTItleTipsVisible = true
	else
		self.TextTItleTipsVisible = false
		CurrentCountText = RichTextUtil.GetText(tostring(CurrentMailCount), "d5d5d5" )
	end
	local CountText = CurrentCountText .. "/" .. RichTextUtil.GetText(tostring(MailTotalNum), "d5d5d5" )
	self.TextSubtitle = MailTypeInfo[MailType].NameText .. CountText
end

-- 刷新对应的MailListItem
function MailMainVM:RefreshMailListItemVM(MailID)
	local MailData = MailMgr:GetMailData(MailID, self.CurrentMailType, self.CurrentMailBoxType)
	local ViewMode, _ = self.MailList:Find(function(Item) return Item.ID == MailID end )
	if ViewMode == nil or MailData == nil then
		self:NoFindMailData()
		return 
	end
	ViewMode:UpdateVM( MailData, ViewMode.UpdateVMParams)
end

-- 接受到已读过后刷新
function MailMainVM:RefreshCurrentMailList(ReadMailID)
	self:RefreshMailListItemVM(ReadMailID)
	-- Detail
	if ReadMailID == self.CurrentMailID  then
		local MailData = MailMgr:GetMailData(ReadMailID, self.CurrentMailType, self.CurrentMailBoxType)
		if MailData == nil then
			self:NoFindMailData()
			return 
		else
			if MailData.GreetingCardData ~= nil then
				self:RefreshAfterReceivedAttachment({ReadMailID})
			else
				self:DetailPanelMaturityDay(MailData)
			end
		end
	end
end

-- 接受到领取过后刷新
---@param MailIDList table   @领取成功的Id列表
function MailMainVM:RefreshAfterReceivedAttachment(MailIDList)
	for i = 1, #(MailIDList or {})  do
		self:RefreshMailListItemVM(MailIDList[i])
	end

	local MailListData = MailMgr:GetCacheMailList(self.CurrentMailType, false)
	self.MailAllAttchList = MailMgr:GetMailAllAttchList(MailListData) or {}
	self.BtnGetAllIsEnabled = #(self.MailAllAttchList) > 0

	-- Detail
	if table.contain(MailIDList, self.CurrentMailID) then
		local MailData = MailMgr:GetMailData(self.CurrentMailID, self.CurrentMailType, self.CurrentMailBoxType)
		if MailData == nil then
			self:NoFindMailData()
			return 
		else
			if self.CurrentMailType == MailDefine.MailType.Gift then
				self.PanelGiftMailContentVisible = true
				self.GiftMailEnvelopeVisible = false
				self.GiftTextFromName = ""
				MailMainVM:ShowMailDetail(self.CurrentMailID)
			end

			self:DetailPanelMaturityDay(MailData)
		end

		local VMItems = self.AttachsInfoList:GetItems() or {}
		self.BtnGetVisible = false
		self.BtnDeleteMailVisible = true
		for i = 1, #VMItems do
			VMItems[i].IconReceivedVisible = true
			VMItems[i].IsMask = true
		end
	end
end

-- 接受到删除过后刷新
function MailMainVM:RefreshAfterDeleteMail()
	self:SelectMailTab(self.CurrentMailType, false)
	self.MailListDelChanged = not self.MailListDelChanged
end

function MailMainVM:ShowMailDetail(MailID)
	local MailDate = MailMgr:GetMailData(MailID, self.CurrentMailType, self.CurrentMailBoxType)
	if nil == MailDate then
		self:NoFindMailData()
		return
	end
	self:MailPaperEmbellish(MailDate)
	local AttachCount = #(MailDate.Attachment or {} )
	local AttachsInfoList
	if AttachCount > 0 then
		self.ContentPanelVisible = false
		self.AttachContentPanelVisible = true
		self.LittleAttachPanelVisible = true
		self.LargeAttachPanelVisible = false
		AttachsInfoList = MailDate.Attachment
	else
		self.ContentPanelVisible = true
		self.AttachContentPanelVisible = false
		AttachsInfoList = { }
	end

	if AttachCount > 6 then
		self.LittleAttachPanelVisible = false
		self.LargeAttachPanelVisible = true
	end

	if AttachCount > 0 and MailDate.Attach then
		self.BtnGetVisible = true
		self.BtnDeleteMailVisible = false
		for i = 1, #AttachsInfoList do
			AttachsInfoList[i].IconReceivedVisible = false
			AttachsInfoList[i].IsMask = false
		end
	else
		self.BtnGetVisible = false
		self.BtnDeleteMailVisible = true
		for i = 1, #AttachsInfoList do
			-- 发件箱不显示 物品领取状态
			local IsInBox = self.CurrentMailBoxType == MailDefine.MailBoxType.InBox
			AttachsInfoList[i].IconReceivedVisible = true and IsInBox
			AttachsInfoList[i].IsMask = true and IsInBox
		end
	end

	self.AttachsInfoList:UpdateByValues(AttachsInfoList, nil)

	self:DetailPanelMaturityDay(MailDate)

	self.MailTitle = MailDate.Title or ""

	if self.CurrentMailType == MailDefine.MailType.Gift then
		self.ReceiverName = MailUtil.GetMailSenderName(MailDate.ReceiverID) or ""
	end

	self.MapHyperLink = {}
	self.MailContent = DialogueUtil.ParseLabel(MailDate.Text or "")

	if (MailDate.SenderID or 0) == 0 then
		self.SenderNameVisible = false
	else
		self.SenderNameVisible = true
		self.SenderName = MailUtil.GetMailSenderName(MailDate.SenderID) or ""
	end

	self.SendTimeText = TimeUtil.GetTimeFormat(LSTR(740001) , MailDate.SendTime)			
end

-- 有效期显示处理
function MailMainVM:DetailPanelMaturityDay(MailDate)
	local CurrentTime = TimeUtil.GetServerTime()
	--if not(MailDate.Attach) and MailDate.Readed then
	if (MailDate.ExpiresTime or 0) ~= 0 then
		local Time = MailDate.ExpiresTime - (MailDate.GetDataTime or CurrentTime)
		Time = Time > 60 and Time or 60
		local TimeText = LocalizationUtil.GetCountdownTimeForSimpleTime(Time, "m") or ""
		TimeText = string.format(LSTR(740016), TimeText)
		self.MaturityDayVisible  = true
		self.MaturityDayText = TimeText
	else
		self.MaturityDayVisible  = false
	end
end

-- 选中某邮件
function MailMainVM:SelectMail(MailID)
	self.CurrentMailID = MailID
	local IsShowMailDetail = true
	local MailDate = MailMgr:GetMailData(MailID, self.CurrentMailType, self.CurrentMailBoxType)
	if MailDate == nil then
		self:NoFindMailData()
		return
	end
	if self.CurrentMailType == MailDefine.MailType.Gift then
		local IsUnreadGreetingCard = MailDate.GreetingCardData ~= nil and MailDate.Readed == false
		if MailDate.Attach  or IsUnreadGreetingCard then
			self.PanelGiftMailContentVisible = false
			self.GiftMailEnvelopeVisible = true
			if IsUnreadGreetingCard then
				self.GiftTextFromName = string.format(LSTR(740025), MailUtil.GetMailSenderName(MailDate.SenderID)) --来自%s的贺卡
			else
				self.GiftTextFromName = string.format(LSTR(740012), MailUtil.GetMailSenderName(MailDate.SenderID)) --来自%s的礼物
			end
			IsShowMailDetail = false
		else
			self.PanelGiftMailContentVisible = true
			self.GiftMailEnvelopeVisible = false
			self.GiftTextFromName = ""
			self.GiftMailBtnCheckVisible = (self.CurrentMailBoxType == MailDefine.MailBoxType.InBox) or MailDate.GreetingCardData ~= nil
		end
	end

	if IsShowMailDetail then
		MailMainVM:ShowMailDetail(MailID)
	end
	if MailDate.Readed == false and MailDate.GreetingCardData == nil then
		MailMgr:ReadMail(MailID, self.CurrentMailType)
	end
end

-- 找不到指定邮件数据处理
function MailMainVM:NoFindMailData()
	self:RefreshAfterDeleteMail()
end

-- 开启商城赠礼邮件扩展视图
function MailMainVM:ShowStoreGiftMailExpandedView(FirstOpen)
	local MailData = _G.MailMgr:GetMailData(self.CurrentMailID, self.CurrentMailType, self.CurrentMailBoxType)
	if MailData ~= nil and self.CurrentMailType == MailDefine.MailType.Gift then
		if MailData.GreetingCardData ~= nil then
			self:ShowGreetingCardView(MailData, FirstOpen)
		else
			self:ShowStoreGiftMailView(MailData)
		end
	end
end

-- 开启商城赠礼邮件界面
function MailMainVM:ShowStoreGiftMailView(MailData)
	local Params = { }
	local GiftData = MailData.GiftData or {}
	Params.AlreadyReceived = not MailData.Attach
	Params.MailID = self.CurrentMailID
	Params.FriendID = tonumber(MailData.SenderID)
	Params.GoodID = GiftData.GoodID or 0
	Params.GiftMessage = GiftData.GiftMessage or ""
	Params.GiftNum = GiftData.GiftNum or 0
	Params.Style = GiftData.DecorativeStyle or 0
	Params.GiftTime = MailData.SendTime or 0

	_G.StoreMainVM:OnShowGiftMailPanel(true, Params)
end

-- 领取好友赠礼邮件
function MailMainVM:ReceiveGiftEmailAttachment()
	local AttachList = { self.CurrentMailID }
	MailMgr:GetMailAttch(AttachList, self.CurrentMailType)
end

-- 开启贺卡界面
function MailMainVM:ShowGreetingCardView(MailData, FirstOpen)
	local Params = { }
	Params.MailID = self.CurrentMailID
	Params.SenderID = tonumber(MailData.SenderID)
	Params.ReceiverID = tonumber(MailData.ReceiverID)
	Params.GiftMessage = MailData.Text or ""
	Params.StyleID = (MailData.GreetingCardData or {}).StyleID or 0
	Params.URL = (MailData.GreetingCardData or {}).URl or 0
	Params.GiftTime = MailData.SendTime or 0
	Params.Readed = MailData.Readed
	Params.FirstOpen = FirstOpen

	_G.GreetingCardWinVM:OpenBrowsingCardPanel(Params)
end

-- 收下贺卡
function MailMainVM:ReceiveGreetingCard()
	if _G.UIViewMgr:FindView(UIViewID.MailMainView) then
		MailMgr:ReadMail(self.CurrentMailID, self.CurrentMailType)
	end
end

function MailMainVM:StoreMapHyperLink(MapLinkData)
	table.insert(self.MapHyperLink, MapLinkData)
end

function MailMainVM:GetMapHyperLink(LinkID)
	local Value, _ = table.find_by_predicate( self.MapHyperLink,
		function(Item)
			return Item.LinkID == LinkID
		end
	)
	return Value
end

-- 信笺装饰
function MailMainVM:MailPaperEmbellish(MailDate)
	if self.CurrentMailType ~= MailDefine.MailType.System then
		return
	end

	local StyleData = MailMgr:GetStyleData(MailDate.StyleID)
	if StyleData ~= nil then
		self.TopCenterIconVisible = StyleData.TopCenterIcon ~= ""
		self.TopCenterIconPath = StyleData.TopCenterIcon
		self.SpineLetterInStyle = StyleData.SpineLetterIn
	end
end

--要返回当前类
return MailMainVM