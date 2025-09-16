--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2024-12-17 10:48:29
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2025-01-20 14:57:40
FilePath: \Client\Source\Script\Game\FishNotes\ItemVM\FishNotesWeatherBallItemVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local TipsUtil = require("Utils/TipsUtil")

---@class FishNotesWeatherBallItemVM: UIViewModel
local FishNotesWeatherBallItemVM = LuaClass(UIViewModel)

function FishNotesWeatherBallItemVM:Ctor()
    self.Icon = nil
    self.Name = ""
    self.IsShowName = false
end

function FishNotesWeatherBallItemVM:IsEqualVM(Value)
    return self.Name == Value.Name
end

function FishNotesWeatherBallItemVM:UpdateVM(Value)
    self.Icon = Value.Icon or ""
    self.Name = Value.Name or ""
end

function FishNotesWeatherBallItemVM.BtnCallBack(ItemData, ItemView)
    TipsUtil.ShowInfoTips(ItemData.Name, ItemView, _G.UE.FVector2D(0, 0), _G.UE.FVector2D(0, 0), false)
end

return FishNotesWeatherBallItemVM