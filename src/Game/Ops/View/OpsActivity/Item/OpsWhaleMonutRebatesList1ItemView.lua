---
--- Author: Administrator
--- DateTime: 2024-12-09 11:07
--- Description:
---


local TaskUIView = require("Game/Ops/View/OpsActivity/Item/OpsActivityList1ItemView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCS = require("Protocol/ProtoCS")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
---@class OpsWhaleMonutRebatesList1ItemView : TaskUIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSlot CommBtnSView
---@field PanelList UFCanvasPanel
---@field TableViewSlot UTableView
---@field TextList UFTextBlock
---@field TextQuantity UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsWhaleMonutRebatesList1ItemView = LuaClass(TaskUIView, true)

function OpsWhaleMonutRebatesList1ItemView:OnInit()
    self.Super.OnInit(self)
    local BinderData = {"BgVisible", UIBinderSetIsVisible.New(self, self.ImgBG)}

    table.insert(self.Binders, BinderData)
end

function OpsWhaleMonutRebatesList1ItemView:OnRegisterSubView()
    self:AddSubView(self.BtnSlot)
end

function OpsWhaleMonutRebatesList1ItemView:OnShow()
	self:SetBtnState()
end

return OpsWhaleMonutRebatesList1ItemView