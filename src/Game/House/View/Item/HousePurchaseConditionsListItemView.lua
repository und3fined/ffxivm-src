---
--- Author: muyanli
--- DateTime: 2025-05-30 20:52
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local HouseLocalDef = require("Game/House/HouseLocalDef")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local CommonBoxDefine = require("Game/CommMsg/CommonBoxDefine")
local ProtoCS = require("Protocol/ProtoCS")

---@class HousePurchaseConditionsListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommBtn CommBtnSView
---@field IconCancel UFImage
---@field IconCheck UFImage
---@field ImgBG UFImage
---@field Text UFTextBlock
---@field TextTips UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HousePurchaseConditionsListItemView = LuaClass(UIView, true)

function HousePurchaseConditionsListItemView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.CommBtn = nil
    -- self.IconCancel = nil
    -- self.IconCheck = nil
    -- self.ImgBG = nil
    -- self.Text = nil
    -- self.TextTips = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HousePurchaseConditionsListItemView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.CommBtn)
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HousePurchaseConditionsListItemView:OnInit()

end

function HousePurchaseConditionsListItemView:OnDestroy()

end

function HousePurchaseConditionsListItemView:OnShow()

end

function HousePurchaseConditionsListItemView:OnHide()

end

function HousePurchaseConditionsListItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.CommBtn, self.OnCommBtnClicked)
end

function HousePurchaseConditionsListItemView:OnRegisterGameEvent()

end

function HousePurchaseConditionsListItemView:OnRegisterBinder()
    local Params = self.Params
    if nil == Params or Params.Data == nil then
        return
    end

    local HouseID = Params.Data.HouseID
    local IsPass = false
    _G.HouseLandMianPanelVM:SetHouseOpCondition(HouseID)
    if Params.Data.ID ~= nil then
        local data = _G.HouseLandMianPanelVM.AllBuyConditions[Params.Data.ID]
        IsPass = data ~= nil and data.IsPass or false
    elseif Params.Data.HouseOpType ~= nil then
        local data = _G.HouseLandMianPanelVM.AllHouseOpConditions[Params.Data.HouseOpType][Params.Index]
        IsPass = data ~= nil and data.IsPass or false
    end
    local Param = Params.Data.Param
    local desc = Params.Data.Desc
    if Param ~= nil and Param ~= 0 then
        desc = string.format(Params.Data.Desc, Param)
    end
    local HasBtn = Params.Data.BtnName ~= nil and Params.Data.BtnName ~= ""
    if HasBtn then
        self.TextTips:SetText(desc)
    else
        self.Text:SetText(desc)
    end
    UIUtil.SetIsVisible(self.Text, not HasBtn)
    UIUtil.SetIsVisible(self.TextTips, HasBtn)
    UIUtil.SetIsVisible(self.IconCheck, IsPass and not HasBtn)
    UIUtil.SetIsVisible(self.IconCancel, not IsPass and not HasBtn)
    UIUtil.SetIsVisible(self.CommBtn, HasBtn)
    self.CommBtn:SetText(Params.Data.BtnName)
    if HasBtn then
        local AllPass = _G.HouseLandMianPanelVM:GetHouseOpConditionAllPass(Params.Data.HouseOpType, HouseID)
        if Params.Data.HouseOpType and Params.Data.HouseOpType == HouseLocalDef.HouseOpType.Destory then
            if _G.HouseInfoMgr:IsCurHouseLandCanGiveUp(HouseID) then
                self.CommBtn:SetIsDisabledState(true, false)
            else
                self.CommBtn:SetIsDisabledState(not AllPass, true)
            end
        else
            self.CommBtn:SetIsDisabledState(not AllPass, true)
        end
    end
end

function HousePurchaseConditionsListItemView:OnCommBtnClicked()
    local Params = self.Params 
    if not Params or not Params.Data then return end

    local HouseType = Params.Data.HouseType
    local HouseID = Params.Data.HouseID
    local HouseOpType = Params.Data.HouseOpType
    local AllPass = _G.HouseLandMianPanelVM:GetHouseOpConditionAllPass(HouseOpType, HouseID)
    local HouseOpTipsData = HouseLocalDef.HouseOpTipsData[HouseOpType]

    if AllPass then
        local MsgBoxParams = {
            TextAlignment = CommonBoxDefine.TextAlignment.Left,
            bUseNever = true,
            NeverMindText = HouseOpTipsData.AgreeCheck,
            CheckBoxSetRightBtnDisableState = true,
            bUseOnLeftTimeClose = false,
        }
        local Content = HouseOpTipsData.AgreeTips.."\n"..HouseOpTipsData.SureTipsPersonal
        if HouseType == ProtoCS.HouseType.HouseType_HouseType_Group and HouseOpTipsData.SureTipsGroup then
           Content =  Content.."\n"..HouseOpTipsData.SureTipsGroup
        end

        MsgBoxUtil.ShowMsgBoxMTwoOp(nil, HouseOpTipsData.Title, Content, function(View,Result)
            if Result and not Result.IsNeverAgain then
                _G.MsgTipsUtil.ShowTips(HouseOpTipsData.AgreeCheckTips)
            else
                if HouseOpType == HouseLocalDef.HouseOpType.Destory then
                    -- local CurlandHouseID = _G.HouseLandMgr:GetCurLandHouseID()
                    -- if CurlandHouseID == HouseID then
                    --     _G.MsgTipsUtil.ShowTips(HouseOpTipsData.DesHasPlayerInRange)
                    -- else
                    -- end
                    _G.HouseLandMgr:SendDestroyHouseReq(HouseID)
                elseif HouseOpType == HouseLocalDef.HouseOpType.GiveUpLand then
                    local function SendAbandonLandReq(Basic)
                        if not Basic or not next(Basic) then
                            FLOG_ERROR("Empty Basic to SendAbandonLandReq")
                        else
                            local LandInfo = {
                                WorldID = Basic.WorldID or 0,
                                ResidenceNumber = Basic.Addr and Basic.Addr.EstateID or 1,
                                AreaNumber = Basic.Addr and Basic.Addr.Area or 1,
                                LandNumber = Basic.Addr and Basic.Addr.Number or 1
                            }
                            _G.HouseLandMgr:SendAbandonLandReq(LandInfo)
                        end
                    end

                    local HouseDetail = _G.HouseInfoMgr.CacheHouseDetailInfo[HouseID]
                    if next(HouseDetail) then
                        local Basic = HouseDetail.Basic
                        SendAbandonLandReq(Basic)
                    else
                        _G.HouseInfoMgr:QueryHouseDetail(HouseID, function(Basic, Roommates)
                            SendAbandonLandReq(Basic)
                        end)
                    end
                end
                MsgBoxUtil.CloseMsgBoxM()
            end
        end, function()
            MsgBoxUtil.CloseMsgBoxM()
        end, LSTR(10003), LSTR(10002), MsgBoxParams)

    end
    if not AllPass then
        _G.MsgTipsUtil.ShowTips(HouseOpTipsData.CannotTips)
    end
end

return HousePurchaseConditionsListItemView
