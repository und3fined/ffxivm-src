---
--- Author: anypkvcai
--- DateTime: 2021-07-16 19:11
--- Description:
---


local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local UIViewModelConfig = require("Define/UIViewModelConfig")

local FLOG_ERROR = _G.FLOG_ERROR


---@class UIViewModelMgr : MgrBase
---@field ViewModels table<UIViewModel>

local UIViewModelMgr = LuaClass(MgrBase)

function UIViewModelMgr:OnInit()
	self:InitViewModel()
end

function UIViewModelMgr:OnBegin()
end

function UIViewModelMgr:OnEnd()
end

function UIViewModelMgr:OnShutdown()
	self.ViewModels = nil
end

function UIViewModelMgr:InitViewModel()
	self.ViewModels = {}

	for _, v in ipairs(UIViewModelConfig) do
		local ViewModel = require(v.Path)

		if nil == ViewModel then
			FLOG_ERROR("UIViewModelMgr:InitViewModel ViewModel is nil, %s", v.Path)
		elseif nil ~= self.ViewModels[v.Name] then
			FLOG_ERROR("UIViewModelMgr:InitViewModel ViewModel already exists, %s", v.Path)
		else
			ViewModel:StaticConstructor()
			_G[v.Name] = ViewModel
			self.ViewModels[v.Name] = ViewModel
		end
	end
end

--不递归子table
local function table_to_string(t)
	local Result = {}
	if type(t) == "table" then
		table.insert(Result, "{")
		for key, value in pairs(t) do
			table.insert(Result, key .. "=")
			table.insert(Result, tostring(value))
			table.insert(Result, ",")
		end
		if Result[#Result] == ',' then
			table.remove(Result, #Result)
		end
		table.insert(Result, "}")
	end
	return table.concat(Result)
end

--打印指定命名静态VM所有BindableProperty(PropertyName, Value)
function UIViewModelMgr:ShowViewModelProperty(...)
	local NameList = {...}
	if not self.ViewModels or #NameList == 0 then return end
	local Display = ""
	for _, VMName in ipairs(NameList) do
		local ViewModel = self.ViewModels[VMName]
		if not ViewModel then return end
		local Result = ViewModel:GetViewModelPropertyPair() or {}
		Display = string.format("%s\n%s: %s", Display, VMName, table_to_string(Result))
	end

	print(string.format("ShowViewModelProperty:%s", Display))
end

return UIViewModelMgr