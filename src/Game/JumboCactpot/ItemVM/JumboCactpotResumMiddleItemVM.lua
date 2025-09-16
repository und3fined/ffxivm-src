---
--- Author: Leo
--- DateTime: 2023-09-21 16:25:34
--- Description: 
---
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local JumboCactpotSubNameItemVM = require("Game/JumboCactpot/ItemVM/JumboCactpotSubNameItemVM")
local ItemCfg = require("TableCfg/ItemCfg")
local ProtoRes = require("Protocol/ProtoRes")


local LSTR = _G.LSTR
---@class JumboCactpotResumMiddleItemVM : UIViewModel

local JumboCactpotResumMiddleItemVM = LuaClass(UIViewModel)

function JumboCactpotResumMiddleItemVM:Ctor()
    self.Term = 0
    self.OpenTime = ""
    self.RewardNum = 0
    self.Rewards = {}
    self.RoleList = {}

    self.JDIcon = ""
    self.ItemIcon = ""
    self.ItemCount = 0
    self.FirstNum = ""
    self.SecondNum = ""
    self.ThirdNum = ""
    self.ForthNum = ""
    self.bContentVisible = true
    self.bEmptyVisible = false

    self.NameList = UIBindableList.New(JumboCactpotSubNameItemVM)
end

function JumboCactpotResumMiddleItemVM:IsEqualVM()
    return true
end

function JumboCactpotResumMiddleItemVM:UpdateVM(Value)
    self.bEmptyVisible = Value.bEmptyVisible
    local bEmptyVisible = self.bEmptyVisible
    self.bContentVisible = not bEmptyVisible
    if bEmptyVisible then
        return
    end
    self.Term = string.format(LSTR(240043), Value.Term)  -- 第%d期
    self.OpenTime = Value.OpenTime
    local Number = Value.Number
    self.FirstNum = string.sub(Number, 1, 1)
    self.SecondNum = string.sub(Number, 2, 2)
    self.ThirdNum = string.sub(Number, 3, 3)
    self.ForthNum = string.sub(Number, 4, 4)

    self.RewardNum = string.formatint(Value.RewardNum)
    self.Rewards = Value.Rewards
    self.RoleList = Value.RoleList

    local JDCoinID = ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE
    local JDCfg = ItemCfg:FindCfgByKey(JDCoinID)
    local JDIconID = JDCfg.IconID
    self.JDIcon = ItemCfg.GetIconPath(JDIconID)

    local ResID = Value.Rewards[1].ResID
    self.ItemResID = ResID
    local Cfg = ItemCfg:FindCfgByKey(ResID)
    if Cfg ~= nil then
        local IconID = Cfg.IconID
	    self.ItemIcon = ItemCfg.GetIconPath(IconID)
    end
    self.ItemCount = Value.Rewards[1].Count

    local RoleList = self.RoleList
    local LimitRoleList = {}
    if #RoleList <= 4 then
        LimitRoleList = RoleList
    else
        for i = 1, 4 do
            LimitRoleList[i] = RoleList[i]
        end
    end
    self:UpdateNameList(LimitRoleList)

end

function JumboCactpotResumMiddleItemVM:UpdateNameList(RoleList)
    local NameList = self.NameList
    if NameList == nil then
        return
    end

    if #RoleList == 0 then
        NameList:Clear()
        return
    end

    if nil ~= NameList and NameList:Length() > 0 then
        NameList:Clear()
    end

    NameList:UpdateByValues(RoleList)
end

return JumboCactpotResumMiddleItemVM