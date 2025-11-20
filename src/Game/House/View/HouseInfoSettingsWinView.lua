---
--- Author: mingyyzhang
--- DateTime: 2025-06-18 16:38
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local HouseInfoSettingsWinVM = require("Game/House/VM/HouseInfoSettingsWinVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local HouseLocalDef = require("Game/House/HouseLocalDef")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MathUtil = require("Utils/MathUtil")
local CommonUtil = require("Utils/CommonUtil")
local ProtoRes = require("Protocol/ProtoRes")
local GroupPermissionType = ProtoRes.GroupPermissionType

---@class HouseInfoSettingsWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSaveHouseInfo CommBtnLView
---@field BtnSaveTag CommBtnLView
---@field BtnSaveViewPermissions CommBtnLView
---@field Comm2FrameL_UIBP Comm2FrameLView
---@field CommCheckBox1 CommCheckBoxView
---@field CommCheckBox2 CommCheckBoxView
---@field CommCheckBox3 CommCheckBoxView
---@field CommInputBox CommInputBoxView
---@field CommMultilineInputBox CommMultilineInputBoxView
---@field Menu CommMenuView
---@field PanelHouseInfo UFCanvasPanel
---@field PanelOther UFVerticalBox
---@field PanelTag UFCanvasPanel
---@field PanelViewPermissions UFCanvasPanel
---@field TableViewList1 UTableView
---@field TableViewList2 UTableView
---@field TableViewTag UTableView
---@field TextGiveUp UFTextBlock
---@field TextGreetings UFTextBlock
---@field TextHouseName UFTextBlock
---@field TextPermissionsHint UFTextBlock
---@field TextTag UFTextBlock
---@field TextTearDown UFTextBlock
---@field TextViewPermissions UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HouseInfoSettingsWinView = LuaClass(UIView, true)
local EToggleButtonState = _G.UE.EToggleButtonState
local ProtoCS = require("Protocol/ProtoCS")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local MajorUtil = require("Utils/MajorUtil")

local MenuList = {
	{
		Key = 1,
		Name = LSTR("房屋信息")
	},
	{
		Key = 2,
		Name = LSTR("宣传标签")
	},
	{
		Key = 3,
		Name = LSTR("出入和查看权限")
	}
	,
	{
		Key = 4,
		Name = LSTR("其他")
	}
}

function HouseInfoSettingsWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSaveHouseInfo = nil
	--self.BtnSaveTag = nil
	--self.BtnSaveViewPermissions = nil
	--self.Comm2FrameL_UIBP = nil
	--self.CommCheckBox1 = nil
	--self.CommCheckBox2 = nil
	--self.CommCheckBox3 = nil
	--self.CommInputBox = nil
	--self.CommMultilineInputBox = nil
	--self.Menu = nil
	--self.PanelHouseInfo = nil
	--self.PanelOther = nil
	--self.PanelTag = nil
	--self.PanelViewPermissions = nil
	--self.TableViewList1 = nil
	--self.TableViewList2 = nil
	--self.TableViewTag = nil
	--self.TextGiveUp = nil
	--self.TextGreetings = nil
	--self.TextHouseName = nil
	--self.TextPermissionsHint = nil
	--self.TextTag = nil
	--self.TextTearDown = nil
	--self.TextViewPermissions = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HouseInfoSettingsWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnSaveHouseInfo)
	self:AddSubView(self.BtnSaveTag)
	self:AddSubView(self.BtnSaveViewPermissions)
	self:AddSubView(self.Comm2FrameL_UIBP)
	self:AddSubView(self.CommCheckBox1)
	self:AddSubView(self.CommCheckBox2)
	self:AddSubView(self.CommCheckBox3)
	self:AddSubView(self.CommInputBox)
	self:AddSubView(self.CommMultilineInputBox)
	self:AddSubView(self.Menu)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HouseInfoSettingsWinView:OnInit()
	self.ViewModel = HouseInfoSettingsWinVM.New()
	self.TagViewListTableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewTag)
	self.TableViewList1TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList1)
	self.TableViewList2TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList2)
	self.Binders = {
		{"PanelHouseInfoVisible", UIBinderSetIsVisible.New(self, self.PanelHouseInfo)},
		{"PanelTagVisible", UIBinderSetIsVisible.New(self, self.PanelTag)},
		{"PanelViewPermissionsVisible", UIBinderSetIsVisible.New(self, self.PanelViewPermissions)},
		{"PanelOtherVisible", UIBinderSetIsVisible.New(self, self.PanelOther)},
		{ "TagNum", UIBinderValueChangedCallback.New(self, nil, self.OnTagNumValueChangedCallback)},
		{ "DestoryHouseConditions", UIBinderUpdateBindableList.New(self, self.TableViewList1TableViewAdapter) },
		{ "GiveUpLandConditions", UIBinderUpdateBindableList.New(self, self.TableViewList2TableViewAdapter) }}
	self.ViewModel:HouseTagInit()

	--设置固定值
	self.CommInputBox:SetHintText(HouseLocalDef.HouseInfoSettingWinStr.HouseNameHint)
	self.CommInputBox:SetMaxNum(14)
	self.CommMultilineInputBox:SetHintText(HouseLocalDef.HouseInfoSettingWinStr.GreetingHint)
	self.CommMultilineInputBox:SetMaxNum(100)
	self.TextHouseName:SetText(HouseLocalDef.HouseInfoSettingWinStr.HouseNameTittle)
	self.TextGreetings:SetText(HouseLocalDef.HouseInfoSettingWinStr.GreetingTittle)
	self.BtnSaveHouseInfo:SetButtonText(HouseLocalDef.HouseSaveStr)
	self.BtnSaveTag:SetButtonText(HouseLocalDef.HouseSaveStr)
	self.BtnSaveViewPermissions:SetButtonText(HouseLocalDef.HouseSaveStr)
	self.TextViewPermissions:SetText(HouseLocalDef.HouseInfoSettingWinStr.PermissionTittle)
	self.TextPermissionsHint:SetText(HouseLocalDef.HouseInfoSettingWinStr.PermissionHint)
	self.TextTearDown:SetText(HouseLocalDef.HouseInfoSettingWinStr.DestoryHouse)
	self.TextGiveUp:SetText(HouseLocalDef.HouseInfoSettingWinStr.GiveUpLand)
end

function HouseInfoSettingsWinView:OnDestroy()

end

function HouseInfoSettingsWinView:OnShow()
	self.ViewModel:InitParam(self.Params)

	local HouseType = self.ViewModel.HouseType 
	local MenuData = {}
	for i, v in ipairs(MenuList) do
		local NeedRemove = false
		if v.Key == 4 then
			NeedRemove = HouseType == HouseLocalDef.BuyHouseBelongType.Personal and not MajorUtil.IsMajorByRoleID(self.ViewModel.OwnerID)
			NeedRemove = NeedRemove or (HouseType == HouseLocalDef.BuyHouseBelongType.Army and not _G.ArmyMgr:IsLeader())
			NeedRemove = NeedRemove or HouseType == ProtoCS.HouseType.HouseType_HouseType_GroupMemberRoom
		elseif v.Key == 2 or v.Key == 3 then
			NeedRemove = HouseType == HouseLocalDef.BuyHouseBelongType.Army and not _G.ArmyMgr:GetSelfIsHavePermisstion(GroupPermissionType.PermissionTypeEstateGuestAccessAndTagSettings)
		elseif v.Key == 1 then
			NeedRemove = HouseType == HouseLocalDef.BuyHouseBelongType.Army and not _G.ArmyMgr:GetSelfIsHavePermisstion(GroupPermissionType.PermissionTypeEstateEditNameAndGreeting)
		end

		if not NeedRemove then
			table.insert(MenuData, v)
		end
	end

	self.Menu:UpdateItems(MenuData)
	self.Menu:SetSelectedIndex(1)
	if self.Params and self.Params.IsGroup then
		self.CommCheckBox1.TextContent:SetText(HouseLocalDef.HouseInfoSettingWinStr.AllPermission)
		self.CommCheckBox2.TextContent:SetText(HouseLocalDef.HouseInfoSettingWinStr.ArmyMemberPermission)
		UIUtil.SetIsVisible(self.CommCheckBox3, false)
	else
		self.CommCheckBox1.TextContent:SetText(HouseLocalDef.HouseInfoSettingWinStr.AllPermission)
		self.CommCheckBox2.TextContent:SetText(HouseLocalDef.HouseInfoSettingWinStr.FriendPermission)
		self.CommCheckBox3.TextContent:SetText(HouseLocalDef.HouseInfoSettingWinStr.SelfPermission)
		UIUtil.SetIsVisible(self.CommCheckBox3, true)
	end

	self.TagViewListTableViewAdapter:UpdateAll(self.ViewModel.HouseTagSelect)
	self:InitVisitPrivilege()
end

function HouseInfoSettingsWinView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.Menu, self.OnSelectionChangedCommMenu)
	UIUtil.AddOnClickedEvent(self, self.BtnSaveHouseInfo, self.OnClickSaveHouse)
	UIUtil.AddOnClickedEvent(self, self.BtnSaveTag, self.OnClickSaveTag)
	UIUtil.AddOnClickedEvent(self, self.BtnSaveViewPermissions, self.OnSaveViewPermissions)
	for i = 1, 3 do
		UIUtil.AddOnClickedEvent(self, self["CommCheckBox" .. i].ToggleButton, self.OnToggleButtonClick, i)
	end
end

function HouseInfoSettingsWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.HouseInfoModifyRsp, self.IsHouseInfoModifySuc)
	self:RegisterGameEvent(_G.EventID.HousePrivilegeModifyRsp, self.IsHousePrivilegeModifySuc)
	self:RegisterGameEvent(_G.EventID.HouseDestroyNotify, self.OnDestroyHouse)
	self:RegisterGameEvent(_G.EventID.HouseAbandonLand, self.OnAbandonLand)
end

function HouseInfoSettingsWinView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
end

--保存房屋信息
function HouseInfoSettingsWinView:OnClickSaveHouse()
	local IsEmpty = CommonUtil.GetStrLen(self.CommInputBox:GetText()) == 0
	--CommonUtil.GetStrLen(self.CommInputBox:GetText())
	if self.CommInputBox:GetText() == self.ViewModel.HouseName and self.CommMultilineInputBox:GetText() == self.ViewModel.HouseGreet then
		MsgTipsUtil.ShowTips(LSTR("未变更内容"))
		return
	end

	if IsEmpty == false then
		self.ViewModel.HouseName = self.CommInputBox:GetText()
		self.ViewModel.HouseGreet = self.CommMultilineInputBox:GetText()
	end

	self.ViewModel:RecordHouseInfo(IsEmpty)
end

--保存Tag
function HouseInfoSettingsWinView:OnClickSaveTag()
	local SaveTag = 0
	for i, v in ipairs(self.ViewModel.TagTable) do
		if v == 1 then
			SaveTag = SaveTag + i
		end
	end

	for i, v in ipairs(self.ViewModel.CacheTagTable) do
		SaveTag = SaveTag - v
	end

	if SaveTag == 0 then
		MsgTipsUtil.ShowTips(LSTR("未变更内容"))
	else
		self.ViewModel:RecordHouseInfo(false)
	end
end

--保存权限
function HouseInfoSettingsWinView:OnSaveViewPermissions()
	local CurCheck = 1
	for j = 1, 3 do
		local State = self["CommCheckBox" .. j].ToggleButton:GetCheckedState()
		if State == EToggleButtonState.Checked then
			CurCheck = j
			break
		end
	end

	local SaveCheckData = self.ViewModel.VisitPrivilege[1]
	if SaveCheckData.Value ~= CurCheck then
		local Data = {}
		for k, v in pairs(self.ViewModel.VisitPrivilege) do
			if not Data[k] then
				Data[k] = {}
			end
			Data[k].Typ = v.Typ
			Data[k].Value = CurCheck
		end

		_G.HouseInfoMgr:SendSetPrivilege(self.ViewModel.HouseID, Data)
	else
		MsgTipsUtil.ShowTips(LSTR("未变更内容"))
	end
end

--菜单切换
function HouseInfoSettingsWinView:OnSelectionChangedCommMenu(Index, ItemData, ItemView)
    local Key = ItemData.Key
    if Key == nil then
        return
    end
    self.ViewModel.Page = Key
	self.Comm2FrameL_UIBP:SetTitleText(HouseLocalDef.LocalTxtStr.HouseInfoSettingsTitle) --"时尚目标"
    if Key == 1 then
        self.CommInputBox:SetText(self.ViewModel.HouseName)
        self.CommMultilineInputBox:SetText(self.ViewModel.HouseGreet)
    end
    self.ViewModel.PanelHouseInfoVisible = Key == 1
    self.ViewModel.PanelTagVisible = Key == 2
    self.ViewModel.PanelViewPermissionsVisible = Key == 3
    self.ViewModel.PanelOtherVisible = Key == 4
end

--Tag数量显示
function HouseInfoSettingsWinView:OnTagNumValueChangedCallback()
	self.TextTag:SetText(string.format(HouseLocalDef.HouseSettingTag, self.ViewModel.TagNum, 3))
end

--权限设置
function HouseInfoSettingsWinView:OnToggleButtonClick(Index)
	for i = 1, 3 do
		local CurBtn = self["CommCheckBox" .. i].ToggleButton
		if i == Index then
			CurBtn:SetCheckedState(EToggleButtonState.Checked)
		else
			CurBtn:SetCheckedState(EToggleButtonState.UnChecked)
		end
	end
end

--初始化权限
function HouseInfoSettingsWinView:InitVisitPrivilege()
	if not self.ViewModel.VisitPrivilege then return end
	self.CommCheckBox1.ToggleButton:SetCheckedState(EToggleButtonState.UnChecked)
	self.CommCheckBox2.ToggleButton:SetCheckedState(EToggleButtonState.UnChecked)
	self.CommCheckBox3.ToggleButton:SetCheckedState(EToggleButtonState.UnChecked)

	for i = 1, #self.ViewModel.VisitPrivilege do         --目前两种权限的设置的设计是一起的 
		self["CommCheckBox" .. self.ViewModel.VisitPrivilege[i].Value].ToggleButton:SetCheckedState(EToggleButtonState.Checked)
	end
end

function HouseInfoSettingsWinView:IsHouseInfoModifySuc(MsgBody)
	if self.ViewModel.ModifyTypes[1] == ProtoCS.ModifyHouseInfoType.ModifyHouseInfoType_Tags then
		if MathUtil.EncodeUint(MsgBody.Tags) == MathUtil.EncodeUint(self.ViewModel.CacheTagTable) then
			MsgTipsUtil.ShowTips(LSTR("修改成功"))
		end
	else
		if self.ViewModel.HouseName == MsgBody.Name and self.ViewModel.HouseGreet == MsgBody.Greeting then
			MsgTipsUtil.ShowTips(LSTR("修改成功"))
		end
	end

	table.clear(self.ViewModel.ModifyTypes)
end

function HouseInfoSettingsWinView:IsHousePrivilegeModifySuc(MsgBody)
	if MsgBody and MsgBody.Setting then
		MsgTipsUtil.ShowTips(LSTR("修改成功"))
		if MsgBody and MsgBody.Setting and MsgBody.HouseID == self.ViewModel.HouseID then
			self.ViewModel.VisitPrivilege = MsgBody.Setting
			self:InitVisitPrivilege()
		end
	end
end

function HouseInfoSettingsWinView:OnDestroyHouse(HouseID)
	if HouseID == _G.HouseInfoMgr.ArmyHouseID or HouseID == _G.HouseInfoMgr.MajorHouseID then
		self:Hide()
	end
end

function HouseInfoSettingsWinView:OnAbandonLand()
	self:Hide()
end

return HouseInfoSettingsWinView