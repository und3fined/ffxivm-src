---
--- Author: Alex
--- DateTime: 2023-8-29 09:30:17
--- Description: 风脉泉系统
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local AetheCurrentMainItemVM = require("Game/AetherCurrent/ItemVM/AetheCurrentMainItemVM")
local AetherCurrentSkillPanelVM = require("Game/AetherCurrent/AetherCurrentSkillPanelVM")
local AetherCurrentDefine = require("Game/AetherCurrent/AetherCurrentDefine")
local MapUtil = require("Game/Map/MapUtil")
local ProtoRes = require("Protocol/ProtoRes")
local WindPulseSpringActivateType = ProtoRes.WindPulseSpringActivateType
local TimerMgr
local FLOG_ERROR = _G.FLOG_ERROR

---@class AetherCurrentsVM : UIViewModel
---@field MapItems UIBindableList@区域地图风脉泉相关数据显示
local AetherCurrentsVM = LuaClass(UIViewModel)

---Ctor
function AetherCurrentsVM:Ctor()
end

function AetherCurrentsVM:OnInit()
    -- Main Part
    self.bShowAetherCurrentSearchSkill = true -- 是否显示风脉仪技能界面
    self.AllMapItems = nil -- 所有地图的ViewModel数据

    self.MapItems = UIBindableList.New(AetheCurrentMainItemVM)
    --[[local function PlayAnim()
        self:PlayAllIconItemAnimIn()
    end
    self.MapItems:RegisterUpdateListCallback(self, PlayAnim)--]]
    self.SkillPanelVM = AetherCurrentSkillPanelVM.New()
    self.bShowMajorCoordinate = false -- 是否显示个人坐标
    self.bShowDropDownList = false

    self.bShowTemporaryBtn = false -- 是否显示minimap临时风脉地图入口按钮
    TimerMgr = _G.TimerMgr
end

function AetherCurrentsVM:OnShutdown()
    self.AllMapItems = nil 
    self.MapItems = nil
    self.SkillPanelVM = nil
end

function AetherCurrentsVM:OnBegin()
  
end

function AetherCurrentsVM:OnEnd()
    local SkillPanelVM = self.SkillPanelVM -- 切换角色则初始化风脉仪数据
    if SkillPanelVM then
        SkillPanelVM:InitData()
    end
end

--- 同步所有地图的风脉泉数据
---@param Value table@[RegionID[AetheCurrentMainItemVMs]]
function AetherCurrentsVM:UpdateAllMapItems(Value)
    self.AllMapItems = Value
end

--- 更新对应地域当前地图列表
function AetherCurrentsVM:UpdateMainPanelData(RegionID)
    local MapItems = self.MapItems
    local AllMapItems = self.AllMapItems
    if not AllMapItems then
        return
    end
    if not MapItems then
        return
    end

    local RegionMapItems = AllMapItems[RegionID]
    if not RegionMapItems then
        return
    end
    local MapListData = RegionMapItems
    if MapListData then
        for _, MapData in ipairs(MapListData) do
            MapData.bRootPanelVisible = true
        end
        MapItems:UpdateByValues(MapListData)
    else
        MapItems:Clear()
    end
end

--- 播放所有Item的AnimIn动画
--[[function AetherCurrentsVM:PlayAllIconItemAnimIn()
    local MapItems = self.MapItems
    if not MapItems then
        return
    end
    local TimerLoopCount = MapItems:Length()
    if not TimerLoopCount or TimerLoopCount <= 0 then
        return
    end

    local ItemIndex = 1
    TimerMgr:AddTimer(self, function()
        local Item = MapItems:Get(ItemIndex)
        if Item then
            local AnimInSwitch = Item.AnimInSwitch
            Item.AnimInSwitch = not AnimInSwitch
        end
        print("CurIndex played：%s", tostring(ItemIndex))
        ItemIndex = ItemIndex + 1
    end, 0, 0.08, TimerLoopCount)
end--]]

--- 同步更新所有地图缓存中新的风脉泉标记的激活状态
---@param PointInfo table @[MapID, MarkID, CurrentType, bFinished]
function AetherCurrentsVM:UpdateAllItemsSinglePointInfoActived(PointInfo)
    if not PointInfo then
        return
    end

    local AllMapItems = self.AllMapItems
    if not AllMapItems or not next(AllMapItems) then
        return
    end

    local MapID = PointInfo.MapID
    local MarkID = PointInfo.MarkID
    if not MapID or not MarkID then
        return
    end

    local RegionID = MapUtil.GetMapRegionID(MapID)
    if not RegionID then
        return
    end

    local RegionInfo = AllMapItems[RegionID]
    if not RegionInfo then
        return
    end

    local TargetMap = table.find_by_predicate(RegionInfo, function(e)
        return e.MapID == MapID
    end)

    if not TargetMap then
        return
    end

    local Type = PointInfo.CurrentType
    local MarkListData
    if Type == WindPulseSpringActivateType.Interact then
        MarkListData = TargetMap.InteractMarkDatas
    elseif Type == WindPulseSpringActivateType.Task then
        MarkListData = TargetMap.QuestMarkDatas
    end
    
    if not MarkListData then
        return
    end

    local MarkData = table.find_by_predicate(MarkListData, function(e)
        return e.MarkID == MarkID
    end)

    if not MarkData then
        return
    end

    MarkData.bActived = true
end

function AetherCurrentsVM:UpdateAllMapItemFinishedState(PointInfo)
    local MapID = PointInfo.MapID
    if not MapID then
        return
    end

    local RegionID = MapUtil.GetMapRegionID(MapID)
    if not RegionID then
        return
    end

    local bFinished = PointInfo.bFinished
    local AllMapList = self.AllMapItems
    if not AllMapList then
        return
    end

    local RegionInfo = AllMapList[RegionID]
    if not RegionInfo then
        return
    end
    local StoreMapItem = table.find_by_predicate(RegionInfo, function(e)
        return e.MapID == MapID
    end)
    
    if StoreMapItem then
        StoreMapItem.bFinished = bFinished
    end
end

--- 打开界面新增风脉泉激活表现
---@param PointInfo table@[MapID, MarkID, CurrentType, bFinished]
function AetherCurrentsVM:AddNewActivedAetherCurrent(PointInfo)
    local MapList = self.MapItems
    if MapList == nil then
        return
    end
    local MapID = PointInfo.MapID or 0
    local MarkID = PointInfo.MarkID or 0
    local Type = PointInfo.CurrentType or WindPulseSpringActivateType.Interact
    local bFinished = PointInfo.bFinished
    self:UpdateAllMapItemFinishedState(PointInfo)

    local TargetMap = MapList:Find(function(e)
        return e.MapID == MapID
    end)
    if TargetMap == nil then
        FLOG_ERROR("AetherCurrentsVM:AddNewActivedAetherCurrent: Can not find the map")
        return
    end

    -- 刷新主界面Map列表内容
    local PointInfoMapUpdate = {
        MarkID = MarkID,
        CurrentType = Type,
        bFinished = bFinished
    }
    TargetMap:UpdatePointActiveState(PointInfoMapUpdate)
    self:UpdateAllItemsSinglePointInfoActived(PointInfo)
    -- to do 刷新MapContent内容

end

--- 打开/关闭CD面板
function AetherCurrentsVM:SetSkillCDPanelVisible(bShow)
    local SkillVM = self.SkillPanelVM
    if SkillVM == nil then
        return
    end
    SkillVM.bShowCDPanel = bShow
end

--- 刷新风脉仪技能cd显示
---@param TextCD string@剩余时间显示，单位秒
---@param CDPercent number@RadialImage Percent
function AetherCurrentsVM:UpdateSearchSkillCD(TextCD, CDPercent)
    local SkillVM = self.SkillPanelVM
    if SkillVM == nil then
        return
    end
    local SkillCDInfo = {
        TextCD = TextCD,
        CDPercent = CDPercent,
    }
    SkillVM:UpdateVM(SkillCDInfo)
end

return AetherCurrentsVM