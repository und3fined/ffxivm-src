---
--- Author: Administrator
--- DateTime: 2024-09-30 15:09
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local CollectablesVM = require("Game/Collectables/CollectablesVM")
local LSTR = _G.LSTR

---@class CollectablesTransactionTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelTips UFCanvasPanel
---@field TableViewValue UTableView
---@field TextTitle UFTextBlock
---@field TextValue UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CollectablesTransactionTipsView = LuaClass(UIView, true)

function CollectablesTransactionTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelTips = nil
	--self.TableViewValue = nil
	--self.TextTitle = nil
	--self.TextValue = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CollectablesTransactionTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CollectablesTransactionTipsView:OnInit()
	self.TableViewValueAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewValue, nil, true)

	self.Binders = {
		{ "CurTransactionVMList", UIBinderUpdateBindableList.New(self, self.TableViewValueAdapter)},
	}
end

function CollectablesTransactionTipsView:OnDestroy()

end

function CollectablesTransactionTipsView:OnShow()
	self.TextTitle:SetText(LSTR(770025))
	self.TextValue:SetText(LSTR(770028))
end

function CollectablesTransactionTipsView:OnHide()

end

function CollectablesTransactionTipsView:OnRegisterUIEvent()

end

function CollectablesTransactionTipsView:OnRegisterGameEvent()
end

function CollectablesTransactionTipsView:OnRegisterBinder()
	self:RegisterBinders(CollectablesVM, self.Binders)
end

return CollectablesTransactionTipsView