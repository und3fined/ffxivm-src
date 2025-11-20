--[[
Author: zhangyuhao_ds zhangyuhao@dasheng.tv
Date: 2025-08-04 17:47:38
LastEditors: zhangyuhao_ds zhangyuhao@dasheng.tv
LastEditTime: 2025-08-13 17:23:19
FilePath: \Script\Game\House\VM\Item\House2TabPanelVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local MenuParentVM = require("Game/Common/Menu/CommMenuParentVM")
local LuaClass = require("Core/LuaClass")
local House2TabItemVM = require("Game/House/VM/Item/House2TabItemVM")
local UIBindableList = require("UI/UIBindableList")
local House2TabPanelVM = LuaClass(MenuParentVM)

-- self.TextColor = {
--     Selected = "5A4224",
--     Normal = "878075"
-- }

function House2TabPanelVM:Ctor()
    self.Key = nil
	self.Name = ""
	self.ModuleID = nil
	self.IsAutoExpand = false
	self.IsExpanded = false
	self.IsUnLock = false
	self.IsShowTogetherWithChildItem = false
	self.NextClickChildItem = nil
	self.BindableListChildren = UIBindableList.New(House2TabItemVM, self)
    self.ExtraData = nil
end

function House2TabPanelVM:UpdateVM(Value)
    self.Super.UpdateVM(self, Value)
    self.ExtraData = Value.ExtraData
end

return House2TabPanelVM

