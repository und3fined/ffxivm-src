---
--- Author: xingcaicao
--- DateTime: 2024-06-21 15:47
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TipsUtil = require("Utils/TipsUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local EventID = require("Define/EventID")
local CommonUtil = require("Utils/CommonUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIAdapterTreeView = require("UI/Adapter/UIAdapterTreeView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local LinkShellMgr = require("Game/Social/LinkShell/LinkShellMgr")
local LinkShellVM = require("Game/Social/LinkShell/LinkShellVM")
local LinkShellDefine = require("Game/Social/LinkShell/LinkShellDefine")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local NoSetTipsCfg = require("TableCfg/LinkshellNoSetTipsCfg")
local ChatDefine = require("Game/Chat/ChatDefine")

local LSTR = _G.LSTR
local FVector2D = _G.UE.FVector2D
local LINKSHELL_IDENTIFY = LinkShellDefine.LINKSHELL_IDENTIFY
local SetModuleType = LinkShellDefine.SetModuleType

local AdminTabsConfig = {
	{
        Name = LSTR(40007), --"基础信息" 
	},
	{
        Name = LSTR(40008), --"成员列表" 
	},
	{
        Name = LSTR(40009), --"申请列表" 
	},
}

local NormalTabsConfig = {
	{
        Name = LSTR(40007), --"基础信息" 
	},
	{
        Name = LSTR(40008), --"成员列表" 
	},
}

---@class LinkShellDetailPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ActivityListPanel UScaleBox
---@field BtnCopyNo UFButton
---@field BtnGoToChat CommBtnLView
---@field BtnManage CommBtnLView
---@field BtnNewsDetails UFButton
---@field BtnQuit CommBtnLView
---@field BtnReport UFButton
---@field BtnTop UFButton
---@field ComHorTabs CommHorTabsView
---@field ImgTopGrey UFImage
---@field PanelBaseInfo UFCanvasPanel
---@field PanelManage UFCanvasPanel
---@field PanelMemberList UFCanvasPanel
---@field TableViewActivity UTableView
---@field TableViewApplyList UTableView
---@field TableViewNews UTableView
---@field TextManifesto UFTextBlock
---@field TextName UFTextBlock
---@field TextNoActivity UFTextBlock
---@field TextNoManifesto UFTextBlock
---@field TextNoNews UFTextBlock
---@field TextNoNotice UFTextBlock
---@field TextNotice UFTextBlock
---@field TextNumber UFTextBlock
---@field TextRecruitSet UFTextBlock
---@field TextTitleAct UFTextBlock
---@field TextTitleManifesto UFTextBlock
---@field TextTitleNews UFTextBlock
---@field TextTitleNotice UFTextBlock
---@field TextTitleRecruit UFTextBlock
---@field TreeViewMemList UFTreeView
---@field AnimChangeSubMenu UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimUpdateContent UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LinkShellDetailPanelView = LuaClass(UIView, true)

function LinkShellDetailPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ActivityListPanel = nil
	--self.BtnCopyNo = nil
	--self.BtnGoToChat = nil
	--self.BtnManage = nil
	--self.BtnNewsDetails = nil
	--self.BtnQuit = nil
	--self.BtnReport = nil
	--self.BtnTop = nil
	--self.ComHorTabs = nil
	--self.ImgTopGrey = nil
	--self.PanelBaseInfo = nil
	--self.PanelManage = nil
	--self.PanelMemberList = nil
	--self.TableViewActivity = nil
	--self.TableViewApplyList = nil
	--self.TableViewNews = nil
	--self.TextManifesto = nil
	--self.TextName = nil
	--self.TextNoActivity = nil
	--self.TextNoManifesto = nil
	--self.TextNoNews = nil
	--self.TextNoNotice = nil
	--self.TextNotice = nil
	--self.TextNumber = nil
	--self.TextRecruitSet = nil
	--self.TextTitleAct = nil
	--self.TextTitleManifesto = nil
	--self.TextTitleNews = nil
	--self.TextTitleNotice = nil
	--self.TextTitleRecruit = nil
	--self.TreeViewMemList = nil
	--self.AnimChangeSubMenu = nil
	--self.AnimIn = nil
	--self.AnimUpdateContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LinkShellDetailPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnGoToChat)
	self:AddSubView(self.BtnManage)
	self:AddSubView(self.BtnQuit)
	self:AddSubView(self.ComHorTabs)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LinkShellDetailPanelView:OnInit()
	self.TableAdapterActivity = UIAdapterTableView.CreateAdapter(self, self.TableViewActivity)
    self.TreeAdapterMember = UIAdapterTreeView.CreateAdapter(self, self.TreeViewMemList)
    self.TableAdapterApplyList = UIAdapterTableView.CreateAdapter(self, self.TableViewApplyList)
    self.TableAdapterNews = UIAdapterTableView.CreateAdapter(self, self.TableViewNews)

	self.Binders = {
		{ "Name", 				UIBinderSetText.New(self, self.TextName) },
		{ "ID", 				UIBinderSetText.New(self, self.TextNumber) },
		{ "Manifesto", 			UIBinderSetText.New(self, self.TextManifesto) },
		{ "Notice", 			UIBinderSetText.New(self, self.TextNotice) },
		{ "IsEmptyAct", 		UIBinderSetIsVisible.New(self, self.TextNoActivity) },
		{ "IsEmptyManifesto", 	UIBinderSetIsVisible.New(self, self.TextNoManifesto) },
		{ "IsEmptyNotice", 		UIBinderSetIsVisible.New(self, self.TextNoNotice) },
		{ "IsCreator", 			UIBinderSetIsVisible.New(self, self.BtnManage, nil, true) },
		{ "IsCreator", 			UIBinderSetIsVisible.New(self, self.BtnQuit, true, true) },
		{ "IsStick", 			UIBinderSetIsVisible.New(self, self.ImgTopGrey) },

		{ "IsAdmin", 	UIBinderValueChangedCallback.New(self, nil, self.OnIsAdminChanged) },
		{ "RecruitSet", UIBinderValueChangedCallback.New(self, nil, self.OnRecruitSetChanged) },
		{ "ActVMList", 	UIBinderUpdateBindableList.New(self, self.TableAdapterActivity) },
	}

	self.BindersLinkShellVM = {
		{ "IsEmptyNews", 			UIBinderSetIsVisible.New(self, self.TextNoNews) },
		{ "LinkShellMemTreeVMList", UIBinderUpdateBindableList.New(self, self.TreeAdapterMember) },
		{ "CurMoreMemberItem", 		UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedCurMoreMemberItem) },

		{ "LinkShellApplyVMList", UIBinderUpdateBindableList.New(self, self.TableAdapterApplyList) },
		{ "PartNewsItemVMList", UIBinderUpdateBindableList.New(self, self.TableAdapterNews) },
	}
end

function LinkShellDetailPanelView:OnDestroy()

end

function LinkShellDetailPanelView:OnShow()
	self:InitConstText()
end

function LinkShellDetailPanelView:OnHide()
	self.ViewModel = nil 
	self:ClearData()
	UIViewMgr:HideView(UIViewID.ReportTips)
end

function LinkShellDetailPanelView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnCopyNo, 		self.OnClickButtonCopyNo)
    UIUtil.AddOnClickedEvent(self, self.BtnTop, 		self.OnClickButtonTop)
    UIUtil.AddOnClickedEvent(self, self.BtnNewsDetails, self.OnClickButtonNewsDetails)
    UIUtil.AddOnClickedEvent(self, self.BtnQuit, 		self.OnClickButtonQuit)
    UIUtil.AddOnClickedEvent(self, self.BtnManage, 		self.OnClickButtonManage)
    UIUtil.AddOnClickedEvent(self, self.BtnGoToChat,	self.OnClickButtonGoToChat)
    UIUtil.AddOnClickedEvent(self, self.BtnReport, 		self.OnClickButtonReport)

	UIUtil.AddOnSelectionChangedEvent(self, self.ComHorTabs, self.OnSelectionChangedTabs)
end

function LinkShellDetailPanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.LinkShellRefreshMemList, self.OnLinkShellMemListRefresh)
end

function LinkShellDetailPanelView:OnRegisterBinder()

end

function LinkShellDetailPanelView:InitConstText()
	if self.IsInitConstText then
		return
	end

	self.IsInitConstText = true

	self.TextTitleAct:SetText(LSTR(40055)) -- "主要活动"
	self.TextTitleRecruit:SetText(LSTR(40056)) -- "招募模式"
	self.TextTitleManifesto:SetText(LSTR(40057)) -- "招募宣言"
	self.TextTitleNotice:SetText(LSTR(40058)) -- "公告"
	self.TextTitleNews:SetText(LSTR(40059)) -- "最新动态"

	self.BtnQuit:SetButtonText(LSTR(40060)) -- "退出通讯贝"
	self.BtnManage:SetButtonText(LSTR(40061)) -- "编辑管理"
	self.BtnGoToChat:SetButtonText(LSTR(40062)) -- "通讯贝频道"
end

function LinkShellDetailPanelView:ClearData()
    LinkShellVM.LinkShellMemTreeVMList:Clear()
    LinkShellVM.LinkShellApplyVMList:Clear()
	LinkShellVM.NewsItemVMList:Clear()
	LinkShellVM.PartNewsItemVMList:Clear()
    LinkShellVM.IsChangingIdentify = false 

	self.ComHorTabs:CancelSelected()

	LinkShellVM.IsEmptyNews = true
end

function LinkShellDetailPanelView:GetNoSetTipsTexts(Type, IsAdmin)
	local Normal = self.NoSetTipsNormal
	local Admin = self.NoSetTipsAdmin
	if nil == Normal or nil == Admin then
		Normal = {}
		Admin = {}
		local CfgList = NoSetTipsCfg:FindAllCfg()

		for _, v in pairs(CfgList) do
			local ID = v.ID
			if ID then
				Normal[ID] = v.Desc2
				Admin[ID] = v.Desc1
			end
		end

		self.NoSetTipsNormal = Normal
		self.NoSetTipsAdmin = Admin
	end

	return (IsAdmin and Admin[Type] or Normal[Type]) or ""
end

function LinkShellDetailPanelView:SetViewModel( ViewModel )
	if ViewModel == self.ViewModel then
		return
	end

	self:ClearData()

	self.ViewModel = ViewModel 
	if nil == self.ViewModel then
		return
	end

	--- 查询通讯贝动态事件
	LinkShellMgr:QueryNews(LinkShellVM.CurLinkShellID)

	--重新绑定属性
	self:Re_RegisterBinders(ViewModel)

	--默认选择第一个Tab
	self.ComHorTabs:SetSelectedIndex(1)

	-- 播放动效
	self:PlayAnimation(self.AnimChangeSubMenu)
end

function LinkShellDetailPanelView:Re_RegisterBinders( )
	self:UnRegisterAllBinder()

	self:RegisterBinders(self.ViewModel, self.Binders)
	self:RegisterBinders(LinkShellVM, self.BindersLinkShellVM)
end

function LinkShellDetailPanelView:OnIsAdminChanged(IsAdmin)
	IsAdmin = IsAdmin == true

	local Idx = self.ComHorTabs:GetSelectedIndex() or 1
	if IsAdmin then
		self.ComHorTabs:UpdateItems(AdminTabsConfig, Idx)

	else
		local TabNum = #NormalTabsConfig
		if Idx > TabNum then
			Idx = 1
		end

		self.ComHorTabs:UpdateItems(NormalTabsConfig, Idx)
	end

	--未设置提示文本
	self.TextNoActivity:SetText(self:GetNoSetTipsTexts(SetModuleType.Act, IsAdmin))
	self.TextNoManifesto:SetText(self:GetNoSetTipsTexts(SetModuleType.Manifesto, IsAdmin) or "")
	self.TextNoNews:SetText(self:GetNoSetTipsTexts(SetModuleType.News, IsAdmin) or "")
	self.TextNoNotice:SetText(self:GetNoSetTipsTexts(SetModuleType.Notice, IsAdmin) or "")

	-- 举报按钮
	local IsVisibleReport = not IsAdmin
	UIUtil.SetIsVisible(self.BtnReport, IsVisibleReport,  IsVisibleReport)
end

function LinkShellDetailPanelView:OnRecruitSetChanged(Set)
	if nil == Set then
		return
	end

	local Item = table.find_by_predicate(LinkShellDefine.RecruitSetConfig, function(e) return e.Key == Set end) or {}
	self.TextRecruitSet:SetText(LSTR(Item.NameUkey))
end

function LinkShellDetailPanelView:OnValueChangedCurMoreMemberItem( MemberItem )
	local IsVisible = MemberItem ~= nil and self.ViewModel ~= nil
	if not IsVisible then
		UIViewMgr:HideView(UIViewID.CommStorageTipsView)
		return
	end

	-- 按钮状态
	local SelfIdentify = (self.ViewModel or {}).Identify
	local MemIdentify = (LinkShellVM.MoreMemVM or {}).Identify

	--移出通讯贝、撤销管理员、任命管理员、移交总管理身份
	local b1, b2, b3, b4 = false, false, false, false

    if SelfIdentify == LINKSHELL_IDENTIFY.CREATOR and MemIdentify == LINKSHELL_IDENTIFY.MANAGER then
		b1, b2, b4 = true, true, true 

    elseif SelfIdentify == LINKSHELL_IDENTIFY.CREATOR and MemIdentify == LINKSHELL_IDENTIFY.NORMAL then
		b1, b3, b4 = true, true, true 

    elseif SelfIdentify == LINKSHELL_IDENTIFY.MANAGER and MemIdentify == LINKSHELL_IDENTIFY.NORMAL then
		b1 = true
	end

	local Data = {}
	if b1 then
		-- "移除通讯贝"
		table.insert(Data, {Content = LSTR(40063), ClickItemCallback = self.OnClickButtonRemoveMem, View = self})
	end

	if b2 then
		-- "撤销管理员"
		table.insert(Data, {Content = LSTR(40064), ClickItemCallback = self.OnClickButtonRemoveManager, View = self})
	end

	if b3 then
		-- "任命管理员"
		table.insert(Data, {Content = LSTR(40065), ClickItemCallback = self.OnClickButtonAppointManager, View = self})
	end

	if b4 then
		-- "移交总管身份"
		table.insert(Data, {Content = LSTR(40066), ClickItemCallback = self.OnClickButtonTransferCreator, View = self})
	end

	if #Data <= 0 then
		return
	end

	local BtnSize = UIUtil.CanvasSlotGetSize(MemberItem.BtnMore)
	local ClickedParams = {View = self, HidePopUpBGCallback = self.OnClickedHidePopUpBg}
	TipsUtil.ShowStorageBtnsTips(Data, MemberItem.BtnMore, FVector2D(-BtnSize.X, 0), FVector2D(1, 0), false, ClickedParams)
end

function LinkShellDetailPanelView:OnClickedHidePopUpBg()
	UIViewMgr:HideView(UIView.CommStorageTipsView)
	LinkShellVM:SetCurMoreMemberItem()
end

function LinkShellDetailPanelView:OnSelectionChangedTabs(Index)
    if nil == self.ViewModel then return end

	local LinkShellID = self.ViewModel.ID
	if nil == LinkShellID then
		return
	end

	--隐藏More信息（成员操作按钮）
	LinkShellVM:SetCurMoreMemberItem()

	if Index == 1 then
		--请求详情
		LinkShellMgr:SendGetLinkShellDetailReq(LinkShellID)

	elseif Index == 2 then
		LinkShellVM.LinkShellMemTreeVMList:Clear()

		--请求成员列表
        LinkShellMgr:SendMsgGetLinkShellMembersReq(LinkShellID)

	elseif Index == 3 then
		LinkShellVM.LinkShellApplyVMList:Clear()

        --请求申请列表
        LinkShellMgr:SendMsgGetReqJoinListReq(LinkShellID)
	end

	UIUtil.SetIsVisible(self.PanelBaseInfo, Index == 1)
	UIUtil.SetIsVisible(self.PanelMemberList, Index == 2)
	UIUtil.SetIsVisible(self.PanelManage, Index == 3)

	-- 播放动效
	self:PlayAnimation(self.AnimUpdateContent)
end

-------------------------------------------------------------------------------------------------------
---Client Event CallBack 

function LinkShellDetailPanelView:OnLinkShellMemListRefresh()
    self.TreeAdapterMember:ExpandAll()
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function LinkShellDetailPanelView:OnClickButtonCopyNo()
	local Text = string.format("%s#%s", self.TextName:GetText(), self.TextNumber:GetText())
    CommonUtil.ClipboardCopy(Text)
    MsgTipsUtil.ShowTips(LSTR(40067)) -- "通讯贝信息已复制，可于聊天框粘贴分享"
end

function LinkShellDetailPanelView:OnClickButtonTop()
	local ViewModel = self.ViewModel
	if nil == ViewModel then
		return
	end

	if ViewModel.IsStick then
		MsgTipsUtil.ShowTips(LSTR(40068)) -- "通讯贝置顶中"
		return
	end

	local LinkShellID = self.ViewModel.ID
	if LinkShellID then
		LinkShellMgr:SendStickLinkShell(LinkShellID)
	end
end

function LinkShellDetailPanelView:OnClickButtonNewsDetails()
	UIViewMgr:ShowView(UIViewID.LinkShellNewsWin, self:GetNoSetTipsTexts(SetModuleType.News, (self.ViewModel or {}).IsAdmin))
end

function LinkShellDetailPanelView:OnClickButtonQuit()
	if nil == self.ViewModel then
		return
	end

	local LinkShellID = self.ViewModel.ID
	MsgBoxUtil.ShowMsgBoxTwoOp(
		nil, 
		LSTR(10004), --"提 示"
		LSTR(40069), --"是否退出通讯贝？"
		function() 
			LinkShellMgr:SendMsgLeaveLinkShellReq(LinkShellID)
		end,
		nil, LSTR(10003), LSTR(10010)) -- "取 消"、"退 出"
end

function LinkShellDetailPanelView:OnClickButtonManage()
	UIViewMgr:ShowView(UIViewID.LinkShellManageWin, self.ViewModel)
end

function LinkShellDetailPanelView:OnClickButtonGoToChat()
    if nil == self.ViewModel then
        return
    end

    _G.ChatMgr:GoToGroupChatView(self.ViewModel.ID, ChatDefine.OpenSource.LinkShellWin, self:GetViewID())
end

function LinkShellDetailPanelView:OnClickButtonReport()
	local ViewModel = self.ViewModel
    if nil == ViewModel then
        return
    end

	local Params = { 
		GroupID = ViewModel.ID, 
		GroupName = ViewModel.Name,
		ReportContentList = {
			Announcement = ViewModel.Notice,
			RecruitmentSlogan = ViewModel.Manifesto,
		}
	}

	_G.ReportMgr:OpenViewByLinkShell(Params)
end

------------------------------
--- 成员列表 

function LinkShellDetailPanelView:OnClickButtonRemoveMem()
	local VM = LinkShellVM.MoreMemVM
    if nil == VM then
        return
    end

	local Name = VM.Name or ""
	local RoleID = VM.RoleID

	LinkShellVM:SetCurMoreMemberItem()

	-- '是否确认将玩家<span color="#6FB1E9FF">%s</>移出通讯贝？'
    local Message = string.format(LSTR(40070), Name or "")
    MsgBoxUtil.ShowMsgBoxTwoOp(
        self, 
		LSTR(10004), --"提 示"
        Message,
        function() 
            LinkShellMgr:SendKickOff(LinkShellVM.CurLinkShellID, RoleID)
        end,
		nil, LSTR(10003), LSTR(10002)) -- "取 消"、"确 认"
end

function LinkShellDetailPanelView:OnClickButtonRemoveManager()
	local VM = LinkShellVM.MoreMemVM
    if nil == VM then
        return
    end

	local Name = VM.Name or ""
	local RoleID = VM.RoleID

	LinkShellVM:SetCurMoreMemberItem()

	--'是否确认撤销玩家<span color="#6FB1E9FF">%s</>的管理员身份？'
    local Message = string.format(LSTR(40071), Name or "")
    MsgBoxUtil.ShowMsgBoxTwoOp(
        self, 
		LSTR(10004), --"提 示"
        Message,
        function() 
			LinkShellMgr:SendSetManager(LinkShellVM.CurLinkShellID, RoleID, false)
        end,
		nil, LSTR(10003), LSTR(10002)) -- "取 消"、"确 认"
end

function LinkShellDetailPanelView:OnClickButtonAppointManager()
	local VM = LinkShellVM.MoreMemVM
    if VM then
		LinkShellMgr:SendSetManager(LinkShellVM.CurLinkShellID, VM.RoleID, true)
		LinkShellVM:SetCurMoreMemberItem()
	end
end

function LinkShellDetailPanelView:OnClickButtonTransferCreator()
	local VM = LinkShellVM.MoreMemVM
    if nil == VM then
        return
    end

	UIViewMgr:HideView(UIViewID.CommStorageTipsView)

	local Name = VM.Name or ""
	local RoleID = VM.RoleID

	-- '是否确认将总管理身份转移给玩家<span color="#6FB1E9FF">%s</>？确认后将无法撤回'
    local Message = string.format(LSTR(40072), Name or "")
    MsgBoxUtil.ShowMsgBoxTwoOp(
        self, 
		LSTR(10004), --"提 示"
        Message,
        function() 
            LinkShellMgr:SendTransferCreator(LinkShellVM.CurLinkShellID, RoleID)
			LinkShellVM:SetCurMoreMemberItem()
        end,
        function()
			LinkShellVM:SetCurMoreMemberItem()
		end, 
		LSTR(10003), -- "取 消"
		LSTR(10002), -- "确 认"
		{
			CloseClickCB = function()
				LinkShellVM:SetCurMoreMemberItem()
			end
		 
		})
end

return LinkShellDetailPanelView