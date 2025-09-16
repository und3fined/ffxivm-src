local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MailDefine = require("Game/Mail/MailDefine")
local TimeUtil = require("Utils/TimeUtil")
local MailUtil = require("Game/Mail/MailUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")

local BrightTextColor = "d5d5d5FF"
local DarkTextColor = "828282FF"

---@class MailListItemViewVM : UIViewModel
local MailListItemViewVM = LuaClass(UIViewModel)

---Ctor
function MailListItemViewVM:Ctor()
	self.ID = 0
	self.MailType = nil
	self.Readed = false
	self.ShowTitle = ""
	self.ImgIconPath = ""
	self.TimeText = 0
	self.ShowTitleColor = BrightTextColor
	self.IsSelected = false
end

function MailListItemViewVM:OnInit()

end

function MailListItemViewVM:OnBegin()

end

function MailListItemViewVM:IsEqualVM(Value)
	return true
end

function MailListItemViewVM:OnEnd()

end

function MailListItemViewVM:OnShutdown()

end

---UpdateVM
---@param Value table @common.Item
---@param Params table @可以在UIBindableList.New函数传递参数，
function MailListItemViewVM:UpdateVM(Value, Params)
	self.ID = Value.ID
	self.MailType = Value.MailType

	self:RefreshShowTitleColor()

	if _G.MailMainVM.CurrentMailBoxType == MailDefine.MailBoxType.OutBox then
		self:OutBoxShow(Value)
	else
		self:InBoxShow(Value)
	end
end

function MailListItemViewVM:InBoxShow(Value)
	if #(Value.Attachment) > 0 then
		if Value.Attach then
			self.ImgIconPath = MailDefine.ExistAttachIcon
		else
			self.ImgIconPath = MailDefine.NoExistAttachIcon
		end
	else
		if Value.Readed then
			self.ImgIconPath = MailDefine.ReadIcon
		else
			self.ImgIconPath = MailDefine.UnReadIcon
		end
	end
	local Time = TimeUtil.GetServerTime() - Value.SendTime
	Time = Time > 60 and Time or 60
	self.TimeText = LocalizationUtil.GetTimerForLowPrecision(Time, 1000)
	if Value.MailType == MailDefine.MailType.Gift then
		self.ShowTitle = MailUtil.GetMailSenderName(Value.SenderID)
	else
		self.ShowTitle = Value.Title or ""
	end
end

function MailListItemViewVM:OutBoxShow(Value)
	self.ImgIconPath = MailDefine.OutBoxMailIcon
	self.ShowTitle = MailUtil.GetMailSenderName(Value.ReceiverID)
	local Time = TimeUtil.GetServerTime() - Value.SendTime
	Time = Time > 60 and Time or 60
	self.TimeText = LocalizationUtil.GetTimerForLowPrecision(Time, 1000)
end

function MailListItemViewVM:RefreshShowTitleColor()
	if self.IsSelected then
		self.ShowTitleColor = BrightTextColor
		return
	end
	local CurrentMailBoxType = _G.MailMainVM.CurrentMailBoxType
	if CurrentMailBoxType == MailDefine.MailBoxType.InBox then
		local MailData = _G.MailMgr:GetMailData(self.ID, self.MailType, CurrentMailBoxType)
		if MailData == nil then
			self.ShowTitleColor = BrightTextColor
			return 
		end
		if #(MailData.Attachment) > 0 then
			self.ShowTitleColor =  MailData.Attach and BrightTextColor or DarkTextColor
		else
			self.ShowTitleColor =  MailData.Readed and DarkTextColor or BrightTextColor
		end 
	else
		self.ShowTitleColor = BrightTextColor 
	end
end

return MailListItemViewVM