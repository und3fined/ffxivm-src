--[[
Author: jususchen jususchen@tencent.com
Date: 2025-07-14 14:27:16
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2025-07-14 14:41:05
FilePath: \Script\Game\Team\View\Item\TeamReadytoconfirmJobItemView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetImageBrushByResFunc = require("Binder/UIBinderSetImageBrushByResFunc")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ProfUtil = require("Game/Profession/ProfUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoCS = require("Protocol/ProtoCS")

---@class TeamReadytoconfirmJobItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconCancel UFImage
---@field IconCheck UFImage
---@field IconJob UFImage
---@field IconState UFImage
---@field ImgBG UFImage
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TeamReadytoconfirmJobItemView = LuaClass(UIView, true)

function TeamReadytoconfirmJobItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconCancel = nil
	--self.IconCheck = nil
	--self.IconJob = nil
	--self.IconState = nil
	--self.ImgBG = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TeamReadytoconfirmJobItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TeamReadytoconfirmJobItemView:OnInit()
	
	self.Binders = {
		{"ConfirmState", 		UIBinderValueChangedCallback.New(self, nil, self.OnConfirmStateChanged)},
		{ "ProfID", 			UIBinderSetProfIcon.New(self, self.IconJob) },
		{ "ProfID", 			UIBinderSetImageBrushByResFunc.NewByResFunc(function(ProfID)
			local PF = ProfUtil.Prof2Func(ProfID)
			if PF == ProtoCommon.function_type.FUNCTION_TYPE_GUARD then
				return "Texture2D'/Game/UI/Texture/Team/UI_Team_Img_Win_Job_Blue.UI_Team_Img_Win_Job_Blue'"
			end
			if PF == ProtoCommon.function_type.FUNCTION_TYPE_RECOVER then
				return "Texture2D'/Game/UI/Texture/Team/UI_Team_Img_Win_Job_Green.UI_Team_Img_Win_Job_Green'"
			end
			if PF == ProtoCommon.function_type.FUNCTION_TYPE_ATTACK then
				return "Texture2D'/Game/UI/Texture/Team/UI_Team_Img_Win_Job_Rad.UI_Team_Img_Win_Job_Rad'"
			end

			return "Texture2D'/Game/UI/Texture/Team/UI_Team_Img_Win_Job_White.UI_Team_Img_Win_Job_White'"
		end, self, self.ImgBG) },
		{ "Name", 				UIBinderSetText.New(self, self.TextName) },
		{ "IsCaptain", 			UIBinderSetIsVisible.New(self, self.IconState) },
		{ "bOnline", 			UIBinderValueChangedCallback.New(self, nil, function(View, Value)
			UIUtil.SetRenderOpacity(View, Value and 1 or 0.5)
		end)}
	}
end

function TeamReadytoconfirmJobItemView:OnRegisterBinder()
	if not self.Params or not self.Params.Data then
		return
	end

	self:RegisterBinders(self.Params.Data, self.Binders)
end

function TeamReadytoconfirmJobItemView:OnConfirmStateChanged(Value)
	UIUtil.SetIsVisible(self.IconCheck, Value == ProtoCS.Team.Team.ReadyVoteStatus.ReadyVoteStatusReady)
	UIUtil.SetIsVisible(self.IconCancel, Value == ProtoCS.Team.Team.ReadyVoteStatus.ReadyVoteStatusWait)
end

return TeamReadytoconfirmJobItemView