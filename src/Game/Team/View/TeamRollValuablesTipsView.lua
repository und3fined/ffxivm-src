---
--- Author: Administrator
--- DateTime: 2025-03-06 20:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local TeamRollItemVM = require("Game/Team/VM/TeamRollItemVM")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

---@class TeamRollValuablesTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGoNeed UFButton
---@field CloseBtn CommonCloseBtnView
---@field PanelPopUp UFCanvasPanel
---@field TableViewReward UTableView
---@field TextNeed UFTextBlock
---@field TextTips UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimIn1 UWidgetAnimation
---@field AnimOut1 UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamRollValuablesTipsView = LuaClass(UIView, true)

function TeamRollValuablesTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGoNeed = nil
	--self.CloseBtn = nil
	--self.PanelPopUp = nil
	--self.TableViewReward = nil
	--self.TextNeed = nil
	--self.TextTips = nil
	--self.TextTitle = nil
	--self.AnimIn1 = nil
	--self.AnimOut1 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TeamRollValuablesTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CloseBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamRollValuablesTipsView:OnInit()
	self.TableViewGoodsAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewReward, self.OnItemSelectChanged, true)

	self.Binders = {
		{ "ValuablesList", UIBinderUpdateBindableList.New(self, self.TableViewGoodsAdapter) },
	}
end

function TeamRollValuablesTipsView:OnDestroy()

end

function TeamRollValuablesTipsView:OnShow()
	self.TextTitle:SetText(LSTR(480018))	--- 贵重战利品
	self.TextNeed:SetText(LSTR(480019))	--- 前往需求
	_G.EventMgr:SendEvent(_G.EventID.TeamRollBoxTipsVisibleEvent, false)
end

function TeamRollValuablesTipsView:OnHide()

end

function TeamRollValuablesTipsView:OnItemSelectChanged(Index, ItemData, ItemView)
	_G.EventMgr:SendEvent(_G.EventID.TeamRollHiTipsEvent)
	ItemTipsUtil.ShowTipsByResID(ItemData.ResID, ItemView, {X = 0, Y = 0})
	-- TeamRollItemVM.IsShowTips = false
end

function TeamRollValuablesTipsView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGoNeed, self.OnClickBtnGoNeed)
	self.CloseBtn:SetCallback(self, self.OnClickBtnClose)
end

function TeamRollValuablesTipsView:OnRegisterGameEvent()
end

function TeamRollValuablesTipsView:OnRegisterBinder()
	self:RegisterBinders(_G.TeamRollItemVM, self.Binders)
end

function TeamRollValuablesTipsView:OnClickBtnGoNeed()
	if not UIViewMgr:IsViewVisible(UIViewID.TeamRollPanel) then
		_G.RollMgr.IsPopWindow = false
		_G.RollMgr.TeamPanelVisible = true
        UIViewMgr:ShowView(UIViewID.TeamRollPanel)
    end
	self:Hide()
end

function TeamRollValuablesTipsView:OnClickBtnClose()
	self:Hide()
	if not UIViewMgr:IsViewVisible(UIViewID.TeamRollPanel) then
		_G.EventMgr:SendEvent(_G.EventID.TeamRollBoxTipsVisibleEvent, not TeamRollItemVM.IsAllOperated)
	end
end

return TeamRollValuablesTipsView