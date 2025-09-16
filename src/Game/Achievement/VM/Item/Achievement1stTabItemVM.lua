---
--- Author: ds_herui
--- DateTime: 2023-12-26 16:11
--- Description:
---

local ProtoRes = require("Protocol/ProtoRes")
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local AchievementDefine = require("Game/Achievement/AchievementDefine")
local AchievementUtil = require("Game/Achievement/AchievementUtil")
local AchievementCategoryCfg = require("TableCfg/AchievementCategoryCfg")
local Achievement2ndTabItemVM = require("Game/Achievement/VM/Item/Achievement2ndTabItemVM")

local EToggleButtonState = _G.UE.EToggleButtonState
local AchievementHideType = ProtoRes.AchievementHideType

---@class Achievement1stTabItemVM : UIViewModel
local Achievement1stTabItemVM = LuaClass(UIViewModel)

---Ctor
function Achievement1stTabItemVM:Ctor()
	self.Key = nil
	self.TypeID = 0
	self.TextContent = ""
	self.ToggleBtnState = EToggleButtonState.Unchecked
	self.ArrowUp = true

	self.TableView2ndTabDataList = {}
	self.TableView2ndTabVMList = {}
end

function Achievement1stTabItemVM:OnInit()

end

function Achievement1stTabItemVM:OnBegin()

end

function Achievement1stTabItemVM:IsEqualVM(Value)
	return self.TypeID == Value.TypeID
end

function Achievement1stTabItemVM:SetToggleBtnState(Selected)
	self.ToggleBtnState = Selected and EToggleButtonState.Checked or EToggleButtonState.Unchecked
end

function Achievement1stTabItemVM:GetChildVM(CategoryID)
	if CategoryID == 0 then
		return self.TableView2ndTabVMList[1]
	end
	local ItemVM, _ = table.find_item(self.TableView2ndTabVMList, CategoryID, "CategoryID")
	return ItemVM
end 

function Achievement1stTabItemVM:OnEnd()

end

function Achievement1stTabItemVM:OnShutdown()

end

---UpdateVM
---@param Value table @common.Item
---@param Params table @可以在UIBindableList.New函数传递参数，
function Achievement1stTabItemVM:UpdateVM(Value, Params)
	self.ArrowUp = false
	self.Key = Value.TypeID 
	self.TypeID = Value.TypeID 
	self.TextContent = Value.TypeName or ""
	
	self.TableView2ndTabDataList = {}
	self.TableView2ndTabVMList = {}
	if Value.TypeID == AchievementDefine.OverviewTypeDataTable.TypeID then
		table.merge_table(self.TableView2ndTabDataList, AchievementDefine.OverviewCategoryDataTable)
	else
		local Conditions = string.format(" Type = %d ", Value.TypeID)
		local AllCfg = AchievementCategoryCfg:FindAllCfg(Conditions) or {}
		for i = 1, #AllCfg do
			local Cfg = AllCfg[i]
			if self:DisplayCheck(Cfg) then 
				table.insert( self.TableView2ndTabDataList, 
				{ TypeID = Cfg.Type, CategoryID = Cfg.ID, Category = Cfg.Category, Sort = Cfg.Sort, ShowComplete = Cfg.ShowComplete } )
			end
		end
	end

	table.sort(self.TableView2ndTabDataList, function(A, B)
		return A.Sort < B.Sort  
	end )
	
	local ViewModel
	for i = 1, #self.TableView2ndTabDataList do
		ViewModel = Achievement2ndTabItemVM.New()
		ViewModel:UpdateVM(self.TableView2ndTabDataList[i])
		table.insert(self.TableView2ndTabVMList, ViewModel)
	end
end

function Achievement1stTabItemVM:AdapterOnGetChildren()
	return self.TableView2ndTabVMList
end

function Achievement1stTabItemVM:AdapterOnGetCanBeSelected()
	return true
end

function Achievement1stTabItemVM:AdapterOnGetWidgetIndex()
	return 0
end

function Achievement1stTabItemVM:AdapterOnGetIsCanExpand()
	return true
end

function Achievement1stTabItemVM:GetKey()
	return self.Key 
end

function Achievement1stTabItemVM:AdapterOnExpansionChanged(IsExpanded)
	self.ArrowUp = IsExpanded == true
end

function Achievement1stTabItemVM:DisplayCheck(Cfg)
	local Display = false
	if Cfg ~= nil then
		if Cfg.ShowComplete == 1 then
			if AchievementUtil.HaveUnLockAchieveFromCategory(Cfg.ID) then
				Display = true
			end
		else
			local AchieveDataList = _G.AchievementMgr:GetAchieveDataListFromCategoryID(Cfg.ID)
			for j = 1, #AchieveDataList do
				if not ( not AchieveDataList[j].IsFinish and AchieveDataList[j].HideType == AchievementHideType.ACHIEVEMENT_HIDE_TYPE_HIDE_ACHIEVEMENT ) then
					Display = true
					break
				end
			end
		end
	end 
	return Display
end


return Achievement1stTabItemVM