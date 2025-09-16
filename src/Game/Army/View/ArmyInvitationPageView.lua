---
--- Author: qibaoyiyi
--- DateTime: 2023-03-08 09:56
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIViewMgr = require("UI/UIViewMgr")


local ArmyMainVM = require("Game/Army/VM/ArmyMainVM")
local ArmyMgr = require("Game/Army/ArmyMgr")
local ArmyInvitationPageVM
local ArmyDefine = require("Game/Army/ArmyDefine")

---@class ArmyInvitationPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAcceptJoin CommBtnLView
---@field BtnRefuse CommBtnLView
---@field PanelEmpty UFCanvasPanel
---@field PanelInvite UFCanvasPanel
---@field PanelList UFCanvasPanel
---@field PanelRefreshTip UFCanvasPanel
---@field ShowInfoPage ArmyShowInfoPageView
---@field TableViewArmyList UTableView
---@field TextLevel UFTextBlock
---@field TextMemberAmount UFTextBlock
---@field TextName UFTextBlock
---@field TextShortName UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimRefreshTipsIn UWidgetAnimation
---@field AnimRefreshTipsOut UWidgetAnimation
---@field AnimUpdateList UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyInvitationPageView = LuaClass(UIView, true)

function ArmyInvitationPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAcceptJoin = nil
	--self.BtnRefuse = nil
	--self.PanelEmpty = nil
	--self.PanelInvite = nil
	--self.PanelList = nil
	--self.PanelRefreshTip = nil
	--self.ShowInfoPage = nil
	--self.TableViewArmyList = nil
	--self.TextLevel = nil
	--self.TextMemberAmount = nil
	--self.TextName = nil
	--self.TextShortName = nil
	--self.AnimIn = nil
	--self.AnimRefreshTipsIn = nil
	--self.AnimRefreshTipsOut = nil
	--self.AnimUpdateList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyInvitationPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnAcceptJoin)
	self:AddSubView(self.BtnRefuse)
	self:AddSubView(self.ShowInfoPage)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyInvitationPageView:OnInit()
	local JoinPanelVM = ArmyMainVM:GetJoinPanelVM()
	ArmyInvitationPageVM = JoinPanelVM:GetArmyInvitationPageVM()
	if ArmyInvitationPageVM and ArmyInvitationPageVM.ArmyShowInfoVM then
        local ShowInfoVM = ArmyInvitationPageVM.ArmyShowInfoVM
        self.ShowInfoPage:RefreshVM(ShowInfoVM)
    end
	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewArmyList)
	self.TableViewAdapter:SetOnClickedCallback(self.OnClickedSelectItem)
	self.Binders = {
		{ "ArmyList", UIBinderUpdateBindableList.New(self, self.TableViewAdapter)},
		{ "bInfoPage", UIBinderSetIsVisible.New(self, self.ShowInfoPage)},
		{ "bAccepBtn", UIBinderSetIsVisible.New(self, self.BtnAcceptJoin)},
		{ "bRefuseBtn", UIBinderSetIsVisible.New(self, self.BtnRefuse)},
		{ "bEmptyPanel", UIBinderSetIsVisible.New(self, self.PanelEmpty)},
		{ "bEmptyPanel", UIBinderSetIsVisible.New(self, self.PanelList, true)},
		{ "bEmptyPanel", UIBinderValueChangedCallback.New(self, nil, self.AddEmptyUI)},
		{ "GrandCompanyType", UIBinderValueChangedCallback.New(self, nil, self.GrandCompanyTypeChanged)},
	}
end

function ArmyInvitationPageView:OnClickedSelectItem(Index, ItemData, ItemView)
	ArmyInvitationPageVM:OnSelectedItem(Index, ItemData)
end

function ArmyInvitationPageView:GrandCompanyTypeChanged(GrandCompanyType)
	if GrandCompanyType then
		ArmyMainVM:SetBGIcon(GrandCompanyType)
	end
end

function ArmyInvitationPageView:AddEmptyUI(bEmptyPanel)
	if bEmptyPanel then
		if self.EmptyView == nil then
			self.EmptyView = UIViewMgr:CreateViewByName("Army/ArmyEmptyPage_UIBP", nil, self, true)
			if self.EmptyView then
				self.PanelEmpty:AddChildToCanvas(self.EmptyView)
				local Anchor = _G.UE.FAnchors()
				Anchor.Minimum = _G.UE.FVector2D(0, 0)
				Anchor.Maximum = _G.UE.FVector2D(1, 1)
				UIUtil.CanvasSlotSetAnchors(self.EmptyView, Anchor)
				UIUtil.CanvasSlotSetSize(self.EmptyView, _G.UE.FVector2D(0, 0))
				-- LSTR string:暂未收到邀请
				self.EmptyView:SetTextEmptyTip(LSTR(910156))
			end
		end
	else
		if self.EmptyView then
			self.PanelEmpty:RemoveChild(self.EmptyView)
			UIViewMgr:RecycleView(self.EmptyView)
			self.EmptyView = nil
		end
	end
end

function ArmyInvitationPageView:OnDestroy()
	if ArmyInvitationPageVM then
		ArmyInvitationPageVM:OnShutdown()
		ArmyInvitationPageVM = nil
	end
end

function ArmyInvitationPageView:OnShow()
	---设置固定文本
	-- LSTR string:部队名字
	self.TextName:SetText(LSTR(910251))
	-- LSTR string:部队简称
	self.TextShortName:SetText(LSTR(910262))
	-- LSTR string:等级
	self.TextLevel:SetText(LSTR(910296))
	-- LSTR string:人数
	self.TextMemberAmount:SetText(LSTR(910304))

	--ShowView时会被IsShow挡住，无法传递绑定数据
	--self.ShowInfoPage:ShowView({ Data = ArmyInvitationPageVM.ArmyShowInfoVM })
	-- LSTR string:查看部队
	self.BtnAcceptJoin:SetText(LSTR(910370))
	-- LSTR string:拒绝邀请
	self.BtnRefuse:SetText(LSTR(910406))

end

function ArmyInvitationPageView:OnHide()
	if self.EmptyView then
		self.PanelEmpty:RemoveChild(self.EmptyView)
		UIViewMgr:RecycleView(self.EmptyView)
		self.EmptyView = nil
	end
end

function ArmyInvitationPageView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnAcceptJoin, self.OnOpenArmyJoinInfoView)
	UIUtil.AddOnClickedEvent(self, self.BtnRefuse, self.OnClickedRefuseJoin)
end

function ArmyInvitationPageView:OnRegisterGameEvent()

end

function ArmyInvitationPageView:OnRegisterBinder()
	if ArmyInvitationPageVM ~= nil then
		self.ShowInfoPage:SetViewModel(ArmyInvitationPageVM.ArmyShowInfoVM)
		self:RegisterBinders(ArmyInvitationPageVM, self.Binders)
	end
end

--- 打开查看部队界面
function ArmyInvitationPageView:OnOpenArmyJoinInfoView()
	if ArmyInvitationPageVM == nil then
		return
	end
	local SelectedItemData = ArmyInvitationPageVM.CurSelectedItemData
	if nil == SelectedItemData then
		return
	end
	local Params = {
		OpenPath = ArmyDefine.ArmyOpenJoinInfoType.InvitePanel,
		ArmyID = SelectedItemData.ID,
	}
	if SelectedItemData then
		ArmyMgr:OpenArmyJoinInfoPanel(SelectedItemData.LeaderID, Params)
	end
end

--- 同意加入部队
function ArmyInvitationPageView:OnClickedAcceptJoin()
	if ArmyInvitationPageVM == nil then
		return
	end
	local SelectedItemData = ArmyInvitationPageVM.CurSelectedItemData
	if nil == SelectedItemData then
		return
	end
	ArmyMgr:SendArmyAcceptInviteMsg(SelectedItemData.ID)
	ArmyMgr:ClearInvitePopUpInfo()
end

--- 拒绝加入部队
function ArmyInvitationPageView:OnClickedRefuseJoin()
	if ArmyInvitationPageVM == nil then
		return
	end
	local SelectedItemData = ArmyInvitationPageVM.CurSelectedItemData
	if nil == SelectedItemData then
		return
	end
	ArmyMgr:SendIgnoreInviteMsg({ ArmyInvitationPageVM.CurSelectedItemData.ID })
	ArmyMgr:ClearInvitePopUpInfoByArmyID(ArmyInvitationPageVM.CurSelectedItemData.ID)
end

return ArmyInvitationPageView