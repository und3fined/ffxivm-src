---
--- Author: Administrator
--- DateTime: 2025-07-31 16:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

---@class NightGiftRecordList02ItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TableViewSlot UTableView
---@field TextDescribe UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NightGiftRecordList02ItemView = LuaClass(UIView, true)

function NightGiftRecordList02ItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TableViewSlot = nil
	--self.TextDescribe = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NightGiftRecordList02ItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NightGiftRecordList02ItemView:OnInit()
	self.AwardTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewSlot)
	self.AwardTableViewAdapter:SetOnClickedCallback(self.OnAwardItemClicked)
	self.Binders = {
		{ "DescribeName", UIBinderSetText.New(self, self.TextDescribe) },
		{ "TableViewAwardList", UIBinderUpdateBindableList.New(self, self.AwardTableViewAdapter) },
	}
end

function NightGiftRecordList02ItemView:OnDestroy()

end

function NightGiftRecordList02ItemView:OnShow()

end

function NightGiftRecordList02ItemView:OnHide()

end

function NightGiftRecordList02ItemView:OnRegisterUIEvent()

end

function NightGiftRecordList02ItemView:OnRegisterGameEvent()

end

function NightGiftRecordList02ItemView:OnAwardItemClicked(Index, ItemData, ItemView)
	local ItemTipsUtil = require("Utils/ItemTipsUtil")
	ItemTipsUtil.ShowTipsByResID(ItemData.ResID, ItemView)
end

function NightGiftRecordList02ItemView:OnRegisterBinder()
	local Params = self.Params
	if not Params then return end
		
	local ViewModel = Params.Data

	self:RegisterBinders(ViewModel, self.Binders)
end

return NightGiftRecordList02ItemView