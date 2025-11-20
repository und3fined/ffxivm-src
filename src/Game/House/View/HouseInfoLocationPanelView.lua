---
--- Author: muyanli
--- DateTime: 2025-06-20 10:09
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local HouseLocalDef = require("Game/House/HouseLocalDef")
local TipsUtil = require("Utils/TipsUtil")

---@class HouseInfoLocationPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnTeleport CommBtnLView
---@field HouseMineBG_UIBP HouseMineBGView
---@field TableViewList UTableView
---@field TextHousingLocation UFTextBlock
---@field TextLike UFTextBlock
---@field TextName UFTextBlock
---@field TextSerialNumber UFTextBlock
---@field TextTag UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseInfoLocationPanelView = LuaClass(UIView, true)

function HouseInfoLocationPanelView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.HouseMineBG_UIBP = nil
    -- self.TableViewList = nil
    -- self.TextHousingLocation = nil
    -- self.TextLike = nil
    -- self.TextName = nil
    -- self.TextSerialNumber = nil
    -- self.TextTag = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseInfoLocationPanelView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.HouseMineBG_UIBP)
    self:AddSubView(self.BtnTeleport)
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseInfoLocationPanelView:OnInit()
    self.ResidenceNumber = 1
    self.CurSelectedSubArea = 1
    self.CurSelectedArea = 1
    self.TextSerialNumber:SetText(HouseLocalDef.LocationInfoStr.TextSerialNumber)
    self.TextName:SetText(HouseLocalDef.LocationInfoStr.TextName)
    self.TextHousingLocation:SetText(HouseLocalDef.LocationInfoStr.TextHousingLocation)
    self.TextTag:SetText(HouseLocalDef.LocationInfoStr.TextTag)
    self.TextLike:SetText(HouseLocalDef.LocationInfoStr.TextLike)
    self.BtnTeleport:SetText(HouseLocalDef.LandInfoStr.Transmit)
    self.TableViewListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList)
end

function HouseInfoLocationPanelView:OnDestroy()

end

function HouseInfoLocationPanelView:OnShow()
    self.HouseMineBG_UIBP:SetCommTabInfo(HouseLocalDef.SubAreaTypeStr, self.OnCommTabChange, self.CurSelectedSubArea,self)
    if self.Params and self.Params.ResidenceNumber then
        local EstateInfo = _G.HouseLandMianPanelVM:GetEstateInfo(self.Params.ResidenceNumber)
        if EstateInfo then
            self.HouseMineBG_UIBP:SetTitleInfo(EstateInfo.EstateName, 11213)
        end
        self.ResidenceNumber = self.Params.ResidenceNumber
        local IsUnlock = _G.HouseLandMianPanelVM:GetEstateIsUnlock(self.ResidenceNumber) or self.Params.IsIgnoreUnlock

        self.BtnTeleport:SetIsDisabledState(not IsUnlock, true)
        self.CurSelectedArea = 1
        _G.HouseLandMgr:SendLandQueryArea(self.ResidenceNumber, self.CurSelectedArea, self.CurSelectedSubArea, 0, {},
            HouseLocalDef.LandQuerySceneType.HouseList)
    end
end

function HouseInfoLocationPanelView:OnHide()
    self.HasSetAreaTabView = false
end

function HouseInfoLocationPanelView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnTeleport, self.OnBtnTeleportClicked)
end

function HouseInfoLocationPanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.HouseListLocationUpdate, self.OnHouseListLocationUpdate)
    self:RegisterGameEvent(_G.EventID.HouseTransAreaChange, self.OnTransSuccess)
end

function HouseInfoLocationPanelView:OnRegisterBinder()

end

function HouseInfoLocationPanelView:OnHouseListLocationUpdate(Data)
    if Data == nil or self.Params == nil then
        return
    end
   
    self:SetAreaTabView()
    self.TableViewListAdapter:UpdateAll(Data)
end

function HouseInfoLocationPanelView:OnTransSuccess()
    self:Hide()
end

function HouseInfoLocationPanelView:SetAreaTabView()
    if not self.HasSetAreaTabView then
        local TabList = {}
        local ReleaseLandNum = _G.HouseLandMgr:GetReleaseLand(self.ResidenceNumber)
        if ReleaseLandNum == nil or ReleaseLandNum <= 0 then
            ReleaseLandNum = 1
        end
        local SubTabNum = HouseLocalDef.LocationAreaSubTabNum
        local TabNum = math.floor(ReleaseLandNum / SubTabNum)
        local LastSubTabNum = ReleaseLandNum - TabNum * SubTabNum
        TabNum = LastSubTabNum > 0 and TabNum + 1 or TabNum
        for i = 1, TabNum do
            local SubList = {}
            SubList.Key = (i - 1) * SubTabNum + i
            SubList.Name = string.format(HouseLocalDef.LocationInfoStr.Tab, (i - 1) * SubTabNum + 1, i * SubTabNum)
            SubList.Children = {}
            local SubListNum = (LastSubTabNum > 0 and i == TabNum) and LastSubTabNum or SubTabNum
            for j = 1, SubListNum do
                local TabSubList = {}
                local AreaNumber = (i - 1) * SubTabNum + j
                TabSubList.Key = SubList.Key + j
                TabSubList.Name = string.format(HouseLocalDef.LocationInfoStr.SubTab, AreaNumber)
                TabSubList.ExtraData = AreaNumber
                table.insert(SubList.Children, TabSubList)
            end
            table.insert(TabList, SubList)
        end
        self.HouseMineBG_UIBP:SetTabView(TabList, 1)
        self.HouseMineBG_UIBP:SetOnSelectionChangedCallback(self.OnSelectionChanged,self)
        self.HasSetAreaTabView = true
    end
end

function HouseInfoLocationPanelView:OnCommTabChange(Index)
    self.CurSelectedSubArea = Index
    _G.HouseLandMgr:SendLandQueryArea(self.ResidenceNumber, self.CurSelectedArea, self.CurSelectedSubArea, 0, {},
        HouseLocalDef.LandQuerySceneType.HouseList)
end

function HouseInfoLocationPanelView:OnBtnTeleportClicked()
    if self.Params then
        local EstateCfg = _G.HouseLandMianPanelVM:GetEstateCfg()
        local EstateInfo = EstateCfg[self.ResidenceNumber]
        if EstateInfo then
            local IsIgnoreUnlock = self.Params.IsIgnoreUnlock 
            local IsUnlock = _G.HouseLandMianPanelVM:GetEstateIsUnlock(self.ResidenceNumber) or IsIgnoreUnlock
            if IsUnlock then
                local Params = {
                    ResidenceNumber = self.ResidenceNumber,
                    AreaNumber = self.CurSelectedArea
                }
                _G.HouseLandMgr:SendLandTransmit(HouseLocalDef.LandTransmitType.Residence, Params)
            else
                local Content = require("TableCfg/SysnoticeCfg"):FindCfgByKey(EstateInfo.LockTipsID).Content[1]
                if Content then
                    TipsUtil.ShowTaskUnlockTips(Content, EstateInfo.UnLockTaskID, self.BtnTeleport,
                    _G.UE.FVector2D(-5, 0), _G.UE.FVector2D(1, 1))
                end
            end
        end
    end
end

function HouseInfoLocationPanelView:OnSelectionChanged(Index, ItemData, ItemView)
    if ItemData.ExtraData ~= nil then
        _G.EventMgr:SendEvent(EventID.HouseMineBGLocationAni, {EstateID = self.ResidenceNumber})
        self.CurSelectedArea = ItemData.ExtraData
        _G.HouseLandMgr:SendLandQueryArea(self.ResidenceNumber, self.CurSelectedArea, self.CurSelectedSubArea, 0, {},
            HouseLocalDef.LandQuerySceneType.HouseList)
    end
end

return HouseInfoLocationPanelView
