local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local FashionDecoDefine = require("Game/FashionDeco/VM/FashionDecoDefine")
local FashionDecoSettingTipsVM = require("Game/FashionDeco/VM/FashionDecoSettingTipsVM")
local FashionDecoSlotItemVM = require("Game/FashionDeco/VM/FashionDecoSlotItemVM")
local FashionDecoActionItemVM = require("Game/FashionDeco/VM/FashionDecoActionItemVM")
local FashionDecoMgr = require("Game/FashionDeco/FashionDecoMgr")
local CommTabsDefine = require("Game/Common/Tab/CommTabsDefine")
local DataReportUtil = require("Utils/DataReportUtil")
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
--设置当前选择的item
function FashionDecoSideFrameWinVM:SetCurrentSelectedItem(InNewItem)
    if self.CurrentSelectedItem ~= nil and (InNewItem.ID == self.CurrentSelectedItem.ID  ) then
        return
    end
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
    self.CurrentSelectedItem = nil
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

function FashionDecoSideFrameWinVM:WearCurrentFashionDeco()
    if FashionDecoMgr:CheckFashionDecorateHiddenState(self.CurrentSelectType) then
        --336005 当前状态无法装备
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
            FashionDecoMgr:SingAndSendClothing(self.CurrentSelectedID,bIsUmbrella,true)
            DataReportUtil.ReportEasyUseFlowData(3, self.CurrentSelectedID, 4)
        end
end

function FashionDecoSideFrameWinVM:SetTabsSelectionIndex(Index)
    self.CurrentSelectType = Index
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

--改变了类型
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