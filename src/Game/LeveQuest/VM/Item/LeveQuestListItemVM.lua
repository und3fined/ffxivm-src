--
-- Author: ZhengJianChuan
-- Date: 2023-12-27 11:20
-- Description:
--


local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemUtil = require("Utils/ItemUtil")
local UIUtil = require("Utils/UIUtil")
local ItemVM = require("Game/Item/ItemVM")

local NormalColor = "#D5D5D5FF"
local SelectedColor = "#FFF4D0FF"

---@class LeveQuestListItemVM : UIViewModel
local LeveQuestListItemVM = LuaClass(UIViewModel)

---Ctor
function LeveQuestListItemVM:Ctor()
    self.ProfTypeIcon = nil
    self.QuestName = ""
    self.TextLv = ""
    self.LevelNum = 0
    self.NeededItem = nil
    self.TextItemName = ""
    self.QuantityNum = ""
    self.IconCheckVisible = false
    self.IsSelected = false
    self.SelectedColor = "#D5D5D5FF"
    self.SelectedLineColor = "#AFAFAFFF"
    self.ItemID = nil
    self.QuantityNumVisible = false
    self.ID = nil
    self.PropsItemVM = ItemVM.New()
    self.ItemLevelVisible = false
end

function LeveQuestListItemVM:OnInit()
	--只有在UIViewModelConfig配置的全局的ViewModel，才会调用到OnInit函数
	--只初始化自身模块的数据，不能引用其他的同级模块
end

function LeveQuestListItemVM:OnBegin()
end

function LeveQuestListItemVM:OnEnd()
end

function LeveQuestListItemVM:OnShutdown()
end

function LeveQuestListItemVM:UpdateVM(Value)
    self.ID = Value.ID
    self.IconCheckVisible = Value.IconCheckVisible
    self.Level = string.format(_G.LSTR(880001), Value.Level)
    self.LevelNum = Value.Level
    self.PropType = Value.PropType
    self.QuantityNumVisible = Value.QuantityNumVisible
    self.ProfTypeIcon = Value.PropType
    self.QuestName = Value.QuestName
    self.TextLv = string.format(_G.LSTR(880001), Value.Level)
    self.LevelNum = Value.Level
    -- 道具
    local Item = Value.RequireItem
    if Item.Num > 1 then
        self.TextItemName = string.format("%sx%d", ItemUtil.GetItemName(Item.ID), Item.Num)
    else
        self.TextItemName = ItemUtil.GetItemName(Item.ID)
    end
    self.ItemID = Item.ID
    self.TextQuantityVisible = false
    local IconID = ItemUtil.GetItemIcon(Item.ID)
    if IconID ~= nil then
        self.PropItemIcon = UIUtil.GetIconPath(IconID)
    end

    self.QuantityNum = Value.QuantityNum

    local Item1 = ItemUtil.CreateItem(self.ItemID, 0)
	self.PropsItemVM:UpdateVM(Item1, {IsShowNum = false, IsShowNumProgress = false})

end

function LeveQuestListItemVM:SetSelected(IsSelected)
    self.IsSelected = IsSelected
    self.SelectedColor = IsSelected and SelectedColor or NormalColor
    self.SelectedLineColor = IsSelected and "#F1EAB6FF" or "#AFAFAFFF"
end

function LeveQuestListItemVM:IsEqualVM(Value)
	return self.ID == Value.ID
end

--要返回当前类
return LeveQuestListItemVM