---
--- Author: chriswang
--- DateTime: 2022-04-22 15:18
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local EventID = require("Define/EventID")
local UIViewID = require("Define/UIViewID")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local SelectMonsterMainPanelVM = require("Game/Interactive/SelectMonster/SelectMonsterMainPanelVM")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

---@class SelectMonsterMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EntranceCanvasPanel UFCanvasPanel
---@field TableViewItems UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SelectMonsterMainPanelView = LuaClass(UIView, true)

function SelectMonsterMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EntranceCanvasPanel = nil
	--self.TableViewItems = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SelectMonsterMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SelectMonsterMainPanelView:OnInit()
	self.TableViewItemList = UIAdapterTableView.CreateAdapter(self, self.TableViewItems)

end

function SelectMonsterMainPanelView:OnDestroy()

end

function SelectMonsterMainPanelView:OnShow()

end

function SelectMonsterMainPanelView:OnHide()

end

function SelectMonsterMainPanelView:OnRegisterUIEvent()
end

function SelectMonsterMainPanelView:OnRegisterGameEvent()

end

function SelectMonsterMainPanelView:OnRegisterBinder()
	local Binders = {
		--回调
		{ "MonsterItemList", UIBinderValueChangedCallback.New(self, nil, self.SetMonsters) },
		{ "TableViewItemsLeft", UIBinderValueChangedCallback.New(self, nil, self.OnTableViewItemsLeft) },
	}

	self:RegisterBinders(SelectMonsterMainPanelVM, Binders)
end

function SelectMonsterMainPanelView:SetMonsters(ItemList)
	self.TableViewItemList:UpdateAll(ItemList)
end

function SelectMonsterMainPanelView:OnTableViewItemsLeft(TableViewLeft)
	if self.TableViewItems and TableViewLeft then
		local offset = UIUtil.CanvasSlotGetOffsets(self.TableViewItems)
		if offset then
			offset.Left = TableViewLeft
			UIUtil.CanvasSlotSetOffsets(self.TableViewItems, offset)
		end
	end
end

return SelectMonsterMainPanelView