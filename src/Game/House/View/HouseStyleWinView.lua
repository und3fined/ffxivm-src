---
--- Author: muyanli
--- DateTime: 2025-06-21 11:41
--- Description:
---
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local HouseStyleWinViewVM = require("Game/House/VM/HouseStyleWinViewVM")
local HouseLocalDef = require("Game/House/HouseLocalDef")
local HouseCfg = require("TableCfg/HouseCfg")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local ZoneProtoDownGAME_House = _G.UE.ZoneProtoDownGAME_House
local UHousingMgr = _G.UE.UHousingMgr
local ProtoRes = require("Protocol/ProtoRes")

local CommonUtil = require("Utils/CommonUtil")

---@class HouseStyleWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommBtnS CommBtnSView
---@field CommSidebarFrameS CommSidebarFrameSView
---@field HouseStyleList UTableView
---@field IconMoney UFImage
---@field PanelMoney UFHorizontalBox
---@field TextPrice UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseStyleWinView = LuaClass(UIView, true)

function HouseStyleWinView:Ctor()
    -- AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
    -- self.CommBtnS = nil
    -- self.CommSidebarFrameS = nil
    -- self.HouseStyleList = nil
    -- self.IconMoney = nil
    -- self.PanelMoney = nil
    -- self.TextPrice = nil
    -- AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseStyleWinView:OnRegisterSubView()
    -- AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
    self:AddSubView(self.CommBtnS)
    self:AddSubView(self.CommSidebarFrameS)
    -- AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseStyleWinView:OnInit()
    self.ViewModel = HouseStyleWinViewVM.New()
    self.HouseStyleListAdapter = UIAdapterTableView.CreateAdapter(self, self.HouseStyleList, self.OnSelectChanged, true)
    self.Binders = {{"HouseStyleList", UIBinderUpdateBindableList.New(self, self.HouseStyleListAdapter)}}
end

function HouseStyleWinView:OnDestroy()

end

function HouseStyleWinView:OnShow()
    self.CommSidebarFrameS:SetTitleText(HouseLocalDef.LocalTxtStr.BuildHouseTitle)
    self.CommBtnS.TextContent:SetText(HouseLocalDef.LocalTxtStr.BuildHouse)
    local Params = self.Params
    if nil == Params then
        return
    end

    local LandCondCfg =  require("TableCfg/LandCondCfg")
    local LandSearchCondition = string.format("EstateID=%d and BlockID=%d ", Params.ResidenceNumber, Params.LandNumber)
    local LandCfg = LandCondCfg:FindCfg(LandSearchCondition)
    local SearchConditions = string.format("Size=%d and ResidenceNumber=%d ", LandCfg.Size or 0, Params.ResidenceNumber)
    local Cfg = HouseCfg:FindAllCfg(SearchConditions)
	self.ViewModel.CurSelectIndex = 1
    self.ViewModel:UpdateVM(Cfg)
    local Enough = self.ViewModel:GetBuildCostEnough()
    self.CommBtnS:SetIsDisabledState(not Enough, true)
    self.HouseStyleListAdapter:SetSelectedIndex(1)

    CommonUtil.DisableShowJoyStick(true)
	CommonUtil.HideJoyStick()
end

function HouseStyleWinView:OnHide()    
    self:HidePreShowHouse(self.ViewModel.CurSelectIndex)
    CommonUtil.DisableShowJoyStick(false)
	CommonUtil.ShowJoyStick()
end

function HouseStyleWinView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.CommBtnS, self.OnClickedBtnBuildHouse)
end

function HouseStyleWinView:OnSelectChanged(Index, ItemData, ItemView)
    self.ViewModel.CurSelectIndex = Index
    local Enough = self.ViewModel:GetBuildCostEnough()
    self.CommBtnS:SetIsDisabledState(not Enough, true)
    _G.EventMgr:SendEvent(_G.EventID.BuildHouseResSelected, Index)

    --预览
    self:PreShowHouse(Index)
end

function HouseStyleWinView:PreShowHouse(Index)
    local ItemData = self.ViewModel.HouseStyleList[Index]
    if (ItemData == nil) then
        FLOG_ERROR("HouseStyleWinView: itemdata is nil, index=%d",Index)
        return
    end

    local Cfg = HouseCfg:FindCfg(string.format("ItemIds=%d", tonumber(ItemData.ItemIds)))
    if (Cfg == nil) then
        FLOG_ERROR("HouseStyleWinView: HouseCfg is nil by ItemIds=%d",tonumber(ItemData.ItemIds))
        return
    end

    local HouseData = ZoneProtoDownGAME_House()
    HouseData.Block = self.Params.LandNumber
    HouseData.Size = Cfg.Size
    HouseData.ExteriorIds = _G.UE.TArray(_G.UE.int32)
    HouseData.Colors = _G.UE.TArray(_G.UE.int32)

    for i = 1,8 do
        HouseData.ExteriorIds:Add(0)
        HouseData.Colors:Add(0)
    end    

    --室外屋顶
    HouseData.ExteriorIds[1] = Cfg.InitDoUps[5].ID
    --室外墙壁
    HouseData.ExteriorIds[2] = Cfg.InitDoUps[4].ID
    --室外窗户
    HouseData.ExteriorIds[3] = Cfg.InitDoUps[6].ID
    --室外房门
    HouseData.ExteriorIds[4] = Cfg.InitDoUps[7].ID
    
    --室外墙壁装饰
    --HouseData.ExteriorIds[5] = 4097
    --室外屋顶装饰
    --HouseData.ExteriorIds[6] = 1537    
    --室外门牌装饰
    --HouseData.ExteriorIds[7] = 3585
    --室外院墙装饰
    --HouseData.ExteriorIds[8] = 3585

    local HousingMgrInstance = UHousingMgr:Get()
    if HousingMgrInstance ~= nil then
        HousingMgrInstance:OnUpdateHouse(HouseData)    
    end  

    FLOG_INFO("House PreShow: ItemIds:%s", ItemData.ItemIds)
end

function HouseStyleWinView:HidePreShowHouse(Index)
    local ItemData = self.ViewModel.HouseStyleList[Index]
    if (ItemData == nil) then
        FLOG_ERROR("HouseStyleWinView: itemdata is nil, index=%d",Index)
        return
    end

    local Cfg = HouseCfg:FindCfg(string.format("ItemIds=%d", tonumber(ItemData.ItemIds)))
    if (Cfg == nil) then
        FLOG_ERROR("HouseStyleWinView: HouseCfg is nil by ItemIds=%d",tonumber(ItemData.ItemIds))
        return
    end

    local HouseData = ZoneProtoDownGAME_House()
    HouseData.Block = self.Params.LandNumber    
    HouseData.Size = Cfg.Size
    HouseData.ExteriorIds = _G.UE.TArray(_G.UE.int32)
    HouseData.Colors = _G.UE.TArray(_G.UE.int32)

    for i = 1,8 do
        HouseData.ExteriorIds:Add(0)
        HouseData.Colors:Add(0)
    end    

    local HousingMgrInstance = UHousingMgr:Get()
    if HousingMgrInstance ~= nil then
        HousingMgrInstance:OnUpdateHouse(HouseData)    
    end 
end


function HouseStyleWinView:OnRegisterGameEvent()

end

function HouseStyleWinView:OnRegisterBinder()
    self:RegisterBinders(self.ViewModel, self.Binders)
end

function HouseStyleWinView:OnClickedBtnBuildHouse()
    local HouseType = 1
    local HasPrivilege = true

    if _G.HouseLandMgr.GroupHasLandNoBuild() then
        HouseType = HouseLocalDef.BuyHouseBelongType.Army
        HasPrivilege = _G.ArmyMgr:GetSelfIsHavePermisstion(ProtoRes.GroupPermissionType.PermissionTypeEstatePurchaseLandAndBuild)
    end

    local Enough = self.ViewModel:GetBuildCostEnough()
    if not Enough then
        _G.MsgTipsUtil.ShowTips(HouseLocalDef.LocalTxtStr.BuildHouseItemNotEnough)
    elseif not HasPrivilege then
        _G.MsgTipsUtil.ShowTips(HouseLocalDef.LocalTxtStr.NoBuildHousePrivilege)
    elseif self.Params and self.ViewModel and self.ViewModel.HouseStyleList and
        self.ViewModel.HouseStyleList[self.ViewModel.CurSelectIndex] then
        local ItemData = self.ViewModel.HouseStyleList[self.ViewModel.CurSelectIndex]
        local Params = {
            ResidenceNumber = self.Params.ResidenceNumber,
            AreaNumber = self.Params.AreaNumber,
            LandNumber = self.Params.LandNumber,
            HouseType = HouseType,
            ResID = ItemData.ID,
            ItemID = tonumber(ItemData.ItemIds)
        }
        _G.HouseLandMgr:SendBuildHouseReq(Params)
		self:Hide()
    end
end

return HouseStyleWinView
