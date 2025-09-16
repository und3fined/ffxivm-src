---
--- Author: Administrator
--- DateTime: 2025-03-17 15:46
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

---@class CardsPrepareRulePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CardsPrepareRuleItem_UIBP CardsPrepareRuleItemView
---@field TableViewList UTableView
---@field TextDescribe UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CardsPrepareRulePanelView = LuaClass(UIView, true)

function CardsPrepareRulePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CardsPrepareRuleItem_UIBP = nil
	--self.TableViewList = nil
	--self.TextDescribe = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CardsPrepareRulePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CardsPrepareRuleItem_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CardsPrepareRulePanelView:OnInit()
	self.TableViewTabAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList, self.OnRuleSelectChanged, true)
	self.Binders = {
        {"AllRuleVMList", UIBinderUpdateBindableList.New(self, self.TableViewTabAdapter)},
	}
end

function CardsPrepareRulePanelView:OnDestroy()

end

function CardsPrepareRulePanelView:OnShow()
	self.TableViewTabAdapter:SetSelectedIndex(1)
end

function CardsPrepareRulePanelView:OnHide()

end

function CardsPrepareRulePanelView:OnRegisterUIEvent()

end

function CardsPrepareRulePanelView:OnRegisterGameEvent()

end

function CardsPrepareRulePanelView:OnRegisterBinder()
	if self.ViewModel then
		self:RegisterBinders(self.ViewModel, self.Binders)
	end
end

function CardsPrepareRulePanelView:SetViewModel(Model)
	self.ViewModel = Model
end

---@type 规则被选中
function CardsPrepareRulePanelView:OnRuleSelectChanged(Index, ItemData, ItemView)
	local DetailedIcon = ItemData.DetailedIcon
    local PictureTitles = ItemData.PictureTitles
	local DetailedDesc = ItemData.DetailedDesc
	local RuleName = ItemData.RuleName
	self.CardsPrepareRuleItem_UIBP:UpdateInfo(DetailedIcon, PictureTitles)
	self.TextTitle:SetText(RuleName)
	self.TextDescribe:SetText(DetailedDesc)
end 

return CardsPrepareRulePanelView