--[[
Author: zhangyuhao_ds zhangyuhao@dasheng.tv
Date: 2025-08-12 16:32:04
LastEditors: zhangyuhao_ds zhangyuhao@dasheng.tv
LastEditTime: 2025-08-12 16:33:26
FilePath: \undefinede:\Client\Source\Script\Game\House\View\ViewBase\HouseInfoViewBase.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local PhotoDefine = require("Game/Photo/PhotoDefine")
local GroupEmblemTotemCfg = require("TableCfg/GroupEmblemTotemCfg")
local GroupEmblemBackgroundCfg = require("TableCfg/GroupEmblemBackgroundCfg")
local GroupEmblemIconCfg = require("TableCfg/GroupEmblemIconCfg")
local CommonUtil = require("Utils/CommonUtil")
local HouseLocalDef = require("Game/House/HouseLocalDef")
local UIUtil = require("Utils/UIUtil")

local HouseInfoViewBase = LuaClass(UIView, true)

function HouseInfoViewBase:OnHide()
	local ImageDownloader = self.ImageDownloader
	if ImageDownloader and ImageDownloader:IsValid() then
		ImageDownloader:Stop()
	end
end

function HouseInfoViewBase:DownloadPic(Url, ImgPhotoWidget, TextLoadingWidget)
    if not Url then return end

	local MaxRequest = PhotoDefine.CropAlreadyImgDownloadMax
	local ImageDownloader = _G.UE.UImageDownloader.MakeDownloader("PhotoHouseInfoImg", true, MaxRequest)
	ImageDownloader.OnSuccess:Add(ImageDownloader,
			function(_, texture)
				if texture then
                    UIUtil.SetIsVisible(ImgPhotoWidget, true)
					self.ViewModel.PanelLoadingVisibility = false
					FLOG_INFO("[HouseInfoViewBase] download image success. = %s", Url)
                    if ImgPhotoWidget then
                        UIUtil.ImageSetMaterialTextureParameterValue(ImgPhotoWidget, 'Texture', texture)
                    end
				end
			end
	)

	ImageDownloader.OnFail:Add(ImageDownloader,
			function()
				FLOG_INFO("[HouseInfoViewBase] download image failed. = %s", Url)
                if TextLoadingWidget then
                    TextLoadingWidget:SetText(LSTR(630077))
                end
			end
	)
	ImageDownloader:Start(Url, "", true)
	self.ImageDownloader = ImageDownloader
end

--- 自己的部队头像设置
function HouseInfoViewBase:UpdateMyArmyInfo()
    local MajorUtil = require("Utils/MajorUtil")
    _G.ArmyMgr:GetArmySimpleDataByRoleIDs({MajorUtil:GetMajorRoleID()}, function(MsgBody)
    	if MsgBody and #MsgBody > 0 then
    	    local ArmyInfo = MsgBody[1].Simple
    	    self.HouseInfoHomeowner1:UpdateView(nil, ArmyInfo.Leader.RoleID, HouseLocalDef.HouseInfoStr.ArmyOwnerText)
    	    local ArmyName = CommonUtil.GetTextFromStringWithSpecialCharacter(ArmyInfo.Name .. " <10006>" .. ArmyInfo.Alias .. "<10007>")
    	    local TotemIconPath = GroupEmblemTotemCfg:GetEmblemTotemIconByID(ArmyInfo.Emblem.TotemID)
    	    local EmblemIconPath = GroupEmblemIconCfg:GetEmblemIconByID(ArmyInfo.Emblem.IconID)
    	    local ColorHex = GroupEmblemBackgroundCfg:GetEmblemBgColorByID(ArmyInfo.Emblem.BackgroundID)
    	    self.HouseInfoHomeowner2:SetArmy(ArmyName, TotemIconPath, EmblemIconPath, ColorHex)
		end
    end)
end

return HouseInfoViewBase
