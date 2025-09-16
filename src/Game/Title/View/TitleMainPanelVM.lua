local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIBindableList = require("UI/UIBindableList")
local TitleListItemVM =  require("Game/Title/View/Item/TitleListItemVM")
local MajorUtil = require("Utils/MajorUtil")
local TitleDefine = require("Game/Title/TitleDefine")
local AchievementUtil = require("Game/Achievement/AchievementUtil")

local EToggleButtonState = _G.UE.EToggleButtonState
local RoleGender = ProtoCommon.role_gender
local ButtonStyle = TitleDefine.ButtonStyle
local AppendTitleType = TitleDefine.AppendTitleType
local LSTR
local TitleMgr

---@class TitleMainPanelVM : UIViewModel
local TitleMainPanelVM = LuaClass(UIViewModel)

---Ctor
function TitleMainPanelVM:Ctor()
	self.CurrentSelectData = nil
	self.CurrentTitleText = ""
	self.AchievementText = ""
	self.BtnFavoriteState = EToggleButtonState.Unchecked
	self.EmptyCollectionPanel = false
	self.UseBtnState = ButtonStyle.UnUse
	self.TitleList = UIBindableList.New( TitleListItemVM )
	
	self.LastSelectTitleId = 0
	self.SearchText = ""
	self.EmptyPanelHintText = ""
	self.AchieveIconPath = ""
	self.BtnGotoVisible = true
end

function TitleMainPanelVM:OnInit()

end

function TitleMainPanelVM:OnBegin()
	LSTR = _G.LSTR
	TitleMgr = _G.TitleMgr
	self.SearchText = ""
end

function TitleMainPanelVM:OnEnd()

end

function TitleMainPanelVM:OnShutdown()

end

-- 清除自己在使用称号vm的使用状态
function TitleMainPanelVM:ClearUseState(LastUseTitleId)
	local PredicateFun = function(Item)
		return Item.ID == LastUseTitleId
	end

	local ViewMode, _ = self.TitleList:Find(PredicateFun)
	if ViewMode ~= nil then
		ViewMode.IsUsed = false
	end
end

-- 设置上一次选中称号ID
function TitleMainPanelVM:SetLastSelectTitleId(LastSelectTitleId)
	if LastSelectTitleId ~= nil then
		self.LastSelectTitleId = LastSelectTitleId
	end
end

function TitleMainPanelVM:SetGotoInfo(ConditionText, ConditionType)
	if ConditionType == TitleDefine.ConditionType.Activity then
		self.AchievementText = string.format(LSTR(710019), ConditionText or "")        -- "参与<%s>获得"
		self.AchieveIconPath = TitleDefine.ActivityIconPath
		self.BtnGotoVisible = false
	elseif ConditionType == TitleDefine.ConditionType.Achievement then
		self.AchievementText = LSTR(710006) .. AchievementUtil.GetAchievementName(tonumber(ConditionText))
		self.AchieveIconPath = TitleDefine.AchievementIconPath
		self.BtnGotoVisible = true
	else
		self.AchievementText = ""
		self.AchieveIconPath = ""
		self.BtnGotoVisible = false
	end
end

function TitleMainPanelVM:SetCurrentTitleText(CurrentTitleText)
	if CurrentTitleText == nil or CurrentTitleText == "" then
		self.CurrentTitleText = LSTR(710005)
		return 
	end
	self.CurrentTitleText = LSTR(710004) .. CurrentTitleText
end

-- 选中称号类型改变
function TitleMainPanelVM:SelectTitleTypeChange(CurrentTypeID)
	local TitleIDList = TitleMgr:GetAllTitleFromType(CurrentTypeID) or {}
	local Gender = MajorUtil.GetMajorGender()
	local CurrentTitle = TitleMgr:GetCurrentTitle()

	local TitleDataList = {}
	for i = 1, #TitleIDList do
		local TitleCfg = TitleMgr:QueryTitleTableData(TitleIDList[i])
		if TitleCfg ~= nil then
			if TitleCfg.Display == 0 or TitleMgr:QueryUnLockState(TitleCfg.ID) then
				local TitleText = ""
				if Gender == RoleGender.GENDER_MALE then
					TitleText = TitleCfg.MaleName or ""
				elseif Gender == RoleGender.GENDER_FEMALE then
					TitleText = TitleCfg.FemaleName or ""
				end

				table.insert(TitleDataList,
				{ ID = TitleCfg.ID, TitleText = TitleText, 
						IsUnLock = TitleMgr:QueryUnLockState(TitleCfg.ID),
						IsUsed = CurrentTitle == TitleCfg.ID, 
						IsFavorite = TitleMgr:QueryCollectedState(TitleCfg.ID) })
			end
		end
	end

	if self.SearchText ~= "" then
		TitleDataList = table.find_all_by_predicate(TitleDataList, function(Item) return string.find(Item.TitleText, self.SearchText, 1 , true) ~= nil end)
	end

	--为了单个Item显示时适配做的特殊处理
	if #TitleDataList == 1 then
		table.insert(TitleDataList, { ID = 0, TitleText = "", IsUnLock = false, IsUsed = false, IsFavorite = false } )
	end
	self.TitleList:UpdateByValues(TitleDataList, nil)

	self.EmptyCollectionPanel = #TitleDataList <= 0
	if self.EmptyCollectionPanel then
		if self.SearchText ~= "" then
			self.EmptyPanelHintText = LSTR(710014)
		elseif CurrentTypeID == AppendTitleType[1].ID then 
			self.EmptyPanelHintText = LSTR(710010)
		else
			self.EmptyPanelHintText = LSTR(710011)
		end
	end
end

-- 选中称号改变
function TitleMainPanelVM:SelectTitleChange(ItemData)
	self.CurrentSelectData = ItemData or {}
	local CfgInfo = TitleMgr:QueryTitleTableData(self.CurrentSelectData.ID)
	if CfgInfo == nil then
		self:SetGotoInfo(nil, nil)
	else
		self:SetGotoInfo(CfgInfo.Condition, CfgInfo.ConditionType)

		if ItemData.IsFavorite then
			self.BtnFavoriteState = EToggleButtonState.Checked
		else
			self.BtnFavoriteState = EToggleButtonState.Unchecked
		end
		
		if ItemData.IsUnLock then
			if ItemData.IsUsed then
				self.UseBtnState = ButtonStyle.InUse
			else
				self.UseBtnState = ButtonStyle.UnUse
			end
		else
			self.UseBtnState = ButtonStyle.Lock
		end
		self:SetLastSelectTitleId(ItemData.ID)
	end
end

--收藏操作成功对应界面刷新
function TitleMainPanelVM:CollectFinish(TitleID, IsCollect)
	local ItemData, _ = self.TitleList:Find(function(Item) return Item.ID == TitleID end)
	if ItemData ~= nil then
		if IsCollect then 
			ItemData.IsFavorite = nil
		else
			ItemData.IsFavorite = false
		end 
	end

	local CurItemData = self.CurrentSelectData or {}
	if TitleID == CurItemData.ID then
		self.BtnFavoriteState = IsCollect and EToggleButtonState.Checked or EToggleButtonState.Unchecked
	end
end

--设置操作成功对应界面刷新
function TitleMainPanelVM:SetTitleSucceed(SetTitleID)
	local CurItemData = self.CurrentSelectData 
	if SetTitleID == 0 then
		self.UseBtnState = ButtonStyle.UnUse
		local OldSetTitle =  self.TitleList:Find(function(Item) return Item.ID == TitleMgr:GetCurrentTitle() end)
		if OldSetTitle ~= nil then
			OldSetTitle.IsUsed = false
		end
		return 
	end
	local ItemData, _ = self.TitleList:Find(function(Item) return Item.ID == SetTitleID end)
	if ItemData ~= nil then
		ItemData.IsUsed = nil
		if CurItemData and CurItemData.ID == ItemData.ID then
			self.UseBtnState = ButtonStyle.InUse
		else
			self.UseBtnState = ButtonStyle.UnUse
		end
	end
end

-- 获取当前称号列表中上一个选中称号下标
function TitleMainPanelVM:GetLastSelectTitleIndex()
	if self.LastSelectTitleId == 0 then
		return 1
	end

	local PredicateFun = function(Item)
		return Item.ID == self.LastSelectTitleId
	end

	local Index = self.TitleList:GetItemIndexByPredicate(PredicateFun)
	return Index or 1
end

function TitleMainPanelVM:SetSearchKeyword(SearchText)
	self.SearchText = SearchText
end

function TitleMainPanelVM:InitiativeSearch(SearchText, CurrentTypeID)
	if self.SearchText ~= SearchText then
		self.SearchText = SearchText
		self:SelectTitleTypeChange(CurrentTypeID)
	end
end

--要返回当前类
return TitleMainPanelVM