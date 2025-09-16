local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local FishVM = require("Game/Fish/FishVM")
local MajorUtil = require("Utils/MajorUtil")

---@class FishAreaPanelVM : UIViewModel
local FishAreaPanelVM = LuaClass(UIViewModel)

function FishAreaPanelVM:Ctor()
    self.UseBaitID = nil
    self.SelectedBaitID = nil
    self.SelectedBaitNum = 0
    self.IsUse = true
    self.IsUnUse = false
end

function FishAreaPanelVM:UpdateBaitInfo(BaitID,Num)
    self.SelectedBaitID = BaitID
    self.SelectedBaitNum = Num
    self.IsUse = (tonumber(Num) == 0) or (self.SelectedBaitID ~= self.UseBaitID)
    self.IsUnUse = (tonumber(Num) ~= 0) and (self.SelectedBaitID == self.UseBaitID)
end

function FishAreaPanelVM:SetUseBaitID(BaitID)
    self.UseBaitID = BaitID
    self.IsUse = self.SelectedBaitID ~= self.UseBaitID
    self.IsUnUse = self.SelectedBaitID == self.UseBaitID
end

function FishAreaPanelVM:IsLimitLevel(BaitID)
    local LimitLevel = FishVM:GetFishBaitLimitLevelByBaitID(BaitID) or 0
    local CurLevel = MajorUtil.GetMajorLevel() or 0
    return (LimitLevel > CurLevel)
end

return FishAreaPanelVM