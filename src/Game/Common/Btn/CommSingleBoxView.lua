---
--- Author: anypkvcai
--- DateTime: 2022-05-25 10:14
--- Description:
---

local CommCheckBoxBaseView = require("Game/Common/Btn/CommCheckBoxBaseView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIDefine = require("Define/UIDefine")

local SearchBtnColorType = UIDefine.SearchBtnColorType
local EToggleButtonState = _G.UE.EToggleButtonState
---@class CommSingleBoxView : CommCheckBoxBaseView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FImg_Check UFImage
---@field FImg_UnCheck UFImage
---@field TextContent UFTextBlock
---@field ToggleButton UToggleButton
---@field Font SlateFontInfo
---@field Horizontal ETextJustify
---@field Min Font Size int
---@field Reduction Step int
---@field Text Adaption ETextAdaptation
---@field Text Over Flow ETextOverflow
---@field Enable Show Detail Text Tips bool
---@field Max Nedd Width float
---@field Max Need Height float
---@field Style CommSingleBoxImgStruct
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommSingleBoxView = LuaClass(CommCheckBoxBaseView, true)

--- !!!! See CommCheckBoxBaseView See CommCheckBoxBaseView See CommCheckBoxBaseView !!!!!
---     一些通用设置在CommCheckBoxBaseView 新增通用方法也加在CommCheckBoxBaseView

function CommSingleBoxView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FImg_Check = nil
	--self.FImg_UnCheck = nil
	--self.TextContent = nil
	--self.ToggleButton = nil
	--self.Font = nil
	--self.Horizontal = nil
	--self.Min Font Size = nil
	--self.Reduction Step = nil
	--self.Text Adaption = nil
	--self.Text Over Flow = nil
	--self.Enable Show Detail Text Tips = nil
	--self.Max Nedd Width = nil
	--self.Max Need Height = nil
	--self.Style = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommSingleBoxView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommSingleBoxView:OnInit()
	self.Super.OnInit(self)
	self:SetColorType(self.CheckColorType, self.IsGary)
end

return CommSingleBoxView