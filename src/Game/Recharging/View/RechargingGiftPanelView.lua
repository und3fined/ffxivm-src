---
--- Author: zimuyi
--- DateTime: 2024-01-22 19:35
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local AudioUtil = require("Utils/AudioUtil")

local RechargingDefine = require("Game/Recharging/RechargingDefine")
local RechargingMgr = require("Game/Recharging/RechargingMgr")
local RechargingGiftVM = require("Game/Recharging/VM/RechargingGiftVM")
local RechargingGiftItemVM = require("Game/Recharging/VM/RechargingGiftItemVM")

local LSTR = _G.LSTR

---@class RechargingGiftPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBack CommBackBtnView
---@field BtnLeft UFButton
---@field BtnRight UFButton
---@field TableViewGift UTableView
---@field TextTitle UFTextBlock
---@field AnimRawIn UWidgetAnimation
---@field AnimReturn UWidgetAnimation
---@field AnimTataruIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local RechargingGiftPanelView = LuaClass(UIView, true)

function RechargingGiftPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBack = nil
	--self.BtnLeft = nil
	--self.BtnRight = nil
	--self.TableViewGift = nil
	--self.TextTitle = nil
	--self.AnimRawIn = nil
	--self.AnimReturn = nil
	--self.AnimTataruIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function RechargingGiftPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBack)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function RechargingGiftPanelView:OnInit()
	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewGift)
	self.TableViewAdapter.bLessRenderModeChange = true		-- 减少RT的创建数量
	self.Binders = {
		{ "GiftItemVMList", UIBinderUpdateBindableList.New(self, self.TableViewAdapter) },
		{ "TextTitle", UIBinderSetText.New(self, self.TextTitle) },
	}

	self.bShowCharacter = false
	self.LastScrollOffset = 0
	self.LastItemOffset = 0
	self.bIgnoreScrollOnce = false
end

function RechargingGiftPanelView:OnDestroy()

end

function RechargingGiftPanelView:OnShow()
	self.bShowCharacter = RechargingMgr:ShouldShowShopkeeper()
	RechargingGiftVM.TextTitle = self.bShowCharacter and LSTR(940010) or LSTR(940011)
	if self.bShowCharacter then
		self:PlayAnimation(self.AnimTataruIn)
	else
		self:PlayAnimation(self.AnimRawIn)
	end
	self.TableViewGift:SetSpacingCurveEnabled(self.bShowCharacter)
	local EntrySpacing = self.bShowCharacter and 0 or 115
	self.TableViewGift.EntrySpacing = EntrySpacing
	self:GenerateGiftList()

	self.LastScrollOffset = 0
	self.LastItemOffset = 0
end

function RechargingGiftPanelView:OnHide()
	RechargingMgr:OnGiftPanelHide()
end

function RechargingGiftPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnBack.Button, self.OnBackClicked)
	UIUtil.AddOnItemHideEvent(self, self.TableViewGift, self.OnTableViewItemHide)
	UIUtil.AddOnItemShowEvent(self, self.TableViewGift, self.OnTableViewItemShow)
	UIUtil.AddOnScrolledEvent(self, self.TableViewGift, self.OnTableViewScrolled)
end

function RechargingGiftPanelView:OnRegisterGameEvent()

end

function RechargingGiftPanelView:OnRegisterBinder()
	self:RegisterBinders(RechargingGiftVM, self.Binders)
end

function RechargingGiftPanelView:OnBackClicked()
	self:PlayAnimation(self.AnimReturn)
	self.BtnBack:SetIsEnabled(false) -- 避免被重复点击
	local Delay = self.AnimReturn:GetEndTime()
	local function OnAnimEnd()
		self.BtnBack:SetIsEnabled(true)
		self:Hide()
	end
	self:RegisterTimer(OnAnimEnd, Delay)
	RechargingMgr:OnGiftPanelStartHide(Delay)
end

function RechargingGiftPanelView:OnTableViewItemHide(_, ItemView)
	local ItemIndex = ItemView.ViewModel.GiftID
	if ItemIndex == 1 then
		UIUtil.SetIsVisible(self.BtnLeft, true)
	elseif ItemIndex == self.TableViewAdapter:GetNum() then
		UIUtil.SetIsVisible(self.BtnRight, true)
	end
end

function RechargingGiftPanelView:OnTableViewItemShow(_, Item, ItemView)
	local ItemIndex = ItemView.ViewModel.GiftID
	if ItemIndex == 1 then
		UIUtil.SetIsVisible(self.BtnLeft, false)
	elseif ItemIndex == self.TableViewAdapter:GetNum() then
		UIUtil.SetIsVisible(self.BtnRight, false)
	end
end

function RechargingGiftPanelView:OnTableViewScrolled(TableView, ItemOffset)
	ItemOffset = math.clamp(ItemOffset, 0, 1)
	local ScrollOffset = ItemOffset - self.LastItemOffset
	if self.bIgnoreScrollOnce then
		self.bIgnoreScrollOnce = false
	else
		if ScrollOffset ~= 0 and self.LastScrollOffset * ScrollOffset <= 0 then
			AudioUtil.LoadAndPlayUISound("/Game/WwiseAudio/Events/UI/UI_INGAME/Play_UI_chain_move.Play_UI_chain_move")
		end
	end
	self.LastScrollOffset = ScrollOffset
	self.LastItemOffset = ItemOffset
end

function RechargingGiftPanelView:GenerateGiftList()
	local GiftItemVMList = {}
	local GiftCount = RechargingMgr:GetMaxRewardCount()
	for ID = 1, GiftCount do
		local GiftItemVM = RechargingGiftItemVM.New()
		GiftItemVM:UpdateVM({GiftID = ID})
		table.insert(GiftItemVMList, GiftItemVM)
	end
	self.TableViewAdapter:UpdateAll(GiftItemVMList)

	-- 滚动到第一个未领取的礼物
	local FirstVisibleIndex = #GiftItemVMList
	for Index, GiftItemVM in ipairs(GiftItemVMList) do
		if GiftItemVM.State ~= RechargingDefine.RewardItemState.Got then
			FirstVisibleIndex = Index
			break
		end
	end
	-- 防止过度滑动
	local EntriesNums=4
	if FirstVisibleIndex > GiftCount-EntriesNums+1 then
		FirstVisibleIndex = GiftCount-EntriesNums+1
	end
	self.bIgnoreScrollOnce = FirstVisibleIndex > 1
	self.TableViewAdapter:ScrollToIndex(FirstVisibleIndex)

end

return RechargingGiftPanelView