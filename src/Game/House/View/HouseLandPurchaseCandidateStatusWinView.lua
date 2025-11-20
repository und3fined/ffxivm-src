---
--- Author: muyanli
--- DateTime: 2025-05-30 20:51
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local HouseLocalDef = require("Game/House/HouseLocalDef")
local MajorUtil = require("Utils/MajorUtil")

---@class HouseLandPurchaseCandidateStatusWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field CommHead CommHeadView
---@field TextLandBelong UFTextBlock
---@field TextPersona UFTextBlock
---@field TextTeam UFTextBlock
---@field TextTips UFTextBlock
---@field ToggleBtnArmy UToggleButton
---@field ToggleBtnPersonal UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseLandPurchaseCandidateStatusWinView = LuaClass(UIView, true)

function HouseLandPurchaseCandidateStatusWinView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.Comm2FrameM_UIBP = nil
    -- self.CommHead = nil
    -- self.Text1 = nil
    -- self.Text2 = nil
    -- self.TextPersona = nil
    -- self.TextPersona_1 = nil
    -- self.ToggleBtnArmy = nil
    -- self.ToggleBtnPersonal = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseLandPurchaseCandidateStatusWinView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.Comm2FrameM_UIBP)
    self:AddSubView(self.CommHead)
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseLandPurchaseCandidateStatusWinView:OnInit()

end

function HouseLandPurchaseCandidateStatusWinView:OnDestroy()

end

function HouseLandPurchaseCandidateStatusWinView:OnShow()
    self.CurSelectBelongType = nil
    self.Comm2FrameM_UIBP:SetTitleText(HouseLocalDef.LocalTxtStr.SelectOwnerTitle)
    self.Comm2FrameM_UIBP.Btn2Right:SetBtnName(HouseLocalDef.LocalTxtStr.BtnSure)
    self.Comm2FrameM_UIBP.Ben2Left:SetBtnName(HouseLocalDef.LocalTxtStr.BtnCancel)
    self.CommHead:SetInfo(MajorUtil.GetMajorRoleID())
    self.TextLandBelong:SetText("")
    self.TextTips:SetText(HouseLocalDef.LocalTxtStr.SelectOwnerTips)
    self.TextPersona:SetText(HouseLocalDef.BuyHouseBelongTypeStr[1])
    self.TextTeam:SetText(HouseLocalDef.BuyHouseBelongTypeStr[2])
    self.ToggleBtnPersonal:SetIsChecked(false, true)
    self.ToggleBtnArmy:SetIsChecked(false, true)
    self.Comm2FrameM_UIBP.Btn2Right:SetIsDisabledState(true, true)
end

function HouseLandPurchaseCandidateStatusWinView:OnHide()

end

function HouseLandPurchaseCandidateStatusWinView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.ToggleBtnPersonal, self.OnClickedBtnPersonal)
    UIUtil.AddOnClickedEvent(self, self.ToggleBtnArmy, self.OnClickedBtnArmy)
    UIUtil.AddOnClickedEvent(self, self.Comm2FrameM_UIBP.Btn2Right, self.OnClickedBtnSure)
    UIUtil.AddOnClickedEvent(self, self.Comm2FrameM_UIBP.Ben2Left, self.OnClickedBtnCancel)
end

function HouseLandPurchaseCandidateStatusWinView:OnRegisterGameEvent()

end

function HouseLandPurchaseCandidateStatusWinView:OnRegisterBinder()

end

function HouseLandPurchaseCandidateStatusWinView:OnClickedBtnPersonal()
    self.CurSelectBelongType = HouseLocalDef.BuyHouseBelongType.Personal
    self.Comm2FrameM_UIBP.Btn2Right:SetIsDisabledState(false, true)
    self.ToggleBtnPersonal:SetIsChecked(true, true)
    self.ToggleBtnArmy:SetIsChecked(false, true)
    self.TextLandBelong:SetText(string.format(HouseLocalDef.LocalTxtStr.LandBelongTips,
        HouseLocalDef.LocalTxtStr.LandBelongType1))
    self:PlayAnimation(self.AnimSelect)
end

function HouseLandPurchaseCandidateStatusWinView:OnClickedBtnArmy()
    self.CurSelectBelongType = HouseLocalDef.BuyHouseBelongType.Army
    self.Comm2FrameM_UIBP.Btn2Right:SetIsDisabledState(false, true)
    self.ToggleBtnPersonal:SetIsChecked(false, true)
    self.ToggleBtnArmy:SetIsChecked(true, true)
    self.TextLandBelong:SetText(string.format(HouseLocalDef.LocalTxtStr.LandBelongTips,
        HouseLocalDef.BuyHouseBelongTypeStr[2]))
    self:PlayAnimation(self.AnimSelect)
end

function HouseLandPurchaseCandidateStatusWinView:OnClickedBtnSure()
    if self.CurSelectBelongType == nil then
        _G.MsgTipsUtil.ShowTips(HouseLocalDef.LocalTxtStr.SelectLandBelongTypeTips)
    elseif self.Params~=nil then
        self.Params.ViewModel:OpenSelectSurePanel(self.CurSelectBelongType)
		self:Hide()
    end
end

function HouseLandPurchaseCandidateStatusWinView:OnClickedBtnCancel()
    self:Hide()
end

return HouseLandPurchaseCandidateStatusWinView
