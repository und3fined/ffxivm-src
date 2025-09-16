--
-- Author: anypkvcai
-- Date: 2020-11-23 10:09:25
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIView = require("UI/UIView")
local UIUtil = require("Utils/UIUtil")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")

local MainTeamMemuItemView = LuaClass(UIView, true)

--AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
--AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
function MainTeamMemuItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ButtonItem = nil
	--self.ImageLine = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainTeamMemuItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainTeamMemuItemView:OnInit()

end

function MainTeamMemuItemView:OnDestroy()

end

function MainTeamMemuItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Data = Params.Data
	if nil == Data then
		return
	end
	--self.TextItem:SetText(self.Params.Data.Name)

	self.TextMenu:SetText(Data.Name)
	--self.Comm_Btn_3rd_Recom:SetButtonText(Data.Name)

	UIUtil.SetIsVisible(self.ImgCutline, Data.ShowLine)
end

function MainTeamMemuItemView:OnHide()

end

function MainTeamMemuItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnItem, self.OnClickButtonItem)
end

function MainTeamMemuItemView:OnRegisterGameEvent()

end

function MainTeamMemuItemView:OnRegisterTimer()

end

function MainTeamMemuItemView:OnRegisterBinder()

end

function MainTeamMemuItemView:OnClickButtonItem()
	self.Params.Data.Callback(self.Params.Data.Object)

	UIViewMgr:HideView(UIViewID.TeamMenu)
end

return MainTeamMemuItemView