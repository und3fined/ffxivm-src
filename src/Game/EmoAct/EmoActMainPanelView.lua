---
--- Author: Administrator
--- DateTime: 2023-09-15 15:03
--- Description: 情感动作
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local WidgetCallback = require("UI/WidgetCallback")
local EmoActPanelVM = require("Game/EmoAct/EmoActPanelVM")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local EmotionCfg = require("TableCfg/EmotionCfg")
local EmotionMgr = require("Game/Emotion/EmotionMgr")
local EmotionUtils = require("Game/Emotion/Common/EmotionUtils")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local EmotionDefines = require("Game/Emotion/Common/EmotionDefines")
local TipsUtil = require("Utils/TipsUtil")
local MajorUtil = require("Utils/MajorUtil")
local UIBinderSetViewParams = require("Binder/UIBinderSetViewParams")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local DataReportUtil = require("Utils/DataReportUtil")
local LSTR = _G.LSTR	--多语言ukey值对应文本配置在21EmotionText.xlsx
local EventID = _G.EventID

---@class EmoActMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommEmpty CommBackpackEmptyView
---@field CommTabs CommHorTabsView
---@field RichTextUnselected URichTextBox
---@field SearchBar CommSearchBarView
---@field TableViewEmoAct UTableView
---@field TableViewRecent UTableView
---@field TableViewScenes UTableView
---@field ToggleBtnFavorite UToggleButton
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimUpdateEmoAct UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EmoActMainPanelView = LuaClass(UIView, true)

function EmoActMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommEmpty = nil
	--self.CommTabs = nil
	--self.RichTextUnselected = nil
	--self.SearchBar = nil
	--self.TableViewEmoAct = nil
	--self.TableViewRecent = nil
	--self.TableViewScenes = nil
	--self.ToggleBtnFavorite = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimUpdateEmoAct = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EmoActMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommEmpty)
	self:AddSubView(self.CommTabs)
	self:AddSubView(self.SearchBar)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EmoActMainPanelView:OnInit()
	---情感动作类型：收藏0、一般1、持续2、表情3
	self.TabIDs = {
		collectionTab  = 0,
		OnceEmotionTab = 1,
		LoopEmotionTab = 2,
		FaceEmotionTab = 3
	}
	self.TabNames = {
		[self.TabIDs.collectionTab ] = LSTR(210005),    --"收藏"
		[self.TabIDs.OnceEmotionTab] = LSTR(210006),    --"一般"
		[self.TabIDs.LoopEmotionTab] = LSTR(210007),    --"持续"
		[self.TabIDs.FaceEmotionTab] = LSTR(210008),    --"表情"
	}
	---类型列表的图片路径
	local collectionIconPath  = EmotionUtils.GetScenesIconPath("UI_EmoAct_Tab_Favorite_Off_png")
	local OnceEmotionIconPath = EmotionUtils.GetScenesIconPath("UI_EmoAct_Tab_Once_Off_png")
	local LoopEmotionIconPath = EmotionUtils.GetScenesIconPath("UI_EmoAct_Tab_Loop_Off_png")
	local FaceEmotionIconPath = EmotionUtils.GetScenesIconPath("UI_EmoAct_Tab_Face_Off_png")
	---类型列表
	self.ListData = {
		{Name = self.TabIDs.collectionTab , IconPath = collectionIconPath , RedDotName = EmotionDefines.TabRedDots.Favorite},
		{Name = self.TabIDs.OnceEmotionTab, IconPath = OnceEmotionIconPath, RedDotName = EmotionDefines.TabRedDots.Once},
		{Name = self.TabIDs.LoopEmotionTab, IconPath = LoopEmotionIconPath, RedDotName = EmotionDefines.TabRedDots.Loop},
		{Name = self.TabIDs.FaceEmotionTab, IconPath = FaceEmotionIconPath, RedDotName = EmotionDefines.TabRedDots.Face},
	}
	self.ScenesIconPath = {
		Stand = EmotionUtils.GetScenesIconPath("UI_EmoAct_Scenes_Stand_Off_png"),
		Sit   = EmotionUtils.GetScenesIconPath("UI_EmoAct_Scenes_Sit_Off_png"),
		Seat  = EmotionUtils.GetScenesIconPath("UI_EmoAct_Scenes_Seat_Off_png"),
		Ride  = EmotionUtils.GetScenesIconPath("UI_EmoAct_Scenes_Ride_Off_png"),
	}

	self.TableViewEmoActAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewEmoAct, self.OnSelectChanged, true)
	self.TableViewRecentAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewRecent, self.OnRecentChanged, true)
	self.TableViewScenesAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewScenes, self.OnScenesClicked, true)

	self.bIsFind = false   		  	---是否在搜索中
	self.EmoActText = nil  		  	---用于在搜索的值
	EmotionMgr:InitRedDot()
end

--- 切换类型
function EmoActMainPanelView:OnTypeSelectChanged(Index, ItemData, ItemView)
	EmoActPanelVM.SelectList = {}
	if self.bIsFind and self.EmoActText then
		--在切换类型的时候记得先退出搜索状态
		self.SearchBar:OnClickButtonCancel()
	end
	if Index then
		EmoActPanelVM:SetEmotionFilter(Index)
	end
end

function EmoActMainPanelView:OnSelectChanged()
end

function EmoActMainPanelView:OnRecentChanged()
end

function EmoActMainPanelView:OnShow()
	self.RichTextUnselected:SetText(LSTR(210002))	--"选中动作，进行查看和使用"
	self.SearchBar:SetHintText(LSTR(210031))		--"搜索动作"
	local ArgIndex = EmoActPanelVM:GetEmotionFilter()
	if self.Params and type(self.Params) == "table" then
		if self.Params.TabType then
			ArgIndex = self.Params.TabType+1
		end
		if self.Params.EmoActID then
			EmoActPanelVM.ShowTemporaryTagID = self.Params.EmoActID
			self.TagTimerID = _G.TimerMgr:AddTimer(self, self.SetScrollCenter, 0.2, 0, 1, {EmoActID = self.Params.EmoActID})
		end
		if self.Params.QuestEmoID then
			self.QuestTimerID = _G.TimerMgr:AddTimer(self, self.SetScrollCenter, 0.2, 0, 1, {EmoActID = self.Params.QuestEmoID})
		end
		if self.Params.EntityID then
			EmotionMgr:SetNewTargetEntityID(self.Params.EntityID)
		else
			EmotionMgr:SetNewTargetEntityID(0)
		end
	end
	self.CommTabs:OnShow()
	self.CommTabs:SetSelectedIndex(ArgIndex)	--打开对应类型的界面
	self:SetTypeRedDot()

	self:SetFavoriteVisible(false)
	UIUtil.SetIsVisible(self.CommEmpty, false)
	--上报界面访问情况
	DataReportUtil.ReportSystemFlowData("EmotionSystemInfo", "4", tostring(ArgIndex))
end

function EmoActMainPanelView:OnHide()
	EmoActPanelVM.EnableID = nil
	
	_G.EventMgr:SendEvent(EventID.OnEmotionPanelClose, EmotionMgr.TargetQuestEmotionID)

	---- 关闭时退出搜索状态  ↓-------
	self.bIsFind = false
	self.EmoActText = nil
	UIUtil.SetIsVisible(self.CommEmpty, false)
	---- 关闭时退出搜索状态  ↑-------

	self:SetFavoriteVisible(false)
	_G.TimerMgr:CancelTimer(self.QuestTimerID)
	EmoActPanelVM.SelectList = {}
	EmoActPanelVM.ShowTemporaryTagID = nil
end

--- 这个注册只会在首次打开界面时执行一次
function EmoActMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnFavorite, self.OnBtnFavoriteClick)
	self.SearchBar:SetCallback(self, self.OnChangeCallback, nil, self.OnClickCancelSearchBar)
	UIUtil.AddOnSelectionChangedEvent(self, self.CommTabs, self.OnTypeSelectChanged)
end

--- 这个注册会在每次打开界面时都执行
function EmoActMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.PostEmotionEnter, 	self.OnGameEventPostEmotionEnter)	--播放动作
	self:RegisterGameEvent(EventID.PostEmotionEnd  , 	self.OnGameEventPostEmotionEnd)	--播放结束
	self:RegisterGameEvent(EventID.MajorDead	   , 	self.OnGameEventMajorDead)		--主角死亡
	self:RegisterGameEvent(EventID.ActorReviveNotify,	self.OnGameEventActorRevive)		--角色复活
	self:RegisterGameEvent(EventID.EmotionRefreshItemUI, self.OnGameEventEmotionRefreshItemUI)--刷新情感动作UI
	self:RegisterGameEvent(EventID.EmotionUpdateFavorite, self.OnGameEventEmotionUpdateFavorite)--刷新收藏UI
end

function EmoActMainPanelView:OnGameEventPostEmotionEnter(Params)
	if nil == Params then return end
	if EmoActPanelVM.SelectList == {} then return end
	if Params.ULongParam1 == MajorUtil.GetMajorEntityID() then
		local MaxKey
		for Key, _ in pairs(EmoActPanelVM.SelectList) do
			if not MaxKey or Key > MaxKey then
				MaxKey = Key
			end
		end
		local k, v = next(EmoActPanelVM.SelectList)
		while k do
			if k < MaxKey then
				if v and v.ItemView then
					v.ItemView:SetSelectVisibity(false)
				end
				EmoActPanelVM.SelectList[k] = nil		--清除旧view，只存最新的一个
			end
			k, v = next(EmoActPanelVM.SelectList, k)
		end
		if EmoActPanelVM.SelectList[MaxKey] then
			if CommonUtil.IsObjectValid(EmoActPanelVM.SelectList[MaxKey].ItemView) then
				EmoActPanelVM.SelectList[MaxKey].ItemView:SetSelectVisibity(true)
			else
				EmoActPanelVM.SelectList[MaxKey] = nil
			end
		end
	end
end

function EmoActMainPanelView:OnGameEventPostEmotionEnd(Params)
	if nil == Params then return end
	if EmoActPanelVM.SelectList == {} then return end
	if Params.ULongParam1 == MajorUtil.GetMajorEntityID() then
		local MaxKey, MinKey
		for Key, _ in pairs(EmoActPanelVM.SelectList) do
			if not MaxKey or Key > MaxKey then
				MaxKey = Key
			end
			if not MinKey or Key < MinKey then
				MinKey = Key
			end
		end
		local NewSelect = EmoActPanelVM.SelectList[MaxKey]
		if MaxKey ~= nil and NewSelect ~= nil then
			if CommonUtil.IsObjectValid(NewSelect.ItemView) then
			--	NewSelect.ItemView:SetEFFVisible(false)
			else
				EmoActPanelVM.SelectList[MaxKey] = nil
			end
			local EndID = Params.IntParam1
			if MinKey ~= nil and MinKey ~= MaxKey and NewSelect.ID ~= EndID then
				local OldSelect = EmoActPanelVM.SelectList[MinKey]
				if CommonUtil.IsObjectValid(OldSelect.ItemView) then
					-- if OldSelect.ID ~= nil and OldSelect.ID == EndID then
					-- 	OldSelect.ItemView:SetEFFVisible(false)
					-- end
				else
					EmoActPanelVM.SelectList[MinKey] = nil
				end
			end
		end
	end
end

--- 获取正在显示的Item
function EmoActMainPanelView:GetItemViewList()
	local ItemViewList = {}
	if self:IsLike() then
		--最近使用、收藏
		for _, RecentList in pairs(self.TableViewRecentAdapter.ItemViewList) do
			for _, Item in pairs(RecentList.TableViewEmoActAdapter.ItemViewList) do
				if nil ~= Item and nil ~= Item.Params.Data and nil ~= Item.Params.Data.ID then
					table.insert(ItemViewList,Item)
				end
			end
		end
	else
		--非收藏分类
		ItemViewList = self.TableViewEmoActAdapter.ItemViewList
	end
	return ItemViewList
end

--主角死亡，禁用所有动作
function EmoActMainPanelView:OnGameEventMajorDead()
	if MajorUtil.IsMajorDead() then
		local ItemViewList = self:GetItemViewList()
		for _, Item in pairs(ItemViewList) do
			if Item then
				Item:SetEnable(false)
			end
		end
	end
end

--主角复活，刷新动作可用性
function EmoActMainPanelView:OnGameEventActorRevive(Params)
	if nil == Params then return end
	if Params.ULongParam1 == MajorUtil.GetMajorEntityID() then
		self:OnGameEventEmotionRefreshItemUI()
	end
end

--- 刷新小图标
function EmoActMainPanelView:OnGameEventEmotionRefreshItemUI(Params)
	if nil ~= self.TimeID then
		_G.TimerMgr:CancelTimer(self.TimeID)
		self.TimeID = nil
	end
	self.TimeID = _G.TimerMgr:AddTimer(self, function()
		self.UpdateItemList = {}	--待更新的小图标
		self:UpdateEnableList(self:GetEmotionList())
		self:SetItemEnable(self:GetItemViewList())
	end, 0.1, 0, 1)
end

--- 获取当前分类的动作ID
function EmoActMainPanelView:GetEmotionList()
	local EmotionList = {}
	if self:IsLike() then
		--最近使用、收藏
		for _, RecentList in pairs(EmoActPanelVM.ListRecentFavorite) do
			for _, Item in pairs(RecentList.EmotionList) do
				if nil ~= Item and nil ~= Item.ID then
					table.insert(EmotionList,Item)
				end
			end
		end
	else
		--非收藏分类
		EmotionList = EmoActPanelVM.CurEmotionList.Items
	end
	return EmotionList
end

--- 刷新记录Item的可用状态
function EmoActMainPanelView:UpdateEnableList(EmotionList)
	if EmotionList == nil or #EmotionList < 1 then return end
	local bIsEnable = true
	for _, Item in pairs(EmotionList) do
		local EmoActID = Item.ID
		bIsEnable = EmotionMgr:IsEnableID(EmoActID)
		if EmoActPanelVM.CanUseList[EmoActID] ~= bIsEnable then
			self.UpdateItemList[EmoActID] = bIsEnable		--仅对有变更且已显示的View进行手动更新EmoActMainPanelView:SetItemEnable
			EmoActPanelVM.CanUseList[EmoActID] = bIsEnable	--在EmoActSlotView更新ID时会用到
		end
	end
end

--- 设置可用性
function EmoActMainPanelView:SetItemEnable(ItemViewList)
	for _, Item in pairs(ItemViewList) do
		if CommonUtil.IsObjectValid(Item) then
			local ID = Item.Params.Data.ID
			if nil ~= self.UpdateItemList[ID] then
				Item:SetEnable(self.UpdateItemList[ID])
			end
		end
	end
	self.UpdateItemList = {}	--使用后一定要清空
end

function EmoActMainPanelView:OnGameEventEmotionUpdateFavorite()
	self.ToggleBtnFavorite:SetIsChecked(EmoActPanelVM.bIsFavorite, true)
	self:UpdateAllFavorite()
end

function EmoActMainPanelView:OnRegisterBinder()
	local Binders = {
		---存放所有常用动作
		{ "CurEmotionList", UIBinderUpdateBindableList.New(self, self.TableViewEmoActAdapter) },

		---存放所有最近+收藏
		{ "ListRecentFavorite", UIBinderUpdateBindableList.New(self, self.TableViewRecentAdapter) },

		---将“情感动作类型”设置为：收藏0、一般1、持续2、表情3
		{ "CurEmotionFilter", UIBinderValueChangedCallback.New(self, nil, self.OnFilterChange) },

		---触发收藏
		{ "bIsFavorite", UIBinderSetIsChecked.New(self, self.ToggleBtnFavorite) },

		---选中的数据ID
		{"EnableID", UIBinderValueChangedCallback.New(self, nil, self.OnDataChanged) },
		
		---顶侧类型选择VM
		-- { "CommSideFrameTabsVM", UIBinderSetViewParams.New(self, self.CommTabs)},
	}
	self:RegisterBinders(EmoActPanelVM, Binders)
end

--- 切换情感动作类型
function EmoActMainPanelView:OnFilterChange(NewValue)
	if self.bIsFind and self.EmoActText then
--		self.TableTypeViewAdapter:CancelSelected()	--全局搜索不能切换类型
--		return

	end
--	self.TableTypeViewAdapter:SetSelectedIndex(EmoActPanelVM:GetEmotionFilter() + 1)
	self:UpdateAllEmoAct(NewValue - 1)
	self:SetFavoriteVisible(false)	  --设置收藏状态的可视性
	-- iOS GC
	_G.ObjectMgr:CollectGarbage(false, true, false)
	EmoActPanelVM.EnableID = nil
end

--- 更新情感动作：当数据发生变化时会调用到，用于选择或切换 情感动作类型：收藏0、一般1、持续2、表情3
---@param NewValue 传入的情感动作类型
function EmoActMainPanelView:UpdateAllEmoAct(NewValue)
	if NewValue == EmotionDefines.EmotionTypeId.collectionTab then
		UIUtil.SetIsVisible(self.TableViewRecent,true)
		UIUtil.SetIsVisible(self.TableViewEmoAct,false)
		self:GetRecentViewSize()
		if self.bIsFind and self.EmoActText then
			self:OnChangeCallback(self.EmoActText)  				   		---正在搜索
		else
			EmoActPanelVM.ListRecentFavorite = EmotionMgr:RecentFavoriteTab()	---更新列表
		end
	else
		UIUtil.SetIsVisible(self.TableViewRecent,false)
		UIUtil.SetIsVisible(self.TableViewEmoAct,true)

		if self.bIsFind and self.EmoActText then
			self:OnChangeCallback(self.EmoActText)  				   		---正在搜索
		else
			EmoActPanelVM.CurEmotionList:Clear()
			EmoActPanelVM.CurEmotionList:UpdateByValues(EmotionMgr:EmotionTab(NewValue))   	---更新列表
		end
	end
	self:OnGameEventEmotionRefreshItemUI()
end

--- 选中ID时，会更新主界面最下面的动作详情
function EmoActMainPanelView:OnDataChanged(EmotionID)
	if EmotionID ~= nil then

		--【使用场景详情】
			--  1、目前共4种：站立、坐在地面、座椅、坐骑。钓鱼动作只有一个，暂时不考虑。
			--	2、此TableCanUse[1]为表中查找到的第一个CanUse，对应是数据表CanUse[0]列数据。
			--	3、后续若增加钓鱼、漂浮、潜水等，需要在下面添加对应图标地址
		self:SetFavoriteVisible(true)
		local ID = tonumber(EmotionID)
		local TableCanUse = EmotionCfg:FindValue(ID, "CanUse")
		local Scenes = {
			{CanUse = TableCanUse[1], IconPath = self.ScenesIconPath.Stand},
			{CanUse = TableCanUse[2], IconPath = self.ScenesIconPath.Sit},
			{CanUse = TableCanUse[3], IconPath = self.ScenesIconPath.Seat},
			{CanUse = TableCanUse[4], IconPath = self.ScenesIconPath.Ride},
		}
		self.TableViewScenesAdapter:UpdateAll(Scenes)

		--【收藏详情】
		EmoActPanelVM.bIsFavorite = EmotionMgr:IsSavedFavoriteID(EmotionID)
		DataReportUtil.ReportEasyUseFlowData(3, EmotionID, 1)
	end
end

--- 点击触发收藏
function EmoActMainPanelView:OnBtnFavoriteClick()
	if EmoActPanelVM.EnableID == nil then
		return
	end

	EmotionMgr:SendFavoriteReq(EmoActPanelVM.EnableID)

	_G.TimerMgr:AddTimer(self, function()
		self.ToggleBtnFavorite:SetIsChecked(EmoActPanelVM.bIsFavorite, true)
	end, 0.5, 0, 1)
end

--- 当前在收藏分类时，点击收藏或取消才会更新Item列表
function EmoActMainPanelView:UpdateAllFavorite()
	if self:IsLike() then
		if self.bIsFind and self.EmoActText then
			self:OnChangeCallback(self.EmoActText)  				---正在搜索
		else
			local EmoActList = EmotionMgr:RecentFavoriteTab()
			if #EmoActList >= 2 then		--若有最近使用，则表里会依次存放：1、最近使用列表 2、收藏列表
				EmoActPanelVM.ListFavorite = EmoActList[2].EmotionList
			elseif #EmoActList == 1 then
				EmoActPanelVM.ListFavorite = EmoActList[1].EmotionList
			end
		end
	end
end

--- 点击右下角使用场景详情图标提示
function EmoActMainPanelView:OnScenesClicked(Index, ItemData, ItemView)
	local CanUseName = {
		LSTR(210009),   --"站立状态"
		LSTR(210010),   --"坐在地上"
		LSTR(210011),   --"座椅状态"
		LSTR(210012)}   --"坐骑状态"
	local IsScenes = {
		LSTR(210013),   --"不可使用该情感动作"
		LSTR(210014)}   --"可使用该情感动作"
	if ItemData and ItemData.CanUse and self.TableViewScenes then
		local ScenesText = CanUseName[Index]..IsScenes[ItemData.CanUse + 1]

		---点击小图标时，在左上侧显示通用提示tips
		local ItemViewSize = UIUtil.GetWidgetSize(ItemView)
		TipsUtil.ShowInfoTips(ScenesText, ItemView, _G.UE.FVector2D(-160, ItemViewSize.Y / 2 - 15), _G.UE.FVector2D(1, 0.5))
	end
end

--- 设置收藏、动作详情的可视性
function EmoActMainPanelView:SetFavoriteVisible(Visible)
	UIUtil.SetIsVisible(self.ToggleBtnFavorite, Visible, true, true)
	UIUtil.SetIsVisible(self.TableViewScenes, Visible)
	UIUtil.SetIsVisible(self.RichTextUnselected, not Visible)
end

--- 清空搜索框
function EmoActMainPanelView:OnClickCancelSearchBar()
	self.bIsFind = false
	self.EmoActText = nil
	UIUtil.SetIsVisible(self.CommEmpty, false)

	self:OnFilterChange(EmoActPanelVM:GetEmotionFilter())
end

--- 实时模糊搜索(全局搜索)
function EmoActMainPanelView:OnChangeCallback(Text)
	local function TextIsLegalCallback(bCan)
		if bCan == false then
			print("[EmoActMainPanelView] 当前文本不可使用，请重新输入")
		end
	end
	_G.JudgeSearchMgr:QueryTextIsLegal(Text, TextIsLegalCallback, true, LSTR(10057))
	
	Text = string.gsub(Text, "[%[]", "[[]")
	Text = string.gsub(Text, "[%]]", "[]]")
	Text = string.gsub(Text, "[%(]", "[(]") --规避)(%][.
	Text = string.gsub(Text, "[%)]", "[)]")
	Text = string.gsub(Text, "[%.]", "[.]")

	self.bIsFind = true
	self.EmoActText = Text
	if self:IsLike() then
		UIUtil.SetIsVisible(self.TableViewRecent, false)
		UIUtil.SetIsVisible(self.TableViewEmoAct, true)
	end

	if string.isnilorempty(Text) then
		self:OnClickCancelSearchBar()
		return
	end
	if string.find(Text, "%%") then
		EmoActPanelVM.CurEmotionList:UpdateByValues({})
		UIUtil.SetIsVisible(self.CommEmpty, true)
		self.CommEmpty:SetTipsContent(LSTR(210015))	--"未搜索到该情感动作"
		return
	end

	local AllEmotion = {}
	AllEmotion = EmotionMgr:EmotionTab()

	local CurEmotionList = {}
	for k,v in ipairs(AllEmotion) do
		local EmotionName = v.EmotionName
		if EmotionName ~= '' and EmotionName ~= nil then
			if string.find(EmotionName,Text) then
				table.insert(CurEmotionList,v)
			end
		end
	end

	EmoActPanelVM.CurEmotionList:Clear()
	EmoActPanelVM.CurEmotionList:UpdateByValues(CurEmotionList)
	EmoActPanelVM.SelectList = {}
	if #CurEmotionList == 0 then
		UIUtil.SetIsVisible(self.CommEmpty, true)
		self.CommEmpty:SetTipsContent(LSTR(210015))	--"未搜索到该情感动作"
	else
		UIUtil.SetIsVisible(self.CommEmpty, false)
	end
	self:OnGameEventEmotionRefreshItemUI()

	--上报搜索到的情感动作ID
	if nil ~= self.ReportTimeID then
		_G.TimerMgr:CancelTimer(self.ReportTimeID)
		self.ReportTimeID = nil
	end
	self.ReportTimeID = _G.TimerMgr:AddTimer(self, function()
		for _, v in pairs(CurEmotionList) do
			DataReportUtil.ReportSystemFlowData("EmotionSystemInfo", "5", tostring(v.ID))
		end
	end, 0.2, 0, 1)
end

function EmoActMainPanelView:IsLike()
	return EmoActPanelVM:GetEmotionFilter() - 1 == EmotionDefines.EmotionTypeId.collectionTab
end

--- 将ID跳至页面中心  (情感动作任务相关)
function EmoActMainPanelView:SetScrollCenter(Params)
	if not self.TableViewEmoActAdapter then return end
	local GoToID = EmotionMgr.TargetQuestEmotionID
	if not GoToID then
		if Params and Params.EmoActID then
			GoToID = Params.EmoActID
		end
	end
	local EachRow = 4		--页面一行4个图标
	local Column = 0		--页面图标总列数

	local ItemViewList = self.TableViewEmoActAdapter.ItemViewList
	if ItemViewList then
		local ListLength = #ItemViewList
		if ListLength < 12 then
			return
		end
		Column = math.ceil(ListLength / EachRow)
		if Column < 4 then
			return
		end
		local AllEmotionList = self:GetEmotionList()
		if AllEmotionList then
			for k, Item in pairs(AllEmotionList) do
				if Item and Item.ID and Item.ID > 0 then
					if Item.ID == GoToID then
						local CurrentColumn = math.ceil(k / EachRow)	--所在列
						local CenterColumn = math.ceil(Column / 2)	--中心列
						if CurrentColumn > CenterColumn then
							local ScrollIndex = k - (CenterColumn - 1) * EachRow	--滚动序号
							if AllEmotionList[ScrollIndex] and AllEmotionList[ScrollIndex].ID then
								-- 这里是通过计算滑动到顶部的图标，进而确定居中图标
								-- （不要用 ScrollIndexIntoView ，存在非对齐真正中心）
								self.TableViewEmoActAdapter:ScrollToIndex(ScrollIndex)
							end
						end
						return
					end
				end
			end
		end
	end
end

function EmoActMainPanelView:GetRecentViewSize()
	if self.TableViewRecent then
		if EmoActPanelVM and EmoActPanelVM.RecentSize == nil then
			local Size = UIUtil.GetWidgetSize( self.TableViewRecent )
			if Size.Y > 1 then
				EmoActPanelVM.RecentSize = Size
			end
		end
	end
end

-- 配置动作类型红点路径
function EmoActMainPanelView:SetTypeRedDot()
	if self.CommTabs and self.CommTabs.AdapterTabs and self.CommTabs.AdapterTabs.SubViews then
		for k, TabItem in pairs(self.CommTabs.AdapterTabs.SubViews) do
			if nil ~= TabItem then
				TabItem.RedDot:SetStyle(4)
				TabItem.RedDot:SetRedDotText(LSTR(10030))
				TabItem:UpdateRedDot({RedDotName = EmotionDefines.TabKeyRedDots[k - 1], IsStrongReminder = true})
			end
		end
	end
end

return EmoActMainPanelView