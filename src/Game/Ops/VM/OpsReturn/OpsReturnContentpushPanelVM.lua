--
-- Author: ZhengJanChuan
-- Date: 2025-07-17 20:32
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIBindableList = require("UI/UIBindableList")
local OpsReturnMgr = require("Game/Ops/OpsReturn/OpsReturnMgr")
local OpsReturnContentpushBannerItemVM = require("Game/Ops/VM/OpsReturn/Item/OpsReturnContentpushBannerItemVM")
local OpsReturnCfg = require("TableCfg/OpsReturnCfg")
local OpsReturnTagCfg = require("TableCfg/OpsReturnTagCfg")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")

---@class OpsReturnContentpushPanelVM : UIViewModel
local OpsReturnContentpushPanelVM = LuaClass(UIViewModel)

---Ctor
function OpsReturnContentpushPanelVM:Ctor()
	self.TagName = ""
	self.PointList = UIBindableList.New(OpsReturnContentpushBannerItemVM)
	self.BannerList = UIBindableList.New(OpsReturnContentpushBannerItemVM)
	self.BannerImgList = UIBindableList.New(OpsReturnContentpushBannerItemVM)

	self.DropListSelectIndex = nil
end

function OpsReturnContentpushPanelVM:OnInit()
end

function OpsReturnContentpushPanelVM:OnBegin()
end

function OpsReturnContentpushPanelVM:OnEnd()
end

function OpsReturnContentpushPanelVM:OnShutdown()
end


function OpsReturnContentpushPanelVM:UpdateTagName()
	local TagList = _G.OpsReturnMgr:GetTagList()
	table.sort(TagList, function(a, b) 
		local ATagCfg = OpsReturnTagCfg:FindCfgByKey(a)
		local BTagCfg = OpsReturnTagCfg:FindCfgByKey(b)
		if ATagCfg ~= nil and BTagCfg ~= nil then
			return ATagCfg.Priority < BTagCfg.Priority
		end
		return false
	end)
	if not table.is_nil_empty(TagList) then
		local TagCfg = OpsReturnTagCfg:FindCfgByKey(TagList[1])
		if TagCfg ~= nil then
			self.TagName = TagCfg.TagName or ""
		end
	end
end

-- 更新当前的版本内容list
function OpsReturnContentpushPanelVM:UpdateVersionList()
	local Version =  _G.UE.UVersionMgr.GetGameVersion()
	local CfgList = OpsReturnCfg:FindAllCfg()
	self.PointList:Clear()
	local ItemList = {}
	local TempItemList = {}
	local ServerTimeStamp = _G.TimeUtil.GetServerLogicTime()
	for _, v in ipairs(CfgList) do
		if v.Version == Version then
			local IsChecked = v.LimitTime == 0 
			if v.LimitTime ~= 0  then
				local IsActive = false
				local Cfg1 = ActivityNodeCfg:FindCfgByKey(v.ActivityID)
				if Cfg1 then
					local StartTime = _G.OpsActivityMgr:GetActivityStartTime(Cfg1) or 0
					local EndTime = _G.OpsActivityMgr:GetActivityEndTime(Cfg1) or 0
					IsActive = (EndTime > 0) and (ServerTimeStamp >= StartTime) and (ServerTimeStamp <= EndTime)
				end
				IsChecked = IsActive
			end
			if IsChecked then
			local Item = table.deepcopy(v)
			Item.BannerID = v.ID
			Item.BannerImg = v.Banner
			table.insert(ItemList, Item)
			end
		end
	end
	self.PointList:UpdateByValues(ItemList) -- 点是实际的内容。
	local Len = #ItemList
	for i = 1, 50 * Len do
		local Index = ((i - 1) % Len) + 1
		local Item = ItemList[Index]
		Item.IndexPos = Index
		table.insert(TempItemList, Item)
	end
	self.BannerImgList:UpdateByValues(TempItemList)
	self.DropListSelectIndex = 1
end

-- 更新右边的内容list StartIndex(开始的索引)
function OpsReturnContentpushPanelVM:UpdateContentList(StartIndex)
	--Todo 读取玩家标签数据，然后塞出内容
	local TagList = OpsReturnMgr:GetTagList()
	local ContentList = OpsReturnMgr:GetContentsByPlayerTags(TagList)
	if #ContentList < 6 then
		local NewContent = OpsReturnMgr:GetSupplementContentsByPlayerTags(TagList, ContentList)
		ContentList = NewContent
	end
	local Content, StartIndex, EndIndex = OpsReturnMgr:GetLoopContents(ContentList, StartIndex == nil and OpsReturnMgr:GetContentStartIndex() or StartIndex)
	OpsReturnMgr:SetContentStartIndex(StartIndex)
	OpsReturnMgr:SetContentEndIndex(EndIndex)
	local ItemList = {}
	self.BannerList:Clear()
	for _, v in ipairs(Content) do
		local Item = {}
		Item.BannerID = v.ID
		table.insert(ItemList, Item)
	end

	self.BannerList:UpdateByValues(ItemList)
end

--要返回当前类
return OpsReturnContentpushPanelVM