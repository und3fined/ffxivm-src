local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local culinary_element_type = ProtoRes.culinary_element_type
local CrafterConfig = require("Define/CrafterConfig")
local ProtoCommon = require("Protocol/ProtoCommon")
local EElementItemViewType = CrafterConfig.ProfConfig[ProtoCommon.prof_type.PROF_TYPE_CULINARIAN].EElementItemViewType

---@class CrafterCulinarianElementItemVM : UIViewModel
local CrafterCulinarianElementItemVM = LuaClass(UIViewModel)

function CrafterCulinarianElementItemVM:Ctor()
    self.ElementType = culinary_element_type.CULINARY_ELEMENT_TYPE_NONE
    self.Index = 0
    self.bIsVisible = false
    self.bShine = false
    self.ImgColorIconPath = ""
    self.ElementItemViewType = EElementItemViewType.None
    self:SetNoCheckValueChange("ElementType", true)
end

function CrafterCulinarianElementItemVM:IsEqualVM(Value)
    return self.ElementType == Value.ElementType and
           self.Index == Value.Index and
           self.ElementItemViewType == self.ElementItemViewType
end

function CrafterCulinarianElementItemVM:UpdateVM(Value)
    self.ElementType = Value.ElementType
    self.Index = Value.Index
    self.ElementItemViewType = Value.ElementItemViewType
end

return CrafterCulinarianElementItemVM