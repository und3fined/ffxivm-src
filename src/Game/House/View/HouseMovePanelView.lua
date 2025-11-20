---
--- Author: skysong
--- DateTime: 2025-05-06 15:09
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local HouseMovePanelVM = require("Game/House/VM/HouseMovePanelVM")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetVisibility = require("Binder/UIBinderSetVisibility")
local UIBinderSetSlider = require("Binder/UIBinderSetSlider")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local ItemCfg = require("TableCfg/ItemCfg")
local HouseCommon = require("Game/House/HouseCommon")
local UIDefine = require("Define/UIDefine")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ProtoCS = require("Protocol/ProtoCS")
local CommBtnColorType = UIDefine.CommBtnColorType
local LSTR = _G.LSTR
local UE = _G.UE
local UHousingMgr = _G.UE.UHousingMgr

---@class HouseMovePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAdd UFButton
---@field BtnBag UFButton
---@field BtnL UFButton
---@field BtnOK UFButton
---@field BtnR UFButton
---@field BtnSub UFButton
---@field BtnWarehouse UFButton
---@field BtnX UFButton
---@field IconBagDisab UFImage
---@field IconBagNormal UFImage
---@field IconOK UFImage
---@field IconOKDisab UFImage
---@field IconWarehouseDisab UFImage
---@field IconWarehouseNormal UFImage
---@field ImgAdd UFImage
---@field ImgL UFImage
---@field ImgProgressBarBg UFImage
---@field ImgProgressBarBg2 UFImage
---@field ImgR UFImage
---@field ImgSub UFImage
---@field PanelHeight UFCanvasPanel
---@field PanelRotate UFCanvasPanel
---@field ProgressBar UProgressBar
---@field ProgressBar2 UProgressBar
---@field Slider USlider
---@field Slider2 USlider
---@field TextBag UFTextBlock
---@field TextHigh UFTextBlock
---@field TextName UFTextBlock
---@field TextNum1 UFTextBlock
---@field TextNum2 UFTextBlock
---@field TextOK UFTextBlock
---@field TextRotate UFTextBlock
---@field TextRotate2 UFTextBlock
---@field TextWarehouse UFTextBlock
---@field TextX UFTextBlock
---@field ToggleBtnRotate UToggleButton
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseMovePanelView = LuaClass(UIView, true)

function HouseMovePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAdd = nil
	--self.BtnBag = nil
	--self.BtnL = nil
	--self.BtnOK = nil
	--self.BtnR = nil
	--self.BtnSub = nil
	--self.BtnWarehouse = nil
	--self.BtnX = nil
	--self.IconBagDisab = nil
	--self.IconBagNormal = nil
	--self.IconOK = nil
	--self.IconOKDisab = nil
	--self.IconWarehouseDisab = nil
	--self.IconWarehouseNormal = nil
	--self.ImgAdd = nil
	--self.ImgL = nil
	--self.ImgProgressBarBg = nil
	--self.ImgProgressBarBg2 = nil
	--self.ImgR = nil
	--self.ImgSub = nil
	--self.PanelHeight = nil
	--self.PanelRotate = nil
	--self.ProgressBar = nil
	--self.ProgressBar2 = nil
	--self.Slider = nil
	--self.Slider2 = nil
	--self.TextBag = nil
	--self.TextHigh = nil
	--self.TextName = nil
	--self.TextNum1 = nil
	--self.TextNum2 = nil
	--self.TextOK = nil
	--self.TextRotate = nil
	--self.TextRotate2 = nil
	--self.TextWarehouse = nil
	--self.TextX = nil
	--self.ToggleBtnRotate = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseMovePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseMovePanelView:OnInit()
    self.ViewModel = HouseMovePanelVM.New()
    self.Binders = {
        { "Height", UIBinderSetText.New(self, self.TextNum1, self.HeightTextHandleFunc) },
        { "Rotate", UIBinderSetText.New(self, self.TextNum2, self.RotateTextHandleFunc) },
        { "HeightSlider", UIBinderSetSlider.New(self, self.Slider) },
        { "RotateSlider", UIBinderSetSlider.New(self, self.Slider2) },
        -- { "HeightViewVisibility", UIBinderSetVisibility.New(self, self.PanelHeight)},
        { "RotateViewVisibility", UIBinderSetVisibility.New(self, self.PanelRotate)},
    }
    self.OldRotate = 0
    self.OldGroundZ = 0
    self.OldHeight = 0
    self.bHeightUnset = true
    self.HasChange = false
end

function HouseMovePanelView:OnDestroy()

end

function HouseMovePanelView:OnShow()
    self.TextHigh:SetText(LSTR(1640030))
    self.TextRotate:SetText(LSTR(1640031))
    self.TextRotate2:SetText(LSTR(1640031))
    self.TextBag:SetText(LSTR(1640032))
    self.TextWarehouse:SetText(LSTR(1640033))
    self.TextX:SetText(LSTR(1640034))
    self.TextOK:SetText(LSTR(1640035))
end

function HouseMovePanelView:OnHide()
    self:OnClickedCancel()
end

function HouseMovePanelView:OnRegisterUIEvent()
    UIUtil.AddOnValueChangedEvent(self, self.Slider, self.OnValueChangedHeight)
    UIUtil.AddOnMouseCaptureBeginEvent(self, self.Slider, self.OnSliderMouseCaptureBegin)
    UIUtil.AddOnMouseCaptureEndEvent(self, self.Slider, self.OnSliderMouseCaptureEnd)
    UIUtil.AddOnClickedEvent(self, self.BtnAdd, self.OnClickedBtnHeightAdd)
    UIUtil.AddOnClickedEvent(self, self.BtnSub, self.OnClickedBtnHeightSub)

    UIUtil.AddOnValueChangedEvent(self, self.Slider2, self.OnValueChangedRotate)
    UIUtil.AddOnClickedEvent(self, self.BtnL, self.OnClickedBtnRotateSub)
    UIUtil.AddOnClickedEvent(self, self.BtnR, self.OnClickedBtnRotateAdd)

    UIUtil.AddOnClickedEvent(self, self.ToggleBtnRotate, self.OnToggleRotateChanged)
    UIUtil.AddOnClickedEvent(self, self.BtnBag, self.OnClickedBag)
    UIUtil.AddOnClickedEvent(self, self.BtnWarehouse, self.OnClickedBtnWarehouse)
    UIUtil.AddOnClickedEvent(self, self.BtnX, self.OnClickedCancel)
    UIUtil.AddOnClickedEvent(self, self.BtnOK, self.OnClickedOK)

end

function HouseMovePanelView:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.RemoveFurniture,self.OnRemoveFurniture)
    self:RegisterGameEvent(EventID.PickEndFurniture,self.OnPickEndFurniture)
end

function HouseMovePanelView:OnRegisterBinder()
    self:RegisterBinders(self.ViewModel, self.Binders)
end

-- Param from EventID.EnterHouseFurniturePreview
function HouseMovePanelView:UpdateView(Param)
    self.Params = Param
    self.BackBag = false
    self.BackDepot = false

    local FurnitureName = ItemCfg:GetItemName(self.Params.Item.ResID) or ""
    self.TextName:SetText(FurnitureName)

    self.ToggleBtnRotate:SetCheckedState(_G.UE.EToggleButtonState.UnChecked)
    self.ViewModel.RotateViewVisibility = 1

    UIUtil.TextBlockSetColorAndOpacityHex( self.TextWarehouse, "ffffff")

    self:UpdateBackBagImage(CommBtnColorType.Normal)
    self:UpdateBackDepotImage(CommBtnColorType.Normal)
    self:UpdateOKBtnImage(CommBtnColorType.Normal)
    --self.TopLow = _G.HousingMgr:GetLowTopHeight()

    self.OldRotate = self.Params.Rotate
    self.ViewModel:SetRotate(self.OldRotate)
    self.ViewModel:SetHeight(0)
    self.bHeightUnset = true

    self:UpdateOKBtnImage(CommBtnColorType.Disable)
end

function HouseMovePanelView:UpdateBackBagImage(ColorType)
    if CommBtnColorType.Normal == ColorType then
        UIUtil.TextBlockSetColorAndOpacityHex( self.TextWarehouse, "ffffff")
        UIUtil.SetIsVisible(self.IconBagNormal,true,false)
        UIUtil.SetIsVisible(self.IconBagDisab,false,false)
    elseif CommBtnColorType.Disable == ColorType then
        UIUtil.TextBlockSetColorAndOpacityHex( self.TextWarehouse, "c0c0c0")
        UIUtil.SetIsVisible(self.IconBagNormal,false,false)
        UIUtil.SetIsVisible(self.IconBagDisab,true,false)
    end
end

function HouseMovePanelView:UpdateBackDepotImage(ColorType)
    if CommBtnColorType.Normal == ColorType then
        UIUtil.TextBlockSetColorAndOpacityHex( self.TextBag, "ffffff")
        UIUtil.SetIsVisible(self.IconWarehouseNormal,true,false)
        UIUtil.SetIsVisible(self.IconWarehouseDisab,false,false)
    elseif CommBtnColorType.Disable == ColorType then
        UIUtil.TextBlockSetColorAndOpacityHex( self.TextBag, "c0c0c0")
        UIUtil.SetIsVisible(self.IconWarehouseNormal,false,false)
        UIUtil.SetIsVisible(self.IconWarehouseDisab,true,false)
    end
end

--region 旋转滑动

function HouseMovePanelView.RotateTextHandleFunc(NewValue, _)
    return string.format("%d°", NewValue)
end

local RotateGrid = 15
local RotateThreshold = 1
function HouseMovePanelView:OnValueChangedRotate(_, Value)
    local LastRotate = self.ViewModel.Rotate
    if _G.HousingMgr.IsGirdModel then
        if math.abs(Value - LastRotate) < RotateGrid then
            return
        end
        if Value > LastRotate then
            Value = LastRotate + RotateGrid
        else
            Value = LastRotate - RotateGrid
        end
    else
        if math.abs(Value - LastRotate) < RotateThreshold then
            return
        end
    end
    self.HasChange = true

    local Angle = math.clamp(Value,-180,180)
    Angle = math.ceil(Angle - 0.5)

    self.ViewModel:SetRotate(Angle, true)
    _G.HousingMgr:CheckAndSetPickObjectRotate(Angle)
    self:UpdateOKBtnImage(CommBtnColorType.Normal)
    local HousingMgrInstance = UHousingMgr:Get()
    if HousingMgrInstance ~= nil then
        HousingMgrInstance:SetRotationKeyPressed(Angle)
    end
end

function HouseMovePanelView:OnClickedBtnRotateAdd()
    self.HasChange = true
    local Delta = _G.HousingMgr.IsGirdModel and 15 or 1
    local Rotate = math.clamp(self.ViewModel.Rotate + Delta, -180, 180)

    self.ViewModel:SetRotate(Rotate)
    self:UpdateOKBtnImage(CommBtnColorType.Normal)
    local HousingMgrInstance = UHousingMgr:Get()
    _G.HousingMgr:CheckAndSetPickObjectRotate(Rotate)
    if HousingMgrInstance ~= nil then
        HousingMgrInstance:SetRotationKeyPressed(Rotate)
    end
end

function HouseMovePanelView:OnClickedBtnRotateSub()
    self.HasChange = true
    local Delta = _G.HousingMgr.IsGirdModel and 15 or 1
    local Rotate = math.clamp(self.ViewModel.Rotate - Delta, -180, 180)

    self.ViewModel:SetRotate(Rotate)
    self:UpdateOKBtnImage(CommBtnColorType.Normal)
    local HousingMgrInstance = UHousingMgr:Get()
    _G.HousingMgr:CheckAndSetPickObjectRotate(Rotate)
    if HousingMgrInstance ~= nil then
        HousingMgrInstance:SetRotationKeyPressed(Rotate)
    end
end

--region 高度滑动

function HouseMovePanelView.HeightTextHandleFunc(NewValue, _)
    return string.format("%.1f", NewValue / 100)
end

local HeightGrid = 100
local HeightThreshold = 10
function HouseMovePanelView:OnValueChangedHeight(_, Value)
    local LastHeight = self.ViewModel.Height
    if _G.HousingMgr.IsGirdModel then
        if math.abs(Value - LastHeight) < HeightGrid then
            return
        end
        if Value > LastHeight then
            Value = LastHeight + HeightGrid
        else
            Value = LastHeight - HeightGrid
        end
    else
        if math.abs(Value - LastHeight) < HeightThreshold then
            return
        end
    end
    self.HasChange = true

    local Height = math.clamp(Value, 0, 600)
    Height = math.ceil(Height / 10 - 0.5) * 10

    self.ViewModel:SetHeight(Height, true)
    _G.HousingMgr:CheckAndSetPickObjectZ(self.OldGroundZ + Height)
    self:UpdateOKBtnImage(CommBtnColorType.Normal)
    -- local HousingMgrInstance = UHousingMgr:Get()
    -- if HousingMgrInstance ~= nil then
    --     HousingMgrInstance:SetRotationKeyPressed(Height)
    -- end
end

function HouseMovePanelView:OnClickedBtnHeightAdd()
    self.HasChange = true
    local Delta = _G.HousingMgr.IsGirdModel and 100 or 10
    local Height = math.clamp(self.ViewModel.Height + Delta, 0, 600)

    self.ViewModel:SetHeight(Height)
    self:UpdateOKBtnImage(CommBtnColorType.Normal)
    _G.HousingMgr:CheckAndSetPickObjectZ(self.OldGroundZ + Height)
    -- local HousingMgrInstance = UHousingMgr:Get()
    -- if HousingMgrInstance ~= nil then
    --     HousingMgrInstance:SetRotationKeyPressed(Height)
    -- end
end

function HouseMovePanelView:OnClickedBtnHeightSub()
    self.HasChange = true
    local Delta = _G.HousingMgr.IsGirdModel and 100 or 10
    local Height = math.clamp(self.ViewModel.Height - Delta, 0, 600)

    self.ViewModel:SetHeight(Height)
    self:UpdateOKBtnImage(CommBtnColorType.Normal)
    _G.HousingMgr:CheckAndSetPickObjectZ(self.OldGroundZ + Height)
    -- local HousingMgrInstance = UHousingMgr:Get()
    -- if HousingMgrInstance ~= nil then
    --     HousingMgrInstance:SetRotationKeyPressed(Height)
    -- end
end

--region 其他

function HouseMovePanelView:OnSliderMouseCaptureBegin()
end

function HouseMovePanelView:OnSliderMouseCaptureEnd()
end

function HouseMovePanelView:OnToggleRotateChanged()
    local state = self.ToggleBtnRotate:GetCheckedState()

    if state == _G.UE.EToggleButtonState.Checked then
        self.ViewModel.RotateViewVisibility = 0

        local HousingMgrInstance = UHousingMgr:Get()
        if HousingMgrInstance ~= nil then
            HousingMgrInstance:SetLayoutEditMode(HouseCommon.eLayoutEditMode.LAYOUTEDIT_MODE_ROTATE)
        end
    elseif state == _G.UE.EToggleButtonState.Unchecked then
        self.ViewModel.RotateViewVisibility = 1
        local HousingMgrInstance = UHousingMgr:Get()
        if HousingMgrInstance ~= nil then
            HousingMgrInstance:SetLayoutEditMode(HouseCommon.eLayoutEditMode.LAYOUTEDIT_MODE_TRANSLATE)
        end
    end
end

function HouseMovePanelView:OnClickedBag()
    if UIUtil.IsVisible(self.IconBagNormal) then
        if _G.BagMgr:GetBagLeftNum() > 1 then
            self.BackBag = true
            _G.HousingMgr:SendBackFurnitureReq(self.Params.Item.GID,ProtoCS.HouseUseBagType.HouseUseBagType_RoleBag)
        else
            MsgTipsUtil.ShowTips(LSTR(1640050))
        end
    else
        MsgTipsUtil.ShowTips(LSTR(1640075))
    end

    self:UpdateBackBagImage(CommBtnColorType.Disable)
end

function HouseMovePanelView:OnClickedBtnWarehouse()
    if UIUtil.IsVisible(self.IconWarehouseNormal) then
        if not self:IsDepotFull() then
            self.BackDepot = true
            _G.HousingMgr:SendBackFurnitureReq(self.Params.Item.GID,ProtoCS.HouseUseBagType.HouseUseBagType_HouseDepot)
        else
            MsgTipsUtil.ShowTips(LSTR(1640053))
        end
    else
        MsgTipsUtil.ShowTips(LSTR(1640075))
    end

    self:UpdateBackDepotImage(CommBtnColorType.Disable)
end

function HouseMovePanelView:IsDepotFull()
    local Depot = _G.HousingMgr:GetCurrentDepot()

    if Depot ~= nil then
        local IsDepotFull = false
        if Depot.ItemList ~= nil then
            if Depot.Capacity - #Depot.ItemList < 1 then
                IsDepotFull = true
            end
        end

        return IsDepotFull
    end
end

function HouseMovePanelView:OnClickedCancel()
    _G.EventMgr:SendEvent(_G.EventID.ExitHouseFurniturePreview)
    _G.HousingMgr:CheckAndSetPickObjectRotate(self.OldRotate)
    _G.HousingMgr:CheckAndSetPickObjectZ(self.OldGroundZ + self.OldHeight)
    _G.HousingMgr:CancelPickObject()

    local HousingMgrInstance = UHousingMgr:Get()
    if HousingMgrInstance ~= nil then
        HousingMgrInstance:SetMouseCancelReleased()
        HousingMgrInstance:EndLayoutMode() -- LAYOUTEDIT_MODE_INVALID
    end
end

function HouseMovePanelView:OnClickedOK()
    if self.HasChange then
        _G.HousingMgr:RefreshPickObjectsInfo()

        local HousingMgrInstance = UHousingMgr:Get()
        if HousingMgrInstance ~= nil then
            HousingMgrInstance:SetMouseEnterReleased()
        end

        _G.HousingMgr:SendFurnitureMoveRes()
    else
        MsgTipsUtil.ShowTips(LSTR(1640146))
    end
end

-- --更新当前房子最高最低大小
-- function HouseMovePanelView:UpdateSlider(MinValue, MaxValue)
--     local Slider = self.Slider
--     if nil == Slider then
--         return
--     end

--     Slider:SetMinValue(MinValue)
--     Slider:SetMaxValue(MaxValue)
-- end

-- function HouseMovePanelView:UpdateSliderHeight(Value)
--     local Slider = self.Slider
--     if nil == Slider then
--         return
--     end

--     Slider:SetValue(Value)
-- end

function HouseMovePanelView:OnRemoveFurniture(Params)
    _G.EventMgr:SendEvent(EventID.ExitHouseFurniturePreview)
end

function HouseMovePanelView:UpdateOKBtnImage(ColorType)
    if CommBtnColorType.Normal == ColorType then
        UIUtil.SetIsVisible(self.IconOK,true,false)
        UIUtil.SetIsVisible(self.IconOKDisab,false,false)
    elseif CommBtnColorType.Disable == ColorType then
        UIUtil.SetIsVisible(self.IconOK,false,false)
        UIUtil.SetIsVisible(self.IconOKDisab,true,false)
    end
end

function HouseMovePanelView:OnPickEndFurniture(Params)
    self.HasChange = true
    local GroundZ, Height = _G.HousingMgr:GetPickObjectHeight()
    if self.bHeightUnset then
        self.bHeightUnset = false
        self.OldGroundZ, self.OldHeight = GroundZ, Height
    end
    self.ViewModel:SetHeight(Height)
    self:UpdateOKBtnImage(CommBtnColorType.Normal)
end

return HouseMovePanelView