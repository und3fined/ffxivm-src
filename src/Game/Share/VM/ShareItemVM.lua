---
--- Author: jususchen
--- DateTime: 2024-12-17 10:24
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class ShareItemVM : UIViewModel
---@field ShareObject ShareObject
---@field Icon string
local ShareItemVM = LuaClass(UIViewModel, nil)

function ShareItemVM:IsEqualVM()
	return false
end

function ShareItemVM:UpdateVM(Value)
    self.ShareObject = Value.ShareObject
    self.Icon = self.ShareObject and self.ShareObject.Icon or ""
end



return ShareItemVM