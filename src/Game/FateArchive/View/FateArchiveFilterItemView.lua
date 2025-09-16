---
--- Author: guanjiewu
--- DateTime: 2023-12-13 16:09
--- Description:
---

local UIView = require("UI/UIView")
local CommDropDownListView = require("Game/Common/DropDownList/CommDropDownListView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class FateArchiveFilterItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field DropListPanel UFCanvasPanel
---@field ExtendItem CommDropDownExtendItemView
---@field ImgDown UFImage
---@field ImgIcon UFImage
---@field ImgListBg UFImage
---@field ImgUp UFImage
---@field SizeBoxRange USizeBox
---@field TableViewItemList UTableView
---@field TextContent UFTextBlock
---@field ToggleBtnExtend UToggleButton
---@field DropDown bool
---@field ParamShowIcon bool
---@field ParamIcon SlateBrush
---@field PositionUp Vector2D
---@field PositionDown Vector2D
---@field AlignmentUp Vector2D
---@field AlignmentDown Vector2D
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FateArchiveFilterItemView = LuaClass(CommDropDownListView, true)

function FateArchiveFilterItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.DropListPanel = nil
	--self.ExtendItem = nil
	--self.ImgDown = nil
	--self.ImgIcon = nil
	--self.ImgListBg = nil
	--self.ImgUp = nil
	--self.SizeBoxRange = nil
	--self.TableViewItemList = nil
	--self.TextContent = nil
	--self.ToggleBtnExtend = nil
	--self.DropDown = nil
	--self.ParamShowIcon = nil
	--self.ParamIcon = nil
	--self.PositionUp = nil
	--self.PositionDown = nil
	--self.AlignmentUp = nil
	--self.AlignmentDown = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FateArchiveFilterItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ExtendItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

return FateArchiveFilterItemView