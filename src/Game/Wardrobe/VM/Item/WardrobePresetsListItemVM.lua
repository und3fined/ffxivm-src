--
-- Author: ZhengJanChuan
-- Date: 2024-03-04 10:00
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")

---@class WardrobePresetsListItemVM : UIViewModel
local WardrobePresetsListItemVM = LuaClass(UIViewModel)

local FirstIcon = "PaperSprite'/Game/UI/Atlas/Wardrobe/Frames/UI_Wardrobe_Icon_SuitCurrent_png.UI_Wardrobe_Icon_SuitCurrent_png'"
local NoFirstIcon = "PaperSprite'/Game/UI/Atlas/Wardrobe/Frames/UI_Wardrobe_Icon_Presets_png.UI_Wardrobe_Icon_Presets_png'"

local FirstTextColor =  "#D5D5D5FF"
local NoFirstTextColor = "C7C0A7FF"
---Ctor
function WardrobePresetsListItemVM:Ctor()
    self.ID = 0
    self.DetailVisible = false
    self.AddVisible = true
    self.CurSuitCheck = false
    self.IconVisible = false
    self.Num = 1
    self.PresetName = ""
    self.ProfName = ""
    self.ProfVisible = false
    self.ProfColor = nil
    self.IsSelected = nil
    self.IsFirst = nil
    self.PresetIcon = nil
end

function WardrobePresetsListItemVM:OnInit()
end

function WardrobePresetsListItemVM:OnBegin()
end

function WardrobePresetsListItemVM:OnEnd()
end

function WardrobePresetsListItemVM:OnShutdown()
end

function WardrobePresetsListItemVM:OnSelectedChange(IsSelected)
    self.IsSelected = IsSelected
end

function WardrobePresetsListItemVM:UpdateVM(Value)
    self.IconVisible = Value.IconVisible
    self.DetailVisible = Value.DetailVisible
    self.AddVisible = Value.AddVisible
    self.CurSuitCheck = Value.CurSuitCheck
    self.Num = Value.Num
    self.PresetName = Value.PresetName
    self.ProfName = Value.ProfName
    self.ProfColor = Value.ProfColor
    self.ProfVisible = Value.ProfVisible
    self.ID = Value.ID
    self.IsFirst = Value.IsFirst or false
    self.PresetIcon = self.IsFirst and FirstIcon or NoFirstIcon
end

function WardrobePresetsListItemVM:UpdateNameProf(Value)
    self.PresetName = Value.PresetName
    self.ProfName = Value.ProfName
    self.ProfVisible = Value.ProfVisible
    self.ProfColor = Value.ProfColor
end

function WardrobePresetsListItemVM:UpdateCurSuitCheck(Value)
    self.CurSuitCheck = Value
end



--要返回当前类
return WardrobePresetsListItemVM