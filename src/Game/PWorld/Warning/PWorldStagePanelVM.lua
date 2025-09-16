--[[
Author: skysong
Date: 2023/12/13 11:21
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2025-03-12 10:47:29
FilePath: \Script\Game\PWorld\Warning\PWorldStagePanelVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local WarningSkillCDItemVM = require("Game/PWorld/Warning/WarningSkillCDItemVM")
local PworldCfg = require("TableCfg/PworldCfg")
local ProtoRes = require("Protocol/ProtoRes")

---@class PWorldStagePanelVM : UIViewModel
local PWorldStagePanelVM = LuaClass(UIViewModel)

---Ctor
function PWorldStagePanelVM:Ctor()
    self.WarningSkillCDItemList = UIBindableList.New(WarningSkillCDItemVM)
    self.bToggleCheck = false
    self.PWorldIcon = ""
    self.SettingVisible = true
end

function PWorldStagePanelVM:Clear()
    self.WarningSkillCDItemList:Clear(false)
end

function PWorldStagePanelVM:UpdateWaringItems(Items)
    if self.WarningSkillCDItemList ~= nil then
        local number = table.length(Items)
        local length = self.WarningSkillCDItemList:Length()
        local offset = number - length

        if offset ~= 0 then
            if offset > 0 then
                local index = 1
                for _,Item in ipairs(Items) do
                    if index > length then
                        self.WarningSkillCDItemList:AddByValue(Item)
                    end
                    index = index + 1

                end
            else
                offset = _G.math.abs(offset)
                local index = 1

                while true do
                    self.WarningSkillCDItemList:RemoveAt(self.WarningSkillCDItemList:Length())

                    index = index + 1

                    if index >= offset then
                        break
                    end
                end
            end

            return true
        end
    end

    return false
end

function PWorldStagePanelVM:SetSettingVisible(IsVisible)
    self.SettingVisible = IsVisible
end

function PWorldStagePanelVM:Toggle()
    self.bToggleCheck = not self.bToggleCheck
end

function PWorldStagePanelVM:SetPWorldIcon(InIncon)
    self.PWorldIcon = InIncon or ""
end

function PWorldStagePanelVM:UpdateStatus()
    local Icon = _G.PWorldStageMgr.CurrIconPath
    if string.isnilorempty(Icon) then
        Icon = PworldCfg:FindValue(_G.PWorldMgr:GetCurrPWorldResID(), "PWorldIcon")
    end
    self:SetPWorldIcon(Icon)

    local PWorldID = _G.PWorldMgr:GetCurrPWorldResID()
    local Cfg = PworldCfg:FindCfgByKey(PWorldID) 
    -- local bFlag = not (Cfg and (Cfg.MaxPlayerNum == 1 or Cfg.Type == ProtoRes.pworld_sub_type.PWORLD_SUB_TYPE_1R))
    local bFlag = true
    if Cfg then
        local EnterCfg = require("TableCfg/SceneEnterCfg"):FindCfgByKey(PWorldID)
        if EnterCfg and EnterCfg.TypeID == require("Protocol/ProtoCommon").ScenePoolType.ScenePoolMuRen then
            bFlag = true
        end
    end
    -- 机制特训副本不需要显示Setting按钮
    if bFlag then
        local MainPanelVM = require("Game/Main/MainPanelVM")
        if MainPanelVM.TeachingLevelVisible then
            bFlag = false
        end
    end
    self:SetSettingVisible(bFlag)
end

return PWorldStagePanelVM