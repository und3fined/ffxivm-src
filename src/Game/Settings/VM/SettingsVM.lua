---
--- Author: xingcaicao
--- DateTime: 2023-03-22 11:18
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local SettingsCategoryCfg = require("TableCfg/SettingsCategoryCfg")
local SettingsSubCategoryVM = require("Game/Settings/VM/SettingsSubCategoryVM")
local DungeonFpsmodeCfg = require("TableCfg/DungeonFpsmodeCfg")
local SaveKey = require("Define/SaveKey")

---@class SettingsVM : UIViewModel
local SettingsVM = LuaClass(UIViewModel)

---Ctor
function SettingsVM:Ctor()
end
	
function SettingsVM:OnInit()
    self:Reset(true)
end

function SettingsVM:OnBegin()

end

function SettingsVM:OnEnd()

end

function SettingsVM:OnShutdown()
    self:Reset()
end

function SettingsVM:Reset( IsInit )
    self.CategoryList = {}
    self.SettingsItemVMList = {}

    self.CurCategory = 0
    self.CurSubCategoryVM = nil

    if IsInit then
        self:InitSettings()
    end
end

function SettingsVM:InitSettings()
    _G.SettingsMgr:LoadFpsModeDungeonList()

    local Data = {}
	local Cfg = SettingsCategoryCfg:FindAllCfg()

	for _, v in ipairs(Cfg) do
		local Category = v.Category
		if Category then
            local T = Data[Category] or {}
            T.Category = Category
            T.Name = T.Name or v.CategoryName
            T.Key = Category
            Data[Category] = T
		end
	end

    Data = table.values(Data) 
    table.sort(Data, function(lhs, rhs) return lhs.Category < rhs.Category end)

	self.CategoryList = Data

    for _, v in ipairs(self.CategoryList) do
        v.Name = string.isnilorempty(v.Name) and v.CategoryName or v.Name --SettingsMainPanelView的CommMenu需要Name数据

        local Category = v.Category
        if nil == self.SettingsItemVMList[Category]then
            self.SettingsItemVMList[Category] = UIBindableList.New(SettingsSubCategoryVM)
        end
    end
end

function SettingsVM:SetCategory( Category )
    if nil == Category then
        return
    end

    self.CurCategory = Category
end

function SettingsVM:UpdateItemList( bForce )
    if self.CurCategory == 0 then
        return
    end

    if bForce then --开关性能模式的时候都要刷
        self.SettingsItemVMList[self.CurCategory]  = UIBindableList.New(SettingsSubCategoryVM)
    end

    local ItemVM = self.SettingsItemVMList[self.CurCategory] 
    if nil == ItemVM then
        return 
    end

    if ItemVM:Length() > 0 then
        local Cnt = ItemVM:Length()
        for index = 1, Cnt do
            ItemVM:Get(index):RefreshItems()
        end
        
        self.CurSubCategoryVM = ItemVM 
        return
    end

	local SubCategoryList = SettingsCategoryCfg:GetSubCategoryList(self.CurCategory)
    if self.CurCategory ~= 6 then
        for _, v in ipairs(SubCategoryList) do 
            ItemVM:AddByValue(v)
        end
    else
        local SaveMode = _G.UE.USaveMgr.GetInt(SaveKey.PerformanceMode, -1, false)
        --没Save过或者关闭的情况，会显示预设和画质的
        local bPerformanceMode = true
        if SaveMode < 0 or SaveMode == 1 then --关闭
            bPerformanceMode = false
        end
    
        -- local IsWithEmulatorMode = _G.UE.UUIMgr.Get():IsWithEmulator()
        -- if Category == 11 and (IsWithEmulatorMode 
        --     or _G.UE.USettingUtil.GetDefaultQualityLevel() <= 1
        --     or not _G.SettingsMgr:HaveFpsModeDungeon()) then
        --     FLOG_INFO("setting don't show Dungeon tab")
        -- else
        -- end
        
        local LastSelectLevel = _G.UE.USaveMgr.GetInt(SaveKey.SelectQualityLevel, -1, false)
        if LastSelectLevel <= 1 then
            bPerformanceMode = false
        end
    
        local bHidePerforceMode = _G.SettingsMgr:IsHidePerforceMode()
        for _, v in ipairs(SubCategoryList) do 
            if bPerformanceMode and v.Category == 6 and (v.SubCategory == 2 or v.SubCategory == 3) then --预设方案、画质里的都隐藏
            elseif bHidePerforceMode and v.Category == 6 and v.SubCategory == 1 then    --低和极低的时候，是不会显示预设方案的
            else
                ItemVM:AddByValue(v)
            end
        end    
    end

    self.CurSubCategoryVM = ItemVM 
end

return SettingsVM