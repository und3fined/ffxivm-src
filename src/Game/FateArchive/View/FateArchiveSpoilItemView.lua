---
--- Author: guanjiewu
--- DateTime: 2023-12-25 17:27
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewID = require("Define/UIViewID")
local ItemCfg = require("TableCfg/ItemCfg")
---@class FateArchiveSpoilItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field ImgItem UFImage
---@field ImgKnownBg UFImage
---@field ImgNormalTag UFImage
---@field ImgRareTag UFImage
---@field ImgUnknownBg UFImage
---@field TextGetRate UFTextBlock
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FateArchiveSpoilItemView = LuaClass(UIView, true)

function FateArchiveSpoilItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.Btn = nil
    --self.ImgItem = nil
    --self.ImgKnownBg = nil
    --self.ImgNormalTag = nil
    --self.ImgRareTag = nil
    --self.ImgUnknownBg = nil
    --self.TextGetRate = nil
    --self.TextName = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FateArchiveSpoilItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FateArchiveSpoilItemView:OnInit()
end

function FateArchiveSpoilItemView:OnDestroy()
end

function FateArchiveSpoilItemView:OnShow()
    local Params = self.Params
    if nil == Params then
        return
    end
    local SpoilInfo = Params.Data
    self.Index = SpoilInfo.Index
    self.ItemID = SpoilInfo.ResID
    if SpoilInfo.Percent >= 10 then
        self.TextGetRate:SetText(string.format(LSTR(190090), SpoilInfo.Percent))
    else
        self.TextGetRate:SetText(string.format(LSTR(190091), SpoilInfo.Percent))
    end
    local bIsDefeat = SpoilInfo.AvatarDone
    -- 设置物品名称和图标
    local Cfg = ItemCfg:FindCfgByKey(self.ItemID)
    UIUtil.ImageSetBrushFromAssetPath(self.ImgItem, ItemCfg.GetIconPath(Cfg.IconID))
    self.TextName:SetText(ItemCfg:GetItemName(self.ItemID))

    UIUtil.SetIsVisible(self.ImgUnknownBg, not bIsDefeat)
    UIUtil.SetIsVisible(self.ImgKnownBg, bIsDefeat)
    --判断多少百分比一下是稀有
    local bIsRare = (SpoilInfo.Percent <= 5)
    UIUtil.SetIsVisible(self.ImgNormalTag, not bIsRare)
    UIUtil.SetIsVisible(self.ImgRareTag, bIsRare)
end

function FateArchiveSpoilItemView:OnHide()
end

function FateArchiveSpoilItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.Btn, self.OnBtnClicked)
end

function FateArchiveSpoilItemView:OnRegisterGameEvent()
end

function FateArchiveSpoilItemView:OnRegisterBinder()
end

function FateArchiveSpoilItemView:OnBtnClicked()
    UIViewMgr:ShowView(UIViewID.FateEventStatsDetialPanel, {Index = self.Index})
end

return FateArchiveSpoilItemView
