local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local QuestDefine = require("Game/Quest/QuestDefine")
local MapUtil = require("Game/Map/MapUtil")
local UIBindableList = require("UI/UIBindableList")
local NewMapTaskListItemVM = require("Game/NewMap/VM/NewMapTaskListItemVM")
local QuestHelper = require("Game/Quest/QuestHelper")


local QUEST_TYPE = ProtoRes.QUEST_TYPE

---@class NewMapTaskListPanelVM : UIViewModel
local NewMapTaskListPanelVM = LuaClass(UIViewModel)

---Ctor
function NewMapTaskListPanelVM:Ctor()
	self.TaskList = UIBindableList.New(NewMapTaskListItemVM)
	self.WidgetIndex = 0
end

function NewMapTaskListPanelVM:OnInit()
	
end

function NewMapTaskListPanelVM:OnBegin()

end

function NewMapTaskListPanelVM:OnEnd()
	
end

function NewMapTaskListPanelVM:OnShutdown()
	
end

function NewMapTaskListPanelVM:SetShowUIMapID()
	-- 一二级地图只显示主线和重要任务，三级地图显示主线、重要和支线
	local CurUIMapID =_G.WorldMapMgr:GetUIMapID()
	local IsAreaMap = MapUtil.IsAreaMap(CurUIMapID)
	local IsRegionMap = MapUtil.IsRegionMap(CurUIMapID)
	local IsWorldMap = MapUtil.IsWorldMap(CurUIMapID)
	local QuestTypeList = {}
	if IsAreaMap then
		QuestTypeList = { QUEST_TYPE.QUEST_TYPE_MAIN, QUEST_TYPE.QUEST_TYPE_IMPORTANT, QUEST_TYPE.QUEST_TYPE_BRANCH }
	elseif IsRegionMap or IsWorldMap then
		QuestTypeList = { QUEST_TYPE.QUEST_TYPE_MAIN, QUEST_TYPE.QUEST_TYPE_IMPORTANT }
	end
	
	local QuestMgr = _G.QuestMgr
	local ShowTaskCount = 0
	local CurTypeData = nil
	local CurTypeChildData = nil
	local TypeCount = 0
	local CHAPTER_STATUS = QuestDefine.CHAPTER_STATUS
	local ChapterStatus = { CHAPTER_STATUS.CAN_SUBMIT, CHAPTER_STATUS.IN_PROGRESS, CHAPTER_STATUS.FAILED }
	
	local function SortFunction(Left, Right)
		local LeftQuestCfgitem = QuestHelper.GetQuestCfgItem(Left.QuestID) or {}
		local LeftChapterVM = _G.QuestMainVM:GetChapterVM(LeftQuestCfgitem.ChapterID)
		local RightQuestCfgitem = QuestHelper.GetQuestCfgItem(Right.QuestID) or {}
		local RightChapterVM = _G.QuestMainVM:GetChapterVM(RightQuestCfgitem.ChapterID)

		if LeftChapterVM and RightChapterVM then
			if LeftChapterVM.Status ~= RightChapterVM.Status then
				return LeftChapterVM.Status > RightChapterVM.Status
			end
			if LeftChapterVM.MinLevel ~= RightChapterVM.MinLevel then
				return LeftChapterVM.MinLevel < RightChapterVM.MinLevel
			end
		end

		return Left.QuestID < Right.QuestID
	end
	local AllVMData = {}
	for _, QuestType in ipairs(QuestTypeList) do
		CurTypeData = nil
		CurTypeChildData = nil
		ShowTaskCount = 0
		local Quests = QuestMgr:GetChapterIDList(QuestType, ChapterStatus)
		
		if Quests then
			for _, Status in pairs(ChapterStatus) do
				local QuestList = Quests[Status]
				if #QuestList > 0 then
					for _, ChapterID in ipairs(QuestList) do
						local ChapterVM = _G.QuestMainVM:GetChapterVM(ChapterID)
						if ChapterVM ~= nil then
							local UIMapID = MapUtil.GetUIMapID(ChapterVM.MapID) or 0
							local CanAddData = false
							if IsAreaMap then -- 三级地图展示所有主线、重要任务和当前区域接取的支线任务
								if QuestType == QUEST_TYPE.QUEST_TYPE_MAIN or QuestType == QUEST_TYPE.QUEST_TYPE_IMPORTANT then
									CanAddData = true
								else -- 支线任务只展示当前区域接取的(比如乌尔达哈这种多层的，都统一属于乌尔达哈，所以不能直接判断地图ID)
									local CurMapRegion = MapUtil.GetMapName(CurUIMapID)
									local MapRegion = MapUtil.GetMapName(UIMapID)
									if CurMapRegion == MapRegion then
										CanAddData = true
									end
								end
							elseif IsRegionMap or IsWorldMap then -- 一二级地图展示所有主线和重要任务
								if QuestType == QUEST_TYPE.QUEST_TYPE_MAIN or QuestType == QUEST_TYPE.QUEST_TYPE_IMPORTANT then
									CanAddData = true
								end
							end

							if CanAddData then
								if not CurTypeData then
									CurTypeData = {}
									CurTypeChildData = {}
									TypeCount = TypeCount + 1
									CurTypeData.Key = TypeCount
									CurTypeData.MapTaskWidgetIndex = 0
									CurTypeData.QuestType = QuestType
									CurTypeData.QuestData = CurTypeChildData
								end

								ShowTaskCount = ShowTaskCount + 1
								local Key = TypeCount * 10 + ShowTaskCount
								table.insert(CurTypeChildData, { MapTaskWidgetIndex = 1, QuestID = ChapterVM.QuestID, Key = Key })
							end
						end
					end
				end
			end
		end

		if CurTypeData then
			table.sort(CurTypeData, SortFunction)
			table.insert(AllVMData, CurTypeData)
		end
	end

	if TypeCount == 0 then 
		self.WidgetIndex = 1
	else
		self.WidgetIndex = 0
		self.TaskList:UpdateByValues(AllVMData)
	end
end

function NewMapTaskListPanelVM:UpdateQuestByChapterID(ChapterID)
	local ChapterVM = _G.QuestMainVM:GetChapterVM(ChapterID)
	self:UpdateListItemVM(ChapterVM)
end

function NewMapTaskListPanelVM:UpdateQuestByQuestID(QuestID)
	local QuestCfgitem = QuestHelper.GetQuestCfgItem(QuestID) or {}
	local ChapterVM = _G.QuestMainVM:GetChapterVM(QuestCfgitem.ChapterID)
	self:UpdateListItemVM(ChapterVM)
end

function NewMapTaskListPanelVM:UpdateListItemVM(ChapterVM)
	if ChapterVM == nil then
		_G.FLOG_ERROR("NewMapTaskListPanelVM ChapterVM is nil")
		return
	end
	
	local QuestTypeList = self.TaskList:GetItems()
	local QuestVMList = nil
	for _, QuestTypeData in ipairs(QuestTypeList) do
		if QuestTypeData.QuestType == ChapterVM.Type then
			QuestVMList = QuestTypeData.BindableListChildren
			break
		end
	end

	if QuestVMList then
		local QuestVM = QuestVMList:Find(function(Quest)
			return Quest.QuestID == ChapterVM.QuestID
		end)

		if QuestVM then
			QuestVM.bTracking = _G.QuestMgr:GetTrackingQuest() == QuestVM.QuestID
		end
	end
end

--要返回当前类
return NewMapTaskListPanelVM