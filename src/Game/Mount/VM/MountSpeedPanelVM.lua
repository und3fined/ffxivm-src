local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local MountSpeedListItemVM = require("Game/Mount/VM/MountSpeedListItemVM")
local MountSpeedUnlockInfoVM = require("Game/Mount/VM/MountSpeedUnlockInfoVM")
local MapUtil = require("Game/Map/MapUtil")
local WeatherRegionCfg = require("TableCfg/WeatherRegionCfg")

local MountMgr = _G.MountMgr

---class MountSpeedPanelVM : UIViewModel
local MountSpeedPanelVM = LuaClass(UIViewModel)



function MountSpeedPanelVM:Ctor()
    self.AllMapItems = nil --所有地图数据
    self.TextMainCity = ""
    self.TextCity = ""
    self.MapList = UIBindableList.New(MountSpeedListItemVM)
    self.QuestInfoList = UIBindableList.New(MountSpeedUnlockInfoVM)
    self.CurMapSpeedLevel = 0
    self.CurMapID = 0
    self.SpeedLevelOne = 0
    self.SpeedLevelTwo = 0
    self.ImgBG = ""
end

function MountSpeedPanelVM:OnShutdown()
    self.AllMapItems = nil 
    self.MapList = nil
    self.TextMainCity = ""
    self.TextCity = ""
    self.CurMapSpeedLevel = 0
    self.CurMapID = 0
    self.SpeedLevelOne = 0
    self.SpeedLevelTwo = 0
    self.ImgBG = ""
end

function MountSpeedPanelVM:SetSelectMapContent(Value)
    self.CurMapID = Value.MapID
    self.CurMapSpeedLevel = Value.MapSpeedLevel
    self:SetSpeedLevelIcon()
    self.TextCity = Value.MapName
    self.QuestID = Value.QuestID
    self:SetQuestInfo(Value.QuestInfoList)
    for i = 1, self.MapList:Length() do
		local ItemVM = self.MapList:Get(i)
		ItemVM:SetSelectedState(self.CurMapID == ItemVM.MapID)	
	end
end

function MountSpeedPanelVM:UpdateMapListData(RegionID)
    local MountSpeedCfg = MountMgr.MountSpeedCfg
    if not MountSpeedCfg then
        return
    end
    local MapListData = MountSpeedCfg[RegionID]
    if MapListData then
        self.MapList:UpdateByValues(MapListData)
    else
        self.MapList.Clear()
    end
    self.TextMainCity = MapUtil.GetRegionName(RegionID)
    local Cfg = WeatherRegionCfg:FindCfgByKey(RegionID)
    if Cfg then
        self.ImgBG = Cfg.BG or ""
    end
end

function MountSpeedPanelVM:SetSpeedLevelIcon()
    if self.CurMapSpeedLevel == 0 then
        self.SpeedLevelOne = 0
        self.SpeedLevelTwo = 0
    elseif self.CurMapSpeedLevel == 1 then
        self.SpeedLevelOne = 1
        self.SpeedLevelTwo = 0
    else
        self.SpeedLevelOne = 1
        self.SpeedLevelTwo = 1
    end
end

function MountSpeedPanelVM:SetQuestInfo(QuestInfo)
    if QuestInfo then
        self.QuestInfoList:UpdateByValues(QuestInfo)
    else
        self.QuestInfoList.Clear()   
    end
end

return MountSpeedPanelVM