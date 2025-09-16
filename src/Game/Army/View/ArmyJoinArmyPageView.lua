---
--- Author: daniel
--- DateTime: 2023-03-08 09:57
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local ArmyMainVM = require("Game/Army/VM/ArmyMainVM")
local ArmyJoinArmyPageVM = nil
local ArmyMgr = require("Game/Army/ArmyMgr")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local CommBtnLView = require("Game/Common/Btn/CommBtnLView")
local MajorUtil = require("Utils/MajorUtil")
local TimeUtil = require("Utils/TimeUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local GroupGlobalCfg = require("TableCfg/GroupGlobalCfg")
local ArmyDefine = require("Game/Army/ArmyDefine")
local GlobalCfgType = ArmyDefine.GlobalCfgType

---@class ArmyJoinArmyPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCheck CommBtnLView
---@field PanelEmpty UFCanvasPanel
---@field PanelTop UFCanvasPanel
---@field SearchInput CommSearchBarView
---@field ShowInfoPage ArmyShowInfoPageView
---@field SingleBoxShowFull CommSingleBoxView
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
local ArmyJoinArmyPageView = LuaClass(UIView, true)


local LastFindCondition = nil --- 上一次查找条件
local MaxJoinTextLen = nil --- 申请入队留言最大长度

function ArmyJoinArmyPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCheck = nil
	--self.PanelEmpty = nil
	--self.PanelTop = nil
	--self.SearchInput = nil
	--self.ShowInfoPage = nil
	--self.SingleBoxShowFull = nil
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

function ArmyJoinArmyPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnCheck)
	self:AddSubView(self.SearchInput)
	self:AddSubView(self.ShowInfoPage)
	self:AddSubView(self.SingleBoxShowFull)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyJoinArmyPageView:OnInit()
	local JoinPanelVM = ArmyMainVM:GetJoinPanelVM()
	ArmyJoinArmyPageVM = JoinPanelVM:GetArmyJoinPageVM()
	if ArmyJoinArmyPageVM and ArmyJoinArmyPageVM.ArmyShowInfoVM then
        local ShowInfoVM = ArmyJoinArmyPageVM.ArmyShowInfoVM
        self.ShowInfoPage:RefreshVM(ShowInfoVM)
    end
	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewArmyList)
	self.TableViewAdapter:SetOnClickedCallback(self.OnClickedSelectItem)
	self.SearchInput:SetCallback(self, nil, self.OnSearchInput, self.OnCloseSearch)
	self.Binders = {
		{ "ArmyList", UIBinderUpdateBindableList.New(self, self.TableViewAdapter)},
		{ "bInfoPage", UIBinderSetIsVisible.New(self, self.ShowInfoPage)},
		{ "bEmptyPanel", UIBinderSetIsVisible.New(self, self.PanelEmpty)},
		{ "bEmptyPanel", UIBinderValueChangedCallback.New(self, nil, self.AddEmptyUI)},
		{ "bApplyBtn", UIBinderSetIsVisible.New(self, self.BtnCheck)},
		--{ "IsApplyCD", UIBinderValueChangedCallback.New(self, nil, self.SetIsApplyCD) },
		--{ "CurIsFull", UIBinderValueChangedCallback.New(self, nil, self.SetCurIsFull) },
		{ "IsSearch", UIBinderValueChangedCallback.New(self, nil, self.OnIsSearchChanged) },
	}
	MaxJoinTextLen = GroupGlobalCfg:GetValueByType(GlobalCfgType.ApplyMsgMaxLimit)
end

function ArmyJoinArmyPageView:AddEmptyUI(bEmptyPanel)
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
				-- LSTR string:未搜索到符合条件的部队
				self.EmptyView:SetTextEmptyTip(LSTR(910159))
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

-- function ArmyJoinArmyPageView:SetIsApplyCD(IsApplyCD)
-- 	if ArmyJoinArmyPageVM.CurIsFull then
-- 		-- LSTR string:已满员
-- 		self.BtnCheck:SetBtnName(LSTR(910110))
-- 		self.BtnCheck:SetButtonState(CommBtnLView.BtnState.Disable)
-- 		return
-- 	end
-- 	if IsApplyCD then
-- 		-- LSTR string:已申请
-- 		self.BtnCheck:SetBtnName(LSTR(910113))
-- 		self.BtnCheck:SetButtonState(CommBtnLView.BtnState.Disable)
-- 	else
-- 		-- LSTR string:加入部队
-- 		self.BtnCheck:SetBtnName(LSTR(910076))
-- 		self.BtnCheck:SetButtonState(CommBtnLView.BtnState.Recommend)
-- 	end
-- end

-- function ArmyJoinArmyPageView:SetCurIsFull(CurIsFull)
-- 	if CurIsFull then
-- 		-- LSTR string:已满员
-- 		self.BtnCheck:SetBtnName(LSTR(910110))
-- 		self.BtnCheck:SetButtonState(CommBtnLView.BtnState.Disable)
-- 	elseif ArmyJoinArmyPageVM.IsApplyCD then
-- 		-- LSTR string:已申请
-- 		self.BtnCheck:SetBtnName(LSTR(910113))
-- 		self.BtnCheck:SetButtonState(CommBtnLView.BtnState.Disable)
-- 	else
-- 		-- LSTR string:加入部队
-- 		self.BtnCheck:SetBtnName(LSTR(910076))
-- 		self.BtnCheck:SetButtonState(CommBtnLView.BtnState.Recommend)
-- 	end
-- end

function ArmyJoinArmyPageView:OnClickedSelectItem(Index, ItemData, ItemView)
	ArmyMainVM:SetBGIcon(ItemData.GrandCompanyType)
	ArmyJoinArmyPageVM:OnSelectedItem(Index, ItemData)
end

function ArmyJoinArmyPageView:OnDestroy()

end

function ArmyJoinArmyPageView:OnShow()
	---设置固定文本
	-- LSTR string:部队名字
	self.TextName:SetText(LSTR(910251))
	-- LSTR string:部队简称
	self.TextShortName:SetText(LSTR(910262))
	-- LSTR string:等级
	self.TextLevel:SetText(LSTR(910296))
	-- LSTR string:人数
	self.TextMemberAmount:SetText(LSTR(910304))
	-- LSTR string:搜索部队名称或部队编号
	self.SearchInput:SetHintText(LSTR(910305))
	-- LSTR string:显示满员部队
	self.SingleBoxShowFull:SetText(LSTR(910306))
	-- LSTR string:查看部队
	self.BtnCheck:SetBtnName(LSTR(910370))
	
	if ArmyMgr.bQueryArmy then
		self:SetSearchPanelState(true)
		self.SearchInput:SetText(tostring(ArmyMgr.QuerySimpleID))
	end
	ArmyMgr:SetSearchArmyListIsEnd(false)
	local ItemData = ArmyJoinArmyPageVM:GetCurSelectedItemData()
	if ItemData then
		ArmyMainVM:SetBGIcon(ItemData.GrandCompanyType)
	end
	--- 需求变更，默认显示搜索
	UIUtil.SetIsVisible(self.SingleBoxShowFull, true, true)
	UIUtil.SetIsVisible(self.SearchInput, true)
end

function ArmyJoinArmyPageView:OnHide()
	ArmyJoinArmyPageVM:SetIsSearch(false)
	LastFindCondition = nil
	ArmyJoinArmyPageVM:SetIsFull(false)
end

function ArmyJoinArmyPageView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnCheck, self.OnOpenArmyJoinInfoView)
	UIUtil.AddOnStateChangedEvent(self, self.SingleBoxShowFull.ToggleButton, self.OnToggleStateChanged)
	--UIUtil.AddOnClickedEvent(self, self.BtnSearch, self.OnClickedShowSearch)
	-- UIUtil.AddOnClickedEvent(self, self.SearchInput.BtnCancel, self.OnClickedCloseSearch)
end

function ArmyJoinArmyPageView:OnRegisterGameEvent()

end

function ArmyJoinArmyPageView:OnRegisterBinder()
	if nil == ArmyJoinArmyPageVM then
		return
	end
	self:RegisterBinders(ArmyJoinArmyPageVM, self.Binders)
	-- local ShowInfoVM = ArmyJoinArmyPageVM.ArmyShowInfoVM
	-- if nil == ShowInfoVM then
	-- 	return
	-- end
	-- self.ShowInfoPage:RefreshVM(ShowInfoVM)
end

--- 打开查看部队界面
function ArmyJoinArmyPageView:OnOpenArmyJoinInfoView()
	if nil ~= ArmyJoinArmyPageVM then
		local IsApplyCD = ArmyJoinArmyPageVM:GetIsApplyCD()
		--local CurIsFull = ArmyJoinArmyPageVM.CurIsFull
		local ArmyData = ArmyJoinArmyPageVM:GetCurSelectedItemData()
		if ArmyData == nil then
			return
		end
		local Params = {
			IsApplyCD = IsApplyCD,
			--CurIsFull = CurIsFull,
			OpenPath = ArmyDefine.ArmyOpenJoinInfoType.JoinPanel,
			ArmyID = ArmyData.ID
		}
		ArmyMgr:OpenArmyJoinInfoPanel(ArmyData.LeaderID, Params)
	end 
end

--- 申请加入部队
function ArmyJoinArmyPageView:OnApplyJoinArmy()
	if nil ~= ArmyJoinArmyPageVM then
		local IsDisable = ArmyJoinArmyPageVM:GetIsApplyCD()
		if ArmyJoinArmyPageVM.CurIsFull then
			-- LSTR string:该部队已满员
			MsgTipsUtil.ShowTips(LSTR(910223))
			return
		end
		if IsDisable then
			-- LSTR string:已申请，请等待审批
			MsgTipsUtil.ShowTips(LSTR(910114))
			return
		end
	else
		return
	end 
    UIViewMgr:ShowView(UIViewID.ArmyApplyJoinPanel, {
		MaxTextLength = MaxJoinTextLen,
		-- LSTR string:请输入申请留言
		HintText =  _G.LSTR(910230),
		Callback = function(Message)
			---确认做申请实时禁用，本地计时可以接受，重新申请数据时会被服务器正确数据覆盖
			if nil ~= ArmyJoinArmyPageVM then
				local RoleID = MajorUtil.GetMajorRoleID()
				local ApplyHistory
				if ArmyJoinArmyPageVM.CurSelectedItemData and ArmyJoinArmyPageVM.CurSelectedItemData.ApplyHistories then
					ApplyHistory = table.find_by_predicate(ArmyJoinArmyPageVM.CurSelectedItemData.ApplyHistories, function(Element)
						return Element.RoleID == RoleID
					end)
				end
				if ApplyHistory then
					ApplyHistory.Time = TimeUtil.GetServerTime()
				else
					ApplyHistory = {}
					ApplyHistory.Time = TimeUtil.GetServerTime()
					ApplyHistory.RoleID = RoleID
					if ArmyJoinArmyPageVM.CurSelectedItemData then
						if  nil == ArmyJoinArmyPageVM.CurSelectedItemData.ApplyHistories then
							ArmyJoinArmyPageVM.CurSelectedItemData.ApplyHistories = {}
						end
						table.insert(ArmyJoinArmyPageVM.CurSelectedItemData.ApplyHistories, ApplyHistory)
					else
						_G.FLOG_ERROR("[ArmyJoinArmyPageView] CurArmyData is nil, RoleID:", RoleID)
					end
				end
				ArmyJoinArmyPageVM.IsApplyCD = true
			end
			if ArmyJoinArmyPageVM and ArmyJoinArmyPageVM.CurSelectedItemData then
				ArmyMgr:SendArmyApplyJoinMsg({ArmyJoinArmyPageVM.CurSelectedItemData.ID}, Message)
			else
				_G.FLOG_ERROR("[ArmyJoinArmyPageView] ArmyJoinArmyPageVM.CurSelectedItemData is nil")
			end
		end
	})
end

--- 是否显示全部满员
function ArmyJoinArmyPageView:OnToggleStateChanged(ToggleButton, State)
	if ArmyJoinArmyPageVM:GetIsSearch() then
		---搜索结果客户端处理
		ArmyJoinArmyPageVM:SetIsSearchFullList(UIUtil.IsToggleButtonChecked(State))
	else
		ArmyMgr:ClearLastSearchArmyInput()
		if UIUtil.IsToggleButtonChecked(State) then
			ArmyMgr:SendArmySearchMsg(ArmyMgr:GetPageDataByType(1), true)
			ArmyJoinArmyPageVM:SetIsFull(true)
		else
			ArmyMgr:SendArmySearchMsg(ArmyMgr:GetPageDataByType(1), false)
			ArmyJoinArmyPageVM:SetIsFull(false)
		end
	end
end

--- 打开查找
function ArmyJoinArmyPageView:OnClickedShowSearch()
	self:SetSearchPanelState(true)
end
--- 设置搜索界面状态
function ArmyJoinArmyPageView:SetSearchPanelState(bShow)
	UIUtil.SetIsVisible(self.SingleBoxShowFull, not bShow, true)
	UIUtil.SetIsVisible(self.SearchInput, bShow)
	UIUtil.SetIsVisible(self.BtnSearch, not bShow, true);
end

--- 搜索
function ArmyJoinArmyPageView:OnSearchInput(SearchText)
	if LastFindCondition ~= SearchText then
		if SearchText == "" then
			SearchText = nil
		end
		ArmyJoinArmyPageVM:SaveArmyList()
		ArmyMgr:SendArmySearchByInputMsg(SearchText)
        LastFindCondition = SearchText
    end
end

function ArmyJoinArmyPageView:OnCloseSearch()
	LastFindCondition = nil
	--ArmyMgr:SendArmySearchByInputMsg()
	ArmyJoinArmyPageVM:RecoverArmyList()
	local ReIndex = ArmyJoinArmyPageVM:GetRecoverIndex()
	if ReIndex then
		self.TableViewAdapter:ScrollToIndex(ReIndex)
	end
	local ItemData = ArmyJoinArmyPageVM:GetCurSelectedItemData()
	if ItemData then
		ArmyMainVM:SetBGIcon(ItemData.GrandCompanyType)
	end
end

function ArmyJoinArmyPageView:OnIsSearchChanged(IsSearch)
	if IsSearch then
		self.SingleBoxShowFull:SetChecked(true, false)
	else
		ArmyMgr:ClearLastSearchArmyInput()
		local IsFull = ArmyJoinArmyPageVM:GetIsFull() or false
		self.SingleBoxShowFull:SetChecked(IsFull, false)
	end
end

return ArmyJoinArmyPageView