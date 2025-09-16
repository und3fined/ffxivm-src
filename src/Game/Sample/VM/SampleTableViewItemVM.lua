--
-- Author: anypkvcai
-- Date: 2024-06-17 16:00
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
---@class SampleTableViewItemVM : UIViewModel
local SampleTableViewItemVM = LuaClass(UIViewModel)

---Ctor
function SampleTableViewItemVM:Ctor()
	self.Key = 0
	self.Name = ""
end

function SampleTableViewItemVM:IsEqualVM(Value)
	return self.Key == Value.ID
end

---OnValueChanged @UIBindableList数据更新时，OnValueChanged会立即调用，用来处理在UpdateVM之前要访问的数据
---@param Value table
function SampleTableViewItemVM:OnValueChanged(Value)
	-- 初始化Key值，整个列表要唯一不能重复，一般是ID
	self.Key = Value.ID

	--UpdateVM调用之前要访问的数据
end

---UpdateVM @UIBindableList数据更新时，UpdateVM可以延迟到数据绑定是才调用
---@param Value table
function SampleTableViewItemVM:UpdateVM(Value)
	self.Name = Value.Name

	--其他比较耗时的逻辑
end

return SampleTableViewItemVM