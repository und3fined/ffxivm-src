---
--- Author: user
--- DateTime: 2023-03-03 10:03
--- Description:仙人仙彩购买人数界面item
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local LSTR = _G.LSTR
---@class JumboCactpotBuyersItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgOff UFImage
---@field TextPlus UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JumboCactpotBuyersItemView = LuaClass(UIView, true)

function JumboCactpotBuyersItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.FImg_Off = nil
    --self.FText_Plus = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JumboCactpotBuyersItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JumboCactpotBuyersItemView:OnInit()
    self.BoughtNum = _G.JumboCactpotMgr:GetBoughtNum()
end

function JumboCactpotBuyersItemView:OnDestroy()
end

function JumboCactpotBuyersItemView:OnShow()
    local Data = self.Params.Data
    if nil == Data then
        return
    end
    self.TextLevel:SetText(Data.JD)
    self.TextBuyers:SetText(Data.BoughtNum)
    local str = ""
    for i = 1, #Data.ToObject do
        str = string.format("%s%d", str, Data.ToObject[i])
        if i ~= #Data.ToObject then
            str = string.format("%s%s", str, "、")
        end
    end
    self.TextObject:SetText(string.format(LSTR(240050), str)) -- %s等奖
    if Data.Effecttype == 1 then
        self.TextPlus:SetText(string.format("%d%s", Data.EffectNum, "%"))
    elseif Data.Effecttype == 2 then
        self.TextPlus:SetText(Data.EffectNum)
    end
    local BoolIsVisible = self.BoughtNum >= Data.BoughtNum
    UIUtil.SetIsVisible(self.ImgOn, BoolIsVisible)
    UIUtil.SetIsVisible(self.ImgOff, not BoolIsVisible)
end

function JumboCactpotBuyersItemView:OnHide()
end

function JumboCactpotBuyersItemView:OnRegisterUIEvent()
end

function JumboCactpotBuyersItemView:OnRegisterGameEvent()
end

function JumboCactpotBuyersItemView:OnRegisterBinder()
end

return JumboCactpotBuyersItemView
