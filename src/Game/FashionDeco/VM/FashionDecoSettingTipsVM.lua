local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local FashionDecoDefine = require("Game/FashionDeco/VM/FashionDecoDefine")
local localFashionDecoSettingTipsItemVM = require("Game/FashionDeco/VM/FashionDecoSettingTipsItemVM")
local LSTR = _G.LSTR
---@class FashionDecoSettingTipsVM : UIViewModel
local FashionDecoSettingTipsVM = LuaClass(UIViewModel)

function FashionDecoSettingTipsVM:Ctor()
    self.ListSettingTipsItemVM = nil
    self.AutoUseInRainTitle = LSTR(1030005)--雨天自动穿戴穿戴
    self.bAutoUseSelect = false
end

function FashionDecoSettingTipsVM:SelectDefaultElem()
    self.bAutoUseSelect = true
    self:GenItems(FashionDecoDefine.FashionDecorateAutoUseChooseType. FashionDecorateUseByLast)
    self:CallSettingFunction(FashionDecoDefine.FashionDecorateAutoUseChooseType. FashionDecorateUseByLast)
end
function FashionDecoSettingTipsVM:GetEmptyIndexDefaultElem()
    return FashionDecoDefine.FashionDecorateAutoUseChooseType.FashionDecorateUseByNone
end
function FashionDecoSettingTipsVM:IsAutoUse()
    return self.bAutoUseSelect
end
function FashionDecoSettingTipsVM:GetCurrentChooseType()
    return self.ParentViewModel:GetCurrentChooseType()
end
function FashionDecoSettingTipsVM:OnSelected(InIndex)
    
    if self.bAutoUseSelect ~= false or InIndex == FashionDecoDefine.FashionDecorateAutoUseChooseType.FashionDecorateUseByNone  then
        self:SettingCurrentChooseType(InIndex)
        self:CallSettingFunction(InIndex)
    end

end
function FashionDecoSettingTipsVM:CancelAllSelected()
    self:SettingCurrentChooseType(FashionDecoDefine.FashionDecorateAutoUseChooseType.FashionDecorateUseByNone)
end
--触发随机选择
function FashionDecoSettingTipsVM:CallSettingFunction(InIndex)
    self.ParentViewModel:SetChooseType(InIndex)
end
function FashionDecoSettingTipsVM:HideSelf()
    self.ParentViewModel:SetSettingPanel(false)
end
function FashionDecoSettingTipsVM:SettingCurrentChooseType(InType)
    if FashionDecoDefine.FashionDecorateAutoUseChooseType.FashionDecorateUseByNone == InType then
        self.bAutoUseSelect = false
        self:GenItems(FashionDecoDefine.FashionDecorateAutoUseChooseType.FashionDecorateUseByLast,self.bAutoUseSelect)

        return
    end
    if FashionDecoDefine.FashionDecorateAutoUseChooseType.FashionDecorateUseByLike == InType then
        self.bAutoUseSelect = true
        self:GenItems(FashionDecoDefine.FashionDecorateAutoUseChooseType.FashionDecorateUseByLike,self.bAutoUseSelect)

        return
    end
    if FashionDecoDefine.FashionDecorateAutoUseChooseType.FashionDecorateUseByRand == InType then
        self.bAutoUseSelect = true
        self:GenItems(FashionDecoDefine.FashionDecorateAutoUseChooseType.FashionDecorateUseByRand,self.bAutoUseSelect)

        return
    end
    if FashionDecoDefine.FashionDecorateAutoUseChooseType.FashionDecorateUseByLast == InType then
        self.bAutoUseSelect = true
        self:GenItems(FashionDecoDefine.FashionDecorateAutoUseChooseType.FashionDecorateUseByLast,self.bAutoUseSelect)

        return
    end

end
function FashionDecoSettingTipsVM:ClearListData()
    self.ListSettingTipsItemVM = nil
end
function FashionDecoSettingTipsVM:GenItems(InIndex,bAutoUseSelect)
    if self.ListSettingTipsItemVM == nil then
        --生成数据
        local List = {}

        local ItemVM = localFashionDecoSettingTipsItemVM.New()
        ItemVM.Title = LSTR(1030006)--最近召唤
        ItemVM.Index = 1
        ItemVM.ParentViewModel = self;
        ItemVM.FashionDecorateAutoUseChooseType = FashionDecoDefine.FashionDecorateAutoUseChooseType.FashionDecorateUseByLast
        ItemVM.bEditAble = false;
        List[#List + 1] = ItemVM

        ItemVM = localFashionDecoSettingTipsItemVM.New()
        ItemVM.Title = LSTR(1030007)--全部随机
        ItemVM.Index = 2
        ItemVM.ParentViewModel = self;
        ItemVM.FashionDecorateAutoUseChooseType = FashionDecoDefine.FashionDecorateAutoUseChooseType.FashionDecorateUseByRand
        List[#List + 1] = ItemVM

        ItemVM = localFashionDecoSettingTipsItemVM.New()
        ItemVM.Title = LSTR(1030008)--收藏随机
        ItemVM.Index = 3
        ItemVM.ParentViewModel = self;
        ItemVM.FashionDecorateAutoUseChooseType = FashionDecoDefine.FashionDecorateAutoUseChooseType.FashionDecorateUseByLike
        List[#List + 1] = ItemVM

        self.ListSettingTipsItemVM = List
    end

    for _,value in ipairs(self.ListSettingTipsItemVM) do

        --if value.FashionDecorateAutoUseChooseType == InIndex then
        --    value:SetClickAble(false)
        --else
        --    value:SetClickAble(true)
        --end

        value:SetSelect(value.FashionDecorateAutoUseChooseType == InIndex)
        if bAutoUseSelect == false then
            value.bIsClickMaskVisible = true
            value.TitleColor = "8c8c8c"
        else
            value.bIsClickMaskVisible = false
        end

    end
end

return FashionDecoSettingTipsVM