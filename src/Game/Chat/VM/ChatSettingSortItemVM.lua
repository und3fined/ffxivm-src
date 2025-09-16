---
--- Author: xingcaicao
--- DateTime: 2025-03-29 14:43
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local COLOR_NORMAL = "D5D5D5FF"
local COLOR_HIGHLIGHT = "B2A487FF"
local COLOR_DISABLE = "828282FF"

-- 置顶/置底
local IMG_PATH_NORMAL = "PaperSprite'/Game/UI/Atlas/Button/Frames/UI_Com_Btn_UP_png.UI_Com_Btn_UP_png'"
local IMG_PATH_DISABLE = "PaperSprite'/Game/UI/Atlas/Button/Frames/UI_Com_Btn_UP_Disab_png.UI_Com_Btn_UP_Disab_png'"

-- 下移/上移
local MOVE_IMG_PATH_NORMAL = "PaperSprite'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Icon_UPArrow_png.UI_Chat_Icon_UPArrow_png'"
local MOVE_IMG_PATH_DISABLE = "PaperSprite'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Icon_UPArrow_Disab_png.UI_Chat_Icon_UPArrow_Disab_png'"

---@class ChatSettingSortItemVM : UIViewModel
local ChatSettingSortItemVM = LuaClass(UIViewModel)

---Ctor
function ChatSettingSortItemVM:Ctor( )
	self.Name = nil 
	self.Channel = nil
    self.CannotHide = false 
    self.IsHide = false 
	self.Pos = 0

	self.IsTop = false
	self.IsBottom = false

	self.NameColor = COLOR_NORMAL

	self.MoveUpTextColor = COLOR_HIGHLIGHT
	self.MoveDownTextColor = COLOR_HIGHLIGHT

	self.TopImgPath = IMG_PATH_NORMAL
	self.BottomImgPath = IMG_PATH_NORMAL

	self.MoveUpImgPath = MOVE_IMG_PATH_NORMAL
	self.MoveDownImgPath = MOVE_IMG_PATH_NORMAL
end

function ChatSettingSortItemVM:IsEqualVM(Value)
	return false 
end

function ChatSettingSortItemVM:UpdateVM(Value)
	if nil == Value then
		Value = {}
	end

	self.Name = Value.Name
	self.Channel = Value.Channel 
    self.CannotHide = Value.CannotHide == true

	self:SetIsHide(Value.IsHide == true, false)
	self:SetPos(Value.Pos or 0, false)

	self:UpdateColorAndImgPath()
end

function ChatSettingSortItemVM:UpdateColorAndImgPath()
	local NameColor = COLOR_NORMAL
	local MoveUpTextColor = COLOR_HIGHLIGHT
	local MoveDownTextColor = COLOR_HIGHLIGHT
	local TopImgPath = IMG_PATH_NORMAL
	local BottomImgPath = IMG_PATH_NORMAL
	local MoveUpImgPath = MOVE_IMG_PATH_NORMAL
	local MoveDownImgPath = MOVE_IMG_PATH_NORMAL

	if self.IsHide then
		NameColor = COLOR_DISABLE
		MoveUpTextColor = COLOR_DISABLE
		MoveDownTextColor = COLOR_DISABLE
		TopImgPath = IMG_PATH_DISABLE
		BottomImgPath = IMG_PATH_DISABLE
		MoveUpImgPath = MOVE_IMG_PATH_DISABLE
		MoveDownImgPath = MOVE_IMG_PATH_DISABLE		
	else
		if self.IsTop then
			MoveUpTextColor = COLOR_DISABLE
			TopImgPath = IMG_PATH_DISABLE
			MoveUpImgPath = MOVE_IMG_PATH_DISABLE
		elseif self.IsBottom then
			MoveDownTextColor = COLOR_DISABLE
			BottomImgPath = IMG_PATH_DISABLE
			MoveDownImgPath = MOVE_IMG_PATH_DISABLE
		end
	end

	self.NameColor = NameColor
	self.MoveUpTextColor = MoveUpTextColor
	self.MoveDownTextColor = MoveDownTextColor
	self.TopImgPath = TopImgPath
	self.BottomImgPath = BottomImgPath
	self.MoveUpImgPath = MoveUpImgPath
	self.MoveDownImgPath = MoveDownImgPath
end

function ChatSettingSortItemVM:SetIsHide(b, IsUpdateColorAndImgPath)
	self.IsHide = b == true

	if IsUpdateColorAndImgPath ~= false then
		self:UpdateColorAndImgPath()
	end
end

function ChatSettingSortItemVM:SetPos(Pos, IsUpdateColorAndImgPath)
	self.Pos = Pos or 0

	if Pos == 1 then
		self.IsTop = true
		self.IsBottom = false
	elseif Pos >= _G.ChatVM.SettingSortItemCount then
		self.IsTop = false 
		self.IsBottom = true 
	else
		self.IsTop = false 
		self.IsBottom = false 
	end

	if IsUpdateColorAndImgPath ~= false then
		self:UpdateColorAndImgPath()
	end
end

return ChatSettingSortItemVM