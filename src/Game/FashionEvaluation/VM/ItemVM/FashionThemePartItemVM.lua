--
-- Author: Carl
-- Date: 2024-1-29 16:57:14
-- Description:主题部位列表ItemVM

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local EquipmentMgr = require("Game/Equipment/EquipmentMgr")
local FashionEvaluationVMUtils = require("Game/FashionEvaluation/FashionEvaluationVMUtils")
local FashionEvaluationDefine = require("Game/FashionEvaluation/FashionEvaluationDefine")
---@class FashionThemePartItemVM : UIViewModel
local FashionThemePartItemVM = LuaClass(UIViewModel)

function FashionThemePartItemVM:Ctor()
    self.PartThemeName = ""
    self.AppearanceIcon = ""
    self.PartThemeID = 0
    self.Part = 0
    self.AppearanceID = 0
    self.EquipIconOpacity = 1
end


function FashionThemePartItemVM:IsEqualVM(Value)
    return Value ~= nil and Value.Part == self.Part
end

function FashionThemePartItemVM:GetKey()
    return self.Part
end

function FashionThemePartItemVM:UpdateVM(Value)
    self.Part = Value.Part
    self.PartThemeID = Value.PartThemeID
    self.AppearanceID = Value.AppearanceID
    local ViewType = Value.ViewType
    local PartThemeInfo = FashionEvaluationVMUtils.GetPartThemeInfo(self.PartThemeID)
    if PartThemeInfo then
        self.PartThemeName = PartThemeInfo.PartThemeName
    end

    local EquipInfo = FashionEvaluationVMUtils.GetAppearanceInfo(self.AppearanceID)
	if EquipInfo then
		self.AppearanceIcon = EquipInfo.AppIconPath
        self.EquipIconOpacity = 1
    else
        if ViewType == FashionEvaluationDefine.EFashionView.Fitting then
            self.AppearanceIcon = EquipmentMgr:GetPartIcon(self.Part) -- 装备部位底图
            self.EquipIconOpacity = 0.4
        elseif ViewType == FashionEvaluationDefine.EFashionView.Main then
            self.AppearanceIcon = FashionEvaluationVMUtils.GetPartIcon(self.Part) -- 装备部位底图
            self.EquipIconOpacity = 1
        end
    end

end

return FashionThemePartItemVM