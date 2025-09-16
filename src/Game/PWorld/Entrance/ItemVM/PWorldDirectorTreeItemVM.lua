--[[
Author: jususchen jususchen@tencent.com
Date: 2024-07-29 16:07:31
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-07-30 11:33:54
FilePath: \Script\Game\PWorld\Entrance\ItemVM\PWorldDirectorTreeItemVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local UIBindableList = require("UI/UIBindableList")
local UIViewModel = require("UI/UIViewModel")
local PWorldDirectorListItemVM = require("Game/PWorld/Entrance/ItemVM/PWorldDirectorListItemVM")

--- @class PWorldDirectorListVM : UIViewModel
--- @field PWorldItemVMs UIBindableList
local PWorldDirectorTreeItemVM = LuaClass(UIViewModel)

function PWorldDirectorTreeItemVM:Ctor()
    self.Name = ""
    self.PWorldItemVMs = UIBindableList.New(PWorldDirectorListItemVM)
end

function PWorldDirectorTreeItemVM:IsEqualVM(_)
    return false
end

function PWorldDirectorTreeItemVM:UpdateVM(Value)
    self.Name = Value.Name
    local ItemDataList = {}
    for _, ID in ipairs(Value.IDList) do
        table.insert(ItemDataList, {ID=ID, bPreConditonFinished=Value.bPreConditonFinished})
    end
    self.PWorldItemVMs:UpdateByValues(ItemDataList)
end

function PWorldDirectorTreeItemVM:AdapterOnGetIsCanExpand()
    return true
end

function PWorldDirectorTreeItemVM:AdapterOnGetCanBeSelected()
	return true
end

function PWorldDirectorTreeItemVM:AdapterOnGetWidgetIndex()
	return 0
end

function PWorldDirectorTreeItemVM:AdapterOnGetChildren()
	return self.PWorldItemVMs:GetItems()
end

return PWorldDirectorTreeItemVM;