---
--- Author: muyanli
--- DateTime: 2025-07-14 17:13
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ScoreMgr = require("Game/Score/ScoreMgr")
local HouseLocalDef = require("Game/House/HouseLocalDef")
local UIDefine = require("Define/UIDefine")
local ProtoRes = require("Protocol/ProtoRes")

---@class HouseThingWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm126Slot CommBackpack126SlotView
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field TextDescribe UFTextBlock
---@field TextSlot UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseThingWinView = LuaClass(UIView, true)

function HouseThingWinView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.Comm126Slot = nil
    -- self.Comm2FrameM_UIBP = nil
    -- self.TextDescribe = nil
    -- self.TextSlot = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseThingWinView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.Comm126Slot)
    self:AddSubView(self.Comm2FrameM_UIBP)
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseThingWinView:OnInit()
	self.Comm126Slot:SetNumVisible(false)
	self.Comm126Slot:SetIconReceivedVisible(false)
	self.Comm126Slot:SetIconChooseVisible(false)
end

function HouseThingWinView:OnDestroy()

end

function HouseThingWinView:OnShow()
    if nil == self.Params then
        return
    end
    local Data = self.Params
    if Data.ViewType == ProtoRes.HouseFurnitureFunction.HouseFurnitureFunction_Food then
        self:ShowFoodType(Data)
    else
        self:ShowMoneyType(Data)
    end
end

function HouseThingWinView:OnHide()

end

function HouseThingWinView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.Comm2FrameM_UIBP.Btn1.Button, self.OnClickBtnReciveMoney)
    UIUtil.AddOnClickedEvent(self, self.Comm2FrameM_UIBP.Btn2Right.Button, self.OnClickBtnFoodSure)
    UIUtil.AddOnClickedEvent(self, self.Comm2FrameM_UIBP.Ben2Left.Button, self.OnClickBtnFoodCancel)
end

function HouseThingWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.HouseReciveReturnMoney, self.OnHouseReciveReturnMoney)
end

function HouseThingWinView:OnRegisterBinder()

end

function HouseThingWinView:SetInfo(Data)

end

function HouseThingWinView:ShowMoneyType(Data)
    local IconPath = ScoreMgr:GetScoreIconName(Data.MoneyType)
    local ScoreName = ScoreMgr:GetScoreNameText(Data.MoneyType)
    if IconPath then
        self.Comm126Slot:SetIconImg(IconPath)
    end
    local CurPhaseCnt =  _G.HouseLandMianPanelVM.PhaseCnt
    local SelectInfo = _G.HouseLandMianPanelVM.LandSelectInfo and _G.HouseLandMianPanelVM.LandSelectInfo[HouseLocalDef.BuyHouseBelongType.Personal] or {}
    local LandInfo = SelectInfo.LandInfo

    local BuyStateInfo = _G.HouseLandMianPanelVM.BuyStateInfoShow
    local Describe = string.format(HouseLocalDef.LocalTxtStr.HouseSelectResultTips, Data.PhaseID)
    local ProtoCS = require("Protocol/ProtoCS")
    if LandInfo and CurPhaseCnt == SelectInfo.PhaseID and BuyStateInfo.BuildStatus ~= ProtoCS.BuildStatusType.BuildStatus_Overdue then
        local ApplyNumber = LandInfo.ApplyNumber or ""
        Describe = string.format(HouseLocalDef.LocalTxtStr.HouseSelectFailTips, ApplyNumber)
    end

    self.TextDescribe:SetText(Describe)
    self.TextSlot:SetText(string.format(HouseLocalDef.LocalTxtStr.HouseReturnmoney, ScoreName, Data.ReturnMoney))
    self.Comm2FrameM_UIBP:SetTitleText(HouseLocalDef.LocalTxtStr.HouseSelectResultTitle)
    self.Comm2FrameM_UIBP.Btn1:SetButtonText(HouseLocalDef.LandInfoStr.ReceiveMoney)
    self.Comm2FrameM_UIBP:ChangeBtnShowByType(UIDefine.NameOfBtnType.Btn1)
end

function HouseThingWinView:ShowFoodType(Data)
    local ItemCfg = require("TableCfg/ItemCfg")
    local ItemID = Data.ItemID
    local Cfg = ItemCfg:FindCfgByKey(ItemID)
    local Name = ItemCfg:GetItemName(ItemID)
    local IconPath = UIUtil.GetIconPath(Cfg.IconID)
    if IconPath then
        self.Comm126Slot:SetIconImg(IconPath)
    end
    
    local LeftTime = Data.LeftTime or 0
    self.TextDescribe:SetText(string.format(HouseLocalDef.FurnitureInteractionFood.Desc, LeftTime, Name))
    self.TextSlot:SetText(Name)
    self.Comm2FrameM_UIBP:SetTitleText(HouseLocalDef.FurnitureInteractionFood.Title)

    self.Comm2FrameM_UIBP.Btn2Right:SetButtonText(HouseLocalDef.LocalTxtStr.BtnSure)
    self.Comm2FrameM_UIBP.Ben2Left:SetButtonText(HouseLocalDef.LocalTxtStr.BtnCancel)
    self.Comm2FrameM_UIBP:ChangeBtnShowByType(UIDefine.NameOfBtnType.Btn2)
end

function HouseThingWinView:OnClickBtnReciveMoney()
    _G.HouseLandMgr:GetReturnAssets()
end

function HouseThingWinView:OnHouseReciveReturnMoney()
	self:Hide()
end

function HouseThingWinView:OnClickBtnFoodSure()
    if nil == self.Params then
        return
    end
    _G.FurnitureInteractionMgr:ReqFurnitureFoodEat(self.Params.GID)
    self:Hide()
end

function HouseThingWinView:OnClickBtnFoodCancel()
    self:Hide()
end

return HouseThingWinView
