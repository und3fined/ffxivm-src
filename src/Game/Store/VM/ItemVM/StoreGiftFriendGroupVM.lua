
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local StoreGiftFriendGroupItemVM = require("Game/Store/VM/ItemVM/StoreGiftFriendGroupItemVM")

local LSTR = _G.LSTR
local FLOG_WARNING = _G.FLOG_WARNING

---@class StoreGiftFriendGroupVM: UIViewModel
local StoreGiftFriendGroupVM = LuaClass(UIViewModel)

function StoreGiftFriendGroupVM:Ctor()
	self.ID = nil
    self.Name = ""
    self.Desc = ""

    self.MemberVMList = UIBindableList.New(StoreGiftFriendGroupItemVM)
	self.IsExpanded = false
end

function StoreGiftFriendGroupVM:IsEqualVM(Value)
	return nil ~= Value
end

function StoreGiftFriendGroupVM:UpdateVM(Value)
    if Value == nil then
        FLOG_WARNING("StoreGiftFriendGroupVM:UpdateVM Value is nil")
        return
    end

	self.ID = Value.ID
	self.Desc = Value.Desc

    if Value.MemberVMList ~= nil then
		if Value.MemberVMList.Items ~= nil then
        	self.MemberVMList:UpdateByValues(Value.MemberVMList.Items)
		end
    end

	-- self.Index = Value.Index
end

---@type 是否自动展开
function StoreGiftFriendGroupVM:AdapterOnGetIsAutoExpand()
    return true
end

function StoreGiftFriendGroupVM:AdapterOnExpansionChanged(IsExpanded)
	self.IsExpanded = IsExpanded and self.MemberVMList:Length() > 0
end

function StoreGiftFriendGroupVM:AdapterOnGetWidgetIndex()
    return 0
end

function StoreGiftFriendGroupVM:AdapterOnGetChildren()
    return self.MemberVMList:GetItems()
end

return StoreGiftFriendGroupVM