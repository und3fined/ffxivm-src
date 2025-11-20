local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIViewID = require("Define/UIViewID")
local GreetingCardDefine = require("Game/StarlightCelebration/GreetingCard/GreetingCardDefine")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local GreetingCardStyleCfg = require("TableCfg/GreetingCardStyleCfg")

local UIBindableList = require("UI/UIBindableList")

local CardFriendItemVM = require("Game/StarlightCelebration/GreetingCard/VM/ItemVM/CardFriendItemVM")
local CardStyleItemVM = require("Game/StarlightCelebration/GreetingCard/VM/ItemVM/CardStyleItemVM")
local FriendVM = require("Game/Social/Friend/FriendVM")

local ShowMode = GreetingCardDefine.ShowMode
local LSTR
local UIViewMgr
local FLOG_ERROR

---@class GreetingCardWinVM : UIViewModel
local GreetingCardWinVM = LuaClass(UIViewModel)

---Ctor
function GreetingCardWinVM:Ctor()
	self.FriendItemVMList = UIBindableList.New(CardFriendItemVM)
	self.FriendListCommEmptyVisible = false

	self.CardStyleList = UIBindableList.New(CardStyleItemVM)
	self.ShowMode = ShowMode.ChoosingFriends
	self.CurFriendRoleID = 0
	self.BrowsingCardData = nil
	self.SelectedCardStyleIndex = 1
end

function GreetingCardWinVM:OnInit()
end

function GreetingCardWinVM:OnBegin()
	LSTR = _G.LSTR
	UIViewMgr = _G.UIViewMgr
	FLOG_ERROR = _G.FLOG_ERROR

	local CardStyleListData = GreetingCardStyleCfg:FindAllCfg()
	for i = 1, #CardStyleListData do
		CardStyleListData[i].Islock = false
	end
	self.CardStyleList:UpdateByValues(CardStyleListData)
	GreetingCardWinVM:SwitchCardStyle(1)
end

function GreetingCardWinVM:OnEnd()
end

function GreetingCardWinVM:OnShutdown()
end

function GreetingCardWinVM:UpdateFriendList()
	local FriendVMList = FriendVM.ShowingFriendEntryVMList
	if nil == FriendVMList then
		FLOG_ERROR("[GreetingCardWinVM:UpdateFriendList] FriendVM.ShowingFriendEntryVMList is nil")
		return
	end
	local NewFriendVMList = {}
	for _, FriendItem in ipairs(FriendVMList.Items) do
		if not _G.FriendMgr:IsInBlackList(FriendItem.RoleID) then
			table.insert(NewFriendVMList, FriendItem)
			_G.RoleInfoMgr:QueryRoleSimple(FriendItem.RoleID, nil, self, false)
		end
	end
	self.FriendItemVMList:UpdateByValues(NewFriendVMList)
	self.FriendListCommEmptyVisible = #self.FriendItemVMList:GetItems() == 0
end


--- 检查当前选中风格Index是否解锁
function GreetingCardWinVM:SwitchCardStyle(Index)
	local Items = self.CardStyleList:GetItems()
	for i = 1, #Items do
		Items[i]:SetIsSelected(false)
	end
	if Items[Index] then
		Items[Index]:SetIsSelected(true)
		self.SelectedCardStyleIndex = Index
	else
		self.SelectedCardStyleIndex = 1
		FLOG_ERROR(" GreetingCardWinVM CardStyleList Items[Index] is nil  " .. tostring(Index))
	end
end


function GreetingCardWinVM:OpenChoosingFriendsPanel(StarlightViewEnter)
	self.ShowMode = ShowMode.ChoosingFriends 
	if not UIViewMgr:FindVisibleView(UIViewID.GreetingCardWinView) then 
		UIViewMgr:ShowView(UIViewID.GreetingCardWinView, { StarlightViewEnter = StarlightViewEnter })
	end
end

function GreetingCardWinVM:OpenEditingCardPanel(FriendRoleID)
	if (FriendRoleID or 0) == 0 then
		MsgTipsUtil.ShowTips(LSTR(1670019))    -- "未找到玩家信息"
		return
	end
	self.CurFriendRoleID = FriendRoleID
	self.ShowMode = ShowMode.EditingCard
	if not UIViewMgr:FindVisibleView(UIViewID.GreetingCardWinView) then
		UIViewMgr:ShowView(UIViewID.GreetingCardWinView)
	end
end

function GreetingCardWinVM:OpenBrowsingCardPanel(BrowsingCardData)
	self.ShowMode = ShowMode.BrowsingCard
	local ReceiverName = ""
	local SenderRoleVM = {}
	local SenderID = tonumber(BrowsingCardData.SenderID)
	local ReceiverID = tonumber(BrowsingCardData.ReceiverID)
	if (SenderID or 0) ~= 0 then
		SenderRoleVM = _G.RoleInfoMgr:FindRoleVM(SenderID, true) or {}
	end
	if (ReceiverID or 0) ~= 0 then
		local RoleVM = _G.RoleInfoMgr:FindRoleVM(ReceiverID, true) or {}
		ReceiverName = RoleVM.Name or ""
	end

	self.BrowsingCardData = { SenderRoleVM = SenderRoleVM, SenderName = SenderRoleVM.Name or "", ReceiverName = ReceiverName, GiftMessage = BrowsingCardData.GiftMessage or "", Readed = BrowsingCardData.Readed,
								GiftTime = BrowsingCardData.GiftTime or 0, StyleID = BrowsingCardData.StyleID or 1, URL = BrowsingCardData.URL or "" }
	if not UIViewMgr:FindVisibleView(UIViewID.GreetingCardWinView) then
		UIViewMgr:ShowView(UIViewID.GreetingCardWinView, { FirstOpenBrowsing = BrowsingCardData.FirstOpen })
	end
end

return GreetingCardWinVM