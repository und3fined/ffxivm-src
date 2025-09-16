---
--- Author: loiafeng
--- DateTime: 2025-01-07 10:47
--- Description: 主界面右上角功能区按钮
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local MainFunctionDefine = require("Game/Main/FunctionPanel/MainFunctionDefine")
local MainFunctionUtil = require("Game/Main/FunctionPanel/MainFunctionUtil")

---@class MainFunctionItemVM : UIViewModel
local MainFunctionItemVM = LuaClass(UIViewModel)

---Ctor
function MainFunctionItemVM:Ctor()
    self.Type = MainFunctionDefine.ButtonType.NONE

    self.RowIndex = 0  -- 按钮所在行数，1在最上方
    self.ColumnIndex = 0  -- 按钮所在列数，1在最右侧

    self.Icon = ""
    self.RedDotID = 0

    self.IsUnlock = true            -- 按钮对应的系统是否已经解锁（或处于开启时期）
    self.IsVisibleOrigin = true     -- 业务层可以通过这个变量临时控制按钮是否显示
    self.IsVisible = true           -- 实际ItemView绑这个变量
end

---@param Value MainFunctionItemVM
function MainFunctionItemVM:IsEqualVM(Value)
    return self.Type == Value.Type
end

---UpdateVM
---@param Value table
function MainFunctionItemVM:UpdateVM(Params)
    if nil == Params then
        _G.FLOG_ERROR("MainFunctionItemVM.UpdateVM: Invalid params")
        return
    end

    local Type = Params.Type
    -- loiafeng: ButtonType.NONE 作为占位按钮存在 
    if nil == Type then
        _G.FLOG_ERROR("MainFunctionItemVM.UpdateVM: Invalid type: " .. tostring(Type))
        return
    end

    self.Type = Type
    self.RowIndex = Params.RowIndex
    self.ColumnIndex = Params.ColumnIndex

    local ButtonCfg = MainFunctionDefine.GetButtonConfig(Type)
    self.Icon = ButtonCfg.Icon or ""
    self.RedDotID = ButtonCfg.RedDotID or 0

    self:UpdateUnlockState()
    self:SetIsVisible(true)
end

function MainFunctionItemVM:AdapterOnGetWidgetIndex()
    -- 季节活动特殊显示
    return (self.Type == MainFunctionDefine.ButtonType.SEASON_ACTIVITY or 
            self.Type == MainFunctionDefine.ButtonType.DEPART_OF_LIGHT) and 1 or 0
end

---SortPredicate
---@param Lhs MainFunctionItemVM
---@param Rhs MainFunctionItemVM
function MainFunctionItemVM.SortPredicate(Lhs, Rhs)
    if Lhs.RowIndex ~= Rhs.RowIndex then
        return Lhs.RowIndex < Rhs.RowIndex
    elseif Lhs.IsVisible == Rhs.IsVisible then
        return Lhs.ColumnIndex > Rhs.ColumnIndex
    end
    return Rhs.IsVisible
end

---UpdateIsVisibleInternal
---只有模块解锁，且业务层未隐藏按钮，按钮才显示
---更新可见性后，需要在MainFunctionPanelVM中，重新对BindableList排序
---private
function MainFunctionItemVM:UpdateIsVisibleInternal()
    self.IsVisible = self.IsVisibleOrigin and self.IsUnlock
end

---更新可见性后，需要在MainFunctionPanelVM中，重新对BindableList排序
function MainFunctionItemVM:UpdateUnlockState()
    self.IsUnlock = MainFunctionUtil.IsButtonUnlock(self.Type)
    self:UpdateIsVisibleInternal()
end

---更新可见性后，需要在MainFunctionPanelVM中，重新对BindableList排序
function MainFunctionItemVM:SetIsVisible(IsVisible)
    self.IsVisibleOrigin = IsVisible
    self:UpdateIsVisibleInternal()
end

return MainFunctionItemVM
