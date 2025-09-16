--
-- Author: Carl
-- Date: 2024-1-29 16:57:14
-- Description:外观列表ItemVM

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local FashionEvaluationVMUtils = require("Game/FashionEvaluation/FashionEvaluationVMUtils")
local EquipmentMgr = require("Game/Equipment/EquipmentMgr")

---@class FashionEquipItemVM : UIViewModel
local FashionEquipItemVM = LuaClass(UIViewModel)

function FashionEquipItemVM:Ctor()
    self.AppearanceName = ""
    self.AppearanceIcon = ""
    self.AppearanceID = 0
    self.IsEquiped = false
    self.IsOwn = false
    self.IsTracked = false
    self.Part = 0
    self.IsVailid = true
end

function FashionEquipItemVM:IsEqualVM(Value)
    return Value ~= nil and Value.AppearanceID == self.AppearanceID and self.Part == Value.Part
end

function FashionEquipItemVM:UpdateVM(Value)
    self.AppearanceID = tonumber(Value.AppearanceID)
    self.IsEquiped = Value.IsEquiped
    self.IsOwn = Value.IsOwn
    self.IsTracked = Value.IsTracked
    self.Part = Value.Part
    local AppInfo = FashionEvaluationVMUtils.GetAppearanceInfo(self.AppearanceID)
    self.IsVailid = AppInfo ~= nil
	if AppInfo then
		self.AppearanceIcon = AppInfo.AppIconPath
        if string.isnilorempty(self.AppearanceIcon) then
            self.AppearanceIcon = "PaperSprite'/Game/UI/Atlas/FashionEvaluation/Frames/UI_FashionEvaluation_Icon_Clothing_png.UI_FashionEvaluation_Icon_Clothing_png'" -- 默认空图
        end
        self.AppearanceName = AppInfo.AppearanceName
    else
        self.AppearanceIcon = EquipmentMgr:GetPartIcon(self.Part) -- 装备部位底图
        self.AppearanceName = self.AppearanceID
	end
end

return FashionEquipItemVM