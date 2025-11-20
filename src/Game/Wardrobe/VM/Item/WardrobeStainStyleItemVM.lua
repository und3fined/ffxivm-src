
--
-- Author: ZhengJanChuan
-- Date: 2025-03-20 16:10
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local DyeColorCfg = require("TableCfg/DyeColorCfg")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")

---@class WardrobeStainStyleItemVM : UIViewModel
local WardrobeStainStyleItemVM = LuaClass(UIViewModel)

---Ctor
function WardrobeStainStyleItemVM:Ctor()
	self.ID = 0
    self.Color = ""
    self.IsSelected = false
    self.IsUnlock = nil
    self.IsMetal = nil
    self.AppID = nil
end

function WardrobeStainStyleItemVM:OnInit()
end

function WardrobeStainStyleItemVM:OnBegin()
end

function WardrobeStainStyleItemVM:OnEnd()
end

function WardrobeStainStyleItemVM:OnShutdown()
end

function WardrobeStainStyleItemVM:UpdateVM(Value)
	self.ID = Value.ID
    self.AppID = Value.AppID
    local IsMetal = false
    local ColorCfg  = DyeColorCfg:FindCfgByKey(self.ID)
    if ColorCfg ~= nil then
        self.Color = WardrobeUtil.Dec2HexColor(ColorCfg.Color)
        IsMetal = ColorCfg.Type == 8
    else
        self.Color = ""
    end

    if Value.IsUnlock ~= nil then
        self.IsUnlock =  Value.IsUnlock
    else
        self.IsUnlock = _G.WardrobeMgr:IsActiveColor(self.AppID, self.ID) 
    end
    self.IsMetal = Value.ID ~= 0 and IsMetal
end

function WardrobeStainStyleItemVM:OnSelectedChange(IsSelected)
    self.IsSelected = IsSelected
end


--要返回当前类
return WardrobeStainStyleItemVM