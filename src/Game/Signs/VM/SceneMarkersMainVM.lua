

---
--- Author: ds_tianjiateng
--- DateTime: 2024-03-21 09:21
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local SignsSlotItemVM = require("Game/Signs/VM/ItemVM/SignsSlotItemVM")
local SceneMarkersItemVM = require("Game/Signs/VM/ItemVM/SceneMarkersItemVM")
local UIBindableList = require("UI/UIBindableList")
local ScenemarkCfg = require("TableCfg/ScenemarkCfg")

-- local TargetmarkCfg = require("TableCfg/TargetmarkCfg")

local LSTR = _G.LSTR

--- 保存列表空Item默认值
local SaveListEmptyItem = {
	Index = 0,
	TittleText = LSTR(1240004),		--- "点击存档"
	UTCTime = 0,
	IsEmpty = true,
	BtnBtnCoverVisible = false,
	BtnBtnDeleteVisible = false,
	BtnBtnAddVisible = true,
	IsEnable = false
}

local SaveListMaxLength = 30

---@class SceneMarkersMainVM : UIViewModel
local SceneMarkersMainVM = LuaClass(UIViewModel)

---Ctor
function SceneMarkersMainVM:Ctor()
	self.SelectedIndex = 0

	self.SignsSlots = UIBindableList.New(SignsSlotItemVM)
	self.SaveList = UIBindableList.New(SceneMarkersItemVM)

	self.SaveTimeText = ""

	self.IconMarkersFocus1Visible = false
	self.IconMarkersFocus2Visible = false
	self.IconMarkersFocus3Visible = false
	self.IconMarkersFocus4Visible = false
	self.IconMarkersFocus5Visible = false
	self.IconMarkersFocus6Visible = false
	self.IconMarkersFocus7Visible = false
	self.IconMarkersFocus8Visible = false
end

function SceneMarkersMainVM:OnInitViewData()
	--- 上面八个图标
	local TempScenemarkCfg = ScenemarkCfg:FindAllCfg()
	local IconList = {}
	for i = 1, #TempScenemarkCfg do
		local TempIconItem = {}
		TempIconItem.Index = i
		TempIconItem.IconPath = TempScenemarkCfg[i].IconPath
		TempIconItem.ResPath = TempScenemarkCfg[i].ResPath
		table.insert(IconList, TempIconItem)
	end
	self.SignsSlots:UpdateByValues(IconList)
	--- 保存列表
	self.SaveList:Clear()
	for i = 1, SaveListMaxLength do
		local TempSaveItem = _G.SignsMgr.SceneMarkersSaveList[i]
		local SeverDataIsEmpty = table.is_nil_empty(TempSaveItem)
		if SeverDataIsEmpty then
			TempSaveItem = SaveListEmptyItem
		end
		TempSaveItem.Index = i
		TempSaveItem.IsEmpty = SeverDataIsEmpty
		self.SaveList:AddByValue(TempSaveItem)
	end
end

function SceneMarkersMainVM:UpdateVM(Value)
	
end

function SceneMarkersMainVM:OnShutdown()
	
end

function SceneMarkersMainVM:OnUpdateSaveListByIndex(Index, Value)
	local TempItem = self.SaveList:Get(Index)
	--- 这里重新赋值下标，防止出现原下标
	Value.Index = Index
	TempItem:UpdateVM(Value)
end

function SceneMarkersMainVM:ClearAllItemUsed()
	for i = 1, self.SignsSlots:Length() do
		local Item = self.SignsSlots:Get(i)
		if Item then
			Item:SetIsUsed(false)
			self["IconMarkersFocus".. i .."Visible"] = false
		end
	end
end

--- 设置Slots使用
function SceneMarkersMainVM:OnSetItemUsedState(Index, IsUsed)
	Index = tonumber(Index)
	if self.SignsSlots == nil then
		return
	end
	local Item = self.SignsSlots:Get(Index)
	if Item then
		Item:SetIsUsed(IsUsed)
		self["IconMarkersFocus".. Index .."Visible"] = IsUsed
	end
end

--- 设置SaveList选中下标
function SceneMarkersMainVM:OnSetSelectedIndex(Index)
	Index = tonumber(Index)
	if self.SelectedIndex ~= 0 then
		local Item = self.SaveList:Get(self.SelectedIndex)
		Item.IsSelected = false
	end
	self.SelectedIndex = Index
	local Item = self.SaveList:Get(self.SelectedIndex)
	Item.IsSelected = true

	if Item.UTCTime == 0 then
		self.SaveTimeText = ""
	else
		local SaveTimeFormat = _G.TimeUtil.GetTimeFormat("%Y.%m.%d %H:%M", Item.UTCTime)
		self.SaveTimeText = string.format("%s%s", SaveTimeFormat, LSTR(1240007))		---  "保存"
	end
end

--- 清空单个存档
function SceneMarkersMainVM:OnResetSaveItemByIndex(Index)
	local TempItem = self.SaveList:Get(Index)
	local TempSaveListEmptyItem = SaveListEmptyItem
	TempSaveListEmptyItem.Index = Index
	TempItem:UpdateVM(TempSaveListEmptyItem)
	self.SaveTimeText = ""
end

function SceneMarkersMainVM:GetSlotView(Index)
	return self.SignsSlots:Get(Index)
end

function SceneMarkersMainVM:OnUpdateSaveListEnable(PworldID)
	for i = 1, self.SaveList:Length() do
		local TempItem = self.SaveList:Get(i)
        if TempItem then
			TempItem.IsSelected = false
            TempItem.IsEnable = TempItem.IsEmpty or TempItem.PworldID == PworldID
        end
	end

end
return SceneMarkersMainVM