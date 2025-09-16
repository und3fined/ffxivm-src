---
--- Author: sammrli
--- DateTime: 2025-05-29
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class OpsHalloweenClueItemVM : UIViewModel
local OpsHalloweenClueItemVM = LuaClass(UIViewModel)

local TRUE_ICON_PATH = "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main__Quest__Icon_Target_png.UI_Main__Quest__Icon_Target_png'"
local FALSE_ICON_PATH = "PaperSprite'/Game/UI/Atlas/Main/Frames/UI_Main__Quest__Icon_Close_png.UI_Main__Quest__Icon_Close_png'"
local UN_DISCOVERY_TEXT = "? ? ?"

function OpsHalloweenClueItemVM:Ctor()
    self.ClueText = ""
    self.IconPath = nil
    self.IconVisable = false
    self.Order = nil
    self.ID = nil
end

---@param ClueData ClueData
function OpsHalloweenClueItemVM:UpdateVM(ClueData)
    if nil == ClueData then
         return
    end

    if ClueData.Discovery then
        self.ClueText = ClueData.ClueText

        local Truth = ClueData.Truth
        if Truth == nil then
            self.IconVisable = false
        elseif Truth == false then
            self.IconVisable = true
            self.IconPath = FALSE_ICON_PATH
        else
            self.IconVisable = true
            self.IconPath = TRUE_ICON_PATH
        end
    else
        self.ClueText = UN_DISCOVERY_TEXT
        self.IconVisable = false
    end
    self.ID = ClueData.ID
    self.Order = ClueData.Order
end

function OpsHalloweenClueItemVM:AdapterOnGetWidgetIndex()
    return 1
 end

function OpsHalloweenClueItemVM:AdapterGetCategory()
    return 0
end

return OpsHalloweenClueItemVM