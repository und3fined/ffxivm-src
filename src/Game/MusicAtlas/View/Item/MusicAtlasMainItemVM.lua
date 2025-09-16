--
-- Author: ds_yangyumian
-- Date: 2023-12-08 10:00
-- Description:
--
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local ImgGreyList = {
	"Texture2D'/Game/UI/Texture/MusicAtlas/UI_MusicAtlas_Img_MusicType01_Grey.UI_MusicAtlas_Img_MusicType01_Grey'",
	"Texture2D'/Game/UI/Texture/MusicAtlas/UI_MusicAtlas_Img_MusicType02_Grey.UI_MusicAtlas_Img_MusicType02_Grey'",
	"Texture2D'/Game/UI/Texture/MusicAtlas/UI_MusicAtlas_Img_MusicType03_Grey.UI_MusicAtlas_Img_MusicType03_Grey'",
	"Texture2D'/Game/UI/Texture/MusicAtlas/UI_MusicAtlas_Img_MusicType04_Grey.UI_MusicAtlas_Img_MusicType04_Grey'",
}

local ImgNormalList = {
	"Texture2D'/Game/UI/Texture/MusicAtlas/UI_MusicAtlas_Img_MusicType01_Normal.UI_MusicAtlas_Img_MusicType01_Normal'",
	"Texture2D'/Game/UI/Texture/MusicAtlas/UI_MusicAtlas_Img_MusicType02_Normal.UI_MusicAtlas_Img_MusicType02_Normal'",
	"Texture2D'/Game/UI/Texture/MusicAtlas/UI_MusicAtlas_Img_MusicType03_Normal.UI_MusicAtlas_Img_MusicType03_Normal'",
	"Texture2D'/Game/UI/Texture/MusicAtlas/UI_MusicAtlas_Img_MusicType04_Normal.UI_MusicAtlas_Img_MusicType04_Normal'",
}

local ImgSelectList = {
	"Texture2D'/Game/UI/Texture/MusicAtlas/UI_MusicAtlas_Img_MusicType01_Select.UI_MusicAtlas_Img_MusicType01_Select'",
	"Texture2D'/Game/UI/Texture/MusicAtlas/UI_MusicAtlas_Img_MusicType02_Select.UI_MusicAtlas_Img_MusicType02_Select'",
	"Texture2D'/Game/UI/Texture/MusicAtlas/UI_MusicAtlas_Img_MusicType03_Select.UI_MusicAtlas_Img_MusicType03_Select'",
	"Texture2D'/Game/UI/Texture/MusicAtlas/UI_MusicAtlas_Img_MusicType04_Select.UI_MusicAtlas_Img_MusicType04_Select'",
}

local Pattern1 = {1, 3, 1, 3, 1, 2, 4, 2, 4, 2}
local Pattern2 = {3, 1, 3, 1, 3, 4, 2, 4, 2, 4}

---@class MusicAtlasMainItemVM : UIViewModel
local MusicAtlasMainItemVM = LuaClass(UIViewModel)

---Ctor
function MusicAtlasMainItemVM:Ctor()
	self.Number = nil
	self.Name = nil
	self.GreyName = nil
	self.NarmalName = nil
	self.PanelGreyVisible = false
	self.PanelNormalVisible = false
	self.GreySlect = false
	self.NormalSelect = false
	self.GreySlect2 = false
	self.NormalSelect2 = false
	self.IsUnLock = false
	self.MusicID = nil
	self.ImgGreyType = nil
	self.ImgGreySeleceType = nil
	self.ImgGreySelece2Type = nil
	self.ImgNormalType = nil
	self.ImgNormalSelectType = nil
	self.ImgNormalSelect2Type = nil
end

function MusicAtlasMainItemVM:OnInit()

end

function MusicAtlasMainItemVM:OnBegin()

end

function MusicAtlasMainItemVM:OnEnd()

end

-- function MusicAtlasMainItemVM:IsEqualVM(Value)
-- 	return true
-- end

function MusicAtlasMainItemVM:UpdateVM(List)
	self:UpdateItemInfo(List)
end

function MusicAtlasMainItemVM:UpdateItemInfo(List)
	self.NormalSelect = false
	self.NormalSelect2 = false
	self.GreySlect = false
	self.GreySlect2 = false
	self.Type = self:SetCurType(List.Number)
	self.Number = List.Number
	self.Name = List.Name
	self.MusicID = List.MusicID
	self.IsUnLock = List.IsUnLock
	self:SetPanel(List.IsUnLock)
	self:SetItemBGImgType(List.IsUnLock)
	self:SetName(List.Number, List.Name, List.IsUnLock)
end

function MusicAtlasMainItemVM:SetName(Number, Name, IsUnLock)
	local Number = self:SetNumber(Number)
	if IsUnLock then
		self.NarmalName = string.format("%s %s", Number, Name)
	else
		self.GreyName = string.format("%s %s", Number, Name)
	end
end

function MusicAtlasMainItemVM:SetPanel(IsUnLock)
	if IsUnLock then
		self.PanelGreyVisible = false
		self.PanelNormalVisible = true
	else
		self.PanelGreyVisible = true
		self.PanelNormalVisible = false
	end
end

function MusicAtlasMainItemVM:SetItemBGImgType(IsUnLock) 
	if IsUnLock then
		self.ImgNormalType = ImgNormalList[self.Type]
		self.ImgNormalSelectType = ImgSelectList[self.Type]
		self.ImgNormalSelect2Type = ImgSelectList[self.Type]
	else
		self.ImgGreyType = ImgGreyList[self.Type]
		self.ImgGreySeleceType = ImgSelectList[self.Type]
		self.ImgGreySelece2Type = ImgSelectList[self.Type]
	end
end

function MusicAtlasMainItemVM:UpdateGreyImgType()
	self.ImgGreySeleceType = ImgGreyList[self.Type]
end

function MusicAtlasMainItemVM:UpdateSelectState(NewValue)
	if self.IsUnLock then
		self.NormalSelect = NewValue
		self.NormalSelect2 = NewValue
		self.GreySlect = not NewValue
		self.GreySlect2 = not NewValue
	else
		self.NormalSelect = not NewValue
		self.NormalSelect2 = not NewValue
		self.GreySlect = NewValue
		self.GreySlect2 = NewValue
	end	
end

function MusicAtlasMainItemVM:SetCurType(Number)
	local Group = (Number - 1) % 20
	local Type
	if Group < 10 then
		Type = Pattern1[Group + 1]
	else
		Type = Pattern2[Group - 10 + 1]
	end
	
	return Type
end

function MusicAtlasMainItemVM:SetNumber(Num)
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

function MusicAtlasMainItemVM:IsEqualVM(Value)
	return true
end

return MusicAtlasMainItemVM