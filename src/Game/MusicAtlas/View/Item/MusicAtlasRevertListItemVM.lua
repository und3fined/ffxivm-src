--
-- Author: ds_yangyumian
-- Date: 2023-12-08 10:00
-- Description:
--
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

---@class MusicAtlasRevertListItemVM : UIViewModel
local MusicAtlasRevertListItemVM = LuaClass(UIViewModel)

---Ctor
function MusicAtlasRevertListItemVM:Ctor()
	self.Number = nil
	self.NormalName = nil
	self.PlayingName = nil
	self.PanelNormalVisible = nil
	self.PanelPlayingVisible = nil
	self.MusicID = nil
end

function MusicAtlasRevertListItemVM:OnInit()

end

function MusicAtlasRevertListItemVM:OnBegin()

end

function MusicAtlasRevertListItemVM:OnEnd()

end

function MusicAtlasRevertListItemVM:UpdateVM(List)
	self:UpdateItemInfo(List)
end

function MusicAtlasRevertListItemVM:UpdateItemInfo(List)
	self.MusicID = List.MusicID
	self:SetName(List.Number, List.Name)
end

function MusicAtlasRevertListItemVM:SetName(Number, Name)
	local Number = self:SetNumber(Number)
	self.Number = Number
	self.NormalName = Name
	self.PlayingName = Name
end

function MusicAtlasRevertListItemVM:SetNumber(Num)
	local NewNum = ""
	if Num < 10 then
		NewNum = string.format("%s%d", "00", Num)
	elseif Num < 100 then
		NewNum = string.format("%s%d", "0", Num)
	else
		NewNum = string.format("%s", Num)
	end
	return NewNum
end

function MusicAtlasRevertListItemVM:SetSelectState(Value)
	self.PanelNormalVisible = not Value
	self.PanelPlayingVisible = Value
end

function MusicAtlasRevertListItemVM:IsEqualVM(Value)
	return true
end

return MusicAtlasRevertListItemVM