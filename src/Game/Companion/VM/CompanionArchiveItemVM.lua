local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local RedDotDefine = require("Game/CommonRedDot/RedDotDefine")

local CompanionVM = require ("Game/Companion/VM/CompanionVM")

local StoryProtectIcon = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/Ui_Img_LightSlot_NotUnlock_Companion_png.Ui_Img_LightSlot_NotUnlock_Companion_png'"
local RedDotPrefix = "Root/CompanionArchive/"

local RedDotMgr = _G.RedDotMgr

---@class CompanionListItemVM : UIViewModel
local CompanionArchiveItemVM = LuaClass(UIViewModel)

---Ctor
function CompanionArchiveItemVM:Ctor()
    self.CompanionID = nil
    self.IsMerge = false
    self.Cfg = nil
    self.ItemQualityIcon = "PaperSprite'/Game/UI/Atlas/ItemSlot/Frames/Ui_Img_LightSlot_NQ_Blue_152px_png.Ui_Img_LightSlot_NQ_Blue_152px_png'"
    self.Icon = nil
    self.IsNotOwn = true
    self.IsMask = true
    self.IsSelect = nil
    self.RedDotName = nil
    self.RedDotStyle = nil
    self.NumVisible = false
    self.IsWearable = false
end

--- 刷新宠物图鉴列表数据
function CompanionArchiveItemVM:UpdateArchiveData()
    self:SetArchiveData(self.IsMerge, self.Cfg)
end

--- 设置图鉴列表数据
function CompanionArchiveItemVM:SetArchiveData(IsMerge, Cfg)
    self.IsMerge = IsMerge
    self.Cfg = Cfg

    local CompanionID
    if not IsMerge then
        CompanionID = Cfg.ID
    else
        CompanionID = self.Cfg.CompanionID[1]
    end
    self.CompanionID = CompanionID
    local IsNotOwn = not CompanionVM:IsOwnCompanion(CompanionID)
    local IsStoryProtect = Cfg.IsStoryProtect == 1 and IsNotOwn
    self.Icon = IsStoryProtect and StoryProtectIcon or Cfg.Icon
    self.IsNotOwn = IsNotOwn
    self.IsMask = IsNotOwn

    local IsNew = CompanionVM:IsCompanionArchiveNew(CompanionID)
    local RedDotName = RedDotPrefix .. CompanionID

    if not IsNew then
        RedDotMgr:DelRedDotByName(RedDotName)
        self.RedDotName = nil
    else
        RedDotMgr:AddRedDotByName(RedDotName)
        self.RedDotName = RedDotName
        self.RedDotStyle = RedDotDefine.RedDotStyle.SecondStyle
    end
end

function CompanionArchiveItemVM:OnSelectChanged(IsSelect)
    self.IsSelect = IsSelect
end

function CompanionArchiveItemVM:UpdateRedDot()
    local IsNew = false
    local RedDotName = nil
    local CompanionID = nil

    if not self.IsMerge then
        CompanionID = self.CompanionID
    else
        CompanionID = self.Cfg.CompanionID[1]
    end

    IsNew = CompanionVM:IsCompanionArchiveNew(CompanionID)
    RedDotName = RedDotPrefix .. tostring(CompanionID)
    
    if RedDotName then
        if not IsNew then
            RedDotMgr:DelRedDotByName(RedDotName)
        else
            RedDotMgr:AddRedDotByName(RedDotName)
        end
    end
end

--要返回当前类
return CompanionArchiveItemVM