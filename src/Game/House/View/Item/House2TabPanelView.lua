--[[
Author: zhangyuhao_ds zhangyuhao@dasheng.tv
Date: 2025-08-14 12:26:11
LastEditors: zhangyuhao_ds zhangyuhao@dasheng.tv
LastEditTime: 2025-08-18 15:38:53
FilePath: \Script\Game\House\View\Item\House2TabPanelView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local CommonMenuView = require("Game/common/Menu/CommMenuView")
local LuaClass = require("Core/LuaClass")

local House2TabPanelVM = require("Game/House/VM/Item/House2TabPanelVM")
local UIAdapterTreeView = require("UI/Adapter/UIAdapterTreeView")
local UIBindableList = require("UI/UIBindableList")
local WidgetCallback = require("UI/WidgetCallback")

---@class House2TabPanelView : CommonMenuView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TreeViewMenu UFTreeView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local House2TabPanelView = LuaClass(CommonMenuView, true)

function House2TabPanelView:OnInit()
    self.OnSelectionChanged = WidgetCallback.New()
    self.AdapterMenu = UIAdapterTreeView.CreateAdapter(self, self.TreeViewMenu, self.OnSelectChanged, true)
    local function GetSelectKey()
		return self:GetLastSelectKey()
	end

    local Param = { ColorNormal = self.ParamColorNormal, ColorSelect = self.ParamColorSelect, GetKeyFun = GetSelectKey}
	self.AdapterMenu:SetParams(Param)
    self.SelectedChildKeyMap = {}
	self.ListData = {}
	self.BindableListChildren = UIBindableList.New(House2TabPanelVM)
	self.IsCacheLastIndex = true   ----自动存储上次选择的子页签
end

return House2TabPanelView