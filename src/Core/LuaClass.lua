---
--- Author: anypkvcai
--- Date: 2020-08-05 15:44:47
--- Description:
--- 通过LuaClass实现的类 通过New来创建对象 类似C++的类和对象 创建对象是会自动递归调用构造函数
--- 如果直接使用类 相当于C++静态类 需要调用StaticConstructor函数才能触发构造函数
--- SupportVirtualTable为true时 可以实现虚函数和通过Super调用父类函数 但是性能不好 如果用不到虚函数 建议SupportVirtualTable不要传递true
--- 目前自动生成的View代码类SupportVirtualTable默认使用true


local function LuaClass(InBaseType, SupportVirtualTable)
	local ClassType = {}

	local Construct
	Construct = function(InClassType, InObject, ...)
		local BaseType = rawget(InClassType, "__BaseType")
		if nil ~= BaseType then
			Construct(BaseType, InObject, ...)
		end

		local Ctor = rawget(InClassType, "Ctor")
		if Ctor then
			Ctor(InObject, ...)
		end
	end

	local Constructor = function(InObject, ...)
		return Construct(ClassType, InObject, ...)
	end

	local StaticConstructor = function(InClassType, ...)
		return Construct(InClassType, InClassType, ...)
	end

	if SupportVirtualTable then
		local FindValue
		FindValue = function(InClassType, Key)
			if nil == InClassType then
				return
			end

			local RawValue = rawget(InClassType, Key)
			if nil ~= RawValue then
				return RawValue, InClassType
			end

			if nil == InClassType.__VirtualTable then
				return
			end

			local Value = rawget(InClassType.__VirtualTable, Key)
			if nil ~= Value then
				return Value, InClassType
			end

			local BaseType = rawget(InClassType, "__BaseType")
			if nil ~= BaseType then
				return FindValue(BaseType, Key)
			end
		end

		local New = function(...)
			local Object = {}
			Object.__BaseType = ClassType
			Object.__Current = ClassType
			Object.__FindValue = FindValue

			local ObjectIndex = function(_, Key)
				local Value, Type = FindValue(Object.__BaseType, Key)
				if nil == Value then
					return
				end
				Object.__Current = Type
				return Value
			end

			setmetatable(Object, { __index = ObjectIndex })

			local SuperIndexInternal = function(_, ...)
                local Current = Object.__Current
                if nil == Current then
                    return
                end

                local Value, Type = FindValue(Current.__BaseType, Object.__SuperKey)
                if nil == Value then
                    return
                end

                Object.__Current = Type
                local Result = { Value(Object, ...) }
                Object.__Current = Current

                return table.unpack(Result)
            end

			local SuperIndex = function(_, Key)
                Object.__SuperKey = Key
				return SuperIndexInternal
			end

			Object.Super = setmetatable({}, { __index = SuperIndex })

			Construct(ClassType, Object, ...)

			return Object
		end

		local Index = function(Object, Key)
			return FindValue(Object, Key)
		end

		ClassType.Ctor = false
		ClassType.New = New
		ClassType.Constructor = Constructor
		ClassType.StaticConstructor = StaticConstructor
		ClassType.__BaseType = InBaseType
		ClassType.__VirtualTable = {}

		setmetatable(ClassType, { __index = Index, __newindex = ClassType.__VirtualTable })
	else
		local New = function(...)
			local Object = {}

			setmetatable(Object, { __index = ClassType })

			Construct(ClassType, Object, ...)

			return Object
		end

		ClassType.Ctor = false
		ClassType.New = New
		ClassType.Constructor = Constructor
		ClassType.StaticConstructor = StaticConstructor
		ClassType.Super = InBaseType
		ClassType.__BaseType = InBaseType

		setmetatable(ClassType, { __index = InBaseType })
	end

	return ClassType
end

return LuaClass