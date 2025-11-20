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




local NormalColor = "#878075"
local SelectedColor = "#FFF4D0"

local OutlineNormalColor = "#2121217F"
local OutlineSelectedColor = "#8066447F"

local WardrobeStainStyleItemVM = require("Game/Wardrobe/VM/Item/WardrobeStainStyleItemVM")

---@class WardrobeStainTabItemVM : UIViewModel
local WardrobeStainTabItemVM = LuaClass(UIViewModel)

---Ctor
function WardrobeStainTabItemVM:Ctor()
	self.ID = 0
    self.SocketID = 0
    self.IsSelected = false

    self.Name = ""
    self.TabSelectedColor = SelectedColor
    self.TabOutlineSelectedColor = OutlineSelectedColor

    -- 新增逻辑
    self.ColorID = 0 
    self.PreColorID = 0
    self.IsPreStained = nil
    self.PreColorIsMetal = nil
    self.PreColorHex = ""
    self.IsPreColorEmpty = nil
    
    self.ColorHex = ""
    self.ColorIsMetal = nil
    self.IsColorEmpty = nil
end

function WardrobeStainTabItemVM:OnInit()
end

function WardrobeStainTabItemVM:OnBegin()
end

function WardrobeStainTabItemVM:OnEnd()
end

function WardrobeStainTabItemVM:OnShutdown()
end

function WardrobeStainTabItemVM:UpdateVM(Value)
	self.ID = Value.ID
    self.SocketID = Value.SocketID
    self.AppID = Value.AppID
    self.Name = Value.Name
    self:UpdateColor(Value.ColorID)
    self:UpdatePreColor(Value.PreColorID)
    self.IsPreStained = self.ColorID ~= self.PreColorID
end

function WardrobeStainTabItemVM:UpdateColor(ColorID)
    self.ColorID = ColorID
    local ColorCfg  = DyeColorCfg:FindCfgByKey(ColorID)
    if ColorCfg ~= nil then
        self.ColorHex = WardrobeUtil.Dec2HexColor(ColorCfg.Color)
        self.ColorIsMetal = ColorCfg.Type == 8
        self.IsColorEmpty = false
    else
        self.IsColorEmpty = true
        self.ColorIsMetal = false
    end
end

function WardrobeStainTabItemVM:UpdatePreColor(ColorID)
    self.PreColorID = ColorID
    -- self.PreColorVM:UpdateVM({ID = ColorID, AppID = self.AppID })
    self.IsPreStained = self.ColorID ~= self.PreColorID
    local ColorCfg  = DyeColorCfg:FindCfgByKey(ColorID)
    if ColorCfg ~= nil then
        self.PreColorHex = WardrobeUtil.Dec2HexColor(ColorCfg.Color)
        self.PreColorIsMetal = ColorCfg.Type == 8
        self.IsPreColorEmpty = false
    else
        self.IsPreColorEmpty = true
        self.PreColorIsMetal = false
    end
end

function WardrobeStainTabItemVM:OnSelectedChange(IsSelected)
    self.IsSelected = IsSelected
    self.TabSelectedColor = IsSelected and SelectedColor or NormalColor
    self.TabOutlineSelectedColor = IsSelected and OutlineSelectedColor or OutlineNormalColor
end

function WardrobeStainTabItemVM:UpdateName(Name)
    self.Name = Name
end

function WardrobeStainTabItemVM:IsEqualVM(Value)
    return self.ID == Value.ID
end


--要返回当前类
return WardrobeStainTabItemVM