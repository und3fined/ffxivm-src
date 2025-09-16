---
--- Author: anypkvcai
--- DateTime: 2023-04-06 15:42
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local CommMenuParentVM = require("Game/Common/Menu/CommMenuParentVM")
local WidgetCallback = require("UI/WidgetCallback")
local UIAdapterTreeView = require("UI/Adapter/UIAdapterTreeView")
local UIBindableList = require("UI/UIBindableList")
local UIUtil = require("Utils/UIUtil")
local ParentDesiredSize = 120
local ChildDesiredSize = 92
local MenuDesiredSize = 0

---@class CommMenuView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TreeViewMenu UFTreeView
---@field ParamColorNormal SlateColor
---@field ParamColorSelect SlateColor
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommMenuView = LuaClass(UIView, true)

function CommMenuView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TreeViewMenu = nil
	--self.ParamColorNormal = nil
	--self.ParamColorSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommMenuView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommMenuView:OnInit()
	self.OnSelectionChanged = WidgetCallback.New()
	self.AdapterMenu = UIAdapterTreeView.CreateAdapter(self, self.TreeViewMenu, self.OnSelectChanged, true, false, false, true)
	local function GetSelectKey()
		return self:GetLastSelectKey()
	end

	local Param = { ColorNormal = self.ParamColorNormal, ColorSelect = self.ParamColorSelect, GetKeyFun = GetSelectKey}
	self.AdapterMenu:SetParams(Param)
    self.SelectedChildKeyMap = {}
	self.ListData = {}
	self.BindableListChildren = UIBindableList.New(CommMenuParentVM)
	self.IsCacheLastIndex = true   ----自动存储上次选择的子页签
end

function CommMenuView:SetIsCacheLastChildIndex(IsCache)
	self.IsCacheLastIndex = IsCache
end

function CommMenuView:SetAlwaysNotifySelectChanged(AlwaysNotifySelectChanged)
	-- if self.AdapterMenu ~= nil then
	-- 	self.AdapterMenu:SetAlwaysNotifySelectChanged(AlwaysNotifySelectChanged)
	-- end
end

function CommMenuView:OnDestroy()
	self.OnSelectionChanged:Clear()
	self.OnSelectionChanged = nil
end

function CommMenuView:OnShow()
	MenuDesiredSize = UIUtil.GetWidgetSize(self.TreeViewMenu).Y
end

function CommMenuView:OnHide()
	self.LastMainSelectedKey = nil
	self.LastSubSelectKey = nil
	self.ListData = {}
end

function CommMenuView:OnRegisterUIEvent()

end

function CommMenuView:OnRegisterGameEvent()

end

function CommMenuView:OnRegisterBinder()

end

function CommMenuView:OnSelectChanged(Index, ItemData, ItemView, IsByClick)
	self:ProcessSelectAction(ItemData)
	if self.NeedTrigger then
		self.OnSelectionChanged:OnTriggered(Index, ItemData, ItemView, self.LastMainSelectedKey, self.LastSubSelectKey, IsByClick)
	end
end

---UpdateItems @选中需要调用 SetSelectedIndex  或  SetSelectedKey函数
---@param ListData table
---@param bAutoExpandAll boolean
function CommMenuView:UpdateItems(ListData, bAutoExpandAll)
	self.ListData = ListData
	if next(self.ListData) then
		self:CollapseAll()
	end

	self.BindableListChildren:UpdateByValues(ListData)
	self:InitSelectedChildKeyMap(ListData)
	local AdapterMenu = self.AdapterMenu
	AdapterMenu:SetAutoExpandAll(bAutoExpandAll)
	AdapterMenu:UpdateAll(self.BindableListChildren)
end

---SetSelectedIndex @只有一级菜单 通过索引选中更方便
---@param SelectedIndex number
function CommMenuView:SetSelectedIndex(SelectedIndex)
	self.AdapterMenu:SetSelectedIndex(SelectedIndex)
end

---SetSelectedKey @如果有二级菜单 需要通过Key选中
---@param Key any @列表中的对象 需要实现GetKey函数
---@param IsExpandItem boolean
function CommMenuView:SetSelectedKey(Key, IsExpandItem)
	local ParentKey = self:GetParentKey(Key)
	if nil ~= ParentKey then
		self.AdapterMenu:SetIsExpansion(ParentKey, IsExpandItem)
	end

	self.AdapterMenu:SetSelectedKey(Key, IsExpandItem)
	if IsExpandItem then
		self:RegisterTimer(function()
			self:FixScrollRealOffsetByKey(Key)
		end, 0.01, 0, 1)
	end
end

---@param Key any @列表中的对象 需要实现GetKey函数
---@param IsExpandItem boolean @是否展开
function CommMenuView:SetIsExpansion(Key, IsExpandItem)
	return self.AdapterMenu:SetIsExpansion(Key, IsExpandItem)
end

---ExpandAll
function CommMenuView:ExpandAll()
	self.AdapterMenu:ExpandAll()
end

---CollapseAll
function CommMenuView:CollapseAll()
	self.AdapterMenu:CollapseAll()
end

function CommMenuView:CancelSelected()
	self.AdapterMenu:CancelSelected()
	self.LastMainSelectedKey = nil
	self.LastSubSelectKey = nil
end

function CommMenuView:GetParentKey(InKey)
	local MenuItems = self.BindableListChildren:GetItems()
	if nil == MenuItems then
		return
	end

	for i = 1, #MenuItems do
		local Item = MenuItems[i]
		local Key = Item:GetKey()
		if Key == InKey then
			return
		end
		if nil ~= Item:FindChild(InKey) then
			return Key
		end
	end
end

function CommMenuView:InitSelectedChildKeyMap(MenuData)
	if nil == MenuData or #MenuData == 0 then
		return
	end

	self.SelectedChildKeyMap = {}

	for i = 1, #MenuData do
		local Children = MenuData[i].Children
		local ChildKey = nil
		if nil ~= Children and #Children > 0 then
			ChildKey = Children[1].Key
		end
		table.insert(self.SelectedChildKeyMap, { ParentKey = MenuData[i].Key, ChildKey = ChildKey })
	end

	self.LastSelectedKey = MenuData[1].Key
end

function CommMenuView:IsParentKey(InKey)
	for _, Value in ipairs(self.SelectedChildKeyMap) do
		if Value.ParentKey == InKey then
			return true
		end
	end

	return false
end

function CommMenuView:GetSelectedChildKey(InKey)
	if not self.IsCacheLastIndex then 
		local ChildData = self.ListData[InKey] and self.ListData[InKey].Children or {}
		if next(ChildData) then
			return ChildData[1].Key
		end
	else
		for _, Value in ipairs(self.SelectedChildKeyMap) do
			if Value.ParentKey == InKey then
				return Value.ChildKey
			end
		end	
	end
end

function CommMenuView:SetSelectedChildKey(ParentKey, ChildKey)
	if not self.IsCacheLastIndex then return end
		
	for _, Value in ipairs(self.SelectedChildKeyMap) do
		if Value.ParentKey == ParentKey then
			Value.ChildKey = ChildKey
			break
		end
	end
end

function CommMenuView:CollapseItems(InKey)
	if nil == InKey then
		self:CollapseAll()
	else
		for _, Value in ipairs(self.SelectedChildKeyMap) do
			if Value.ParentKey ~= InKey then
				self:SetIsExpansion(Value.ParentKey, false)
			end
		end
	end
end

function CommMenuView:ProcessSelectAction(ItemData)
	--_G.FLOG_INFO("CommMenuView:ProcessSelectAction")
	self.NeedTrigger = true
	local CurSelectedKey = ItemData:GetKey()
	local CurParentKey = self:GetParentKey(CurSelectedKey)
	if CurParentKey then
		self:OnSubTabClick(CurSelectedKey, CurParentKey)
	else
		self:OnMainTabClick(CurSelectedKey)	
	end
end

function CommMenuView:FixScrollRealOffsetByKey(Key)
	local MainIndex 
	local ChildIndexPos
	local RealSize

	for i, v in ipairs(self.ListData) do
		local ChildData = self.ListData[i] and self.ListData[i].Children or {}
		if next(ChildData) then
			for ChildIndex, ChildData in ipairs(ChildData) do
				if ChildData.Key == Key then
					MainIndex = i
					ChildIndexPos = ChildIndex
					break
				end
			end
		end
	end

	if not MainIndex or not ChildIndexPos then return end
	RealSize = MainIndex * ParentDesiredSize + ChildDesiredSize * ChildIndexPos
	
	local ScrollOffset
	if MenuDesiredSize ~= 0 and RealSize > MenuDesiredSize then
		if RealSize - MainIndex * ParentDesiredSize > MenuDesiredSize then
			ScrollOffset = (RealSize - MenuDesiredSize - MainIndex * ParentDesiredSize) / ChildDesiredSize + MainIndex
		else
			ScrollOffset = (RealSize - MenuDesiredSize) / ParentDesiredSize
		end
	end

	if ScrollOffset then
		local CurOffset = 0
		self:RegisterTimer(function()
			CurOffset = (CurOffset + 1) < ScrollOffset and CurOffset + 1 or ScrollOffset
			self.AdapterMenu:SetScrollOffset(CurOffset)
		end, 0.1, 0.01, math.ceil(ScrollOffset))
	end
end

function CommMenuView:OnMainTabClick(ParentIndex)
	local SoftPath = _G.UE.FSoftObjectPath()
	SoftPath:SetPath("/Game/WwiseAudio/Events/UI/UI_SYS/New/Play_FM_FirstNaviBar.Play_FM_FirstNaviBar")
	self.TreeViewMenu.SoundPathOnClick = SoftPath
	if not self.LastMainSelectedKey or self.LastMainSelectedKey ~= ParentIndex then
		if self.LastMainSelectedKey then
			local Index = self:GetParentIndexByParentKey(self.LastMainSelectedKey)
			local Widget = self.AdapterMenu:GetChildWidget(Index)
			if Widget and Index then
				Widget:OnSelectChanged(false)
			end

			self.LastSubSelectKey = nil
		end
		
		self.SubTabShow = false
		self:CollapseItems(ParentIndex)
		self.AdapterMenu:SetIsExpansion(ParentIndex, true)
		self.LastMainSelectedKey = ParentIndex
		local ChildKey = self:GetSelectedChildKey(ParentIndex)
		if ChildKey and (not self.LastSubSelectKey or self.LastSubSelectKey ~= ChildKey) then
			self.SubTabShow = true
			self:SetSelectedKey(ChildKey, true)
			self:SetSelectedChildKey(ParentIndex, ChildKey)
			self.NeedTrigger = false
		end
	else
		if self.LastSubSelectKey then
			if self.SubTabShow then
				self.AdapterMenu:SetIsExpansion(ParentIndex, false)
				self.SubTabShow = false
			else
				self.SubTabShow = true
				self:SetSelectedKey(self.LastSubSelectKey, true)
			end
		end

		self.NeedTrigger = false
	end
end

function CommMenuView:OnSubTabClick(ChildKey, CurParentKey)
	if not self.LastMainSelectedKey then
		self.SubTabShow = true
	end

	self.LastMainSelectedKey = CurParentKey
	local SoftPath = _G.UE.FSoftObjectPath()
	SoftPath:SetPath("/Game/WwiseAudio/Events/UI/UI_SYS/New/Play_FM_ChildNaviBar.Play_FM_ChildNaviBar")
	self.TreeViewMenu.SoundPathOnClick = SoftPath
	if not self.LastSubSelectKey or self.LastSubSelectKey ~= ChildKey then
		self.LastSubSelectKey = ChildKey
		self:SetSelectedChildKey(CurParentKey, ChildKey)
		self:CollapseItems(CurParentKey)
		self.AdapterMenu:SetIsExpansion(CurParentKey, true)
	else
		self.NeedTrigger = false
	end
end

function CommMenuView:GetLastSelectKey()
	return self.LastMainSelectedKey, self.LastSubSelectKey
end

function CommMenuView:ScrollToItemByKey(Key)
	if not self.LastMainSelectedKey then return end
	local Index 
	if self:IsParentKey(Key) then
		Index = self:GetParentIndexByParentKey(Key)
	else
		Index = self:GetChildIndexByChildKey(Key)
	end
	
	if Index then
		self.AdapterMenu:ScrollToIndex(Index)
	end
end

function CommMenuView:GetParentIndexByParentKey(Key)
	if next(self.ListData) then
		for i, v in ipairs(self.ListData) do
			if v.Key == Key then
				return i
			end
		end
	end
end

function CommMenuView:GetChildIndexByChildKey(Key)
	for i, v in ipairs(self.ListData) do
		local ChildData = self.ListData[i] and self.ListData[i].Children or {}
		if next(ChildData) then
			for ChildIndex, ChildData in ipairs(ChildData) do
				if ChildData.Key == Key then
					return ChildIndex + i
				end
			end
		end
	end
end

return CommMenuView