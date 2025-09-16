local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemUtil = require("Utils/ItemUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local UIBindableList = require("UI/UIBindableList")
local TreasureHuntMapSItemVM = require("Game/TreasureHunt/VM/TreasureHuntMapSItemVM")
local ItemVM = require("Game/Item/ItemVM")

local ItemCfg = require("TableCfg/ItemCfg")
local LootMappingCfg = require("TableCfg/LootMappingCfg")
local InterpretTreasureMapCfg = require("TableCfg/InterpretTreasureMapCfg")
local CounterMgr = require("Game/Counter/CounterMgr")

local TreasureHuntMainVM = LuaClass(UIViewModel)
function TreasureHuntMainVM:Ctor()
	self.PanelOrdinaryVisible = false
	self.ImgTitleDecoOrdinary = false
	self.PanelAdvancedVisible = false
	self.ImgTitleDecoAdvanced = false
	self.MapInfoPanelVisible = false
	self.PanelNotOpenVisible = false
	self.TableViewWidgetVisible = false

	self.BtnReadingVisible = false
	self.BtnGoFindVisible = false
	self.PanelNoGetVisible = false

	self.TextMapName = ""
	self.RichTextLevel = ""
	self.RichTextCount = ""
	self.TextNumber = ""
end

function TreasureHuntMainVM:OnInit()
	self:UpdateStamina()
	self.RewardList = UIBindableList.New(ItemVM)
	self.GetWayList = UIBindableList.New()

	self.MapCount = 10
	self.MainPanelMapItemVMList = {}
	for i = 1,self.MapCount do
		local MainPanelMapItemVM = TreasureHuntMapSItemVM.New()
		table.insert(self.MainPanelMapItemVMList,MainPanelMapItemVM)
	end

	-- 初始化地图数据
	self:InitMap()
	-- 刷新界面
	self:UpdateMapItems()
end

function TreasureHuntMainVM:OnShutdown()
	self.RewardList = nil
end

function TreasureHuntMainVM:InitMap()
	self.MapDatas ={}

	-- 初始化所有宝图
	for i = 1,self.MapCount do
		local mapData = {}
		mapData.Opened = 0
		if math.floor(i % 2) == 0 then
			mapData.Number = 8
		else
			mapData.Number = 1
		end
		mapData.PosID = 0
		table.insert(self.MapDatas,mapData)
	end

	-- 配置表所有地图
	local Index = 1
	local MultiIndex = 2
	local Cfgs = InterpretTreasureMapCfg:FindAllCfg()
	if Cfgs ~= nil then
		for _,V in pairs(Cfgs) do
			local mapData = {}
			mapData.UnDecodeMapID = V.UnReadID
			mapData.ID = V.ID
			mapData.mapTitle = V.MapTitle
			mapData.mapLevel = V.Level
			mapData.LootID = V.LootID
			mapData.Opened = 1
			mapData.Number = V.Number
			mapData.PosID = 0
			if mapData.Number > 1 then
				self.MapDatas[MultiIndex] = mapData
				MultiIndex = MultiIndex + 2
			else
				self.MapDatas[Index] = mapData
				Index = Index + 2
			end
		end
	end
end

function TreasureHuntMainVM:UpdateMapData(TreasureAllMap)
	-- 把服务器下发的地图数据填充到地图数据
	local MapCount = #TreasureAllMap.maps

	for i = 1,MapCount do
		for j = 1, self.MapCount do
			if self.MapDatas[j].ID == TreasureAllMap.maps[i].ID then
				self.MapDatas[j].ID = TreasureAllMap.maps[i].ID
				self.MapDatas[j].MapResID  = TreasureAllMap.maps[i].MapResID
				self.MapDatas[j].Pos  = TreasureAllMap.maps[i].Pos
				self.MapDatas[j].PosID = TreasureAllMap.maps[i].PosID
			end
		end
	end

	-- 刷新界面
	self:UpdateMapItems()
end

function TreasureHuntMainVM:GetTreasureHuntMap(ResID)
	for i = 1,#self.MapDatas do
		if ResID == self.MapDatas[i].ID then
			return self.MapDatas[i]
		end
	end
end

function TreasureHuntMainVM:GetMapInfo(mapIndex)
	if mapIndex < 1 or mapIndex > self.MapCount then return end
	return self.MapDatas[mapIndex]
end

-- 当前是否已经解读过的宝图
function TreasureHuntMainVM:GetDecodeMapID(MapResID)
	local count = #self.MapDatas
	for i = 1,count do
		if MapResID == self.MapDatas[i].UnDecodeMapID then
			if self:GetAllMapCount(self.MapDatas[i].ID) > 0 then
				return self.MapDatas[i].ID
			end
		end
	end
end

-- 当前玩家是否有未解读的宝图
function TreasureHuntMainVM:HaveUnDecodeMap()
	local count = #self.MapDatas
	for i = 1,count do
		if self:GetMapCount(self.MapDatas[i].UnDecodeMapID) > 0 then
			return true
		end
	end
	return false
end

-- 是否有特定未解读的宝图
function TreasureHuntMainVM:HaveUnDecodeMapByID(MapResID)
	if MapResID == nil then return false end

	local count = #self.MapDatas
	for i = 1,count do
		if self.MapDatas[i].ID == MapResID then
			if self:GetMapCount(self.MapDatas[i].UnDecodeMapID) > 0 then
				return true
			end
		end
	end
	return false
end

-- 当前玩家是否有未解读的单人宝图
function TreasureHuntMainVM:HaveUnDecodeSingleMap()
	local count = #self.MapDatas
	for i = 1,count do
		if self.MapDatas[i].Number <= 1 then
			if self:GetMapCount(self.MapDatas[i].UnDecodeMapID) > 0 then
				return true
			end
		end
	end
	return false
end

-- 当前玩家是否有未解读的多人宝图
function TreasureHuntMainVM:HaveUnDecodeMultipleMap()
	local count = #self.MapDatas
	for i = 1,count do
		if self.MapDatas[i].Number > 1 then
			if self:GetMapCount(self.MapDatas[i].UnDecodeMapID) > 0 then
				return true
			end
		end
	end
	return false
end

-- 当前玩家拥有宝图数
function TreasureHuntMainVM:GetMapCount(ResID)
	return  _G.BagMgr:GetItemNum(ResID)
end

-- 当前玩家拥有的所有宝图数，包括仓库
function TreasureHuntMainVM:GetAllMapCount(ResID)
	local ItemNumInBag =  _G.BagMgr:GetItemNum(ResID)
	local ItemNumInDepot = _G.DepotVM:GetDepotItemNum(ResID)
	return  ItemNumInBag + ItemNumInDepot
end

function TreasureHuntMainVM:GetMapItemVM(mapIndex)
	if mapIndex < 1 or mapIndex > self.MapCount then return end
	return self.MainPanelMapItemVMList[mapIndex]
end

function TreasureHuntMainVM:UpdateMapItems()
	for i = 1,self.MapCount do
		self:UpdateMapItem(i)
	end
end

function TreasureHuntMainVM:UpdateMapItem(mapIndex)
	if mapIndex < 1 or mapIndex > self.MapCount then return end

	local MapData = self:GetMapInfo(mapIndex)
	if self.MainPanelMapItemVMList[mapIndex] ~= nil then
		self.MainPanelMapItemVMList[mapIndex]:UpdateMainPanel(MapData)
	end
end

function TreasureHuntMainVM:SetMapSelected(mapIndex)
	if mapIndex < 1 or mapIndex > self.MapCount then return end

	for i = 1,self.MapCount do
		if self.MainPanelMapItemVMList[i] ~= nil then
			if i == mapIndex then
				self.MainPanelMapItemVMList[i]:SetSelected(true)
			else
				self.MainPanelMapItemVMList[i]:SetSelected(false)
			end
		end
	end
end

function TreasureHuntMainVM:UpdateStamina()
	self.CounterID = 22300
	local CurrentLimit = CounterMgr:GetCounterRestore(self.CounterID) or 0	-- 每天最大获取次数
	local CurrentNum = CounterMgr:GetCounterCurrValue(self.CounterID) or 0	-- 今日已获得次数
	self.TextNumber = string.format("%d/%d", CurrentNum, CurrentLimit)
end

function TreasureHuntMainVM:UpdateMapItemData(mapIndex)
	if mapIndex < 1 or mapIndex > self.MapCount then return end

	local mapData = self:GetMapInfo(mapIndex)
	if mapData == nil then return end

	if mapData.Number > 1 then
		self.PanelOrdinaryVisible = false
		self.PanelAdvancedVisible = true
	else
		self.PanelOrdinaryVisible = true
		self.PanelAdvancedVisible = false
	end

	-- 现在又要求未开放的也有选中特效
	self:SetMapSelected(mapIndex)

	if mapData.Opened == 0 then
		self.MapInfoPanelVisible = false
		self.PanelNotOpenVisible = true
		self.ImgTitleDecoOrdinary = false
		self.ImgTitleDecoAdvanced = false
		self.TableViewWidgetVisible = false

		return
	else
		self.MapInfoPanelVisible = true
		self.PanelNotOpenVisible = false
		self.TableViewWidgetVisible = true

		if mapData.Number > 1 then
			self.ImgTitleDecoOrdinary = false
			self.ImgTitleDecoAdvanced = true
		else
			self.ImgTitleDecoOrdinary = true
			self.ImgTitleDecoAdvanced = false
		end
	end

	local DecodeMapCount = self:GetMapCount(mapData.ID)						-- 是否存在已经解读的地图
	local UnDecodeMapCount = self:GetMapCount(mapData.UnDecodeMapID)   		-- 未解读的地图数
	local MapCount = DecodeMapCount + UnDecodeMapCount

	self.TextMapName = mapData.mapTitle
	if mapData.Number > 1 then
		self.RichTextLevel = string.format(LSTR(640027),mapData.mapLevel)  --推荐等级：%d级 组队
	else
		self.RichTextLevel = string.format(LSTR(640028),mapData.mapLevel)  --推荐等级：%d级 单人
	end

	if MapCount == 0 then
		self.RichTextCount = string.format(LSTR(640029), RichTextUtil.GetText(string.format("%d",MapCount), "AF4C58FF")) --数量：%s
	else
		self.RichTextCount = string.format(LSTR(640029), RichTextUtil.GetText(string.format("%d",MapCount), "BD8213FF")) --数量：%s
	end

	-- 填充掉落物品单
	self:UpdateRewardItems(mapData)
	self:UpdateGetWayItems(mapData.UnDecodeMapID)

	if DecodeMapCount > 0 then
		self.BtnReadingVisible = false
		self.BtnGoFindVisible = true
		self.PanelNoGetVisible = false
	else
		if UnDecodeMapCount > 0 then
			self.BtnReadingVisible = true
			self.BtnGoFindVisible = false
			self.PanelNoGetVisible = false
		else
			self.BtnReadingVisible = false
			self.BtnGoFindVisible = false
			self.PanelNoGetVisible = true
		end
	end
end

function TreasureHuntMainVM:UpdateRewardItems(mapData)
	local RewardList = {}
	local LootIDs = mapData.LootID
	self.RewardList:Clear()
	for _, LootID in ipairs(LootIDs) do
		local LootCfg = LootMappingCfg:FindCfg(string.format("ID=%d", LootID))
		if (LootCfg ~= nil) then
			if LootCfg.Programs then
				for _, Program in ipairs(LootCfg.Programs) do
					local RewardItemList =  ItemUtil.GetLootItems(Program.ID)
					if RewardItemList ~= nil then
						for _, RewardItem in ipairs(RewardItemList) do
							local Cfg = ItemCfg:FindCfgByKey(RewardItem.ResID)
							if Cfg ~= nil then
								local Item = {}
								Item.ResID = RewardItem.ResID
								Item.Num = RewardItem.Num
								table.insert(RewardList, Item)
							end
						end
					end
				end
			end
		end
	end

	self.RewardList:UpdateByValues(RewardList)
end

function TreasureHuntMainVM:UpdateGetWayItems(ItemID)
	self.GetWayList = ItemUtil.GetItemGetWayList(ItemID)
end

return TreasureHuntMainVM