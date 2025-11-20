--
-- Author: ZhengJanChuan
-- Date: 2024-02-23 15:38
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class CommRewardHairstyleItemVM : UIViewModel
local CommRewardHairstyleItemVM = LuaClass(UIViewModel)

---Ctor
function CommRewardHairstyleItemVM:Ctor()
    self.ID = 0
	self.ItemNameVisible = true
	self.ItemName = ""
	self.HairStyleIcon = nil
	self.IsSelected = false
end

function CommRewardHairstyleItemVM:OnInit()
end

function CommRewardHairstyleItemVM:OnBegin()
end

function CommRewardHairstyleItemVM:OnEnd()
end

function CommRewardHairstyleItemVM:OnShutdown()
end

function CommRewardHairstyleItemVM:OnSelectedChange(IsSelected)
    self.IsSelected = IsSelected
end

function CommRewardHairstyleItemVM:UpdateVM(Value)
    self.ID = Value.ID
	self.ItemNameVisible = Value.ItemNameVisible
	self.ItemName = Value.ItemName
	self.HairStyleIcon = Value.HairStyleIcon
end

function CommRewardHairstyleItemVM:IsEqualVM(Value)
    return self.ID == Value.ID
end


--要返回当前类
return CommRewardHairstyleItemVM