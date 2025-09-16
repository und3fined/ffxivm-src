local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class OpsConcertGetListItemVM : UIViewModel
local OpsConcertGetListItemVM = LuaClass(UIViewModel)
---Ctor
function OpsConcertGetListItemVM:Ctor()
    self.TaskTitle = nil
    self.RewardGetSituationDes = nil
    self.BunInfoVisible = nil
    self.BunDetailVisible = nil
    self.Icon = nil
    self.Num = nil
	self.IconChooseVisible = nil
	self.IsValid = nil
	self.IconReceivedVisible = nil
end

function OpsConcertGetListItemVM:UpdateVM(Params)
    if Params == nil then
		self.IsValid = false
		return
	end
	self.IsValid = true
	self.ItemID = Params.ItemID
	self.IconChooseVisible = false
	self.TaskTitle = Params.TaskTitle
	self.RewardGetSituationDes = Params.Des
	self.Icon = Params.Icon
	self.Num = Params.Num
	self.BtnInfoVisible = Params.BtnInfoVisible or false
	self.BtnDetailVisible = Params.BtnDetailVisible or false
	self.IconReceivedVisible = Params.IconReceivedVisible or false
	self.IsMask = Params.IconReceivedVisible or false
	if self.IconReceivedVisible then
		self.ImgListBight = false
		self.ImgListDark = true
	else
		self.ImgListBight = true
		self.ImgListDark = false
	end
	self.HelpInfoDes = Params.HelpInfoDes
end

return OpsConcertGetListItemVM