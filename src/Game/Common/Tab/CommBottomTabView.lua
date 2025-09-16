---
--- Author: Administrator
--- DateTime: 2024-08-19 19:17
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local WidgetCallback = require("UI/WidgetCallback")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local CommBottomTabItemVM = require("Game/Common/Tab/CommBottomTabItemVM")


---@class CommBottomTabView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgLine UFImage
---@field TableViewTab UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommBottomTabView = LuaClass(UIView, true)

function CommBottomTabView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgLine = nil
	--self.TableViewTab = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommBottomTabView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommBottomTabView:OnInit()
	self.OnSelectionChanged = WidgetCallback.New()
	self.TabList = UIAdapterTableView.CreateAdapter(self, self.TableViewTab, self.OnSelectChanged, true)
end

function CommBottomTabView:OnDestroy()
	self.OnSelectionChanged:Clear()
	self.OnSelectionChanged = nil
end

function CommBottomTabView:OnShow()

end

function CommBottomTabView:OnHide()

end

function CommBottomTabView:OnRegisterUIEvent()

end

function CommBottomTabView:OnRegisterGameEvent()

end

function CommBottomTabView:OnRegisterBinder()

end

function CommBottomTabView:OnSelectChanged(Index, ItemData, ItemView)
	self.OnSelectionChanged:OnTriggered(Index, ItemData, ItemView)
end

function CommBottomTabView:UpdateItems(List)
	local Items = { }
	for i=1 ,#List do
		local ViewModel = CommBottomTabItemVM.New()
		List[i].Index = i
		ViewModel:UpdateVM(List[i])
		table.insert(Items,ViewModel)
	end

	local TabList = self.TabList
	TabList:UpdateAll(Items)
end

function CommBottomTabView:SetSelectedIndex(Index)
	self.TabList:SetSelectedIndex(Index)
end

function CommBottomTabView:CancelSelected()
	self.TabList:CancelSelected()
end

return CommBottomTabView