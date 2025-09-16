---
--- Author: xingcaicao
--- DateTime: 2024-11-27 20:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local LSTR = _G.LSTR

---@class ChatArmyPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGoTo CommBtnMView
---@field ImgArmyManifesto UFImage
---@field TextJoinArmy UFTextBlock
---@field TextJoinDesc UFTextBlock
---@field TextOrganize URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChatArmyPanelView = LuaClass(UIView, true)

function ChatArmyPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGoTo = nil
	--self.ImgArmyManifesto = nil
	--self.TextJoinArmy = nil
	--self.TextJoinDesc = nil
	--self.TextOrganize = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChatArmyPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnGoTo)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChatArmyPanelView:OnInit()
	self.IsInitConstText = false 
end

function ChatArmyPanelView:OnDestroy()

end

function ChatArmyPanelView:OnShow()
	self:InitConstText()
end

function ChatArmyPanelView:OnHide()

end

function ChatArmyPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGoTo, self.OnClickButtonGoTo)
end

function ChatArmyPanelView:OnRegisterGameEvent()

end

function ChatArmyPanelView:OnRegisterBinder()

end

function ChatArmyPanelView:InitConstText()
	if self.IsInitConstText then
		return
	end

	self.IsInitConstText = true

	self.TextJoinArmy:SetText(LSTR(50095)) -- 10095("加入部队")
	self.TextJoinDesc:SetText(LSTR(50096)) -- 10096("与部队的小伙伴们共同奋战")
	self.TextOrganize:SetText(LSTR(50153)) 

	self.BtnGoTo:SetButtonText(LSTR(50095))

	-- 宣传图
	local Img = self.ImgArmyManifesto
	if not UIUtil.IsVisible(Img) then
		local ArmyManifestoImg ="Texture2D'/Game/UI/Texture/ChatNew/UI_Chat_Img_ArmyBanner.UI_Chat_Img_ArmyBanner'"
		if UIUtil.ImageSetBrushFromAssetPath(Img, ArmyManifestoImg) then
			UIUtil.SetIsVisible(Img, true)
		end
	end
end

function ChatArmyPanelView:OnClickButtonGoTo()
	if _G.ArmyMgr:OpenArmyMainPanel() then
		---跳转后需要隐藏
		_G.UIViewMgr:HideView(_G.UIViewID.ChatMainPanel)
	end	
end

return ChatArmyPanelView