
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MapUtil = require("Game/Map/MapUtil")
local QuestHelper = require("Game/Quest/QuestHelper")
local UIBindableList = require("UI/UIBindableList")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local ProtoRes = require("Protocol/ProtoRes")
local QuestDefine = require("Game/Quest/QuestDefine")

---@class NewMapTaskListItemVM : UIViewModel
local NewMapTaskListItemVM = LuaClass(UIViewModel)

---Ctor
function NewMapTaskListItemVM:Ctor()
	self.MapTaskWidgetIndex = 0
	self.MapName = ""
	self.IsLocate = false

	self.Name = ""
	self.MinLevel = 0
	self.Icon = ""
	self.bTracking = false

	self.ChapterID = 0
	self.QuestID = 0

	self.Key = 0
	self.QuestType = nil
	self.QuestTypeName = ""
	self.ParentVM = nil
	self.BindableListChildren = UIBindableList.New(NewMapTaskListItemVM, self)
	self.IsExpanded = false
	self.TextColor = "#FFF4D0FF"
end

function NewMapTaskListItemVM:OnInit()

end

function NewMapTaskListItemVM:OnBegin()
	
end

function NewMapTaskListItemVM:IsEqualVM(Value)
	return self.MapTaskWidgetIndex == Value.MapTaskWidgetIndex
end

function NewMapTaskListItemVM:AdapterOnGetCanBeSelected()
	return self.MapTaskWidgetIndex == 1
 end
 
function NewMapTaskListItemVM:AdapterOnGetWidgetIndex()
	return self.MapTaskWidgetIndex
end

function NewMapTaskListItemVM:AdapterOnGetIsCanExpand()
	return true
end

function NewMapTaskListItemVM:AdapterOnGetChildren()
	return self.BindableListChildren:GetItems()
end

function NewMapTaskListItemVM:AdapterOnExpansionChanged(IsExpanded)
	self.IsExpanded = IsExpanded
end

function NewMapTaskListItemVM:GetKey()
	return self.Key
end

function NewMapTaskListItemVM:OnEnd()

end

function NewMapTaskListItemVM:OnShutdown()

end

---UpdateVM
---@param Value table @common.Item
---@param Params table @可以在UIBindableList.New函数传递参数，
function NewMapTaskListItemVM:UpdateVM(Value, Params)
	self.Key = Value.Key
	self.MapTaskWidgetIndex = Value.MapTaskWidgetIndex
	if Value.MapTaskWidgetIndex == 2 then
		return
	elseif Value.MapTaskWidgetIndex == 0 then
		self:UpdateTabItemView(Value)
	elseif Value.MapTaskWidgetIndex == 1 then
		self:UpdateChildItemView(Value)
	end
end

function NewMapTaskListItemVM:UpdateTabItemView(Data)
	self.QuestType = Data.QuestType
	self.QuestTypeName = QuestDefine.QuestTypeNames[Data.QuestType]
	self.BindableListChildren:UpdateByValues(Data.QuestData)
end

function NewMapTaskListItemVM:UpdateChildItemView(Data)
	local QuestID = Data.QuestID
	self.QuestID = QuestID
	local QuestCfgitem = QuestHelper.GetQuestCfgItem(QuestID) or {}
	local ChapterVM = _G.QuestMainVM:GetChapterVM(QuestCfgitem.ChapterID)
	if ChapterVM ~= nil then
		self.ChapterID = QuestCfgitem.ChapterID
		self.Name = ChapterVM.Name
		self.MinLevel = ChapterVM.MinLevel
		self.Icon = ChapterVM.Icon
		self.bTracking = _G.QuestMgr:GetTrackingQuest() == QuestID
	end
end

return NewMapTaskListItemVM