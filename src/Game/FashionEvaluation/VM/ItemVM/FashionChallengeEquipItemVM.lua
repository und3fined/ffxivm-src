--
-- Author: Carl
-- Date: 2024-1-29 16:57:14
-- Description:挑战外观列表\NPC外观列表\历史记录外观列表ItemVM

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local EquipmentMgr = require("Game/Equipment/EquipmentMgr")
local FashionEvaluationVMUtils = require("Game/FashionEvaluation/FashionEvaluationVMUtils")

---@class FashionChallengeEquipItemVM : UIViewModel
local FashionChallengeEquipItemVM = LuaClass(UIViewModel)

function FashionChallengeEquipItemVM:Ctor()
    self.IsMatchTheme = false
    self.IsSuperMatch = false
    self.IsOwn = false
    self.AppearanceName = ""
    self.AppearanceIcon = ""
    self.PartIcon = "" -- 部位图标
    self.IsTracked = false
    self.PartThemeID = 0
    self.PartThemeName = ""
    self.ViewType = 0  --界面类型（历史记录或者结算界面）
    self.EquipIconOpacity = 1
    self.IsEmpty = false
    self.Part = 0
    self.AppearanceID = 0
    self.MatchIconVisible = false
    self.SuperMatchIconVisible = false
    self.NotMatchIconVisible = false
end


function FashionChallengeEquipItemVM:IsEqualVM(Value)
    return Value ~= nil and Value.Key == self.Key
end

function FashionChallengeEquipItemVM:GetKey()
    return self.Key
end

function FashionChallengeEquipItemVM:UpdateVM(Value)
    self.Key = Value.Key
    self.Part = Value.Part
    self.PartThemeID = Value.PartThemeID
    self.AppearanceID = Value.AppearanceID
    self.IsMatchTheme = Value.IsMatchTheme
    self.IsSuperMatch = Value.IsSuperMatch
    self.SuperMatchIconVisible = self.IsSuperMatch
    if self.IsSuperMatch then
        self.MatchIconVisible  = false
        self.NotMatchIconVisible = false
    else
        self.MatchIconVisible  = self.IsMatchTheme
        self.NotMatchIconVisible = self.AppearanceID > 0 and not self.IsMatchTheme
    end
    self.IsOwn = Value.IsOwn
    self.IsTracked = Value.IsTracked
    self.ViewType = Value.ViewType

    local PartThemeInfo = FashionEvaluationVMUtils.GetPartThemeInfo(self.PartThemeID)
    self.PartThemeName = PartThemeInfo and PartThemeInfo.PartThemeName or ""
    
    local EquipInfo = FashionEvaluationVMUtils.GetAppearanceInfo(self.AppearanceID)
	if EquipInfo then
		self.AppearanceIcon = EquipInfo.AppIconPath
        self.AppearanceName = EquipInfo.AppearanceName
        if string.isnilorempty(self.AppearanceIcon) then
            self.AppearanceIcon = "PaperSprite'/Game/UI/Atlas/FashionEvaluation/Frames/UI_FashionEvaluation_Icon_Clothing_png.UI_FashionEvaluation_Icon_Clothing_png'" -- 默认空图
        end
        self.EquipIconOpacity = 1
        self.IsEmpty = false
    else
        self.AppearanceName = FashionEvaluationVMUtils.GetPartName(self.Part)
        self.AppearanceIcon = EquipmentMgr:GetPartIcon(self.Part) -- 装备部位底图
        self.EquipIconOpacity = 0.4
        self.IsEmpty = true
	end
end

return FashionChallengeEquipItemVM