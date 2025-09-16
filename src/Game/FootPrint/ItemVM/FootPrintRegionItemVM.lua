--
-- Author: alex
-- Date: 2024-02-28 15:21
-- Description:足迹系统地域地图ItemVM
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local FootPrintDefine = require("Game/FootPrint/FootPrintDefine")
local FootPrintRegionCfg = require("TableCfg/FootMarkRegionCfg")
local FootPrintMapCfg = require("TableCfg/FootPrintMapCfg")
local MapUtil = require("Game/Map/MapUtil")
local LSTR = _G.LSTR

local RegionId2Color = FootPrintDefine.RegionId2Color
local LockedBGPath = "Texture2D'/Game/UI/Texture/FootPrint/UI_FootPrint_Img_Area_NotUnlocked.UI_FootPrint_Img_Area_NotUnlocked'"

---@class FootPrintRegionItemVM : UIViewModel
---@field MapID number@地图id
---@field MapName string@地图名称
---@field LockState LockState@足迹系统解锁状态枚举
---@field ScheduleText string@足迹解锁进度文本
---@field bMajorAtThisMap boolean@主角当前是否在这张地图
---@field bLighted boolean@已点亮
local FootPrintRegionItemVM = LuaClass(UIViewModel)

---Ctor
function FootPrintRegionItemVM:Ctor()
    self.RegionID = 0
    self.RegionName = ""
    self.RegionPhotoPath = ""
    self.RegionColorPath = ""
    self.ScheduleText = ""
    self.bMajorAtThisMap = false
    self.bLighted = false
    self.bShowPanelSchedule = true
    self.RedDotName = ""
    
    self.IsRegionUnlock = false
    self.CompleteTimeText = ""
    self.CompleteTimeTextOutlineColor = nil
    self.CompleteIcon = ""
    self.bNeedPlayAnimIn = true
end

function FootPrintRegionItemVM:IsEqualVM(Value)
    return self.RegionID == Value.RegionID
end

function FootPrintRegionItemVM:UpdateVM(Value)
    local RegionID = Value.RegionID
    local RegionCfg = FootPrintRegionCfg:FindCfgByKey(RegionID)
    if not RegionID or not RegionCfg then
        self:UpdateEmptyVM()
        return
    end
    self.RegionID = RegionID
    self.RegionName = Value.Name
    self.bMajorAtThisMap = Value.bMajorAtThisMap
    local bRegionUnlock = Value.IsRegionUnlock
    self.IsRegionUnlock = bRegionUnlock
    self.RegionColorPath = RegionCfg.BgColorImgPath
    self.CompleteTimeTextOutlineColor = RegionId2Color[RegionID]
    if not bRegionUnlock then
        self.RegionPhotoPath = LockedBGPath
        self.ScheduleText = LSTR(320006)
        self.bLighted = false
    else
        self.RegionPhotoPath = RegionCfg.BgImgPath
       
        local bLighted = Value.bLighted
        self.bLighted = bLighted
        self.CompleteTimeText = Value.CompleteTimeText
        self.CompleteIcon = RegionCfg.StampIconPath
        local CfgScore = RegionCfg.TargetScore or 0
        local ActualScore = Value.ActualScore or 0
     
        self.ScheduleText = bLighted and tostring(CfgScore) or string.format("%d/%d", ActualScore, CfgScore)
    end
   
    self.RedDotName = string.format("%s/%s", FootPrintDefine.RedDotBaseName, tostring(RegionID))
end

function FootPrintRegionItemVM:UpdateEmptyVM()
    self.RegionID = nil
    self.RegionName = LSTR(320007)
    self.RegionPhotoPath = LockedBGPath
    self.ScheduleText = LSTR(320006)
    self.IsRegionUnlock = false
    self.bMajorAtThisMap = false
    self.bLighted = false
end

return FootPrintRegionItemVM