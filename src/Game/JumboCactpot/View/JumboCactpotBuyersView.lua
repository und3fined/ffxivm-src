---
--- Author: user
--- DateTime: 2023-03-02 14:54
--- Description:仙人仙彩购买人数界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
-- local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

local LSTR = _G.LSTR
local JumboCactpotMgr = _G.JumboCactpotMgr
---@class JumboCactpotBuyersView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameSView
---@field FText_Plus UFTextBlock
---@field FText_Stage UFTextBlock
---@field FText_Total UFTextBlock
---@field PopUpBG CommonPopUpBGView
---@field TableView_List UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JumboCactpotBuyersView = LuaClass(UIView, true)

function JumboCactpotBuyersView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    --self.BG = nil
    --self.FText_Plus = nil
    --self.FText_Stage = nil
    --self.FText_Total = nil
    --self.PopUpBG = nil
    --self.TableView_List = nil
    --AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JumboCactpotBuyersView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.BG)
    self:AddSubView(self.PopUpBG)
    --AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JumboCactpotBuyersView:OnInit()
    self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableView_List)
end

function JumboCactpotBuyersView:OnDestroy()
end

function JumboCactpotBuyersView:OnShow()
    self.BoughtNum = JumboCactpotMgr:GetBoughtNum()
    self.BuyersItemsInfos = JumboCactpotMgr:GetBuyersItemsInfos()
    self.FText_Total:SetText(self.BoughtNum)
    self.FText_Stage:SetText(string.format(LSTR(240051), JumboCactpotMgr.StageNum)) -- 第%d阶段已开启
    self.TableViewAdapter:UpdateAll(self.BuyersItemsInfos)
end

function JumboCactpotBuyersView:OnHide()
end

function JumboCactpotBuyersView:OnRegisterUIEvent()
end

function JumboCactpotBuyersView:OnRegisterGameEvent()
end

function JumboCactpotBuyersView:OnRegisterBinder()
end

return JumboCactpotBuyersView
