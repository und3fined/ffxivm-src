---
--- Author: michaelyang_lightpaw
--- DateTime: 2024-11-04 20:48
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")

---@class GateLeapOfFaithResultItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgCheckIcon UFImage
---@field ImgIcon UFImage
---@field ImgIcon_1 UFImage
---@field ImgIcon_2 UFImage
---@field ImgIcon_3 UFImage
---@field TextCoin UFTextBlock
---@field TextGetCount UFTextBlock
---@field TextTypeName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GateLeapOfFaithResultItemView = LuaClass(UIView, true)

function GateLeapOfFaithResultItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.ImgCheckIcon = nil
    --self.ImgIcon = nil
    --self.ImgIcon_1 = nil
    --self.ImgIcon_2 = nil
    --self.ImgIcon_3 = nil
    --self.TextCoin = nil
    --self.TextGetCount = nil
    --self.TextTypeName = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GateLeapOfFaithResultItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GateLeapOfFaithResultItemView:OnInit()
    self.IconTable = {}

    self.IconTable[ProtoRes.Game.LeapOfFaithCactusType.LeapOfFaithCactusTypeGold] = self.ImgIcon_1
    self.IconTable[ProtoRes.Game.LeapOfFaithCactusType.LeapOfFaithCactusTypeSilver] = self.ImgIcon_2
    self.IconTable[ProtoRes.Game.LeapOfFaithCactusType.LeapOfFaithCactusTypeBronze] = self.ImgIcon_3
end

function GateLeapOfFaithResultItemView:OnDestroy()
end

function GateLeapOfFaithResultItemView:OnShow()
end

function GateLeapOfFaithResultItemView:OnHide()
end

function GateLeapOfFaithResultItemView:OnRegisterUIEvent()
end

function GateLeapOfFaithResultItemView:OnRegisterGameEvent()
end

function GateLeapOfFaithResultItemView:OnRegisterBinder()
end

--- InType int32 这里偷懒下，1表示 win ， 2表示lose , 3表示仙人刺
--- InSubType ProtoRes.LeapOfFaithCactusType 金，银，铜
--- InScore int32 分数
function GateLeapOfFaithResultItemView:UpdateInfo(InMainType, InSubType, InCount, InCoin)
    if (InMainType == 1) then
        -- 赢
        UIUtil.SetIsVisible(self.ImgIcon, true)
        UIUtil.SetIsVisible(self.ImgCheckIcon, true)
        UIUtil.SetIsVisible(self.ImgUncheck, false)

        for i = 1, #self.IconTable do
            UIUtil.SetIsVisible(self.IconTable[i], false)
        end

        self.TextTypeName:SetText(LSTR(1270027)) -- 抵达终点

        UIUtil.SetIsVisible(self.TextGetCount, false)

        self.TextCoin:SetText(InCoin)
    elseif (InMainType == 2) then
        -- 输
        UIUtil.SetIsVisible(self.ImgIcon, true)
        UIUtil.SetIsVisible(self.ImgCheckIcon, false)
        UIUtil.SetIsVisible(self.ImgUncheck, true)

        for i = 1, #self.IconTable do
            UIUtil.SetIsVisible(self.IconTable[i], false)
        end

        self.TextTypeName:SetText(LSTR(1270027)) -- 抵达终点

        UIUtil.SetIsVisible(self.TextGetCount, false)

        self.TextCoin:SetText(InCoin)
    elseif (InMainType == 3) then
        -- 仙人刺
        UIUtil.SetIsVisible(self.ImgIcon, false)
        for i = 1, #self.IconTable do
            UIUtil.SetIsVisible(self.IconTable[i], i == InSubType)

        end

        local TypeStr = ProtoEnumAlias.GetAlias(ProtoRes.Game.LeapOfFaithCactusType, InSubType)
        
        local TypeNameStr = string.format("%s%s", TypeStr, LSTR(1270028)) -- 金、银、铜仙人刺
        self.TextTypeName:SetText(TypeNameStr)

        UIUtil.SetIsVisible(self.TextGetCount, true)

        local FinalCount = InCount or 0
        local GetTextStr = "×"..tonumber(FinalCount)
        self.TextGetCount:SetText(GetTextStr)

        self.TextCoin:SetText(InCoin)
        UIUtil.SetIsVisible(self.ImgCheckIcon, false)
        UIUtil.SetIsVisible(self.ImgUncheck, false)
    end
end

return GateLeapOfFaithResultItemView
