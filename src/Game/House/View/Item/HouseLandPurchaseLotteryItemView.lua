---
--- Author: muyanli
--- DateTime: 2025-05-30 20:52
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local HouseLocalDef = require("Game/House/HouseLocalDef")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")

---@class HouseLandPurchaseLotteryItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnLandPurchase UFButton
---@field RedDot CommonRedDotView
---@field TextLottery UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseLandPurchaseLotteryItemView = LuaClass(UIView, true)

function HouseLandPurchaseLotteryItemView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.BtnLandPurchase = nil
    -- self.RedDot = nil
    -- self.TextLottery = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseLandPurchaseLotteryItemView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.RedDot)
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseLandPurchaseLotteryItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnLandPurchase, self.OnBtnLandPurchaseClick)
end

function HouseLandPurchaseLotteryItemView:SetDataInex(Index)
    self.DataInex = Index
    self:SetInfo()
end

function HouseLandPurchaseLotteryItemView:SetInfo()
    local Index = self.DataInex or 1
    self.TextLottery:SetText(HouseLocalDef.SelectInfoTypeData[Index].Name or "")
    self.RedDot:SetRedDotIDByID(HouseLocalDef.SelectInfoTypeData[Index].RedDot)
    -- self.RedDot:SetVisible(Params.Data.RedDotVisible or false)
    if self.DataInex == HouseLocalDef.SelectInfoType.RecycleAssets then
        UIUtil.ImageSetBrushFromAssetPath(self.BtnIcon, "Texture2D'/Game/UI/Texture/Button/Round/UI_Btn_GeneralControls_Delete.UI_Btn_GeneralControls_Delete'")
    else
        UIUtil.ImageSetBrushFromAssetPath(self.BtnIcon, "PaperSprite'/Game/UI/Atlas/House/Frames/UI_House_Btn_LandPurchase_png.UI_House_Btn_LandPurchase_png'")
    end
end

function HouseLandPurchaseLotteryItemView:OnBtnLandPurchaseClick()
    if self.DataInex == HouseLocalDef.SelectInfoType.RecycleAssets then
        _G.UIViewMgr:ShowView(_G.UIViewID.HouseAssetsPanelView)
    else
        local ReturnInfo = _G.HouseLandMianPanelVM.ReturnInfo
        if ReturnInfo ~= nil then
            UIViewMgr:ShowView(UIViewID.HouseThingWinView, ReturnInfo)
        else
            if _G.HouseLandMianPanelVM.LandSelectInfo and _G.HouseLandMianPanelVM.LandSelectInfo[self.DataInex] then
                _G.HouseLandMgr:OpenHouseOrLandPanel(_G.HouseLandMianPanelVM.LandSelectInfo[self.DataInex])
            end
        end
    end
end

return HouseLandPurchaseLotteryItemView
