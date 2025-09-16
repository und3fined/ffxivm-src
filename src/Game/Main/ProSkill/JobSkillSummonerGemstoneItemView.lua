---
--- Author: chaooren
--- DateTime: 2023-03-31 14:22
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderUpdateCountDown = require("Binder/UIBinderUpdateCountDown")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetRenderOpacity = require("Binder/UIBinderSetRenderOpacity")
local UIBinderSetAnimPlayPercentage = require("Binder/UIBinderSetAnimPlayPercentage")

local UIAdapterCountDown = require("UI/Adapter/UIAdapterCountDown")

---@class JobSkillSummonerGemstoneItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CountDownTime UFTextBlock
---@field EFF_Loop_T_ADD_Inst_6 UFImage
---@field EFF_Loop_T_ADD_Inst_7 UFImage
---@field EFF_Loop_T_ADD_Inst_8 UFImage
---@field Gemstone1 UFCanvasPanel
---@field Gemstone2 UFCanvasPanel
---@field Gemstone3 UFCanvasPanel
---@field ImgChain UFImage
---@field ImgChain2 UFImage
---@field ImgChain3 UFImage
---@field ImgGemstone1 UFImage
---@field ImgGemstone2 UFImage
---@field ImgGemstone3 UFImage
---@field TextTime1_2 UFTextBlock
---@field TextTime1_3 UFTextBlock
---@field TextTime1_4 UFTextBlock
---@field Anim1BigHidden UWidgetAnimation
---@field Anim1BigShow UWidgetAnimation
---@field Anim1Dark UWidgetAnimation
---@field Anim1Light UWidgetAnimation
---@field Anim2BigHidden UWidgetAnimation
---@field Anim2BigShow UWidgetAnimation
---@field Anim2Dark UWidgetAnimation
---@field Anim2Light UWidgetAnimation
---@field Anim3BigHidden UWidgetAnimation
---@field Anim3BigShow UWidgetAnimation
---@field Anim3Dark UWidgetAnimation
---@field Anim3Light UWidgetAnimation
---@field AnimState1 UWidgetAnimation
---@field AnimState2 UWidgetAnimation
---@field AnimState3 UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JobSkillSummonerGemstoneItemView = LuaClass(UIView, true)

local function TimeUpdateCallback(_, Time)
	return math.floor(Time)
end

function JobSkillSummonerGemstoneItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CountDownTime = nil
	--self.EFF_Loop_T_ADD_Inst_6 = nil
	--self.EFF_Loop_T_ADD_Inst_7 = nil
	--self.EFF_Loop_T_ADD_Inst_8 = nil
	--self.Gemstone1 = nil
	--self.Gemstone2 = nil
	--self.Gemstone3 = nil
	--self.ImgChain = nil
	--self.ImgChain2 = nil
	--self.ImgChain3 = nil
	--self.ImgGemstone1 = nil
	--self.ImgGemstone2 = nil
	--self.ImgGemstone3 = nil
	--self.TextTime1_2 = nil
	--self.TextTime1_3 = nil
	--self.TextTime1_4 = nil
	--self.Anim1BigHidden = nil
	--self.Anim1BigShow = nil
	--self.Anim1Dark = nil
	--self.Anim1Light = nil
	--self.Anim2BigHidden = nil
	--self.Anim2BigShow = nil
	--self.Anim2Dark = nil
	--self.Anim2Light = nil
	--self.Anim3BigHidden = nil
	--self.Anim3BigShow = nil
	--self.Anim3Dark = nil
	--self.Anim3Light = nil
	--self.AnimState1 = nil
	--self.AnimState2 = nil
	--self.AnimState3 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JobSkillSummonerGemstoneItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JobSkillSummonerGemstoneItemView:OnInit()
	self.AdapterCountDownTime = UIAdapterCountDown.CreateAdapter(self, self.CountDownTime, nil, "%d", nil, TimeUpdateCallback)
	self.SummonerVM = nil
	self.Binders = {
		{ "BuffCDTime", UIBinderUpdateCountDown.New(self, self.AdapterCountDownTime, 0.2, true, true) },
		{ "BuffCDVisible", UIBinderSetIsVisible.New(self, self.CountDownTime) },
		{ "AnimState1", UIBinderSetAnimPlayPercentage.New(self, self.Object, self.AnimState1, true)},
		{ "AnimState2", UIBinderSetAnimPlayPercentage.New(self, self.Object, self.AnimState2, true)},
		{ "AnimState3", UIBinderSetAnimPlayPercentage.New(self, self.Object, self.AnimState3, true)},
	}

	for i = 2, 4 do
		local Index = i - 1
		local BindWidget = self[string.format("TextTime1_%d", i)]
		table.insert(self.Binders, { string.format("GemPile%d", Index), UIBinderSetText.New(self, BindWidget)})

		local LightAnim = self[string.format("Anim%dLight", Index)]
		table.insert(self.Binders, { string.format("LightAnim%d", Index), UIBinderSetAnimPlayPercentage.New(self, self.Object, LightAnim, true) })

		local DarkAnim = self[string.format("Anim%dDark", Index)]
		table.insert(self.Binders, { string.format("DarkAnim%d", Index), UIBinderSetAnimPlayPercentage.New(self, self.Object, DarkAnim, true) })

		local BigShowAnim = self[string.format("Anim%dBigShow", Index)]
		table.insert(self.Binders, { string.format("BigShowAnim%d", Index), UIBinderSetAnimPlayPercentage.New(self, self.Object, BigShowAnim, true) })

		local BigHiddenAnim = self[string.format("Anim%dBigHidden", Index)]
		table.insert(self.Binders, { string.format("BigHiddenAnim%d", Index), UIBinderSetAnimPlayPercentage.New(self, self.Object, BigHiddenAnim, true) })

		local GemStoneCanvas = self[string.format("Gemstone%d", Index)]
		table.insert(self.Binders, { string.format("GemstoneCanvas%d", Index), UIBinderSetIsVisible.New(self, GemStoneCanvas) })
		
	end
end

function JobSkillSummonerGemstoneItemView:OnDestroy()

end

function JobSkillSummonerGemstoneItemView:OnShow()
	-- for i = 1, 3 do
	-- 	self:PlayAnimation(self[string.format("Anim%dDark", i)])
	-- end
end

function JobSkillSummonerGemstoneItemView:OnHide()
end

function JobSkillSummonerGemstoneItemView:OnRegisterUIEvent()

end

function JobSkillSummonerGemstoneItemView:OnRegisterGameEvent()

end

function JobSkillSummonerGemstoneItemView:OnRegisterBinder()
	local SummonerVM = self.SummonerVM
	if SummonerVM then
		self:RegisterBinders(SummonerVM, self.Binders)
	end
end

function JobSkillSummonerGemstoneItemView:SetVM(VM)
	self.SummonerVM = VM
end

return JobSkillSummonerGemstoneItemView