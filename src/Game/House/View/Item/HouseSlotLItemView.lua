---
--- Author: skysong
--- DateTime: 2025-05-06 15:01
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromIconID = require("Binder/UIBinderSetBrushFromIconID")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local HouseCommon = require("Game/House/HouseCommon")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local HouseUtil = require("Game/House/HouseUtil")
local HouseMainPanelVM = require("Game/House/VM/HouseMainPanelVM")

local GestureMgr = _G.UE.UGestureMgr
local UHousingMgr = _G.UE.UHousingMgr


---@class HouseSlotLItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgSelect UFImage
---@field ImgSlot UFImage
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseSlotLItemView = LuaClass(UIView, true)

function HouseSlotLItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgSelect = nil
	--self.ImgSlot = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
    self.TouchDown = false
    self.PointerIndex = -1
    self.TouchMove = false
end

function HouseSlotLItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseSlotLItemView:OnInit()
    self.Binders = {
        { "Name", UIBinderSetText.New(self, self.TextName) },
        { "IsSelect", UIBinderSetIsVisible.New(self, self.ImgSelect) },
        { "Icon", UIBinderSetBrushFromIconID.New(self, self.ImgSlot) },
    }
end

function HouseSlotLItemView:OnDestroy()

end

function HouseSlotLItemView:OnShow()

end

function HouseSlotLItemView:OnHide()

end

function HouseSlotLItemView:OnRegisterUIEvent()

end

function HouseSlotLItemView:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonUp, self.OnPreprocessedMouseButtonUp)
    self:RegisterGameEvent(_G.EventID.PreprocessedMouseMove, self.OnPreprocessedMouseMove)
end

function HouseSlotLItemView:OnRegisterBinder()
    local Params = self.Params
    if nil == Params then return end
    local ViewModel = Params.Data
    if nil == ViewModel then return end
    if ViewModel then
        self.ViewModel = ViewModel
        self:RegisterBinders(ViewModel, self.Binders)
    end
end

function HouseSlotLItemView:OnCreateTemporaryHosingObject()
    local HouseRegionCfg = _G.HousingMgr:GetHouseRegionCfg()
    local FurnitureList = _G.HousingMgr:GetFurnitureList(_G.HousingMgr.HouseID,_G.HousingMgr.Region)

    if FurnitureList ~= nil then
        if HouseRegionCfg ~= nil then
            --满了不能再放了
            if #FurnitureList.Entities == HouseRegionCfg.FurnitureLimit then
                MsgTipsUtil.ShowTips(LSTR(1640074))
            else
                local Cfg = HouseUtil.GetHousePartsCfg(self.ViewModel.ResID)

                if Cfg ~= nil then
                    local HousingMgrInstance = UHousingMgr:Get()
                    if HousingMgrInstance ~= nil then
                        HousingMgrInstance:executePlace(self.ViewModel.GID,Cfg.ID,Cfg.Category,5)
                        _G.HousingMgr.TemporaryHosingObjectGID = self.ViewModel.GID
                        _G.HousingMgr.TemporaryHosingObjectResID = self.ViewModel.ResID
                        HouseMainPanelVM.PanelMainVisible = false
                    end
                end
            end
        end
    end
end

function HouseSlotLItemView:OnTouchStarted(InGeometry, InTouchEvent)
    --FLOG_INFO("HouseSlotLItemView:TouchStart")
    local HouseModel = _G.HousingMgr:GetHouseModel()
    local TabIndex = HouseMainPanelVM:GetTabSelectIndex()

    --只有背包和仓库才可以拖动
    if TabIndex == HouseCommon.SelectHouseLeftBarType.Bag or TabIndex == HouseCommon.SelectHouseLeftBarType.StoreHouse then
        if HouseModel == HouseCommon.HouseModel.FurnitureModel or HouseModel == HouseCommon.HouseModel.YardModel then
            self.PointerIndex = UE.UKismetInputLibrary.PointerEvent_GetPointerIndex(InTouchEvent)
            self.TouchDown = true
            self.TouchMove = false
            _G.UE.ClickFeedbackInteraction.Get():EnableSendMoveEvent(true)
        end
    end

    return _G.UE.UWidgetBlueprintLibrary.Handled()
end

function HouseSlotLItemView:OnMouseLeave(InTouchEvent)
    if self.TouchDown then
        --FLOG_INFO("HouseSlotLItemView:MouseLeave")
        local AbsMousePos = _G.UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)
        local PlayerController = _G.GameplayStaticsUtil.GetPlayerController()
        local ScreenPos = _G.UE.FVector2D(AbsMousePos.X, AbsMousePos.Y)
        local WorldPosition = _G.UE.FVector()
        local WorldDirection = _G.UE.FVector()
        local LocalMousePos, ViewportMousePos = UIUtil.AbsoluteToViewport(AbsMousePos)
        _G.UE.UGameplayStatics.DeprojectScreenToWorld(PlayerController, LocalMousePos, WorldPosition, WorldDirection)
    end
end

function HouseSlotLItemView:OnPreprocessedMouseMove(InTouchEvent)
    local PointerIndex = UE.UKismetInputLibrary.PointerEvent_GetPointerIndex(InTouchEvent)

    if self.TouchDown == true and self.PointerIndex == PointerIndex then
        local AbsMousePos = _G.UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)
        --local SelfGeometry = _G.UE.UWidgetLayoutLibrary.GetViewportWidgetGeometry(self)
        --local CurPos = _G.UE.USlateBlueprintLibrary.AbsoluteToLocal(SelfGeometry, AbsMousePos)

        local IsUnder = UIUtil.IsUnderLocation(self.ParentView, AbsMousePos)
        if not IsUnder then

            if not self.TouchMove then
                self:OnCreateTemporaryHosingObject()
                self.TouchMove = true
                _G.HousingMgr:SetEnableCameraMove(false)
            end


            --local LocalMousePos, ViewportMousePos = UIUtil.AbsoluteToViewport(AbsMousePos)
            --local WorldPosition = _G.UE.FVector()
            --local WorldDirection = _G.UE.FVector()
            --local PlayerController = _G.GameplayStaticsUtil.GetPlayerController()
            --_G.UE.UGameplayStatics.DeprojectScreenToWorld(PlayerController, LocalMousePos, WorldPosition, WorldDirection)

            --要把加入到GestureMgr中的touch干掉
            --if CommonUtil.GetPlatformName() == "IOS" then
            GestureMgr:Get():RemoveDataMapForLua(PointerIndex)
            --end
        end
    end
end

function HouseSlotLItemView:OnPreprocessedMouseButtonUp(InTouchEvent)
    local PointerIndex = UE.UKismetInputLibrary.PointerEvent_GetPointerIndex(InTouchEvent)

    if self.TouchDown and self.PointerIndex == PointerIndex and self.TouchMove then
        --FLOG_INFO("HouseSlotLItemView:TouchEnd")
        _G.UE.ClickFeedbackInteraction.Get():EnableSendMoveEvent(false)
        local HousingMgrInstance = UHousingMgr:Get()
        if HousingMgrInstance ~= nil then
            HousingMgrInstance:SetMouseEnterReleased()
        end
        HouseMainPanelVM.PanelMainVisible = true
        _G.HousingMgr:SetEnableCameraMove(true)
    end

    if self.PointerIndex == PointerIndex then
        self.TouchDown = false
        self.PointerIndex = -1
        self.TouchMove = false
    end
end

function HouseSlotLItemView:UpdatePrey(IsGrey)
    UIUtil.SetImageDesaturate(self.ImgSlot, nil, IsGrey and 1 or 0)
end


return HouseSlotLItemView