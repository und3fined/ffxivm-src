---
--- Author: muyanli
--- DateTime: 2025-06-06 11:12
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local HouseLocalDef = require("Game/House/HouseLocalDef")
local ProtoCS = require("Protocol/ProtoCS")
local RoleInfoMgr = require("Game/Role/RoleInfoMgr")
local TipsUtil = require("Utils/TipsUtil")
local MathUtil = require("Utils/MathUtil")
local HouseFlagCfg = require("TableCfg/HouseFlagCfg")
local CommonUtil = require("Utils/CommonUtil")
---@class HouseLocationListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCheck UFButton
---@field BtnIcon UFButton
---@field BtnPurchase UFButton
---@field BtnTag1 UFButton
---@field BtnTag2 UFButton
---@field BtnTag3 UFButton
---@field HouseStateIcon UFImage
---@field IconHide UFImage
---@field IconMoney UFImage
---@field IconTag1 UFImage
---@field IconTag2 UFImage
---@field IconTag3 UFImage
---@field PanelLike UFCanvasPanel
---@field PriceBox UFHorizontalBox
---@field TextHousingLocation UFTextBlock
---@field TextLike UFTextBlock
---@field TextName UFTextBlock
---@field TextPrice UFTextBlock
---@field TextSerialNumber UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseLocationListItemView = LuaClass(UIView, true)

function HouseLocationListItemView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.FButton_155 = nil
    -- self.IconHide = nil
    -- self.IconTag1 = nil
    -- self.IconTag2 = nil
    -- self.IconTag3 = nil
    -- self.TextHousingLocation = nil
    -- self.TextLike = nil
    -- self.TextName = nil
    -- self.TextSerialNumber = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseLocationListItemView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseLocationListItemView:OnInit()

end

function HouseLocationListItemView:OnDestroy()

end

function HouseLocationListItemView:OnShow()

end

function HouseLocationListItemView:OnHide()

end

function HouseLocationListItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnPurchase, self.OnBtnPurchaseClicked)
    UIUtil.AddOnClickedEvent(self, self.BtnCheck, self.OnBtnCheckClicked)
    UIUtil.AddOnClickedEvent(self, self.BtnIcon, self.OnBtnIconClicked)
    UIUtil.AddOnClickedEvent(self, self.BtnIcon, self.OnBtnIconClicked)
    for i = 1, 3 do
        UIUtil.AddOnClickedEvent(self, self["BtnTag" .. i], self.OnBtnIconTagClicked, i)
    end
end


function HouseLocationListItemView:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.DoLikeRsp, self.OnHouseListDoLike)
end

function HouseLocationListItemView:OnHouseListDoLike(Data)
    if self.ViewModel and self.ViewModel.HouseID then
        if self.ViewModel.HouseID == Data.HouseID then
            self.ViewModel.BeLikeNum  = Data.IsLike and self.ViewModel.BeLikeNum + 1 or self.ViewModel.BeLikeNum - 1
            self.TextLike:SetText(self.ViewModel.BeLikeNum)
        end
    end
end

function HouseLocationListItemView:OnRegisterBinder()
    local Params = self.Params
    if nil == Params then
        return
    end

    self.ViewModel = Params.Data
    if nil == self.ViewModel then
        return
    end

    self.TextSerialNumber:SetText(string.format(HouseLocalDef.LocationInfoStr.LandNumName, self.ViewModel.LandNumber,
        HouseLocalDef.LandSizeTypeStr[self.ViewModel.LandSize]))
    self.TextLike:SetText(self.ViewModel.BeLikeNum)

    local HouseInfoDesc = self.ViewModel.Greeting or ""
    local IconHideVisible = false
    local PriceBoxVisible = false
    local IsLand = self.ViewModel.LandStatus < ProtoCS.LandStatusType.LandStatusType_Built
    if IsLand then
        PriceBoxVisible = true
        HouseInfoDesc = ""
        UIUtil.ImageSetBrushFromAssetPath(self.IconMoney, _G.ScoreMgr:GetScoreIconName(self.ViewModel.MoneyType))
        self.TextPrice:SetText(self.ViewModel.Price)
    end
    UIUtil.SetIsVisible(self.BtnCheck, not IsLand, not IsLand)
    UIUtil.SetIsVisible(self.BtnPurchase, IsLand, IsLand)
    UIUtil.SetIsVisible(self.PriceBox, PriceBoxVisible)
    UIUtil.SetIsVisible(self.PanelLike, not IsLand)
    UIUtil.SetIsVisible(self.TextName, not IsLand)
    if not IsLand then
        if self.ViewModel.GroupID and self.ViewModel.GroupID ~= 0 then
            if _G.ArmyMgr.SelfArmyID == self.ViewModel.GroupID then
                local MajorUtil = require("Utils/MajorUtil")
                _G.ArmyMgr:GetArmySimpleDataByRoleIDs({MajorUtil:GetMajorRoleID()}, function(MsgBody)
                    if MsgBody and #MsgBody > 0 then
                        local ArmyInfo = MsgBody[1].Simple
                        local ArmyName = CommonUtil.GetTextFromStringWithSpecialCharacter(ArmyInfo.Name .. " <10006>" .. ArmyInfo.Alias .. "<10007>")
                        self.TextName:SetText(ArmyName)
                    end
                end)
            else
                _G.ArmyMgr:QueryArmySimple(self.ViewModel.GroupID, function(VM)
                    if VM then
                        local ArmyName = CommonUtil.GetTextFromStringWithSpecialCharacter(VM.Name .. " <10006>" .. VM.ShortName .. "<10007>")
                        self.TextName:SetText(ArmyName)
                    end
                end)
            end
        else
            if self.ViewModel.Owner and self.ViewModel.Owner ~= 0 then
                RoleInfoMgr:QueryRoleSimple(self.ViewModel.Owner, function(_, RoleVM)
                    self.TextName:SetText(RoleVM and RoleVM.Name or "")
                end)
            end
        end
    end

    self.TextHousingLocation:SetText(HouseInfoDesc)
    UIUtil.SetIsVisible(self.IconHide, IconHideVisible, false)
    local HouseInfo = _G.HouseLandMgr:GetHouseStateInfo(self.ViewModel)
    if HouseInfo then
        UIUtil.ImageSetBrushFromAssetPath(self.HouseStateIcon, HouseInfo.IconPath)
    end
    self:SetHouseTagIcons()
end

function HouseLocationListItemView:OnBtnPurchaseClicked()
    if nil == self.ViewModel then
        return
    end
    _G.HouseLandMgr:OpenHouseOrLandPanel(self.ViewModel)
end

function HouseLocationListItemView:OnBtnCheckClicked()
    if self.ViewModel and self.ViewModel.HouseID then
        _G.HouseInfoMgr:OpenOthersHouseInfoPanel(self.ViewModel.HouseID)
    end
end

function HouseLocationListItemView:OnBtnIconClicked()
    local HouseInfo = _G.HouseLandMgr:GetHouseStateInfo(self.ViewModel)
    if HouseInfo then
        TipsUtil.ShowInfoTips(HouseInfo.Tips, self.BtnIcon,_G.UE.FVector2D(0, 0), _G.UE.FVector2D(0.5,1))
    end
end

function HouseLocationListItemView:SetHouseTagIcons()
    if nil == self.ViewModel then
        return
    end

    local Tags = MathUtil.DecodeUint(self.ViewModel.Tags, HouseLocalDef.HouseTagNumLimit)
    for i = 1, 3 do
        local hasTag = Tags[i]~= nil and  Tags[i] > 0
        UIUtil.SetIsVisible(self["BtnTag" .. i], hasTag, hasTag);
        if hasTag then
            UIUtil.ImageSetBrushFromAssetPath(self["IconTag" .. i],
            string.format(HouseLocalDef.LocationHouseTagIconPath, Tags[i], Tags[i]))
        end
    end
end

function HouseLocationListItemView:OnBtnIconTagClicked(Index)
    local Tags = MathUtil.DecodeUint(self.ViewModel.Tags, HouseLocalDef.HouseTagNumLimit)
    local TagID = Tags[Index]
    local TagCfg = HouseFlagCfg:FindCfgByKey(TagID)
    if TagCfg then
        local Item = self["BtnTag" .. Index]
        local ItemSize = UIUtil.GetWidgetSize(Item)
        TipsUtil.ShowInfoTips(TagCfg.FlagName, Item, _G.UE.FVector2D((ItemSize.X/2.0)-10, (ItemSize.Y/2.0)-10), _G.UE.FVector2D(1,1))
    end
end

return HouseLocationListItemView
