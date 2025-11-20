local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local FashionDecoDefine = require("Game/FashionDeco/VM/FashionDecoDefine")
local FashionDecoSettingTipsVM = require("Game/FashionDeco/VM/FashionDecoSettingTipsVM")
local FashionDecoSlotItemVM = require("Game/FashionDeco/VM/FashionDecoSlotItemVM")
local FashionDecoActionItemVM = require("Game/FashionDeco/VM/FashionDecoActionItemVM")
local FashionDecoMgr = require("Game/FashionDeco/FashionDecoMgr")
local CommTabsDefine = require("Game/Common/Tab/CommTabsDefine")
local DataReportUtil = require("Utils/DataReportUtil")
local MajorUtil = require("Utils/MajorUtil")
---@class FashionDecoSideFrameWinVM : UIViewModel
local FashionDecoSideFrameWinVM = LuaClass(UIViewModel)
local LSTR = _G.LSTR
local MsgTipsUtil = _G.MsgTipsUtil
function FashionDecoSideFrameWinVM:Ctor()

    --设置界面
    self.FashionDecoSettingTipsVM = FashionDecoSettingTipsVM.New()
    --类型选择
    self.FashionDecoSettingTipsVM.ParentViewModel = self

    --self.FashionDecoTypeSelectVM.ParentVM = self
    --当前选择
    self.CurrentSelectedItem = nil
    self.CurrentSelectedIsCollect = false
    self.CurrentSelectedName = nil
    self.UpdateToSelectFirstIndex = nil
    self.BtnWearName = LSTR(1030010)--穿戴
    self.ListSlotItemListVM = nil
    self.ListActionItemListVM = nil
    self.SettingBtnVisible = false
    self.SettingPanelVisible = false
    self.CurrentSelectType = nil
    FashionDecoMgr:SetMainVM(self)
    self.CurrentWearBtnState = true
    self.TextActionVisible = false
    self.CurrentSelectedEquip = false
    self.BtnWearVisible = false
    self.ToggleBtnCollectVisible = false

    self.bShowPanelBtnAmeliorate = false --是否显示配饰改良的入口( 目前翅膀显示，雨伞不显示)
    self.bIsAmeliorateSystemOpen = true --配饰改良系统是否能点击
end
--收藏点击
function FashionDecoSideFrameWinVM:ClearData()
    self.CurrentSelectedItem = nil
    self.CurrentSelectedIsCollect = false
    self.CurrentSelectedName = nil
    self.ListSlotItemListVM = nil
    self.ListSlotItemListVM = self:ResetBindableList(self.ListSlotItemListVM,FashionDecoSlotItemVM)
    self.ListActionItemListVM = nil
    self.SettingBtnVisible = false
    self.SettingPanelVisible = false
    self.CurrentSelectType = nil
    self.CurrentWearBtnState = true
    self.TextActionVisible = false
    self.CurrentSelectedEquip = false
    self.UpdateToSelectFirstIndex = nil
    FashionDecoMgr:SetMainVM(nil)
    FashionDecoMgr:OnHideMainView()
end

function FashionDecoSideFrameWinVM:OnBtnCollect()
    FashionDecoMgr:SendCollect(self.CurrentSelectedID,not self.CurrentSelectedIsCollect)
end

function FashionDecoSideFrameWinVM:SetChooseType(InChooseType)
    FashionDecoMgr:SetCurrentChooseType(InChooseType)
end
--获取设置VM
function FashionDecoSideFrameWinVM:GetSettingVM()
    return self.FashionDecoSettingTipsVM
end

-- 改变选中的对象，选中目标ID
function FashionDecoSideFrameWinVM:OnChangeSelectItem(ID)
    for i = 1, self.ListSlotItemListVM:Length() do
        self.ListSlotItemListVM.Items[i]:OnSelectedChange(false)
    end

    local InNewItem = self:FindItemByID(ID)
    if InNewItem then
        InNewItem.IsSelect = true
        self:SetCurrentSelectedItem(InNewItem)
        InNewItem:OnSelectedChange(true)
    end
end

--设置当前选择的item
function FashionDecoSideFrameWinVM:SetCurrentSelectedItem(InNewItem)
    if self.CurrentSelectedItem ~= nil and (InNewItem.ID == nil or not InNewItem.IsSelect) then
        return
    end
    self.CurrentSelectedItem = InNewItem
    self:UpdateCurrentSelectedItem()
    self:ReportCurrentSelectItem()
end

function FashionDecoSideFrameWinVM:FindItemByID(ID)
    return self.ListSlotItemListVM:Find(function(Item)
        return Item.ID == ID
    end)
end

--埋点上报
function FashionDecoSideFrameWinVM:ReportCurrentSelectItem()
   DataReportUtil.ReportFashiondecoData("FashionAccessoriesFlow", 2,1,self.CurrentSelectedID)
end

--更新当前Item所有主界面信息
function FashionDecoSideFrameWinVM:UpdateCurrentSelectedItem()
    FashionDecoMgr:SetMainVM(self)
    self.CurrentSelectedIsCollect = self.CurrentSelectedItem.IconCollectVisible
    self.CurrentSelectedName = self.CurrentSelectedItem.Title
    self.CurrentSelectedID = self.CurrentSelectedItem.ID
    self.CurrentSelectedEquip = self.CurrentSelectedItem.Equip
    -- self.CurrentSelectedItem = nil
    self.ListActionItemListVM = self:ResetBindableList(self.ListActionItemListVM, FashionDecoActionItemVM)
    local TempActionList = FashionDecoMgr:GetActionListDataByID(self.CurrentSelectedID,FashionDecoActionItemVM)
    if #TempActionList > 0 then
        self.TextActionVisible = true
    else
        self.TextActionVisible = false
    end
    self.ListActionItemListVM:UpdateByValues(TempActionList)
    if self.CurrentSelectedEquip == true then
        self.BtnWearName = LSTR(1030009)--卸下
        self.CurrentWearBtnState = false
    else
        self.BtnWearName = LSTR(1030010)--穿戴
        self.CurrentWearBtnState = true
    end
    if FashionDecoMgr:IsNewToRead(self.CurrentSelectedID) then
        FashionDecoMgr:SendRead(self.CurrentSelectedID)
    end

end

function FashionDecoSideFrameWinVM:ClickCurrentAction(ItemData)
    if ItemData.ChangeState ~=nil and ItemData.ChangeState ~= false then
        FashionDecoMgr:ReqChangeIdleAnim()
    else
        local result = FashionDecoMgr:GetCurrentEquip(FashionDecoDefine.FashionDecoType.Umbrella)
        if result ~= nil and result >0 then
            FashionDecoMgr:PlaySkillAction(self.CurrentSelectedID,ItemData.ID)
        else
            MsgTipsUtil.ShowTips(LSTR(1030019))--穿戴雨伞后方可使用
        end
    end
end

function FashionDecoSideFrameWinVM:GetCurrentChooseType()
    return FashionDecoMgr:GetCurrentChooseType()
end

function FashionDecoSideFrameWinVM:UpdateFashionDecoSettingTipsVM()
    self.FashionDecoSettingTipsVM:SettingCurrentChooseType(FashionDecoMgr:GetCurrentChooseType())
end

--触发随机选择
function FashionDecoSideFrameWinVM:CallSettingFunction(InIndex)
    FashionDecoMgr:SendAutoUseType(InIndex)
end

function FashionDecoSettingTipsVM:CancelAllSettingSelected()
    FashionDecoMgr:SendAutoUseType(0)
end

--穿戴/卸下时尚配饰
function FashionDecoSideFrameWinVM:WearCurrentFashionDeco()
    local StateComp = MajorUtil.GetMajorStateComponent()
    local IsHoldWeapon = false
    if StateComp ~= nil  then
        IsHoldWeapon = StateComp:IsHoldWeaponState()
    end

    --检查当前状态能否--穿戴/卸下
    if FashionDecoMgr:CheckFashionDecorateHiddenState(self.CurrentSelectType) and not IsHoldWeapon then
        MsgTipsUtil.ShowTips(LSTR(1030016))--当前状态无法装备
        return
    end
    --是否装备
    local bIsUmbrella = false
    if self.CurrentSelectedEquip == true then
        --if self.CurrentSelectType == FashionDecoDefine.FashionDecoType.Umbrella then
            --bIsUmbrella = true
        --end
        FashionDecoMgr:SendUnClothing(self.CurrentSelectType)
    else

        if self.CurrentSelectType == FashionDecoDefine.FashionDecoType.Umbrella then
            bIsUmbrella = true
        end
        if IsHoldWeapon and self.CurrentSelectType == FashionDecoDefine.FashionDecoType.Wing then
            FashionDecoMgr:SendClothing(self.CurrentSelectedID,bIsUmbrella,true)
        else
            FashionDecoMgr:SingAndSendClothing(self.CurrentSelectedID,bIsUmbrella,true)
        end
        DataReportUtil.ReportEasyUseFlowData(3, self.CurrentSelectedID, 4)
    end
end

function FashionDecoSideFrameWinVM:SetTabsSelectionIndex(Index)
    self.CurrentSelectType = Index

    if self.CurrentSelectType == FashionDecoDefine.FashionDecoType.Wing then
        local Num = FashionDecoMgr:GetFashionDecoNumByType(FashionDecoDefine.FashionDecoType.Wing)
        self.bShowPanelBtnAmeliorate = Num > 0
    else
        self.bShowPanelBtnAmeliorate = false
    end
end

--更新所有的当前类型
function FashionDecoSideFrameWinVM:UpdateBestType()
    self.CurrentSelectType = self:GetBestFirstIndex()
end

function FashionDecoSideFrameWinVM:SetSettingPanel(InState)
    self.SettingPanelVisible = InState
end


function FashionDecoSideFrameWinVM:GetAllReadStatus()
    return FashionDecoMgr:GetAllReadStatus()
end

--改变配饰类型（雨伞/翅膀）
function FashionDecoSideFrameWinVM:OnSelectChangedItem(InIndex)
    if InIndex < FashionDecoDefine.FashionDecoType.Umbrella then
        return
    end
    self.ListSlotItemListVM = self:ResetBindableList(self.ListSlotItemListVM,FashionDecoSlotItemVM)
    self.ListActionItemListVM = nil
    self.CurrentSelectedIsCollect = false
    self.CurrentSelectedName = nil
    self.CurrentSelectedID = 0
    if InIndex == FashionDecoDefine.FashionDecoType.Umbrella then
        self.ListSlotItemListVM:UpdateByValues(FashionDecoMgr:GetListDataByType(InIndex,FashionDecoSlotItemVM))
        self.SettingBtnVisible = true
        self.CurrentSelectType = FashionDecoDefine.FashionDecoType.Umbrella
    end

    if InIndex == FashionDecoDefine.FashionDecoType.Wing then
        self.ListSlotItemListVM:UpdateByValues(FashionDecoMgr:GetListDataByType(InIndex,FashionDecoSlotItemVM))
        self.SettingBtnVisible = false
        self.SettingPanelVisible = false
        self.CurrentSelectType = FashionDecoDefine.FashionDecoType.Wing
    end
    local curvalue = self:GetElementNumOnCurrentType()
    if curvalue > 0  then
        self.ToggleBtnCollectVisible = true
        self.BtnWearVisible = true
    else
        self.SettingBtnVisible = false
        self.BtnWearVisible = false
        self.ToggleBtnCollectVisible = false
        self.TextActionVisible = false
    end
    self.UpdateToSelectFirstIndex = not self.UpdateToSelectFirstIndex
    _G.ObjectMgr:CollectGarbage(false)
    --_G.FLOG_INFO("选择新类型触发选择 %d",InIndex)
end
function FashionDecoSideFrameWinVM:GetBestFirstIndex()
    return FashionDecoMgr:GetFirstUnlockedType()
end
function FashionDecoSideFrameWinVM:GetElementNumOnCurrentType()
    local curvalue = FashionDecoMgr:GetTypeNum(self.CurrentSelectType)
    return curvalue
end

return FashionDecoSideFrameWinVM