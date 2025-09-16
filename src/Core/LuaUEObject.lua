---
--- Author: anypkvcai
--- Date: 2020-08-08 14:46:07
--- Description:
---

local NotExist = {}

--local LuaClass = require("Core/LuaClass")

----@class LuaUEObject
local LuaUEObject = {}

function LuaUEObject:Ctor()
	self.Object = nil

	local MetaTable = {}

	function MetaTable.__index(Table, Key)
		local BaseType = rawget(Table, "__BaseType")
		if nil == BaseType then
			return
		end

		local Value, Type = Table.__FindValue(BaseType, Key)
		if nil ~= Value then
			Table.__Current = Type
			return Value
		end

		local Object = rawget(Table, "Object")
		if nil == Object then
			return
		end

		if not Object:IsValid() then
			-- TODO 临时定位bug 后面要删掉
			local Msg = string.format("LuaUEObject: Object is Invalid, ObjectName=%s AncestorName=%s Key=%s", rawget(Table, "ObjectName"), rawget(Table, "AncestorName"), Key)
			_G.FLOG_WARNING(Msg)
			--_G.UIViewMgr:DumpPoolWidgets()
			--_G.TimerMgr:DumpName()
			local CommonUtil = require("Utils/CommonUtil")
			CommonUtil.ReportCustomError(Msg, debug.traceback(), debug.traceback(), true)
		end

		local V = Object[Key]
		if nil ~= V then
			if type(V) == "function" then
				rawset(Table, Key, V)
			elseif rawequal(V, NotExist) then
				return
			end
		else
			local MT = getmetatable(Object)
			rawset(MT, Key, NotExist)
		end

		return V
	end

	function MetaTable.__newindex(Table, Key, Value)
		local Object = rawget(Table, "Object")
		if nil ~= Object then
			local V = Object[Key]

			if V ~= nil and V ~= NotExist then
				Object[Key] = Value
				return
			end
		end

		rawset(Table, Key, Value)
	end

	setmetatable(self, MetaTable)
end

return LuaUEObject