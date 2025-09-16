--[[
Author: ZhengJianChuan
Date: 2023-03-20 10:56:36
Description: 机遇临门活动---必中一闪快刀斩魔显示数据
--]]



local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")
local UIBindableList = require("UI/UIBindableList")

---@class YojimboStageInfoVM : UIViewModel
--- Main Part
---@field TargetName URichTextBox       游戏名
---@field TextCondition1 UFTextBlock    游戏获胜条件
---@field TextCondition2 UFTextBlock    当前获得的金碟币
---@field TextDetail UFTextBlock        游戏简介
local YojimboStageInfoVM = LuaClass(UIViewModel)

function YojimboStageInfoVM:Ctor()
    self.TargetName = ""
    self.TextCondition1 = ""
    self.TextCondition2 = ""
    self.TextDetail = ""
end

function YojimboStageInfoVM:OnInit()
end

function YojimboStageInfoVM:OnBegin()
end

function YojimboStageInfoVM:OnShutdown()
end

function YojimboStageInfoVM:OnUpdateYojimboStageInfo(TargetName, Condition1, Condition2, Detail)
    self.TargetName = TargetName
    self.TextCondition1 = Condition1
    self.TextCondition2 = Condition2
    self.TextDetail = Detail
end



return YojimboStageInfoVM