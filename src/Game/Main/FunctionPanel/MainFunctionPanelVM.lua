---
--- Author: loiafeng
--- DateTime: 2025-01-07 10:47
--- Description: 主界面右上角功能区按钮
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local MainFunctionItemVM = require("Game/Main/FunctionPanel/MainFunctionItemVM")
local MainFunctionDefine = require("Game/Main/FunctionPanel/MainFunctionDefine")
local ButtonType = MainFunctionDefine.ButtonType

---@class MainFunctionPanelVM : UIViewModel
local MainFunctionPanelVM = LuaClass(UIViewModel)

function MainFunctionPanelVM:Ctor()
    self.ButtonList = UIBindableList.New(MainFunctionItemVM)  ---@type UIBindableList
end

function MainFunctionPanelVM:OnInit()
end

function MainFunctionPanelVM:OnBegin()
end

function MainFunctionPanelVM:OnEnd()
end

function MainFunctionPanelVM:OnShutdown()
end

function MainFunctionPanelVM:UpdateButtonLayout()
    local Layout = self:GetLayoutInternal()
    self.ButtonList:UpdateByValues(Layout)
    self.ButtonList:Sort(MainFunctionItemVM.SortPredicate)
    _G.EventMgr:SendEvent(_G.EventID.MainPanelFunctionLayoutChange)
end

---GetLayoutInternal
---@return table<number, table> @Layout
function MainFunctionPanelVM:GetLayoutInternal()
    -- TODO(loiafeng): 支持玩家自定义部分点位
    -- 这里注意要保证布局中不出现重复的按钮
    local Layout = {
        [1] = { Type = ButtonType.MENU,         RowIndex = 1, ColumnIndex = 1 },
        [2] = { Type = ButtonType.ROLE,         RowIndex = 1, ColumnIndex = 2 },
        [3] = { Type = ButtonType.ADVENTURE,    RowIndex = 1, ColumnIndex = 3 },
        [4] = { Type = ButtonType.NONE,         RowIndex = 1, ColumnIndex = 4 },

        [5] = { Type = ButtonType.ACTIVITY,     RowIndex = 2, ColumnIndex = 1 },
        [6] = { Type = ButtonType.STORE,        RowIndex = 2, ColumnIndex = 2 },
        [7] = { Type = ButtonType.BATTLE_PASS,  RowIndex = 2, ColumnIndex = 3 },
        [8] = { Type = ButtonType.NONE,         RowIndex = 2, ColumnIndex = 4 },
    }

    -- 动态按钮1: 季节活动 > 新版本内容
    local DynamicType1 = ButtonType.NONE
    if _G.OpsSeasonActivityMgr:GetSeasonActivity() ~= nil then
        DynamicType1 = ButtonType.SEASON_ACTIVITY
    elseif _G.OpsSeasonActivityMgr:GetNewVersionContentActivity() ~= nil then
        DynamicType1 = ButtonType.NEW_VERSION
    end
    Layout[4].Type = DynamicType1

    -- 动态按钮2: 光之启程 > 问卷 > 预下载
    local DynamicType2 = ButtonType.NONE
    if _G.DepartOfLightMgr:IsShowEntrance() then
        DynamicType2 = ButtonType.DEPART_OF_LIGHT  -- 光之启程
    elseif _G.MURSurveyMgr:IsNeedShowEntrance() then
        DynamicType2 = ButtonType.MUR_SURVEY
    elseif false then
        DynamicType2 = ButtonType.PRE_DOWNLOAD  -- TODO(loiafeng): 预下载
    end

    if DynamicType1 == ButtonType.NONE then
        Layout[4].Type = DynamicType2
    else
        Layout[8].Type = DynamicType2
    end

    return Layout
end

---@return MainFunctionItemVM
function MainFunctionPanelVM:GetItemVMInternal(Type)
    if nil == Type or ButtonType.NONE == Type then
        FLOG_ERROR("MainFunctionPanelVM.GetItemVMInternal: Invalid Type " .. tostring(Type))
        return nil
    end

    local function Predicate(ItemVM) return ItemVM.Type == Type end

    return self.ButtonList:GetItemByPredicate(Predicate)
end

function MainFunctionPanelVM:UpdateUnlockState(Type)
    local ItemVM = self:GetItemVMInternal(Type)
    if nil == ItemVM then
        FLOG_INFO("MainFunctionPanelVM.UpdateUnlockState: Not find item with type " .. tostring(Type))
        return
    end

    ItemVM:UpdateUnlockState()
    self.ButtonList:Sort(MainFunctionItemVM.SortPredicate)
end

---SetIsVisible 这里可以按照业务需求进行设置，不需要关心按钮是否已经解锁，FunctionVM内部会对解锁状态进行判断
---注意，该接口暂时仅供临时隐藏，UpdateLayout会导致按钮重新显示
function MainFunctionPanelVM:SetIsVisible(Type, IsVisible)
    local ItemVM = self:GetItemVMInternal(Type)
    if nil == ItemVM then
        FLOG_INFO("MainFunctionPanelVM.SetIsVisible: Not find item with type " .. tostring(Type))
        return
    end

    ItemVM:SetIsVisible(IsVisible)
    self.ButtonList:Sort(MainFunctionItemVM.SortPredicate)
end

---@param Type number @see MainFunctionDefine.ButtonType
---@return boolean
function MainFunctionPanelVM:IsInLayout(Type)
    return self:GetItemVMInternal(Type) ~= nil
end

return MainFunctionPanelVM
