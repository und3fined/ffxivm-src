
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local LSTR = _G.LSTR
local FLOG_WARNING = _G.FLOG_WARNING

---@class StoreGiftFriendItemVM: UIViewModel
local StoreGiftFriendItemVM = LuaClass(UIViewModel)

function StoreGiftFriendItemVM:Ctor()
	self.Index = 0

	self.ProfID = nil
	self.RoleID = 0
	self.Level = 0
    self.Desc = ""
	self.IsExpanded = false
end

function StoreGiftFriendItemVM:IsEqualVM(Value)
	return nil ~= Value and Value.RoleID == self.RoleID
end

function StoreGiftFriendItemVM:UpdateVM(Value)
    if Value == nil then
        FLOG_WARNING("StoreGiftFriendItemVM:InitVM Value is nil")
        return
    end


	self.Name = Value.Name
	self.ProfID = Value.ProfID
	self.RoleID = Value.RoleID
	self.Level = Value.Level
	self.State = Value.State
	self.OnlineStatusIcon = Value.OnlineStatusIcon


	self.Index = Value.Index
end

return StoreGiftFriendItemVM