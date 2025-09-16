--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2024-05-30 14:30:20
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2024-06-25 19:57:38
FilePath: \Client\Source\Script\Game\LeveQuest\VM\Item\LeveQuestPropsItemVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
--
-- Author: ZhengJianChuan
-- Date: 2023-12-27 17:11
-- Description: 委托道具ItemListItem
--


local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemUtil = require("Utils/ItemUtil")
local ItemVM = require("Game/Item/ItemVM")
local UIUtil = require("Utils/UIUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local BagMgr = require("Game/Bag/BagMgr")
local CraftingLogDefine = require("Game/CraftingLog/CraftingLogDefine")

local LSTR

---@class LeveQuestPropsItemVM : UIViewModel
local LeveQuestPropsItemVM = LuaClass(UIViewModel)

---Ctor
function LeveQuestPropsItemVM:Ctor()
	self.ItemID = nil
	self.TextPer = ""
	self.TextPerVisible = false
	self.Selected = false
	self.LevelVisible = false
	self.ItemVM = ItemVM.New()
end

function LeveQuestPropsItemVM:OnInit()
	--只有在UIViewModelConfig配置的全局的ViewModel，才会调用到OnInit函数
	--只初始化自身模块的数据，不能引用其他的同级模块
end

function LeveQuestPropsItemVM:OnBegin()
end

function LeveQuestPropsItemVM:OnEnd()
end

function LeveQuestPropsItemVM:OnShutdown()
end

function LeveQuestPropsItemVM:SetSelected(Selected)
	self.Selected = Selected
end

function LeveQuestPropsItemVM:UpdateNum(TextQuantity)
	self.TextQuantity = TextQuantity
end

function LeveQuestPropsItemVM:UpdateVM(Params)
	if Params == nil or Params.ItemID == nil then
		return
	end
	self.ItemID = Params.ItemID
	self.ItemData = Params
	self.TextPerVisible = Params.TextPerVisible or false
	self.TextPer = Params.TextPer
	
	local Item = ItemUtil.CreateItem(self.ItemID, Params.Num)
	if self.ItemID == 0 then
		Item = {ResID = 0, IsQualityVisible = false}
	end
	self.ItemVM:UpdateVM(Item, {IsShowNumProgress = false, HideItemLevel = true})
	self.LevelVisible = false
end

function LeveQuestPropsItemVM:IsEqualVM(Value)
	return self.ItemID == Value.ItemID
end


function LeveQuestPropsItemVM:UpdataTextNum(MakeNumber)
	if self.ItemID == 0 or self.ItemID == nil then
		return
	end
	local MakeCount = MakeNumber
    if MakeNumber == 0 then
        MakeCount = CraftingLogDefine.NormalLowestMakeCount
    end

	local ItemData = self.ItemData
	local SpendNumber = ItemData.ItemNum * MakeCount
	local HaveCount
	if self.bImgHQShow then
		HaveCount = BagMgr:GetItemHQNum(ItemData.ItemID)
	else
		HaveCount = BagMgr:GetItemNumWithHQ(ItemData.ItemID)
	end
	local LabelInfo
	if SpendNumber > HaveCount then
		LabelInfo =string.format("<span color=\"#FF0000FF\">%s</>", HaveCount)
	else
		LabelInfo =string.format("<span color=\"#FFFFFFFF\">%s</>", HaveCount)
	end
	self.TextQuantityVisible = true
	self.TextQuantity = string.format("%s/%d", LabelInfo, SpendNumber)
end

--要返回当前类
return LeveQuestPropsItemVM