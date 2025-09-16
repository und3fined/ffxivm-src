local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemVM = require("Game/Item/ItemVM")

local ItemCfg = require("TableCfg/ItemCfg")
local FishCfg = require("TableCfg/FishCfg")

---@field GID number    @服务器生成的物品ID
---@field ResID number    @物品资源ID 对应c_item_cfg中的ResID
---@field Name string @物品名
---@field Icon string @图标资源路径
---@class FishIconItemVM : UIViewModel
local FishIconItemVM = LuaClass(ItemVM)

function FishIconItemVM:Ctor()
    self.IsUnknown = true
    self.IsShowIcon = true
    self.FishLevel = 0
end

function FishIconItemVM:UpdateIconVM(bAutoRelease, FishLevel)
    self:SetAutoRelease(bAutoRelease)
    self.FishLevel = FishLevel
end


function FishIconItemVM:SetLocked()
    self.IsUnknown = true
    self.IsMask = false
    self.IsSelect = false
    self.NumVisible = false
    self.IsShowIcon = false
end

function FishIconItemVM:SetUnLock()
    self.IsUnknown = false
    self.IsSelect = false
    self.NumVisible = true
    self.IsShowIcon = true
    self:UpdateNumMask()
end

function FishIconItemVM:SetMask()
    self.IsUnknown = false
    self.IsMask = true
    self.IsSelect = false
    self.NumVisible = true
    self.IsShowIcon = true
    self.Num = 0
end

function FishIconItemVM:SetFishNum(FishNum)
    self.IsUnknown = false
    self.IsMask = false
    self.IsSelect = false
    self.NumVisible = true
    self.IsShowIcon = true
    self.Num = FishNum
end

function FishIconItemVM:AddFishNum(AddNum)
    self.Num = self.Num + AddNum
    self:UpdateNumMask()
end

function FishIconItemVM:SetSelected(bSelect)
    self.IsSelect = bSelect
end

function FishIconItemVM:SetInUse(bUsed)
    self.IsSelectTick = bUsed
end

function FishIconItemVM:SetAutoRelease(bAuto)
    self.IsFishLoop = bAuto
end

function FishIconItemVM:UpdateNumMask()
    if tonumber(self.Num) > 0 then
        self.IsMask = false
    else
        self.IsMask = true
    end
end

return FishIconItemVM