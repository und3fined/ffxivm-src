local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local EmotionUtils = require("Game/Emotion/Common/EmotionUtils")
local PhotoDefine = require("Game/Photo/PhotoDefine")
local PhotoUtil = require("Game/Photo/PhotoUtil")

---@class PhotoActionItemVM : UIViewModel
local PhotoActionItemVM = LuaClass(UIViewModel)
local EmotionMgr = _G.EmotionMgr
local PhotoMgr = _G.PhotoMgr

---Ctor
function PhotoActionItemVM:Ctor()
	self.ImgSelectVisible = nil
	self.NameText = nil
	self.ImgIcon = nil
	self.IsEnable = true
	self.ColorHex = ""
	self.AnimType = nil
	self.UseMouth = false
	self.IsMouthTip = false
end

function PhotoActionItemVM:UpdateVM(Value)
	self.Type = Value.Type
	self.ID = Value.ID
	self.NameText = Value.NameText
	if Value.Type == PhotoDefine.AnimType.Motion or Value.Type == PhotoDefine.AnimType.Face then
		self.ImgIcon = EmotionUtils.GetEmoActIconPath(Value.ImgIcon)
	else
		self.ImgIcon = Value.ImgIcon
	end
	self.ImgSelectVisible = false
	self.UseMouth = Value.IsUseMouth
	self:UpdateIsEnableAndColor()
end

function PhotoActionItemVM:UpdateIsEnableAndColor()
	local IsPlayer = PhotoMgr:IsCurSeltPlayer()
	local IsMajor = PhotoMgr:IsCurSeltMajor()
	local CurSelEntID = PhotoMgr.SeltEntID

	if self.Type == PhotoDefine.AnimType.Motion then
		self.IsEnable = IsPlayer and IsMajor and EmotionMgr:IsEnableID(self.ID, CurSelEntID)
		if self.UseMouth then
			self.IsEnable = self.IsEnable and not PhotoMgr.MouthID
			self.IsMouthTip = true
		end
	elseif self.Type == PhotoDefine.AnimType.Movement then
		self.IsEnable = IsPlayer and IsMajor and PhotoUtil.IsEnableIDMovement(CurSelEntID)
	elseif self.Type == PhotoDefine.AnimType.Face then
		self.IsEnable = IsPlayer and IsMajor and EmotionMgr:IsEnableID(self.ID, CurSelEntID)
		if self.UseMouth then
			self.IsEnable = self.IsEnable and not PhotoMgr.MouthID
			self.IsMouthTip = true
		end
	elseif self.Type == PhotoDefine.AnimType.Mouth then
		self.IsEnable = IsPlayer and IsMajor and EmotionMgr:IsEnableID(self.ID, CurSelEntID)
		if PhotoMgr.ActionID then
			self.IsEnable = self.IsEnable and not PhotoMgr:GetEmotionIsUseMouth(PhotoMgr.ActionID)
			self.IsMouthTip = true
		end
		if PhotoMgr.EmojiID then
			self.IsEnable = self.IsEnable and not PhotoMgr:GetEmotionIsUseMouth(PhotoMgr.EmojiID)
			self.IsMouthTip = true
		end
	end

	self.ColorHex = self.IsEnable and "#FFFFFFFF" or "#C1C1C1FF"
end

function PhotoActionItemVM:UpdateIconState(ID)
	self.ImgSelectVisible = ID == self.ID
end

function PhotoActionItemVM:IsEqualVM(Value)
	return nil ~= Value and Value.ID == self.ID and Value.Type == self.Type
end


--要返回当前类
return PhotoActionItemVM