local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local TimeUtil = require("Utils/TimeUtil")
local UIBindableList = require("UI/UIBindableList")
local NightGiftRecordList02ItemVM = require("Game/StarlightCelebration/VM/NightGift/NightGiftRecordList02ItemVM")
local LSTR = _G.LSTR
---@class NightGiftRecordListItemVM : UIViewModel
local NightGiftRecordListItemVM = LuaClass(UIViewModel)

---Ctor
function NightGiftRecordListItemVM:Ctor()
	self.TitleName = nil
    self.BindableActivityList = UIBindableList.New( NightGiftRecordList02ItemVM )
end

function NightGiftRecordListItemVM:UpdateVM(Value)
	self.Index = Value.Index
	self.TitleName = Value.Title
	local Gift = Value.Gift
	local GiftsInfo = {}
	if Gift.Items and #Gift.Items > 0 then
		table.insert(GiftsInfo, {Index = Value.Index + 1, Items = Gift.Items, Title = LSTR(1700009)})
	end

	if Gift.SystemItems and #Gift.SystemItems > 0 then
		table.insert(GiftsInfo, {Index = Value.Index + 2, Items = Gift.SystemItems, Title = LSTR(1700021)})
	end
	self.BindableActivityList:UpdateByValues(GiftsInfo)

end

function NightGiftRecordListItemVM:GetKey()
	return self.Index
end

function NightGiftRecordListItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.Index == self.Index
end

function NightGiftRecordListItemVM:AdapterOnGetCanBeSelected()
	return false
end

function NightGiftRecordListItemVM:AdapterOnGetWidgetIndex()
	return 0
end

function NightGiftRecordListItemVM:AdapterOnGetIsCanExpand()
	return true
end

function NightGiftRecordListItemVM:AdapterOnGetChildren()
    return self.BindableActivityList:GetItems()
end

function NightGiftRecordListItemVM:AdapterOnExpansionChanged(IsExpanded)
end




--要返回当前类
return NightGiftRecordListItemVM