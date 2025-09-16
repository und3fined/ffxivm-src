local LuaClass = require("Core/LuaClass")
local ShareObject = require("Game/Share/ShareObject")
local ShareDefine = require("Game/Share/ShareDefine")


---@class QQPinDaoShareObject : ShareObject
local QQPinDaoShareObject = LuaClass(ShareObject, nil)

function QQPinDaoShareObject:Ctor()
    self:SetIcon(ShareDefine.SharePlatformIcons.QQ_PINDAO)
    self.TipIDAppNotInstalled = 172023
end

function QQPinDaoShareObject:IsAppToShareInstalled()
    local AccountUtil = require("Utils/AccountUtil")
    return AccountUtil.IsQQInstalled()
end

function QQPinDaoShareObject:ShareExternalLink()
    local ShareMgr = require("Game/Share/ShareMgr")
    ShareMgr.ShareLinkByMSDK(self)
end

function QQPinDaoShareObject:GetShareChannel()
    return "QQ"
end

function QQPinDaoShareObject:CanShareImage()
    return true
end

function QQPinDaoShareObject:ShareImage()
    local ShareMgr = require("Game/Share/ShareMgr")
    ShareMgr:ShareToQQPinDao()
end

return QQPinDaoShareObject