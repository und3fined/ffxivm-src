---
--- Author: xingcaicao
--- DateTime: 2024-06-21 15:48
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommonUtil = require("Utils/CommonUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local LinkShellMgr = require("Game/Social/LinkShell/LinkShellMgr")
local LinkShellVM = require("Game/Social/LinkShell/LinkShellVM")
local NoSetTipsCfg = require("TableCfg/LinkshellNoSetTipsCfg")
local LinkShellDefine = require("Game/Social/LinkShell/LinkShellDefine")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local LSTR = _G.LSTR
local SetModuleType = LinkShellDefine.SetModuleType

---@class LinkShellInviteDetailPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ActivityListPanel UScaleBox
---@field BtnAccept CommBtnLView
---@field BtnCopyNo UFButton
---@field BtnGoToChat UFButton
---@field BtnRefuse CommBtnLView
---@field BtnReport UFButton
---@field TableViewActivity UTableView
---@field TableViewNews UTableView
---@field TextInviter UFTextBlock
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
---@field AnimChangeSubMenu UWidgetAnimation
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LinkShellInviteDetailPanelView = LuaClass(UIView, true)

function LinkShellInviteDetailPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ActivityListPanel = nil
	--self.BtnAccept = nil
	--self.BtnCopyNo = nil
	--self.BtnGoToChat = nil
	--self.BtnRefuse = nil
	--self.BtnReport = nil
	--self.TableViewActivity = nil
	--self.TableViewNews = nil
	--self.TextInviter = nil
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
	--self.AnimChangeSubMenu = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LinkShellInviteDetailPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnAccept)
	self:AddSubView(self.BtnRefuse)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LinkShellInviteDetailPanelView:OnInit()
	self.TableAdapterActivity = UIAdapterTableView.CreateAdapter(self, self.TableViewActivity)
    self.TableAdapterNews = UIAdapterTableView.CreateAdapter(self, self.TableViewNews)

	--未设置提示文本
	self:SetNoSetTipsTexts()

	self.Binders = {
		{ "Name", 				UIBinderSetText.New(self, self.TextName) },
		{ "ID", 				UIBinderSetText.New(self, self.TextNumber) },
		{ "InviterName", 		UIBinderSetText.New(self, self.TextInviter) },
		{ "Manifesto", 			UIBinderSetText.New(self, self.TextManifesto) },
		{ "Notice", 			UIBinderSetText.New(self, self.TextNotice) },
		{ "IsEmptyAct", 		UIBinderSetIsVisible.New(self, self.TextNoActivity) },
		{ "IsEmptyManifesto", 	UIBinderSetIsVisible.New(self, self.TextNoManifesto) },
		{ "IsEmptyNotice", 		UIBinderSetIsVisible.New(self, self.TextNoNotice) },

		{ "RecruitSet", 	UIBinderValueChangedCallback.New(self, nil, self.OnRecruitSetChanged) },
		{ "ActVMList", 		UIBinderUpdateBindableList.New(self, self.TableAdapterActivity) },
	}

	self.BindersLinkShellVM = {
		{ "IsEmptyNews", UIBinderSetIsVisible.New(self, self.TextNoNews) },
		{ "PartNewsItemVMList", UIBinderUpdateBindableList.New(self, self.TableAdapterNews) },
	}
end

function LinkShellInviteDetailPanelView:OnDestroy()

end

function LinkShellInviteDetailPanelView:OnShow()
	self:InitConstText()
end

function LinkShellInviteDetailPanelView:OnHide()
	self:ClearData()
end

function LinkShellInviteDetailPanelView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnCopyNo, self.OnClickButtonCopyNo)
    UIUtil.AddOnClickedEvent(self, self.BtnGoToChat, self.OnClickButtonGoToChat)
    UIUtil.AddOnClickedEvent(self, self.BtnReport, self.OnClickButtonReport)
    UIUtil.AddOnClickedEvent(self, self.BtnRefuse, self.OnClickButtonRefuse)
    UIUtil.AddOnClickedEvent(self, self.BtnAccept, self.OnClickButtonAccept)
end

function LinkShellInviteDetailPanelView:OnRegisterGameEvent()

end

function LinkShellInviteDetailPanelView:OnRegisterBinder()

end

function LinkShellInviteDetailPanelView:InitConstText()
	if self.IsInitConstText then
		return
	end

	self.IsInitConstText = true

	self.TextTitleAct:SetText(LSTR(40055)) -- "主要活动"
	self.TextTitleRecruit:SetText(LSTR(40056)) -- "招募模式"
	self.TextTitleManifesto:SetText(LSTR(40057)) -- "招募宣言"
	self.TextTitleNotice:SetText(LSTR(40058)) -- "公告"
	self.TextTitleNews:SetText(LSTR(40059)) -- "最新动态"

	self.BtnRefuse:SetButtonText(LSTR(40074)) -- "拒绝邀请"
	self.BtnAccept:SetButtonText(LSTR(40075)) -- "接受邀请"
end

function LinkShellInviteDetailPanelView:ClearData()
	self.InviterRoleID = nil 
	self.LinkShellID = nil 
	LinkShellVM.NewsItemVMList:Clear()
	LinkShellVM.PartNewsItemVMList:Clear()

	LinkShellVM.IsEmptyNews = true
end

function LinkShellInviteDetailPanelView:SetNoSetTipsTexts()
	local StrNoActivity = ""
	local StrNoManifesto = ""
	local StrNoNews = ""
	local StrNoNotice = ""
	local CfgList = NoSetTipsCfg:FindAllCfg()

	for _, v in pairs(CfgList) do
		local ID = v.ID
		if ID == SetModuleType.Act then
			StrNoActivity = v.Desc2 or "" 

		elseif ID == SetModuleType.Manifesto then
			StrNoManifesto = v.Desc2 or ""

		elseif ID == SetModuleType.News then
			StrNoNews = v.Desc2 or ""

		elseif ID == SetModuleType.Notice then
			StrNoNotice = v.Desc2 or ""
		end
	end

	self.TextNoActivity:SetText(StrNoActivity)
	self.TextNoManifesto:SetText(StrNoManifesto)
	self.TextNoNews:SetText(StrNoNews)
	self.TextNoNotice:SetText(StrNoNotice)
end

function LinkShellInviteDetailPanelView:SetViewModel( ViewModel )
	self:ClearData()

	if nil == ViewModel then
		return
	end

	self.InviterRoleID = ViewModel.InviterRoleID
	local LinkShellID = ViewModel.ID
	self.LinkShellID = LinkShellID	

	if nil == LinkShellID then
		return
	end

	--- 查询通讯贝动态事件
	LinkShellMgr:QueryNews(LinkShellID, 3)

    -- 请求详细信息
    LinkShellMgr:SendGetLinkShellDetailReq(LinkShellID)

	--重新绑定属性
	self:Re_RegisterBinders(ViewModel)

	-- 播放动效
	self:PlayAnimation(self.AnimChangeSubMenu)
end

function LinkShellInviteDetailPanelView:Re_RegisterBinders( ViewModel )
	self:UnRegisterAllBinder()

	self:RegisterBinders(ViewModel, self.Binders)
	self:RegisterBinders(LinkShellVM, self.BindersLinkShellVM)
end

function LinkShellInviteDetailPanelView:OnRecruitSetChanged(Set)
	if nil == Set then
		return
	end

	local Item = table.find_by_predicate(LinkShellDefine.RecruitSetConfig, function(e) return e.Key == Set end) or {}
	self.TextRecruitSet:SetText(LSTR(Item.NameUkey))
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function LinkShellInviteDetailPanelView:OnClickButtonCopyNo()
	local Text = string.format("%s#%s", self.TextName:GetText(), self.TextNumber:GetText())
    CommonUtil.ClipboardCopy(Text)
    MsgTipsUtil.ShowTips(LSTR(40076)) -- "通讯贝信息已复制，可于聊天框粘贴分享"
end

function LinkShellInviteDetailPanelView:OnClickButtonGoToChat()
    _G.ChatMgr:GoToPlayerChatView(self.InviterRoleID)
end

function LinkShellInviteDetailPanelView:OnClickButtonReport()
	local RoleVM = _G.RoleInfoMgr:FindRoleVM(self.InviterRoleID)
	if nil == RoleVM then
		return
	end

	local Params = { ReporteeRoleID = RoleVM.RoleID }
	_G.ReportMgr:OpenViewByLinkShellInvitation(Params)
end

function LinkShellInviteDetailPanelView:OnClickButtonRefuse()
	if nil == self.LinkShellID or nil == self.InviterRoleID then
		return
	end

	LinkShellMgr:SendMsgLSAnswerInviteJoinReq(self.LinkShellID, self.InviterRoleID, false)
end

function LinkShellInviteDetailPanelView:OnClickButtonAccept()
	if nil == self.LinkShellID or nil == self.InviterRoleID then
		return
	end

	LinkShellMgr:SendMsgLSAnswerInviteJoinReq(self.LinkShellID, self.InviterRoleID, true)
end

return LinkShellInviteDetailPanelView