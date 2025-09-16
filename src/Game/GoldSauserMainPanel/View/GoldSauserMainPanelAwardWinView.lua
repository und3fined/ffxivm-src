---
--- Author: Administrator
--- DateTime: 2025-03-11 10:19
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local ProtoRes = require("Protocol/ProtoRes")
local EventID = require("Define/EventID")
local UIViewID = require("Define/UIViewID")
local UIUtil = require("Utils/UIUtil")
local JumpUtil = require("Utils/JumpUtil")
local MajorUtil = require("Utils/MajorUtil")
local TipsUtil = require("Utils/TipsUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local GoldSauserMainPanelMgr = require("Game/GoldSauserMainPanel/GoldSauserMainPanelMgr")
local GoldSauserMainPanelMainVM = require("Game/GoldSauserMainPanel/VM/GoldSauserMainPanelMainVM")
local GoldSauserMainPanelDefine = require("Game/GoldSauserMainPanel/GoldSauserMainPanelDefine")
local GoldSaucerAwardTypeCfg = require("TableCfg/GoldSaucerAwardTypeCfg")
local GoldSaucerAwardShowCfg = require("TableCfg/GoldSaucerAwardShowCfg")
local GoldSaucerAwardBelongCfg = require("TableCfg/GoldSaucerAwardBelongCfg")
local GoodsCfg = require("TableCfg/GoodsCfg")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIAdapterDynamicEntryBox = require("UI/Adapter/UIAdapterDynamicEntryBox")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local GoldSauserAwardSourceType = ProtoRes.GoldSauserAwardSourceType
local GoldSauserAwardBelongType = ProtoRes.GoldSauserAwardBelongType
local AudioType = GoldSauserMainPanelDefine.AudioType
--local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")

local LSTR = _G.LSTR
---@class GoldSauserMainPanelAwardWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose UFButton
---@field BtnGoto CommBtnLView
---@field Comm152Slot CommBackpack152SlotView
---@field CommDropDown CommDropDownListView
---@field CommEmpty CommBackpackEmptyView
---@field CommSingleBox CommSingleBoxView
---@field FCanvasPanel_126 UFCanvasPanel
---@field FDynamicEntryBox_209 UFDynamicEntryBox
---@field IconReceive USizeBox
---@field RichTextBoxItemDescription URichTextBox
---@field RichTextSchedule URichTextBox
---@field ScrollBox_0 UScrollBox
---@field TableViewGatWay UTableView
---@field TableViewTab UTableView
---@field TableViewThing UTableView
---@field TextAchievements UFTextBlock
---@field TextThingName UFTextBlock
---@field TextTitle UFTextBlock
---@field ToggleBtnCollect UToggleButton
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimTableViewTabSelectionChanged UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSauserMainPanelAwardWinView = LuaClass(UIView, true)

function GoldSauserMainPanelAwardWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.BtnGoto = nil
	--self.Comm152Slot = nil
	--self.CommDropDown = nil
	--self.CommEmpty = nil
	--self.CommSingleBox = nil
	--self.FCanvasPanel_126 = nil
	--self.FDynamicEntryBox_209 = nil
	--self.IconReceive = nil
	--self.RichTextBoxItemDescription = nil
	--self.RichTextSchedule = nil
	--self.ScrollBox_0 = nil
	--self.TableViewGatWay = nil
	--self.TableViewTab = nil
	--self.TableViewThing = nil
	--self.TextAchievements = nil
	--self.TextThingName = nil
	--self.TextTitle = nil
	--self.ToggleBtnCollect = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--self.AnimOut = nil
	--self.AnimTableViewTabSelectionChanged = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelAwardWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnGoto)
	self:AddSubView(self.Comm152Slot)
	self:AddSubView(self.CommDropDown)
	self:AddSubView(self.CommEmpty)
	self:AddSubView(self.CommSingleBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelAwardWinView:OnInit()
	self.TableViewTabAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewTab, self.OnTableViewTabSelectChanged, true)
	self.TableViewThingAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewThing, self.OnTableViewThingSelectChanged, true)
	self.TableViewGatWayAdapter = UIAdapterDynamicEntryBox.CreateAdapter(self, self.FDynamicEntryBox_209, self.OnTableViewGatWaySelectChanged)
end

function GoldSauserMainPanelAwardWinView:OnDestroy()

end

function GoldSauserMainPanelAwardWinView:OnShow()
	_G.AchievementMgr:LoadAllAchieveShowData()
	local VM = GoldSauserMainPanelMainVM.AwardWinPanelVM
	if not VM then
		return
	end
	VM:SetTheMainPanelTitle(LSTR(350082))
	self:InitDropDownList()
	self:InitTabItemList(VM)
	
	self.CommEmpty:SetTipsContent(LSTR(350094))
	self.CommSingleBox:SetText(LSTR(350087))
end

function GoldSauserMainPanelAwardWinView:OnHide()
	GoldSauserMainPanelMgr:SaveMarkedReward()
end

function GoldSauserMainPanelAwardWinView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.CommDropDown, self.OnDropDownListSelectionChanged)
	UIUtil.AddOnStateChangedEvent(self, self.CommSingleBox, self.OnSingleBoxSelectionChanged)
	UIUtil.AddOnStateChangedEvent(self, self.ToggleBtnCollect, self.OnToggleBtnCollectSelectionChanged)
	UIUtil.AddOnClickedEvent(self, self.BtnClose, self.OnCloseThePanel)
	UIUtil.AddOnClickedEvent(self, self.BtnGoto, self.OnBtnGotoClick)
	UIUtil.AddOnClickedEvent(self, self.Comm152Slot.BtnCheck, self.OnJumpToPreviewPanel)
	self.Comm152Slot:SetClickButtonCallback(self, self.OnClickShowTips)
end

function GoldSauserMainPanelAwardWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.HideUI, self.OnHideShopUpdate)
end

function GoldSauserMainPanelAwardWinView:OnRegisterBinder()
	local VM = GoldSauserMainPanelMainVM.AwardWinPanelVM
	if not VM then
		return
	end
	self.Binders = {
		{ "Title", UIBinderSetText.New(self, self.TextTitle) },
		{ "TabItemVMs", UIBinderUpdateBindableList.New(self, self.TableViewTabAdapter) },
		{ "ContentItemVMs", UIBinderUpdateBindableList.New(self, self.TableViewThingAdapter) },
		{ "GetWayVMs", UIBinderUpdateBindableList.New(self, self.TableViewGatWayAdapter) },
		{ "TabTitle", UIBinderSetText.New(self, self.TextAchievements) },
		{ "DetailPanelItemName", UIBinderSetText.New(self, self.TextThingName) },
		{ "BtnGotoName", UIBinderSetText.New(self, self.BtnGoto.TextContent) },
		{ "DetailPanelDesc", UIBinderSetText.New(self, self.RichTextBoxItemDescription) },
		{ "CondText", UIBinderSetText.New(self, self.RichTextSchedule) },
		{ "bIconHaveShow", UIBinderSetIsVisible.New(self, self.IconReceive) },
		{ "bShowChildCondList", UIBinderSetIsVisible.New(self, self.TableViewGatWay) },
		{ "bShowEmptyView", UIBinderSetIsVisible.New(self, self.CommEmpty) },
		{ "bShowEmptyView", UIBinderSetIsVisible.New(self, self.FCanvasPanel_126, true) },
		{ "bShowEmptyView", UIBinderSetIsVisible.New(self, self.TextThingName, true) },
		{ "bShowEmptyView", UIBinderSetIsVisible.New(self, self.ScrollBox_0, true) },
		{ "bShowEmptyView", UIBinderSetIsVisible.New(self, self.ToggleBtnCollect, true, true) },
		{ "bShowEmptyView", UIBinderSetIsVisible.New(self, self.BtnGoto, true) },
	}

	self:RegisterBinders(VM, self.Binders)
	self.Comm152Slot:SetParams({Data = VM})
end

function GoldSauserMainPanelAwardWinView:OnHideShopUpdate(ViewID)
    if ViewID ~= UIViewID.ShopMainPanelView then
		return
	end
	local VM = GoldSauserMainPanelMainVM.AwardWinPanelVM
	if not VM then
		return
	end
	local ContentVMs = VM.ContentItemVMs
    if not ContentVMs then
        return
    end

    for Index = 1, ContentVMs:Length() do
		local ContentVM = ContentVMs:Get(Index)
		if ContentVM then
			local Id = ContentVM.ID
			local AwardWinCfg = GoldSaucerAwardShowCfg:FindCfgByKey(Id)
			if AwardWinCfg then
				ContentVM.IconReceivedVisible = GoldSauserMainPanelMgr:GetTheRewardIsOwned(AwardWinCfg)
			end
		end
	end
	ContentVMs:Sort(VM.ContentSortPredicate)
end

function GoldSauserMainPanelAwardWinView:OnClickShowTips()
	local VM = GoldSauserMainPanelMainVM.AwardWinPanelVM
	if not VM then
		return
	end
	local SelectedItemID = VM.SelectedItemID
	if not SelectedItemID then
		return
	end
	local ItemCfg = GoldSaucerAwardShowCfg:FindCfgByKey(SelectedItemID)
	if not ItemCfg then
		return
	end
	local BelongType = ItemCfg.BelongType
	local ItemID = ItemCfg.ItemID
	if BelongType == GoldSauserAwardBelongType.AwardBelongTypeHonor then 
		local Gender = MajorUtil.GetMajorGender()
		local Content = string.format(LSTR(720013), _G.TitleMgr:GetDecoratedTitleText(ItemID, Gender))
		local ItemSize = UIUtil.GetLocalSize(self.Comm152Slot)
		TipsUtil.ShowInfoTips( Content, self.Comm152Slot, _G.UE.FVector2D(-(ItemSize.X/2.0)-20, -(ItemSize.Y/2.0)), _G.UE.FVector2D(0.5, 0.5), false)
	else
		ItemTipsUtil.ShowTipsByResID(ItemID, self.Comm152Slot, {X = 0,Y = 0}, nil)
	end
end

function GoldSauserMainPanelAwardWinView:OnJumpToPreviewPanel()
	local VM = GoldSauserMainPanelMainVM.AwardWinPanelVM
	if not VM then
		return
	end
	local SelectedItemID = VM.SelectedItemID
	if not SelectedItemID then
		return
	end
	local ItemCfg = GoldSaucerAwardShowCfg:FindCfgByKey(SelectedItemID)
	if not ItemCfg then
		return
	end
	_G.PreviewMgr:OpenPreviewView(ItemCfg.ItemID or 0)
end

function GoldSauserMainPanelAwardWinView:OnBtnGotoClick()
	local VM = GoldSauserMainPanelMainVM.AwardWinPanelVM
	if not VM then
		return
	end
	local SelectedItemID = VM.SelectedItemID
	if not SelectedItemID then
		return
	end
	local ItemCfg = GoldSaucerAwardShowCfg:FindCfgByKey(SelectedItemID)
	if not ItemCfg then
		return
	end
	local AwardType = ItemCfg.AwardType
	if AwardType == GoldSauserAwardSourceType.AwardSourceTypeAchievement then
		_G.AchievementMgr:OpenAchieveMainViewByAchieveID(ItemCfg.GroupID)
	elseif AwardType == GoldSauserAwardSourceType.AwardSourceTypeShop then
		local GoodsConfig = GoodsCfg:FindCfgByKey(ItemCfg.GroupID)
		if GoodsConfig then
			local MallID = GoodsConfig.MallID
			_G.ShopMgr:JumpToShopGoods(MallID, ItemCfg.ItemID, 1)
		end
	end
end

function GoldSauserMainPanelAwardWinView:OnTableViewGatWaySelectChanged(_, ItemData)
	if not ItemData then
		return
	end
	local AchievementID = ItemData.AchievementID
	_G.AchievementMgr:OpenAchieveMainViewByAchieveID(AchievementID)
	self:Hide()
end


function GoldSauserMainPanelAwardWinView:OnTableViewThingSelectChanged(_, ItemData)
	local VM = GoldSauserMainPanelMainVM.AwardWinPanelVM
	if not VM then
		return
	end

	local ExtraParams = GoldSauserMainPanelMgr:CreateExplainExtraParams(ItemData)
	VM:SelectTheContentItem(ItemData, ExtraParams)
	local ToggleBtnCollect = self.ToggleBtnCollect
	if ToggleBtnCollect  then
		ToggleBtnCollect:SetChecked(ItemData.bMarked, false)
	end
end


function GoldSauserMainPanelAwardWinView:OnCloseThePanel()
	self:Hide()
	GoldSauserMainPanelMgr:PlayAudio(AudioType.SubView)
end

function GoldSauserMainPanelAwardWinView:OnToggleBtnCollectSelectionChanged(_, State)
	local VM = GoldSauserMainPanelMainVM.AwardWinPanelVM
	if not VM then
		return
	end
	local SelectedID = VM.SelectedItemID
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	if IsChecked then
		GoldSauserMainPanelMgr:ConfirmTheRewardMarked(SelectedID)
	else
		GoldSauserMainPanelMgr:CancelTheRewardMarked(SelectedID)
	end
	VM:ChangeContentItemMarkedState()
end

function GoldSauserMainPanelAwardWinView:OnSingleBoxSelectionChanged(_, State)
	local VM = GoldSauserMainPanelMainVM.AwardWinPanelVM
	if not VM then
		return
	end
	local IsChecked = UIUtil.IsToggleButtonChecked(State)
	local Datas = GoldSauserMainPanelMgr:CreateContentDatasByAwardType(VM.AwardType)
	VM:ChangeShowHaveState(IsChecked, Datas)
end

function GoldSauserMainPanelAwardWinView:OnDropDownListSelectionChanged(_, ItemData, _, IsByClick)
	if not IsByClick then
		return
	end
	local VM = GoldSauserMainPanelMainVM.AwardWinPanelVM
	if not VM then
		return
	end
	local BelongType = ItemData.ID
	local Datas = GoldSauserMainPanelMgr:CreateContentDatasByAwardType(VM.AwardType)
	VM:ChangeSelectBelongType(BelongType, Datas)
end

function GoldSauserMainPanelAwardWinView:OnTableViewTabSelectChanged(_, ItemData)
	if not ItemData then
		return
	end
	
	local VM = GoldSauserMainPanelMainVM.AwardWinPanelVM
	if not VM then
		return
	end

	local AwardType = ItemData.AwardType
	VM:ChangeTabTitle(AwardType)

	local ContentDatas = GoldSauserMainPanelMgr:CreateContentDatasByAwardType(AwardType)
	VM:UpdateTabMainContentByTab(ContentDatas)
	self.TableViewThingAdapter:SetSelectedIndex(1)
	local DropDownWidget = self.CommDropDown
	if not DropDownWidget then
		return
	end
	DropDownWidget:SetSelectedIndex(1)

	local CheckBox = self.CommSingleBox
	if not CheckBox then
		return
	end
	CheckBox:SetChecked(false, false)
end

--- 初始化导航页签列表
function GoldSauserMainPanelAwardWinView:InitTabItemList(VM)
	local AllCfg = GoldSaucerAwardTypeCfg:FindAllCfg("1=1")
	if not AllCfg or not next(AllCfg) then
		return
	end

	VM:CreateTabItemList(AllCfg)
	self.TableViewTabAdapter:SetSelectedIndex(1) -- 默认选中首个页签
end

--- 初始化下拉框列表
function GoldSauserMainPanelAwardWinView:InitDropDownList()
	local AllCfg = GoldSaucerAwardBelongCfg:FindAllCfg("1=1")
	if not AllCfg or not next(AllCfg) then
		return
	end
	local DropDownWidget = self.CommDropDown
	if not DropDownWidget then
		return
	end

	local ListData = {}
	for _, Cfg in ipairs(AllCfg) do
		table.insert(ListData, {
			ID = Cfg.BelongType,
			Name = Cfg.TypeName
		})
	end
	DropDownWidget:UpdateItems(ListData, 1)
end

return GoldSauserMainPanelAwardWinView