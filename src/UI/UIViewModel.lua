--
-- Author: anypkvcai
-- Date: 2020-08-05 15:43:46
-- Description: 用来存储UI需要显示的数据，尽量不要处理和UI显示无关的逻辑
-- WiKi: https://iwiki.woa.com/pages/viewpage.action?pageId=858296043
--

local CommonUtil = require("Utils/CommonUtil")
local UIBindableProperty = require("UI/UIBindableProperty")
local UIBindableObject = require("UI/UIBindableObject")
local UIBindableList = require("UI/UIBindableList")

local FLOG_ERROR = _G.FLOG_ERROR
local FLOG_WARNING = _G.FLOG_WARNING

---@class UIViewModel
---@field BindableProperties table<string, UIBindableProperty>
local UIViewModel = {}

---Ctor
function UIViewModel:Ctor()
	self.BindableProperties = {}

	local ObjectMetaTable = getmetatable(self)
	local ObjectIndex = ObjectMetaTable.__index

	local MetaTable = {}

	function MetaTable.__index(_, Key)
		local BindableProperty = self.BindableProperties[Key]
		if nil ~= BindableProperty then
			return BindableProperty:GetValue()
		end

		return ObjectIndex[Key]
	end

	function MetaTable.__newindex(Table, Key, Value)
		if nil ~= string.find(Key, "^__") then
			rawset(Table, Key, Value)
			return
		end

		local BindableProperties = self.BindableProperties
		local BindableProperty = BindableProperties[Key]
		if nil == BindableProperty then
			BindableProperty = UIBindableProperty.New()
			BindableProperties[Key] = BindableProperty
		end

		BindableProperty:SetValue(Value)

		if CommonUtil.IsA(Value, UIBindableObject) then
			Value:SetBindableProperty(BindableProperty)
		end
	end

	setmetatable(self, MetaTable)
end

---FindBindableProperty
---@param PropertyName string
---@return UIBindableProperty
function UIViewModel:FindBindableProperty(PropertyName)
	local BindableProperties = self.BindableProperties
	if BindableProperties == nil then
		_G.FLOG_ERROR("Try find BindableProperties, but self.BindableProperties is nil")
		return nil
	end
	return BindableProperties[PropertyName]
end

---RegisterBinder
---@param PropertyName string
---@param Binder UIBinder
function UIViewModel:RegisterBinder(PropertyName, Binder)
	local _ <close> = CommonUtil.MakeProfileTag("UIViewModel:RegisterBinder_0")

	local BindableProperty = self:FindBindableProperty(PropertyName)
	if nil == BindableProperty then
		return
	end

	local _ <close> = CommonUtil.MakeProfileTag("UIViewModel:RegisterBinder_1")
	BindableProperty:RegisterBinder(Binder)
end

---UnRegisterBinder
---@param PropertyName string
---@param Binder UIBinder
function UIViewModel:UnRegisterBinder(PropertyName, Binder)
	local BindableProperty = self:FindBindableProperty(PropertyName)
	if nil == BindableProperty then
		return
	end

	BindableProperty:UnRegisterBinder(Binder)
end

---SetNoCheckValueChange @设置是否检测Value值变化了才会调用OnValueChanged函数
---@param PropertyName string
---@param NoCheckValueChg boolean
function UIViewModel:SetNoCheckValueChange(PropertyName, NoCheckValueChg)
	local BindableProperty = self:FindBindableProperty(PropertyName)
	if nil == BindableProperty then
		return
	end

	BindableProperty:SetNoCheckValueChange(NoCheckValueChg)
end

function UIViewModel:PropertyValueChanged(PropertyName)
	local BindableProperty = self:FindBindableProperty(PropertyName)
	if nil == BindableProperty then
		return
	end

	BindableProperty:ValueChanged()
end

function UIViewModel:SetPropertyValue(PropertyName, Value)
	local BindableProperty = self:FindBindableProperty(PropertyName)
	if nil == BindableProperty then
		return
	end

	BindableProperty:SetValue(Value)
end

function UIViewModel:ResetBindableList(BindableList, VMClass)
	if nil == BindableList then
		BindableList = UIBindableList.New(VMClass)

	else
		BindableList:Clear()
	end

	return BindableList
end

---GetKey 获取唯一标记，可以在OnValueChanged 或 UpdateVM时初始化
---@return any
function UIViewModel:GetKey()
	return self.Key
end

--IsEqualVM、OnValueChanged、UpdateVM 可以参考 SampleTableViewItemVM

---IsEqualVM
---@param Value table
---@return boolean @返回true表示和当前的VM是相同的，如果已经显示不会再次创建，只通过Binder更新数据
function UIViewModel:IsEqualVM(Value)
	FLOG_WARNING("UIViewModel:IsEqualVM Error: Subclass must implement this method")

	-- 子类需要实现，如果和当前的VM是相同的返回true
	-- return nil ~= Value and Value.ID == self.Key
	return true
end

---UpdateVM  @如果由UIBindableList通过 AddByValue 或 UpdateByValues 更新列表，子类需要实现 UpdateVM，通过Value更新ViewModel
---默认是使用Hash值作为VM的唯一标识，如果指定了Key就用Key做为唯一标识，可以在UpdateVM的时候初始化
---@param Value any
---@param Param any
function UIViewModel:UpdateVM(Value, Param)
	FLOG_ERROR("UIViewModel:UpdateVM Error: Subclass must implement this method")

	-- 初始化Key值，整个列表要唯一不能重复，一般是ID
	-- self.Key = Value.ID
end

---OnValueChanged @对于要延迟更新，但是又要在UpdateVM之前访问的数据，可以在这里处理，比如：ID、Key、AdapterOnGetCanBeSelected或AdapterOnGetWidgetIndex要用到的数据
---@param Value table
---@param Param any
function UIViewModel:OnValueChanged(Value, Param)
	-- 初始化Key值，整个列表要唯一不能重复，一般是ID
	-- self.Key = Value.ID
end

---DelayUpdateVM
---@param Value table
---@param Params any
---@param bDelayUpdate boolean
function UIViewModel:UpdateByValue(Value, Params, bDelayUpdate)
	self:OnValueChanged(Value, Params)

	if bDelayUpdate and not self:IsRegistered() then
		rawset(self, "VMValue", Value)
		rawset(self, "VMParams", Params)
		rawset(self, "bPendingUpdate", true)
	else
		rawset(self, "VMValue", nil)
		rawset(self, "VMParams", nil)
		rawset(self, "bPendingUpdate", false)
		self:UpdateVM(Value, Params)
	end
end

---IsRegistered
---@return boolean
function UIViewModel:IsRegistered()
	local BindableProperties = self.BindableProperties
	if nil == BindableProperties then
		return false
	end

	for _, v in pairs(BindableProperties) do
		if v:IsRegistered() then
			return true
		end
	end

	return false
end

---PrevRegisterBinder
---@return boolean
function UIViewModel:PrevRegisterBinder()
	if rawget(self, "bPendingUpdate") then
		--print("UIViewModel:PrevRegisterBinder UpdateVM")
		rawset(self, "bPendingUpdate", false)
		self:UpdateVM(rawget(self, "VMValue"), rawget(self, "VMParams"))
	end
end

--[[
-- TableView 和 TreeView 可能要实现的函数

---AdapterOnGetCanBeSelected @[TableView | TreeView]不实现该函数 默认可以选中
---@return boolean @返回是否可以选中 列表里不能选中的返回false、树形控件父节点一般返回false
function UIViewModel:AdapterOnGetCanBeSelected()
	return true
end

---AdapterOnGetIsVisible @[TableView | TreeView]不实现该函数 默认显示
---@return boolean @返回是否显示
function UIViewModel:AdapterOnGetIsVisible()
	return true
end

---AdapterOnGetWidgetIndex @[TableView | TreeView] 如果列表里所有Item相同 不用实现该函数
---@return number @返回UMG控件里配置的EntryWidgetClass数组索引 从0开始
function UIViewModel:AdapterOnGetWidgetIndex()
	return 0
end

---AdapterOnGetIsCanExpand @[TreeView]不实现该函数 默认可以展开
---@return boolean @返回是否可以展开树形控件子节点
function UIViewModel:AdapterOnGetIsCanExpand()
	return true
end

---AdapterOnGetChildren @[TreeView]
---@return table @返回树形控件子节点
function UIViewModel:AdapterOnGetChildren()
	return {}
end

---AdapterOnExpansionChanged @[TreeView]
---@param IsExpanded boolean
function UIViewModel:AdapterOnExpansionChanged(IsExpanded)

end
--]]

--====================   生命期相关逻辑 begin、end ==================================
-- UIViewModelConfig中配置的才会有效，动态创建的vm是不用这些的
function UIViewModel:Init()
	self:OnInit()
end

function UIViewModel:Begin()
	self:OnBegin()
end

function UIViewModel:End()
	self:OnEnd()
end

function UIViewModel:Shutdown()
	self:OnShutdown()
end

function UIViewModel:OnInit()

end

function UIViewModel:OnBegin()

end

function UIViewModel:OnEnd()

end

function UIViewModel:OnShutdown()

end

--====================   生命期相关逻辑 begin、end ==================================

function UIViewModel:GetViewModelPropertyPair()
	local BindableProperties = self.BindableProperties
	if not BindableProperties then return end
	local Result = {}
	for PropertyName, BindableProperty in pairs(BindableProperties) do
		Result[PropertyName] = BindableProperty:GetValue()
	end

	return Result
end

return UIViewModel