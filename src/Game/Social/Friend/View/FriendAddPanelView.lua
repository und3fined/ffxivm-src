---
--- Author: xingcaicao
--- DateTime: 2024-06-21 15:42
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local FriendVM = require("Game/Social/Friend/FriendVM")
local FriendMgr = require("Game/Social/Friend/FriendMgr")
local FriendDefine = require("Game/Social/Friend/FriendDefine")
local SocialDefine = require("Game/Social/SocialDefine")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local ClientSetupID = require("Game/ClientSetup/ClientSetupID")
local RoleInfoMgr = require("Game/Role/RoleInfoMgr")

local LSTR = _G.LSTR
local TabType = SocialDefine.TabType
local FindType = FriendDefine.FindType
local FindDropDownData = FriendDefine.FindDropDownData

local ListEmptyText = LSTR(30037) --"列表是空的"
local SearchEmptyText = LSTR(30038) --"暂无搜索结果，请重新搜索"
local ScreenEmptyText = LSTR(30039) --"暂无筛选结果，请重新筛选"

---@class FriendAddPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnFind CommSearchBtnView
---@field BtnScreen CommScreenerBtnView
---@field CommEmptyApply CommBackpackEmptyView
---@field CommEmptyFind CommBackpackEmptyView
---@field DropDownList CommDropDownListView
---@field FindInput CommSearchBarView
---@field PanelApply UFCanvasPanel
---@field PanelDropDown UFCanvasPanel
---@field PanelFind UFCanvasPanel
---@field TableViewApplyList UTableView
---@field TableViewFindList UTableView
---@field AnimIn UWidgetAnimation
---@field AnimUpdateList UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FriendAddPanelView = LuaClass(UIView, true)

function FriendAddPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnFind = nil
	--self.BtnScreen = nil
	--self.CommEmptyApply = nil
	--self.CommEmptyFind = nil
	--self.DropDownList = nil
	--self.FindInput = nil
	--self.PanelApply = nil
	--self.PanelDropDown = nil
	--self.PanelFind = nil
	--self.TableViewApplyList = nil
	--self.TableViewFindList = nil
	--self.AnimIn = nil
	--self.AnimUpdateList = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FriendAddPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnFind)
	self:AddSubView(self.BtnScreen)
	self:AddSubView(self.CommEmptyApply)
	self:AddSubView(self.CommEmptyFind)
	self:AddSubView(self.DropDownList)
	self:AddSubView(self.FindInput)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FriendAddPanelView:OnInit()
	self.FindInput:SetCallback(self, nil, self.OnTextCommittedFind, self.OnClickCancelInputFind)

	self.TableAdapterFind = UIAdapterTableView.CreateAdapter(self, self.TableViewFindList)
    self.TableAdapterApply = UIAdapterTableView.CreateAdapter(self, self.TableViewApplyList)

	self.Binders = {
		{ "IsScreening", 		UIBinderSetIsChecked.New(self, self.BtnScreen, false) },
		{ "IsEmptyFindList",	UIBinderSetIsVisible.New(self, self.CommEmptyFind) },
		{ "FindEmptyTips", 		UIBinderSetText.New(self, self.CommEmptyFind:GetContentText()) },
		{ "IsEmptyApplyList",	UIBinderSetIsVisible.New(self, self.CommEmptyApply) },

		{ "FindResultVMList",  UIBinderUpdateBindableList.New(self, self.TableAdapterFind) },
		{ "FriendApplyVMList", UIBinderUpdateBindableList.New(self, self.TableAdapterApply) },
	}

	self.CommEmptyApply:SetTipsContent(ListEmptyText)
	self.FindInput:SetHintText(LSTR(30077)) -- "搜索全部玩家"
end

function FriendAddPanelView:OnDestroy()

end

function FriendAddPanelView:OnShow()
end

function FriendAddPanelView:OnHide()
	self.FindInput:SetText("")
	FriendVM:ClearFindScreenData()
	UIViewMgr:HideView(UIViewID.ReportTips)
end

function FriendAddPanelView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownList, self.OnSelectionChangedDropDownList)
	UIUtil.AddOnStateChangedEvent(self, self.BtnScreen, self.OnClickedBtnScreen)

	UIUtil.AddOnClickedEvent(self, self.BtnFind.BtnSearch, self.OnClickedButtonFind)
end

function FriendAddPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.FriendRecentInfoUpdate, self.OnGameEventFriendRecentInfoUpdate)
	self:RegisterGameEvent(EventID.FriendAddResetDefaultState, self.OnGameEventResetDefaultState)
	self:RegisterGameEvent(EventID.FriendPlayAddUpdateListAnim, self.OnGameEventPlayUpdateListAnim)
end

function FriendAddPanelView:OnRegisterBinder()
	self:RegisterBinders(FriendVM, self.Binders)
end

function FriendAddPanelView:SelectTab( Key )
	self.CurFindType = nil 
	FriendVM.FindResultVMList:Clear()

	if Key == TabType.FindFriend then
		UIUtil.SetIsVisible(self.PanelApply, false)

		UIUtil.SetIsVisible(self.FindInput, false)
		UIUtil.SetIsVisible(self.PanelDropDown, true)
		UIUtil.SetIsVisible(self.PanelFind, true)

		self.DropDownList:CancelSelected()
		self.DropDownList:UpdateItems(FindDropDownData, 1)

	elseif Key == TabType.ApplyList then
		-- 刷新申请列表角色信息 
		local EntryVMList = FriendVM.FriendApplyVMList:GetItems()
		local RoleIDs = table.extract(EntryVMList, "RoleID")
		if #RoleIDs > 0 then
			RoleInfoMgr:QueryRoleSimples(RoleIDs, function()
				for _, v in ipairs(EntryVMList) do
					local RoleVM = RoleInfoMgr:FindRoleVM(v.RoleID)
					if RoleVM then
						v:UpdateRoleInfo(RoleVM)
					end
				end
			end, nil, false)
		end

		UIUtil.SetIsVisible(self.PanelFind, false)
		UIUtil.SetIsVisible(self.PanelApply, true)
	end
end

function FriendAddPanelView:ResetState()
	self.FindInput:SetText("")

	-- 重置回初始状态
	self.DropDownList:CancelSelected()
	self.DropDownList:SetDropDownIndex(1)

	UIUtil.SetIsVisible(self.FindInput, false)
	UIUtil.SetIsVisible(self.PanelDropDown, true)
end

---@param Text string @回调的文本
function FriendAddPanelView:OnTextCommittedFind(Text)
	FriendVM.FindEmptyTips = SearchEmptyText

	if string.isnilorempty(Text) then
		FriendVM:UpdateFindFriendList()
		return
	end

	FriendVM.IsEmptyFindList = false
	FriendVM:ClearFindScreenData()
	FriendMgr:SendFindFirnds_RoleName(Text)
end

function FriendAddPanelView:OnClickCancelInputFind()
	FriendVM:ClearFindScreenData()
	self:ResetState()
end

-------------------------------------------------------------------------------------------------------
---Client Event CallBack 

function FriendAddPanelView:OnGameEventFriendRecentInfoUpdate(SetupID)
	if SetupID == ClientSetupID.FriendRecentTeam then 
		if self.CurFindType == FindType.RecentTeam then
			FriendVM:UpdateFindFriendList(FriendVM.RecentTeamRoleIDs, false)
		end

	elseif SetupID == ClientSetupID.FriendRecentChat then 
		if self.CurFindType == FindType.RecentChat then
			FriendVM:UpdateFindFriendList(FriendVM.RecentChatRoleIDs, false)
		end
	end
end

function FriendAddPanelView:OnGameEventResetDefaultState()
	self:ResetState()
end

function FriendAddPanelView:OnGameEventPlayUpdateListAnim()
    self:PlayAnimation(self.AnimUpdateList)
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function FriendAddPanelView:OnSelectionChangedDropDownList( Index )
	if nil == Index then
		return
	end

	FriendVM.IsEmptyFindList = false

	local TextEmpty = ListEmptyText

	local Type = (FindDropDownData[Index] or {}).Type
	if Type == FindType.AllRecommond then -- 全部推荐
		if FriendVM.IsScreening then -- 正在筛选中
			local ProfIDs = FriendVM.ProfScreenList
			local StyleIDs = FriendVM.PlayStyleScreenList

			if #ProfIDs <= 0 and #StyleIDs <= 0 then
				FriendVM:ClearFindScreenData()
				FriendMgr:SendFindFriends_AllRecommond()

			else
				TextEmpty = ScreenEmptyText
				FriendMgr:SendFindFriends_Dim(ProfIDs, StyleIDs)
			end
		else
			FriendMgr:SendFindFriends_AllRecommond()
		end

	elseif Type == FindType.RecentTeam then -- 近期组队
		FriendVM:ClearFindScreenData()
		FriendVM:UpdateFindFriendList(FriendVM.RecentTeamRoleIDs, false)

	elseif Type == FindType.RecentChat then -- 近期聊天 
		FriendVM:ClearFindScreenData()
		FriendVM:UpdateFindFriendList(FriendVM.RecentChatRoleIDs, false)
	end

	self.CurFindType = Type
	FriendVM.FindEmptyTips = TextEmpty
end

function FriendAddPanelView:OnClickedBtnScreen(_, State)
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	if IsChecked then
		UIViewMgr:ShowView(UIViewID.FriendScreenerWin) 

	else
		FriendVM:ClearFindScreenData()
		self:ResetState()
	end

	FriendVM.IsScreening = IsChecked 
end

function FriendAddPanelView:OnClickedButtonFind()
	UIUtil.SetIsVisible(self.PanelDropDown, false)
	UIUtil.SetIsVisible(self.FindInput, true)
end

return FriendAddPanelView