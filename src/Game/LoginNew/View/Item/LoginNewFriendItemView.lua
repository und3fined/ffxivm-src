---
--- Author: richyczhou
--- DateTime: 2024-06-25 09:58
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local LoginMgr = require("Game/Login/LoginMgr")
local LoginNewDefine = require("Game/LoginNew/LoginNewDefine")
local LoginNewVM = require("Game/LoginNew/VM/LoginNewVM")
local UIUtil = require("Utils/UIUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")

local FLOG_INFO = _G.FLOG_INFO
local FLOG_ERROR = _G.FLOG_ERROR

---@class LoginNewFriendItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconBtn UFButton
---@field IconSilhouette UFImage
---@field ImgBg UFImage
---@field ImgNormalFrame UFImage
---@field ImgPlayer UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginNewFriendItemView = LuaClass(UIView, true)

function LoginNewFriendItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconBtn = nil
	--self.IconSilhouette = nil
	--self.ImgBg = nil
	--self.ImgNormalFrame = nil
	--self.ImgPlayer = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginNewFriendItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginNewFriendItemView:OnInit()

end

function LoginNewFriendItemView:OnDestroy()

end

function LoginNewFriendItemView:OnShow()
    local Params = self.Params
    if nil == Params then return end

    ---@type FriendItemVM
    local FriendItemVM = Params.Data
    if nil == FriendItemVM then return end

    FLOG_INFO("[LoginNewFriendItemView:OnShow] Name:%s, IconUrl:%s", FriendItemVM.Name, FriendItemVM.IconUrl)
    self:ShowIconByUrl(FriendItemVM.IconUrl)
end

function LoginNewFriendItemView:OnHide()
    local ImageDownloader = self.ImageDownloader
    if ImageDownloader and ImageDownloader:IsValid() then
        ImageDownloader:Stop()
    end
end

function LoginNewFriendItemView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.IconBtn, self.OnClickIconBtn)
end

function LoginNewFriendItemView:OnRegisterGameEvent()

end

function LoginNewFriendItemView:OnRegisterBinder()

end

function LoginNewFriendItemView:OnClickIconBtn()
    --local Params = self.Params
    --if nil == Params then
    --    return
    --end
    --local ViewModel = self.Params.Data
    --if nil == ViewModel then
    --    return
    --end
    --
    --LoginNewVM.WorldID = self.Params.Data.WorldID
    --LoginNewVM.WorldState = self.Params.Data.State
    --LoginNewVM.NodeTag = self.Params.Data.Tag
    --LoginMgr.OverseasSvrAreaId = self.Params.Data.CustomValue2
    --FLOG_INFO("[LoginNewFriendItemView:OnClickIconBtn] WorldID:%d", LoginNewVM.WorldID)

    -- 播放视频崩溃上报比较多，减少调用次数，不重复播放:打开同玩好友列表
    --LoginMgr.IsMoviePlaying = false
    --_G.CgMgr:StopCGVideo()
    UIViewMgr:ShowView(UIViewID.LoginServerList, { Index = 3 })
end

function LoginNewFriendItemView:ShowIconByUrl(IconUrl)
    if string.isnilorempty(IconUrl) then
        self:ShowDefaultIcon(true)
        return
    end

    ---@type UImageDownloader
    local ImageDownloader = _G.UE.UImageDownloader.MakeDownloader("FriendIcon", true, LoginNewDefine.DefaultFriendImageMax)
    ImageDownloader.OnSuccess:Add(ImageDownloader,
        function(_, texture)
            if texture then
                FLOG_INFO("[LoginNewFriendItemView:ShowIconByUrl] Download success")
                if self.ImgPlayer and self.ImgPlayer:IsValid() then
                    self:ShowDefaultIcon(false)
                    UIUtil.ImageSetBrushFromAssetPath(self.ImgPlayer, LoginNewDefine.DefaultMaterial)
                    UIUtil.ImageSetMaterialTextureParameterValue(self.ImgPlayer, 'Texture', texture)
                else
                    FLOG_ERROR("[LoginNewFriendItemView:ShowIconByUrl] ImgPlayer is invalid")
                end
            end
        end
    )

    ImageDownloader.OnFail:Add(ImageDownloader,
        function()
            FLOG_ERROR("[LoginNewFriendItemView:ShowIconByUrl] Download failed...")
            self:ShowDefaultIcon(true)
        end
    )

    ImageDownloader:Start(IconUrl, "", true)
	self.ImageDownloader = ImageDownloader
end

function LoginNewFriendItemView:ShowDefaultIcon(bShowDefaultIcon)
    UIUtil.SetIsVisible(self.IconSilhouette, bShowDefaultIcon)
    UIUtil.SetIsVisible(self.ImgPlayer, not bShowDefaultIcon)
    --UIUtil.ImageSetBrushFromAssetPath(self.ImgPlayer, LoginNewDefine.DefaultFriendImage)
end

return LoginNewFriendItemView