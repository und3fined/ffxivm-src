--
-- Author: Carl
-- Date: 2025-3-23 16:57:14
-- Description:玩法详细说明VM

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local DepartOfLightDefine = require("Game/Departure/DepartOfLightDefine")
local DepartActivityPointItemVM = require("Game/Departure/VM/Item/DepartActivityPointItemVM")
local DepartDescIndexItemVM = require("Game/Departure/VM/Item/DepartDescIndexItemVM")

---@class DepartActivityDetailVM : UIViewModel
---@field ThemeName string @
---@field GetProgressNum number @
---
local DepartActivityDetailVM = LuaClass(UIViewModel)

function DepartActivityDetailVM:Ctor()
    self.CurDescIndex = 0 -- 当前选中索引
    self.CurDescIcon = "" -- 说明图片
    self.CurDescTitle = "" -- 说明标题
    self.CurDescContent = "" -- 说明内容
    self.CurDescPointList = {} -- 兴趣点列表
    self.CurDescPointVMList = UIBindableList.New(DepartActivityPointItemVM)
    self.DescIndexList = {}
    self.DescIndexVMList = UIBindableList.New(DepartDescIndexItemVM)
end

function DepartActivityDetailVM:OnInit()
end

function DepartActivityDetailVM:OnBegin()
end

function DepartActivityDetailVM:OnEnd()

end

function DepartActivityDetailVM:OnShutdown()

end

---@type 更新当前玩法所有玩法说明
function DepartActivityDetailVM:UpdateDescList(DescList)
    self.DescIndexList = {}
    if DescList then
        for index, _ in ipairs(DescList) do
            table.insert(self.DescIndexList, index)
        end
    end
    self.DescIndexVMList:UpdateByValues(self.DescIndexList, nil, false)
end

---@type 更新当前选中玩法玩法说明
function DepartActivityDetailVM:UpdateActivityDescInfo(Detail, Index)
    if Detail == nil then
        return
    end
    self.CurDescIndex = Index
    self.CurDescIcon = Detail.IconPath
    self.CurDescTitle = Detail.Title
    self.CurDescContent = Detail.Content

    self.CurDescPointList = Detail.Points
    self.CurDescPointVMList:UpdateByValues(self.CurDescPointList, nil, false)
end

---@type 获取当前选中玩法图片索引
function DepartActivityDetailVM:GetCurDescIndex()
    return self.CurDescIndex
end

return DepartActivityDetailVM