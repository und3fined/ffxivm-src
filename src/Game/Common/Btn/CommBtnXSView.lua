---
--- Author: v_hggzhang
--- DateTime: 2023-11-06 14:46
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommBtnParentView = require("Game/Common/Btn/CommBtnParentView")

---@class CommBtnXSView : CommBtnParentView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Button UFButton
---@field Img UFImage
---@field TextContent UFTextBlock
---@field AnimPressed UWidgetAnimation
---@field AnimReleased UWidgetAnimation
---@field ParamLongPress bool
---@field ParamPressTime float
---@field bAutoAddSpace bool
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommBtnXSView = LuaClass(CommBtnParentView, true)

function CommBtnXSView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Button = nil
	--self.Img = nil
	--self.TextContent = nil
	--self.AnimPressed = nil
	--self.AnimReleased = nil
	--self.ParamLongPress = nil
	--self.ParamPressTime = nil
	--self.bAutoAddSpace = false
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommBtnXSView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommBtnXSView:OnInit()
	self:SetImgAssetPath()
	self.Super:OnInit()
end

function CommBtnXSView:OnDestroy()
	self.Super:OnDestroy()
end

function CommBtnXSView:OnShow()
	self.Super:OnShow()

	if(self.bAutoAddSpace == true) then
		UIUtil.AutoAddSpaceForTwoWords(self.TextContent)
	end
	---初始化时播放Released动画的结尾，防止上一次动画异常中断导致的按钮表现异常
	self:SetReleaseAnimEnd()
end

function CommBtnXSView:OnHide()

end

function CommBtnXSView:OnRegisterUIEvent()
	self.Super:OnRegisterUIEvent()

end

function CommBtnXSView:OnRegisterGameEvent()

end

function CommBtnXSView:OnRegisterBinder()

end



return CommBtnXSView