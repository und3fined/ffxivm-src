---
--- Author: Administrator
--- DateTime: 2024-03-07 10:42
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local PhotoMediaUtil = require("Game/Photo/Util/PhotoMediaUtil")
local PhotoDefine = require("Game/Photo/PhotoDefine")

local TempNameMaxLen = 10

---@class PhotoAddTemplateWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCancel CommBtnLView
---@field BtnEdit UFButton
---@field BtnYes CommBtnLView
---@field Comm2FrameM_UIBP Comm2FrameMView
---@field ImgPic UFImage
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PhotoAddTemplateWinView = LuaClass(UIView, true)

function PhotoAddTemplateWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCancel = nil
	--self.BtnEdit = nil
	--self.BtnYes = nil
	--self.Comm2FrameM_UIBP = nil
	--self.ImgPic = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PhotoAddTemplateWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnYes)
	self:AddSubView(self.Comm2FrameM_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PhotoAddTemplateWinView:OnInit()
	self.Comm2FrameM_UIBP.FText_Title:SetText(_G.LSTR(630037))

	self.BtnYes:SetText(_G.LSTR(10002))
	self.BtnCancel:SetText(_G.LSTR(10003))
	-- self.TextName:SetMaxNum(TempNameMaxLen)
end

function PhotoAddTemplateWinView:OnDestroy()

end
function PhotoAddTemplateWinView:OnShow()
	local List = _G.PhotoMgr.CustTemplateList or {}
	local CustCnt = #List
	local Name = _G.LSTR(630025) .. tostring(CustCnt + 1)

	PhotoMediaUtil.TakePictureAndSetImage(self.ImgPic)
	-- self.TextName:SetText(Name)
	self.TextName:SetHintText(Name)
end

function PhotoAddTemplateWinView:OnHide()

end

function PhotoAddTemplateWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self,              self.BtnYes,    			self.OnBtnYes)
	UIUtil.AddOnClickedEvent(self,              self.BtnCancel,    			self.OnBtnCancel)
	UIUtil.AddOnClickedEvent(self,              self.BtnEdit,    			self.OnBtnEdit)
	UIUtil.AddOnTextChangedEvent(self, 			self.TextName, 				self.OnTextChange)
	UIUtil.AddOnTextCommittedEvent(self, 		self.TextName, 				self.OnTextCommit)
end

function PhotoAddTemplateWinView:OnRegisterGameEvent()

end

function PhotoAddTemplateWinView:OnRegisterBinder()

end

function PhotoAddTemplateWinView:OnBtnYes()
	local Name = self.TextName:GetText()
	if string.isnilorempty(Name) then
		Name = self.TextName.HintText or ""
	end
	local Icon = _G.UE.UMediaUtil.GetWidgetScreenshotImageData(self.ImgPic, PhotoDefine.TemplateShutImageSize, 100, false)
	_G.PhotoMgr:AddCustTemplate(Name, Icon)
	self:Hide()
end

function PhotoAddTemplateWinView:OnBtnCancel()
	self:Hide()
end

function PhotoAddTemplateWinView:OnBtnEdit()
	-- print('Andre OnBtnEdit')
end

local LIMIT_TIPS_INTERVAL = 3
local MAX_NUM = 12
function PhotoAddTemplateWinView:CheckTextOverLimit(Text, IsShowTips)
	-- Text = Text or self:GetText()
	if not Text then
		return
	end

	local CurLen = CommonUtil.GetStrLen(Text)
	if CurLen > MAX_NUM then
		if IsShowTips then
			local CurTime = os.time() 
			local LastTime = self.LastOverLimitTipsTime or 0
			if CurTime - LastTime > LIMIT_TIPS_INTERVAL then
				self.LastOverLimitTipsTime = CurTime
				MsgTipsUtil.ShowErrorTips(LSTR(10045)) -- "超出字数限制"
			end
		end
		return false
	end

	return true
end

-- function PhotoAddTemplateWinView:CheckText(Text)
-- 	local Temp = CommonUtil.RemoveSpecialChars(Text)
-- 	local Ret, Num = string.gsub(Text, "[\n\r\t]", "")

-- end

function PhotoAddTemplateWinView:OnTextCommit(_, Text)
	-- print('Andre Text = ' .. tostring(Text))
	self:CheckTextOverLimit(Text, true)
		Text = string.gsub(Text, "[\n\r\t]", "")
		Text = CommonUtil.SubStr(Text, 1, MAX_NUM)
		self.TextName:SetText(Text)
end

function PhotoAddTemplateWinView:OnTextChange(_, Text)
	-- print('Andre Text = ' .. tostring(Text))
	self:CheckTextOverLimit(Text, true)
		Text = string.gsub(Text, "[\n\r\t]", "")
		Text = CommonUtil.SubStr(Text, 1, MAX_NUM)
		self.TextName:SetText(Text)
end

return PhotoAddTemplateWinView