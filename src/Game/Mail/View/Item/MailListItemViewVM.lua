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
	self.IsGreetingCard = false
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
	local IsOutBox = _G.MailMainVM.CurrentMailBoxType == MailDefine.MailBoxType.OutBox
	self.ID = Value.ID
	self.MailType = IsOutBox and MailUtil.GetInBoxID(Value.MailType) or Value.MailType
	self.IsGreetingCard = Value.GreetingCardData ~= nil
	self:RefreshShowTitleColor(Value)
	self:RefreshShowImgIcon(Value)

	if IsOutBox then
		self:OutBoxShow(Value)
	else
		self:InBoxShow(Value)
	end
end

function MailListItemViewVM:InBoxShow(Value)
	local Time = TimeUtil.GetServerTime() - Value.SendTime
	Time = Time > 60 and Time or 60
	self.TimeText = LocalizationUtil.GetTimerForLowPrecision(Time, 1000)
	if self.MailType == MailDefine.MailType.Gift then
		self.ShowTitle = MailUtil.GetMailSenderName(Value.SenderID)
		if self.IsGreetingCard then
			self.ShowTitle = self.ShowTitle .. _G.LSTR(740023)
		end
	else
		self.ShowTitle = Value.Title or ""
	end
end

function MailListItemViewVM:OutBoxShow(Value)
	self.ShowTitle = MailUtil.GetMailSenderName(Value.ReceiverID)
	local Time = TimeUtil.GetServerTime() - Value.SendTime
	Time = Time > 60 and Time or 60
	self.TimeText = LocalizationUtil.GetTimerForLowPrecision(Time, 1000)
end

function MailListItemViewVM:RefreshShowTitleColor(MailData)
	if self.IsSelected then
		self.ShowTitleColor = BrightTextColor
		return
	end
	local CurrentMailBoxType = _G.MailMainVM.CurrentMailBoxType
	if MailData == nil then
		MailData = _G.MailMgr:GetMailData(self.ID, self.MailType, CurrentMailBoxType)
	end
	
	if CurrentMailBoxType == MailDefine.MailBoxType.InBox then
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

function MailListItemViewVM:RefreshShowImgIcon(MailData)
	local CurrentMailBoxType = _G.MailMainVM.CurrentMailBoxType
	if MailData == nil then
		MailData = _G.MailMgr:GetMailData(self.ID, self.MailType, CurrentMailBoxType)
	end
	if CurrentMailBoxType == MailDefine.MailBoxType.InBox then
		if MailData == nil then
			return 
		end
		if #(MailData.Attachment) > 0 then
			if MailData.Attach then
				self.ImgIconPath = MailDefine.ExistAttachIcon
			else
				self.ImgIconPath = self.IsSelected and MailDefine.NoExistAttachSelectIcon or MailDefine.NoExistAttachIcon
			end
		else
			if MailData.Readed then
				if self.IsGreetingCard then
					self.ImgIconPath = self.IsSelected and MailDefine.GreetingCardSelectIcon or MailDefine.GreetingCardReadIcon
				else
					self.ImgIconPath = self.IsSelected and MailDefine.ReadedSelectIcon or MailDefine.ReadIcon
				end
			else
				self.ImgIconPath = self.IsGreetingCard and MailDefine.GreetingCardUnReadIcon or MailDefine.UnReadIcon
			end
		end
	else
		if self.IsGreetingCard then
			self.ImgIconPath = MailDefine.OutBoxGreetingCardMailIcon
		else
			self.ImgIconPath = MailDefine.OutBoxMailIcon
		end
	end
end

return MailListItemViewVM