---
--- Author: user
--- DateTime: 2023-03-06 15:10
--- Description:仙人仙彩奖励兑换界面Item
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ProtoCS = require("Protocol/ProtoCS")
local ExchangeItemVM = require("Game/JumboCactpot/JumboCactpotExchangeItemVM")

local JumboCactpotMgr = _G.JumboCactpotMgr

---@class JumboCactpotExchangeItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ExchangeBtn Comm2BtnMView
---@field FImg_On UFImage
---@field FText_Miss UFTextBlock
---@field FText_Ranking UFTextBlock
---@field FText_Status UFTextBlock
---@field Reward1 CommBackpackSlotView
---@field Reward2 CommBackpackSlotView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JumboCactpotExchangeItemView = LuaClass(UIView, true)

function JumboCactpotExchangeItemView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.ExchangeBtn = nil
    --self.FImg_On = nil
    --self.FText_Miss = nil
    --self.FText_Ranking = nil
    --self.FText_Status = nil
    --self.Reward1 = nil
    --self.Reward2 = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JumboCactpotExchangeItemView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.ExchangeBtn)
    self:AddSubView(self.Reward1)
    self:AddSubView(self.Reward2)
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JumboCactpotExchangeItemView:OnInit()
    self.Binders = {
        {"FText_Status", UIBinderSetText.New(self, self.FText_Status)},
        {"Reward1", UIBinderSetBrushFromAssetPath.New(self, self.Reward1.FImg_Icon)},
        {"Reward1Status", UIBinderSetIsVisible.New(self, self.Reward1)},
        {"Reward1TextStatus", UIBinderSetIsVisible.New(self, self.Reward1.RichTextNum)},
        {"Reward1Num", UIBinderSetText.New(self, self.Reward1.RichTextNum)},
        {"Reward2", UIBinderSetBrushFromAssetPath.New(self, self.Reward2.FImg_Icon)},
        {"Reward2Status", UIBinderSetIsVisible.New(self, self.Reward2)},
        {"Reward2TextStatus", UIBinderSetIsVisible.New(self, self.Reward2.RichTextNum)},
        {"Reward2Num", UIBinderSetText.New(self, self.Reward2.RichTextNum)},
        {"FText_Miss", UIBinderSetText.New(self, self.FText_Miss)},
        {"FText_Ranking", UIBinderSetText.New(self, self.FText_Ranking)},
        {"BtnStatus", UIBinderSetIsVisible.New(self, self.ExchangeBtn)},
        {"BtnStatus", UIBinderSetIsVisible.New(self, self.FImg_On)},
        {"IsMountNotOwn", UIBinderSetIsVisible.New(self, self.Reward1.ImageNotOwn)},
        {"IsMountNotOwn", UIBinderSetIsVisible.New(self, self.Reward2.ImageNotOwn)}
    }
end

function JumboCactpotExchangeItemView:OnDestroy()
end

function JumboCactpotExchangeItemView:OnShow()
    local Data = self.Params.Data
    if nil == Data then
        return
    end
    self.Data = Data
    self.ViewModel:OnInitValue(
            self.Data.Ranking,
            self.Data.RewardID1,
            self.Data.RewardNum1,
            self.Data.RewardID2 or nil,
            self.Data.RewardNum2 or nil,
            self.Data.TxtStatus,
            self.Data.BtnStatus,
            self.Params.Index
        )
end

function JumboCactpotExchangeItemView:OnHide()
end

function JumboCactpotExchangeItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.ExchangeBtn, self.OnClickReceive)
end

--兑奖函数
function JumboCactpotExchangeItemView:OnClickReceive()
    local MsgBody = {
        Cmd = ProtoCS.FairyColorGameCmd.ExchangeReward,
        Exchange = { Term =  JumboCactpotMgr.LastTerm}
    }
    JumboCactpotMgr:OnSendNetMsg(MsgBody)
end

function JumboCactpotExchangeItemView:OnRegisterGameEvent()
end

function JumboCactpotExchangeItemView:OnRegisterBinder()
    self.ViewModel = ExchangeItemVM.New()
    self:RegisterBinders(self.ViewModel, self.Binders)
end

return JumboCactpotExchangeItemView
