---
--- Author: xingcaicao
--- DateTime: 2023-06-29 19:51
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local SidebarVM = require("Game/Sidebar/VM/SidebarVM")
local SidebarDefine = require("Game/Sidebar/SidebarDefine")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local MagicCardTourneyMgr = require("Game/MagicCardTourney/MagicCardTourneyMgr")
local LinkShellMgr = require("Game/Social/LinkShell/LinkShellMgr")
local FriendMgr = require("Game/Social/Friend/FriendMgr")
local FishNoteMgr = require("Game/FishNotes/FishNotesMgr")
local TeamDefine = require("Game/Team/TeamDefine")
local WBL = _G.UE.UWidgetBlueprintLibrary
local UKismetInputLibrary = _G.UE.UKismetInputLibrary
local UWidgetLayoutLibrary = _G.UE.UWidgetLayoutLibrary
local USlateBlueprintLibrary = _G.UE.USlateBlueprintLibrary
local TimeUtil = require("Utils/TimeUtil")

local SidebarType = SidebarDefine.SidebarType

---@class SidebarMainWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnMask UFButton
---@field BtnUnfold UFButton
---@field ImgBg2 UFImage
---@field ImgBg3 UFImage
---@field PanelFold UFCanvasPanel
---@field PanelUnfold UFCanvasPanel
---@field SidebarItemSingle SidebarItemView
---@field TableViewSidebar UTableView
---@field AnimFold UWidgetAnimation
---@field AnimInXX UWidgetAnimation
---@field AnimOutXX UWidgetAnimation
---@field AnimUnfold UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SidebarMainWinView = LuaClass(UIView, true)

function SidebarMainWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnMask = nil
	--self.BtnUnfold = nil
	--self.ImgBg2 = nil
	--self.ImgBg3 = nil
	--self.PanelFold = nil
	--self.PanelUnfold = nil
	--self.SidebarItemSingle = nil
	--self.TableViewSidebar = nil
	--self.AnimFold = nil
	--self.AnimInXX = nil
	--self.AnimOutXX = nil
	--self.AnimUnfold = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SidebarMainWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SidebarItemSingle)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SidebarMainWinView:OnInit()
	self.TableAdapterSidebar = UIAdapterTableView.CreateAdapter(self, self.TableViewSidebar, self.OnSelectItemChanged, true)

	self.Binders = {
		{ "ItemNum", UIBinderValueChangedCallback.New(self, nil, self.OnItemNumChanged) },
		{ "FirstItemVM", UIBinderValueChangedCallback.New(self, nil, self.OnFirstItemVMChanged) },
		{ "SidebarItemVMList", UIBinderUpdateBindableList.New(self, self.TableAdapterSidebar) },
	}
end

function SidebarMainWinView:OnDestroy()
	self.IsDraging = false
end

function SidebarMainWinView:ShowView(Params)
	self.Super:ShowView(Params)
	self.SidebarItemSingle:ResetRegisterBinder(SidebarVM.FirstItemVM)
end

---self.Params需要为nil,不然会影响 self.SidebarItemSingle 的 Binders 注册
function SidebarMainWinView:OnShow()
	self.IsDraging = false
	UIUtil.SetIsVisible(self.PanelFold, true)
	UIUtil.SetIsVisible(self.PanelUnfold, false)

	self.SidebarItemSingle:HideTypeName()
end

function SidebarMainWinView:OnHide()
	self.IsDraging = false
end

function SidebarMainWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnMask, self.OnClickButtonMask)
end

function SidebarMainWinView:OnRegisterBinder()
	self:RegisterBinders(SidebarVM, self.Binders)
end

function SidebarMainWinView:OnSelectItemChanged(Index, ItemData, ItemView)
	if nil == ItemData then
		return
	end

	self:OpenSideBarDetailWin(ItemData)
end

function SidebarMainWinView:OnItemNumChanged(ItemNum)
	ItemNum = ItemNum or 0
	if ItemNum <= 0 then
		return
	end

	UIUtil.SetIsVisible(self.ImgBg2, ItemNum > 1)
	UIUtil.SetIsVisible(self.ImgBg3, ItemNum > 2)
end

function SidebarMainWinView:OnFirstItemVMChanged(FirstItemVM)
	local SingleItemView = self.SidebarItemSingle
	if SingleItemView:GetIsShowView() then
		SingleItemView:ResetRegisterBinder(FirstItemVM)
	end
end

function SidebarMainWinView:OpenSideBarDetailWin( ItemVM )
	if nil == ItemVM then
		return
	end

	self:Hide()

	local StartTime = ItemVM.StartTime
	local CountDown = ItemVM.CountDown

	local Type = ItemVM.Type
	if Type == SidebarType.LinkShellInvite then	-- 通讯贝邀请
		LinkShellMgr:OpenLinkShellInviteSidebar(StartTime, CountDown, Type)

	elseif Type == SidebarType.FriendInvite then -- 好友邀请
		FriendMgr:OpenFriendRequestSidebar(StartTime, CountDown, Type)

	elseif Type == SidebarType.NewbieInvite then -- 指导者新人邀请
		_G.NewbieMgr:OpenChatInvitationWinPanel(ItemVM.TransData)

	elseif Type == SidebarType.TeamInvite then -- 组队邀请
		local Params = ItemVM.TransData or {}
		Params.StartTime = StartTime
		Params.CountDown = CountDown

		UIViewMgr:ShowView(UIViewID.SidebarTeamInvite, Params)
	elseif Type == SidebarType.PWorldQuestGiveUp then -- 副本放弃任务
		UIViewMgr:ShowView(UIViewID.SidebarGiveUpTaskWin, {ShowType = TeamDefine.VoteType.TASK_GIVEUP})

	elseif Type == SidebarType.PWorldQuestKick then -- 副本驱逐队员
		UIViewMgr:ShowView(UIViewID.SidebarGiveUpTaskWin, {ShowType = TeamDefine.VoteType.EXPEL_PLAYER})

	elseif Type == SidebarType.PWorldQuestMVP then -- 副本MVP
		UIViewMgr:ShowView(UIViewID.PWorldVoteBest, {ShowType = TeamDefine.VoteType.BEST_PLAYER})

	elseif Type == SidebarType.PWorldMatch then -- 副本匹配
		_G.PWorldMatchMgr:ShowMatchView(true)
	elseif Type == SidebarType.GatherClock or Type == SidebarType.MinerClock then -- 采集笔记闹钟
		local TransData = ItemVM.TransData or {}
		_G.GatheringLogMgr:OpenGatheringLogAlarmSidebar(StartTime, CountDown, TransData, Type)
	elseif Type == SidebarType.PWorldEnterConfirm then -- 副本确认
		UIViewMgr:ShowView(UIViewID.PWorldConfirm, {bFromSidebar=true})
	elseif Type == SidebarType.MagicCardMatchConfirm then -- 幻卡大赛匹配确认
		local Params = MagicCardTourneyMgr:GetMatchConfirmParams(true)
		UIViewMgr:ShowView(UIViewID.PWorldConfirm, Params)
	elseif Type == SidebarType.EntourageEnterConfirm then -- 随从副本确认
		UIViewMgr:ShowView(UIViewID.EntourageConfirm)
	elseif Type == SidebarType.MountInvite then -- 坐骑邀请
		local Params = ItemVM.TransData or {}
		_G.MountMgr:OpenApplyNotifySidebar(StartTime, CountDown, Params.RoleID, Type)
	elseif Type == SidebarType.FishClock then --钓鱼闹钟
		local TransData = ItemVM.TransData or {}
		FishNoteMgr:OpenFishClockRequestSidebar(StartTime,CountDown, TransData, Type)
	elseif Type == SidebarType.ArmyInvite then --部队邀请
		local Params = ItemVM.TransData or {}
		Params.StartTime = StartTime
		Params.CountDown = CountDown
		Params.Type = Type
		UIViewMgr:ShowView(UIViewID.SidebarCommon, Params)
	elseif Type == SidebarType.Death then --死亡復活
		_G.ReviveMgr:ShowReviveMsgBox()
	elseif Type == SidebarType.Revive then --他人救助
		UIViewMgr:ShowView(UIViewID.BeReviveView)
	elseif Type == SidebarType.MeetTradeRequest then --交易
		local TransData = ItemVM.TransData or {}
		_G.MeetTradeMgr:OpenMeetTradeRequestSidebar(StartTime, CountDown, TransData, Type)
	elseif Type == SidebarType.PVPDuel then
		_G.WolvesDenPierMgr:ShowDuelPanel()
	elseif Type == SidebarType.ChocoboBabyClaim then
		_G.ChocoboMgr:OpenChocoboBabyClaimSidebar(StartTime, CountDown, Type)
	elseif Type == SidebarType.ArmySignInvite then --部队署名邀请
		local Params = ItemVM.TransData or {}
		Params.StartTime = StartTime
		Params.CountDown = CountDown
		Params.Type = Type
		UIViewMgr:ShowView(UIViewID.SidebarCommon, Params)

	elseif Type == SidebarType.PrivateChat then -- 私聊
		UIViewMgr:ShowView(UIViewID.SidebarPrivateChat, ItemVM)
	end
end

-------------------------------------------------------------------------------------------------------
---Client Event CallBack 

function SidebarMainWinView:OnClickButtonMask()
	UIUtil.SetIsVisible(self.PanelUnfold, false)
	UIUtil.SetIsVisible(self.PanelFold, true)

	-- self:PlayAnimation(self.AnimFold)
end

function SidebarMainWinView:OnClickButtonUnfold()
	local AudioUtil = require("Utils/AudioUtil")
	AudioUtil.LoadAndPlayUISound("/Game/WwiseAudio/Events/UI/UI_SYS/New/Play_FM_SideBar.Play_FM_SideBar")
	local ItemNum = SidebarVM.ItemNum
	if ItemNum <= 0 then
		return
	end

	if ItemNum == 1 then
		self:OpenSideBarDetailWin(SidebarVM.FirstItemVM)
		return
	end

	UIUtil.SetIsVisible(self.PanelFold, false)
	UIUtil.SetIsVisible(self.PanelUnfold, true)

	-- self:PlayAnimation(self.AnimUnfold)
end

function SidebarMainWinView:OnMouseButtonDown(_, MouseEvent)
	self.IsDraging = true
	self.LastDragTime = TimeUtil.GetServerTimeMS()

	return WBL.Handled()
end

function SidebarMainWinView:OnMouseButtonUp()
	if self.IsDraging then
		self.IsDraging = false
		local NowTime = TimeUtil.GetServerTimeMS()
		if NowTime - self.LastDragTime < 300 then
			self:OnClickButtonUnfold()
		end
	end

	return WBL.Handled()
end

function SidebarMainWinView:OnMouseMove(_, MouseEvent)
	if not self.IsDraging then
		return WBL.Handled()
	end

	local MousePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	local SelfGeometry = UWidgetLayoutLibrary.GetViewportWidgetGeometry(self)
	local ViewportMousePos = USlateBlueprintLibrary.AbsoluteToLocal(SelfGeometry, MousePosition)
	local LimitPanelSizeY = UIUtil.GetWidgetSize(self.PanelUnfold).Y
	local FoldPanelSizeY = UIUtil.GetWidgetSize(self.PanelFold).Y
	local MousePosY =  ViewportMousePos.Y 
	if MousePosY < FoldPanelSizeY / 2 then
		MousePosY = FoldPanelSizeY / 2
	end

	if MousePosY > LimitPanelSizeY - FoldPanelSizeY  then
		MousePosY = LimitPanelSizeY - FoldPanelSizeY / 2
	end

	UIUtil.CanvasSlotSetPosition(self.PanelFold, UE.FVector2D(0, MousePosY - LimitPanelSizeY / 2))
	return WBL.Handled()
end

return SidebarMainWinView