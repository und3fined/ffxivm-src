--
-- Author: anypkvcai
-- Date: 2020-12-11 15:39:34
-- Description:
--

local LuaClass = require("Core/LuaClass")
local InfoTipsBaseView = require("Game/InfoTips/InfoTipsBaseView")
local UIUtil = require("Utils/UIUtil")
local MsgTipsID = require("Define/MsgTipsID")
local MissionTipsView = LuaClass(InfoTipsBaseView, true)
local LSTR = _G.LSTR

function MissionTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FImg_Symbol = nil
	--self.Text_Fail = nil
	--self.Text_Title = nil
	--self.Text_Upgrade = nil
	--self.AnimFail = nil
	--self.AnimMission = nil
	--self.AnimUpgrade = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MissionTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MissionTipsView:OnInit()

end

function MissionTipsView:OnDestroy()

end

function MissionTipsView:OnShow()
	self.Super:OnShow()

	-- 判断使命类型
	if ((self.Params.ID >= 10000) and (self.Params.ID <= 10003)) or (self.Params.ID == 10021) then
		local TitleText = ""
		if self.Params.ID == 10000 then
			TitleText = LSTR("使命开始")
		elseif self.Params.ID == 10001 then
			TitleText = LSTR("使命完成")
		elseif (self.Params.ID == 10002) or (self.Params.ID == 10003) or (self.Params.ID == 10021) then
			TitleText = self.Params.Content
		end
		self.Text_Title:SetText(TitleText)

		if self.FImg_Symbol then
			local bSymbolInvisible = self.Params.bSymbolInvisible
			UIUtil.SetIsVisible(self.FImg_Symbol, not bSymbolInvisible)
		end

		if self.AnimMission ~= nil then
			self:PlayAnimation(self.AnimMission)
		end
	elseif self.Params.ID == MsgTipsID.JumboLottoryTip 
			or self.Params.ID == MsgTipsID.TouringBandListenCountAdd 
			or self.Params.ID == MsgTipsID.TouringBandStoryUnLock then
		local TitleText = self.Params.Content
		self.Text_Title:SetText(TitleText)
		if self.FImg_Symbol then
			local bSymbolInvisible = self.Params.bSymbolInvisible
			UIUtil.SetIsVisible(self.FImg_Symbol, not bSymbolInvisible)
		end
		self:PlayAnimation(self.AnimMission)
	else
		local RichText = '<span color="#FFFFFFFF" outline="2;#52514eB3" size="84">'
		RichText = RichText .. self.Params.Content
		RichText = RichText .. '</><span color="#FFFFFFFF" outline="2;#52514eB3" size="62">······</>'
		self.Text_Fail:SetText(RichText)
		if self.AnimFail ~= nil then
			self:PlayAnimation(self.AnimFail)
		end
	end

end

function MissionTipsView:OnHide()
	if (self.Params.Callback ~= nil) then
		self.Params.Callback()
	end
end

function MissionTipsView:OnRegisterUIEvent()

end

function MissionTipsView:OnRegisterGameEvent()

end

function MissionTipsView:OnRegisterTimer()
	self.Super:OnRegisterTimer()
end

function MissionTipsView:OnRegisterBinder()

end

return MissionTipsView