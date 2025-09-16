---
--- Author: richyczhou
--- DateTime: 2024-07-17 21:02
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local LoginNewDefine = require("Game/LoginNew/LoginNewDefine")
local UIUtil = require("Utils/UIUtil")

local FLOG_INFO = _G.FLOG_INFO
local FLOG_ERROR = _G.FLOG_ERROR

---@class LoginNewFriendItem2View : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBg UFImage
---@field ImgPlayer UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginNewFriendItem2View = LuaClass(UIView, true)

function LoginNewFriendItem2View:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBg = nil
	--self.ImgPlayer = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginNewFriendItem2View:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginNewFriendItem2View:OnInit()

end

function LoginNewFriendItem2View:OnDestroy()

end

function LoginNewFriendItem2View:OnShow()

end

function LoginNewFriendItem2View:OnHide()
	local ImageDownloader = self.ImageDownloader
	if ImageDownloader and ImageDownloader:IsValid() then
		ImageDownloader:Stop()
	end
end

function LoginNewFriendItem2View:OnRegisterUIEvent()

end

function LoginNewFriendItem2View:OnRegisterGameEvent()

end

function LoginNewFriendItem2View:OnRegisterBinder()

end

function LoginNewFriendItem2View:ShowIconByUrl(IconUrl)
    FLOG_INFO("[LoginNewFriendItem2View:ShowIconByUrl] IconUrl:" .. IconUrl)

    if string.isnilorempty(IconUrl) then
        self:ShowDefaultIcon(true)
        return
    end

    ---@type UImageDownloader
    local ImageDownloader = _G.UE.UImageDownloader.MakeDownloader("FriendIcon", true, LoginNewDefine.DefaultFriendImageMax)
    ImageDownloader.OnSuccess:Add(ImageDownloader,
            function(_, texture)
                if texture then
                    FLOG_INFO("[LoginNewFriendItem2View:ShowIconByUrl] Download success")
                    self:ShowDefaultIcon(false)
                    --UIUtil.SetIsVisible(self.ImgPlayer, true)
                    --UIUtil.ImageSetBrushResourceObject(self.ImgPlayer, texture)
                    UIUtil.ImageSetMaterialTextureParameterValue(self.ImgPlayer, 'Texture', texture)
                end
            end
    )

    ImageDownloader.OnFail:Add(ImageDownloader,
            function()
                FLOG_ERROR("[LoginNewFriendItem2View:ShowIconByUrl] Download failed...")
                self:ShowDefaultIcon(true)
            end
    )

    ImageDownloader:Start(IconUrl, "", true)
	self.ImageDownloader = ImageDownloader
end

function LoginNewFriendItem2View:ShowDefaultIcon(bShowDefaultIcon)
    UIUtil.SetIsVisible(self.IconSilhouette, bShowDefaultIcon)
    UIUtil.SetIsVisible(self.ImgPlayer, not bShowDefaultIcon)
    --UIUtil.ImageSetBrushFromAssetPath(self.ImgPlayer, LoginNewDefine.DefaultFriendImage)
end

return LoginNewFriendItem2View