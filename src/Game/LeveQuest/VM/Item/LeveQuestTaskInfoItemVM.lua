-- Author: ZhengJianChuan
-- Date: 2024-11-18 20:25
-- Description: 理符委托Item
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local ItemUtil = require("Utils/ItemUtil")
local ItemVM = require("Game/Item/ItemVM")
local LeveQuestPropsItemVM = require("Game/LeveQuest/VM/Item/LeveQuestPropsItemVM")
local MajorUtil = require("Utils/MajorUtil")
local ProfUtil = require("Game/Profession/ProfUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local LeveQuestDefine = require("Game/LeveQuest/LeveQuestDefine")
local NpcCfg = require("TableCfg/NpcCfg")

---@class LeveQuestTaskInfoItemVM : UIViewModel
local LeveQuestTaskInfoItemVM = LuaClass(UIViewModel)

---Ctor
function LeveQuestTaskInfoItemVM:Ctor()
	self.ID  = nil
	self.Lv = ""
	self.Title = ""
	self.Content = ""
	self.ItemDesc = ""
	self.PayText = ""

	self.RewardMustList = UIBindableList.New(ItemVM, {HideItemLevel = true, IsShowNumProgress = false, IsShowSelectStatus = false})
	self.RewardProbabilityList = UIBindableList.New(LeveQuestPropsItemVM)
	self.RewardPayList = UIBindableList.New(ItemVM,  {HideItemLevel = true, IsShowNumProgress = true, IsCanBeSelected = true })
	self.TextProbabilityVisible = false

	self.Cfg = nil
	self.PayListSelectedIndex = nil
	self.InsufficientLevelVisible = false

	self.PayBtnRecommendState = 1  -- 0：置灰， 1：推荐

	self.EffectVisible = false
	self.InitPayReady = false
	self.Card = nil
	self.MostPayNum = 0
	self.IsMarked = nil
end

function LeveQuestTaskInfoItemVM:OnInit()
	--只有在UIViewModelConfig配置的全局的ViewModel，才会调用到OnInit函数
	--只初始化自身模块的数据，不能引用其他的同级模块
end

function LeveQuestTaskInfoItemVM:OnBegin()
end

function LeveQuestTaskInfoItemVM:OnEnd()
end

function LeveQuestTaskInfoItemVM:OnShutdown()
end

function LeveQuestTaskInfoItemVM:UpdateVM(Params)
	if Params == nil then
		_G.FLOG_INFO(string.format("LeveQuestTaskInfoItemVM:UpdateVM is nil" ))
		return
	end
	self.ID = Params.ID
	self.Lv = string.format(_G.LSTR(880001), Params.Level)  --- %d级
	self.Title = Params.QuestName
	local NPCName = (Params and Params.NPCName) and Params.NPCName or ""
	-- self.Content = string.format(_G.LSTR(880014), Params.CityNPCTitle or "", NPCName, Params.QuestDesc)  --- 委托人：%s %s \n %s
	-- local Subtitle =  RichTextUtil.GetText(string.format(_G.LSTR(880014), Params.CityNPCTitle or "", NPCName), "313131")
	local Subtitle =  RichTextUtil.GetText(string.format("委托人：%s %s", Params.CityNPCTitle or "", NPCName), "313131")
	local Content =  RichTextUtil.GetText(string.format("%s", Params.QuestDesc or ""), "6c6964")
	self.Content = string.format("%s\n%s", Subtitle, Content)
	self.Cfg = Params
	local ProfLevel = _G.LeveQuestMgr:GetProfCurLevel(Params.ProfType)
	self.InsufficientLevelVisible = ProfLevel >= Params.Level
	local Pic1 = "PaperSprite'/Game/UI/Atlas/LeveQuest/Frames/UI_LeveQuest_Img_Card1_png.UI_LeveQuest_Img_Card1_png'"
	local Pic2 ="PaperSprite'/Game/UI/Atlas/LeveQuest/Frames/UI_LeveQuest_Img_Card_png.UI_LeveQuest_Img_Card_png'" 
	self.Card = ProfUtil.IsGpProf(Params.ProfType) and Pic1 or Pic2
	
	self.RewardMustList:Clear()
	self.RewardProbabilityList:Clear()
	
	self:UpdateItemDesc()
	-- 更新
	self:UpdateRewardPayList()
	local SelectedIndex = self:GetEnoughPayItemIndex()
	local SelectedItemID = self:GetEnoughPayItemID(SelectedIndex)
	local IsHQ = ItemUtil.IsHQ(SelectedItemID)
	self:UpdateRewardMustList(IsHQ)
	self:UpdateRewardProbabilityList(IsHQ)
	self:UpdatePayNum(SelectedItemID)
	
	-- 更新选中
	self.PayListSelectedIndex = nil
	self.PayListSelectedIndex = SelectedIndex
	self.InitPayReady = true
	
	self:SetMarkedItem()
end

function LeveQuestTaskInfoItemVM:SetMarkedItem()
    self.IsMarked = _G.LeveQuestMgr:IsProfMarkedItem(self.Cfg.ProfType, self.ID)
end

function LeveQuestTaskInfoItemVM:UpdateItemDesc()
	local QuestItemCfg = self.Cfg
	local RequireItem =  QuestItemCfg.RequireItem
	if RequireItem ~= nil and RequireItem.ID ~= nil then
		if RequireItem.Num and RequireItem.Num > 1 then
			self.ItemDesc = string.format("%sx%d", ItemUtil.GetItemName(RequireItem.ID), RequireItem.Num)
		else
			self.ItemDesc = string.format("%s", ItemUtil.GetItemName(RequireItem.ID))
		end
	end
end

function LeveQuestTaskInfoItemVM:UpdateRewardMustList(IsHQ)
	self.RewardMustList:Clear()
	local QuestItemCfg = self.Cfg

	local ItemList = {}
	for _, v in ipairs(QuestItemCfg.RewardItems) do
		local Num = IsHQ and math.floor(v.Num +  v.Num * (v.Rate / 100)) or v.Num 
		local Item = ItemUtil.CreateItem(v.ID, Num)
		Item.IsShowNum = true
		table.insert(ItemList, Item)
	end
	self.RewardMustList:UpdateByValues(ItemList)
end

function LeveQuestTaskInfoItemVM:UpdateRewardProbabilityList(IsHQ)
	self.RewardProbabilityList:Clear()
	local QuestItemCfg = self.Cfg
 
	local ItemList = {}
	for _, v in ipairs(QuestItemCfg.ExtraItems) do
		if v.ID and v.ID ~= 0 then
			local Num = IsHQ and math.floor(v.Num +  v.Num * (v.IncreRate / 100)) or v.Num 
			local Item ={}
			Item.Rate = v.Rate
			Item.ItemID = v.ID
			Item.Num = Num
			Item.TextPerVisible = true
			Item.TextPer = string.format("%d%s", v.Rate,"%")
			table.insert(ItemList, Item)
		end
	end

	table.sort(ItemList, LeveQuestTaskInfoItemVM.SortItemByRate)

	self.RewardProbabilityList:UpdateByValues(ItemList)

	self.TextProbabilityVisible = #ItemList > 0
end

function LeveQuestTaskInfoItemVM:UpdateRewardPayList()
	self.RewardPayList:Clear()
	local QuestItemCfg = self.Cfg
	local RequireItem =  QuestItemCfg.RequireItem
	local ItemList = {}
	if RequireItem.ID ~= 0 then
		local Item = ItemUtil.CreateItem(RequireItem.ID, RequireItem.Num)
		Item.LeveQuest = true
		table.insert(ItemList, Item)
		if not ItemUtil.IsHQ(RequireItem.ID) then
			local Cfg = ItemCfg:FindCfgByKey(RequireItem.ID)
			if Cfg ~= nil then
				if Cfg.NQHQItemID ~= 0 then
					local Item2 = ItemUtil.CreateItem(Cfg.NQHQItemID, RequireItem.Num)
					Item2.LeveQuest = true
					table.insert(ItemList, Item2)
				end
			end
		end
	end
	table.sort(ItemList, LeveQuestTaskInfoItemVM.SortItemByHQ)

	self.InitPayReady = false
	self.RewardPayList:UpdateByValues(ItemList)
end

function LeveQuestTaskInfoItemVM:UpdatePayNum(ItemID)
	local MostPayNum = self:GetMostPayNum(ItemID)
	self.MostPayNum = MostPayNum
	local LimitNum = _G.LeveQuestMgr:GetRestoreNum()
	self.PayBtnRecommendState = (MostPayNum == 0 or LimitNum <= 0) and 0 or 1
	self.EffectVisible = not (MostPayNum == 0 or LimitNum <= 0)
	if _G.LeveQuestMgr:GetPaySingleOrMost() == LeveQuestDefine.PayType.Single then
		-- self.PayText =  (MostPayNum == 0 or LimitNum <= 0) and _G.LSTR(880004) or string.format(_G.LSTR(880003), 1)
		self.PayText = string.format(_G.LSTR(880003), 1)  -- 交纳%d次
		self.MostPayNum = 1
		return
	end
	self.PayText = (MostPayNum == 0 or LimitNum <= 0) and _G.LSTR(880004) or string.format(_G.LSTR(880003), MostPayNum) -- 交纳， 交纳%d次
end

function LeveQuestTaskInfoItemVM:GetMostPayNum(ItemID)
	local Cfg = self.Cfg
	local NeededItem = Cfg.RequireItem
	local NeededItemNum = NeededItem.Num or 1
	local OwnNum = _G.LeveQuestMgr:GetCanPayItemNum(ItemID)
	local PayNum = math.floor(OwnNum/NeededItemNum)
	return PayNum or 1
end

function LeveQuestTaskInfoItemVM:GetEnoughPayItemIndex()
	for i = 1, self.RewardPayList:Length() do
		local ItemData = self.RewardPayList:Get(i)
		if ItemData ~= nil then
			local Cfg = self.Cfg
			if Cfg ~= nil then
				local IsEnough = false
				local NeedNum = 1
				local PayNum = 0
				local NeededItem = Cfg.RequireItem
				if NeededItem ~= nil and NeededItem.ID ~= 0 then
					local ItemID = ItemData.ResID
					NeedNum = NeededItem.Num or 1
					local OwnNum = _G.LeveQuestMgr:GetCanPayItemNum(ItemID)
					IsEnough = OwnNum >= NeedNum
					PayNum = math.floor(OwnNum / NeedNum)
					if IsEnough then
						return i
					end
				end
			end
		end
	end

	return 1
end

function LeveQuestTaskInfoItemVM:GetEnoughPayItemID(Index)
	for i = 1, self.RewardPayList:Length() do
		local ItemData = self.RewardPayList:Get(i)
		if ItemData ~= nil and Index == i then
			return ItemData.ID
		end
	end
	return 0
end

function LeveQuestTaskInfoItemVM:GetPayBtnRecommendState()
	return self.PayBtnRecommendState
end

function LeveQuestTaskInfoItemVM.SortItemByHQ(a, b)
    return ItemUtil.IsHQ(a.ID) == ItemUtil.IsHQ(b.ID) or (ItemUtil.IsHQ(a.ID)and not ItemUtil.IsHQ(b.ID))
end

function LeveQuestTaskInfoItemVM.SortItemByRate(a, b)
    return a.Rate > b.Rate
end


--要返回当前类
return LeveQuestTaskInfoItemVM