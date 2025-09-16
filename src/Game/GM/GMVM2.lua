---
--- Author: v_zanchang
--- DateTime: 2021-09-28 10:35
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
---@class GMVM2 : UIViewModel
local GMVM2 = LuaClass(UIViewModel)

---Ctor
function GMVM2:Ctor()
    self.Desc = nil
    self.Minimum = nil
    self.Maximum = nil
    self.ID = 0
    self.DefaultValue = 0
    self.Params = nil
    self.IsVisible = true
    self.IsServerCmd = nil
    self.RefreshChangeLevel = nil
    self.OnCmdList = nil
    self.OffCmdList = nil
end

---UpdateVM
function GMVM2:UpdateVM(Value)
    self.Item = Value
    self.Params = Value
    self.Desc = Value.Desc
    self.Minimum = Value.Minimum
    self.Maximum = Value.Maximum
    self.ID = Value.ID
    self.DefaultValue = Value.DefaultValue
end

function GMVM2:AdapterGetCategory()
	return self.WidgetIndex
end

function GMVM2:AdapterOnGetWidgetIndex()
	return self.WidgetIndex
end

function GMVM2:AdapterSetCategory(WidgetIndex)
	if self.Item == nil then return end
    self:UpdateVM(self.Item)

end

return GMVM2