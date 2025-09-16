--
-- Author: Carl
-- Date: 2024-1-29 16:57:14
-- Description:追踪外观列表ItemVM

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local FashionEvaluationVMUtils = require("Game/FashionEvaluation/FashionEvaluationVMUtils")

---@class FashionTrackEquipItemVM : UIViewModel
local FashionTrackEquipItemVM = LuaClass(UIViewModel)

function FashionTrackEquipItemVM:Ctor()
    self.CanUnLock = false
    self.Unlock = false
    self.AppearanceIcon = ""
    self.IsOwn = false
    self.AppearanceID = 0
end


function FashionTrackEquipItemVM:IsEqualVM(Value)
    return Value ~= nil and Value.AppearanceID == self.AppearanceID
end

function FashionTrackEquipItemVM:GetKey()
    return self.AppearanceID
end

function FashionTrackEquipItemVM:UpdateVM(Value)
    self.AppearanceID = Value.AppearanceID
    self.IsOwn = Value.IsOwn
    self.CanUnLock = Value.CanUnLock
    self.Unlock = Value.Unlock
    local AppInfo = FashionEvaluationVMUtils.GetAppearanceInfo(self.AppearanceID)
	if AppInfo then
		self.AppearanceIcon = AppInfo.AppIconPath
	end
end

return FashionTrackEquipItemVM