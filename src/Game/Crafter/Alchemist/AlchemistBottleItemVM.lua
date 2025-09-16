local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class CrafterSkillItemVM : UIViewModel
local CrafterSkillItemVM = LuaClass(UIViewModel)

---Ctor
function CrafterSkillItemVM:Ctor()
    self.SkillID = 0
    self.ButtonIndex = 0

    self.SkillIcon = ""
    self.SkillIconColor = "FFFFFFFF"

    self.LevelText = ""
    self.bCommonMask = false

    self.SetItemNumColorType = 0    -- 1红色 0：够用的颜色
    self.ItemNum = 0
    self.bItemNum = true

    self.bLevelText = false
    self.LevelText = 0

    self.bBtnBottle = false
    self.bImgNumberMask = true
    
    -- self.bNormalCD = false
    -- self.NormalCDPercent = 0
    self.SkillCDText = ""
end

function CrafterSkillItemVM:OnInit()

end

--为了DragVM使用
function CrafterSkillItemVM:OnDragVMPrepare(DragVM)
    self.bItemNum = false
    self.bLevelText = false
    self.bCommonMask = false
    self.bImgNumberMask = false

    self.SkillID = DragVM.SkillID
    self.SkillIcon = DragVM.SkillIcon
end

function CrafterSkillItemVM:OnDragDetected()
    self.SkillIconColor = "FFFFFF33"
end

function CrafterSkillItemVM:OnDragCancelled()
    self.SkillIconColor = "FFFFFFFF"
end

return CrafterSkillItemVM