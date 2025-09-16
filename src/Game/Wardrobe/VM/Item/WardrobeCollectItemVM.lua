--
-- Author: ZhengJanChuan
-- Date: 2024-02-27 19:26
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local NormalColor = "#D5D5D5FF"
local UnlockedColor = "#828282FF"

---@class WardrobeCollectItemVM : UIViewModel
local WardrobeCollectItemVM = LuaClass(UIViewModel)

---Ctor
function WardrobeCollectItemVM:Ctor()
    self.IsNormal = false
    self.IsLight = true
    self.JobIcon = nil
    self.SmallJobIcon = nil
    self.JobName = ""
    self.TotalNum = ""
    self.IsUnlock = false
	self.IsUnlockNoActive = false
	self.ActiveVisible = false
end

function WardrobeCollectItemVM:OnInit()
end

function WardrobeCollectItemVM:OnBegin()
end

function WardrobeCollectItemVM:OnEnd()
end

function WardrobeCollectItemVM:OnShutdown()
end

function WardrobeCollectItemVM:UpdateVM(Value)
    self.IsNormal = Value.IsNormal
    self.IsLight = Value.IsLight
    self.JobIcon = Value.JobIcon
    self.JobName = Value.JobName
    self.SmallJobIcon = Value.SmallJobIcon
    self.TotalNum = Value.TotalNum
    self.IsUnlock = Value.IsUnlock or Value.ActiveVisible
    self.ActiveVisible = Value.IsUnlock and Value.ActiveVisible
    self.IsUnlockNoActive = Value.IsUnlock and (not Value.ActiveVisible) or false
    self.UnlockColor =  Value.IsUnlock and NormalColor or UnlockedColor
end


--要返回当前类
return WardrobeCollectItemVM