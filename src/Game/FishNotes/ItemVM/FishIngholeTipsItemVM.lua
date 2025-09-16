--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2025-01-17 20:21:28
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2025-01-17 20:41:05
FilePath: \Client\Source\Script\Game\FishNotes\ItemVM\FishIngholeTipsItemVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE）
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local TimeUtil = require("Utils/TimeUtil")
local FishSlotItemVM = require("Game/FishNotes/ItemVM/FishSlotItemVM")
local FishNotesMgr = require("Game/FishNotes/FishNotesMgr")
local LocalizationUtil = require("Utils/LocalizationUtil")
local EToggleButtonState = _G.UE.EToggleButtonState
local LSTR = _G.LSTR

local FishIngholeTipsItemVM = LuaClass(UIViewModel)
function FishIngholeTipsItemVM:Ctor()
    self.TextState = ""
    self.TimeText = ""
    self.ClockState = EToggleButtonState.Unchecked
    self.bClockEnabled = false
    self.bClockVisible = false
    self.bProBarCDVisible = false
    self.ProgressValue = 0
    self.Num = ""
    self.SlotVM = FishSlotItemVM.New()
    self.FishID = nil
end

function FishIngholeTipsItemVM:IsEqualVM(Value)
    return Value ~= nil
end

function FishIngholeTipsItemVM:UpdateVM(Value)
    self.Fish = Value.Fish
    local FishID = Value.Fish.Cfg.ID
    self.SlotVM:UpdateVM({ID = FishID, LocationID = Value.LocationID, IsLocationFish = false})
    self.Num = Value.Num
    self:RefreshProBar()

    --闹钟按钮状态
    self.bClockVisible = self.bClockIsActive and self.bClockEnabled
    local ClockData = FishNotesMgr:GetClockData(FishID, _G.FishIngholeVM.SelectLocationID)
    if ClockData and next(ClockData) then
        self.ClockState = EToggleButtonState.Checked
    else
        self.ClockState = EToggleButtonState.Unchecked
    end
end

function FishIngholeTipsItemVM:RefreshProBar()
    --最近窗口期ProBar （全天可钓的不能定闹钟）
    local Fish = self.Fish
    local TimeCondition = Fish.TimeCondition and Fish.TimeCondition[1]
    if Fish.WeatherCondition == nil and TimeCondition == nil then
        --全天可钓
        self.TextState = LSTR(180042)--"全天可钓"
        self.TimeText = ""
        self.bProBarCDVisible = false
        self.bClockEnabled = false
    else
        local Begin, End = FishNotesMgr:GetFishNeasetWindowTime(Fish.Cfg.ID, _G.FishIngholeVM.SelectLocationID)
        if Begin ~= nil and End ~= nil then
            local Now = TimeUtil.GetServerTime()
            local bActive = Now >= Begin and Now < End
            if bActive then
                --活跃中
                local TotalWindowTime = End - Begin
                local LeftTime = End - Now
                self.TextState = _G.LSTR(180066)--"活跃中"
                self.TimeText = LocalizationUtil.GetCountdownTimeForLongTime(LeftTime)
                self.ProgressValue = LeftTime / TotalWindowTime
                self.bProBarCDVisible = true
            else
                --休眠期
                local RemainSeconds = Begin - Now
                self.TextState = _G.LSTR(180067)--"休眠期"
                self.TimeText =  LocalizationUtil.GetCountdownTimeForLongTime(RemainSeconds)
                self.bProBarCDVisible = false
                self.ProgressValue = 0
            end
            self.bClockEnabled = true
        else
            --暂不出现
            self.TextState = _G.LSTR(180068)--"暂不出现"
            self.TimeText = ""
            self.bProBarCDVisible = false
            self.bClockEnabled = false
            self.ProgressValue = 0 
        end
    end
end

function FishIngholeTipsItemVM:SetClockSelected(IsSelected)
    self.ClockIsSelected = IsSelected
end

function FishIngholeTipsItemVM:GetFishData()
    return self.FishData
end

function FishIngholeTipsItemVM:GetFishLocationID()
    return self.LocationID
end

return FishIngholeTipsItemVM