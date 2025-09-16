---
--- Author: Administrator
--- DateTime: 2023-11-13 16:24
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local TipsUtil = require("Utils/TipsUtil")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local BuddyAiCfg = require("TableCfg/BuddyAiCfg")
local GroupBonusStateDataCfg = require("TableCfg/GroupBonusStateDataCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local MajorUtil = require ("Utils/MajorUtil")
local BuddyDefine = require("Game/Buddy/BuddyDefine")
local EventID = require("Define/EventID")
local InteractivedescCfg = require("TableCfg/InteractivedescCfg")

local BagMgr = nil
local BuddyMgr = nil
local LSTR = _G.LSTR

---@class BuddyStatusPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBreakup CommBtnXSView
---@field BtnBuff UFButton
---@field BtnCall01 CommBtnSView
---@field BtnChangeofName UFButton
---@field BtnEditName UFButton
---@field BtnFeed CommBtnSView
---@field BtnLeave UFButton
---@field BtnSupplement CommBtnXSView
---@field BtnUseOrder CommBtnSView
---@field CommSlot CommBackpack74SlotView
---@field CommSlot01 CommBackpack126SlotView
---@field ImgBreakup UFImage
---@field ImgBuff UFImage
---@field ImgLeaveIcon UFImage
---@field PanelCallTime UFCanvasPanel
---@field PanelEdit UFCanvasPanel
---@field PanelFeedOrder UFCanvasPanel
---@field PanelMiddleContent UFCanvasPanel
---@field PanelNoCall UFCanvasPanel
---@field PanelStrength UFCanvasPanel
---@field ProgressBarExp UProgressBar
---@field ProgressBarExp_1 UProgressBar
---@field RichTextCallTime URichTextBox
---@field RichTextStrength URichTextBox
---@field SizeBoxBuff USizeBox
---@field SizeBoxLeave USizeBox
---@field StatusTabs CommHorTabsView
---@field TableViewFeed UTableView
---@field TableViewOrder UTableView
---@field TextCallTime UFTextBlock
---@field TextName UFTextBlock
---@field TextOrder UFTextBlock
---@field TextStrength UFTextBlock
---@field AnimChangeTab UWidgetAnimation
---@field AnimProgressBarExp1 UWidgetAnimation
---@field AnimProgressBarExp1Control UWidgetAnimation
---@field ValueAnimProgressBarExp1Start float
---@field ValueAnimProgressBarExp1End float
---@field CurveAnimProgressBar CurveFloat
---@field ValueAnimProgressBarExp1 float
---@field BtnChangeofName UFButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BuddyStatusPageView = LuaClass(UIView, true)

function BuddyStatusPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBreakup = nil
	--self.BtnBuff = nil
	--self.BtnCall01 = nil
	--self.BtnChangeofName = nil
	--self.BtnEditName = nil
	--self.BtnFeed = nil
	--self.BtnLeave = nil
	--self.BtnSupplement = nil
	--self.BtnUseOrder = nil
	--self.CommSlot = nil
	--self.CommSlot01 = nil
	--self.ImgBreakup = nil
	--self.ImgBuff = nil
	--self.ImgLeaveIcon = nil
	--self.PanelCallTime = nil
	--self.PanelEdit = nil
	--self.PanelFeedOrder = nil
	--self.PanelMiddleContent = nil
	--self.PanelNoCall = nil
	--self.PanelStrength = nil
	--self.ProgressBarExp = nil
	--self.ProgressBarExp_1 = nil
	--self.RichTextCallTime = nil
	--self.RichTextStrength = nil
	--self.SizeBoxBuff = nil
	--self.SizeBoxLeave = nil
	--self.StatusTabs = nil
	--self.TableViewFeed = nil
	--self.TableViewOrder = nil
	--self.TextCallTime = nil
	--self.TextName = nil
	--self.TextOrder = nil
	--self.TextStrength = nil
	--self.AnimChangeTab = nil
	--self.AnimProgressBarExp1 = nil
	--self.AnimProgressBarExp1Control = nil
	--self.ValueAnimProgressBarExp1Start = nil
	--self.ValueAnimProgressBarExp1End = nil
	--self.CurveAnimProgressBar = nil
	--self.ValueAnimProgressBarExp1 = nil
	--self.BtnChangeofName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BuddyStatusPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBreakup)
	self:AddSubView(self.BtnCall01)
	self:AddSubView(self.BtnFeed)
	self:AddSubView(self.BtnSupplement)
	self:AddSubView(self.BtnUseOrder)
	self:AddSubView(self.CommSlot)
	self:AddSubView(self.CommSlot01)
	self:AddSubView(self.StatusTabs)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BuddyStatusPageView:OnInit()
	--喂养
	self.TableViewFeedAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewFeed)
	self.TableViewFeedAdapter:SetOnClickedCallback(self.OnFeedItemClicked)
	--指令
	self.TableViewOrderAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewOrder)
	self.TableViewOrderAdapter:SetOnClickedCallback(self.OnAIItemClicked)

	BagMgr = _G.BagMgr
	BuddyMgr = _G.BuddyMgr

	self.Binders = {
		{ "MiddleContentVisible", UIBinderSetIsVisible.New(self, self.PanelMiddleContent) },
		{ "NoCallVisible", UIBinderSetIsVisible.New(self, self.PanelNoCall) },
		{ "FeedOrderVisible", UIBinderSetIsVisible.New(self, self.PanelFeedOrder) },

		{ "FeedListVisible", UIBinderSetIsVisible.New(self, self.TableViewFeed) },
		{ "AIListVisible", UIBinderSetIsVisible.New(self, self.TableViewOrder) },

		{ "FeedListVMList", UIBinderUpdateBindableList.New(self, self.TableViewFeedAdapter) },
		{ "AIListVMList", UIBinderUpdateBindableList.New(self, self.TableViewOrderAdapter) },
		
		{ "NameText", UIBinderSetText.New(self, self.TextName)},

		{ "HpText", UIBinderSetText.New(self, self.RichTextStrength)},
		{ "CallTimeText", UIBinderSetText.New(self, self.RichTextCallTime)},
		
		{ "HPProgressEnable", UIBinderSetIsEnabled.New(self, self.ProgressBarExp) },
		{ "CallTimeEnable", UIBinderSetIsEnabled.New(self, self.ProgressBarExp_1) },

		{ "HPProgressPercent", UIBinderSetPercent.New(self, self.ProgressBarExp) },
		{ "CallTimePercent", UIBinderSetPercent.New(self, self.ProgressBarExp_1) },

		{ "BuffImg", UIBinderSetBrushFromAssetPath.New(self, self.ImgBuff) },
		{ "BuffImgVisible", UIBinderSetIsVisible.New(self, self.BtnBuff,false, true) },

		{ "CallBtnEnable", UIBinderSetIsEnabled.New(self, self.BtnCall01, false, true)},

		{ "SupplementBtnEnable", UIBinderSetIsEnabled.New(self, self.BtnSupplement, false, true)},
		
		{ "FeedBtnEnable", UIBinderSetIsEnabled.New(self, self.BtnFeed, false, true)},
		{ "UseAIBtnEnable", UIBinderSetIsEnabled.New(self, self.BtnUseOrder, false, true)},

		{ "FeedBtnVisible", UIBinderSetIsVisible.New(self, self.BtnFeed) },
		{ "UseAIVisible", UIBinderSetIsVisible.New(self, self.BtnUseOrder) },

		{ "OnlyOrderVisible", UIBinderSetIsVisible.New(self, self.TextOrder) },
		{ "OrderAndFeedVisible", UIBinderSetIsVisible.New(self, self.StatusTabs) },

		{ "TextColor", UIBinderSetColorAndOpacityHex.New(self, self.TextStrength) },
		{ "TextColor", UIBinderSetColorAndOpacityHex.New(self, self.TextCallTime) },
		
		{ "BuffNodeVisible", UIBinderSetIsVisible.New(self, self.SizeBoxBuff) },
		{ "LeaveNodeVisible", UIBinderSetIsVisible.New(self, self.SizeBoxLeave) },
	}
	
end

function BuddyStatusPageView:OnDestroy()

end

function BuddyStatusPageView:OnShow()
	--self.StatusTabs:SetSelectedIndex(BuddyStatusPageVM.TabType.Feed)
	--self:OnGroupTabsSelectionChanged(BuddyStatusPageVM.TabType.Feed, nil, nil)
end

function BuddyStatusPageView:OnHide()

end

function BuddyStatusPageView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.StatusTabs, self.OnGroupTabsSelectionChanged)
	UIUtil.AddOnClickedEvent(self, self.BtnCall01.Button, self.OnBtnCall) --召唤
	UIUtil.AddOnClickedEvent(self, self.BtnBreakup.Button, self.OnBtnBreakup) --解散
	UIUtil.AddOnClickedEvent(self, self.BtnFeed.Button, self.OnBtnFeed) --喂养
	UIUtil.AddOnClickedEvent(self, self.BtnUseOrder.Button, self.OnBtnUseAI) --使用指令

	UIUtil.AddOnClickedEvent(self, self.BtnBuff, self.OnBtnBuff) 
	UIUtil.AddOnClickedEvent(self, self.BtnLeave, self.OnBtnLeave) 

	UIUtil.AddOnClickedEvent(self, self.BtnSupplement.Button, self.OnBtnSupplement) --补充

	UIUtil.AddOnClickedEvent(self, self.BtnChangeofName, self.OnBtnChangeName)
	self.CommSlot:SetClickButtonCallback(self, self.OnPotherbItemClicked)
	self.CommSlot01:SetClickButtonCallback(self, self.OnPotherbItemClicked)
end

function BuddyStatusPageView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.BuddyQueryInfo, self.OnUpdateBuddyQueryInfo)
	self:RegisterGameEvent(EventID.BuddyUpdateStatus, self.OnUpdateBuddyStatus)
	self:RegisterGameEvent(EventID.BuddyTickTime, self.OnUpdateBuddyTickTime)
	self:RegisterGameEvent(EventID.BagUpdate, self.OnUpdateBuddyQueryInfo)
	self:RegisterGameEvent(EventID.Attr_Change_HP, self.OnGameEventAttrChangeHP)
	self:RegisterGameEvent(EventID.BuddyRenameSuccess, self.OnBuddyRenameSuccess)
end

function BuddyStatusPageView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
	self.CommSlot:SetParams({Data = ViewModel.ItemVM})
	self.CommSlot01:SetParams({Data = ViewModel.ItemVM})

	self.TextStrength:SetText(LSTR(1000045))
	self.TextCallTime:SetText(LSTR(1000046))
	self.BtnSupplement:SetText(LSTR(1000047))
	self.BtnBreakup:SetText(LSTR(1000048))
	self.BtnCall01:SetText(LSTR(1000049))
	self.TextOrder:SetText(LSTR(1000050))
	self.BtnFeed:SetText(LSTR(1000051))
	self.BtnUseOrder:SetText(LSTR(1000052))
end

function BuddyStatusPageView:OnGroupTabsSelectionChanged(Index, ItemData, ItemView)
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	ViewModel:SetTabsSelectionIndex(Index)
	self:PlayAnimation(self.AnimChangeTab)
end

function BuddyStatusPageView:OnFeedItemClicked(Index, ItemData, ItemView)
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	ViewModel:SelectedFeedItem(ItemData.ID)

	ItemTipsUtil.ShowTipsByItem(ItemData.Item, self.TableViewFeed, {X = 30, Y = -200})
end

function BuddyStatusPageView:OnAIItemClicked(Index, ItemData, ItemView)
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	ViewModel:SelectedAIItem(ItemData.ID)

	local ItemViewSize = UIUtil.GetWidgetSize(ItemView)
	local ItemWidgetPosition = UIUtil.GetWidgetPosition(ItemView)
	local TableWidgetPosition = UIUtil.GetWidgetPosition(self.TableViewOrder)

	TipsUtil.ShowSimpleTipsView({Title = ItemData.Value.Name, Content = ItemData.Value.Desc}, ItemView, _G.UE.FVector2D(-ItemViewSize.X - 40 - (ItemWidgetPosition.X - TableWidgetPosition.X) , 0), _G.UE.FVector2D(1, 0), false)
end

function BuddyStatusPageView:OnBtnCall()
	if BagMgr:GetItemNum(BuddyMgr.CallTimeItemID) == 0 then
		_G.MsgTipsUtil.ShowTipsByID(308019)
		return
	end

	local MajorUtil = require("Utils/MajorUtil")
	local ActorUtil = require("Utils/ActorUtil")
	if ActorUtil.IsDeadState(MajorUtil.GetMajorEntityID()) then
		_G.MsgTipsUtil.ShowTipsByID(308012)
		return
	end

	BuddyMgr:OnCallBuddy()
	
end

function BuddyStatusPageView:OnPotherbItemClicked(ItemView)
	ItemTipsUtil.ShowTipsByResID(BuddyMgr.CallTimeItemID, ItemView)
	
end

function BuddyStatusPageView:OnBtnSupplement()
	if BagMgr:GetItemNum(BuddyMgr.CallTimeItemID) == 0 then
		_G.MsgTipsUtil.ShowTipsByID(308019)
		return
	end

	if BuddyMgr:CanBuddyActivity() == false then
		_G.MsgTipsUtil.ShowTipsByID(308020)
		return
	end

	if MajorUtil.IsMajorDead() then
		_G.MsgTipsUtil.ShowTipsByID(308012)
		return
	end

	local GID = BagMgr:GetItemGIDByResID(BuddyMgr.CallTimeItemID)
	local Item = BagMgr:GetItemDataByGID(GID)
	if Item == nil then
		return
	end
	local Cfg = ItemCfg:FindCfgByKey(Item.ResID)
	if Cfg == nil then
		return
	end
	local CfgItem = InteractivedescCfg:FindCfgByKey(Cfg.InteractiveID)
	if CfgItem then
		self.TempUseInteractiveItemParam = {}
		self.TempUseInteractiveItemParam.SingStateID = CfgItem.SingStateID[1]
		self.TempUseInteractiveItemParam.Item = Item
		self:RegisterGameEvent(EventID.MajorSingBarOver, self.OnMajorSingBarOverHandleOnce)
		_G.InteractiveMgr:SendInteractiveStartReqWithoutObj(Cfg.InteractiveID)
	end
end

function BuddyStatusPageView:OnMajorSingBarOverHandleOnce(EntityID, IsBreak, SingStateID)
	if EntityID == MajorUtil.GetMajorEntityID() then
		if self then
			local Param = self.TempUseInteractiveItemParam or {}
			if Param.SingStateID == SingStateID then
				if not IsBreak then
					BagMgr:ItemUseFunction(Param.Item)
					if self.Params and self.Params.Data then
						local ViewModel = self.Params.Data
						ViewModel.Supple = true
						self.ValueAnimProgressBarExp1Start = math.clamp(ViewModel.CallTimePercent, 0, 1)
						self.ValueAnimProgressBarExp1End = math.clamp(ViewModel.CallTimePercent + 0.5, 0, 1)
						self:PlayAnimProgressBarExp(self.ValueAnimProgressBarExp1End)
						ViewModel.CallTimePercent = self.ValueAnimProgressBarExp1End
					end
				end
			end
			self.TempUseInteractiveItemParam = nil
			self:UnRegisterGameEvent(EventID.MajorSingBarOver, self.OnMajorSingBarOverHandleOnce)
		end
	end
end

function BuddyStatusPageView:OnBtnBreakup()
	if MajorUtil.IsMajorDead() then
		_G.MsgTipsUtil.ShowTipsByID(308012)
	else
		BuddyMgr:SendBuddyCallMessage(false)
	end
end

function BuddyStatusPageView:OnBtnFeed()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	if ViewModel.CurFeedID == nil then
		_G.MsgTipsUtil.ShowTipsByID(308021)
		return
	end

	if BagMgr:GetItemNum(ViewModel.CurFeedID) == 0 then
		_G.MsgTipsUtil.ShowTipsByID(308022)
		return
	end

	if BuddyMgr:CanBuddyActivity() == false then
		_G.MsgTipsUtil.ShowTipsByID(308023)
		return
	end

	if ViewModel.CurFeedID == self.BreakThroughItemID then
		if BuddyMgr:CanBreakThrough() == false then
			_G.MsgTipsUtil.ShowTipsByID(308024)
			return
		end

		if BuddyMgr:IsMaxLevel() then
			_G.MsgTipsUtil.ShowTipsByID(308025)
			return
		end
	end

	local GID = BagMgr:GetItemGIDByResID(ViewModel.CurFeedID)
	if GID then
		BagMgr:UseItem(GID)
	end
end

function BuddyStatusPageView:OnBtnUseAI()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	if ViewModel.CurAIID == nil then
		_G.MsgTipsUtil.ShowTipsByID(308026)
		return
	end

	if MajorUtil.IsMajorDead() then
		_G.MsgTipsUtil.ShowTipsByID(308012)
		return
	end

	local AiCfg = BuddyAiCfg:FindCfgByKey(ViewModel.CurAIID)
	if AiCfg then
		if AiCfg.Strategy == BuddyMgr:GetBuddyUseAI() then
			_G.MsgTipsUtil.ShowTipsByID(308027)
			return
		end

		if BuddyMgr:CanBuddyActivity() == false then
			_G.MsgTipsUtil.ShowTipsByID(308028)
			return
		end

		BuddyMgr:SendBuddyUseAIMessage(AiCfg.Strategy)
	end

end

function BuddyStatusPageView:OnBtnBuff()
	local State = BuddyMgr:GetBuddyBuff()
	if State == nil then
		return
	end

	local StateShowCfg = GroupBonusStateDataCfg:FindCfgByKey(State)
    if StateShowCfg ~= nil then
		local ItemViewSize = UIUtil.GetWidgetSize(self.BtnBuff)
		TipsUtil.ShowSimpleTipsView({Title = StateShowCfg.EffectName, Content = StateShowCfg.Desc}, self.BtnBuff, _G.UE.FVector2D(0, ItemViewSize.Y), _G.UE.FVector2D(1, 0), false)
    end

end

function BuddyStatusPageView:OnBtnLeave()
	local ItemViewSize = UIUtil.GetWidgetSize(self.BtnLeave)
	TipsUtil.ShowSimpleTipsView({Title = LSTR(1000039), Content = LSTR(1000040)}, self.BtnLeave, _G.UE.FVector2D(0, ItemViewSize.Y), _G.UE.FVector2D(1, 0), false)

end

function BuddyStatusPageView:OnUpdateBuddyQueryInfo()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	local CurFeedID = ViewModel.CurFeedID
	local CurAIID = ViewModel.CurAIID

	ViewModel:UpdateVM()
	ViewModel:SetTabsSelectionIndex(ViewModel.TabIndex, CurFeedID, CurAIID)
end

function BuddyStatusPageView:OnGameEventAttrChangeHP()
	if nil == self then
		return
	end

	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end
	ViewModel:UpdateBuddyHp()
end

function BuddyStatusPageView:OnUpdateBuddyStatus()
	if nil == self then
		return
	end
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	ViewModel:UpdateBuddyState()
end

function BuddyStatusPageView:OnUpdateBuddyTickTime()
	if nil == self then
		return
	end

	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	ViewModel:UpdateBuddyTime()
	
end


function BuddyStatusPageView:OnBtnChangeName()
	if MajorUtil.IsMajorDead() then
		_G.MsgTipsUtil.ShowTipsByID(308012)
		return
	end
	_G.BuddyMgr:OpenRenamePanel()
	self.OnUpdateBuddyStatus()
end

function BuddyStatusPageView:OnBuddyRenameSuccess()
	if nil == self then
		return
	end
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	ViewModel:UpdateVM()
end
return BuddyStatusPageView