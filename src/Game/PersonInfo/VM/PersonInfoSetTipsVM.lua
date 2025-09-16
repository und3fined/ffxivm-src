---
--- Author: xingcaicao
--- DateTime: 2023-10-16 20:43
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local PersonInfoSetTipsItemVM = require("Game/PersonInfo/VM/PersonInfoSetTipsItemVM")


---@class PersonInfoSetTipsVM : UIViewModel
local PersonInfoSetTipsVM = LuaClass(UIViewModel)

---Ctor
function PersonInfoSetTipsVM:Ctor( )
    self.BtnVMList = self:ResetBindableList(self.BtnVMList, PersonInfoSetTipsItemVM)
end

-- function PersonInfoSetTipsVM:IsEqualVM( Value )
--     return Value ~= nil and self.ID ~= nil and self.ID == Value.ID
-- end

function PersonInfoSetTipsVM:UpdateVM( Value )
    self.BtnVMList:UpdateByValues(Value)
end

return PersonInfoSetTipsVM