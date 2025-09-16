---
--- Author: ds_tianjiateng
--- DateTime: 2024-03-12 19:21
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local SignsMainItemVM = require("Game/Signs/VM/ItemVM/SignsMainItemVM")
local UIBindableList = require("UI/UIBindableList")
local TargetmarkCfg = require("TableCfg/TargetmarkCfg")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local ProtoRes = require("Protocol/ProtoRes")

local TargetMarkType = ProtoRes.TargetMarkType

---@class SignsMainVM : UIViewModel
local SignsMainVM = LuaClass(UIViewModel)

---Ctor
function SignsMainVM:Ctor()
	self.SinsItems = UIBindableList.New(SignsMainItemVM)
end

-- 自定义排序函数  
local function compareItems(a, b)  
    -- 先按Index升序排列  
    if a.Index ~= b.Index then  
        return a.Index < b.Index  
    end  
    
    -- Index相同时，比较Children  
    local aChildren = a.Children  
    local bChildren = b.Children  
    
    -- Children为空在前  
    if not aChildren and bChildren then  
        return true  
    elseif aChildren and not bChildren then  
        return false  
    end  
      
    -- 如果两个元素都有Children，按Children的元素升序排列  
    if aChildren and bChildren then  
        for i = 1, math.min(#aChildren, #bChildren) do  
            if aChildren[i].ID ~= bChildren[i].ID then  
                return aChildren[i].ID < bChildren[i].ID
            end  
        end  
          
        -- 如果Children的前部分都相同，但长度不同，则较短的排在前面  
        return #aChildren < #bChildren  
    end  

    -- 如果两个元素都没有Children或者完全相等，保持原始顺序  
    return false  
end

function SignsMainVM:OnInitViewData()
	local Items = {}
	local GroupMaxSize = 5
	for _, ItemType in pairs(TargetMarkType) do
		if ItemType > 0 then
			local TempTable = {}
			TempTable.Index = ItemType
			TempTable.Tittle = ProtoEnumAlias.GetAlias(TargetMarkType, ItemType)
			table.insert(Items, TempTable)
			local Children = TargetmarkCfg:FindAllCfg(string.format("Type=%d", ItemType))
			if Children ~= nil then
				TempTable = {}
				if #Children <= GroupMaxSize then
					TempTable.Index = ItemType
					TempTable.Children = Children
					table.insert(Items, TempTable)
				else
					local TempChildren = {}
					for i = 1, #Children do
						table.insert(TempChildren, Children[i])
						if i % GroupMaxSize == 0 or i == #Children then
							TempTable.Index = ItemType
							TempTable.Children = TempChildren
							table.insert(Items, TempTable)
							TempTable = {}
							TempChildren = {}
						end
					end
				end
			end
		end
	end
	table.sort(Items, compareItems)
	self.SinsItems:UpdateByValues(Items)
end

function SignsMainVM:UpdateVM(Value)
	
end

function SignsMainVM:OnShutdown()
	
end

function SignsMainVM:ClearAllItemUsed()
	local Items = self.SinsItems:GetItems()
	for _, value in ipairs(Items) do
		local Children = value.SignsSlots:GetItems()
		for i = 1, #Children do
			if Children[i].IsUsed then
				Children[i]:SetIsUsed(false)
			end
		end
	end
end

function SignsMainVM:OnSetItemUsedState(Index, State)
	local Items = self.SinsItems:GetItems()
	for _, value in ipairs(Items) do
		local Children = value.SignsSlots:GetItems()
		for i = 1, #Children do
			if Children[i].ID == Index then
				Children[i].IsUsed = State
				return
			end
		end
	end

end

return SignsMainVM