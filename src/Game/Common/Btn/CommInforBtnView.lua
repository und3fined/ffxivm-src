---
--- Author: stellahxhu
--- DateTime: 2022-07-28 15:26
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local HelpInfoUtil = require("Utils/HelpInfoUtil")
local TipsUtil = require("Utils/TipsUtil")
local TipsItemVM = require("Game/Common/Tips/VM/TipsItemVM")
local TipsVM = require("Game/Common/Tips/VM/TipsVM")

local GroupMemberCategoryCfg = require("TableCfg/GroupMemberCategoryCfg")

---@class CommInforBtnView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnInfor UFButton
---@field Imgnfor UFImage
---@field HelpInfoID int
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommInforBtnView = LuaClass(UIView, true)

function CommInforBtnView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnInfor = nil
	--self.Imgnfor = nil
	--self.HelpInfoID = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY

	self.View = nil
	self.Callback = nil
	self.CheckClickedCallback = nil
	self.Args = {}
end

function CommInforBtnView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommInforBtnView:OnInit()
end

function CommInforBtnView:OnDestroy()
end

function CommInforBtnView:OnShow()
	if self.HelpInfoID == -1 then
		self:SetButtonStyle(self.Type or HelpInfoUtil.HelpInfoType.Normal)
		return
	else
		if self.HelpInfoID >= HelpInfoUtil.GroupStartID then
			self:SetButtonStyle(self.Type or  HelpInfoUtil.HelpInfoType.Normal)
			return
		end
		local Type = HelpInfoUtil.GetHelpType(self.HelpInfoID)
		self:SetButtonStyle(Type)
	end
end

function CommInforBtnView:OnHide()
end

function CommInforBtnView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnInfor, self.OnClickBtnInfor)
end

function CommInforBtnView:OnRegisterGameEvent()
end

function CommInforBtnView:OnRegisterBinder()

end

function CommInforBtnView:SetButtonStyle(Type)
	self.Type = Type
	if Type == HelpInfoUtil.HelpInfoType.Normal then
		UIUtil.ImageSetBrushFromAssetPath(self.Imgnfor, "PaperSprite'/Game/UI/Atlas/Button/Frames/UI_Comm_Btn_Help_png.UI_Comm_Btn_Help_png'")
	elseif Type == HelpInfoUtil.HelpInfoType.Large or Type == HelpInfoUtil.HelpInfoType.Mid then
		UIUtil.ImageSetBrushFromAssetPath(self.Imgnfor, "PaperSprite'/Game/UI/Atlas/Button/Frames/UI_Comm_Btn_Help_png.UI_Comm_Btn_Help_png'")
	elseif Type  == HelpInfoUtil.HelpInfoType.NewTips then
		UIUtil.ImageSetBrushFromAssetPath(self.Imgnfor, "Texture2D'/Game/UI/Texture/Button/UI_Comm_Btn_InforS.UI_Comm_Btn_InforS'")
	elseif Type  == HelpInfoUtil.HelpInfoType.NewTipsBright  then
		UIUtil.ImageSetBrushFromAssetPath(self.Imgnfor, "Texture2D'/Game/UI/Texture/Button/UI_Btn_Info_Bright.UI_Btn_Info_Bright'")
	else
		UIUtil.ImageSetBrushFromAssetPath(self.Imgnfor, "PaperSprite'/Game/UI/Atlas/Button/Frames/UI_Comm_Btn_Infor_png.UI_Comm_Btn_Infor_png'")
	end
end

function CommInforBtnView:OnClickBtnInfor()
	if nil ~= self.Callback then
		self.Callback(self.View)
	else
		if self.HelpInfoID == -1 then
			return
		end

		HelpInfoUtil.ShowHelpInfo(self, nil, table.unpack(self.Args))
	end
	---用于数据埋点上传
	if self.CheckClickedCallback then
		self.CheckClickedCallback(self.View)
	end
end

function CommInforBtnView:SetArgs(...)
	self.Args = {...}
end

function CommInforBtnView:SetCallback(View, Callback)
	self.View = View
	self.Callback = Callback
end

function CommInforBtnView:SetHelpInfoID(ID)
	self.HelpInfoID = ID
	self:OnShow()
end

function CommInforBtnView:SetCheckClickedCallback(View, CheckClickedCallback)
	self.View = View
	self.CheckClickedCallback = CheckClickedCallback
end

return CommInforBtnView