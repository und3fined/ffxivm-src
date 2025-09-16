--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2024-03-15 14:34:44
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2024-05-29 10:06:25
FilePath: \Client\Source\Script\Game\Common\DropDownList\VM\CommDropDownListItemNewVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
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
---@field ImgIconColorbSameasText boolean @ImgIcon是否和文字颜色同步
local CommDropDownListItemVM = LuaClass(UIViewModel)

function CommDropDownListItemVM:Ctor()
    self.ID = nil
    self.Name = nil
    self.IconPath = nil
    self.ImgIconColorbSameasText = nil
    self.RightIconPath = nil
    self.IsNew = nil
    self.TextNewStr = nil
    self.TextQuantityStr = nil
    self.bTextQuantityShow = false
    self.ItemData = nil
    self.IsSelectedFunc = nil
    self.IsItemVM = nil
    self.IsShowIcon = nil
    self.IsShowRightIcon = nil
    self.IsShowRightPanel = nil
    self.IsShowPlayingIcon = nil

    self.RedDotType = nil
    self.RedDotData = nil
    self.Prof = nil
    self.HorIndex = nil
    self.DropdownIndex = nil
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
    self.ImgIconColorbSameasText = Value.ImgIconColorbSameasText
    self.RightIconPath = Value.RightIconPath
    self.ClickFunc = Value.ClickFunc
    self.TextNewStr = Value.TextNewStr or LSTR(10030)
    self.IsNew = Value.IsNew
    self.TextQuantityStr = Value.TextQuantityStr or " "
    self.bTextQuantityShow = Value.bTextQuantityShow or false
    self.IsSelectedFunc = Value.IsSelectedFunc
    self.ItemData = Value.ItemData
    -- self.ItemTextContentColor = Value.ItemTextContentColor
    -- self.ItemTextContenSelectedColor = Value.ItemTextContenSelectedColor
    -- self.ImgLineColor = Value.ImgLineColor
    -- self.ImgSelectColor = Value.ImgSelectColor
    -- self.Style = Value.Style
    ---防止崩溃，用rawset设置颜色变量
    rawset(self, "ItemTextContentColor", Value.ItemTextContentColor)
    rawset(self, "ItemTextContenSelectedColor", Value.ItemTextContenSelectedColor)
    rawset(self, "ImgLineColor", Value.ImgLineColor)
    rawset(self, "ImgSelectColor", Value.ImgSelectColor)
    rawset(self, "TitleTextContentColor", Value.TitleTextContentColor)
    rawset(self, "Style", Value.Style)


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

    self.RedDotType = Value.RedDotType
    self.RedDotID = Value.RedDotID  --红点表ID
    self.RedDotData = Value.RedDotData
    self.Prof = Value.Prof
    self.HorIndex = Value.HorIndex
    self.DropdownIndex = Value.DropdownIndex
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

function CommDropDownListItemVM:SetIsShowPlayingIcon(IsShowPlayingIcon)
    self.IsShowPlayingIcon = IsShowPlayingIcon
end

return CommDropDownListItemVM