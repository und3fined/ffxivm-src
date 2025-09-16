---
--- Author: zerodeng
--- DateTime: 2024-11-20 11:30
--- Description: 针对背包空格子情况特殊处理，空格子可共用同一个VM，依赖VM的IsEqualVM接口
--- WiKi: 
---


local LuaClass = require("Core/LuaClass")
local UIBindableList = require("UI/UIBindableList")

---@class UIBindableBagSlotList : UIBindableList
---
local UIBindableBagSlotList = LuaClass(UIBindableList)

function UIBindableBagSlotList.New(...)
    local Object = UIBindableList.New(...)
    
    getmetatable(Object).__index = UIBindableBagSlotList

	return Object
end

function UIBindableBagSlotList:FreeAllItems(CurViewModelsMap)
	local Items = self.Items
	if nil == Items or #Items <= 0 then
		return false
	end

	local ViewModelClass = self.ViewModelClass
	if nil ~= ViewModelClass then
        local FreeObjectMap = {}

		for i = 1, #Items do
            local vm = Items[i]
            local KeyStr = tostring(vm)

            --还在使用，不删除
            if (CurViewModelsMap == nil or CurViewModelsMap[KeyStr] == nil) then
                --存在复用VM，只删除一次
                if (FreeObjectMap[KeyStr] == nil) then
                    FreeObjectMap[KeyStr] = true

                    _G.ObjectPoolMgr:FreeObject(ViewModelClass, vm)
                end 
            end
		end
	end

	self.Items = {}

	return true
end

function UIBindableBagSlotList:FindEqualVM(Value, CurViewModels)
    if nil == Value then
		FLOG_ERROR("UIBindableBagSlotList:FindEqualVM Value is nil")
		return
	end

	local _ <close> = CommonUtil.MakeProfileTag("UIBindableBagSlotList:FindEqualVM()")

	local Items = self.Items
	if not Items or not next(Items) then
		return
	end
	for i = #Items, 1, -1 do
		local v = Items[i]

		local _ <close> = CommonUtil.MakeProfileTag("UIBindableBagSlotList:FindEqualVM_IsEqualVM")

		if v.IsEqualVM and v:IsEqualVM(Value) then
			table.remove(Items, i)
			return v
		end
	end

    --缓存的没有找到，从现有的查找，VM公用
    if CurViewModels ~= nil then        
        for k = 1, #CurViewModels do
            local v = CurViewModels[k]
            if v.IsEqualVM and v:IsEqualVM(Value) then                
                return v
            end
        end
    end
end


return UIBindableBagSlotList