---
--- Author: xingcaicao
--- DateTime: 2024-07-13 15:23
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local LinkShellVM = require("Game/Social/LinkShell/LinkShellVM")
local LinkShellDefine = require("Game/Social/LinkShell/LinkShellDefine")
local UIBindableList = require("UI/UIBindableList")
local LinkShellActivityVM = require("Game/Social/LinkShell/VM/LinkShellActivityVM")
local LinkshellCfg = require("TableCfg/LinkshellCfg")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local LinkShellMgr = require("Game/Social/LinkShell/LinkShellMgr")
local LinkshellDefineCfg = require("TableCfg/LinkshellDefineCfg")

local LSTR = _G.LSTR
local TextCommitOnEnter = _G.UE.ETextCommit.OnEnter
local MaxActNum = LinkShellDefine.MaxActNum
local RECRUITING_SET = LinkShellDefine.RECRUITING_SET

local ACT_TITLE_PRE_STR = LSTR(40104) -- "通讯贝主要活动"

local ManageTabType = {
    BaseInfo = 1,
    MainAct = 2,
    Recruit = 3,
}

local ManageTabs = {
    {
        Key = ManageTabType.BaseInfo, 
        Name = LSTR(40007), --"基础信息" 
    },
    {
        Key = ManageTabType.MainAct, 
        Name = LSTR(40018), --"主要活动" 
    },
    {
        Key = ManageTabType.Recruit, 
        Name = LSTR(40019), --"招募" 
    }
}

local RecruitWayConfig = {
	{
		Type = RECRUITING_SET.AUDIT,
		Name = LSTR(40002), -- "审核允许"
		Desc = LSTR(40051), -- "允许他人申请加入",
		AllowSetPrivateChat = true,
	},
	{
		Type = RECRUITING_SET.OPEN,
		Name = LSTR(40001), -- "公开招募"
		Desc = LSTR(40049), -- "允许他人自由加入",
	},
	{
		Type = RECRUITING_SET.INVITE,
		Name = LSTR(40003), -- "仅限邀请"
		Desc = LSTR(40050), -- "仅允许通过管理员、创建人邀请加入",
	},
}

---@class LinkShellManageWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bg Comm2FrameLView
---@field BtnDisband CommBtnLView
---@field BtnSave CommBtnLView
---@field CommMenu CommMenuView
---@field InputManifesto CommInputBoxView
---@field InputName CommInputBoxView
---@field InputNotice CommMultilineInputBoxView
---@field PanelBaseInfo UFCanvasPanel
---@field PanelMainAct UFCanvasPanel
---@field PanelRecruit UFCanvasPanel
---@field TableViewActivity UTableView
---@field TableViewRecruitWay UTableView
---@field TextActTitle UFTextBlock
---@field TextName UFTextBlock
---@field TextNotice UFTextBlock
---@field TextPeople UFTextBlock
---@field TextPeopleMem UFTextBlock
---@field TextPeopleMg UFTextBlock
---@field TextRecruit UFTextBlock
---@field TextRecruitWay UFTextBlock
---@field AnimChangeMenu UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LinkShellManageWinView = LuaClass(UIView, true)

function LinkShellManageWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bg = nil
	--self.BtnDisband = nil
	--self.BtnSave = nil
	--self.CommMenu = nil
	--self.InputManifesto = nil
	--self.InputName = nil
	--self.InputNotice = nil
	--self.PanelBaseInfo = nil
	--self.PanelMainAct = nil
	--self.PanelRecruit = nil
	--self.TableViewActivity = nil
	--self.TableViewRecruitWay = nil
	--self.TextActTitle = nil
	--self.TextName = nil
	--self.TextNotice = nil
	--self.TextPeople = nil
	--self.TextPeopleMem = nil
	--self.TextPeopleMg = nil
	--self.TextRecruit = nil
	--self.TextRecruitWay = nil
	--self.AnimChangeMenu = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LinkShellManageWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Bg)
	self:AddSubView(self.BtnDisband)
	self:AddSubView(self.BtnSave)
	self:AddSubView(self.CommMenu)
	self:AddSubView(self.InputManifesto)
	self:AddSubView(self.InputName)
	self:AddSubView(self.InputNotice)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LinkShellManageWinView:OnInit()
	self.TableAdapterActivity = UIAdapterTableView.CreateAdapter(self, self.TableViewActivity)
	self.TableAdapterRecruitWay = UIAdapterTableView.CreateAdapter(self, self.TableViewRecruitWay, self.OnSelectChangedRecruitWay)

	self.InputName:SetMaxNum(LinkshellDefineCfg:GetNameMaxLength())
	self.InputName:SetCallback(self, nil, self.OnInputTextCommittedName)

	self.InputNotice:SetMaxNum(LinkshellDefineCfg:GetNoticeMaxLength())
	self.InputManifesto:SetMaxNum(LinkshellDefineCfg:GetManifestoMaxLength())

	self.AllActVMList = UIBindableList.New(LinkShellActivityVM) 
end

function LinkShellManageWinView:OnDestroy()

end

function LinkShellManageWinView:OnShow()
	self:InitConstText()

	--菜单栏
	self.CurKey = nil
	self.CommMenu:UpdateItems(ManageTabs, false)
	self.CommMenu:SetSelectedKey(ManageTabType.BaseInfo)

	local ViewModel = self.Params
	if nil == ViewModel then
		self.ViewModel = nil
		return
	end

	self.ViewModel = ViewModel

	-- 名称
	local Name = ViewModel.Name or ""
	self.SrcName = Name 
	self.InputName:SetText(Name)

	-- 公告
	local Notice = ViewModel.Notice or ""
	self.SrcNotice = Notice
	self.InputNotice:SetText(Notice)

	-- 人数上限
	local ManagerMaxNum = LinkshellDefineCfg:GetManagerMaxNum()
	local NormalMaxNum = LinkshellDefineCfg:GetMemMaxNum() - ManagerMaxNum
	local AdminNum = ViewModel.AdminNum or 0
	local NormalNum = math.max((ViewModel.MemNum or 0) - AdminNum, 0)

	-- "管理员"
	local MgDesc = string.format("%s：%s/%s", LSTR(40010), AdminNum, ManagerMaxNum)
	self.TextPeopleMg:SetText(MgDesc)

	-- "参与者"
	local NormalDesc = string.format("%s：%s/%s", LSTR(40011), NormalNum, NormalMaxNum)
	self.TextPeopleMem:SetText(NormalDesc)

	-- 招募宣言
	local Manifesto = ViewModel.Manifesto or ""
	self.SrcManifesto = Manifesto
	self.InputManifesto:SetText(Manifesto)

	-- 招募方式
	local RecruitSet = ViewModel.RecruitSet or RECRUITING_SET.SET_UNKNOWN
	self.SrcRecruitSet = RecruitSet 
	LinkShellVM.MgRecruitSet = RecruitSet

	local IsPrivateChat = RecruitSet == RECRUITING_SET.AUDIT and ViewModel.IsAllowPrivateChat or false
	self.SrcIsPrivateChat = IsPrivateChat
	LinkShellVM.MgIsAllowPrivateChat = IsPrivateChat

	-- 主要活动
	local StrActIDs = ""
	local ActIDs = {}
	local ActVMList = ViewModel.ActVMList
	if ActVMList then
		ActIDs = table.extract(ActVMList:GetItems(), "ID")
		table.sort(ActIDs)
		StrActIDs = table.concat(ActIDs, "-")
	end

	self.SrcStrActIDs = StrActIDs 

	LinkShellVM:ResetMgSelectedActIDs(ActIDs)
end

function LinkShellManageWinView:OnHide()
	self.IsInitedRecruitWayTableView = nil

	self.SrcName = nil 
	self.SrcNotice = nil 
	self.SrcManifesto = nil 
	self.SrcRecruitSet = nil 
	self.SrcStrActIDs = nil 

	LinkShellVM:ClearMgData()

	self.CommMenu:CancelSelected()
	self.AllActVMList:Clear()
end

function LinkShellManageWinView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.CommMenu, self.OnSelectionChangedCommMenu)

	UIUtil.AddOnClickedEvent(self, self.BtnDisband, self.OnClickButtonDisband)
	UIUtil.AddOnClickedEvent(self, self.BtnSave, self.OnClickButtonSave)
end

function LinkShellManageWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.LinkShellMgSelectedActIDsUpdate, self.OnGameEventSelectedActIDsUpdate)
end

function LinkShellManageWinView:OnRegisterBinder()

end

function LinkShellManageWinView:InitConstText()
	if self.IsInitConstText then
		return
	end

	self.IsInitConstText = true

	self.TextRecruitWay:SetText(LSTR(40048)) -- "招募方式"
	self.TextRecruit:SetText(LSTR(40057)) -- "招募宣言"

	self.Bg:SetTitleText(LSTR(40095)) -- "通讯贝编辑管理"
	self.TextName:SetText(LSTR(40096)) -- "通讯贝名称"
	self.TextNotice:SetText(LSTR(40097)) -- "通讯贝公告"
	self.TextPeople:SetText(LSTR(40098)) -- "成员上限"

	self.InputName:SetHintText(LSTR(40099)) -- "请输入通讯贝名称"
	self.InputNotice:SetHintText(LSTR(40100)) -- "请输入通讯贝公告"
	self.InputManifesto:SetHintText(LSTR(40101)) -- "请输入招募宣言"

	self.BtnDisband:SetBtnName(LSTR(40102)) -- "解散通讯贝"
	self.BtnSave:SetBtnName(LSTR(10011)) -- "保  存"
end

function LinkShellManageWinView:OnSelectChangedRecruitWay(Index, ItemData, ItemView)
	LinkShellVM.MgRecruitSet = ItemData.Type
end

-------------------------------------------------------------------------------------------------------
---Client Event CallBack 

function LinkShellManageWinView:OnGameEventSelectedActIDsUpdate( )
	local CurNum = #(LinkShellVM.MgSelectedActIDs or {})
	local Title = string.format("%s %d/%d", ACT_TITLE_PRE_STR, CurNum, MaxActNum)
	self.TextActTitle:SetText(Title)
end

-------------------------------------------------------------------------------------------------------
---Component CallBack 

function LinkShellManageWinView:OnSelectionChangedCommMenu(_, ItemData)
	if nil == ItemData then
		return
	end

	local Key = ItemData:GetKey()
	if Key == self.CurKey then
		return
	end

	self.CurKey = Key

	local PanelBaseInfoVisible = false
	local PanelMainActVisible = false
	local PanelRecruitVisible = false

	if Key == ManageTabType.BaseInfo then
		PanelBaseInfoVisible = true

	elseif Key == ManageTabType.MainAct then
		PanelMainActVisible = true

		if self.AllActVMList:Length() <= 0 then
			local CfgList = LinkshellCfg:GetActList() or {}
			self.AllActVMList:UpdateByValues(CfgList)
			self.TableAdapterActivity:UpdateAll(self.AllActVMList)
		end

	elseif Key == ManageTabType.Recruit then
		PanelRecruitVisible = true

		local TableAdapterRecruitWay = self.TableAdapterRecruitWay
		if not self.IsInitedRecruitWayTableView then	-- 通讯贝招募
			TableAdapterRecruitWay:UpdateAll(RecruitWayConfig)

			self.IsInitedRecruitWayTableView = true 
		end

		local RecruitSet = LinkShellVM.MgRecruitSet
		local _, WayIdx = TableAdapterRecruitWay:GetItemDataByPredicate(function (v) return v.Type == RecruitSet end)
		TableAdapterRecruitWay:SetSelectedIndex(WayIdx or 1)
	end

	UIUtil.SetIsVisible(self.PanelBaseInfo, PanelBaseInfoVisible)
	UIUtil.SetIsVisible(self.PanelMainAct, PanelMainActVisible)
	UIUtil.SetIsVisible(self.PanelRecruit, PanelRecruitVisible)

	-- 播放动效
	self:PlayAnimation(self.AnimChangeMenu)
end

function LinkShellManageWinView:OnInputTextCommittedName(InputText, CommitMethod)
	if CommitMethod == TextCommitOnEnter then
		self.BtnSave:SetIsEnabled(not string.isnilorempty(InputText), true)
	end
end

function LinkShellManageWinView:OnClickButtonDisband()
	if nil == self.ViewModel then
		return
	end

	local LinkShellID = self.ViewModel.ID
	MsgBoxUtil.ShowMsgBoxTwoOp(
		nil, 
		LSTR(10004), -- "提 示"
		LSTR(40103), -- "是否解散通讯贝？"
		function() 
			LinkShellMgr:SendMsgDestroyLinkShellReq(LinkShellID)
			self:Hide()
		end,
		nil, LSTR(10003), LSTR(10012), { RightBtnCD = 11 }) -- "取 消"、"解 散"
end

function LinkShellManageWinView:OnClickButtonSave()
	if nil == self.ViewModel then
		return
	end

	-- 名字
	local Name = self.InputName:GetText()
	if string.isnilorempty(Name) then
		MsgTipsUtil.ShowTips(LSTR(40105)) -- "通讯贝未命名"
		return
	end

	if Name == self.SrcName then
		Name = nil
	end

	-- 公告
	local Notice = self.InputNotice:GetText()
	if Notice == self.SrcNotice then
		Notice = nil
	end

	-- 主要活动
	local ActIDs = LinkShellVM.MgSelectedActIDs or {}
	table.sort(ActIDs)
	local StrActIDs = table.concat(ActIDs, "-")
	if StrActIDs == self.SrcStrActIDs then
		ActIDs = nil
	end

	-- 招募宣言
	local Manifesto = self.InputManifesto:GetText() 
	if Manifesto == self.SrcManifesto then
		Manifesto = nil
	end

	-- 招募方式
	local RecruitSet = LinkShellVM.MgRecruitSet
	if RecruitSet == self.SrcRecruitSet then
		RecruitSet = nil
	end

	-- 私聊
	local IsPrivateChat = LinkShellVM.MgIsAllowPrivateChat
	if IsPrivateChat == self.SrcIsPrivateChat then
		IsPrivateChat = nil
	end

	-- 是否无变动
	if nil == Name and nil == Notice and nil == ActIDs and nil == Manifesto and nil == RecruitSet and nil == IsPrivateChat then
		MsgTipsUtil.ShowTips(LSTR(40106)) -- "无变更内容"
		return
	end

	LinkShellMgr:SetModifyLinkShellInfo(self.ViewModel.ID, Name, RecruitSet, ActIDs, Manifesto, Notice, IsPrivateChat)

	self:Hide()
end

return LinkShellManageWinView