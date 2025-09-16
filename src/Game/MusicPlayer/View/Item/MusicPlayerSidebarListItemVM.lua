--
-- Author: ds_yangyumian
-- Date: 2023-12-08 10:00
-- Description:
--
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MusicPlayerMgr = require("Game/MusicPlayer/MusicPlayerMgr")

---@class MusicPlayerSidebarListItemVM : UIViewModel
local MusicPlayerSidebarListItemVM = LuaClass(UIViewModel)

---Ctor
function MusicPlayerSidebarListItemVM:Ctor()
	self.NumText = nil
	self.Name = nil
	self.MusicID = nil
	self.ImgPlayingVisible = false
	self.TextNumVisible = false
	self.IsSame = false
	self.TextNameColor = nil
	self.ImgSelectVisible = false
	self.Type = nil
	--self.TextColor = "313131"
end

function MusicPlayerSidebarListItemVM:OnInit()

end

function MusicPlayerSidebarListItemVM:OnBegin()

end

function MusicPlayerSidebarListItemVM:OnEnd()

end

function MusicPlayerSidebarListItemVM:IsEqualVM(Value)

end

function MusicPlayerSidebarListItemVM:UpdateVM(List)
	--FLOG_ERROR("MusicPlayerSidebarListItemVM = %s",table_to_string(List))
	self:UpdateItemInfo(List)
end

function MusicPlayerSidebarListItemVM:UpdateItemInfo(List)
	local Index
	if List.SearchID ~= nil then
		Index = List.SearchID
	else
		Index = List.Index
	end

	local NumOrer
	if List.Number then
		NumOrer = List.Number
	else
		NumOrer = Index
	end
	self.NumText = MusicPlayerMgr:SetNumber(NumOrer, true)
	self.Name = List.MusicName
	self.MusicID = List.MusicID
	self.Type = List.Type
end


function MusicPlayerSidebarListItemVM:UpdateItemState(Value)
	self.ImgSelectVisible = Value
	if Value then
		self.TextNameColor = "4D85B4FF"
	else
		self.TextNameColor = "313131"
	end

	self.ImgPlayingVisible = Value
	self.TextNumVisible = not Value
end

return MusicPlayerSidebarListItemVM