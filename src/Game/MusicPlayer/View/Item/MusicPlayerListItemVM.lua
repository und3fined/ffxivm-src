--
-- Author: ds_yangyumian
-- Date: 2023-12-08 10:00
-- Description:
--
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MusicPlayerMgr = require("Game/MusicPlayer/MusicPlayerMgr")
local MusicPlayerCfg = require("TableCfg/MusicPlayerCfg")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

local LSTR = _G.LSTR

local TextColor = {
	"4D85B4FF", --蓝
	"313131", --黑
	"6c6964", --灰
	"BD8213FF", --黄
}

---@class MusicPlayerListItemVM : UIViewModel
local MusicPlayerListItemVM = LuaClass(UIViewModel)

---Ctor
function MusicPlayerListItemVM:Ctor()
	self.NumText = nil
	self.Name = nil
	self.TextNameColor = nil
	self.TextNumColor = nil
	self.BtnSwitchVisible = false
	self.BtnDeleteVisible = false
	self.BtnAddVisible = false
	self.ListInfo = nil
	self.MusicInfo = nil
	self.IsNil = false
	self.CurIndex = nil
	self.ImgSelectVisible1 = false
	self.ImgSelectVisible2 = false
	self.ImgPlayingVisible = false
	self.TextNumVisible = true
end

function MusicPlayerListItemVM:OnInit()

end

function MusicPlayerListItemVM:OnBegin()

end

function MusicPlayerListItemVM:OnEnd()

end

function MusicPlayerListItemVM:IsEqualVM(Value)

end

function MusicPlayerListItemVM:UpdateVM(List)
	--FLOG_ERROR("MusicPlayerListItemVM = %s",table_to_string(List))
	self.MusicInfo = List
	self:UpdateItemInfo(List)
end

function MusicPlayerListItemVM:UpdateItemInfo(List)
	self.ListInfo = List
	self.NumText = MusicPlayerMgr:SetNumber(List.Index)
	self.Name = List.MusicName
	self.MusicID = List.MusicID
	self.CurIndex = List.Index
	if List.IsNil == true then 
		self.TextNameColor = TextColor[3]
	else
		self.TextNameColor = TextColor[2]
	end
	self.TextNumColor = TextColor[4]
	self.IsNil = List.IsNil
	if MusicPlayerMgr.EditState then--and MusicPlayerMgr.RighListChoseIndex ~= nil then 
		self:UpdateItemBtnState()
	else
		self.ImgSelectVisible1 = false
		self.ImgSelectVisible2 = false
		self.BtnDeleteVisible = false
		self.BtnSwitchVisible = false
		self.BtnAddVisible = false
		self.TextNumVisible = true
		self.ImgPlayingVisible = false
		self.TextNameColor = TextColor[2]
	end
end

function MusicPlayerListItemVM:UpdateItemBtnState()
	-- self.BtnDeleteVisible = true
	-- self.BtnSwitchVisible = true
	-- self.BtnAddVisible = true
	-- print(self.IsNil)
	if self.IsNil and MusicPlayerMgr.IsChoseRight then
		self.BtnDeleteVisible = false
		self.BtnSwitchVisible = false
		self.BtnAddVisible = true
	elseif not self.IsNil and MusicPlayerMgr.EditState and MusicPlayerMgr.IsChoseRight then
		self.BtnDeleteVisible = true	
		self.BtnAddVisible = false
		if self.MusicID == MusicPlayerMgr.RighListChoseMusicID then
			self.BtnSwitchVisible = false
		else
			self.BtnSwitchVisible = true
		end
	elseif not self.IsNil and MusicPlayerMgr.EditState and MusicPlayerMgr.IsChoseLeft then
		self.BtnDeleteVisible = true
		if self.MusicID == MusicPlayerMgr.LeftChosedID then
			self.BtnSwitchVisible = false
		else
			self.BtnSwitchVisible = true
		end
		self.BtnAddVisible = false
	elseif not self.IsNil and MusicPlayerMgr.EditState then
		self.BtnDeleteVisible = true
		self.BtnSwitchVisible = false
		self.BtnAddVisible = false
	elseif self.IsNil and MusicPlayerMgr.IsChoseLeft then
		self.BtnDeleteVisible = false
		self.BtnSwitchVisible = true
		self.BtnAddVisible = false
	else
		self.BtnDeleteVisible = false
		self.BtnSwitchVisible = false
		self.BtnAddVisible = false
	end

	if MusicPlayerMgr.EditState then
		self.ImgPlayingVisible = false
		self.TextNumVisible = true
		if self.IsNil then
			self.ImgSelectVisible1 = true
		else
			self.ImgSelectVisible1 = false
		end
	else
		self.ImgSelectVisible1 = false
		self.ImgSelectVisible2 = false
	end
end

function MusicPlayerListItemVM:AddMusicForEditMusicInfo()
	local EditInfo = MusicPlayerMgr.EditMusicInfo
	local CurIndex = self.CurIndex
	local OldList = self:SetOldList(EditInfo)
	MusicPlayerMgr:SetOldPlayList(OldList[1])
	local RighListChoseMusicID = MusicPlayerMgr.RighListChoseMusicID
	local MusicInfo = MusicPlayerCfg:FindCfgByKey(RighListChoseMusicID)
	if MusicInfo == nil then
		local Tips = LSTR(1190014)
		MsgTipsUtil.ShowTips(Tips)
		return
	end
	EditInfo[CurIndex].Time = MusicInfo.Time
	EditInfo[CurIndex].MusicName = MusicInfo.MusicName
	EditInfo[CurIndex].MusicID = RighListChoseMusicID
	EditInfo[CurIndex].IsNil = false
	MusicPlayerMgr.EditMusicInfo[CurIndex] = EditInfo[CurIndex]
	MusicPlayerMgr:PlayListIsChanged()
	--MusicPlayerMgr.IsCanSave = true
	--MusicPlayerMainPaneVM:UpdateConfirmBtnState()
end

function MusicPlayerListItemVM:DeleteMusicForEditMusicInfo()
	local EditInfo = MusicPlayerMgr.EditMusicInfo 
	local CurIndex = self.CurIndex
	local OldList = self:SetOldList(EditInfo)
	MusicPlayerMgr:SetOldPlayList(OldList[1])
	EditInfo[CurIndex].Time = 0
	EditInfo[CurIndex].MusicName = LSTR(1190009)
	EditInfo[CurIndex].MusicID = 0
	EditInfo[CurIndex].IsNil = true
	MusicPlayerMgr.EditMusicInfo[CurIndex] = EditInfo[CurIndex]
	MusicPlayerMgr:PlayListIsChanged()
	MusicPlayerMgr.IsChoseLeft = false
	MusicPlayerMgr.LeftChosedID = nil
end

function MusicPlayerListItemVM:SwithMusicForEditMusicInfo()
	if not MusicPlayerMgr.IsChoseLeft and not MusicPlayerMgr.IsChoseRight then
		return
	end
	local EditInfo = MusicPlayerMgr.EditMusicInfo
	local CurIndex = self.CurIndex
	local OldList = self:SetOldList(EditInfo)
	MusicPlayerMgr:SetOldPlayList(OldList[1])
	local ChoseMusicID

	if MusicPlayerMgr.IsChoseRight then
		ChoseMusicID = MusicPlayerMgr.RighListChoseMusicID
		local MusicInfo = MusicPlayerCfg:FindCfgByKey(ChoseMusicID)
		EditInfo[CurIndex].Time = MusicInfo.Time
		EditInfo[CurIndex].MusicName = MusicInfo.MusicName
		EditInfo[CurIndex].MusicID = ChoseMusicID
		EditInfo[CurIndex].IsNil = false
		MusicPlayerMgr.EditMusicInfo[CurIndex] = EditInfo[CurIndex]
		MusicPlayerMgr:PlayListIsChanged()
	elseif MusicPlayerMgr.IsChoseLeft then
		ChoseMusicID = MusicPlayerMgr.LeftChosedID
		--旧的
		if EditInfo[MusicPlayerMgr.CurPlayIndex] and OldList then
			EditInfo[MusicPlayerMgr.CurPlayIndex].Time = OldList[1].Time
			EditInfo[MusicPlayerMgr.CurPlayIndex].MusicName = OldList[1].MusicName
			EditInfo[MusicPlayerMgr.CurPlayIndex].MusicID = OldList[1].MusicID
			EditInfo[MusicPlayerMgr.CurPlayIndex].IsNil = OldList[1].IsNil
			MusicPlayerMgr.EditMusicInfo[MusicPlayerMgr.CurPlayIndex] = OldList[1]
	
			--新的
			local MusicInfo = MusicPlayerCfg:FindCfgByKey(ChoseMusicID)
			EditInfo[CurIndex].Time = MusicInfo.Time
			EditInfo[CurIndex].MusicName = MusicInfo.MusicName
			EditInfo[CurIndex].MusicID = ChoseMusicID
			EditInfo[CurIndex].IsNil = false
			MusicPlayerMgr.EditMusicInfo[CurIndex] = EditInfo[CurIndex]
			MusicPlayerMgr:PlayListIsChanged()
		end
	end

	MusicPlayerMgr.IsChoseLeft = false
	MusicPlayerMgr.LeftChosedID = nil
end

function MusicPlayerListItemVM:UpdateItemState(NewValue)
	if MusicPlayerMgr.EditState then
		self.TextNumVisible = true
		self.ImgPlayingVisible = false
		if self.IsNil then
			self.ImgSelectVisible2 = false
		else
			self.ImgSelectVisible2 = NewValue
		end

	else
		self.ImgSelectVisible1 = false
		self.ImgSelectVisible2 = false

		if NewValue then
			self.TextNameColor = TextColor[1]
			self.TextNumColor = TextColor[1]
			if self.MusicID == MusicPlayerMgr.CurPlayerPlayingMusicID and not MusicPlayerMgr.PlayerPlayState then
				self.ImgPlayingVisible = false
				self.TextNumVisible = true
				return
			end
		else
			self.TextNameColor = TextColor[2]
			self.TextNumColor = TextColor[4]
		end

		self.TextNumVisible = not NewValue
		self.ImgPlayingVisible = NewValue
	end

	--self:UpdateCurPlayingItem()
end

function MusicPlayerListItemVM:UpdateCurPlayingItem()
	if self.MusicID == MusicPlayerMgr.CurPlayerPlayingMusicID then
		if self.CurIndex == MusicPlayerMgr.CurPlayIndex and MusicPlayerMgr.CurPlayListIndex == MusicPlayerMgr.CurPlayingListIndex then
			self.TextNumVisible = not MusicPlayerMgr.PlayerPlayState
			self.ImgPlayingVisible = MusicPlayerMgr.PlayerPlayState
		end
	end
end

function MusicPlayerListItemVM:SetOldList(List)
	local NewList = {}
	for i = 1, #List do
		if i == self.CurIndex then
			local Data = {}
			Data.Time = List[i].Time
			Data.MusicName = List[i].MusicName
			Data.MusicID = List[i].MusicID
			Data.IsNil = List[i].IsNil
			table.insert(NewList, Data)
		end
	end
	return NewList
end

return MusicPlayerListItemVM