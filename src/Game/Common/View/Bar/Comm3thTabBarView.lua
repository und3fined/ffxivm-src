---
--- Author: v_zanchang
--- DateTime: 2023-05-16 09:51
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
-- local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local WidgetCallback = require("UI/WidgetCallback")

---@class Comm3thTabBarView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBtnNormal UFImage
---@field TableViewTabs UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local Comm3thTabBarView = LuaClass(UIView, true)

function Comm3thTabBarView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBtnNormal = nil
	--self.TableViewTabs = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function Comm3thTabBarView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function Comm3thTabBarView:OnInit()
	self.OnSelectionChanged = WidgetCallback.New()
	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewTabs, self.OnItemSelectChanged, true)

	self.TableViewAdapter:SetOnClickedCallback(self.OnItemClicked)
	self.TableViewAdapter:SetOnDoubleClickedCallback(self.OnItemDoubleClicked)

	-- local IconPathNormal = "PaperSprite'/Game/UI/Atlas/CraftingLog/Frames/UI_GatheringLog_Icon_Favor_png.UI_GatheringLog_Icon_Favor_png'"
	-- local IconPathSelect = "PaperSprite'/Game/UI/Atlas/CraftingLog/Frames/UI_GatheringLog_Icon_Favor_Select_png.UI_GatheringLog_Icon_Favor_Select_png'"
	-- local ListData2 = { { IconPathNormal = IconPathNormal, IconPathSelect = IconPathSelect }, { IconPathNormal = IconPathNormal, IconPathSelect = IconPathSelect } }
	-- self.TableViewAdapter:UpdateAll(ListData2, 2)
end

function Comm3thTabBarView:OnDestroy()

end

function Comm3thTabBarView:OnShow()

end

function Comm3thTabBarView:OnHide()

end

function Comm3thTabBarView:OnRegisterUIEvent()

end

function Comm3thTabBarView:OnRegisterGameEvent()

end

function Comm3thTabBarView:OnRegisterBinder()

end

function Comm3thTabBarView:OnItemSelectChanged(Index, ItemData, ItemView)
	self.SelectedIndex = Index
	self.OnSelectionChanged:OnTriggered(Index)
end

function Comm3thTabBarView:OnItemClicked(Index, ItemData, ItemView)
	-- print("Comm3thTabBarView:OnItemClicked", Index, ItemData)

end

function Comm3thTabBarView:OnItemDoubleClicked(Index, ItemData, ItemView)
	-- print("Comm3thTabBarView:OnItemDoubleClicked", Index, ItemData)

end

---UpdateItems
---@param ListData table
---@private SelectedIndex number @当前选中索引 从 1 开始
function Comm3thTabBarView:UpdateItems(ListData, SelectedIndex)
	self.TableViewAdapter:UpdateAll(ListData)
	self:SetSelectedIndex(SelectedIndex)
end

function Comm3thTabBarView:SetSelectedIndex(SelectedIndex)
	self.SelectedIndex = SelectedIndex
	self.TableViewAdapter:SetSelectedIndex(SelectedIndex)
end

return Comm3thTabBarView