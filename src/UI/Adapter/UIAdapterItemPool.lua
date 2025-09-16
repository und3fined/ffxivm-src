--
-- Author: anypkvcai
-- Date: 2020-11-12 11:16:42
-- Description:
--

--[[
---@class UIAdapterItemPool
local UIAdapterItemPool = {
	PoolItems = {}
}

---GetItem
---@param Path string
---@return userdata         @UObject
function UIAdapterItemPool:GetItem(Path)
	local Pool = self.PoolItems[Path]
	if nil == Pool then
		Pool = {}
		Pool.FreeItems = {}
		Pool.UsedItems = {}
		self.PoolItems[Path] = Pool
	else
		if #Pool.FreeItems > 0 then
			local Item = table.remove(Pool.FreeItems, 1)
			table.insert(Pool.UsedItems, Item)
			--print(string.format("UIAdapterItemPool GetItem 1 Used=%d Free=%d", #Pool.UsedItems, #Pool.FreeItems))
			return Item
		end
	end

	local Class = _G.ObjectMgr:LoadClassSync(Path)
	if nil == Class then
		return
	end

	local Item = NewObject(Class)
	table.insert(Pool.UsedItems, Item)

	--print(string.format("UIAdapterItemPool GetItem 2 Used=%d Free=%d", #Pool.UsedItems, #Pool.FreeItems))

	return Item
end

---FreeItem
---@param Item userdata         @UObject
function UIAdapterItemPool:FreeItem(Item)
	if nil == Item then
		return
	end

	for _, v in pairs(self.PoolItems) do
		if self:FreeItemInternal(v, Item) then
			--print(string.format("UIAdapterItemPool FreeItem Used=%d Free=%d", #v.UsedItems, #v.FreeItems))
			return
		end
	end

	FLOG_ERROR("UIAdapterItemPoo:FreeItem error")
end

---FreeItemInternal
---@param Pool table
---@param Item userdata         @UObject
function UIAdapterItemPool:FreeItemInternal(Pool, Item)
	if nil == Pool then
		return false
	end

	if nil == Item then
		return false
	end

	for i, v in ipairs(Pool.UsedItems) do
		if v == Item then
			table.remove(Pool.UsedItems, i)
			table.insert(Pool.FreeItems, Item)
			return true
		end
	end

	return false
end

return UIAdapterItemPool

--]]