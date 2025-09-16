local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local FashionDecoSkillBtnVM = require("Game/FashionDeco/VM/FashionDecoSkillBtnVM")
local FashionDecoMgr = require("Game/FashionDeco/FashionDecoMgr")
local FashionDecoDefine = require("Game/FashionDeco/VM/FashionDecoDefine")
local FashionDecorateCfg = require("TableCfg/FashionDecorateCfg")
local FashionDecorateSkillCfg = require("TableCfg/FashionDecorateSkillCfg")
---@class FashionDecoSkillPanelVM : UIViewModel
local FashionDecoSkillPanelVM = LuaClass(UIViewModel)

function FashionDecoSkillPanelVM:Ctor()
    self.SkillFashionSwitchBtnEnable = false
    self.ActionWingSkillEnable = false
    self.ActionUmAction1Enable = false
    self.ActionUmAction2Enable = false
    self.ActionSwitchIdleEnable = false
    self.UmAction1VM = nil
    self.WingActionVM = nil
    self.UpdateAnimView = false

end
function FashionDecoSkillPanelVM:UpdateFashionDecorateUpdateData()
    self:OnGameEventFashionDecorateUpdateData(FashionDecoMgr:GetCurrentClothingMap())
end
function FashionDecoSkillPanelVM:IsInClothingMapTypeValid(InCurrentClothingMap,InType)
    if InType > 0 and InCurrentClothingMap ~= nil and InCurrentClothingMap[InType] ~= nil
    and InCurrentClothingMap[InType] ~= 0  then
        return true
    end
    return false
end
function FashionDecoSkillPanelVM:OnGameEventFashionDecorateUpdateData(InCurrentClothingMap)
    if InCurrentClothingMap ~= nil then
        if self:IsInClothingMapTypeValid(InCurrentClothingMap,FashionDecoDefine.FashionDecoType.Umbrella) then
            self:ProcessUmbrella(InCurrentClothingMap[FashionDecoDefine.FashionDecoType.Umbrella])
        else
            self.ActionUmAction1Enable = false
            self.ActionUmAction2Enable = false
        end
        if self:IsInClothingMapTypeValid(InCurrentClothingMap,FashionDecoDefine.FashionDecoType.Wing) then
            self:ProcessWing(InCurrentClothingMap[FashionDecoDefine.FashionDecoType.Wing])
        else
            self.ActionWingSkillEnable = false
        end
        self.SkillFashionSwitchBtnEnable = true
    else
        self.SkillFashionSwitchBtnEnable = false
        self.ActionUmAction1Enable = false
        self.ActionWingSkillEnable = false
        self.ActionUmAction2Enable = false
    end
    if self.ActionUmAction1Enable or self.ActionUmAction2Enable or self.ActionWingSkillEnable then
        self.UpdateAnimView = false
    else
        self.UpdateAnimView = true
    end
    if not self.ActionUmAction1Enable and not  self.ActionUmAction2Enable and not  self.ActionWingSkillEnable then
        self.SkillFashionSwitchBtnEnable = false
    end
end
function FashionDecoSkillPanelVM:ProcessWing(InWingID)
    local itemCurrentSelectedCfg = FashionDecorateCfg:FindCfgByKey(InWingID)

    if itemCurrentSelectedCfg.Action[1] ~= nil and itemCurrentSelectedCfg.Action[1] ~= 0 then
        local itemcfg =FashionDecorateSkillCfg:FindCfgByKey(itemCurrentSelectedCfg.Action[1])
        if itemcfg ~= nil then
            self.ActionWingSkillEnable = true
            self.WingActionVM.AppearanceIcon = itemcfg.Icon
            self.WingActionVM.FashionDecorateID = InWingID
            self.WingActionVM.ActionID = itemCurrentSelectedCfg.Action[1]
        else
            self.ActionWingSkillEnable = false
        end
    else
        self.ActionWingSkillEnable = false
    end
end
function FashionDecoSkillPanelVM:SwitchIdleStateWithnUmbrella()
    FashionDecoMgr:ReqChangeIdleAnim()
end
function FashionDecoSkillPanelVM:ProcessUmbrella(InUmbrellaID)
    local itemCurrentSelectedCfg = FashionDecorateCfg:FindCfgByKey(InUmbrellaID)

    if itemCurrentSelectedCfg.Action[1] ~= nil and itemCurrentSelectedCfg.Action[1] ~= 0 then
        local itemcfg =FashionDecorateSkillCfg:FindCfgByKey(itemCurrentSelectedCfg.Action[1])
        if itemcfg ~= nil then
            self.ActionUmAction1Enable = true
            self.UmAction1VM.AppearanceIcon = itemcfg.Icon
            self.UmAction1VM.FashionDecorateID = InUmbrellaID
            self.UmAction1VM.ActionID = itemCurrentSelectedCfg.Action[1]
        else
            self.ActionUmAction1Enable = false
        end
    end
    if itemCurrentSelectedCfg.Action[2] ~= nil and itemCurrentSelectedCfg.Action[2] ~= 0 then
        local itemcfg =FashionDecorateSkillCfg:FindCfgByKey(itemCurrentSelectedCfg.Action[2])
        if itemcfg ~= nil then
            self.ActionUmAction2Enable = true
            self.UmAction2VM.AppearanceIcon = itemcfg.Icon
            self.UmAction2VM.FashionDecorateID = InUmbrellaID
            self.UmAction2VM.ActionID = itemCurrentSelectedCfg.Action[2]
        else
            self.ActionUmAction2Enable = false
        end
    end
end
function FashionDecoSkillPanelVM:GetWingViewModel()
    local NewVM = FashionDecoSkillBtnVM.New()
    return NewVM
end
function FashionDecoSkillPanelVM:SetActionUmAction1ViewModelAttr(ItemView)
    self.UmAction1VM = ItemView.ViewModel
    self.UmAction1VM.Init = true
    self.UmAction1VM.AppearanceIcon = "Texture2D'/Game/Assets/Icon/ItemIcon/008000/UI_Icon_008103.UI_Icon_008103'";
    self.UmAction1VM.FunctionType = FashionDecoDefine.FashionActionBtnType.Action1
end
function FashionDecoSkillPanelVM:SetActionUmAction2ViewModelAttr(ItemView)
    self.UmAction2VM = ItemView.ViewModel
    self.UmAction2VM.Init = true
    self.UmAction2VM.AppearanceIcon = "Texture2D'/Game/Assets/Icon/ItemIcon/008000/UI_Icon_008103.UI_Icon_008102'";
    self.UmAction2VM.FunctionType = FashionDecoDefine.FashionActionBtnType.Action2
end
function FashionDecoSkillPanelVM:SetActionWingViewModelAttr(ItemView)
    self.WingActionVM = ItemView.ViewModel
    self.WingActionVM.Init = true
    self.WingActionVM.AppearanceIcon = "Texture2D'/Game/Assets/Icon/ItemIcon/008000/UI_Icon_008104.UI_Icon_008104'";
    self.WingActionVM.FunctionType = FashionDecoDefine.FashionActionBtnType.Wing
end
function FashionDecoSkillPanelVM:SetSwitchViewModelAttr(ItemView)
    ItemView.ViewModel.Init = true
    ItemView.ViewModel.AppearanceIcon = "Texture2D'/Game/Assets/Icon/ItemIcon/008000/UI_Icon_008101.UI_Icon_008101'";
    ItemView.ViewModel.FunctionType = FashionDecoDefine.FashionActionBtnType.Switch
end
function FashionDecoSkillPanelVM:OnSwitchIdleClicked()
    FashionDecoMgr:ReqChangeIdleAnim()
end
return FashionDecoSkillPanelVM