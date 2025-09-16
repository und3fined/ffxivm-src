---
--- Author: ds_herui
--- DateTime: 2023-12-26 16:11
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local AchievementTypeCfg = require("TableCfg/AchievementTypeCfg")
local AchievementDefine = require("Game/Achievement/AchievementDefine")
local AchievementUtil = require("Game/Achievement/AchievementUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local CommonUtil = require("Utils/CommonUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local ItemUtil = require("Utils/ItemUtil")
local MsgTipsID = require("Define/MsgTipsID")
local UIViewID = require("Define/UIViewID")
local UIBindableList = require("UI/UIBindableList")
local Achievement1stTabItemVM = require("Game/Achievement/VM/Item/Achievement1stTabItemVM")
local AchievementItemVM = require("Game/Achievement/VM/Item/AchievementItemVM")
local ProtoRes = require("Protocol/ProtoRes")

local LSTR
local FLOG_WARNING
local UIViewMgr
local AchievementMgr
local EToggleButtonState = _G.UE.EToggleButtonState
local AchievementHideType = ProtoRes.AchievementHideType

---@class AchievementMainPanelVM : UIViewModel
local AchievementMainPanelVM = LuaClass(UIViewModel)

---Ctor
function AchievementMainPanelVM:Ctor()
	self.TableViewTabsList = UIBindableList.New( Achievement1stTabItemVM )
	self.TableViewAchievementList = UIBindableList.New( AchievementItemVM )

	self.PanelTopVisible = true   -- 这个里面包含着FinishToggleButton按钮的显示
	self.TextTargetVisible = false
	self.TargetAchievementNum = 0
	self.EmptyPanelVisible = true
	self.PanelListVisible = false
	self.PanelGetAllVisible = false
	self.Spacer4ListOnlyVisible = false
	self.FinishToggleButtonState = EToggleButtonState.Unchecked
	self.LevelRewardEFFVisible = false
	self.TrackedBgVisible = false
	self.DropDownListVisible = false

	self.SelectTypeID = 0
	self.CategoryID = 0
	self.SelectAchievementID = 0
	self.EmptyPanelText = ""
	self.RichTextProcess = ""

	self.CurrentFiltrateTypeID = 1

	-- 纯数据暂未绑定
	self.SelectTypeVM = nil
	self.SelectCategoryVM = nil
	self.ShowAchievementDataList = {}
	self.HaveRewardIDList = {}
	self.ExtendView = nil
end

function AchievementMainPanelVM:OnInit()

end

function AchievementMainPanelVM:OnBegin()
	LSTR = _G.LSTR
	AchievementMgr = _G.AchievementMgr
	UIViewMgr = _G.UIViewMgr
	FLOG_WARNING = _G.FLOG_WARNING
end

function AchievementMainPanelVM:LoadTypeData()
	local TypeAllCfg = AchievementTypeCfg:FindAllCfg() or {}
	local TypeDataList = {}
	for i = 1, #TypeAllCfg do 
		if TypeAllCfg[i] ~= nil then
			local AchieveDataList = AchievementMgr:GetAchieveDataListFromTypeID(TypeAllCfg[i].ID)
			local IsAdd = false
			for j = 1, #AchieveDataList do
				if not ( not AchieveDataList[j].IsFinish and AchieveDataList[j].HideType == AchievementHideType.ACHIEVEMENT_HIDE_TYPE_HIDE_ACHIEVEMENT ) then
					IsAdd = true
					break
				end
			end

			if IsAdd then 
				table.insert(TypeDataList, {
					TypeID = TypeAllCfg[i].ID,
					Sort = TypeAllCfg[i].Sort,
					TypeName = TypeAllCfg[i].TypeName,
				})
			end
		end
	end

	table.sort(TypeDataList, function(A, B)
		return A.Sort < B.Sort
	end )

	table.insert(TypeDataList, 1, AchievementDefine.OverviewTypeDataTable)

	self.TableViewTabsList:UpdateByValues(TypeDataList)
end

function AchievementMainPanelVM:OnEnd()

end

function AchievementMainPanelVM:OnShutdown()

end

function AchievementMainPanelVM:ResetData()
	local ViewMode, _ = self.TableViewTabsList:Find(function(Item) return Item.TypeID == self.SelectTypeID end)
	if ViewMode ~= nil then
		ViewMode.ArrowUp = false
	end

	self.SelectTypeID = 0
	self.CategoryID = 0
	self.SelectAchievementID = 0
	self.FinishToggleButtonState = EToggleButtonState.Unchecked
	self.CurrentFiltrateTypeID = 1
end

function AchievementMainPanelVM:SetCurrentFiltrateTypeID(FiltrateTypeID)
	if self.CurrentFiltrateTypeID ~= FiltrateTypeID then
		self.CurrentFiltrateTypeID = FiltrateTypeID
		if #self.ShowAchievementDataList > 0 then
			AchievementMainPanelVM:SetTableViewAchievementList(self.ShowAchievementDataList)
		end
	end
end

function AchievementMainPanelVM:SetFinishToggleButtonState(State)
	if self.FinishToggleButtonState ~= State then
		self.FinishToggleButtonState = State
		if #self.ShowAchievementDataList > 0 then
			AchievementMainPanelVM:SetTableViewAchievementList(self.ShowAchievementDataList)
		end
	end
end

-- 设置成就等级奖励特效显示与否
function AchievementMainPanelVM:SetLevelRewardEFFVisible(TypeID)
	self.LevelRewardEFFVisible = AchievementUtil.IsCanGetLevelReward(TypeID)
end

-- 设置成就总点数
function AchievementMainPanelVM:SetTotalAchievePointText()
	local AchievementPoint = AchievementUtil.GetAchievementPointInfo(0)
	self.TotalAchievePointText = string.format(LSTR(720026), ItemUtil.GetItemNumText(AchievementPoint))  	-- "成就点：%s
end

--设置定位背景
function AchievementMainPanelVM:SetTrackedBgVisible(TrackedBgVisible)
	if self.TrackedBgVisible ~= TrackedBgVisible then 
		local ViewModel = self.TableViewAchievementList:Find(function(Item) return Item.ID == self.SelectAchievementID end )
		if ViewModel ~= nil then
			ViewModel:SetTrackedVisible(TrackedBgVisible)
		end
		self.TrackedBgVisible = TrackedBgVisible
	end
end

--------------------------------- 展示列表处理

--- 成就展示列排序
---@param LAchieve any
---@param RAchieve any
local AchievementShowSort = function(LAchieve, RAchieve)
	local LFinishAndReceive =  LAchieve.IsFinish and (not LAchieve.HaveReward)    	--已达成
	local LFinish = LAchieve.IsFinish and ( LAchieve.HaveReward)					--可领取
	local LUnFinish = not LAchieve.IsFinish											--进行中

	local RFinishAndReceive =  RAchieve.IsFinish and (not RAchieve.HaveReward)
	local RFinish =  RAchieve.IsFinish and ( RAchieve.HaveReward)
	local RUnFinish = not RAchieve.IsFinish

	if LFinish then
		if RFinish then
			return LAchieve.FinishTime > RAchieve.FinishTime
		else
			return true
		end
	elseif LUnFinish then
		if RFinish then
			return false
		elseif RUnFinish then
			return LAchieve.Sort < RAchieve.Sort
		elseif RFinishAndReceive then
			return true
		end
	elseif LFinishAndReceive then
		if RFinishAndReceive then
			return LAchieve.Sort < RAchieve.Sort
		else
			return false
		end
	end
end

--设置当前成就列表显示的数据
function AchievementMainPanelVM:SetTableViewAchievementList(DataList)
	self.ShowAchievementDataList = DataList
	local OnlyShowCompleted = self.FinishToggleButtonState == EToggleButtonState.Checked and self.PanelTopVisible
	local UseFiltering = self.DropDownListVisible
	local ShowDataList = {}

	if self.CategoryID ~= AchievementDefine.OverviewCategoryDataTable[2].CategoryID then
		for i = 1, #(DataList or {}) do
			DataList[i].IsShow = true
			if OnlyShowCompleted then
				DataList[i].IsShow = AchievementMgr:GetAchievementFinishState(DataList[i].ID)
			end
			if UseFiltering and DataList[i].IsShow then
				DataList[i].IsShow = AchievementUtil.CheckMeetFilterCriteria(self.CurrentFiltrateTypeID, DataList[i])
			end
			if DataList[i].IsShow then
				table.insert(ShowDataList, DataList[i])
			end
		end
	else
		for i = 1, #(DataList or {}) do
			DataList[i].IsShow = true
		end
		table.merge_table(ShowDataList, DataList)
	end

	local DataListNum = #DataList
	local ShowListNum = #ShowDataList

	if self.SelectTypeID == AchievementDefine.OverviewTypeDataTable.TypeID  then
		if self.CategoryID  == AchievementDefine.OverviewCategoryDataTable[1].CategoryID then
			-- 目标列表 规则能领取的在前面
			local AvailableList = {}
			local OriginalList = ShowDataList
			ShowDataList = {}
			for i = 1, #OriginalList do
				if OriginalList[i].IsFinish and ( OriginalList[i].HaveReward) then
					table.insert(AvailableList, OriginalList[i])
				else
					table.insert(ShowDataList, OriginalList[i])
				end
			end
			for i = #AvailableList, 1, -1 do
				table.insert(ShowDataList, 1, AvailableList[i])
			end

			self.EmptyPanelVisible = ShowListNum <= 0
			self.PanelListVisible = ShowListNum > 0

			if DataListNum > 0 and ShowListNum <= 0 then
				self.EmptyPanelText = RichTextUtil.GetText(LSTR(720005), "6C6964")
			elseif  DataListNum <= 0 then
				self.EmptyPanelText = RichTextUtil.GetText(string.format(LSTR(720008), AchievementDefine.TagetAchievementTotalNum), "6C6964")
			end
		elseif self.CategoryID == AchievementDefine.OverviewCategoryDataTable[2].CategoryID then
			self.EmptyPanelVisible = ShowListNum <= 0
			self.PanelListVisible = ShowListNum > 0

			if DataListNum > 0 and ShowListNum <= 0 then
				self.EmptyPanelText = RichTextUtil.GetText(LSTR(720005), "6C6964")
			elseif  DataListNum <= 0 then
				self.EmptyPanelText = RichTextUtil.GetText(LSTR(720007), "6C6964")
			end
		end
	else
		table.sort(ShowDataList, AchievementShowSort)

		self.EmptyPanelVisible = ShowListNum <= 0
		self.PanelListVisible = ShowListNum > 0

		if DataListNum > 0 and ShowListNum <= 0 then
			self.EmptyPanelText = RichTextUtil.GetText(LSTR(720005), "6C6964")
		elseif  DataListNum <= 0 then
			self.EmptyPanelText = RichTextUtil.GetText(LSTR(720006), "6C6964")
		end
	end

	self.TableViewAchievementList:UpdateByValues(ShowDataList)
	self:GetAllAttachShow()
end

-- 一件领取按钮显示的相关处理
function AchievementMainPanelVM:GetAllAttachShow()
	if #self.ShowAchievementDataList > 0 then
		local GetIDList = {}
		for i = 1, #self.ShowAchievementDataList do
			if self.ShowAchievementDataList[i].IsShow then
				table.insert(GetIDList, self.ShowAchievementDataList[i].ID)
			end
		end
		local HaveRewardIDList = AchievementMgr:GetHaveRewardList(GetIDList)
		self.PanelGetAllVisible = #(HaveRewardIDList) > 0
		self.HaveRewardIDList = HaveRewardIDList
	else
		self.PanelGetAllVisible = false
		self.HaveRewardIDList = {}
	end
end

function AchievementMainPanelVM:BtnGetAllClick()
	if not self.PanelGetAllVisible then
		return
	end

	AchievementMgr:GetAchievementReward(self.HaveRewardIDList)
end


--------------------------------- 类型菜单处理
function AchievementMainPanelVM:SetSelectType(TypeID)
	if TypeID == nil or TypeID == 0 or TypeID == self.SelectTypeID then
		return
	end
	if self.SelectTypeVM ~= nil then
		self.SelectTypeVM:SetToggleBtnState(false)
		self.SelectTypeVM = nil
	end
	local ViewMode, _ = self.TableViewTabsList:Find(function(Item) return Item.TypeID == TypeID end)
	if ViewMode ~= nil then
		self.SelectTypeVM = ViewMode
		self.SelectTypeID = TypeID
		ViewMode:SetToggleBtnState(true)
	end
end

function AchievementMainPanelVM:SetSelectCategoryID(CategoryID)
	local InvalidParameter = (CategoryID == 0 or CategoryID == nil)
	if not InvalidParameter then
		local TypeID = AchievementUtil.GetTypeIDFromCategoryID(CategoryID)
		if TypeID == 0 then
			return
		end
		if self.SelectTypeID ~= TypeID then
			self:SetSelectType(TypeID)
		end
	end

	if self.SelectTypeVM == nil then
		return
	end
	local ChildVM = self.SelectTypeVM:GetChildVM(CategoryID)
	if ChildVM ~= nil then
		if self.SelectCategoryVM ~= nil then
			self.SelectCategoryVM:SetSelectedState(false)
		end
		self.SelectCategoryVM = ChildVM
		self.CategoryID = ChildVM.CategoryID
		self.SelectCategoryVM:SetSelectedState(true)
	end

	self:SetSelectAchievemwntID(0)
	self.Spacer4ListOnlyVisible = false

	--  详情
	if self.SelectTypeID == AchievementDefine.OverviewTypeDataTable.TypeID  then
		self.DropDownListVisible = false
		if self.CategoryID  == AchievementDefine.OverviewCategoryDataTable[1].CategoryID then
	        local TargetAchievementDataList = AchievementMgr:GetTargetAchievementDataList() or {}
			self.TargetAchievementNum = #TargetAchievementDataList
			self.PanelTopVisible = true
			self.TextTargetVisible = true
			self:SetTableViewAchievementList(TargetAchievementDataList)
		elseif self.CategoryID == AchievementDefine.OverviewCategoryDataTable[2].CategoryID then
			self.PanelTopVisible = false
			self.TextTargetVisible = false
			self.Spacer4ListOnlyVisible = true
			local NewAchievementDataList = AchievementMgr:GetNewAchievementDataList() or {}
			self:SetTableViewAchievementList(NewAchievementDataList)
		end
	else
		self.TextTargetVisible = false
		self.DropDownListVisible = true
		self.PanelTopVisible = true
		local ShowAchievementDataList = AchievementMgr:GetAchieveDataListFromCategoryID(self.CategoryID ) or {}
		ShowAchievementDataList = AchievementUtil.CheckShowFromHideType(ShowAchievementDataList)
		self:SetTableViewAchievementList(ShowAchievementDataList)
	end

	_G.ObjectMgr:CollectGarbage(false, true, false)
end

function AchievementMainPanelVM:SetSelectAchievemwntID(AchievementID)
	local ViewModel = self.TableViewAchievementList:Find(function(Item) return Item.ID == AchievementID end )
	if ViewModel == nil then
		if AchievementID ~= 0 then
			FLOG_WARNING(string.format("SetSelectAchievemwntID: TableViewAchievementList no found id: %s AchievementItemVM", tostring(AchievementID)))
		end
		self.SelectAchievementID = 0
	else
		self.SelectAchievementID = ViewModel.ID
	end
end

-- 收藏回馈
function AchievementMainPanelVM:CollectionSucceed(IsAdd, AchieveIDs)
	local DetailShow = false
	local View = UIViewMgr:FindVisibleView(UIViewID.AchievementDetailWin)
	if View ~= nil then
		View:CollectionSucceed(IsAdd, AchieveIDs)
		DetailShow = true 
	end

	for i = 1, #AchieveIDs do
		local ViewModel = self.TableViewAchievementList:Find(function(Item) return Item.ID == AchieveIDs[i] end )
		if ViewModel ~= nil then
			if IsAdd then
				ViewModel:SetToggleBtnFavorState(EToggleButtonState.Checked)  
				if not DetailShow then
					MsgTipsUtil.ShowTipsByID(MsgTipsID.AchievementAddTarget, nil, string.formatint(AchievementMgr:GetTargetAchievementNum())) 
				end
			else
				ViewModel:SetToggleBtnFavorState(EToggleButtonState.Unchecked)
				if not DetailShow then
				   MsgTipsUtil.ShowTipsByID(MsgTipsID.AchievementRemoveTarget, nil, string.formatint(AchievementMgr:GetTargetAchievementNum()))
				end
			end
		end
	end
	local TargetAchievementDataList = AchievementMgr:GetTargetAchievementDataList() or {}
	self.TargetAchievementNum = #TargetAchievementDataList

	if (not IsAdd) and self.CategoryID == AchievementDefine.OverviewCategoryDataTable[1].CategoryID then
		self:SetTableViewAchievementList(TargetAchievementDataList)
	end
end

-- 领取成就奖励成功
function AchievementMainPanelVM:ReceiveAwardSucceed(AchieveIDs, AwardList)
	local View = UIViewMgr:FindVisibleView(UIViewID.AchievementDetailWin)
    for i = 1, #AchieveIDs do
		if View ~= nil then
			local ViewModel = View.AchievementTypeDataList:Find(function(Item) return Item.ID == AchieveIDs[i] end )
			if ViewModel ~= nil then
				ViewModel:ReceiveAwardSucceed()
			end
		end
		local ViewModel =  self.TableViewAchievementList:Find(function(Item) return Item.ID == AchieveIDs[i] end )
		if ViewModel ~= nil then
			ViewModel:ReceiveAwardSucceed()
		end
	end
	self:GetAllAttachShow()
end

-- 设置扩展小视图
function AchievementMainPanelVM:SetExendView(NewView)
	if self.ExtendView ~= NewView then 
		if self.ExtendView and CommonUtil.IsObjectValid(self.ExtendView.Object) and self.ExtendView:IsVisible() then
			self.ExtendView:Hide()
		end
	end
	self.ExtendView = NewView
	if NewView == nil then
		-- 关闭的时候检查下货币的展示界面
		local ScoreTipsView = UIViewMgr:FindView(UIViewID.CurrencyTips)
		if ScoreTipsView ~= nil and CommonUtil.IsObjectValid(ScoreTipsView.Object) and ScoreTipsView:IsVisible() then   
			ScoreTipsView:Hide()
		end
	end
end

-- 刷新当前展示成就的进度
function AchievementMainPanelVM:RefreshDisplaysAchievementsProgress()
	if UIViewMgr then
		local View = UIViewMgr:FindVisibleView(UIViewID.AchievementMainPanel)
		if View ~= nil then
			local VmItems = self.TableViewAchievementList:GetItems()
			for i = 1, #VmItems do 
				local AchievemwntInfo = AchievementMgr:GetAchievementInfo(VmItems[i].ID)
				if AchievemwntInfo ~= nil then
					VmItems[i]:ProcessTextDisplays(AchievemwntInfo)
				end
			end
		end
	end
end

-- 打开成就等级奖励界面
function AchievementMainPanelVM:OpenTypeLevelRewardView()
	local function OnGetAwardCallBack(Index, ItemData, ItemView)
        if ItemData then
			local LevelAwardInfoList = AchievementUtil.GetLevelRewardList(0) or {}
			local LevelAwardInfo = table.find_item(LevelAwardInfoList, ItemData.CollectTargetNum, "BasicAchievePoint")
			if LevelAwardInfo == nil then
				return
			end
            if ItemData.IsGetProgress and not ItemData.IsCollectedAward then
                AchievementMgr:GetAchievementLevelReward(0, LevelAwardInfo.Level )
            end
        end
    end

	local function ItemClickCallback(Index, ItemData, ItemView)
		if ItemData then
			local LevelAwardInfoList = AchievementUtil.GetLevelRewardList(0) or {}
			local LevelAwardInfo = table.find_item(LevelAwardInfoList, ItemData.CollectTargetNum, "BasicAchievePoint")
			if ItemData.IsGetProgress and not ItemData.IsCollectedAward then
				AchievementMgr:GetAchievementLevelReward(0, LevelAwardInfo.Level )
			else
				local ItemTipsUtil = require("Utils/ItemTipsUtil")
				ItemTipsUtil.ShowTipsByResID(ItemData.AwardID, ItemView)
			end
		end
    end


	local LevelInfo = AchievementMgr:GetAchievementLevelRewardInfo(0)
	if LevelInfo == nil then
		return 
	end
	local Params = {
		ModuleID = nil,
		CollectedNum = tostring(LevelInfo.AchievementPoint),
		MaxCollectNum = nil,
		AreaName = nil,
		OnGetAwardCallBack = OnGetAwardCallBack,
		TextCurrent = LSTR(720027),     -- "当前成就点"
		IgnoreIsGetProgress = true,
		ItemClickCallback = ItemClickCallback,
	}

	local AwardSelectIndex = 1
	local AwardInfoList = {}
	local LevelAwardInfoList = AchievementUtil.GetLevelRewardList(0) or {}
	for i = #LevelAwardInfoList, 1, -1 do
		local Reward = LevelAwardInfoList[i].RewardList[1] or {}
		local AwardInfo = {
			CollectTargetNum = LevelAwardInfoList[i].BasicAchievePoint,
			AwardID = Reward.ResID,
			AwardNum = Reward.Num,
			IsGetProgress = LevelInfo.AchievementPoint >= LevelAwardInfoList[i].BasicAchievePoint and not LevelAwardInfoList[i].Received, -- 是否已达到奖励进度
			IsCollectedAward = LevelAwardInfoList[i].Received, -- 是否已领奖
		}
		if LevelInfo.AchievementPoint <= LevelAwardInfoList[i].BasicAchievePoint or AwardInfo.IsGetProgress then
			AwardSelectIndex = i
		end
		table.insert(AwardInfoList, 1, AwardInfo)
	end

	Params.AwardList = AwardInfoList
	Params.AwardSelectIndex = AwardSelectIndex

    UIViewMgr:ShowView(UIViewID.CollectionAwardPanel, Params)
end

-- 领取等级奖励成功
function AchievementMainPanelVM:ReceiveLevelAwardSucceed(Level)
	self:SetLevelRewardEFFVisible(0)

	local AwardView = UIViewMgr:FindVisibleView(UIViewID.CollectionAwardPanel)
	if AwardView and AwardView.AwardVMList then
		local LevelAwardInfoList = AchievementUtil.GetLevelRewardList(0) or {}
		local LevelAwardInfo = table.find_item(LevelAwardInfoList, Level, "Level") or {}
		local AwardVM = AwardView.AwardVMList:Find(function(Item) return Item.CollectTargetNum == LevelAwardInfo.BasicAchievePoint end )
		if AwardVM ~= nil then
			AwardVM.IsCollectedAward = true
			AwardVM.IsGetProgress = false
		end
		local AwardItem = table.find_item(AwardView.AwardList or {}, LevelAwardInfo.BasicAchievePoint, "CollectTargetNum") or {}
		if AwardItem ~= nil then
			AwardItem.IsCollectedAward = true
			AwardItem.IsGetProgress = false
		end
	end
end


--要返回当前类
return AchievementMainPanelVM