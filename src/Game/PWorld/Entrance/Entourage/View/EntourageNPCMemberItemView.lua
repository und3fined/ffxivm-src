---
--- Author: Administrator
--- DateTime: 2023-12-18 19:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView =  require("UI/Adapter/UIAdapterTableView")
local UIBinderSetProfIcon = require("Binder/UIBinderSetProfIcon")
local UIBinderSetProfName = require("Binder/UIBinderSetProfName")
local UIBinderSetSelectedIndex = require("Binder/UIBinderSetSelectedIndex")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local ProfUtil = require("Game/Profession/ProfUtil")
local ProtoCommon = require("Protocol/ProtoCommon")

local PROF_FUNC_TYPE = ProtoCommon.function_type

---@class EntourageNPCMemberItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgNPCAppearance UFImage
---@field ImgNPCBg UFImage
---@field ImgNPCJobBg UFImage
---@field ImgPlayerJob UFImage
---@field TextNPCInfo UFTextBlock
---@field TextNPCName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EntourageNPCMemberItemView = LuaClass(UIView, true)

function EntourageNPCMemberItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgNPCAppearance = nil
	--self.ImgNPCBg = nil
	--self.ImgNPCJobBg = nil
	--self.ImgPlayerJob = nil
	--self.TextNPCInfo = nil
	--self.TextNPCName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EntourageNPCMemberItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EntourageNPCMemberItemView:OnInit()
	self.Binders = {
		{ "Name", 						UIBinderSetText.New(self, self.TextNPCName) },
		{ "ProfName", 					UIBinderSetText.New(self, self.TextNPCInfo) },
		{ "Prof",						UIBinderValueChangedCallback.New(self, nil, self.OnProfChanged) },
		----------------------------------------------------------------------------------
		{ "ProfIcon", 					UIBinderSetBrushFromAssetPath.New(self, self.ImgPlayerJob) },
		{ "Portrait", 					UIBinderSetBrushFromAssetPath.New(self, self.ImgNPCAppearance) },
		{ "BGRes", 						UIBinderSetBrushFromAssetPath.New(self, self.ImgNPCJobBg) },
	}
end

function EntourageNPCMemberItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	
	self.VM = self.Params.Data
	if nil == self.VM then
		return
	end
	
	self:RegisterBinders(self.VM,               self.Binders)
end

function EntourageNPCMemberItemView:OnProfChanged(Prof)
	local PF = ProfUtil.Prof2Func(Prof)
	local BgAssetPath = ""
	if PF == PROF_FUNC_TYPE.FUNCTION_TYPE_ATTACK then
		BgAssetPath = "Texture2D'/Game/UI/Texture/Entourage/UI_Entourage_Img_NPCBg_Red.UI_Entourage_Img_NPCBg_Red'"
	elseif PF == PROF_FUNC_TYPE.FUNCTION_TYPE_GUARD then
		BgAssetPath = "Texture2D'/Game/UI/Texture/Entourage/UI_Entourage_Img_NPCBg_Blue.UI_Entourage_Img_NPCBg_Blue'"
	elseif PF == PROF_FUNC_TYPE.FUNCTION_TYPE_RECOVER then
		BgAssetPath = "Texture2D'/Game/UI/Texture/Entourage/UI_Entourage_Img_NPCBg_Green.UI_Entourage_Img_NPCBg_Green'"
	end

	UIUtil.ImageSetBrushFromAssetPath(self.ImgNPCBg, BgAssetPath)
end

return EntourageNPCMemberItemView