--[[
Author: jususchen jususchen@tencent.com
Date: 2024-12-12 20:11:21
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-12-23 16:50:11
FilePath: \Script\Game\Share\ShareObject.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AEail
--]]
local LuaClass = require("Core/LuaClass")
local ShareDefine = require("Game/Share/ShareDefine")


---@class ShareObject
---@field Icon string | nil
local ShareObject = LuaClass(nil, nil)

function ShareObject:Ctor(ShareType, Content)
    self.ShareType = ShareType
    self.Content = Content
end

---@return boolean | nil
function ShareObject:IsAppToShareInstalled()
end

function ShareObject:HandleAppNotInstalled()
    if self.TipIDAppNotInstalled then
       _G.MsgTipsUtil.ShowTipsByID(self.TipIDAppNotInstalled)
        return true
    end
end

function ShareObject:SetIcon(Icon)
    self.Icon = Icon
end

function ShareObject:CanShareText()
end

function ShareObject:CanShareImage()
end

function ShareObject:CanShareMiniApp()
end

function ShareObject:CanShareLink()
end

function ShareObject:ShareImage()
    if self.ShareType ~= ShareDefine.ShareTypeEnum.IMAGE then
        _G.FLOG_ERROR("ShareObject:ShareImage invalid share type: %s", self.ShareType)
        return
    end

    self:BeforeShare()
    _G.FLOG_INFO("ShareObject:ShareImage channel: %s content: %s", self:GetShareChannel(), _G.table_to_string(self.Content))
    local ImagePath = _G.ShareMgr.GetImageLocalSharePath()
    _G.AccountUtil.SharePicture(self:GetShareChannel(), ImagePath)
end

function ShareObject:ShareExternalLink()
    if self.ShareType ~= ShareDefine.ShareTypeEnum.EXTERNAL_LINK then
        _G.FLOG_ERROR("ShareObject:ShareExternalLink invalid share type %s", self.ShareType)
        return
    end

    if type(self.Content) ~= 'table' then
        _G.FLOG_ERROR("ShareObject:ShareExternalLink content must be table")
        return
    end

    local Title = self.Content.Title
    local Link = self.Content.Link
    if Title == nil or Title == "" then
        _G.FLOG_ERROR("ShareObject:ShareExternalLink content must specify `Title` field")
        return
    end

    self:BeforeShare()
    _G.FLOG_INFO("ShareObject:ShareExternalLink share with channel: %s, title: %s, link: %s", self:GetShareChannel(), Title, Link)
    _G.AccountUtil.ShareLink(self:GetShareChannel(), Link, Title)
end

function ShareObject:GetShareChannel()
end

function ShareObject:SetShareCallbackBefore(Callback, ...)
    if type(Callback) == 'function' then
       self.ShareCallbackBefore = Callback
       self.ShareCallbackBeforeParams = table.pack(...)
    end
end

function ShareObject:BeforeShare()
    if self.ShareCallbackBefore then
       self.ShareCallbackBefore(table.unpack(self.ShareCallbackBeforeParams)) 
    end
end

function ShareObject:GetMSDKUserField()
end

function ShareObject:IsUsingSOpenID()
end

return ShareObject