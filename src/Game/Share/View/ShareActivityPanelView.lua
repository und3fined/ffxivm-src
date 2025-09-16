--[[
Author: jususchen jususchen@tencent.com
Date: 2024-12-12 20:11:21
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-12-13 17:00:28
FilePath: \Script\Game\Share\View\ShareActivityPanelView.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local ProfUtil = require("Game/Profession/ProfUtil")

---@class ShareActivityPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommPlayerHeadSlot_UIBP CommPlayerHeadSlotView
---@field IconJob UFImage
---@field ImgBG UFImage
---@field ImgLogo UFImage
---@field ImgQRCode UFImage
---@field ShareActivityTitleLeft1 ShareActivityTitleLeftItemView
---@field ShareActivityTitleLeft2 ShareActivityTitleLeftItemView
---@field ShareActivityTitleRight ShareActivityTitleRightItemView
---@field ShareActivityTitleRight1 ShareActivityTitleRightItemView
---@field TextLevel UFTextBlock
---@field TextName UFTextBlock
---@field TextPlatform UFTextBlock
---@field TextWatermarkID UFTextBlock
---@field VBOX_Role UFVerticalBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ShareActivityPanelView = LuaClass(UIView, true)

function ShareActivityPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommPlayerHeadSlot_UIBP = nil
	--self.IconJob = nil
	--self.ImgBG = nil
	--self.ImgLogo = nil
	--self.ImgQRCode = nil
	--self.ShareActivityTitleLeft1 = nil
	--self.ShareActivityTitleLeft2 = nil
	--self.ShareActivityTitleRight = nil
	--self.ShareActivityTitleRight1 = nil
	--self.TextLevel = nil
	--self.TextName = nil
	--self.TextPlatform = nil
	--self.TextWatermarkID = nil
	--self.VBOX_Role = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ShareActivityPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommPlayerHeadSlot_UIBP)
	self:AddSubView(self.ShareActivityTitleLeft1)
	self:AddSubView(self.ShareActivityTitleLeft2)
	self:AddSubView(self.ShareActivityTitleRight)
	self:AddSubView(self.ShareActivityTitleRight1)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ShareActivityPanelView:OnInit()
	self:UpdateLogo()
	self.bDestoryed = false
	self.bDestroying = false
end

function ShareActivityPanelView:OnShow()
	local Callback = function(View)
	end
	self:Update(Callback, self, true)
end

function ShareActivityPanelView:OnHide()
	local ImageDownloader = self.ImageDownloader
	if ImageDownloader and ImageDownloader:IsValid() then
		ImageDownloader:Stop()
	end
end

function ShareActivityPanelView:DestroyView(Params)
	self.bDestroying = true
	self.Super.DestroyView(self, Params)
end

function ShareActivityPanelView:OnDestroy()
	self.bDestoryed = true
	self:ResetResourceRef()
end

function ShareActivityPanelView:PickActivityPanel(Index)
	if Index == 0 then
		return self.ShareActivityTitleLeft1
	end

	if Index == 1 then
		return self.ShareActivityTitleLeft2
	end

	if Index == 2 then
		return self.ShareActivityTitleRight1
	end

	if Index == 3 then
		return self.ShareActivityTitleRight
	end
end

function ShareActivityPanelView:SetWaterMarkText()
	local IsEnableWaterMark = _G.LoginMgr.EnableWaterMark
	if IsEnableWaterMark then
		self.LogNameWithFix =_G.LevelRecordMgr:GetLogName().."-"
		self.TextWatermarkID:SetText(self.LogNameWithFix .. _G.DateTimeTools.GetOutputTime(-1, ":", 4))
	end

	UIUtil.SetIsVisible(self.TextWatermarkID, IsEnableWaterMark)
end

function ShareActivityPanelView:Update(Callback, View, bForce)
	if self.Params == nil then
		return
	end

	local bUpdateActivityContent = self:GetShareID() == nil or self.LastUpdateShareID ~= self:GetShareID() or bForce
	self.LastUpdateShareID = self:GetShareID()

	if bUpdateActivityContent then
		UIUtil.SetIsVisible(self.ShareActivityTitleLeft1, false)
		UIUtil.SetIsVisible(self.ShareActivityTitleLeft2, false)
		UIUtil.SetIsVisible(self.ShareActivityTitleRight, false)
		UIUtil.SetIsVisible(self.ShareActivityTitleRight1, false)
	end

	self:SetWaterMarkText()

	local MajorVM = MajorUtil.GetMajorRoleVM(true)
	if MajorVM then
		self.TextName:SetText(MajorVM.Name)
		self.TextLevel:SetText(tostring(MajorVM.Level))
		self.CommPlayerHeadSlot_UIBP:SetInfo(MajorVM.RoleID)
		local RoleInitCfg = require("TableCfg/RoleInitCfg")
		UIUtil.ImageSetBrushFromAssetPathSync(self.IconJob, RoleInitCfg:FindRoleInitProfIconSimple2nd(MajorVM.Prof))
		self.TextPlatform:SetText(_G.LoginMgr:GetMapleNodeName(MajorVM.WorldID))
	end

	UIUtil.SetIsVisible(self.CommPlayerHeadSlot_UIBP, self.Params.bShowRole)
	if not string.isnilorempty(self.Params.QRcodePath) then
		UIUtil.ImageSetBrushFromAssetPathSync(self.ImgQRCode, self.Params.QRcodePath)
	end
	UIUtil.SetIsVisible(self.ImgQRCode, self.Params.bShowQRCode)
	--UIUtil.SetIsVisible(self.ImgLogo, self.Params.bShowQRCode)
	UIUtil.SetIsVisible(self.VBOX_Role, self.Params.bShowRole)

	if  not bUpdateActivityContent then
		Callback(View)
		return
	end

	local SACfg = _G.ShareMgr:GetShareActivityCfg(self:GetShareID())
	if SACfg then
		local Loc = SACfg.ShowLocation or 0
		local ActivityWidget = self:PickActivityPanel(Loc)
		if ActivityWidget then
			ActivityWidget:UpdateData(SACfg)
			UIUtil.SetIsVisible(ActivityWidget, true)
			if string.match(SACfg.ActivityBG, "http") then
				UIUtil.SetIsVisible(self.ImgBG, false)
				local ImageDownloader = _G.UE.UImageDownloader.MakeDownloader("ActivityBG", true, 200)
				ImageDownloader.OnSuccess:Add(ImageDownloader,
					function(_, Texture)
						if Texture then
							_G.FLOG_INFO('ShareActivityPanelView:Update, Download image success.')
							UIUtil.SetIsVisible(self.ImgBG, true)
							UIUtil.ImageSetMaterialTextureParameterValue(self.ImgBG, 'Texture', Texture)
						end
						Callback(View)
					end
				)

				ImageDownloader.OnFail:Add(ImageDownloader,
					function()
						if self.ImgBG:IsValid() then
							UIUtil.SetIsVisible(self.ImgBG, true)
						end
						_G.FLOG_ERROR('ShareActivityPanelView:Update, Download image failed!')
						Callback(View)
					end
				)

				ImageDownloader:Start(SACfg.ActivityBG, "", true)
				self.ImageDownloader = ImageDownloader

			else
				UIUtil.ImageSetBrushFromAssetPathSync(self.ImgBG, SACfg.ActivityBG, true)
				Callback(View)
			end
		else
			_G.FLOG_ERROR("invalid index loc %s for share activity %s", Loc, self:GetShareID())
		end
	end

	--Just for test
	-- UIUtil.SetIsVisible(self.ImgBG, false)
	-- local ImageDownloader = _G.UE.UImageDownloader.MakeDownloader("ActivityBG", true, 200)
    -- ImageDownloader.OnSuccess:Add(ImageDownloader,
	-- 	function(_, texture)
	-- 		if texture then
	-- 			_G.FLOG_INFO('ShareActivityPanelView:Update, Download image success')
	-- 			UIUtil.SetIsVisible(self.ImgBG, true)
	-- 			UIUtil.ImageSetMaterialTextureParameterValue(self.ImgBG, 'Texture', texture)
	-- 		end
	-- 		Callback(View)
	-- 	end
    -- )

    -- ImageDownloader.OnFail:Add(ImageDownloader,
	-- 	function()
    --         UIUtil.SetIsVisible(self.ImgBG, true)
	-- 		_G.FLOG_ERROR('ShareActivityPanelView:Update, Download image failed')
	-- 		Callback(View)
	-- 	end
	-- )

    -- ImageDownloader:Start("https://game.gtimg.cn/images/ff14/act/a20250214call/share.png", "", true)
	-- self.ImageDownloader = ImageDownloader
end

function ShareActivityPanelView:UpdateLogo()
	local CNLogo = "PaperSprite'/Game/UI/Atlas/Share/Frames/UI_Share_Img_Logo_CN_png.UI_Share_Img_Logo_CN_png'"
	local ENLogo = "PaperSprite'/Game/UI/Atlas/Share/Frames/UI_Share_Img_Logo_EN_png.UI_Share_Img_Logo_EN_png'"
	UIUtil.ImageSetBrushFromAssetPathSync(self.ImgLogo, _G.CommonUtil.IsCurCultureChinese() and CNLogo or ENLogo)
end

function ShareActivityPanelView:GetShareID()
	return self.Params and self.Params.ShareID or nil
end

function ShareActivityPanelView:ResetResourceRef()
	UIUtil.ImageSetMaterialTextureParameterValue(self.ImgBG, 'Texture', nil)
end

return ShareActivityPanelView