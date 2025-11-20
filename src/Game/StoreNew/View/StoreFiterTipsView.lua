---
--- Author: zimuyi
--- DateTime: 2025-07-08 15:35
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local StoreMainVM = require("Game/Store/VM/StoreMainVM")

---@class StoreFiterTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TableViewFiter UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StoreFiterTipsView = LuaClass(UIView, true)

function StoreFiterTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TableViewFiter = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StoreFiterTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StoreFiterTipsView:OnInit()
	self.AdapterTabTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewFiter, self.OnTabTableViewSelectChange, false)
end

function StoreFiterTipsView:OnShow()
	local DropListTable = {{Text = LSTR(950095), Index = 1},{Text = LSTR(950096), Index = 2}}
	self.AdapterTabTableView:UpdateAll(DropListTable)
	local SelectedIndex = StoreMainVM.bIsFilter and 2 or 1
	self.AdapterTabTableView:SetSelectedIndex(SelectedIndex or 1)
end

return StoreFiterTipsView