--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2024-12-03 17:20:03
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2024-12-04 10:32:13
FilePath: \Client\Source\Script\Game\CraftingLog\View\CraftingLogMainPanelView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
---
--- Author: ghnvbnvb
--- DateTime: 2023-04-12 17:34
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CraftingLogVM = require("Game/CraftingLog/CraftingLogVM")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local UIBinderSetBrushFromIconID = require("Binder/UIBinderSetBrushFromIconID")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetSelectedIndex = require("Binder/UIBinderSetSelectedIndex")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local CraftingLogMgr = require("Game/CraftingLog/CraftingLogMgr")
local CraftingLogCareerItemVM = require("Game/CraftingLog/ItemVM/CraftingLogCareerItemVM")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local CraftingLogDefine = require("Game/CraftingLog/CraftingLogDefine")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local GatheringLogDefine = require("Game/GatheringLog/GatheringLogDefine")
local ItemUtil = require("Utils/ItemUtil")
local CraftingLogState = CraftingLogDefine.CraftingLogState
local FilterALLType = CraftingLogDefine.FilterALLType
local LSTR = _G.LSTR
local UIDefine = require("Define/UIDefine")
local CommUIStyleType = UIDefine.CommUIStyleType

---@class CraftingLogMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Bkg CommonBkg01View
---@field BorderNotice UBorder
---@field BtnAdd UFButton
---@field BtnClose CommonCloseBtnView
---@field BtnCraft CommBtnLView
---@field BtnGoBuy UFButton
---@field BtnMax UFButton
---@field BtnPractise CommBtnSView
---@field BtnSorting UFButton
---@field BtnSubtract UFButton
---@field CommLight152Slot CommLight152SlotView
---@field CommonBookBkg CommonBookBkgView
---@field CommonTitle CommonTitleView
---@field DropDown CommDropDownListView
---@field FButton_58 UFButton
---@field FCanvasPanel_93 UFCanvasPanel
---@field FImage_601 UFImage
---@field FTextBlock_61 UFTextBlock
---@field HorTabs CommHorTabsView
---@field IconMost UFImage
---@field ImgAdd UFImage
---@field ImgAddDisable UFImage
---@field ImgCollect UFImage
---@field ImgMaxNormal UFImage
---@field ImgSubtract UFImage
---@field ImgSubtractDisable UFImage
---@field InputSearch CommSearchBarView
---@field PanelAmountSetting UFHorizontalBox
---@field PanelFix UFCanvasPanel
---@field PanelInfo UFCanvasPanel
---@field PanelInfo_TutorialGuide UFCanvasPanel
---@field PanelListEmpty UFCanvasPanel
---@field PanelTabFilter UFCanvasPanel
---@field PanelTabList UFCanvasPanel
---@field RichTextTextRecipeDetail URichTextBox
---@field SearchHistory CraftingLogSearchHistoryItemView
---@field TableViewConditions UTableView
---@field TableViewCrystal UTableView
---@field TableViewList UTableView
---@field TableViewMaterial UTableView
---@field TextAmount UFTextBlock
---@field TextCraftTips UFTextBlock
---@field TextCrystal UFTextBlock
---@field TextDescription UFTextBlock
---@field TextListEmpty UFTextBlock
---@field TextMaterial UFTextBlock
---@field TextName UFTextBlock
---@field TextNotice UFTextBlock
---@field TextRecipe UFTextBlock
---@field ToggleBtnFavor UToggleButton
---@field VerIconTabs CommVerIconTabsView
---@field AnimIn UWidgetAnimation
---@field AnimPanelIn1 UWidgetAnimation
---@field AnimPanelIn2 UWidgetAnimation
---@field AnimPanelIn3 UWidgetAnimation
---@field AnimSearchBack UWidgetAnimation
---@field AnimSearchResultUpdate UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CraftingLogMainPanelView = LuaClass(UIView, true)

function CraftingLogMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Bkg = nil
	--self.BorderNotice = nil
	--self.BtnAdd = nil
	--self.BtnClose = nil
	--self.BtnCraft = nil
	--self.BtnGoBuy = nil
	--self.BtnMax = nil
	--self.BtnPractise = nil
	--self.BtnSorting = nil
	--self.BtnSubtract = nil
	--self.CommLight152Slot = nil
	--self.CommonBookBkg = nil
	--self.CommonTitle = nil
	--self.DropDown = nil
	--self.FButton_58 = nil
	--self.FCanvasPanel_93 = nil
	--self.FImage_601 = nil
	--self.FTextBlock_61 = nil
	--self.HorTabs = nil
	--self.IconMost = nil
	--self.ImgAdd = nil
	--self.ImgAddDisable = nil
	--self.ImgCollect = nil
	--self.ImgMaxNormal = nil
	--self.ImgSubtract = nil
	--self.ImgSubtractDisable = nil
	--self.InputSearch = nil
	--self.PanelAmountSetting = nil
	--self.PanelFix = nil
	--self.PanelInfo = nil
	--self.PanelInfo_TutorialGuide = nil
	--self.PanelListEmpty = nil
	--self.PanelTabFilter = nil
	--self.PanelTabList = nil
	--self.RichTextTextRecipeDetail = nil
	--self.SearchHistory = nil
	--self.TableViewConditions = nil
	--self.TableViewCrystal = nil
	--self.TableViewList = nil
	--self.TableViewMaterial = nil
	--self.TextAmount = nil
	--self.TextCraftTips = nil
	--self.TextCrystal = nil
	--self.TextDescription = nil
	--self.TextListEmpty = nil
	--self.TextMaterial = nil
	--self.TextName = nil
	--self.TextNotice = nil
	--self.TextRecipe = nil
	--self.ToggleBtnFavor = nil
	--self.VerIconTabs = nil
	--self.AnimIn = nil
	--self.AnimPanelIn1 = nil
	--self.AnimPanelIn2 = nil
	--self.AnimPanelIn3 = nil
	--self.AnimSearchBack = nil
	--self.AnimSearchResultUpdate = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CraftingLogMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Bkg)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.BtnCraft)
	self:AddSubView(self.BtnPractise)
	self:AddSubView(self.CommLight152Slot)
	self:AddSubView(self.CommonBookBkg)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.DropDown)
	self:AddSubView(self.HorTabs)
	self:AddSubView(self.InputSearch)
	self:AddSubView(self.SearchHistory)
	self:AddSubView(self.VerIconTabs)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CraftingLogMainPanelView:OnInit()
	self:TableViewAdapterInit()
	self.Binders = {
		{"TitleName", UIBinderSetText.New(self, self.CommonTitle.TextTitleName)},
		{"SubTitle", UIBinderSetText.New(self, self.CommonTitle.TextSubtitle)},
		{"TextListEmpty", UIBinderSetText.New(self, self.TextListEmpty)},
		{"TextCraftTips", UIBinderSetText.New(self, self.TextCraftTips)},
		{"PropItemTabAdapter", UIBinderUpdateBindableList.New(self, self.PropItemTabsAdapter)},
        {"PropItemTabAdapterIndex", UIBinderSetSelectedIndex.New(self, self.PropItemTabsAdapter)},
		{"ConditionItemAdapter", UIBinderUpdateBindableList.New(self, self.ConditionItemAdapter)},
		{"MaterialItemAdapter", UIBinderUpdateBindableList.New(self, self.MaterialItemAdapter)},
		{"CrystalItemAdapter", UIBinderUpdateBindableList.New(self, self.TableViewCrystalAdapter)},
		{"bPanelAmountRootShow", UIBinderSetIsVisible.New(self, self.PanelAmountRoot)},
		{"bLeveQuestMarked", UIBinderSetIsVisible.New(self, self.FImage_601)},
		----------------------------------------------------------------------------------
		{"IconID", UIBinderSetBrushFromIconID.New(self, self.CommLight152Slot.Icon)},
        {"ItemQualityImg", UIBinderSetBrushFromAssetPath.New(self, self.CommLight152Slot.ImgBg)},
        {"TextNum", UIBinderSetText.New(self, self.CommLight152Slot.RichTextNum)},
		{"InUseItemName", UIBinderSetText.New(self, self.TextName)},
		{"InUseItemDes", UIBinderSetText.New(self, self.TextDescription)},
		{"TextNoticeTips", UIBinderSetText.New(self, self.TextNotice)},
		{"InUseItemRecipeDetail", UIBinderSetText.New(self, self.RichTextTextRecipeDetail)},
		{"CraftingTextAmount", UIBinderSetText.New(self, self.TextAmount)},
		{"CraftingTextAmountColor", UIBinderSetColorAndOpacityHex.New(self, self.TextAmount)},

		{"bBorderNoticeShow", UIBinderSetIsVisible.New(self, self.BorderNotice)},
		{"BtnCraftText", UIBinderSetText.New(self, self.BtnCraft.TextContent)},
		{"bBtnCloseShow", UIBinderSetIsVisible.New(self, self.BtnClose)},
		{"bImgSubtractShow", UIBinderSetIsVisible.New(self, self.ImgSubtract)},
		{"bImgSubtractDisableShow", UIBinderSetIsVisible.New(self, self.ImgSubtractDisable)},
		{"bImgAddShow", UIBinderSetIsVisible.New(self, self.ImgAdd)},
		{"bImgAddDisableShow", UIBinderSetIsVisible.New(self, self.ImgAddDisable)},
		{"bPanelListEmptyShow", UIBinderSetIsVisible.New(self, self.PanelListEmpty)},
		{"bBatchMakeShow", UIBinderSetIsVisible.New(self, self.PanelAmountSetting)},
		{"bImgMaxNormalShow", UIBinderSetIsVisible.New(self, self.ImgMaxNormal)},
		{"bImgMaxNormalShow", UIBinderSetIsVisible.New(self, self.IconMost)},
		{"bTrainMakeShow", UIBinderSetIsVisible.New(self, self.BtnPractise)},
		{"bBuyShow", UIBinderSetIsVisible.New(self, self.FCanvasPanel_93)},

		----------------------------------------------------------------------------------
		{"bVerIconTabsShow", UIBinderSetIsVisible.New(self, self.VerIconTabs)},
		{"bPanelInfoShow", UIBinderSetIsVisible.New(self, self.PanelInfo)},
		{"bDropDownShow", UIBinderSetIsVisible.New(self, self.DropDown)},
		{"bDropDownShow", UIBinderSetIsVisible.New(self, self.BtnSorting, false, true)},
		{"bDropDownTextQuantityShow", UIBinderSetIsVisible.New(self, self.DropDown.TextQuantity)},
		----------------------------------------------------------------------------------
		{"bSetFavor", UIBinderSetIsChecked.New(self, self.ToggleBtnFavor)},
		{"bSearchHistoryShow", UIBinderSetIsVisible.New(self, self.SearchHistory)},
	}
end

function CraftingLogMainPanelView:TableViewAdapterInit()
	--  道具
	self.PropItemTabsAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList, nil, true)
	-- 制作说明
	self.ConditionItemAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewConditions, nil, false)
	-- 素材
	self.MaterialItemAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewMaterial, self.OnMaterialItemClicked, true)
	-- 水晶
	self.TableViewCrystalAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewCrystal, self.OnMaterialItemClicked, true)
	--  搜索历史
	
	self.PropItemTabsAdapter:InitCategoryInfo(CraftingLogCareerItemVM, CraftingLogVM.ItemTypePredicate)
end

function CraftingLogMainPanelView:OnDestroy()
end

function CraftingLogMainPanelView:OnShow()
	self.BtnPractise:SetText(LSTR(80047)) --练习制作
	self.TextRecipe:SetText(LSTR(80048)) --配方信息
	--self.TextCraftTips:SetText(LSTR(80049)) --制作条件
	self.TextMaterial:SetText(LSTR(80050)) --素材
	self.TextCrystal:SetText(LSTR(80051)) --水晶
	self.FTextBlock_61:SetText(LSTR(80064)) --一键购买
	self.CommonTitle.CommInforBtn:SetHelpInfoID(11125)

	if CraftingLogMgr.HistoryUpdateMsg then
		CraftingLogMgr:HistoryUpdate()
	end
	CraftingLogMgr:SeverDatainit()

	local bConvenient = CraftingLogMgr.bConvenient
	UIUtil.SetIsVisible(self.FButton_58, bConvenient, bConvenient)
	local CraftingState = CraftingLogMgr.CraftingState
	local State = CraftingLogDefine.CraftingLogState
	self.StayCraftingState = CraftingState == State.Searching

	self.HorTabs:SetRedDotType(ProtoCS.NoteType.NOTE_TYPE_PRODUCTION)
	self.VerIconTabs:UpdateItems(CraftingLogMgr:GetAllCareerData(), CraftingLogMgr:GetChoiceCareer())
	CraftingLogVM.bVerIconTabsShow = true
	CraftingLogVM.bSearchHistoryShow = false
	CraftingLogVM.bDropDownTextQuantityShow = true
	self.InputSearch:SetHintText(LSTR(CraftingLogDefine.SearchHintLabel))
	self.bPlayAnimation = true

end

function CraftingLogMainPanelView:OnHide()
	CraftingLogMgr:ViewHide()
	CraftingLogMgr:DelRedDotsOnHide()
end

function CraftingLogMainPanelView:OnRegisterUIEvent()
	-- 职业
	UIUtil.AddOnSelectionChangedEvent(self, self.VerIconTabs, self.OnCommVerIconTabsChanged)
	-- 分类
	UIUtil.AddOnSelectionChangedEvent(self, self.HorTabs, self.OnSelectionChangedHorTabs)
	-- 筛选
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDown, self.OnSelectionChangedDropDown)
	-- 数量减
	UIUtil.AddOnClickedEvent(self, self.BtnSubtract, self.OnSubtractBtnClicked)
	-- 数量加
	UIUtil.AddOnClickedEvent(self, self.BtnAdd, self.OnAddBtnClicked)
	-- 数量最大
	UIUtil.AddOnClickedEvent(self, self.BtnMax, self.OnMaxBtnClicked)
	-- 制作
	UIUtil.AddOnClickedEvent(self, self.BtnCraft, self.OnBtnCraftClicked)
	-- 训练制作
	UIUtil.AddOnClickedEvent(self, self.BtnPractise, self.OnBtnTrainClicked)

	-- 搜索输入框
	self.InputSearch:SetCallback(self, nil, self.OnSureSearch, self.SearchBackClicked)
	UIUtil.AddOnFocusReceivedEvent(self, self.InputSearch.TextInput, self.OnBtnSearchClick)
	UIUtil.AddOnFocusLostEvent(self, self.InputSearch.TextInput, self.OnTextFocusLost)

	--一键购买
	UIUtil.AddOnClickedEvent(self, self.BtnGoBuy, self.OnBuyAll)
	-- 制作效率提示
	UIUtil.AddOnClickedEvent(self, self.FButton_58, self.OnNoticeBtnClicked)
	--收藏
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnFavor, self.OnToggleBtnFavorClick)
	-- slot
	self.CommLight152Slot:SetClickButtonCallback(self.CommLight152Slot, self.OnIconClick)
	--排序按钮
	UIUtil.AddOnClickedEvent(self, self.BtnSorting, self.OnBtnSorting)
end

function CraftingLogMainPanelView:OnBtnSorting()
    CraftingLogMgr:OnBtnSorting(self.DropDown)
end

function CraftingLogMainPanelView:OnIconClick(ItemView)
    local ItemData = CraftingLogMgr.NowPropData
	if ItemData and ItemData.ProductID > 0 then
		--有制作成品时要和背包里物品显示的属性一致
		local Item = _G.BagMgr:GetItemByResID(ItemData.ProductID) or {ResID = ItemData.ProductID}
		ItemTipsUtil.ShowTipsByItem(Item, ItemView, {X = 0, Y = 0})
	end
end

function CraftingLogMainPanelView:OnMaterialItemClicked(Index, ViewModel, ItemView)
	if ViewModel.ItemID ~= 0 then
		local Item = ItemUtil.CreateItem(ViewModel.ItemID)
		local ItemNum = ViewModel.ItemData.ItemNum
		local PropHaveNumber = ViewModel.IsHQ and _G.BagMgr:GetItemHQNum(ViewModel.ItemID) or _G.BagMgr:GetItemNumWithHQ(ViewModel.ItemID)
		Item.NeedBuyNum = ItemNum - PropHaveNumber
		ItemTipsUtil.ShowTipsByItem(Item, ItemView, _G.UE4.FVector2D(0, 0))
	end
end

---@type 点击收藏
function CraftingLogMainPanelView:OnToggleBtnFavorClick()
	local ItemData = CraftingLogMgr.NowPropData
	if ItemData == nil then
		return
	end
	CraftingLogMgr:SendMsgMarkOrNotinfo(ItemData.ID, not CraftingLogVM.bSetFavor)
    if CraftingLogVM.bSetFavor then
		self.ToggleBtnFavor:SetCheckedState(_G.UE.EToggleButtonState.Checked)
	else
		self.ToggleBtnFavor:SetCheckedState(_G.UE.EToggleButtonState.UnChecked)
    end
end

function CraftingLogMainPanelView:CraftingLogFastSearch(SearchInfo)
	self.InputSearch:SetText(SearchInfo)
	self:OnSureSearch(SearchInfo)
	CraftingLogMgr.OnShowSearchInfo = nil
end

function CraftingLogMainPanelView:OnBtnSearchClick()
	CraftingLogMgr.CraftingState = CraftingLogState.InFunSearch
	CraftingLogMgr.NowChoicePropData = CraftingLogMgr.NowPropData

	self:ShowSearchHistory(true)
	--self.InputSearch:SetText("")
	UIUtil.SetIsVisible(self.InputSearch.BtnCancel,true,true)
end

function CraftingLogMainPanelView:ShowSearchHistory(HistoryVisible)
	if self.HistoryVisible ~= nil and self.HistoryVisible == HistoryVisible then
		return
	end
	self.HistoryVisible = HistoryVisible
	local InputSearch = self.InputSearch
    local FSlateColor = _G.UE.FSlateColor
    local FLinearColor = _G.UE.FLinearColor
	CraftingLogVM.bSearchHistoryShow = HistoryVisible
	if HistoryVisible then
        CraftingLogVM.bPanelInfoShow = false
        CraftingLogVM.bPanelListEmptyShow = false
		InputSearch.SytleType = CommUIStyleType.Dark
		InputSearch.InputTextColor = FSlateColor(FLinearColor.FromHex("#d5d5d5")) --白
    else
        CraftingLogVM.bPanelInfoShow = CraftingLogMgr.NowPropData ~= nil
		InputSearch.SytleType = CommUIStyleType.Light
		InputSearch.InputTextColor = FSlateColor(FLinearColor.FromHex("#313131")) --黑
    end
	InputSearch:UpdateStyle()
    InputSearch:SetInputTextWidgetStyle(#InputSearch:GetText() <= 0)
	UIUtil.SetIsVisible(self.PanelTabList, not HistoryVisible)
	UIUtil.SetIsVisible(self.CommonBookBkg, not HistoryVisible)
	self.VerIconTabs.AdapterTabs:SetAlwaysNotifySelectChanged(HistoryVisible)
end

--搜索确定提交
function CraftingLogMainPanelView:OnSureSearch(Info)
	FLOG_INFO("CraftingLogMainPanelView:OnSureSearch")
	local SearchInfo = self.InputSearch:GetText()
	--如果info为nil，或者是空字符串，直接返回
	if string.isnilorempty(Info) or string.isnilorempty(SearchInfo) then
		return
	end
	if Info ~= SearchInfo then
		Info = SearchInfo
	end
	self:PlayAnimation(self.AnimSearchBack)
	self:ShowSearchHistory(false)
	if CraftingLogMgr.CraftingState == CraftingLogState.MaterialsSeaarch then
		self.TextListEmpty:SetText(LSTR(CraftingLogDefine.InterGetNoSearchResult))
	else
		self.TextListEmpty:SetText(LSTR(CraftingLogDefine.GetNoSearchResult))
	end
	CraftingLogMgr.CraftingState = CraftingLogState.Searching
	--保存历史记录
	CraftingLogMgr:SetSearchHistory(Info, false)
	--取消所有页签的选中
    self.VerIconTabs.AdapterTabs:CancelSelected()
    self.HorTabs:CancelSelected()
    self.DropDown:CancelSelected()
	--下拉框显示不限，且不可切换
	CraftingLogVM.bDropDownShow = true
	CraftingLogVM.bDropDownTextQuantityShow = false
    self.DropDown:UpdateItems({{Name = LSTR(70042)}}) --不限
    self.DropDown.ToggleBtnExtend:SetCheckedState(_G.UE.EToggleButtonState.Locked)
    --隐藏左上角副标题
    UIUtil.SetIsVisible(self.CommonTitle.TextSubTitle, false)
    CraftingLogMgr.NowSearchPropData = nil

	--显示搜索结果
	CraftingLogVM.bPanelInfoShow = false
	CraftingLogVM.bPanelListEmptyShow = false
	local ResultDataList, PrecisionIndex = CraftingLogMgr:GetSearchData(Info)
	CraftingLogVM:UpdatePropItemListTab(ResultDataList, PrecisionIndex)
    self.PropItemTabsAdapter:ScrollToIndex(PrecisionIndex)
	--self:PlayAnimation(self.AnimSearchResultUpdate)
	self.StayCraftingState = false
end

function CraftingLogMainPanelView:OnTextFocusLost()
	FLOG_INFO("CraftingLogMainPanelView:OnTextFocusLost")
    UIUtil.SetIsVisible(self.InputSearch.BtnCancelNode, true,true)
end

function CraftingLogMainPanelView:SearchBackClicked()
	self:PlayAnimation(self.AnimSearchBack)
	self:ShowSearchHistory(false)
	CraftingLogMgr:ChangeNowProfData()
	if CraftingLogMgr.NowPropData ~= nil then
		self:RefreshSearchData(CraftingLogMgr.NowPropData)
		CraftingLogMgr.NowSearchPropData = nil
	else
		self.HorTabs:SetSelectedIndex(CraftingLogMgr.LastHorTabIndex)
	end
	self:ExitSearchState()
end

function CraftingLogMainPanelView:RefreshSearchData(ItemData)
	if ItemData == nil then
		return
	end
	local VerIndex = 1
	local AllAllowData = CraftingLogMgr:GetAllCareerData()
	for key, value in ipairs(AllAllowData) do
		if value.Prof == ItemData.Craftjob then
			VerIndex = key
			break
		end
	end
	self.VerIconTabs:SetSelectedIndex(VerIndex)

	local DropIndex = 1
	if ItemData.RecipeType == ProtoRes.RecipeType.RecipeTypeRoutine then
		self.HorTabs:SetSelectedIndex(FilterALLType.Level)
		local DropDownData = CraftingLogMgr:GetDropDownData(FilterALLType.Level)
		local Level = ItemData.RecipeLevel
		for key, value in pairs(DropDownData) do
			local FloorLimitLevel = value.FloorLimitLevel
			local UpperLimitLevel = value.UpperLimitLevel
			if FloorLimitLevel <= Level and UpperLimitLevel >= Level then
				DropIndex = key
			end
		end
	else
		self.HorTabs:SetSelectedIndex(FilterALLType.Career)
		local DropDownData = CraftingLogMgr:GetDropDownData(FilterALLType.Career)
		for key, value in pairs(DropDownData) do
			if value.Name == ProtoEnumAlias.GetAlias(ProtoRes.RecipeType, ItemData.RecipeType) then
				DropIndex = key
			end
		end
	end
	self.DropDown:SetSelectedIndex(DropIndex)

	local TablePropData = CraftingLogMgr:GetTablePropData()
	for key, value in pairs(TablePropData) do
		if value.ID == ItemData.ID then
			CraftingLogVM:UpdatePropItemListTab(TablePropData, key)
			self.PropItemTabsAdapter:ScrollToIndex(key)
			break
		end
	end
end

---@type 退出搜索状态
function CraftingLogMainPanelView:ExitSearchState()
	-- 如果不是搜索状态，或要保持搜索状态，则返回
    if CraftingLogMgr.CraftingState == CraftingLogState.Picking or self.StayCraftingState then
        return
    end
	self:ShowSearchHistory(false)
    CraftingLogMgr.CraftingState = CraftingLogState.Picking
    self.DropDown.ToggleBtnExtend:SetCheckedState(_G.UE.EToggleButtonState.Unchecked)
    UIUtil.SetIsVisible(self.CommonTitle.TextSubTitle, true)
	CraftingLogVM.bDropDownTextQuantityShow = true
	UIUtil.SetIsVisible(self.InputSearch.BtnCancelNode, false)
    self.InputSearch:SetText("")
	CraftingLogMgr.SearchInfo = nil
	if CraftingLogMgr.LastHorTabIndex and CraftingLogMgr.LastHorTabIndex == CraftingLogDefine.FilterALLType.Career then
		self.TextListEmpty:SetText(LSTR(CraftingLogDefine.SpecialListEmpty))
	elseif CraftingLogMgr.LastHorTabIndex and CraftingLogMgr.LastHorTabIndex == CraftingLogDefine.FilterALLType.Collect then
		self.TextListEmpty:SetText(LSTR(CraftingLogDefine.CollectListEmpty))
	else
		self.TextListEmpty:SetText(LSTR(CraftingLogDefine.TextListEmpty))
	end
end

-- 职业更变
function CraftingLogMainPanelView:OnCommVerIconTabsChanged(CareerIndex)
	if CraftingLogMgr.CraftingState ~= CraftingLogState.Picking then
	self:ExitSearchState()
		CraftingLogMgr.NowSearchPropData = nil
		CraftingLogMgr:ChangeNowProfData()
	end
	self:PlayAnimation(self.AnimPanelIn1)
	CraftingLogMgr:VerTabsChanged(CareerIndex)

	-- 分类部分
	--self.HorTabs:OnShow()
	--self:OnSelectionChangedHorTabs(CraftingLogMgr:GetCareerCheckData().HorIndex or 1)
	local HorIndex = CraftingLogMgr:GetCareerCheckData().HorIndex or 1
	local SelectResult = self.HorTabs:SetSelectedIndex(HorIndex)
	if SelectResult == false then
		self.HorTabs:OnSelectChanged(HorIndex)
	end
	self.VerIconTabs.AdapterTabs:ScrollIndexIntoView(CareerIndex)
	local PropData = self.VerIconTabs.AdapterTabs:GetItemDataByIndex(CareerIndex)
	CraftingLogVM:SetCareerTitle(RoleInitCfg:FindRoleInitProfName(PropData.ID))

	_G.ObjectMgr:CollectGarbage(false, true, false)
end

-- 分类更变
function CraftingLogMainPanelView:OnSelectionChangedHorTabs(Index)
	CraftingLogMgr:SetLastHorTabIndex(Index)
    -- 如果是搜索状态 且 不用保持（要在SetLastHorTabIndex后执行）
	if CraftingLogMgr.CraftingState ~= CraftingLogState.Picking and self.StayCraftingState == false then
        local LastChoiceCareer = CraftingLogMgr.LastChoiceCareer
		local VerIndex = 1
		if LastChoiceCareer then
			local AllCareerData = CraftingLogMgr:GetAllCareerData()
			for Index, value in pairs(AllCareerData) do
				if value.Prof == LastChoiceCareer then
					VerIndex = Index
				end
			end
		end
        self.VerIconTabs:SetSelectedIndex(VerIndex)
	else
		self:PlayAnimation(self.AnimPanelIn1)
    end

	-- 分类部分
	-- local SelectResult = self.HorTabs:SetSelectedIndex(Index)

	-- 筛选部分
	local DropDownListData = CraftingLogMgr.FilterLevelList
	local LastDropDownIndex = CraftingLogMgr.LastDropDownIndex
	local HaveData = #DropDownListData > 0
	if not HaveData then
		CraftingLogVM:UpdatePropItemListTab({}, 1)
	else
		if LastDropDownIndex > #DropDownListData then
			self.DropDown:UpdateItems(DropDownListData, 1)
		else
			self.DropDown:UpdateItems(DropDownListData, LastDropDownIndex)
		end
	end
	
	local CurDropDownIndex = self.DropDown.SelectedIndex
	if LastDropDownIndex == CurDropDownIndex then
		self:OnSelectionChangedDropDown(LastDropDownIndex)
	end
end

-- 筛选更变
function CraftingLogMainPanelView:OnSelectionChangedDropDown(Index)
	local Data = self.DropDown:GetDropDownItemDataByIndex(Index)
	if Data and Data.Name == LSTR(70042) then --不限
		return
	end
	if self.bPlayAnimation then
        self:PlayAnimation(self.AnimPanelIn2)
    end
    self.bPlayAnimation = true

	local DropDownListData = CraftingLogMgr.FilterLevelList
	if not table.is_nil_empty(DropDownListData) then
		self.DropDown.TextQuantity:SetText(DropDownListData[Index].TextQuantityStr or "")
	end

	CraftingLogMgr:SetLastDropDownIndex(Index)
	local TablePropData = CraftingLogMgr:GetTablePropData()
	local NowRecipeIndex = CraftingLogMgr:GetRecipeIndex()

	local HorTabsIndex = CraftingLogMgr.LastHorTabIndex
	local ProfID = CraftingLogMgr.LastChoiceCareer
	--配方的红点显示,下拉框选项红点的消失
	local DropdownIndex = not table.is_nil_empty(CraftingLogMgr.FilterLevelList) and CraftingLogMgr.FilterLevelList[Index].DropdownIndex
	local DropResDotName = nil
	if DropdownIndex then
		DropResDotName = CraftingLogMgr:GetRedDotName(ProfID, HorTabsIndex, DropdownIndex)
	end

	if DropResDotName then
        local SpecialType = GatheringLogDefine.SpecialType
		local DropRedNode =  _G.RedDotMgr:FindRedDotNodeByName(DropResDotName)
        local ReadData = CraftingLogMgr:GetSpecialReadData(ProfID, DropdownIndex)
		local ReadVersion = ReadData and ReadData.ReadVersion or 0
		local Volume = ReadData and ReadData.Volume or 0
		if (DropdownIndex == SpecialType.SpecialTypeCollection or DropdownIndex == SpecialType.SpecialTypeSecret) and DropRedNode.IsStrongReminder == true then
			_G.RedDotMgr:DelRedDotByName(DropResDotName)
			if DropdownIndex == SpecialType.SpecialTypeSecret then
				CraftingLogMgr:SendMsgRemoveDropNewData(ProfID, nil, DropdownIndex, nil, true)
			else
				CraftingLogMgr.SpecialDropRedDotLists[ProfID][SpecialType.SpecialTypeCollection] = {ReadVersion=0, Volume=0, IsRead=true, SpecialType=3}
				CraftingLogMgr:SpecialRedDotDataUpdate(ProfID)
				_G.EventMgr:SendEvent(EventID.UpdateTabRedDot)
				_G.EventMgr:SendEvent(EventID.CraftingLogUpdateHorTabs, self.LastHorTabIndex)
			end

			DropResDotName = CraftingLogMgr:GetRedDotName(ProfID, HorTabsIndex, DropdownIndex, CraftingLogDefine.RedDotID.CraftingLogProf)
			DropRedNode =  _G.RedDotMgr:FindRedDotNodeByName(DropResDotName)
		end

		if DropRedNode then
			if table.is_nil_empty(DropRedNode.SubRedDotList) then
				DropRedNode.SubRedDotList = {}
				if TablePropData and #TablePropData > 0 then
					for _, Item in pairs(TablePropData) do
						if Item.TextTips == nil
						and ((HorTabsIndex == FilterALLType.Career and DropdownIndex == SpecialType.SpecialTypeCollection ) --and ReadVersion < Item.RecipeLevel )
							or (HorTabsIndex == FilterALLType.Career and DropdownIndex == SpecialType.SpecialTypeSecret and ReadVersion < CraftingLogMgr:VersionNameToNum(Item.Version) or (ReadVersion == CraftingLogMgr:VersionNameToNum(Item.Version) and CraftingLogMgr:IsHaveUnReadEsotericaVolume(ProfID, Volume)) )
							or HorTabsIndex == FilterALLType.Level )then
								local ItemName = ItemUtil.GetItemName(Item.ProductID)
							local Name = string.format("%s/%s",DropResDotName, ItemName)
							_G.RedDotMgr:AddRedDotByName(Name)
							CraftingLogMgr.ItemRedDotNameList[Item.ID] = Name
						end
					end
				end
			end
		end

		if HorTabsIndex and HorTabsIndex == FilterALLType.Level then
			if CraftingLogMgr.CancelNormalDropRedDotLists[ProfID] == nil then
				CraftingLogMgr.CancelNormalDropRedDotLists[ProfID] = {}
			end
			CraftingLogMgr.CancelNormalDropRedDotLists[ProfID][DropdownIndex] = true
		elseif HorTabsIndex and HorTabsIndex == FilterALLType.Career then
			if CraftingLogMgr.CancelSpecialDropRedDotLists[ProfID] == nil then
				CraftingLogMgr.CancelSpecialDropRedDotLists[ProfID] = {}
			end
			CraftingLogMgr.CancelSpecialDropRedDotLists[ProfID][DropdownIndex] = true
		end
	end

	CraftingLogVM:UpdatePropItemListTab(TablePropData, NowRecipeIndex)
	self.PropItemTabsAdapter:ScrollToIndex(NowRecipeIndex)

	if HorTabsIndex == FilterALLType.Level then
		_G.ObjectMgr:CollectGarbage(false, true, false)
	end
end

function CraftingLogMainPanelView:UpdateDropDownItemsProgress()
	_G.FLOG_INFO("CraftingLogMainPanelView:UpdateDropDownItemsProgress")
	CraftingLogMgr.FilterLevelList = {}
	CraftingLogMgr:IsHorIndexChoiceWithLevel()
	local DropDownListData = CraftingLogMgr.FilterLevelList
	local LastDropDownIndex = CraftingLogMgr:GetLastDropDownIndex()
	local HaveData = #DropDownListData > 0
	if HaveData and LastDropDownIndex <= #DropDownListData then
		self.DropDown:UpdateItems(DropDownListData, LastDropDownIndex)
	end
end

--简易制作
function CraftingLogMainPanelView:OnBtnSimpleCraftClicked()
	CraftingLogVM:EaseMakeProps()
end

-- 数量减
function CraftingLogMainPanelView:OnSubtractBtnClicked()
	self:OnAmountChoiced(CraftingLogDefine.AmountChoicedType.Subtract)
end

-- 数量加
function CraftingLogMainPanelView:OnAddBtnClicked()
	self:OnAmountChoiced(CraftingLogDefine.AmountChoicedType.Add)
end

--最大
function CraftingLogMainPanelView:OnMaxBtnClicked()
	self:OnAmountChoiced(CraftingLogDefine.AmountChoicedType.Max)
end

--数量变化---
---@param Type CraftingLogDefine.AmountChoicedType
function CraftingLogMainPanelView:OnAmountChoiced(Type)
	local NowMakeCount, MaxMakeCount = CraftingLogMgr.NowMakeCount, CraftingLogMgr:GetMaxMakeCount()
	if MaxMakeCount < 1 then
		return
	end
    local AmountState = CraftingLogDefine.AmountState
	if Type == CraftingLogDefine.AmountChoicedType.Subtract then
		if NowMakeCount <= 1 then
			return
		end
		NowMakeCount = NowMakeCount - 1
		CraftingLogVM:OnAmountPromptChange(
			NowMakeCount == 1 and AmountState.Minimum or AmountState.DropUnMax
		)
	elseif Type == CraftingLogDefine.AmountChoicedType.Add then
		if NowMakeCount >= MaxMakeCount then
			return
		end
		NowMakeCount = NowMakeCount + 1
		if NowMakeCount >= MaxMakeCount then
			CraftingLogVM:OnAmountPromptChange(AmountState.Maximum)
		else
			CraftingLogVM:OnAmountPromptChange(AmountState.AddUnMin)
		end
	elseif Type == CraftingLogDefine.AmountChoicedType.Max then
		if MaxMakeCount <= 0 or NowMakeCount >= MaxMakeCount then
			return
		end
		NowMakeCount = MaxMakeCount
		CraftingLogVM:OnAmountPromptChange(AmountState.Maximum)
	end

	CraftingLogVM:OnAmountChange(NowMakeCount)
	CraftingLogMgr.NowMakeCount = NowMakeCount
end

--Tips
function CraftingLogMainPanelView:OnNoticeBtnClicked()
	if CraftingLogMgr.bConvenient then
        CraftingLogMgr:TestEnoughToDo()
    end
end

--一键购买
function CraftingLogMainPanelView:OnBuyAll()
	_G.UIViewMgr:ShowView(_G.UIViewID.CraftingLogShopWin)
end

-- 制作
function CraftingLogMainPanelView:OnBtnCraftClicked()
	CraftingLogVM:MakeProps(false)
end

function CraftingLogMainPanelView:OnBtnTrainClicked()
	CraftingLogVM:MakeProps(true)
end

function CraftingLogMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.CraftingLogMakeSucceedBack, self.CraftingLogMakeSucceed)
	self:RegisterGameEvent(_G.EventID.CraftingLogCancelMake, self.CraftingLogCancelMake)
	self:RegisterGameEvent(_G.EventID.CraftingLogHistoryInit, self.CraftingLogHistoryInit)
	self:RegisterGameEvent(_G.EventID.CraftingLogCollectInit, self.CraftingLogCollectInit)
	self:RegisterGameEvent(_G.EventID.CraftingLogButtonState, self.CraftingLogButtonState)
	self:RegisterGameEvent(_G.EventID.CraftingLogFastSearch, self.CraftingLogFastSearch)
	self:RegisterGameEvent(_G.EventID.BagUpdate, self.UpdateCraftMaterial)
	self:RegisterGameEvent(_G.EventID.CraftingLogExitSearchState, self.ExitSearchState)
	self:RegisterGameEvent(_G.EventID.CraftingLogUpdateHorTabs, self.OnSelectionChangedHorTabs)
	self:RegisterGameEvent(_G.EventID.CraftingLogUpdateItemAnim, self.OnCraftingLogUpdateItemAnim)
end


function CraftingLogMainPanelView:OnCraftingLogUpdateItemAnim()
	self:PlayAnimation(self.AnimPanelIn3)
end

function CraftingLogMainPanelView:CraftingLogMakeSucceed(Data)
	if CraftingLogMgr.NowPropData == nil then
		return
	end
	if CraftingLogMgr.NowPropData.ID == Data.ID then
		CraftingLogVM:PropItemOnClick(Data, CraftingLogMgr.CraftingState)
	end
end

function CraftingLogMainPanelView:CraftingLogCancelMake(ID)
	local LastHorTabIndex = CraftingLogMgr.LastHorTabIndex
    if LastHorTabIndex == CraftingLogDefine.FilterALLType.Collect then
		--从列表移除（不用刷新整个列表了）
		local ItemVM = CraftingLogVM:GetItemVMByItemID(ID)
		CraftingLogVM.PropItemTabAdapter:Remove(ItemVM)
        local Length = CraftingLogVM.PropItemTabAdapter:Length()
        if Length >= 1 then
			--移除后选中列表的第一个
			local Elem = CraftingLogVM.PropItemTabAdapter:Get(1)
			CraftingLogVM:PropItemOnClick(Elem.ItemData)
			--刷新下拉框右侧的收藏数字
			CraftingLogMgr:GetDropDownData(LastHorTabIndex)
			local DropDownListData = CraftingLogMgr.FilterLevelList
			local LastDropDownIndex = CraftingLogMgr.LastDropDownIndex
			if not table.is_nil_empty(DropDownListData) then
				self.DropDown.TextQuantity:SetText(DropDownListData[LastDropDownIndex].TextQuantityStr or "")
			end
			self.DropDown:UpdateItems(DropDownListData, LastDropDownIndex)
        else
			CraftingLogMgr:IsChoiceWithCollect()
			self.bPlayAnimation = false
			self:OnSelectionChangedHorTabs(LastHorTabIndex)
        end
    else
        local PropItem = CraftingLogVM:GetPropItemByID(ID)
        if PropItem then
            PropItem:SetCollectShow()
        end
    end
end

function CraftingLogMainPanelView:CraftingLogHistoryInit()
	CraftingLogVM:HistoryInitChangeState()
	if CraftingLogMgr.CraftingState == CraftingLogState.Picking then
		--如果不在搜索状态，更新下拉框item的制作进度统计
		self:UpdateDropDownItemsProgress()
	end
end

function CraftingLogMainPanelView:CraftingLogCollectInit()
	CraftingLogVM:CollectInitChangeState()
end

function CraftingLogMainPanelView:CraftingLogButtonState(IsEnable)
	if CraftingLogMgr.NowPropData ~= nil then
		local Prof = CraftingLogMgr.NowPropData.Craftjob
		if CraftingLogMgr:GetProfIsLock(Prof) then
			IsEnable = CraftingLogVM:GetSwichProfState(Prof)
		end
    end

	if IsEnable then
		self.BtnCraft:SetIsRecommendState(true)	
		UIUtil.TextBlockSetColorAndOpacityHex(self.BtnCraft.TextContent, "#fffcf1")
	else
		self.BtnCraft:SetIsDisabledState(true, true)	
		UIUtil.TextBlockSetColorAndOpacityHex(self.BtnCraft.TextContent, "#828282")
	end
end

function CraftingLogMainPanelView:OnRegisterBinder()
	self:RegisterBinders(CraftingLogVM, self.Binders)
end

-- 检测背包内物品刷新时是否需要刷新材料
function CraftingLogMainPanelView:UpdateCraftMaterial(UpdateItem)
	local NowPropData = CraftingLogMgr.NowPropData
	if NowPropData == nil then
		return
	end
	local Materials = NowPropData.Material
	local CrystalTypes = NowPropData.CrystalType
	local NeedRefresh = false
	for _, v1 in pairs(UpdateItem) do
		local Elem = v1
		local PstItem = Elem.PstItem
		local ResID = PstItem.ResID
		for _, v2 in pairs(Materials) do
			local Material = v2
			if Material.ItemID == ResID then
				NeedRefresh = true
				break
			end
		end
		if NeedRefresh then
			break
		end
		for _, v3 in pairs(CrystalTypes) do
			local CrystalType = v3
			if CrystalType.ItemID == ResID then
				NeedRefresh = true
				break
			end
		end
	end
	if NeedRefresh then
		CraftingLogVM:PropItemOnClick(NowPropData, CraftingLogMgr.CraftingState)
	end
	if _G.UIViewMgr:IsViewVisible(_G.UIViewID.CraftingLogShopWin) then
		_G.CraftingLogShopWinVM:UpdataShoppingItemBagNum(UpdateItem)
	end
end

return CraftingLogMainPanelView
