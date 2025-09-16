---
--- Author: Administrator
--- DateTime: 2024-12-31 18:38
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ArmyMainVM = require("Game/Army/VM/ArmyMainVM")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local ArmySignPanelVM 
local UIViewMgr = require("UI/UIViewMgr")
local ArmyMgr = require("Game/Army/ArmyMgr")
local ProtoCS = require("Protocol/ProtoCS")


---@class ArmySignPageView : UIView
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
---@field TextName UFTextBlock
---@field TextShortName UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimRefreshTipsIn UWidgetAnimation
---@field AnimRefreshTipsOut UWidgetAnimation
---@field AnimUpdateList UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmySignPageView = LuaClass(UIView, true)

function ArmySignPageView:Ctor()
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
	--self.TextName = nil
	--self.TextShortName = nil
	--self.AnimIn = nil
	--self.AnimRefreshTipsIn = nil
	--self.AnimRefreshTipsOut = nil
	--self.AnimUpdateList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmySignPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnAcceptJoin)
	self:AddSubView(self.BtnRefuse)
	self:AddSubView(self.ShowInfoPage)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmySignPageView:OnInit()
	ArmySignPanelVM = ArmyMainVM:GetArmySignPanelVM()
	if ArmySignPanelVM and ArmySignPanelVM.ArmyShowInfoVM then
        local ShowInfoVM = ArmySignPanelVM.ArmyShowInfoVM
        self.ShowInfoPage:RefreshVM(ShowInfoVM)
    end
	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewArmyList)
	self.TableViewAdapter:SetOnClickedCallback(self.OnClickedSelectItem)
	self.Binders = {
		{ "ArmySignList", UIBinderUpdateBindableList.New(self, self.TableViewAdapter)},
		{ "bInfoPage", UIBinderSetIsVisible.New(self, self.ShowInfoPage)},
		{ "bAccepBtn", UIBinderSetIsVisible.New(self, self.BtnAcceptJoin)},
		{ "bRefuseBtn", UIBinderSetIsVisible.New(self, self.BtnRefuse)},
		{ "bEmptyPanel", UIBinderSetIsVisible.New(self, self.PanelEmpty)},
		{ "bEmptyPanel", UIBinderSetIsVisible.New(self, self.PanelList, true)},
		{ "bEmptyPanel", UIBinderValueChangedCallback.New(self, nil, self.AddEmptyUI)},
		{ "GrandCompanyType", UIBinderValueChangedCallback.New(self, nil, self.GrandCompanyTypeChanged)},
	}
end

function ArmySignPageView:GrandCompanyTypeChanged(GrandCompanyType)
	if GrandCompanyType then
		ArmyMainVM:SetBGIcon(GrandCompanyType)
	end
end

function ArmySignPageView:AddEmptyUI(bEmptyPanel)
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
				local ArmyState = _G.ArmyMgr:GetArmyState()
				if ArmyState ==  ProtoCS.RoleGroupState.RoleGroupStateGainedPetition then
					-- LSTR string:处于部队创建状态，无法获得署名邀请
					self.EmptyView:SetTextEmptyTip(LSTR(910357))
				else
					-- LSTR string:暂无署名邀请
					self.EmptyView:SetTextEmptyTip(LSTR(910356))
				end
			end
		end
	else
		if self.EmptyView then
			self.PanelEmpty:RemoveChild(self.EmptyView)
			UIViewMgr:RecycleView(self.EmptyView)
			self.EmptyView = nil
		end
	end

	---设置蒙版/是否为空都有蒙版
	ArmyMainVM:SetIsMask(true)
end

function ArmySignPageView:OnClickedSelectItem(Index, ItemData, ItemView)
	if ArmySignPanelVM ~= nil then
		ArmySignPanelVM:OnSelectedItem(Index, ItemData)
	end
end

function ArmySignPageView:OnDestroy()

end

function ArmySignPageView:OnShow()
	-- LSTR string:部队名字
	self.TextName:SetText(LSTR(910251))
	-- LSTR string:部队简称
	self.TextShortName:SetText(LSTR(910262))
	-- LSTR string:署名人
	self.TextLevel:SetText(LSTR(910335))
	-- LSTR string:署名部队
	self.BtnAcceptJoin:SetText(LSTR(910350))
	-- LSTR string:拒绝署名
	self.BtnRefuse:SetText(LSTR(910349))
end

function ArmySignPageView:OnHide()
	if self.EmptyView then
		self.PanelEmpty:RemoveChild(self.EmptyView)
		UIViewMgr:RecycleView(self.EmptyView)
		self.EmptyView = nil
	end
end

function ArmySignPageView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnAcceptJoin, self.OnClickedAcceptJoin)
	UIUtil.AddOnClickedEvent(self, self.BtnRefuse, self.OnClickedRefuseJoin)
end

function ArmySignPageView:OnRegisterGameEvent()

end

function ArmySignPageView:OnRegisterBinder()
	if ArmySignPanelVM ~= nil then
		--self.ShowInfoPage:SetViewModel(ArmySignPanelVM.ArmyShowInfoVM)
		self:RegisterBinders(ArmySignPanelVM, self.Binders)
	end
end

--- 同意署名
function ArmySignPageView:OnClickedAcceptJoin()
	local SelectedItemData = ArmySignPanelVM.CurSelectedItemData
	if nil == SelectedItemData then
		return
	end
	ArmyMgr:SendGroupSignAgree(SelectedItemData.RoleID)
	ArmyMgr:ClearInvitePopUpInfo()
end

--- 拒绝署名
function ArmySignPageView:OnClickedRefuseJoin()
	local SelectedItemData = ArmySignPanelVM.CurSelectedItemData
	if nil == SelectedItemData then
		return
	end
	ArmyMgr:SendGroupSignRefuse(ArmySignPanelVM.CurSelectedItemData.RoleID)
	-- 弹窗清理
	ArmyMgr:ClearInvitePopUpInfoByRoleID(ArmySignPanelVM.CurSelectedItemData.RoleID)
end

function ArmySignPageView:IsForceGC()
	return true
end

return ArmySignPageView