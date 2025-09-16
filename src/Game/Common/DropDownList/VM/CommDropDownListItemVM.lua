--@author Star
--@date 2023-12-25

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class CommDropDownListItemVM : UIViewModel
---@field IconPath string @IconPath
---@field RightIconPath string @IconPath
---@field Name string @名称
---@field IsNew boolean @是否显示 新 文本
---@field TextNewStr string@TextNew string
---@field IsItemVM boolean @规避fate报错
---@field IsShowIcon boolean @是否显示Icon
---@field IsShowRightIcon boolean @是否显示RightIcon
---@field IsShowRightPanel boolean @是否显示 IconPanel
local CommDropDownListItemVM = LuaClass(UIViewModel)

function CommDropDownListItemVM:Ctor()
    self.ID = nil
    self.Name = nil
    self.IconPath = nil
    self.RightIconPath = nil
    self.IsNew = nil
    self.TextNewStr = nil
    self.ItemData = nil
    self.IsSelectedFunc = nil
    self.IsItemVM = nil
    self.IsShowIcon = nil
    self.IsShowRightIcon = nil
    self.IsShowRightPanel = nil
end

function CommDropDownListItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.Name == self.Name
end

---UpdateVM
---@param Value table
function CommDropDownListItemVM:UpdateVM(Value)
    self.IsItemVM = true
    self.ID = Value.ID
    self.Name = Value.Name
    self.IconPath = Value.IconPath
    self.RightIconPath = Value.RightIconPath
    self.ClickFunc = Value.ClickFunc
    self.TextNewStr = Value.TextNewStr or LSTR(10030)
    self.IsNew = Value.IsNew
    self.IsSelectedFunc = Value.IsSelectedFunc
    self.ItemData = Value.ItemData

   

    self.IsShowIcon = false
    if Value.IsShowIcon ~= nil then
        self.IsShowIcon = Value.IsShowIcon
    elseif self.IconPath  then
        self.IsShowIcon = true
    end

    self.IsShowRightIcon = false
    if Value.IsShowRightIcon ~= nil then
        self.IsShowRightIcon = Value.IsShowRightIcon
    elseif self.RightIconPath then
        self.IsShowRightIcon = true
    end

    self.IsShowRightPanel = false
    if Value.IsShowRightPanel ~= nil then
        self.IsShowRightPanel = Value.IsShowRightPanel
    elseif self.RightIconPath or self.IsNew then
        self.IsShowRightPanel = true
    end
end


function CommDropDownListItemVM:SetIconPath(InIconPath)
    self.IconPath = InIconPath
end

function CommDropDownListItemVM:SetRightIconPath(InRightIconPath)
    self.RightIconPath = InRightIconPath
end

function CommDropDownListItemVM:SetIsShowRightIcon(IsShowRightIcon)
    self.IsShowRightIcon = IsShowRightIcon
end

function CommDropDownListItemVM:SetIsShowIcon(IsShowIcon)
    self.IsShowIcon = IsShowIcon
end

return CommDropDownListItemVM