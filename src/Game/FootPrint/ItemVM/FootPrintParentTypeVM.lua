--
-- Author: alex
-- Date: 2024-02-28 15:21
-- Description:足迹系统地域地图ItemVM
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local FootPrintDefine = require("Game/FootPrint/FootPrintDefine")
local FootPrintParentTypeCfg = require("TableCfg/FootPrintParentTypeCfg")
local FootPrintRegionCfg = require("TableCfg/FootMarkRegionCfg")
local MapUtil = require("Game/Map/MapUtil")
local ProtoRes = require("Protocol/ProtoRes")
local FootPrint_Filter_Type = ProtoRes.FootMarkType
local ParentType2MapCfgIndex = FootPrintDefine.ParentType2MapCfgIndex
local ParentTypeIconPath = FootPrintDefine.ParentTypeIconPath
local ParentTypeSelectColor = FootPrintDefine.ParentTypeSelectColor

---@class FootPrintParentTypeVM : UIViewModel
---@field RegionID number@地域id
---@field ParentType FootPrint_Filter_Type@大分类枚举
---@field ScoreSchedule string@大分类足迹点数进度文本
---@field ParentTypeName string@大分类名称
---@field TypeIconPath string@大分类图标
---@field ScoreAdded number@当前打开界面是否有新增加的分数
---@field bSelected boolean@选中状态
local FootPrintParentTypeVM = LuaClass(UIViewModel)

---Ctor
function FootPrintParentTypeVM:Ctor()
    self.RegionID = 0
    self.ParentType = FootPrint_Filter_Type.FootMarkType_Invalide 
    self.ParentTypeName = ""
    self.TypeIconPath = ""
    self.ScoreScheduleCache = ""
    self.ScoreSchedule = ""
    self.ScoreAdded = 0
    self:SetNoCheckValueChange("ScoreAdded", true)
    self.ScoreStart = 0
    self.CfgScore = 0
    self.bSelected = false
    self.TextColor = ""
end

function FootPrintParentTypeVM:IsEqualVM(Value)
    return self.ParentType == Value.ParentType
end

function FootPrintParentTypeVM:UpdateVM(Value)
    local RegionID = Value.RegionID or 0
    self.RegionID = RegionID
    local ParentType = Value.ParentType
    if not ParentType then
        return
    end
    self.ParentType = ParentType

    local ParentTypeCfg = FootPrintParentTypeCfg:FindCfgByKey(ParentType)
    if not ParentTypeCfg then
        return
    end
    self.ParentTypeName = ParentTypeCfg.Name
    self.TypeIconPath = ParentTypeIconPath.Normal

     
    local ParentTypeCfgs = FootPrintRegionCfg:FindValue(RegionID, "Tabs")
    if not ParentTypeCfgs then
        return
    end

    local CfgScoreNum = 0
    local TabsCfg = table.find_by_predicate(ParentTypeCfgs, function(E) return E.Typ == ParentType end)
    if TabsCfg then
        CfgScoreNum = TabsCfg.TargetScore or 0 
    end
    self.CfgScore = CfgScoreNum
    local ActualScore = Value.ActualScore or 0
    local ScoreAdded = Value.ScoreAdded
    local ScoreShowContent = string.format("%d/%d", ActualScore, CfgScoreNum)
    if ScoreAdded > 0 then
        self.ScoreScheduleCache = ScoreShowContent
        self.ScoreAdded = ScoreAdded
        self.ScoreStart = ActualScore - ScoreAdded
    else
        self.ScoreScheduleCache = ""
        self.ScoreAdded = 0
        self.ScoreStart = 0
        self.ScoreSchedule = ScoreShowContent
    end
end

--- 在滚动动画结束后将变化后的分数赋值给UI显示
function FootPrintParentTypeVM:ShowParentTypeScoreInView()
    self.ScoreSchedule = self.ScoreScheduleCache
end

--- 在滚动动画中更新分数的显示
function FootPrintParentTypeVM:UpdateParentTypeScoreInView(Score)
    local ScoreInt = math.floor(Score)
    self.ScoreSchedule = string.format("%d/%d", ScoreInt, self.CfgScore)
end

function FootPrintParentTypeVM:SetTheSelectedState(bSelected)
    self.bSelected = bSelected
    local Icon = bSelected and ParentTypeIconPath.Selected or ParentTypeIconPath.Normal
    self.TypeIconPath = Icon
    local ColorHex = bSelected and ParentTypeSelectColor.Selected or ParentTypeSelectColor.Normal
    self.TextColor = ColorHex
end

return FootPrintParentTypeVM