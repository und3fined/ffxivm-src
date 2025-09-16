--
-- Author: alex
-- Date: 2024-02-28 15:21
-- Description:足迹系统
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local FootPrintRegionItemVM = require("Game/FootPrint/ItemVM/FootPrintRegionItemVM")
local FootPrintRegionVM = require("Game/FootPrint/FootPrintRegionVM")
--local FootPrintMapItemVM = require("Game/FootPrint/ItemVM/FootPrintMapItemVM")
local FootPrintDefine = require("Game/FootPrint/FootPrintDefine")
local MapUtil = require("Game/Map/MapUtil")
local ProtoRes = require("Protocol/ProtoRes")
local FLOG_ERROR = _G.FLOG_ERROR

---@class FootPrintVM : UIViewModel
---@field RegionContentVM FootPrintRegionVM@具体地图的足迹内容VM
local FootPrintVM = LuaClass(UIViewModel)

---Ctor
function FootPrintVM:Ctor()
end

function FootPrintVM:OnInit()
    -- Main Part
    self.RegionName = ""
    self.RegionContentVM = FootPrintRegionVM.New()
    self.RegionItemVMs = UIBindableList.New(FootPrintRegionItemVM)
    self.RegionBg = ""

    self.SelectedRegionID = 0

    self.bLightedAnimPlayingMainPanel = false -- 主界面点亮动画是否在播放
    self.bLightedAnimPlayingBottle = false -- 瓶子的点亮动画是否在播放
end

function FootPrintVM:OnShutdown()
    self.RegionContentVM = nil
    self.RegionItemVMs = nil 
end

function FootPrintVM:ChangeTheRegion(RegionInfo)
    --[[local RegionMapItems = {}
    local RegionID = RegionInfo.RegionID
    if not RegionID then
        return
    end
    self.SelectedRegionID = RegionID

    self.RegionName = MapUtil.GetRegionName(RegionID)
    --self.RegionBg = RegionInfo.BgImgPath

    local MapItems = RegionInfo.MapItems
    if not MapItems or not next(MapItems) then
        return
    end
    for _, value in ipairs(MapItems) do
        local SubItemVM = FootPrintMapItemVM.New()
        SubItemVM:UpdateVM(value)
        table.insert(RegionMapItems, SubItemVM)
    end
    self.RegionMapItems = RegionMapItems
    local UpdateCallBack = self.RegionMapItemsCallBack
    if UpdateCallBack then
        UpdateCallBack()
    end--]]
end

function FootPrintVM:UpdateRegionList(RegionDataList)
    if not RegionDataList or not next(RegionDataList) then
        return
    end
    local RegionItemVMs = self.RegionItemVMs
    if not RegionItemVMs then
        return
    end
    RegionItemVMs:Clear()
    RegionItemVMs:UpdateByValues(RegionDataList)
end

function FootPrintVM:SelectTheRegion(RegionInfo)
    if not RegionInfo then
        return
    end

    local RegionID = RegionInfo.RegionID
    if not RegionID then
        return
    end
    local RegionItemVMs = self.RegionItemVMs
    if not RegionItemVMs then
        return
    end

    local TargetBottle = RegionItemVMs:Find(function(e)
        return e.RegionID == RegionID
    end) 
    
    self.RegionContentVM:UpdateMainPanelData(RegionInfo, TargetBottle)
end

function FootPrintVM:SelectTheParentType(ParentTypeSevInfo)
    if not ParentTypeSevInfo then
        return
    end
    local MapDetailVM = self.RegionContentVM
    if not MapDetailVM then
        return
    end

    local ParentType = ParentTypeSevInfo.ParentType
    local TypeItemsSevInfo = ParentTypeSevInfo.TypeItemsSevInfo
    MapDetailVM:SelectTheParentType(ParentType)
    MapDetailVM:UpdateMapItemsDetailContent(TypeItemsSevInfo)
end

function FootPrintVM:OnNotifyMapRewardReceived(RegionIDGetReward)
    local RegionContentVM = self.RegionContentVM
    if not RegionContentVM then
        return
    end

    local RegionID = RegionContentVM.RegionID or 0
    if RegionID ~= RegionIDGetReward then
        return
    end
    RegionContentVM.bLighted = true

    local BottleVM = RegionContentVM.BottleVM
    if not BottleVM then
        return
    end

    BottleVM.bLighted = true
end

--- 控制所有区域Item的AnimIn是否可以播放
function FootPrintVM:SetAllRegionItemPlayAnimInState(bPlay)
    local RegionItemVMs = self.RegionItemVMs
    if not RegionItemVMs then
        return
    end

    for Index = 1, RegionItemVMs:Length() do
        local ItemVM = RegionItemVMs:Get(Index)
        if ItemVM then
            ItemVM.bNeedPlayAnimIn = bPlay
        end
    end
end

return FootPrintVM