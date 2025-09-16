local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local CommScreenerClassItemVM = require("Game/Common/View/Screener/CommScreenerClassItemVM")

local FLOG_WARNING = _G.FLOG_WARNING


---@class CommScreenerTableItemVM : UIViewModel
local CommScreenerTableItemVM = LuaClass(UIViewModel)

---Ctor
function CommScreenerTableItemVM:Ctor()
    self.DropDown1Visible = nil
    self.DropDown2Visible = nil
    self.Title1Visible = nil
    self.Title2Visible = nil

    self.SelectListVisible = nil
    self.CheckBoxVisible = nil

    self.SelectListVMList = UIBindableList.New(CommScreenerClassItemVM)

    self.Title1Text = nil
    self.Title2Text = nil

    self.DropDown1List = nil
    self.DropDown1Index = nil
    self.DropDown2List = nil
    self.DropDown2Index = nil

    self.IsMultiple = nil
    self.SelectList = nil

    self.CheckBoxText = nil
    self.CheckBoxScreenerInfo = nil
    self.IsCheckedSingleBox = 0

    self.ScreenerID1 = nil
    self.ScreenerID2 = nil

    self.DropDown1Callback = nil
    self.DropDown2Callback = nil

    self.CheckBoxCallback = nil
end

function CommScreenerTableItemVM:UpdateVM(Value)
    local SelectList = Value.SelectList
    local DropDown1List = Value.DropDown1List
    local DropDown2List = Value.DropDown2List
    local Title1 = Value.Title1
    local Title2 = Value.Title2
    local CheckBoxScreenerInfo = Value.CheckBoxScreenerInfo

    self.SelectList = SelectList
    self.DropDown1List = DropDown1List
    self.DropDown2List = DropDown2List
    self.CheckBoxScreenerInfo = CheckBoxScreenerInfo

    self.Index = Value.Index
    self.ScreenerID1 = Value.ScreenerID1
    self.ScreenerID2 = Value.ScreenerID2
    self.IsMultiple = Value.IsMultiple

    self.ScreenerSelectedInfo = Value.ScreenerSelectedInfo
    if SelectList ~= nil then
        self:SetSelectListActivation()
    elseif Title1 ~= nil then
        self:SetTitleActivation(Title1, Title2)
    elseif DropDown1List ~= nil then
        self:SetDropDownActivation()
    elseif CheckBoxScreenerInfo ~= nil then
        self:SetCheckBoxActivation(CheckBoxScreenerInfo)
    else
        FLOG_WARNING("CommScreenerTableItemVM:UpdateItemByScreener is all nil")
    end
end

function CommScreenerTableItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.Index == self.Index and Value.ScreenerID == self.ScreenerID
end


function CommScreenerTableItemVM:SetTitleActivation(Title1, Title2)
    self.DropDown1Visible = false
    self.DropDown2Visible = false
    self.CheckBoxVisible = false
    self.SelectListVisible = false

    self.Title1Visible = Title1 ~= nil
    self.Title2Visible = Title2 ~= nil

    self.Title1Text = Title1
    self.Title2Text = Title2
end

function CommScreenerTableItemVM:SetCheckBoxActivation(CheckBoxScreenerInfo)
    self.DropDown1Visible = false
    self.DropDown2Visible = false
    self.SelectListVisible = false
    self.Title1Visible = false
    self.Title2Visible = false

    self.CheckBoxVisible = true
    self.CheckBoxText = CheckBoxScreenerInfo[1].ScreenerName
end

function CommScreenerTableItemVM:SetDropDownActivation()
    self.CheckBoxVisible = false
    self.SelectListVisible = false
    self.Title1Visible = false
    self.Title2Visible = false

    self.DropDown1Visible = self.DropDown1List  ~= nil
    self.DropDown2Visible = self.DropDown2List  ~= nil
end

function CommScreenerTableItemVM:SetSelectListActivation()
    self.DropDown1Visible = false
    self.DropDown2Visible = false
    self.Title1Visible = false
    self.Title2Visible = false
    self.CheckBoxVisible = false
   
    self.SelectListVisible = true

    self.SelectListVMList.UpdateVMParams = {ShowTag = self.IsMultiple}
    self.SelectListVMList:UpdateByValues(self.SelectList)
end


--通过选中信息设置选中
function CommScreenerTableItemVM:SetSelectListSelectedInfo(ScreenerSelectedInfo)
    if ScreenerSelectedInfo == nil then
        self:ResetSelected()
        return
    end

    local ScreenerList = {}
    for i = 1,#ScreenerSelectedInfo do
        local Screener = ScreenerSelectedInfo[i]
        if  self.ScreenerID1 == Screener.ScreenerID then
            ScreenerList[Screener.ID] = Screener
        end
    end

    if next(ScreenerList) == nil then
        self:ResetSelected()
        return
    end

    for i = 1, self.SelectListVMList:Length() do
		local ItemVM = self.SelectListVMList:Get(i)
        ItemVM:SetItemSelected(ScreenerList[ItemVM.Value.ID] ~= nil)
	end
    
end

--通过选中信息设置选中
function CommScreenerTableItemVM:SetDropDownSelectedInfo(ScreenerSelectedInfo)
    if ScreenerSelectedInfo == nil then
        self:ResetDropDown()
        return
    end

    local SelctedScreener1 = nil
    local SelctedScreener2 = nil
    for i = 1,#ScreenerSelectedInfo do
        local Screener = ScreenerSelectedInfo[i]
        if  self.ScreenerID1 == Screener.ScreenerID then
            SelctedScreener1 = Screener
        end

        if  self.ScreenerID2 == Screener.ScreenerID then
            SelctedScreener2 = Screener
        end
    end


    if SelctedScreener1 and self.DropDown1List then
        for i = 1,#self.DropDown1List do
            if self.DropDown1List[i].ID == SelctedScreener1.ID then
                self:SetDropDown1(i)
                break
            end
        end
    end
    
    if SelctedScreener2 and self.DropDown2List then
        for i = 1,#self.DropDown2List do
            if self.DropDown2List[i].ID == SelctedScreener2.ID then
                self:SetDropDown2(i)
                break
            end
        end
    end
end

--通过选中信息设置选中
function CommScreenerTableItemVM:SetCheckBoxSelectedInfo(ScreenerSelectedInfo)
    if ScreenerSelectedInfo == nil then
        self:ResetCheckBox()
        return
    end

    local SelctedScreener = nil
    for i = 1,#ScreenerSelectedInfo do
        local Screener = ScreenerSelectedInfo[i]
        if  self.ScreenerID1 == Screener.ScreenerID then
            SelctedScreener = Screener
            break
        end
    end

    if SelctedScreener == nil then
        self:ResetCheckBox()
        return
    end

    self:SetCheckBox(1)
end


function CommScreenerTableItemVM:ResetLastSingleSelectIndex(CurSelectedIndex)
	for i = 1, self.SelectListVMList:Length() do
		local ItemVM = self.SelectListVMList:Get(i)
        if i ~= CurSelectedIndex then
            ItemVM:ResetSelected()
        end
	end
end


function CommScreenerTableItemVM:ResetDropDown()
    self:SetDropDown1(1)
    self:SetDropDown2(1)
end

function CommScreenerTableItemVM:ResetCheckBox()
    self:SetCheckBox(0)
end

function CommScreenerTableItemVM:SetDropDown2(Index)
    if self.DropDown2Callback ~= nil then
        self.DropDown2Callback(Index)
    end
end

function CommScreenerTableItemVM:SetDropDown1(Index)
    if self.DropDown1Callback ~= nil then
        self.DropDown1Callback(Index)
    end
end

function CommScreenerTableItemVM:SetCheckBox(State)
    if self.CheckBoxCallback ~= nil then
        self.CheckBoxCallback(State)
    end
end


function CommScreenerTableItemVM:ResetSelected()
    for i = 1, self.SelectListVMList:Length() do
		local ItemVM = self.SelectListVMList:Get(i)
		ItemVM:ResetSelected()
	end
end

function CommScreenerTableItemVM:SetCheckedSingleBox(State)
    self.IsCheckedSingleBox = State
end

function CommScreenerTableItemVM:SetDropDown1Index(Index)
    self.DropDown1Index = Index
end

function CommScreenerTableItemVM:SetDropDown2Index(Index)
    self.DropDown2Index = Index
end

function CommScreenerTableItemVM:SetDropDown1Callback( func )
	self.DropDown1Callback = func
end

function CommScreenerTableItemVM:SetDropDown2Callback( func )
	self.DropDown2Callback = func
end

function CommScreenerTableItemVM:SetCheckBoxCallback( func )
	self.CheckBoxCallback = func
end


function CommScreenerTableItemVM:GetCheckBoxInfo()
    if self.IsCheckedSingleBox == 1 then
        return self.CheckBoxScreenerInfo[1]
    end
    return nil
end


--要返回当前类
return CommScreenerTableItemVM