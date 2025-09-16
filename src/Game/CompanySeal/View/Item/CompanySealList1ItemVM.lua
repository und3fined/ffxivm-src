local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemUtil = require("Utils/ItemUtil")
local UIUtil = require("Utils/UIUtil")
local BagMgr = require("Game/Bag/BagMgr")
local RichTextUtil = require("Utils/RichTextUtil")



local LSTR = _G.LSTR
local SubIconPath = "PaperSprite'/Game/UI/Atlas/CompanySeal/Frames/UI_CompanySeal_Icon_Submittable_png.UI_CompanySeal_Icon_Submittable_png'"
local LockIconPath = "PaperSprite'/Game/UI/Atlas/CompanySeal/Frames/UI_CompanySeal_Icon_Lock_png.UI_CompanySeal_Icon_Lock_png'"


---@class CompanySealList1ItemVM : UIViewModel
local CompanySealList1ItemVM = LuaClass(UIViewModel)

---Ctor
function CompanySealList1ItemVM:Ctor()
	self.ImgFocusVisible = nil
	self.JobIcon = nil
	self.JobIconSimple = nil
	self.Name = nil
	self.TaskState = nil
	self.RequireNum = nil
	self.TagSilverVisible = nil
	self.TagGoldVisible = nil
	self.ItemIcon = nil
	self.NQItemID = nil
	self.HQItemID = nil
	self.ImgFocusVisible = nil
	self.ItemList = nil
	self.RewardList = nil
	self.ItemQualityIcon = nil
	self.CurID = nil
	self.State = nil
	self.CraftJobID = nil
	self.SilverText = ""
	self.GoldText = ""
	self.TextQuantity = nil
	self.TextLevel = nil
	self.IconChoose = nil
	self.StateIcon = nil
	self.StateIconVisible = nil
	self.TaskLv = nil
	self.ProfessionMask = nil
	self.ItemMask = nil
end

function CompanySealList1ItemVM:OnInit()

end

---UpdateVM
---@param List table
function CompanySealList1ItemVM:UpdateVM(List)
	self.TextQuantity = false
	self.TextLevel = false
	self.IconChoose = false
	self.CurID = List.ID
	self.JobIcon = List.CraftJobID
	self.JobIconSimple = List.CraftJobID
	self.CraftJobID = List.CraftJobID
	self.NeedNum = List.Num
	self.Times = List.Times
	self.Exp = List.Exp
	self.CompanySeal = List.CompanySeal
	self.NQItemID = List.NQItemID
	self.HQItemID = List.HQItemID
	local IconID = ItemUtil.GetItemIcon(List.NQItemID)
	local Path = UIUtil.GetIconPath(IconID)
	self.ItemIcon = Path
	self.ItemList = {}
	self.RewardList = {}
	self.State = List.State
	self.ItemQualityIcon = ItemUtil.GetItemColorIcon(List.NQItemID)
	self:SetTaskState(List.NQItemID, List.HQItemID, List.Times, List.ItemName, List.Level)
end

function CompanySealList1ItemVM:SetTaskState(NQItemID, HQItemID, Times, ItemName, Level)
	local HasNQItemNum, HasHQItemNum = self:GetCanSubmitNum(NQItemID, HQItemID)
	self.HasNQItemNum = HasNQItemNum
	self.HasHQItemNum = HasHQItemNum

	local Count = 0
	if NQItemID and NQItemID ~= 0 then
		Count = Count + 1
	end
	if HQItemID and HQItemID ~= 0 then
		Count = Count + 1
	end

	local Index = 1
	for i = 1, Count do
		local Data = {}
		Data.NeedNum = self.NeedNum
		Data.Times = self.Times
		Data.RewardList = {}
		Data.RewardList[1] = self.Exp
		Data.RewardList[2] = self.CompanySeal
		Data.RewardList.IsReward = false
		Data.State = self.State
		if HQItemID and HQItemID ~= 0 and Index == 1 then
			Data.ItemID = HQItemID
			Data.HasItem = HasHQItemNum
			Data.Index = Index
			Data.Times = Times
			Data.IsHQ = true
			table.insert(self.ItemList, Data)
		else
			if NQItemID and NQItemID ~= 0 then
				Data.ItemID = NQItemID
				Data.HasItem = HasNQItemNum
				Data.Index = Index
				Data.Times = Times
				Data.IsHQ = false
				table.insert(self.ItemList, Data)
			end
		end
		Index = Index + 1
	end

	local StateText = ""
	local NeedTitle = RichTextUtil.GetText(LSTR(1160018), "#d5d5d5")
	local NeedNum = string.format("%s：<span color=\"#d5d5d5\">%s</>", NeedTitle, self.NeedNum)
	local Name = RichTextUtil.GetText(ItemName, "#d5d5d5")
	local LevelText = string.format("<span color=\"#d5d5d5\">%d</>", Level)
	local MaskState = false
	self.StateIconVisible = false
	if self.State == 1 or self.State == 2 or self.State == 3 then
		StateText = RichTextUtil.GetText(LSTR(1160018), "#d1ba8e") 
		self.StateIcon = SubIconPath
		self.StateIconVisible = true
	elseif self.State == 4 then
		StateText = RichTextUtil.GetText(LSTR(1160035), "#d5d5d5") 
	elseif self.State == 5 then
		StateText = RichTextUtil.GetText(LSTR(1160042), "#828282") 
		self.StateIcon = LockIconPath
		self.StateIconVisible = true
	elseif self.State == 6 then
		StateText = RichTextUtil.GetText(LSTR(1160028), "#828282") 
		NeedTitle = RichTextUtil.GetText(LSTR(1160018), "#828282")
		NeedNum = string.format("%s：<span color=\"#828282\">%s</>", NeedTitle, self.NeedNum)
		Name = 	RichTextUtil.GetText(ItemName, "#828282")
		LevelText = string.format("<span color=\"#828282\">%d</>", Level)
		MaskState = true
	end
	self.TaskLv = LevelText
	self.RequireNum = NeedNum
	self.TaskState = StateText
	self.ProfessionMask = MaskState
	self.ItemMask = MaskState
	self.Name = Name

	if Times > 1 and HQItemID ~= 0 and HasHQItemNum >= self.NeedNum then
		self.TagGoldVisible = true
		self.TagSilverVisible = false
		self.GoldText = "400%"
	else
		if Times > 1 then
			self.TagGoldVisible = false
			self.TagSilverVisible = true
			self.SilverText = "200%"
		else
			self.TagGoldVisible = false
			self.TagSilverVisible = false
		end
	end
end

function CompanySealList1ItemVM:GetCanSubmitNum(NQItemID, HQItemID)
	local IsEquip = ItemUtil.CheckIsEquipmentByResID(NQItemID)
	local Data = {}			

	for _, value in pairs(_G.CompanySealMgr.CurEquipList) do
		if value.ResID == NQItemID or value.ResID == HQItemID then
			local IsInScheme = value.Attr.Equip.IsInScheme
			local CarryList = value.Attr.Equip.GemInfo.CarryList
			local HasCarry = false
			for _, CarryInfo in pairs(CarryList) do
				if CarryInfo then
					HasCarry = true
					break
				end
			end

			if  not IsInScheme and not HasCarry then
				table.insert(Data, value.ResID)
			end
		end
	end

	if IsEquip then
		local HasNQItemNum = 0
		local HasHQItemNum = 0
		for _, ResID in pairs(Data) do
			local IsHQ = ItemUtil.IsHQ(ResID)
			if IsHQ then
				HasHQItemNum = HasHQItemNum + 1
			else
				HasNQItemNum = HasNQItemNum + 1
			end
		end
		return HasNQItemNum, HasHQItemNum
	else
		local HasNQItemNum = BagMgr:GetItemNum(NQItemID)
		local HasHQItemNum = BagMgr:GetItemHQNum(NQItemID)
		return HasNQItemNum, HasHQItemNum
	end

end

function CompanySealList1ItemVM:IsEqualVM(Value)
    --return nil ~= Value and Value.ID == self.ShopItemData.ID
end


return CompanySealList1ItemVM