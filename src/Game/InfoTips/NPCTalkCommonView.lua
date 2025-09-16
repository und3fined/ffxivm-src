--[[
Author: your name
Date: 2021-08-16 14:31:25
LastEditTime: 2021-08-20 14:47:26
LastEditors: your name
Description: In User Settings Edit
FilePath: \Script\Game\InfoTips\NPCTalkCommonView.lua
--]]
--[[
Author: your name
Date: 2021-08-16 14:31:25
LastEditTime: 2021-08-16 17:17:26
LastEditors: your name
Description: In User Settings Edit
FilePath: \Script\Game\InfoTips\NPCTalkCommonView.lua
--]]
--[[
Author: your name
Date: 2021-08-16 14:31:25
LastEditTime: 2021-08-16 16:17:46
LastEditors: your name
Description: In User Settings Edit
FilePath: \Script\Game\InfoTips\NPCTalkCommonView.lua
--]]
---
--- Author: chunfengluo
--- DateTime: 2021-08-16 14:31
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class NPCTalkCommonView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGPS UButton
---@field Img_Bg UImage
---@field Img_Gps UImage
---@field Img_NPCBanner UImage
---@field Text_NPCName UTextBlock
---@field Text_Talk UTextBlock
---@field Anim_Aoto_In UWidgetAnimation
---@field Anim_Aoto_Out UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NPCTalkCommonView = LuaClass(UIView, true)

function NPCTalkCommonView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	self.BtnGPS = nil
	self.Img_Bg = nil
	self.Img_Gps = nil
	self.Img_NPCBanner = nil
	self.Text_NPCName = nil
	self.Text_Talk = nil
	self.Anim_Aoto_In = nil
	self.Anim_Aoto_Out = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NPCTalkCommonView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NPCTalkCommonView:OnInit()

end

function NPCTalkCommonView:OnDestroy()

end

function NPCTalkCommonView:OnShow()
	self.Super:OnShow()
	self.Text_NPCName:SetText(self.Params.NpcName)
	self.Text_Talk:SetText(self.Params.Talk)
end

function NPCTalkCommonView:OnHide()

end

function NPCTalkCommonView:OnRegisterUIEvent()

end

function NPCTalkCommonView:OnRegisterGameEvent()

end

function NPCTalkCommonView:OnRegisterTimer()

end

function NPCTalkCommonView:OnRegisterBinder()

end

return NPCTalkCommonView