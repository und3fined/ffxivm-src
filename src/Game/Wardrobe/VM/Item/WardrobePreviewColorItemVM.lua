--
-- Author: ZhengJanChuan
-- Date: 2025-09-02 11:31
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ItemUtil = require("Utils/ItemUtil")
local WardrobeStainStyleItemVM = require("Game/Wardrobe/VM/Item/WardrobeStainStyleItemVM")

---@class WardrobePreviewColorItemVM : UIViewModel
local WardrobePreviewColorItemVM = LuaClass(UIViewModel)

---Ctor
function WardrobePreviewColorItemVM:Ctor()
    self.SectionID = -1
    self.SectionName = ""
    self.ColorVM = WardrobeStainStyleItemVM.New()
    self.PreColorVM = WardrobeStainStyleItemVM.New()
end

function WardrobePreviewColorItemVM:OnInit()
end

function WardrobePreviewColorItemVM:OnBegin()
end

function WardrobePreviewColorItemVM:OnEnd()
end

function WardrobePreviewColorItemVM:OnShutdown()
    self.ColorVM = nil
    self.PreColorVM = nil
end

function WardrobePreviewColorItemVM:UpdateVM(Value)
    self.SectionID = Value.SectionID
    self.SectionName = self.SectionID == -1 and _G.LSTR(1080037) or  string.format(_G.LSTR("%s"), Value.SectionName)
    self.ColorVM:UpdateVM({ID = Value.ColorID, AppID = Value.AppID})
    self.PreColorVM:UpdateVM({ID = Value.PreColorID, AppID = Value.AppID })
end

function WardrobePreviewColorItemVM:IsEqualVM(Value)
    return self.SectionID == Value.SectionID
end


--要返回当前类
return WardrobePreviewColorItemVM