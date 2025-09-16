local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local EmotionUtils = require("Game/Emotion/Common/EmotionUtils")
local PhotoDefine = require("Game/Photo/PhotoDefine")

---@class PhotoActionItemVM : UIViewModel
local PhotoActionItemVM = LuaClass(UIViewModel)
PhotoActionItemVM.ItemType = table.clone(PhotoDefine.AnimType) -- 动作，移动
---Ctor
function PhotoActionItemVM:Ctor()
	self.ImgSelectVisible = nil
	self.NameText = nil
	self.ImgIcon = nil
	self.IsEnable = true
	self.ColorHex = ""
	self.AnimType = nil
end

function PhotoActionItemVM:UpdateVM(Value)
	self.Type = Value.Type
	self.ID = Value.ID

	self.IsEnable = Value.IsEnable
	self.ColorHex = self.IsEnable and "#FFFFFFFF" or "#C1C1C1FF"
	self.NameText = Value.NameText
	if Value.Type == PhotoActionItemVM.ItemType.Motion or Value.Type == PhotoActionItemVM.ItemType.Face then
		self.ImgIcon = EmotionUtils.GetEmoActIconPath(Value.ImgIcon)
	else
		self.ImgIcon = Value.ImgIcon
	end
	self.ImgSelectVisible = false
end

function PhotoActionItemVM:UpdateIconState(ID)
	self.ImgSelectVisible = ID == self.ID
end

function PhotoActionItemVM:IsEqualVM(Value)
	return nil ~= Value and Value.ID == self.ID and Value.Type == self.Type
end


--要返回当前类
return PhotoActionItemVM