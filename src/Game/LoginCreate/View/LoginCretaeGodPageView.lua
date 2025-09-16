---
--- Author: chriswang
--- DateTime: 2023-10-20 16:24
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TwelveGodCfg = require("TableCfg/TwelveGodCfg")

--@Binder
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

--@ViewModel
local LoginRoleGodVM = require("Game/LoginRole/LoginRoleGodVM")

---@class LoginCretaeGodPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnAlthyk LoginCreateGodItemView
---@field BtnAzeyma LoginCreateGodItemView
---@field BtnByregot LoginCreateGodItemView
---@field BtnHalone LoginCreateGodItemView
---@field BtnLlymlaen LoginCreateGodItemView
---@field BtnMenphina LoginCreateGodItemView
---@field BtnNaldthal LoginCreateGodItemView
---@field BtnNophica LoginCreateGodItemView
---@field BtnNymeia LoginCreateGodItemView
---@field BtnOschon LoginCreateGodItemView
---@field BtnRhalgr LoginCreateGodItemView
---@field BtnThaliak LoginCreateGodItemView
---@field ImgGod UFImage
---@field PanelGodIcon UFCanvasPanel
---@field TextInfo UFTextBlock
---@field TextName UFTextBlock
---@field ToggleBtnAlthyk UToggleButton
---@field ToggleBtnAzeyma UToggleButton
---@field ToggleBtnByregot UToggleButton
---@field ToggleBtnHalone UToggleButton
---@field ToggleBtnLlymlaen UToggleButton
---@field ToggleBtnMenphina UToggleButton
---@field ToggleBtnNaldthal UToggleButton
---@field ToggleBtnNophica UToggleButton
---@field ToggleBtnNymeia UToggleButton
---@field ToggleBtnOschon UToggleButton
---@field ToggleBtnRhalgr UToggleButton
---@field ToggleBtnThaliak UToggleButton
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---@field AnimSwitch UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginCretaeGodPageView = LuaClass(UIView, true)

function LoginCretaeGodPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnAlthyk = nil
	--self.BtnAzeyma = nil
	--self.BtnByregot = nil
	--self.BtnHalone = nil
	--self.BtnLlymlaen = nil
	--self.BtnMenphina = nil
	--self.BtnNaldthal = nil
	--self.BtnNophica = nil
	--self.BtnNymeia = nil
	--self.BtnOschon = nil
	--self.BtnRhalgr = nil
	--self.BtnThaliak = nil
	--self.ImgGod = nil
	--self.PanelGodIcon = nil
	--self.TextInfo = nil
	--self.TextName = nil
	--self.ToggleBtnAlthyk = nil
	--self.ToggleBtnAzeyma = nil
	--self.ToggleBtnByregot = nil
	--self.ToggleBtnHalone = nil
	--self.ToggleBtnLlymlaen = nil
	--self.ToggleBtnMenphina = nil
	--self.ToggleBtnNaldthal = nil
	--self.ToggleBtnNophica = nil
	--self.ToggleBtnNymeia = nil
	--self.ToggleBtnOschon = nil
	--self.ToggleBtnRhalgr = nil
	--self.ToggleBtnThaliak = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--self.AnimSwitch = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginCretaeGodPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnAlthyk)
	self:AddSubView(self.BtnAzeyma)
	self:AddSubView(self.BtnByregot)
	self:AddSubView(self.BtnHalone)
	self:AddSubView(self.BtnLlymlaen)
	self:AddSubView(self.BtnMenphina)
	self:AddSubView(self.BtnNaldthal)
	self:AddSubView(self.BtnNophica)
	self:AddSubView(self.BtnNymeia)
	self:AddSubView(self.BtnOschon)
	self:AddSubView(self.BtnRhalgr)
	self:AddSubView(self.BtnThaliak)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginCretaeGodPageView:OnInit()
	self.GodBtnNames = {"BtnHalone", "BtnMenphina", "BtnThaliak", "BtnNymeia"
						, "BtnLlymlaen", "BtnOschon", "BtnByregot", "BtnRhalgr"
						, "BtnAzeyma", "BtnNaldthal", "BtnNophica", "BtnAlthyk"}

	-- self.Angles = {-90, -60.0, -30.0, 0, 30, }	

	self.ViewModel = LoginRoleGodVM--.New()	方便记录数据，不过得在UIViewModelConfig中配置，否则无法绑定view
end

function LoginCretaeGodPageView:OnDestroy()

end

function LoginCretaeGodPageView:OnShow()
	
	for GodID = 1, 12 do
        local GodCfg = TwelveGodCfg:FindCfgByKey(GodID)
		if GodCfg then
			local GodItem = self[self.GodBtnNames[GodID]]
			UIUtil.ImageSetBrushFromAssetPath(GodItem.ImgGodNormal, GodCfg.GodNormalIcon)
			UIUtil.ImageSetBrushFromAssetPath(GodItem.ImgGodSelect, GodCfg.GodSelectIcon)
			GodItem.SelectPanel:SetRenderTransformAngle(-90 + GodID * 30 - 30)
		end
	end

	--随机一个，选中
	local RandomGodID = self.ViewModel:RandomGod()
	if RandomGodID then
		if self.LastSelectBtnName then
			local LastBtn = self[self.LastSelectBtnName]
			LastBtn.ToggleBtn:SetCheckedState(_G.UE.EToggleButtonState.UnChecked, false)
			UIUtil.SetIsVisible(LastBtn.SelectPanel, false)
			LastBtn:PlayAnimation(LastBtn.AnimUnchecked)
		end
		
		local BtnName = self.GodBtnNames[RandomGodID]
		self.LastSelectBtnName = BtnName
		local Btn = self[BtnName]
		Btn.ToggleBtn:SetCheckedState(_G.UE.EToggleButtonState.Checked , false)
		UIUtil.SetIsVisible(Btn.SelectPanel, true)
		Btn:PlayAnimation(Btn.AnimChecked)

		-- local AnimIdx = 1
		-- if RandomGodID >= 8 then
		-- 	AnimIdx = RandomGodID - 7
		-- else
		-- 	AnimIdx = RandomGodID + 5
		-- end
		-- self:PlayAnimation(self["AnimBtnChecked" .. AnimIdx])
	end
end

function LoginCretaeGodPageView:OnHide()

end

function LoginCretaeGodPageView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnRhalgr.ToggleBtn, self.OnGodBtnClick, {GodID = 8, AnimIdx = 1})
	UIUtil.AddOnClickedEvent(self, self.BtnAzeyma.ToggleBtn, self.OnGodBtnClick, {GodID = 9, AnimIdx = 2})
	UIUtil.AddOnClickedEvent(self, self.BtnNaldthal.ToggleBtn, self.OnGodBtnClick, {GodID = 10, AnimIdx = 3})
	UIUtil.AddOnClickedEvent(self, self.BtnNophica.ToggleBtn, self.OnGodBtnClick, {GodID = 11, AnimIdx = 4})
	UIUtil.AddOnClickedEvent(self, self.BtnAlthyk.ToggleBtn, self.OnGodBtnClick, {GodID = 12, AnimIdx = 5})
	UIUtil.AddOnClickedEvent(self, self.BtnHalone.ToggleBtn, self.OnGodBtnClick, {GodID = 1, AnimIdx = 6})
	UIUtil.AddOnClickedEvent(self, self.BtnMenphina.ToggleBtn, self.OnGodBtnClick, {GodID = 2, AnimIdx = 7})
	UIUtil.AddOnClickedEvent(self, self.BtnThaliak.ToggleBtn, self.OnGodBtnClick, {GodID = 3, AnimIdx = 8})
	UIUtil.AddOnClickedEvent(self, self.BtnNymeia.ToggleBtn, self.OnGodBtnClick, {GodID = 4, AnimIdx = 9})
	UIUtil.AddOnClickedEvent(self, self.BtnLlymlaen.ToggleBtn, self.OnGodBtnClick, {GodID = 5, AnimIdx = 10})
	UIUtil.AddOnClickedEvent(self, self.BtnOschon.ToggleBtn, self.OnGodBtnClick, {GodID = 6, AnimIdx = 11})
	UIUtil.AddOnClickedEvent(self, self.BtnByregot.ToggleBtn, self.OnGodBtnClick, {GodID = 7, AnimIdx = 12})
end

function LoginCretaeGodPageView:OnRegisterGameEvent()

end

function LoginCretaeGodPageView:OnRegisterBinder()
	local Binders = {
		{ "GodName", UIBinderSetText.New(self, self.TextName) },
		{ "GodDesc", UIBinderSetText.New(self, self.TextInfo) },
        {"GodBGLogo", UIBinderSetBrushFromAssetPath.New(self, self.ImgGod)},

	}

	self:RegisterBinders(self.ViewModel, Binders)
end

function LoginCretaeGodPageView:OnGodBtnClick(Params)
	local GodID = Params.GodID
	--描述回滚到顶部
	self.ScrollBox_0:ScrollToStart()

	if self.LastSelectBtnName then
		local LastBtn = self[self.LastSelectBtnName]
		LastBtn.ToggleBtn:SetCheckedState(_G.UE.EToggleButtonState.UnChecked , false)
		UIUtil.SetIsVisible(LastBtn.SelectPanel, false)
		LastBtn:PlayAnimation(LastBtn.AnimUnchecked)
	end
	
	-- local AnimIdx = Params.AnimIdx
	-- self:PlayAnimation(self.AnimBtnUnchecked)
	-- self:PlayAnimation(self["AnimBtnChecked" .. AnimIdx])
	self:PlayAnimation(self.AnimSwitch)

	local BtnName = self.GodBtnNames[GodID]
	self.LastSelectBtnName = BtnName
	local Btn = self[BtnName]
	Btn.ToggleBtn:SetCheckedState(_G.UE.EToggleButtonState.Checked , false)
	UIUtil.SetIsVisible(Btn.SelectPanel, true)
	self.ViewModel:SelectGod(GodID)
	Btn:PlayAnimation(Btn.AnimChecked)
end

return LoginCretaeGodPageView