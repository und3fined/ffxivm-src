---
--- Author: anypkvcai
--- DateTime: 2022-05-02 16:25
--- Description:
---

local CommCheckBoxBaseView = require("Game/Common/Btn/CommCheckBoxBaseView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class CommCheckBoxView : CommCheckBoxBaseView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FImg_Check UFImage
---@field FImg_UnCheck UFImage
---@field TextContent UFTextBlock
---@field ToggleButton UToggleButton
---@field Font SlateFontInfo
---@field Min Font Size int
---@field Reduction Step int
---@field Enable Show Detail Text Tips bool
---@field Text Adaptation ETextAdaptation
---@field Text Overflow ETextOverflow
---@field Max Need Width float
---@field Max Need Height float
---@field Horizontal ETextJustify
---@field Vertical EVerticalAlignment
---@field Style CommCheckBoxImgStruct
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommCheckBoxView = LuaClass(CommCheckBoxBaseView, true)

--- !!!! See CommCheckBoxBaseView See CommCheckBoxBaseView See CommCheckBoxBaseView !!!!!
---     一些通用设置在CommCheckBoxBaseView 新增通用方法也加在CommCheckBoxBaseView


function CommCheckBoxView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FImg_Check = nil
	--self.FImg_UnCheck = nil
	--self.TextContent = nil
	--self.ToggleButton = nil
	--self.Font = nil
	--self.Min Font Size = nil
	--self.Reduction Step = nil
	--self.Enable Show Detail Text Tips = nil
	--self.Text Adaptation = nil
	--self.Text Overflow = nil
	--self.Max Need Width = nil
	--self.Max Need Height = nil
	--self.Horizontal = nil
	--self.Vertical = nil
	--self.Style = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommCheckBoxView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommCheckBoxView:OnInit()
	self.Super.OnInit(self)
	self:SetColorType(self.CheckColorType, self.IsGary)
end

return CommCheckBoxView