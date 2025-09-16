
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local ItemUtil = require("Utils/ItemUtil")
local WardrobeDefine = require("Game/Wardrobe/WardrobeDefine")
local UIBindableList = require("UI/UIBindableList")
local WardrobeSuitTabItemVM = require("Game/Wardrobe/VM/Item/WardrobeSuitTabItemVM")
local WardrobeSuitListVM = require("Game/Wardrobe/VM/Item/WardrobeSuitListVM")
local ClosetSuitCfg = require("TableCfg/ClosetSuitCfg")
local ClosetCfg = require("TableCfg/ClosetCfg")
local EquipmentCfg = require("TableCfg/EquipmentCfg")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local ProfMgr = require("Game/Profession/ProfMgr")
local WardrobeMgr = require("Game/Wardrobe/WardrobeMgr")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
local TimeUtil = require("Utils/TimeUtil")

---@class WardrobeSuitPanelVM : UIViewModel
local WardrobeSuitPanelVM = LuaClass(UIViewModel)

---Ctor
function WardrobeSuitPanelVM:Ctor()
    self.TabList = UIBindableList.New(WardrobeSuitTabItemVM)
    self.SuitList = UIBindableList.New(WardrobeSuitListVM)
    self.IsSearching = false
	self.UseBtnVisible = false
	self.EmptyVisible = nil
	self.CharmNumText = ""
end

function WardrobeSuitPanelVM:OnInit()
end

function WardrobeSuitPanelVM:OnBegin()

end

function WardrobeSuitPanelVM:OnEnd()

end

function WardrobeSuitPanelVM:OnShutdown()
end

function WardrobeSuitPanelVM:InitTabList()
    self.TabList:Clear()
    local TabList = {}
    for _, v in ipairs(WardrobeDefine.SuitTabList) do
        local Data = {}
        Data.ID = v.ID
        Data.PositionIcon = v.IconPathNormal
        Data.StateIcon = v.IconPathSelect
		Data.PositionSelectIcon = v.IconPathSelect
        table.insert(TabList, Data)
    end
    self.TabList:UpdateByValues(TabList)
end

local function CheckProfLimitAndClassLimit(Item, CheckList)
	if Item == nil then
		return false
	end

	if (table.is_nil_empty(Item.ProfLimit) or Item.ProfLimit[1] == 0) and (table.is_nil_empty(Item.ClassLimits) or Item.ClassLimits[1] == 0 ) then
        return _G.LSTR(1080016)
    end
	-- local NotHaveProfLimit = table.is_nil_empty(Item.ProfLimit) or (Item.ProfLimit[1] and Item.ProfLimit[1] == 0)

	for __, vv in ipairs(Item.ProfLimit) do
		for i, v in ipairs(CheckList) do
			if v == vv then
				return true
			end
		end
	end
	for __, class in ipairs(Item.ClassLimits) do
		for i, prof in ipairs(CheckList) do
			if ProfMgr.CheckProfClass(prof, class) then
				return true
			end
		end
	end

	return false
end

local function GetDataByFilterIndex(FilterIndex, DataList)
	local FilterProfList = WardrobeDefine.FilterProfList 
	if FilterIndex and FilterIndex ~= 0 then
		local Condition = FilterProfList[FilterIndex]

		local IsAll = Condition.ProfID == -1 and  Condition.ClassType == WardrobeDefine.ProfClass.ClassType
		if IsAll then
			return DataList
		end

		local FilterList = {}
		for i = 1, #DataList do
            local DataID = DataList[i].ID
			local EquipID = DataList[i].AppItems[1]
			local ID = EquipmentCfg:FindCfgByKey(EquipID).AppearanceID
			local EquipmentCfgs = EquipmentCfg:FindAllCfgByAppearanceID(ID) or {}
			local RealData = WardrobeMgr:GetUnlockAppearanceDataByID(ID) or {}
			local EquipmentConditionData = {}
			if WardrobeUtil.GetIsSpecial(ID) then
				table.insert(EquipmentConditionData, {ID = WardrobeUtil.GetUnlockCostItemID(ID)})
			else
				EquipmentConditionData = EquipmentCfgs
			end

			local CheckList = {} --- checklist为空时 视为不限职业

			if Condition.ProfID == 0 and Condition.ClassType == WardrobeDefine.ProfClass.ClassType then
				CheckList = {}
			else
				if Condition.ClassType == WardrobeDefine.ProfClass.ClassType then
					local ClassData = WardrobeUtil.GetClassTypeData()
					CheckList = ClassData[Condition.ProfID] or {}
				elseif Condition.ClassType == WardrobeDefine.ProfClass.BasicType then
					CheckList = {[1] = Condition.ProfID}
				elseif Condition.ClassType == WardrobeDefine.ProfClass.AdvanceType then
					local ProfCfg = RoleInitCfg:FindCfgByKey(Condition.ProfID)
					if ProfCfg ~= nil then
						local AdvanceProf = ProfCfg.AdvancedProf
						CheckList = {[1] = Condition.ProfID, [2]= AdvanceProf}
					end
				end
			end

			local CheckTag = false
			local CheckNum = 0

			if not table.is_nil_empty(RealData) then
				local Item = {
					ProfLimit = RealData.ProfLimits,
					ClassLimits = RealData.ClassLimits,
				}

				local IsCanInsert, UnlimitNum = CheckProfLimitAndClassLimit(Item, CheckList)
				if not FilterList[DataID] and IsCanInsert then
					CheckTag = true
					CheckNum = CheckNum + (UnlimitNum or 0)
				end
			else
				for _, v in ipairs(EquipmentConditionData) do
					local Item  = ItemCfg:FindCfgByKey(v.ID)
					if Item and not FilterList[DataID] then
						Item.ClassLimits = {Item.ClassLimit}
						local IsCanInsert, UnlimitNum = CheckProfLimitAndClassLimit(Item, CheckList)
						if IsCanInsert then
							CheckTag = true
							CheckNum = CheckNum + (UnlimitNum or 0)
						end
					end
				end
			end

			local IsIncludeUnlimit = Condition.ClassType == WardrobeDefine.ProfClass.BasicType or Condition.ClassType == WardrobeDefine.ProfClass.AdvanceType
			local OriginEquipmenNum = table.is_nil_empty(RealData) and #EquipmentConditionData or 1
			if CheckTag then
				if next(CheckList) then
					if CheckNum ~= OriginEquipmenNum or IsIncludeUnlimit then
						FilterList[DataID] = DataList[i]
					end
				else
					if CheckNum == OriginEquipmenNum then
						FilterList[DataID] = DataList[i]
					end
				end
			end
		end
	
		local TempList = {}
		for k, v in pairs(FilterList) do
			table.insert(TempList, v)
		end

		DataList = TempList
	end

	return DataList
end

function WardrobeSuitPanelVM:UpdateSuitList(TabIndex, FilterIndex)
	local RealIndex = TabIndex
	local ItemIndex = 3
	local EquipIndex = 2
	if TabIndex ~= 1 then
		RealIndex = TabIndex == 2 and ItemIndex or EquipIndex
	end
    local SuitCfgs = TabIndex == 1 and ClosetSuitCfg:FindAllCfg(string.format("TabIndex = 3 or TabIndex = 2")) or ClosetSuitCfg:FindAllCfg(string.format("TabIndex = %d", RealIndex))
    local DataList = {}
    for _, cfg in ipairs(SuitCfgs) do
        local Data = {}
        Data.ID = cfg.ID
        Data.TitelName = cfg.SuitName
        Data.AppItems = cfg.AppItems

        --Todo 如果有装备 
        if self:IsInVersion(cfg.AppItems) then
            table.insert(DataList, Data)
        end
    end

    -- 职业筛选
    if FilterIndex then
		DataList = GetDataByFilterIndex(FilterIndex, DataList)
	end

    self.SuitList:UpdateByValues(DataList)

	self.EmptyVisible = #DataList == 0
end

function WardrobeSuitPanelVM:IsInVersion(List)
	local ServerTime = TimeUtil.GetServerLogicTime()
    if List and next(List) then
        for _, v in ipairs(List) do
            local Cfg = EquipmentCfg:FindCfgByEquipID(v)
            if Cfg ~= nil and Cfg.AppearanceID > 0 then
				local ACfg = ClosetCfg:FindCfgByKey(Cfg.AppearanceID)
				if ACfg then
					if ACfg.UpTime == "" then
						return true
					else
						local AppTime = TimeUtil.GetTimeFromString(ACfg.UpTime)
						if ServerTime >= AppTime and AppTime > 0 then
							return true
						end
					end
				end
            end
        end
    end
    return false
end

function WardrobeSuitPanelVM:IsInUpTime(List)
    if List and next(List) then
        for _, v in ipairs(List) do
            local Cfg = EquipmentCfg:FindCfgByEquipID(v)
			local AppID = WardrobeUtil
            if Cfg ~= nil then
                return true
            end
        end
    end
    return false
end

function WardrobeSuitPanelVM:SearchSuitList(SearchText)
    self.SuitList:Clear()

    local DataList = {}

    local Cfgs = ClosetSuitCfg:FindAllCfg(string.format("TabIndex = 3 or TabIndex = 2"))
    for _, cfg in ipairs(Cfgs) do
        if string.find(cfg.SuitName, SearchText) then
            local Data = {}
            Data.ID = cfg.ID
            Data.TitelName = cfg.SuitName
            Data.AppItems = cfg.AppItems
    
            --Todo 如果有装备 
            if self:IsInVersion(cfg.AppItems) then
                table.insert(DataList, Data)
            end
        end
    end

    -- table.sort(DataList, self.AppearanceSortFunction)

	self.SuitList:UpdateByValues(DataList)
	self.EmptyVisible = #DataList == 0
end

function WardrobeSuitPanelVM:UpdateCharismNum()
	if not WardrobeMgr:IsExceedCfgLevel() then
		self.CharmNumText = string.format("%d/%d", WardrobeMgr:GetCharismNum(), WardrobeMgr:GetCharismTotalNum())
		self.CharmEffVisible = WardrobeMgr:GetCharismNum() >= WardrobeMgr:GetCharismTotalNum()
	else
		self.CharmNumText = string.format("%d", WardrobeMgr:GetCharismNum())
		self.CharmEffVisible = false
	end
end

WardrobeSuitPanelVM.GetDataByFilterIndex = GetDataByFilterIndex

return WardrobeSuitPanelVM