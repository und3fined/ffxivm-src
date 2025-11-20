--
-- Author: ZhengJanChuan
-- Date: 2025-07-17 16:39
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIBindableList = require("UI/UIBindableList")
local ItemUtil = require("Utils/ItemUtil")
local MajorUtil = require("Utils/MajorUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local ItemVM = require("Game/Item/ItemVM")
local GUIDE_TYPE = ProtoCommon.GUIDE_TYPE

---@class OpsReturnWelfarePanelVM : UIViewModel
local OpsReturnWelfarePanelVM = LuaClass(UIViewModel)

---Ctor
function OpsReturnWelfarePanelVM:Ctor()
	self.Title = ""
	self.Content = ""

	self.AwardText = ""
	self.NewbeeBenfitContent = ""

	self.NewbeeBenfitHelpID = 0
	self.NewbeeBenfitIcon = nil
	self.NewbeeBenfitPromoteIcon = nil
	self.ChannelIcon = nil
	self.NewbeeBenfitPromoteText = ""
	self.FriendsContent = ""
	self.ArmyContent = ""
	self.RewardList = UIBindableList.New(ItemVM, {HideItemLevel = true, IsShowNumProgress = false, IsShowSelectStatus = false})
end

function OpsReturnWelfarePanelVM:OnInit()
end

function OpsReturnWelfarePanelVM:OnBegin()
end

function OpsReturnWelfarePanelVM:OnEnd()
end

function OpsReturnWelfarePanelVM:OnShutdown()
end

function OpsReturnWelfarePanelVM:UpdateWelfareData(NodeID)
	-- 暂时写死，后续根据服务器传送下来的数据 读取活动节点表，重新赋值
	local Name = MajorUtil.GetMajorName()
	local Prof =  _G.ActorMgr:GetMajorRoleDetail().Prof
	local Timestamp = 0
	if Prof and Prof.ProfList then
		local MinTime = nil
		for _, v in pairs(Prof.ProfList) do
			if MinTime == nil or MinTime < v.OnTime  then
				MinTime = v.OnTime
			end
		end
		if MinTime ~= nil then
			Timestamp = MinTime
		end
	end
	-- local Icon = ""
	-- local GuideType = _G.OpsReturnMgr:GetGuideType()
	-- if GuideType == GUIDE_TYPE.GUIDE_TYPE_NEWBIE then
	-- 	Icon = "PaperSprite'/Game/UI/Atlas/HUD/Frames/UI_Icon_061523_png.UI_Icon_061523_png'"
	-- elseif GuideType == GUIDE_TYPE.GUIDE_TYPE_RETURNEE then
	-- 	Icon = "PaperSprite'/Game/UI/Atlas/HUD/Frames/UI_Icon_061537_png.UI_Icon_061537_png'"
	-- end
	local TempName = string.format(_G.LSTR(1680029), Name)
	-- self.Title = string.format("%s%s", RichTextUtil.GetTexture(Icon, 40, 40), TempName)
	self.Title = string.format(_G.LSTR(1680029), Name)
	self.Content =  string.format(_G.LSTR(1680030), LocalizationUtil.LocalizeStringDate(os.date("%Y年%m月%d日", Timestamp))  , Name)
	self.NewbeeBenfitPromoteText = _G.LSTR(1680025)
	self.NewbeeBenfitContent = _G.LSTR(1680026) --权益描述
	self.FriendsContent = _G.LSTR(1680027) --好友描述
	self.ArmyContent = _G.LSTR(1680028)  --部队描述
	self.AwardText = _G.LSTR(1680024) --查看邮件
end 

function OpsReturnWelfarePanelVM:UpdateRewardList(TempItemList)
	local ItemList = {}
	self.RewardList:Clear()
	for _, v in ipairs(TempItemList) do
		if v.ItemID and v.ItemID ~= 0 then
			local Item = ItemUtil.CreateItem(v.ItemID, v.Num)
			Item.IsShowNum = true
			table.insert(ItemList, Item)
		end
	end

	self.RewardList:UpdateByValues(ItemList)
end

--要返回当前类
return OpsReturnWelfarePanelVM