local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local TimeUtil = require("Utils/TimeUtil")
local UIBindableList = require("UI/UIBindableList")
local ItemVM = require("Game/Item/ItemVM")
local ItemUtil = require("Utils/ItemUtil")

local LSTR = _G.LSTR
---@class NightGiftRecordList02ItemVM : UIViewModel
local NightGiftRecordList02ItemVM = LuaClass(UIViewModel)

---Ctor
function NightGiftRecordList02ItemVM:Ctor()
   self.DescribeName = nil
   self.TableViewAwardList = UIBindableList.New(ItemVM, {IsShowNum = true, IsShowNumProgress = false, IsCanBeSelected = false})
end

function NightGiftRecordList02ItemVM:GetKey()
	return self.Index
end

function NightGiftRecordList02ItemVM:UpdateVM(Value)
	self.Index = Value.Index
	self.DescribeName = Value.Title
	local ItemList = {}
	for _, value in ipairs(Value.Items) do
		table.insert(ItemList, ItemUtil.CreateItem(value.ResID, value.Num))
	end
	self.TableViewAwardList:UpdateByValues(ItemList)
end

function NightGiftRecordList02ItemVM:IsEqualVM(Value)
	return nil ~= Value and Value.Index == self.Index
end

function NightGiftRecordList02ItemVM:AdapterOnGetCanBeSelected()
	return false
end

function NightGiftRecordList02ItemVM:AdapterOnGetWidgetIndex()
	return 1
end

function NightGiftRecordList02ItemVM:AdapterOnGetIsCanExpand()
	return false
end

function NightGiftRecordList02ItemVM:AdapterOnGetChildren()
end

function NightGiftRecordList02ItemVM:AdapterOnExpansionChanged(IsExpanded)
end

--要返回当前类
return NightGiftRecordList02ItemVM