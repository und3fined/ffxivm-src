---
--- Author: Administrator
--- DateTime: 2024-05-31 15:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CompanySealMgr = require("Game/CompanySeal/CompanySealMgr")
local CompanySealMainPanelVM = require("Game/CompanySeal/View/CompanySealMainPanelVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetCheckedState = require("Binder/UIBinderSetCheckedState")
local EventID = require("Define/EventID")
local UIBinderSetText = require("Binder/UIBinderSetText")
local TimeUtil = require("Utils/TimeUtil")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local EventMgr = require("Event/EventMgr")
local UIBinderCommBtnUpdateImage = require("Binder/UIBinderCommBtnUpdateImage")
local ProtoCommon = require("Protocol/ProtoCommon")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local EffectUtil = require("Utils/EffectUtil")
local HelpCfg = require("TableCfg/HelpCfg")
local HelpInfoUtil = require("Utils/HelpInfoUtil")
local TipsUtil = require("Utils/TipsUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")


local UIViewID = _G.UIViewID
local LSTR = _G.LSTR
local EToggleButtonState = _G.UE.EToggleButtonState
local FVector2D = _G.UE.FVector2D


---@class CompanySealMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BackpackEmpty CommBackpackEmptyView
---@field Btn CommBtnMView
---@field BtnClose CommonCloseBtnView
---@field CommSingleBox_UIBP CommSingleBoxView
---@field CommTab CommMenuView
---@field CommonBkg01_UIBP CommonBkg01View
---@field HorizontalBoxTime UFHorizontalBox
---@field IconWarning UFImage
---@field ImgArmyBG UFImage
---@field ImgArmyLogo UFImage
---@field InforBtn CommInforBtnView
---@field MoneySlot CommMoneySlotView
---@field PanelHint UFCanvasPanel
---@field PanelShortList UFCanvasPanel
---@field PanelSubmit UFCanvasPanel
---@field PanelTag UFCanvasPanel
---@field PanelTagGold UFCanvasPanel
---@field PanelTagSilver UFCanvasPanel
---@field RicTextTime URichTextBox
---@field RichTextBoxChosen URichTextBox
---@field TableViewLongList UTableView
---@field TableViewPrize UTableView
---@field TableViewShortList UTableView
---@field TabviewSubmititem UTableView
---@field TextHint UFTextBlock
---@field TextPrize UFTextBlock
---@field TextQuantityGold UFTextBlock
---@field TextQuantitySilver UFTextBlock
---@field TextSelectItem UFTextBlock
---@field TextTitle UFTextBlock
---@field WarningBtn UFButton
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CompanySealMainPanelView = LuaClass(UIView, true)

function CompanySealMainPanelView:Ctor() 
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BackpackEmpty = nil
	--self.Btn = nil
	--self.BtnClose = nil
	--self.CommSingleBox_UIBP = nil
	--self.CommTab = nil
	--self.CommonBkg01_UIBP = nil
	--self.HorizontalBoxTime = nil
	--self.IconWarning = nil
	--self.ImgArmyBG = nil
	--self.ImgArmyLogo = nil
	--self.InforBtn = nil
	--self.MoneySlot = nil
	--self.PanelHint = nil
	--self.PanelShortList = nil
	--self.PanelSubmit = nil
	--self.PanelTag = nil
	--self.PanelTagGold = nil
	--self.PanelTagSilver = nil
	--self.RicTextTime = nil
	--self.RichTextBoxChosen = nil
	--self.TableViewLongList = nil
	--self.TableViewPrize = nil
	--self.TableViewShortList = nil
	--self.TabviewSubmititem = nil
	--self.TextHint = nil
	--self.TextPrize = nil
	--self.TextQuantityGold = nil
	--self.TextQuantitySilver = nil
	--self.TextSelectItem = nil
	--self.TextTitle = nil
	--self.WarningBtn = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CompanySealMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BackpackEmpty)
	self:AddSubView(self.Btn)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.CommSingleBox_UIBP)
	self:AddSubView(self.CommTab)
	self:AddSubView(self.CommonBkg01_UIBP)
	self:AddSubView(self.InforBtn)
	self:AddSubView(self.MoneySlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CompanySealMainPanelView:OnInit()
	CompanySealMgr.TaskTabInfo = CompanySealMgr:GetTabInfo()
	self.ViewModel = CompanySealMainPanelVM.New()
	self.TaskTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewLongList, self.OnTaskSelectChanged,true) --军需品补给品栏
	self.SelectTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TabviewSubmititem, self.OnTaskItemSelectChanged,true)--军需品补给品提交道具选择栏
	self.RareListTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewShortList, self.OnRareItemSelectChanged, true, false, true)--稀有品选择栏
	self.RewardTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewPrize, self.RewardOnSelectChanged, true) --奖励栏

	self.Binders = {
		{ "CurTaskList", UIBinderUpdateBindableList.New(self, self.TaskTableViewAdapter) },
		{ "CurItemSelectList", UIBinderUpdateBindableList.New(self, self.SelectTableViewAdapter) },
		{ "CurRareList", UIBinderUpdateBindableList.New(self, self.RareListTableViewAdapter) },
		{ "CurRewardList", UIBinderUpdateBindableList.New(self, self.RewardTableViewAdapter) },
		{ "TextTime", UIBinderSetText.New(self, self.RicTextTime) },
		{ "ToggleButtonState", UIBinderSetCheckedState.New(self, self.CommSingleBox_UIBP.ToggleButton) },
		{ "ConfimBtnVisible", UIBinderSetIsVisible.New(self, self.Btn) },
		{ "ConfimBtnText", UIBinderSetText.New(self, self.Btn.TextContent) },
		{ "TextSub", UIBinderSetText.New(self, self.Btn.TextSubmitted) },
		{ "BtnColor", UIBinderCommBtnUpdateImage.New(self, self.Btn)},
		{ "BtnTextColor", UIBinderSetColorAndOpacityHex.New(self, self.Btn.TextContent)},
		{ "WarningVisible", UIBinderSetIsVisible.New(self, self.WarningBtn, false, true) },	
		{ "ArmyLogo", UIBinderSetBrushFromAssetPath.New(self, self.ImgArmyLogo) },
		{ "ArmyBG", UIBinderSetBrushFromAssetPath.New(self, self.ImgArmyBG) },
		{ "TagSilverVisible", UIBinderSetIsVisible.New(self, self.PanelTagSilver) },
		{ "TagSilverText", UIBinderSetText.New(self, self.TextQuantitySilver) },
		{ "TagGoldVisible", UIBinderSetIsVisible.New(self, self.PanelTagGold) },
		{ "TagGoldText", UIBinderSetText.New(self, self.TextQuantityGold) },
	}

	self.TextSelectItem:SetText(LSTR(1160053))
	self.TextPrize:SetText(LSTR(1160026))
	self.SelectTaskCraftJobID = 0
end

function CompanySealMainPanelView:OnDestroy()

end

function CompanySealMainPanelView:OnShow()
	self.IsFinishing = false
	if self.ViewModel then
		self.ViewModel:UpdateBGIcon()
	end
	self.TextTitle:SetText(LSTR(1160063))
	self.TextHint:SetText(LSTR(1160072))--镶嵌魔晶石或已穿戴的装备不会纳入
	CompanySealMgr:GetBagEquipList()
	CompanySealMgr:SetRareChoesdList()
	UIUtil.SetIsVisible(self.TableViewShortList, false)
	UIUtil.SetIsVisible(self.BackpackEmpty, false)
	UIUtil.SetIsVisible(self.CommSingleBox_UIBP, false)
	UIUtil.SetIsVisible(self.RichTextBoxChosen, false)
	
	local ScoreID = CompanySealMgr:GetScoreInfo()
	self.MoneySlot:UpdateView(ScoreID, false, UIViewID.MarketExchangeWin, true)
	self.CurIndex = 0
	self.CommTab:UpdateItems(CompanySealMgr.TaskTabInfo)
	self.CommTab:CancelSelected()
	self.CurRareItemIndex = 0
	self.ChosedAllBtnState = false
	CompanySealMgr.IsCanSelect = true
	self.CommSingleBox_UIBP.TextContent:SetText(LSTR(1160059))--批量选择

	EffectUtil.SetIsInDialog(false)

	if self.Params and self.Params.GID then
		self.CommTab:SetSelectedIndex(3)
        CompanySealMgr.ExchangeList = {}
		self:SetSelectedRareItem(self.Params.GID)
		UIUtil.SetIsVisible(self.Btn, true)
	elseif self.Params and self.Params.JumpData then        
		--- 兼容跳转表配置Type1
		local JumpIndex = self.Params.JumpData[1] or 1
		self.CommTab:SetSelectedIndex(JumpIndex)
	else
		self.CommTab:SetSelectedIndex(1)
		self.TaskTableViewAdapter:SetSelectedIndex(1)
		self.TaskTableViewAdapter:ScrollToIndex(1)
	end
end

function CompanySealMainPanelView:OnHide()
	if self.TimeID then
		self:UnRegisterTimer(self.TimeID)
		self.TimeID = nil
	end

	self.ViewModel.ToggleButtonState = EToggleButtonState.Unchecked
	CompanySealMgr:ClearRareTaskList()
	self.IsFinishing = false
end

function CompanySealMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.CommTab, self.UpdateTabSelect)
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnClickedSubmitBtn)
	UIUtil.AddOnClickedEvent(self, self.CommSingleBox_UIBP.ToggleButton, self.OnToggleBtnStateChange)
	UIUtil.AddOnClickedEvent(self, self.WarningBtn, self.OnClickIconWarning)
end

function CompanySealMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.CompanySealUpdateTaskInfo, self.UpdateTask)
	self:RegisterGameEvent(EventID.CompanySealUpdateRareChoseList, self.UpdateRareChoseList)
	self:RegisterGameEvent(EventID.CompanySealCancelRareChosed, self.CancelRareChosed)
	self:RegisterGameEvent(EventID.CompanySealUpdateRareView, self.UpdateRareView)
	self:RegisterGameEvent(EventID.BagUpdate, self.OnUpdateBag)
	self:RegisterGameEvent(EventID.CompanySealPlayUpdateBtnState, self.CompanySealPlayUpdateBtnState)
end

function CompanySealMainPanelView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function CompanySealMainPanelView:OnClickedSubmitBtn()
	if self.CurIndex ~= 3 then
		if self.IsFinishing or self.CurChoseTaskState == 6 then
			return
		end
		if self.CurChoseTaskState and self.CurChoseTaskState ~= 4 and not self.IsFinishing and self.CurItemMatch then
			local IsCloseToLimit = self.ViewModel.WarningVisible

			if IsCloseToLimit and not self.ViewModel.IsNeverTips then
				local Params = { bUseNever = true,  NeverMindText = LSTR(1160073)} --下次登陆不再提醒
				local Content = LSTR(1160074)--持有军票已达或即将达到上限，无法获得全额报酬，是否继续提交
				_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(1160075), Content,--提示
				function(_, Info)
					self.ViewModel.IsNeverTips = Info and Info.IsNeverAgain == true or false
					CompanySealMgr:SendMsgFinishPrepareTask(self.IsHQ)
					self.IsFinishing = true
					--延迟可点击
					local function DealyClick()
						self.IsFinishing = false
					end
					self:RegisterTimer(DealyClick, 0.5, 0, 1)
				end
				, nil, LSTR(1160017), LSTR(1160045), Params)--取消 确定

				return
			else
				CompanySealMgr:SendMsgFinishPrepareTask(self.IsHQ)
			end
		else
			if self.CurChoseTaskState == 5 then --职业未解锁
				CompanySealMgr:GetLockProfInfo(self.SelectTaskCraftJobID)
			else
				if not self.CurChoseTaskNQItemID then
					FLOG_ERROR("OnClickedSubmitBtn CurChoseTaskNQItemID = nil")
					print(self.CurChoseTaskNQItemID)
					return
				end
				if self.SelectTaskCraftJobID == ProtoCommon.prof_type.PROF_TYPE_FISHER then
					_G.FishNotesMgr:ShowCanFishLocation(self.CurChoseTaskNQItemID)  --捕鱼人跳转钓鱼笔记
				else
					if self.CurIndex == 1 then --跳转制作笔记
						_G.CraftingLogMgr:OpenCraftingLogWithItemID(self.CurChoseTaskNQItemID)
					elseif self.CurIndex == 2 then  --跳转采集笔记
						_G.GatheringLogMgr:SearchInGatheringLog(self.CurChoseTaskNQItemID)
					end
				end
			end
		end
	else
		if #CompanySealMgr.ExchangeList > 0 then
			self:SubmitAllChosed()
		end
	end
end

function CompanySealMainPanelView:SubmitAllChosed()
	local IsCanSub = CompanySealMgr:GetCurSealIsMax()
	if IsCanSub and CompanySealMgr.IsCanSelect then
		self:SubmitSatisfy()
	else
		local Tips = LSTR(1160008)
		_G.MsgTipsUtil.ShowTips(Tips)
	end
end

function CompanySealMainPanelView:SubmitSatisfy()
	local ScoreID = CompanySealMgr:GetScoreInfo()
	local CurHas = _G.ScoreMgr:GetScoreValueByID(ScoreID)
	local MaxLimit = CompanySealMgr:GetCurRankScoreMax(CompanySealMgr.GrandCompanyID, CompanySealMgr.MilitaryLevel)
	local List = {}
	local NewChoesdList = {}
	for Index, Info in ipairs(CompanySealMgr.RareChoesdList) do
		if Info.ItemID and Info.ItemID ~= 0 then
			CurHas = Info.TargetItemNum + CurHas
			if CurHas >= MaxLimit then
				NewChoesdList[Index] = Info
				table.insert(List, Info.ItemID)
				break
			else
				NewChoesdList[Index] = Info
				table.insert(List, Info.ItemID)
			end
		end
	end

	local IsCloseToLimit = self.ViewModel.WarningVisible
	if IsCloseToLimit and not self.ViewModel.IsNeverTips then
		local Params = { bUseNever = true,  NeverMindText = LSTR(1160073)} --下次登陆不再提醒
		local Content = LSTR(1160076)--"持有军票即将达到上限，无法获得全额报酬，是否继续提交"
		_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(1160075), Content,--提示
		function(_, Info)
			self.ViewModel.IsNeverTips = Info and Info.IsNeverAgain == true or false
			CompanySealMgr.RareChoesdList = NewChoesdList
			CompanySealMgr.RecordRareChoesd = List
			CompanySealMgr:SendMsgExchangeCompanySeal()
		end
		, nil, LSTR(1160017), LSTR(1160045), Params)--取消 确定
		return
	else
		_G.LootMgr:SetDealyState(true)
		CompanySealMgr:SendMsgExchangeCompanySeal()
	end
end

function CompanySealMainPanelView:RewardOnSelectChanged(Index, ItemData, ItemView)
	if ItemData.CurItemID then
		ItemTipsUtil.ShowTipsByResID(ItemData.CurItemID, ItemView)
	end
end

function CompanySealMainPanelView:OnTaskSelectChanged(Index, ItemData, ItemView)
	--ItemData.ItemList[1].IsSelected = true
	CompanySealMgr.CurChoseTaskID = ItemData.CurID
	CompanySealMgr.CurChoseTaskIndex = Index
	self.SelectTaskCraftJobID = ItemData.CraftJobID
	self.CurChoseTaskNQItemID = ItemData.NQItemID
	self.CurChoseTaskState = ItemData.State
	local List = ItemData.ItemList
	self:UpdateSelectList(List)
	self:UpdateRewardsList(List)
	self:UpdateConfimBtnState(ItemData.State, ItemData.IsHQ, ItemData.Times, true)
	local IsHQ = ItemData.HQItemID ~= 0
	if ItemData.State ~= CompanySealMgr:GetSortRuler(6) then
		local NeedNum = ItemData.NeedNum
		local HasNQItemNum = ItemData.HasNQItemNum
		local HasHQItemNum = ItemData.HasHQItemNum
		--有两个可提交物品根据是否满足需求数量来选择选中下标
		if ItemData.HQItemID ~= 0 and ItemData.NQItemID ~= 0 then
			if HasHQItemNum >= NeedNum then
				self.SelectTableViewAdapter:SetSelectedIndex(1)
			elseif HasNQItemNum >= NeedNum then
				self.SelectTableViewAdapter:SetSelectedIndex(2)
			else
				self.SelectTableViewAdapter:SetSelectedIndex(1)
			end
		else
			self.SelectTableViewAdapter:SetSelectedIndex(1)
		end
	else
		self.ViewModel:UpdateRewardNum(self.CurIndex, IsHQ)
	end
end

function CompanySealMainPanelView:OnRareItemSelectChanged(Index, ItemData, ItemView)
	if self.CurIndex ~= 3 or not CompanySealMgr.IsCanSelect then
		return
	end

	if not ItemData.CurID or ItemData.CurID == 0 then
		return
	end

	--FLOG_ERROR("OnRareItemSelectChanged = %d", Index)
	local State =  ItemData.CurChosedState
	if State then
		self.ViewModel:SetAllSlecteBtnState(false)
		ItemData.CurChosedState = false
		ItemData.ImgFocusVisible = false
		for i = 1,#CompanySealMgr.RareChoesdList do
			if CompanySealMgr.RareChoesdList[i].Index == Index then
				CompanySealMgr.RareChoesdList[i].ItemID = nil
				CompanySealMgr.RareChoesdList[i].Index = 0
				CompanySealMgr.RareChoesdList[i].TargetItemNum = 0
				CompanySealMgr.RareChoesdList[i].EquipGID = 0
				table.remove(CompanySealMgr.RecordRareChoesd, i)
				table.remove(CompanySealMgr.ExchangeList, i)
				CompanySealMgr.ChosedRareCarryList[ItemData.EquipGID] = nil
			end
		end
		
		CompanySealMgr:DealNewTable(CompanySealMgr.RareChoesdList)
	else
		if #CompanySealMgr.RecordRareChoesd >= CompanySealMgr.RareChoseLimit then
			local Tips = LSTR(1160060)--"已达最大交纳上限，无法选择更多装备"
			_G.MsgTipsUtil.ShowTips(Tips)
			return
		end
		ItemData.CurChosedState = true
		ItemData.ImgFocusVisible = true
		CompanySealMgr.RareChoesdList[#CompanySealMgr.RecordRareChoesd + 1].ItemID = ItemData.CurID
		CompanySealMgr.RareChoesdList[#CompanySealMgr.RecordRareChoesd + 1].Index = Index
		CompanySealMgr.RareChoesdList[#CompanySealMgr.RecordRareChoesd + 1].TargetItemNum = ItemData.TargetItemNum
		CompanySealMgr.RareChoesdList[#CompanySealMgr.RecordRareChoesd + 1].EquipGID = ItemData.EquipGID
		table.insert(CompanySealMgr.ExchangeList, ItemData.CurID)
        table.insert(CompanySealMgr.RecordRareChoesd, ItemData.CurID)
		--table.insert(CompanySealMgr.ChosedRareCarryList, ItemData.CarryList)
		CompanySealMgr.ChosedRareCarryList[ItemData.EquipGID] = {}
		CompanySealMgr.ChosedRareCarryList[ItemData.EquipGID].CarryList = ItemData.CarryList
		CompanySealMgr.ChosedRareCarryList[ItemData.EquipGID].ResID = ItemData.CurID
	end
	local NumText = string.format("%s：%d/%d", LSTR(1160029), #CompanySealMgr.ExchangeList, CompanySealMgr.RareChoseLimit)
	self.RichTextBoxChosen:SetText(NumText)
	self:UpdateRareChoseList()
end

function CompanySealMainPanelView:SetSelectedRareItem(GID)
	for Index, ItemData in ipairs(self.ViewModel.CurRareList.Items) do
		if ItemData and ItemData.EquipGID == GID then
			self:OnRareItemSelectChanged(Index, ItemData)
			break
		end
	end
end

function CompanySealMainPanelView:OnTaskItemSelectChanged(Index, ItemData, ItemView)
	--FLOG_ERROR("?????OnTaskItemSelectChanged")
	if ItemData.State == CompanySealMgr:GetSortRuler(6) then
		local Tips = LSTR(1160027)
		MsgTipsUtil.ShowTips(Tips)
		return
	end
	if not ItemData.IsRare then
		CompanySealMgr.CurChoseItemIndex = Index
		CompanySealMgr.CurChoseTaskItemID = ItemData.CurItemID
		self.ViewModel:SetCurItemSelectIndex(Index)
		self.ViewModel:UpdateRewardNum(self.CurIndex, ItemData.IsHQ)
		self:UpdateRewardState(ItemData.IsHQ, ItemData.Times)
		self.IsHQ = ItemData.IsHQ
		self.CurItemMatch = ItemData.IsMatch
		self:UpdateConfimBtnState(self.CurChoseTaskState, ItemData.IsHQ, ItemData.Times, ItemData.IsMatch)
	end

	-- UIUtil.SetIsVisible(self.PanelTagSilver, ItemData.TagSilverVisible)
	-- UIUtil.SetIsVisible(self.PanelTagGold, ItemData.TagGoldVisible)
end

function CompanySealMainPanelView:OnToggleBtnStateChange()
	--self.ViewModel:ChosedAllRare()
	local State =  UIUtil.IsToggleButtonChecked(self.ViewModel.ToggleButtonState)

	if State then
		self.ViewModel.ToggleButtonState = EToggleButtonState.Unchecked
		for i = 1, #CompanySealMgr.RareChoesdList do
			self.RareListTableViewAdapter:SetSelectedIndex(CompanySealMgr.RareChoesdList[1].Index)
		end
		self.ChosedAllBtnState = false
	else
		self.ViewModel.ToggleButtonState = EToggleButtonState.Checked
		local ChoesdList = CompanySealMgr.RareChoesdList
		local EquipList = CompanySealMgr.RareTaskList
		self:ChoesedAllRareItem(EquipList, ChoesdList)
		self.ChosedAllBtnState = true
	end
end

function CompanySealMainPanelView:ChoesedAllRareItem(EquipList, RareChoesdList)
	local List = {}
	for _, Item in ipairs(RareChoesdList) do
		if Item.ItemID then
			List[Item.Index] = true
		end
	end

	local CurEquipLen = #EquipList
	local ChosedLimit = math.min(CurEquipLen, CompanySealMgr.RareChoseLimit)
	for Index = 1, ChosedLimit do
		if not List[Index] then
			self.RareListTableViewAdapter:SetSelectedIndex(Index)
		end
	end
end

function CompanySealMainPanelView:UpdateTabSelect(Index)
	--FLOG_ERROR("UpdateTabSelect = %d", Index)
	if Index == self.CurIndex then
		return
	end
	CompanySealMgr.CurChosedTabIndex = Index
	self.CurIndex = Index
	local LongVisible = UIUtil.IsVisible(self.TableViewLongList) 
	local ShortVisible = UIUtil.IsVisible(self.TableViewShortList) 
	local BackpackEmpty = UIUtil.IsVisible(self.BackpackEmpty)
	local PanelSubmit = UIUtil.IsVisible(self.PanelSubmit)
	local SubTableVisible = UIUtil.IsVisible(self.TabviewSubmititem)
	if Index ~= 3 then
		if self.ViewModel.BtnColor ~= 1 then
			self.ViewModel:UpdateBtnColor(true)
		end
		self.TaskTableViewAdapter:SetSelectedIndex(1)
		self.ViewModel:SetRareListSelectIndex(1)
		UIUtil.SetIsVisible(self.RichTextBoxChosen, false)
		UIUtil.SetIsVisible(self.PanelHint, false)
		if not LongVisible then
			UIUtil.SetIsVisible(self.TableViewLongList, true)
			UIUtil.SetIsVisible(self.TableViewShortList, false)
			UIUtil.SetIsVisible(self.CommSingleBox_UIBP, false)
			UIUtil.SetIsVisible(self.PanelTag, true)
			UIUtil.SetIsVisible(self.HorizontalBoxTime, true)
		end

		if BackpackEmpty then
			UIUtil.SetIsVisible(self.BackpackEmpty, false)
		end

		if not PanelSubmit then
			UIUtil.SetIsVisible(self.PanelSubmit, true)
		end

		if not SubTableVisible then
			UIUtil.SetIsVisible(self.TabviewSubmititem, true)
		end

		--注意刷新时间
		local List = CompanySealMgr:GetAllTaskInfo(Index)
		if List ~= nil then
			self:UpdateTask(List)
		end

		if #CompanySealMgr.RecordRareChoesd > 0 then
			CompanySealMgr:ClearInfo()
			self.ViewModel.ToggleButtonState = EToggleButtonState.Unchecked
		end
	else
		if not ShortVisible then
			UIUtil.SetIsVisible(self.TableViewLongList, false)
			UIUtil.SetIsVisible(self.TableViewShortList, true)
			UIUtil.SetIsVisible(self.CommSingleBox_UIBP, true)
			UIUtil.SetIsVisible(self.PanelTag, false)
			UIUtil.SetIsVisible(self.PanelHint, true)
			UIUtil.SetIsVisible(self.HorizontalBoxTime, false)
		end

		if CompanySealMgr.MilitaryLevel >= CompanySealMgr.ExchangeMilitaryRankMin then
			UIUtil.SetIsVisible(self.RichTextBoxChosen, true)
			UIUtil.SetIsVisible(self.TabviewSubmititem, false)
			if not self.ViewModel.ConfimBtnVisible then
				self.ViewModel.ConfimBtnVisible = true
			end
			self:UpdateRareView(false, false)
			self.ViewModel:UpdateBtnColor(false)
			self.ViewModel.ConfimBtnText = LSTR(1160033)
			--self.Btn.TextContent:SetText(LSTR(1160033))
		else
			UIUtil.SetIsVisible(self.RichTextBoxChosen, false)
			UIUtil.SetIsVisible(self.TableViewShortList, false)
			UIUtil.SetIsVisible(self.BackpackEmpty, true)
			UIUtil.SetIsVisible(self.PanelSubmit, false)
			
			local RankName = CompanySealMgr.CompanyRankList[CompanySealMgr.GrandCompanyID][CompanySealMgr.ExchangeMilitaryRankMin].RankName
			local Text = string.format("<span color=\"#828282\">%s</><span color=\"#d1ba8e\">%s</><span color=\"#828282\">%s</>", LSTR(1160011), RankName, LSTR(1160021))
			self.BackpackEmpty.RichTextNone:SetText(Text)
		end
	end
end

function CompanySealMainPanelView:UpdateTask(List)
	self.ViewModel:UpdateTaskListInfo(List)
	local Index = self:GetLastChosedTaskIndex(List) or 1
	self.TaskTableViewAdapter:SetSelectedIndex(Index)
	self.TaskTableViewAdapter:ScrollToIndex(Index)
	if self.TimeID == nil then
		self.TimeID = self:RegisterTimer(self.UpdateTimeText, 0, 1, 0)
	end
end

function CompanySealMainPanelView:UpdateRewardState(IsHQ, Times)
	self.ViewModel:SetTagState(IsHQ, Times)
end

function CompanySealMainPanelView:UpdateSelectList(List)
	for i = 1, #List do
		List[i].RewardList.IsReward = false
	end
	self.ViewModel:UpdateSelectListInfo(List)
end

function CompanySealMainPanelView:UpdateRewardsList(List)
	local Reward = {}
	-- for i = 1, #List do
	-- 	List[i].RewardList.IsReward = true
		
	-- end
	--local Index = CompanySealMgr.CurChoseItemIndex or 1
	for i = 1, 2 do
		Reward[i] = {}
		Reward[i].Index = i
		Reward[i].IsReward = true
		Reward[i].State = List[1].State
	end
	self.ViewModel:UpdateRewardList(Reward)
end

function CompanySealMainPanelView:UpdateTimeText()
	local ServerTime = TimeUtil.GetServerLogicTime() --秒
	local NextRefreh = CompanySealMgr.DataValidTime
	local Surplus = NextRefreh - ServerTime
	if Surplus < 0 then
		if self.LastRequestTime and (ServerTime - self.LastRequestTime < 5) or Surplus < -5 then
			FLOG_WARNING("UpdateTimeText Surplus = %d ", Surplus)
			print(Surplus)
            return  -- 5秒内已请求过，不再重复
        end
		CompanySealMgr.AllTaskList = {}
		CompanySealMgr:SendMsgPrepareTask(self.CurIndex)
		self.LastRequestTime = ServerTime 
	end
	self.ViewModel:UpdateTimeText(Surplus)
end

function CompanySealMainPanelView:UpdateRareChoseList()
	local List = CompanySealMgr.RareChoesdList
	self.ViewModel:UpdateSelectListInfo(List)
	self:UpdateRareExchangedReward(List)
	local NumText = string.format("%s：%d/%d", LSTR(1160029), #CompanySealMgr.ExchangeList, CompanySealMgr.RareChoseLimit)
	self.RichTextBoxChosen:SetText(NumText)
	if #CompanySealMgr.ExchangeList <= 0 then
		self.ViewModel:UpdateBtnColor(false)
	elseif #CompanySealMgr.ExchangeList == CompanySealMgr.RareChoseLimit then
		self.ViewModel.ToggleButtonState = EToggleButtonState.Checked
		self.ChosedAllBtnState = true
	else
		self.ViewModel:UpdateBtnColor(true)
	end
end

function CompanySealMainPanelView:CompanySealPlayUpdateBtnState()
	self.ViewModel:SetAllSlecteBtnState(false)
end

function CompanySealMainPanelView:CancelRareChosed(Index)
	self.RareListTableViewAdapter:SetSelectedIndex(Index)
end

function CompanySealMainPanelView:UpdateRareExchangedReward(List)
	local Data = {}
	local AllNum = 0
	for i = 1, #List do
		if List[i].ItemID ~= nil and List[i].ItemID ~= 0 then
			AllNum = AllNum + List[i].TargetItemNum
		end 
	end
	Data[1] = {}
	Data[1].ItemID = CompanySealMgr.CompanySealID
	Data[1].Num = AllNum
	Data[1].RareReward = true
	self.ViewModel:UpdateRewardList(Data)
end

function CompanySealMainPanelView:UpdateConfimBtnState(State, IsHQ, Times, IsMatch)
	self.ViewModel:UpdateConfimBtnState(State, IsHQ, Times, IsMatch)
end

function CompanySealMainPanelView:UpdateRareView(IsPlayAni, IsUpdateEquiList)
	self.ChosedAllBtnState = false
	if IsPlayAni then
		local List = CompanySealMgr.RareChoesdList
		EventMgr:SendEvent(EventID.CompanySealPlaySubAni, List)
		local function PlaySubAni()
			_G.LootMgr:SetDealyState(false)
			CompanySealMgr.IsCanSelect = true
			self:UpdateRareViewInfo(true)
		end
		self:RegisterTimer(PlaySubAni, 1.2, 0, 1)
	else
		self:UpdateRareViewInfo(IsUpdateEquiList)
	end
end

function CompanySealMainPanelView:UpdateRareViewInfo(IsUpdateEquiList)
	CompanySealMgr:SetRareChoesdList()
	if IsUpdateEquiList then
		CompanySealMgr:GetBagEquipList()
	end
	
	local List = CompanySealMgr:GetRareTaskList()
	if #List > 0 then
		self:SetBackpackEmptyState(false)
		self.ViewModel:UpdateRareList(List)
		self.ViewModel:UpdateSelectListInfo(CompanySealMgr.RareChoesdList)
		self:UpdateRareChoseList()
		self.ViewModel:SetAllSlecteBtnState(false)
	else
		UIUtil.SetIsVisible(self.TableViewShortList, false)
		self:SetBackpackEmptyState(true)
		local Text = LSTR(1160041)
		self.BackpackEmpty:SetTipsContent(Text)
	end
end

function CompanySealMainPanelView:SetBackpackEmptyState(Value)
	UIUtil.SetIsVisible(self.PanelSubmit, not Value)
	UIUtil.SetIsVisible(self.BackpackEmpty, Value)
end

function CompanySealMainPanelView:OnUpdateBag()
	if self.CurIndex ~= 3 then
		--self.ViewModel:UpdateTaskHasNum()
		local List = CompanySealMgr:GetAllTaskInfo(self.CurIndex)
		if List ~= nil then
			self:UpdateTask(List)
		end
	end
end

function CompanySealMainPanelView:OnClickIconWarning()
	local HelpCfgs = HelpCfg:FindAllHelpIDCfg(56003)
	local TipsContent = HelpInfoUtil.ParseText(HelpInfoUtil.ParseContent(HelpCfgs))
	local Alignment = FVector2D(0, 0)
	local Offset = FVector2D(0, 0)
	TipsUtil.ShowInfoTips(TipsContent, self.WarningBtn, Offset, Alignment, false)
end

function CompanySealMainPanelView:GetLastChosedTaskIndex(List)
	for Index, Info in ipairs(List) do
		if Info.ID == CompanySealMgr.CurChoseTaskID then
			return Index
		end
	end
end

return CompanySealMainPanelView