---
--- Author: Leo , michaelyang_lightpaw
--- DateTime: 2023-9-15 19:06:31
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local GoldGameRewardItemVM = require("Game/Gate/ItemVM/GoldGameRewardItemVM")

local GoldSauserVM = LuaClass(UIViewModel)

function GoldSauserVM:Ctor()
    self:ResetData()
end

function GoldSauserVM:ResetData()
    self.ActivityName = "" -- 活动名字
    self.ActivityDesc = "" -- 活动描述
    self.ActivityTime = "" -- 倒计时内容，目前调用的通用接口
    self.bShowPanelCountDown = false -- 是否显示倒计时
    self.bShowPanelAvoid = false -- 是否显示躲避次数
    self.bAvoidTimesChanged = false -- 躲避次数发生了改变，播放特效的
    self.bShowPanelGet = false -- 显示金币获取数量
    self.bDescVisible = true -- 显示活动描述 Panel
    self.GoldText = "" -- 获取金碟币文字
    self.AvoidText = "" -- 躲避次数的文字
    self.bShowBtnQuit = false
    self.CountDownTitleText = LSTR(1270003) -- 距离开始

    self.RewardListVMList = UIBindableList.New(GoldGameRewardItemVM)
end

function GoldSauserVM:OnInit()
end

function GoldSauserVM:OnBegin()
end

function GoldSauserVM:UpdateVM(Value)
end

function GoldSauserVM:OnShutdown()
end

function GoldSauserVM:OnEnd()
end

return GoldSauserVM
