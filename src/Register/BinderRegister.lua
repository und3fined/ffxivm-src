--
-- Author: anypkvcai
-- Date: 2020-08-11 18:32:47
-- Description:
--


local LuaClass = require("Core/LuaClass")

local BinderRegister = LuaClass()

local ObjectPoolMgr = _G.ObjectPoolMgr

---@class BinderRegister
function BinderRegister:Ctor()
	self.Registers = {}
end

---Register
---@param ViewModel UIViewModel
---@param PropertyName string
---@param Binder UIBinder
function BinderRegister:Register(ViewModel, PropertyName, Binder)
	local BinderTable = ObjectPoolMgr:AllocCommonTable()
	BinderTable.ViewModel = ViewModel
	BinderTable.PropertyName = PropertyName
	BinderTable.Binder = Binder
	table.insert(self.Registers, BinderTable)

	ViewModel:PrevRegisterBinder()
	ViewModel:RegisterBinder(PropertyName, Binder)
end

---RegisterBinders
---@param ViewModel UIViewModel
---@param Binders table<string,UIBinder>
function BinderRegister:RegisterBinders(ViewModel, Binders)
	if nil == ViewModel then
		_G.FLOG_ERROR("BinderRegister:RegisterBinders ViewModel is nil")
		_G.FLOG_ERROR(debug.traceback())
		return
	end

	do
		local _ <close> = CommonUtil.MakeProfileTag("BinderRegister:RegisterBinders_PrevRegister")
		ViewModel:PrevRegisterBinder()
	end

	for i = 1, #Binders do
		local _ <close> = CommonUtil.MakeProfileTag("BinderRegister:RegisterBinders_insert")
		local v = Binders[i]
		local PropertyName = v[1]
		if PropertyName == nil then
			_G.FLOG_ERROR("BinderRegister:RegisterBinders PropertyName is nil")
		end
		local Binder = v[2]

		local BinderTable = ObjectPoolMgr:AllocCommonTable()
		BinderTable.ViewModel = ViewModel
		BinderTable.PropertyName = PropertyName
		BinderTable.Binder = Binder
		table.insert(self.Registers, BinderTable)

		do
			local _ <close> = CommonUtil.MakeProfileTag("BinderRegister:RegisterBinders_viewmodel")

			ViewModel:RegisterBinder(PropertyName, Binder)
		end
	end
end

---RegisterMultiBinders
---@param MultiBinders table<UIViewModel,table<UIBinder>>
function BinderRegister:RegisterMultiBinders(MultiBinders)
	for i = 1, #MultiBinders do
		local v = MultiBinders[i]
		local ViewModel = v.ViewModel
		if ViewModel then
			self:RegisterBinders(ViewModel, v.Binders)
		end
	end
end

---UnRegisterBinder
---@param ViewModel UIViewModel
---@param PropertyName string
---@param Binder UIBinder
function BinderRegister:UnRegister(ViewModel, PropertyName, Binder)
	local Registers = self.Registers

	for i = #Registers, 1, -1 do
		local v = Registers[i]
		if v.ViewModel == ViewModel and v.PropertyName == PropertyName and v.Binder == Binder then
			ViewModel:UnRegisterBinder(PropertyName, Binder)
			local TableRemove = table.remove(self.Registers, i)
			ObjectPoolMgr:FreeCommonTable(TableRemove)
		end
	end
end

---UnRegisterBinders
---@param ViewModel UIViewModel
---@param Binders table<string,UIBinder>
function BinderRegister:UnRegisterBinders(ViewModel, Binders)
	for i = #Binders, 1, -1 do
		local v = Binders[i]
		local PropertyName = v[1]
		local Binder = v[2]

		self:UnRegister(ViewModel, PropertyName, Binder)
	end
end

---UnRegisterAll
function BinderRegister:UnRegisterAll()
	local Registers = self.Registers

	for i = #Registers, 1, -1 do
		local v = Registers[i]
		do
			local _ <close> = CommonUtil.MakeProfileTag(string.format("BinderRegister_UnRegisterBinder"))
			if nil ~= v.ViewModel then
				v.ViewModel:UnRegisterBinder(v.PropertyName, v.Binder)
			end
		end

		do
			local _ <close> = CommonUtil.MakeProfileTag(string.format("BinderRegister_FreeCommonTable"))
			ObjectPoolMgr:FreeCommonTable(v)
		end
	end

	table.clear(self.Registers)
end

return BinderRegister