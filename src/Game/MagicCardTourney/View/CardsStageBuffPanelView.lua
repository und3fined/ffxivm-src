---
--- Author: Administrator
--- DateTime: 2023-11-24 19:53
--- Description:阶段效果选择界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local MagicCardTourneyMgr = require("Game/MagicCardTourney/MagicCardTourneyMgr")
local TourneyVM = require("Game/MagicCardTourney/VM/MagicCardTourneyVM")

local UE = _G.UE
local EventID = _G.EventID
local FMath = _G.UE.UMathUtil

---@class CardsStageBuffPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field MaskBG CommonPopUpBGView
---@field TableViewBuff UTableView
---@field TourneyTips CardsTourneyTipsView
---@field AnimIn UWidgetAnimation
---@field AnimSpecialOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsStageBuffPanelView = LuaClass(UIView, true)

function CardsStageBuffPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.MaskBG = nil
	--self.TableViewBuff = nil
	--self.TourneyTips = nil
	--self.AnimIn = nil
	--self.AnimSpecialOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsStageBuffPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.MaskBG)
	self:AddSubView(self.TourneyTips)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsStageBuffPanelView:OnInit()
	self.LocationFishListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewBuff, self.OnEffectSelectChanged, true)
	self.Binders = {
		{"EffectChoiceVMList", UIBinderUpdateBindableList.New(self, self.LocationFishListAdapter)},
	}
end

function CardsStageBuffPanelView:OnDestroy()

end

function CardsStageBuffPanelView:OnShow()
	self.MaxMoveTime = 0.4
	self.MoveTimeCount = 0
	self.LocationFishListAdapter:ClearSelectedItem()
end

function CardsStageBuffPanelView:OnHide()

end

function CardsStageBuffPanelView:OnRegisterUIEvent()

end

function CardsStageBuffPanelView:OnRegisterGameEvent()

end

function CardsStageBuffPanelView:OnRegisterBinder()
	if TourneyVM == nil then
		return
	end
	self:RegisterBinders(TourneyVM, self.Binders)
end

function CardsStageBuffPanelView:OnEffectSelectChanged(Index, ItemData, ItemView)
	if ItemData == nil then
		return
	end
	local EffectIndex = ItemData.EffectIndex
	MagicCardTourneyMgr:OnEffectSelected(EffectIndex)
	self.SelectItemView = ItemView
	self.SelectItemView:PlaySelectedAnimation()

	local Entries = self.TableViewBuff:GetDisplayedEntryWidgets()
	local Length = Entries:Length()
	-- 将未选中的淡出
	for i=1, Length do
	    local Entry = Entries:Get(i)
	    if nil ~= Entry and ItemView ~= Entry then
			Entry:PlayUnSelectFadeOutAnimation()
	    end
	end

	self.UnSelectFadeOutTime = 0
	if Length > 0 then
		self.TargetEntry = Entries:Get(2)
		if self.TargetEntry then
			self.UnSelectFadeOutTime = self.TargetEntry:GetOutAnimEndTime()
			local TragetAbsolute = UIUtil.GetWidgetAbsolutePosition(self.TargetEntry)
			self.TipsAbsolute = UIUtil.AbsoluteToLocal(self.SelectItemView, TragetAbsolute)
		end
		
	end

	if self.MoveTimer then
		self:UnRegisterTimer(self.MoveTimer)
		self.MoveTimer = nil
	end
	self.MoveTimer = self:RegisterTimer(self.OnShowSelectItem, self.UnSelectFadeOutTime, 0.03, -1)
	
end

---@type 展示选中效果动画
function CardsStageBuffPanelView:OnShowSelectItem()
	self.MoveTimeCount = self.MoveTimeCount + 0.05

	if self.SelectItemView ~= self.TargetEntry then
		local Rate = math.clamp(self.MoveTimeCount / self.MaxMoveTime, 0, 1)
		local NewPositionX = FMath.Lerp(0, self.TipsAbsolute.X, Rate)
		self.SelectItemView:SetRenderTranslation(UE.FVector2D(NewPositionX, 0))
	end

	if self.MoveTimeCount >= self.MaxMoveTime then
		self.MoveTimeCount = 0
		self.TargetEntry = nil
		if self.MoveTimer then
			self:UnRegisterTimer(self.MoveTimer)
			self.MoveTimer = nil
		end

		if self.HideSelectTimer then
			self:UnRegisterTimer(self.HideSelectTimer)
			self.HideSelectTimer = nil
		end
		self.HideSelectTimer = self:RegisterTimer(self.OnHideSelectItem, 1)
	end
end

---@type 隐藏选中效果动画
function CardsStageBuffPanelView:OnHideSelectItem()
	if self.SelectItemView == nil then
		return
	end

	self.SelectItemView:PlaySelectFadeOutAnimation()
	self:OnHideSelf()
end

function CardsStageBuffPanelView:OnHideSelf()
	if self.AnimSpecialOut == nil then
		return
	end
	self:PlayAnimation(self.AnimSpecialOut)
	local HideViewDelay = self.AnimSpecialOut:GetEndTime()
	self:RegisterTimer(self.Hide, HideViewDelay)
end

return CardsStageBuffPanelView