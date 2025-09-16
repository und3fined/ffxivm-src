--
-- Author: Carl
-- Date: 2024-1-29 16:57:14
-- Description:追踪外观列表ItemVM

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local FashionEvaluationVMUtils = require("Game/FashionEvaluation/FashionEvaluationVMUtils")

---@class FashionTrackEquipModelItemVM : UIViewModel
local FashionTrackEquipModelItemVM = LuaClass(UIViewModel)

function FashionTrackEquipModelItemVM:Ctor()
    self.EquipID = 0
    self.EquipName = ""
    self.EquipIcon = ""
    self.OwnNumText = ""
    self.IsVisible = true
end


function FashionTrackEquipModelItemVM:IsEqualVM(Value)
    return Value ~= nil and Value.EquipID == self.EquipID
end

function FashionTrackEquipModelItemVM:GetKey()
    return self.EquipID
end

function FashionTrackEquipModelItemVM:UpdateVM(Value)
    self.EquipID = Value.EquipID
    self.OwnNumText = Value.OwnNumText
    local EquipModelInfo = FashionEvaluationVMUtils.GetEquipInfo(self.EquipID)
	if EquipModelInfo then
        self.IsVisible = true
		self.EquipIcon = EquipModelInfo.EquipIconPath
        self.EquipName = EquipModelInfo.EquipName
    else
        self.IsVisible = false
	end
end

return FashionTrackEquipModelItemVM