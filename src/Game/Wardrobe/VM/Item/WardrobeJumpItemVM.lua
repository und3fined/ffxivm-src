--
-- Author: ZhengJanChuan
-- Date: 2025-02-26 11:26
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")

---@class WardrobeJumpItemVM : UIViewModel
local WardrobeJumpItemVM = LuaClass(UIViewModel)

---Ctor
function WardrobeJumpItemVM:Ctor()
    self.ItemID = nil
    self.Index = 1
    self.AchievementID = nil
    self.AchievementName = ""
    self.AchievementStatus = nil
end

function WardrobeJumpItemVM:OnInit()
end

function WardrobeJumpItemVM:OnBegin()
end

function WardrobeJumpItemVM:OnEnd()
end

function WardrobeJumpItemVM:OnShutdown()
end

function WardrobeJumpItemVM:UpdateVM(Value)
   self.AchievementName = Value.Name
   self.AchievementStatus = _G.AchievementMgr:GetAchievementFinishState(Value.ID) 
   self.AchievementID = Value.ID
   self.ItemID = Value.ItemID
   self.Index =  Value.Index
end


--要返回当前类
return WardrobeJumpItemVM