--
-- Author: anypkvcai
-- Date: 2020-08-05 15:44:05
-- Description: 配合UIViewModule对注册到本模块的UIBinder对象进行值变化同步
-- 			值修改时，会调用UIBinder的OnValueChanged函数
-- WiKi: https://iwiki.woa.com/pages/viewpage.action?pageId=887418793

---@class UIBindableProperty
---@field Value any
---@field Binders table<UIBinder>
local UIBindableProperty = {}

function UIBindableProperty:Ctor()
	self.Value = nil
	self.Binders = {}
end

function UIBindableProperty.New()
	local Object = {}
	setmetatable(Object, { __index = UIBindableProperty })
	Object:Ctor()
	return Object
end

-- 参数是不检查value是否变化
-- 		一般是不传参数，是nil（需要检查value是否变化）
--		传true：不检查value是否变化
function UIBindableProperty:SetNoCheckValueChange(NoCheckValueChg)
	self.NoCheckValueChange = NoCheckValueChg
end

---ValueChanged @主动调用来触发Binders:OnValueChanged, 例如：Property类型是FVector2D, 只有X属性变了可以主动调用此函数
function UIBindableProperty:ValueChanged()
	local Value = self.Value

	self:OnValueChanged(Value, Value)
end

---SetValue
---@param Value any
function UIBindableProperty:SetValue(Value)
	local OldValue = self.Value
	if self.NoCheckValueChange or OldValue ~= Value then
		self.Value = Value
		self:OnValueChanged(Value, OldValue)
	end
end

---GetValue
---@return any
function UIBindableProperty:GetValue()
	return self.Value
end

---OnValueChanged
---@param NewValue any
---@param OldValue any
function UIBindableProperty:OnValueChanged(NewValue, OldValue)
	local Binders = self.Binders

	for i = #Binders, 1, -1 do
		local v = Binders[i]
		if nil ~= v then
			local _ <close> = CommonUtil.MakeProfileTag("UIBindableProperty:OnValueChanged_0")
			v:OnValueChanged(NewValue, OldValue)
		end
	end
end

---RegisterBinder
---@param Binder UIBinder
function UIBindableProperty:RegisterBinder(Binder)
	local _ <close> = CommonUtil.MakeProfileTag("UIBindableProperty:RegisterBinder_0")
	table.insert(self.Binders, Binder)

	local _ <close> = CommonUtil.MakeProfileTag("UIBindableProperty:RegisterBinder_1")
	Binder:OnValueChanged(self.Value, nil)
end

---UnRegisterBinder
---@param Binder UIBinder
function UIBindableProperty:UnRegisterBinder(Binder)
	local Binders = self.Binders

	for i = 1, #Binders do
		local v = Binders[i]
		if v == Binder then
			table.remove(Binders, i)
			return
		end
	end
end

---IsRegistered
---@return boolean
function UIBindableProperty:IsRegistered()
	return next(self.Binders)
end

return UIBindableProperty