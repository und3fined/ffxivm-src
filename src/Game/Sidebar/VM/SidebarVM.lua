---
--- Author: xingcaicao
--- DateTime: 2023-06-30 14:59:45
--- Description: 侧边栏 ViewModel
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local SidebarItemVM = require("Game/Sidebar/VM/SidebarItemVM")

---侧边栏排序算法
---@param lhs SidebarItemVM @侧边栏Item VM
---@param rhs SidebarItemVM @侧边栏Item VM
local SidebarItemSortFunc = function(lhs, rhs)
    return lhs.Priority < rhs.Priority
end

---@class SidebarVM : UIViewModel
local Class = LuaClass(UIViewModel)

---Ctor
function Class:Ctor()

end
	
function Class:OnInit()
    self:Reset()
end

function Class:OnBegin()
end

function Class:OnEnd()

end

function Class:OnShutdown()
    self:Reset()
end

function Class:Reset()
    self.ItemNum = 0
    self.FirstItemVM = nil
    self.SidebarItemVMList = self:ResetBindableList(self.SidebarItemVMList, SidebarItemVM)
end

function Class:GetItemLength()
    return self.SidebarItemVMList:Length()
end

function Class:AddItem( Type, StartTime, CountDown, TransData, Tips, LoopAnimName )
    if nil == Type then
        return
    end

    local Value = {
        Type        = Type,
        StartTime   = StartTime,
        CountDown   = CountDown,
        TransData   = TransData,
        Tips        = Tips,

        LoopAnimName = LoopAnimName,
    }

    self.SidebarItemVMList:AddByValue(Value)
    self.SidebarItemVMList:Sort(SidebarItemSortFunc)
    self.ItemNum = self:GetItemLength()
    self.FirstItemVM = self:GetFirstItem()
end

function Class:RemoveItem( Type )
    if nil == Type then
        return
    end

    local ItemVMList = self.SidebarItemVMList
    if nil == ItemVMList then
        return
    end

	ItemVMList:RemoveByPredicate( function ( VM )
        return VM.Type == Type
    end)

    self.ItemNum = self:GetItemLength()
    self.FirstItemVM = self:GetFirstItem()
end

function Class:RemoveAllItem( Type )
    if nil == Type then
        return
    end

    local ItemVMList = self.SidebarItemVMList
    if nil == ItemVMList then
        return
    end

	ItemVMList:RemoveItemsByPredicate( function ( VM )
        return VM.Type == Type
    end)

    self.ItemNum = self:GetItemLength()
    self.FirstItemVM = self:GetFirstItem()
end

function Class:RemoveItemByParam( Param, ParamName )
    if nil == Param or nil == ParamName then
        return
    end

	self.SidebarItemVMList:RemoveByPredicate( function ( VM )
        if VM.TransData then
            return VM.TransData[ParamName] == Param
        end
    end)

    self.ItemNum = self:GetItemLength()
    self.FirstItemVM = self:GetFirstItem()
end

function Class:GetItem( Type )
    if nil == Type then
        return
    end

    local ItemVMList = self.SidebarItemVMList
    if nil == ItemVMList then
        return
    end

	return ItemVMList:Find( function ( VM )
        return VM.Type == Type
    end)
end

function Class:GetFirstItem()
    if self:GetItemLength() > 0 then
        return self.SidebarItemVMList:Get(1)
    end
end

return Class