local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local CompanionVM = require ("Game/Companion/VM/CompanionVM")
local RedDotItemVM = require("Game/CommonRedDot/VM/RedDotItemVM")

---@class CompanionListItemVM : UIViewModel
local CompanionListItemVM = LuaClass(UIViewModel)

---Ctor
function CompanionListItemVM:Ctor()
    self.IsEmpty = true
    self.CompanionID = nil
    self.IsMerge = false
    self.Cfg = nil
    self.Icon = nil
    self.IsCalled = false
    self.IsSelected = false
    self.IsFavourite = false
    self.IsNew = false
    self.IsShowReddot = false
	self.ReddotVM = RedDotItemVM.New()
end

--- 设置宠物列表数据
---@param IsMerge bool 是否合并的宠物
---@param Cfg CompanionCfg 宠物表格配置
function CompanionListItemVM:SetListData(IsMerge, Cfg)
    self.IsEmpty = Cfg == nil
    local CompanionID = Cfg and Cfg.ID
    self.CompanionID = CompanionID
    self.IsMerge = IsMerge
    self.Cfg = Cfg
    self.Icon = Cfg and Cfg.Icon or ""
    
    if not IsMerge then
        self.IsCalled = CompanionID == CompanionVM:GetCallingOutCompanion()
        self.IsNew = CompanionVM:IsCompanionNew(CompanionID)
        self.IsFavourite = CompanionVM:IsCompanionFavourite(CompanionID)
    else
        self.IsNew = CompanionVM:IsCompanionNew(self.Cfg.CompanionID[1])
        self.IsFavourite = CompanionVM:IsCompanionFavourite(self.Cfg.CompanionID[1])
        self.IsCalled = false
        for _, ID in ipairs(self.Cfg.CompanionID) do
            if ID == CompanionVM:GetCallingOutCompanion() then
                self.IsCalled = true
                break
            end
        end
    end

    -- 红点控制
    self.IsShowReddot = true
    self.ReddotVM.IsVisible = self.IsNew
end

--- 刷新宠物列表数据
function CompanionListItemVM:UpdateListData()
    self:SetListData(self.IsMerge, self.Cfg)
end

function CompanionListItemVM:OnSelectChanged(IsSelected)
    self.IsSelected = IsSelected
end

--要返回当前类
return CompanionListItemVM