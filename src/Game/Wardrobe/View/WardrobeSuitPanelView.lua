---
--- Author: Administrator
--- DateTime: 2025-03-13 11:09
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local CommonStateUtil = require("Game/CommonState/CommonStateUtil")
local TimeUtil = require("Utils/TimeUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local RedDotMgr = require("Game/CommonRedDot/RedDotMgr")

local WardrobeSuitPanelVM = require("Game/Wardrobe/VM/WardrobeSuitPanelVM")
local WardrobeMainPanelVM = require("Game/Wardrobe/VM/WardrobeMainPanelVM")
local EquipmentVM = require("Game/Equipment/VM/EquipmentVM")

local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local WardrobeDefine = require("Game/Wardrobe/WardrobeDefine")
local WardrobeMgr = require("Game/Wardrobe/WardrobeMgr")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")

local ProtoCommon = require("Protocol/ProtoCommon")
local EventID = require("Define/EventID")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local ClosetSuitCfg = require("TableCfg/ClosetSuitCfg")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local ClosetCharismCfg = require("TableCfg/ClosetCharismCfg")
local HelpInfoUtil = require("Utils/HelpInfoUtil")
local EquipmentPartList = ProtoCommon.equip_part

---@class WardrobeSuitPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBox UFButton
---@field BtnCharm UFButton
---@field BtnClose CommonCloseBtnView
---@field BtnCollect2 UFButton
---@field BtnPresets UFButton
---@field BtnReduce UFButton
---@field BtnSearch CommSearchBtnView
---@field BtnUse CommBtnLView
---@field CommEmpty CommBackpackEmptyView
---@field CommonBkg CommonBkg01View
---@field CommonRedDot CommonRedDotView
---@field CommonTitle CommonTitleView
---@field DropDownList CommDropDownListView
---@field EFF_Reward UFCanvasPanel
---@field ImgMask UFImage
---@field ImgPresets UFImage
---@field PanelArrow2 UFCanvasPanel
---@field PanelBg UFCanvasPanel
---@field PanelCharm UFCanvasPanel
---@field PanelEmpty UFCanvasPanel
---@field PanelPresets2 UFCanvasPanel
---@field PanelReduce UFCanvasPanel
---@field PanelSlot UFCanvasPanel
---@field PanelSwitch UFCanvasPanel
---@field PanelTab UFCanvasPanel
---@field SearchBar CommSearchBarView
---@field TableViewList UTableView
---@field TableViewPosition UTableView
---@field TextName UFTextBlock
---@field TextNum UFTextBlock
---@field TextNumCharm UFTextBlock
---@field TextPresets UFTextBlock
---@field TextReduce UFTextBlock
---@field ToggleBtnSwitch UToggleButton
---@field WardrobeOperateItem WardrobeOperateItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WardrobeSuitPanelView = LuaClass(UIView, true)

function WardrobeSuitPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBox = nil
	--self.BtnCharm = nil
	--self.BtnClose = nil
	--self.BtnCollect2 = nil
	--self.BtnPresets = nil
	--self.BtnReduce = nil
	--self.BtnSearch = nil
	--self.BtnUse = nil
	--self.CommEmpty = nil
	--self.CommonBkg = nil
	--self.CommonRedDot = nil
	--self.CommonTitle = nil
	--self.DropDownList = nil
	--self.EFF_Reward = nil
	--self.ImgMask = nil
	--self.ImgPresets = nil
	--self.PanelArrow2 = nil
	--self.PanelBg = nil
	--self.PanelCharm = nil
	--self.PanelEmpty = nil
	--self.PanelPresets2 = nil
	--self.PanelReduce = nil
	--self.PanelSlot = nil
	--self.PanelSwitch = nil
	--self.PanelTab = nil
	--self.SearchBar = nil
	--self.TableViewList = nil
	--self.TableViewPosition = nil
	--self.TextName = nil
	--self.TextNum = nil
	--self.TextNumCharm = nil
	--self.TextPresets = nil
	--self.TextReduce = nil
	--self.ToggleBtnSwitch = nil
	--self.WardrobeOperateItem = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WardrobeSuitPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.BtnSearch)
	self:AddSubView(self.BtnUse)
	self:AddSubView(self.CommEmpty)
	self:AddSubView(self.CommonBkg)
	self:AddSubView(self.CommonRedDot)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.DropDownList)
	self:AddSubView(self.SearchBar)
	self:AddSubView(self.WardrobeOperateItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WardrobeSuitPanelView:OnInit()
	self.VM = WardrobeSuitPanelVM.New()
	self.MainVM = WardrobeMainPanelVM
	-- 装备菜单列表
	self.AppearanceTabListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewPosition, self.OnAppearanceTabListChanged, true)
	-- 套装列表
	self.AppearanceSuitListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList, self.OnAppearanceSuitListChanged, true, true)	

	self.MultiBinders = {
		{
			ViewModel = self.VM,
			Binders = {
				{ "TabList",  UIBinderUpdateBindableList.New(self, self.AppearanceTabListAdapter)},
				{ "SuitList",  UIBinderUpdateBindableList.New(self, self.AppearanceSuitListAdapter)},
				{ "IsSearching", UIBinderSetIsVisible.New(self, self.SearchBar)},
				{ "IsSearching", UIBinderSetIsVisible.New(self, self.DropDownList, true)},
				{ "IsSearching", UIBinderSetIsVisible.New(self, self.BtnSearch, true)},
				{ "EmptyVisible", UIBinderSetIsVisible.New(self, self.PanelEmpty)},
				{ "UseBtnVisible", UIBinderSetIsVisible.New(self, self.BtnUse, false, false)},
				{ "CharmNumText", UIBinderSetText.New(self, self.TextNum)},
				{ "NewCharmNumText", UIBinderSetText.New(self, self.TextNumCharm)},
				{ "CharmEffVisible", UIBinderSetIsVisible.New(self, self.EFF_Reward)},
				{ "CurSuitName", UIBinderSetText.New(self, self.TextName)},
				{ "GetWayVisible", UIBinderSetIsVisible.New(self, self.TextName)},
				{ "GetWayVisible", UIBinderSetIsVisible.New(self, self.PanelReduce)},
			}
		},
		{
			ViewModel = self.MainVM,
			Binders = {
				{ "BtnHandChecked", UIBinderSetIsChecked.New(self, self.WardrobeOperateItem.BtnHand)},
				{ "BtnHatChecked", UIBinderSetIsChecked.New(self, self.WardrobeOperateItem.BtnHat)},
				{ "BtnHatStyleChecked", UIBinderSetIsChecked.New(self, self.WardrobeOperateItem.BtnHatStyle)},
				{ "BtnPoseChecked", UIBinderSetIsChecked.New(self, self.WardrobeOperateItem.BtnPose)},
				{ "BtnCameraChecked", UIBinderSetIsChecked.New(self, self.WardrobeOperateItem.BtnCamera)},
				{ "BtnSuitSwitchChecked", UIBinderSetIsChecked.New(self, self.ToggleBtnSwitch)},
			}
		}
	}

	self.DropDownDataList = {}	--职业下拉框数据列表
	self.TabIndex = 1
	self.CurSelectedSuit = nil

	self.TabSelectedListID = {}

	self.CurViewSuit = {}
	self.IsFirstEnter = true
end

function WardrobeSuitPanelView:OnDestroy()
end

function WardrobeSuitPanelView:OnShow()
	self:InitText()
	self.VM:InitTabList()
	self.CurViewSuit  = {}
	for _, v in ipairs(WardrobeDefine.SuitTabList) do
		self.TabSelectedListID[v.ID] = 0
	end
	self.CurSuitID = self.Params.SuitID
	self.LastHatBtnTime = 0
	self.NeededChangeSearch = true  --是否切换搜索
	self.Common_Render2D_UIBP = self.Params.SuperView.Common_Render2D_UIBP
	UIUtil.SetIsVisible(self.CommonBkg, false)
	UIUtil.SetIsVisible(self.PanelCharm, true)
	
	UIUtil.SetIsVisible(self.WardrobeOperateItem.BtnCamera, false, true)
	
	self.SuperView = self.Params.SuperView
	self.BtnClose:SetCallback(self, function ()  self:Hide() UIViewMgr:HideView(UIViewID.WardrobeMainPanel) end)
	self.SearchBar:SetCallback(self, self.OnChangeSearchBar, nil, self.OnClickCancelSearchBar)
	
	UIUtil.SetIsVisible(self.WardrobeOperateItem, true)
	self.CommonTitle.CommInforBtn.HelpInfoID = 11019
	self.CurDropDownIndex = 0
	self.IsFirstEnter = true
	self:InitDropDownList()
	self.IsFirstEnter = false
	self.VM:UpdateCharismNum()
	self:UpdateBtnHatStyleState(WardrobeMgr:CheckHeadHasGimmick())
	self.AppearanceTabListAdapter:SetSelectedIndex(1)

	self.CommonRedDot:SetRedDotIDByID(WardrobeDefine.RedDotList.SuitUnlock)
end

function WardrobeSuitPanelView:OnHide()
	self.CurSuitID = nil
	UIViewMgr:HideView(UIViewID.WardrobeSuitGetWayWin)
end

function WardrobeSuitPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnBox, self.OnClickedBtnBox)
	UIUtil.AddOnClickedEvent(self, self.BtnCollect2, self.OnClickedBtnCollect2)
	UIUtil.AddOnClickedEvent(self, self.BtnCharm, self.OnClickedBtnCharm1)
	UIUtil.AddOnClickedEvent(self, self.BtnSearch.BtnSearch, self.OnClickedBtnSearch)
	UIUtil.AddOnClickedEvent(self, self.BtnUse.Button, self.OnClickedBtnUseBtn)
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownList, self.OnDropDownListSelectionChanged)

	UIUtil.AddOnStateChangedEvent(self, self.WardrobeOperateItem.BtnCamera, self.OnClickedBtnCamera)
	UIUtil.AddOnStateChangedEvent(self, self.WardrobeOperateItem.BtnHand, self.OnClickedBtnHand)
	UIUtil.AddOnStateChangedEvent(self, self.WardrobeOperateItem.BtnHat, self.OnClickedBtnHat)
	UIUtil.AddOnStateChangedEvent(self, self.WardrobeOperateItem.BtnHatStyle, self.OnClickedBtnHatStyle)
	UIUtil.AddOnStateChangedEvent(self, self.WardrobeOperateItem.BtnPose, self.OnClickedBtnPose)


	UIUtil.AddOnClickedEvent(self, self.BtnPresets, self.OnClickedBtnPresets1)

	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnSwitch, self.OnClickedBtnSwitch)
	UIUtil.AddOnClickedEvent(self, self.BtnReduce, self.OnClickedBtnGetWay)

end

function WardrobeSuitPanelView:OnRegisterGameEvent()
	-- 衣橱魅力值更新
	self:RegisterGameEvent(EventID.WardrobeCharismValueUpdate, self.OnWardrobeCharismValueUpdate)
	self:RegisterGameEvent(EventID.WardrobeSuitIDOpen, self.OnWardrobeSuitIDOpen)
	-- 衣橱解锁更新
	self:RegisterGameEvent(EventID.WardrobeUnlockUpdate, self.OnWardrobeUnlockUpdate)
end

function WardrobeSuitPanelView:OnRegisterBinder()
	self:RegisterMultiBinders(self.MultiBinders)
end

function WardrobeSuitPanelView:OnWardrobeUnlockUpdate()
	if self.VM ~= nil then
		self.VM:UpdateSuitList(self.TabIndex, self:GetFilterProfListIndex(self.CurDropDownIndex))
	end
end

function WardrobeSuitPanelView:OnWardrobeCharismValueUpdate()
	if self.VM then
		self.VM:UpdateCharismNum()
	end
end

-- 点击职业外观收集界面
function WardrobeSuitPanelView:OnClickedBtnCollect2()
	local BtnSize = UIUtil.GetLocalSize(self.BtnCollect2)
	local Params = {}
	Params.TargetView = self.BtnCollect2
	Params.Offset = _G.UE4.FVector2D(-25, BtnSize.Y)
	Params.Alignment = _G.UE4.FVector2D(1, 0)
	UIViewMgr:ShowView(UIViewID.WardrobeProfAppListWin, Params)
end

-- 点击收集奖励界面
function WardrobeSuitPanelView:OnClickedBtnBox()
	local LevelAwardInfoList = ClosetCharismCfg:FindAllCfg()

	if LevelAwardInfoList == nil then
		return
	end

	local TempMaxIndex = 1

	local function OnClickedItem(Index, ItemData, ItemView)
		if ItemData ~= nil then
			if ItemData.IsGetProgress then
				-- 判断最大index
				WardrobeMgr:SendClosetCharismRewardReq(TempMaxIndex)
			else
				ItemTipsUtil.ShowTipsByResID(ItemData.AwardID, ItemView)
			end
		end
	end

	local function OnGetAwardCallBack(Index, ItemData, ItemView)
        if ItemData then
			if ItemData.IsGetProgress then
				-- 判断最大index
				WardrobeMgr:SendClosetCharismRewardReq(TempMaxIndex)
			end
        end
    end

	local Params = {
		ModuleID = nil,
		CollectedNum = WardrobeMgr:GetCharmNum(),
		MaxCollectNum = WardrobeMgr:GetCharismTotalNum(),
		AreaName = nil,
		OnGetAwardCallBack = OnGetAwardCallBack,
		TextCurrent = _G.LSTR(1080111),     -- "外观收集进度"
		IgnoreIsGetProgress = true,
		ItemClickCallback = OnClickedItem,
	}
	

	local AwardInfoList, AwardSelectIndex, MaxIndex = self:GetAwardInfo()

	Params.AwardList = AwardInfoList
	Params.AwardSelectIndex = AwardSelectIndex
	TempMaxIndex = MaxIndex

    UIViewMgr:ShowView(UIViewID.CollectionAwardPanel, Params)
end

-- 点击魅力值tips
function WardrobeSuitPanelView:OnClickedBtnCharm1()
	HelpInfoUtil.ShowHelpInfo({HelpInfoID = WardrobeDefine.CharismHelpID, BtnInfor = self.PanelCharm})
end

function WardrobeSuitPanelView:GetAwardInfo()
	local LevelAwardInfoList = ClosetCharismCfg:FindAllCfg()
	
	if LevelAwardInfoList == nil then
		return
	end
	
	local AwardSelectIndex = 1
	local AwardInfoList = {}
	local MaxIndex = 1
	for index, v in ipairs(LevelAwardInfoList) do
		local Reward = v.Rewards
		local AwardInfo = {
			CollectTargetNum = v.Charism,
			AwardID = Reward[1].ResID,
			AwardNum = Reward[1].Num,
			IsGetProgress =  v.Charism <= WardrobeMgr:GetCharmNum() and  not (index <= WardrobeMgr:GetClaimedCharismReward()), -- 是否已达到奖励进度
			IsCollectedAward = index <= WardrobeMgr:GetClaimedCharismReward(), -- 是否已领奖
		}
		if AwardInfo.IsGetProgress and index >= MaxIndex then
			MaxIndex = index
		end
		AwardSelectIndex = WardrobeMgr:GetClaimedCharismReward() + 1
		table.insert(AwardInfoList, AwardInfo)
	end

	return AwardInfoList, AwardSelectIndex, MaxIndex
end

function WardrobeSuitPanelView:OnClickedBtnPresets1()
	if self.SuperView ~= nil then
		self.MainVM.BtnSuitSwitchChecked = false
		self.SuperView.ResetSelected(self.SuperView)
		self.SuperView.ShowMainPanel(self.SuperView, true) 
		self.SuperView.OnClickedBtnPresets(self.SuperView)
		self:Hide()
	end
end

function WardrobeSuitPanelView:OnClickedBtnSwitch(ToggleButton, State)
	-- 还需要切状态
	if UIUtil.IsToggleButtonChecked(State) then
		self.MainVM.BtnSuitSwitchChecked = false
		self.SuperView.ResetSelected(self.SuperView)
		self.SuperView.ShowMainPanel(self.SuperView, true)
		self:Hide()	
	end
end

function WardrobeSuitPanelView:OnClickedBtnHand(ToggleButton, State)
	local bChanged = self.SuperView.OnClickedBtnHand(self.SuperView, ToggleButton, State)
	if not bChanged then
		self.WardrobeOperateItem.BtnHand:SetChecked(self.MainVM.BtnHandChecked, false)
	end
end

function WardrobeSuitPanelView:OnClickedBtnHatStyle(ToggleButton, State)
	local bChanged = self.SuperView.OnClickedBtnHatStyle(self.SuperView, ToggleButton, State)
	if not bChanged then
		if not self.MainVM.BtnHatStyleVisible then
			self.WardrobeOperateItem.BtnHatStyle:SetCheckedState(_G.UE.EToggleButtonState.Locked, false)
		else
			self.WardrobeOperateItem.BtnHatStyle:SetChecked(self.MainVM.BtnHatStyleChecked, false)
		end
	end
end

function WardrobeSuitPanelView:OnClickedBtnPose(ToggleButton, State)
	local bChanged = self.SuperView.OnClickedBtnPose(self.SuperView, ToggleButton, State)
	if not bChanged then
		self.WardrobeOperateItem.BtnPose:SetChecked(self.MainVM.BtnPoseChecked, false)
	end
end

function WardrobeSuitPanelView:OnClickedBtnCamera(ToggleButton, State)
	local IsShow = State == _G.UE.EToggleButtonState.Checked
	self.MainVM.BtnCameraChecked = IsShow
end

-- 打开获取途径逻辑
function WardrobeSuitPanelView:OnClickedBtnGetWay()
	-- local ViewModel = {}
	-- ViewModel.ParentViewID =  _G.UIViewID.WardrobeMainPanel
	UIViewMgr:ShowView(UIViewID.WardrobeSuitGetWayWin, {SuitID = self.CurSelectedSuit, SuperView = self})
end

function WardrobeSuitPanelView:HideSuitPanelView(AppID)
	self.MainVM.BtnSuitSwitchChecked = false
	self.SuperView.ResetSelected(self.SuperView)
	self.SuperView.ShowMainPanel(self.SuperView, true)
	self.SuperView.OpenWardrobeUnlockPanel(self.SuperView,AppID)
	self:Hide()
end

function WardrobeSuitPanelView:InitText()
	self.CommonTitle:SetTextTitleName(_G.LSTR(1080073))
	self.SearchBar:SetIllegalTipsText(_G.LSTR(10057)) --10057("当前文本不可使用，请重新输入")

	self.BtnUse:SetText(_G.LSTR(1080066))
	self.CommEmpty.RichTextNone:SetText(_G.LSTR(1080109))  -- 暂无对应外观
	self.CommEmpty.RichTextNoneBright:SetText(_G.LSTR(1080109))  -- 暂无对应外观
	self.TextReduce:SetText(_G.LSTR(1080157)) --获取
	self.TextPresets:SetText(_G.LSTR(1080106))
end

-- 初始化职业下拉框
function WardrobeSuitPanelView:InitDropDownList()
	local ItemList = {}
	self.DropDownDataList = {}
	for index, v in ipairs(WardrobeDefine.FilterProfList) do
		local Name = nil
		local ClassType = v.ClassType
		local ProfID = v.ProfID
		local IsVersionOpen = true
		if v.ClassType ==  WardrobeDefine.ProfClass.ClassType then
			IsVersionOpen = true
			if ProfID ~= -1 then
				Name = v.ProfID == 0 and _G.LSTR(1080128) or ProtoEnumAlias.GetAlias(ProtoCommon.class_type, v.ProfID)
			else
				Name = _G.LSTR(1080037)
			end
		elseif v.ClassType == WardrobeDefine.ProfClass.BasicType then
			local Cfg = RoleInitCfg:FindCfgByKey(v.ProfID) 
			IsVersionOpen = Cfg ~= nil and Cfg.IsVersionOpen == 1
			Name = ProtoEnumAlias.GetAlias(ProtoCommon.prof_type, v.ProfID)
		elseif v.ClassType == WardrobeDefine.ProfClass.AdvanceType then
			local Cfg = RoleInitCfg:FindCfgByKey(v.ProfID) 
			IsVersionOpen = Cfg ~= nil and Cfg.IsVersionOpen == 1
			if Cfg ~= nil then
				Name = string.format("%s/%s", ProtoEnumAlias.GetAlias(ProtoCommon.prof_type, v.ProfID), ProtoEnumAlias.GetAlias(ProtoCommon.prof_type, Cfg.AdvancedProf))
			end
		end
		if Name ~= nil and IsVersionOpen then
			table.insert(ItemList, {ID = index, Index = #ItemList + 1, Name = Name, ClassType = ClassType, ProfID = ProfID})
		end
	end

	self.DropDownDataList = ItemList

	self.DropDownList:UpdateItems(ItemList)
end

-- 职业下拉框筛选
function WardrobeSuitPanelView:OnDropDownListSelectionChanged(Index, ItemData, ItemView, IsByClick)
	self.CurDropDownIndex = Index
	if not self.IsFirstEnter then
		self.VM:UpdateSuitList(self.TabIndex, self:GetFilterProfListIndex(self.CurDropDownIndex))
		if self.CurSuitID ~= nil then
			for i = 1, self.AppearanceSuitListAdapter:GetNum() do
				local ItemVM = self.AppearanceSuitListAdapter:GetItemDataByIndex(i)
				if ItemVM ~= nil then
					if ItemVM.ID == self.CurSuitID then
						self.AppearanceSuitListAdapter:CancelSelected()
						self.AppearanceSuitListAdapter:SetSelectedIndex(i)
						self.AppearanceSuitListAdapter:ScrollToIndex(i)
						self.CurSuitID = nil
						return
					end
				end
			end
		else
			self.AppearanceSuitListAdapter:CancelSelected()
			self.CurSuitID = nil
		end
	end
end

-- 获取下拉框下标
function WardrobeSuitPanelView:GetDropDownListSelectedIndex()
	local MarjorProfID = MajorUtil.GetMajorProfID()
	local SelectedIndex = 1

	for i = 1, #self.DropDownDataList do
		local Data = self.DropDownDataList[i]
		if Data.ClassType == WardrobeDefine.ProfClass.BasicType then
			if MarjorProfID == Data.ProfID then
				return Data.Index
			end
		elseif Data.ClassType == WardrobeDefine.ProfClass.AdvanceType then
			local Cfg = RoleInitCfg:FindCfgByKey(Data.ProfID)
			if Cfg ~= nil then
				if MarjorProfID == Data.ProfID or MarjorProfID == Cfg.AdvancedProf then
					return Data.Index
				end
			end
		end
	end

	return SelectedIndex
end

-- 获取下拉框职业ID
function WardrobeSuitPanelView:GetFilterProfListIndex(Index)
	for i = 1, #self.DropDownDataList do
		local Data = self.DropDownDataList[i]
		if Data.Index == Index then
			return Data.ID
		end
	end

	return 1
end

function WardrobeSuitPanelView:ResetDropDownList()
	self.IsFirstEnter = true
	self:InitDropDownList()
	self.IsFirstEnter = false
	self.DropDownList:SetSelectedIndex(self.DefaultDropDownIndex)
end

function WardrobeSuitPanelView:OnAppearanceTabListChanged(Index, ItemData, ItemView)
	self.CommonTitle:SetTextSubtitle(_G.LSTR(WardrobeDefine.SuitTabList[Index].Name))
	self.TabIndex = WardrobeDefine.SuitTabList[Index].ID
	self.DefaultDropDownIndex = self:GetDropDownListSelectedIndex()
	if self.DefaultDropDownIndex == self.CurDropDownIndex then
		self.DropDownList:CancelSelected()
	end
	self.DropDownList:SetSelectedIndex(self.DefaultDropDownIndex)
	if self.NeededChangeSearch and self.VM.IsSearching then
		self.SearchBar:OnClickButtonCancel()
	end
end


function WardrobeSuitPanelView:OnAppearanceSuitListChanged(Index, ItemData, ItemView)
	--Todo 判断选中的套装 全部是否可以预览，不可预览弹提示 return
	--取消选中 穿戴回原来的套装。
	local IsSelected = ItemData.IsSelected
	self.VM.UseBtnVisible = IsSelected
	local Cfg = ClosetSuitCfg:FindCfgByKey(ItemData.ID)

	if Cfg == nil then
		return
	end

	if IsSelected ~= nil then
		if not IsSelected then
			self.CurSelectedSuit = nil
			self.TabSelectedListID[self.TabIndex] = 0
			self:ResetAppearance()
			self.CurViewSuit = {}
			self.VM.GetWayVisible = false
			return
		end
	end

	self.CurSelectedSuit = ItemData.ID

	self.TabSelectedListID[self.TabIndex] =  ItemData.ID

	self.VM.GetWayVisible = true
	
	self.VM.CurSuitName = Cfg.SuitName
	for _, v in ipairs(Cfg.AppItems) do
		local ECfg = EquipmentCfg:FindCfgByKey(v)
		if ECfg	~= nil then
			if not WardrobeMgr:CanPreviewAppearance(ECfg.AppearanceID)  then
				MsgTipsUtil.ShowTips(_G.LSTR(1080122)) --部分外观不符合预览条件，无法进行预览
				return 
			end
		end
	end



	self:ResetAppearance()
	--选中，预览套装内的装备
	local HasHead = false
	local UnlockEnable = false
	for _, v in ipairs(Cfg.AppItems) do
		local ECfg = EquipmentCfg:FindCfgByKey(v)
		if ECfg ~= nil then
			local AppID = ECfg.AppearanceID
			if not WardrobeMgr:GetIsUnlock(AppID) then
				if not UnlockEnable then
					UnlockEnable =  WardrobeUtil.JudgeUnlockAppearanceWithouItem(AppID)
				end
			end
			local Color = WardrobeMgr:GetDyeColor(AppID)
			local RegionDyes = WardrobeMgr:GetUnlockedAppearanceRegionDyes(AppID)
			if ECfg.Part ~= nil then
				local Part =  ECfg.Part ~= EquipmentPartList.EQUIP_PART_FINGER and ECfg.Part or EquipmentPartList.EQUIP_PART_LEFT_FINGER
				if self.CurViewSuit[Part] == nil then
					self.CurViewSuit[Part] = {}
				end
				self.CurViewSuit[Part] = {Avatar = AppID, Color = Color, RegionDyes = RegionDyes}
				self:PreviewAppearance(Part, ECfg.ID, Color)
				self:StainPartForSection(AppID, ECfg.Part, RegionDyes)
				if ECfg.Part == EquipmentPartList.EQUIP_PART_HEAD then
					HasHead = true
					self:UpdateBtnHatStyleState(_G.EquipmentMgr:IsEquipHasGimmick(v))
				end
			end
			
		end
	end

	if not HasHead then
		self:UpdateBtnHatStyleState(WardrobeMgr:CheckHeadHasGimmick())
	end

	-- 获取按钮红点
	if UnlockEnable then
		RedDotMgr:AddRedDotByID(WardrobeDefine.RedDotList.SuitUnlock, nil, false)
	else
		RedDotMgr:DelRedDotByID(WardrobeDefine.RedDotList.SuitUnlock)
	end
	
	-- 更新当前按钮状态
	local IsAllLock = true
	for _, v in ipairs(Cfg.AppItems) do
		local ECfg = EquipmentCfg:FindCfgByKey(v)
		if ECfg ~= nil then
			if WardrobeMgr:GetIsUnlock(ECfg.AppearanceID) then
				IsAllLock = false
				break
			end
		end
	end

	if IsAllLock then
		self.BtnUse:SetIsDisabledState(true, true)
	else
		self.BtnUse:SetIsRecommendState(true)
	end

	


end

function WardrobeSuitPanelView:UpdateBtnHatStyleState(HasGimmick)
	if HasGimmick then
		self.MainVM.BtnHatStyleDisabled = false
		self.WardrobeOperateItem.BtnHatStyle:SetCheckedState(self.MainVM.BtnHatStyleChecked and _G.UE.EToggleButtonState.Checked  or _G.UE.EToggleButtonState.Unchecked, false)
		-- self.WardrobeOperateItem.BtnHatStyle:SetCheckedState(self.MainVM.BtnHatStyleChecked and _G.UE.EToggleButtonState.Checked or _G.UE.EToggleButtonState.Unchecked, false)
	else
	    self.MainVM.BtnHatStyleDisabled = true
		self.WardrobeOperateItem.BtnHatStyle:SetCheckedState(_G.UE.EToggleButtonState.Locked, false)
	end
end

-- Todo 发送使用
function WardrobeSuitPanelView:OnClickedBtnUseBtn()
	if not CommonStateUtil.CheckBehavior(ProtoCommon.CommBehaviorID.COMM_BEHAVIOR_CLOSET_CLOTHING, true) then
		return
	end

	if self.CurSelectedSuit == nil then
		return
	end

	local Cfg = ClosetSuitCfg:FindCfgByKey(self.CurSelectedSuit)
	if Cfg == nil then
		return
	end

	local IsAllLock = true
	for _, v in ipairs(Cfg.AppItems) do
		local ECfg = EquipmentCfg:FindCfgByKey(v)
		if ECfg ~= nil then
			if WardrobeMgr:GetIsUnlock(ECfg.AppearanceID) then
				IsAllLock = false
				break
			end
		end
	end

	if IsAllLock then
		MsgTipsUtil.ShowTips(_G.LSTR(1080113)) --套装未解锁无法使用
		return
	end

	local IsAllEquiped = true
	for _, v in ipairs(Cfg.AppItems) do
		local ECfg = EquipmentCfg:FindCfgByKey(v)
		if ECfg ~= nil then
			if  WardrobeMgr:CanEquipAppearance(ECfg.AppearanceID) then
				IsAllEquiped = false
				break
			end
		end
	end

	-- Todo发送可以穿戴的外观给服务器。
	local ItemList = {}
	for _, v in ipairs(Cfg.AppItems) do
		local ECfg = EquipmentCfg:FindCfgByKey(v)
		if ECfg ~= nil then
			-- if  WardrobeMgr:CanEquipAppearance(ECfg.AppearanceID) then
				table.insert(ItemList,{AppearanceID =  ECfg.AppearanceID , Part  = ECfg.Part} )
			-- end
		end
	end

	if #ItemList > 0 then
		WardrobeMgr:SendClosetSuitClothingReq(ItemList)
	end
end

function WardrobeSuitPanelView:ResetAppearance()
	local ItemList = {}
	local Suit = WardrobeMgr:GetViewSuit()
	local CurCurrentSuit = WardrobeMgr:GetCurAppearanceList()
	local EquipList = EquipmentVM.ItemList

	for index, partID in pairs(WardrobeDefine.EquipmentTab) do
		if Suit[partID] ~= nil and Suit[partID].Avatar ~= 0 then
			local AppID = Suit[partID].Avatar
			local EquipID = WardrobeMgr:IsRandomAppID(AppID) and WardrobeMgr:GetEquipIDByRandomApp(AppID) or WardrobeUtil.GetEquipIDByAppearanceID(AppID)
			local ColorID =  Suit[partID].Color
			local RegionDye = WardrobeUtil.GetRegionDye(AppID, Suit[partID].RegionDye)
			if CurCurrentSuit[partID] ~= nil and CurCurrentSuit[partID].Avatar == Suit[partID].Avatar and CurCurrentSuit[partID].Color ~= Suit[partID].Color then
				ColorID = CurCurrentSuit[partID].Color
			end
			table.insert(ItemList, {AppID = AppID, EquipID = EquipID, PartID = partID, ColorID = ColorID, RegionDye = RegionDye})
		else
			local HasEquip = false
			for part, value in pairs(EquipList) do
				if partID == part then
					HasEquip = true
					local TempEquip = value
					local EquipID = TempEquip.ResID
					local CurrentAppID = WardrobeMgr:GetEquipPartAppearanceID(partID)
					local ColorID = 0
					local RegionDye = {}
					if CurrentAppID ~= 0 then
						EquipID = WardrobeUtil.GetEquipIDByAppearanceID(CurrentAppID)
						ColorID = WardrobeMgr:GetCurAppearanceDyeColor(CurrentAppID)
						RegionDye = WardrobeMgr:GetCurAppearanceRegionDyes(CurrentAppID)
					end
					table.insert(ItemList, {EquipID = EquipID, AppID = CurrentAppID,  PartID = partID, ColorID = ColorID,  RegionDye = RegionDye})
				end
			end

			if not HasEquip then
				table.insert(ItemList, {EquipID = nil, AppID = 0, PartID = partID, ColorID = 0, RegionDye = {}})
			end
		end

	end

	-- 如果有预览效果
	self:RenderPreviewEquipmentList(ItemList)
end

function WardrobeSuitPanelView:RenderPreviewEquipmentList(Items)
	for i = 1, #Items do
		if Items[i] ~= nil and Items[i] ~= 0 then
			local AppID = Items[i].AppID
			local Color = Items[i].ColorID or 0
			local PartID = Items[i].PartID
			local EquipID = Items[i].EquipID
			local RegionDye = Items[i].RegionDye
			local IsAppRegionDye = WardrobeUtil.IsAppRegionDye(AppID)
			if PartID == EquipmentPartList.EQUIP_PART_HEAD then
				if self.MainVM ~= nil and self.MainVM.BtnHatChecked ~= nil then
					if self.MainVM.BtnHatChecked then
						self.Common_Render2D_UIBP:PreViewEquipment(EquipID, PartID, IsAppRegionDye and 0 or Color)
						self:StainPartForSection(AppID, PartID, RegionDye)
					else
						self.Common_Render2D_UIBP:PreViewEquipment(nil, PartID, 0)
					end
				end
			elseif PartID == EquipmentPartList.EQUIP_PART_SLAVE_HAND or PartID == EquipmentPartList.EQUIP_PART_MASTER_HAND then
				if self.MainVM ~= nil and self.MainVM.BtnHandChecked ~= nil then
					if self.MainVM.BtnHandChecked or self.MainVM.BtnPoseChecked then
						self.Common_Render2D_UIBP:PreViewEquipment(EquipID, PartID, IsAppRegionDye and 0 or Color)
						self:StainPartForSection(AppID, PartID, RegionDye)
					else
						self.Common_Render2D_UIBP:PreViewEquipment(nil, PartID, 0)
					end
				end
			else
				self.Common_Render2D_UIBP:PreViewEquipment(EquipID, PartID, IsAppRegionDye and 0 or Color)

				self:StainPartForSection(AppID, PartID, RegionDye)
			end
		end
	end
end

function WardrobeSuitPanelView:PreviewAppearance(PartID, EquipID, AppID)
	local IsPreview = true
	if PartID == EquipmentPartList.EQUIP_PART_HEAD then
		IsPreview = self.MainVM.BtnHatChecked
	elseif PartID == EquipmentPartList.EQUIP_PART_MASTER_HAND or PartID == EquipmentPartList.EQUIP_PART_SLAVE_HAND then
		IsPreview = self.MainVM.BtnHandChecked
	end
	self.Common_Render2D_UIBP:PreViewEquipment(IsPreview and EquipID or nil, PartID, 0)
end

function WardrobeSuitPanelView:OnClickedBtnSearch()
	self.VM.IsSearching = true
	self:ResetDropDownList()
	self.AppearanceSuitListAdapter:CancelSelected()
	self.SearchBar:SetHintText(string.format(_G.LSTR(1080114))) --搜索套装
	self.SearchBar:SetText("")
end

-- 监听搜索框输入变化
function WardrobeSuitPanelView:OnChangeSearchBar(SearchText)
	if string.isnilorempty(SearchText) then  --搜索是否String是null或其值为Empty
		return
	end

	_G.JudgeSearchMgr:QueryTextIsLegal(SearchText, function( IsLegal )
		if not IsLegal then
			self.SearchBar:SetText("")
			return
		end

		if self.AppearanceTabListAdapter:GetSelectedIndex() ~= 1 then
			self.NeededChangeSearch = false
			self.AppearanceTabListAdapter:SetSelectedIndex(1)
			self.AppearanceTabListAdapter:ScrollToIndex(1)
			self.NeededChangeSearch = true
		end

		self.VM:SearchSuitList(SearchText)

	end)
end

function WardrobeSuitPanelView:OnClickCancelSearchBar()
	local AppearanceSuitListAdapter = self.AppearanceSuitListAdapter
	local SelectedData, SelectedID = AppearanceSuitListAdapter:GetSelectedItemData(), nil
	if SelectedData then
		SelectedID = SelectedData.ID
	end
	self.VM.IsSearching = false
	self.SearchBar:SetText("")

	local TargetDropDownIndex = nil
	if SelectedData then
		local Cfg = ClosetSuitCfg:FindCfgByKey(SelectedData.ID)
		TargetDropDownIndex = Cfg and WardrobeUtil.GetFirstDropDownIndexByItemData(
			Cfg, self.DropDownDataList, self.VM.GetDataByFilterIndex, self.CurDropDownIndex) or nil
	end

	self:ResetDropDownList()
	self.SearchBar:SetText("")

	if TargetDropDownIndex then
		self.DropDownList:SetDropDownIndex(TargetDropDownIndex)
	end

	if SelectedID then
		local ItemData, Index = AppearanceSuitListAdapter:GetItemDataByPredicate(function(InItemData)
			return SelectedID == InItemData.ID
		end)
		if ItemData and Index then
			ItemData.IsSelected = true
			AppearanceSuitListAdapter:ScrollToIndex(Index)
			AppearanceSuitListAdapter:SetSelectedIndex(Index)
		end
	end
end

function WardrobeSuitPanelView:StainPartForSection(AppID, PartID, RegionDyes)
	if AppID == nil then
		return
	end

	for _, v in ipairs(RegionDyes or {}) do
		local SectionList = WardrobeUtil.ParseSectionIDList(AppID, v.ID)
		for _, sectionID in ipairs(SectionList) do
			self.Common_Render2D_UIBP:StainPartForSection(WardrobeDefine.StainPartType[PartID], sectionID, v.ColorID)
		end
	end	
end

-- 切换头部显隐状态
function WardrobeSuitPanelView:HatVisibleSwitch(IsShow)
	self.MainVM:ShowHead(IsShow, true)
	self.Common_Render2D_UIBP:HideHead(not IsShow)
end


function WardrobeSuitPanelView:OnClickedBtnHat(ToggleButton, State)
	local LocalTime  = TimeUtil.GetLocalTime()
	if LocalTime - self.LastHatBtnTime < 2 and self.LastHatBtnTime ~= 0  then
		self.WardrobeOperateItem.BtnHat:SetChecked(self.MainVM.BtnHatChecked, false)
		return false
	end
	self.LastHatBtnTime = LocalTime

	local IsShow = State == _G.UE.EToggleButtonState.Checked
	self:HatVisibleSwitch(IsShow)
	if self.MainVM.BtnHatChecked then
		if self.Common_Render2D_UIBP ~= nil then
			local ViewSuit = table.is_nil_empty(self.CurViewSuit) and WardrobeMgr:GetViewSuit() or self.CurViewSuit
			local HasEquipHeadViewSuit = false
			for key, v in pairs(ViewSuit) do
				if key == EquipmentPartList.EQUIP_PART_HEAD then
					HasEquipHeadViewSuit = true
					local EquipID = WardrobeUtil.GetEquipIDByAppearanceID(v.Avatar)
					local RegionDye =  WardrobeMgr:GetCurAppearanceRegionDyes(v.Avatar)
					local IsAppRegionDye = WardrobeUtil.IsAppRegionDye(v.Avatar)
					self.Common_Render2D_UIBP:PreViewEquipment(EquipID, key, IsAppRegionDye and 0 or v.Color)
					self:StainPartForSection(v.Avatar, tonumber(key), RegionDye)
				end
			end

			if not HasEquipHeadViewSuit then
				local EquipList = EquipmentVM.ItemList
				for _, part in ipairs(WardrobeDefine.EquipmentTab) do
					if EquipmentPartList.EQUIP_PART_HEAD == tonumber(part) then
						-- 判断当前装备
						local CurrentAppID = WardrobeMgr:GetEquipPartAppearanceID(part)
						if CurrentAppID ~= 0 then
							local EquipID = WardrobeUtil.GetEquipIDByAppearanceID(CurrentAppID)
							local ColorID = WardrobeMgr:GetCurAppearanceDyeColor(CurrentAppID)
							local RegionDyes = WardrobeMgr:GetCurAppearanceRegionDyes(CurrentAppID)
							local IsAppRegionDye = WardrobeUtil.IsAppRegionDye(CurrentAppID)
							self.Common_Render2D_UIBP:PreViewEquipment(EquipID, part, IsAppRegionDye and 0 or ColorID)
							self:StainPartForSection(CurrentAppID, tonumber(part), RegionDyes)
						else
							local TempEquip = EquipList[part]
							if TempEquip ~= nil then
								local EquipID = TempEquip.ResID
								self.Common_Render2D_UIBP:PreViewEquipment(EquipID, part, 0)
							else
								self.Common_Render2D_UIBP:PreViewEquipment(nil, part, 0)
							end
						end
					end
				end
			end
		end
	end

	return true
end

function WardrobeSuitPanelView:OnWardrobeSuitIDOpen()
	if self.Params.SuitID ~= nil then
		for i = 1, self.AppearanceSuitListAdapter:GetNum() do
			local ItemVM = self.AppearanceSuitListAdapter:GetItemDataByIndex(i)
			if ItemVM ~= nil then
				if ItemVM.ID == self.Params.SuitID then
					self.AppearanceSuitListAdapter:CancelSelected()
					self.AppearanceSuitListAdapter:SetSelectedIndex(i)
					self.AppearanceSuitListAdapter:ScrollToIndex(i)
					self.CurSuitID = nil
					return
				end
			end
		end
	end
end

return WardrobeSuitPanelView