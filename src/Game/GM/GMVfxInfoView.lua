---
--- Author: kanohchen
--- DateTime: 2025-03-12 17:06
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class GMVfxInfoView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Content URichTextBox
---@field FButton UFButton
---@field FButton_1 UFButton
---@field FButton_2 UFButton
---@field FButton_3 UFButton
---@field TextBlock_1 UTextBlock
---@field TextBlock_2 UTextBlock
---@field TextBlock_3 UTextBlock
---@field TextBlock_99 UTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GMVfxInfoView = LuaClass(UIView, true)

function GMVfxInfoView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Content = nil
	--self.FButton = nil
	--self.FButton_1 = nil
	--self.FButton_2 = nil
	--self.FButton_3 = nil
	--self.TextBlock_1 = nil
	--self.TextBlock_2 = nil
	--self.TextBlock_3 = nil
	--self.TextBlock_99 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GMVfxInfoView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GMVfxInfoView:OnInit()
	self.VfxEffectPaths = {}
	self.VfxEffectCounts = {}
	self.CurrentPage = 1
	self.MaxPage = 1
end

function GMVfxInfoView:OnDestroy()

end

function GMVfxInfoView:OnShow()
	self.TextBlock_99:SetText(_G.LSTR(1440021))
	self.TextBlock_1:SetText(_G.LSTR(1440033))
	self.TextBlock_2:SetText(_G.LSTR(1440034))
	self.TextBlock_3:SetText(_G.LSTR(1440035))
	self:UpdateVfxInfo()
end

function GMVfxInfoView:OnHide()

end

function GMVfxInfoView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.FButton, self.OnCloseBtnClick)
	UIUtil.AddOnClickedEvent(self, self.FButton_1, self.OnNextPageBtnClick,false)
	UIUtil.AddOnClickedEvent(self, self.FButton_2, self.OnNextPageBtnClick,true)
	UIUtil.AddOnClickedEvent(self, self.FButton_3, self.OnUpdateInfoBtnClick)
end

function GMVfxInfoView:OnRegisterGameEvent()

end

function GMVfxInfoView:OnRegisterBinder()

end

function GMVfxInfoView:OnNextPageBtnClick(Params)
	if Params then
		if self.CurrentPage + 1 <= self.MaxPage then
			self.CurrentPage = self.CurrentPage + 1
		else
			self.CurrentPage = 1
		end
	else
		if self.CurrentPage - 1 >= 1 then
			self.CurrentPage = self.CurrentPage - 1
		else
			self.CurrentPage = self.MaxPage
		end
	end
	self:ShowVfxInfo()
end

function GMVfxInfoView:OnUpdateInfoBtnClick()
	self:UpdateVfxInfo()
end

function GMVfxInfoView:OnCloseBtnClick()
	_G.UIViewMgr:HideView(_G.UIViewID.GMVfxInfo)
end

function GMVfxInfoView:ShowVfxInfo()
	if(self.CurrentPage > self.MaxPage or self.CurrentPage < 1) then
		self.CurrentPage = 1
	end
	local CurrentPos = (self.CurrentPage - 1) * 18 + 1
	local Text = ""
	for _, value in ipairs(self.VfxEffectCounts) do
		local VfxEffectPathText = string.format("<span color=\"#a8a800ff\" size=\"20\">%s</>", value)
		Text = Text ..VfxEffectPathText.."\n"
	end
	for i = CurrentPos, CurrentPos + 17 do
		if i > #self.VfxEffectPaths then
			break
		end
		local VfxEffectPathText = string.format("<span color=\"#72b8fdff\" size=\"15\">%d. %s</>", 
		i, self.VfxEffectPaths[i])
		Text = Text ..VfxEffectPathText.."\n"
	end
	self.Content:SetText(Text)
end
function GMVfxInfoView:UpdateVfxInfo()
	self.Content:SetText("")
	self.CurrentPage = 1
	self.MaxPage = 1
	self.VfxEffectPaths = {}
	self.VfxEffectCounts = {}
	local VfxEffectData = _G.EffectUtil.GetVfxInfoDebug()
	if VfxEffectData then
		for index = 1, VfxEffectData:Num() do
			if index <= 3 then
				self.VfxEffectCounts[index] = VfxEffectData[index]
				FLOG_INFO("GMVfxInfo: %s",VfxEffectData[index])
			else
				self.VfxEffectPaths[index - 3] = VfxEffectData[index]
				FLOG_INFO("GMVfxInfo: %d. %s",index - 3,VfxEffectData[index])
			end
		end
		self.MaxPage = math.ceil(#self.VfxEffectPaths/18)
		self:ShowVfxInfo()
	end
end

return GMVfxInfoView