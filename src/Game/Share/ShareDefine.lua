

local SharePlatformEnum = {
    QQ = 1,
    QQ_ZONE = 2,
    WECHAT = 3,
    WECHAT_CIRCLE = 4,
    WECHAT_VIDEO = 5,
    SYSTEM = 6,
    TIKTOK = 7,
    BILIBILI = 8,
    XIAO_HONG_SHU = 9,
    WEIBO = 10,
    TWITTER = 11,
    FACEBOOK = 12,
    LINE = 13,
    SMS = 14,
    TAPTAP = 15,
    WHATSAPP = 16,
    INSTAGRAM = 17,
    TELEGARAM = 18,
    QQ_PINDAO = 19,
}

local ShareTypeEnum = {
    EXTERNAL_LINK = 1,
    IMAGE = 2,
}

local SharePlatformIcons = {
    BILIBILI = "PaperSprite'/Game/UI/Atlas/Share/Frames/UI_Share_Icon_Bilibili_png.UI_Share_Icon_Bilibili_png'",
    WECHAT_CIRCLE = "PaperSprite'/Game/UI/Atlas/Share/Frames/UI_Share_Icon_Moments_png.UI_Share_Icon_Moments_png'",
    TWITTER = "PaperSprite'/Game/UI/Atlas/Share/Frames/UI_Share_Icon_X_png.UI_Share_Icon_X_png'",
    FACEBOOK = "PaperSprite'/Game/UI/Atlas/Share/Frames/UI_Share_Icon_Facebook_png.UI_Share_Icon_Facebook_png'",
    LINE = "PaperSprite'/Game/UI/Atlas/Share/Frames/UI_Share_Icon_Line_png.UI_Share_Icon_Line_png'",
    XIAO_HONG_SHU = "PaperSprite'/Game/UI/Atlas/Share/Frames/UI_Share_Icon_LittleRedBook_png.UI_Share_Icon_LittleRedBook_png'",
    SYSTEM = "PaperSprite'/Game/UI/Atlas/Share/Frames/UI_Share_Icon_More_png.UI_Share_Icon_More_png'",
    WECHAT_VIDEO = "PaperSprite'/Game/UI/Atlas/Share/Frames/UI_Share_Icon_Channels_png.UI_Share_Icon_Channels_png'",
    QQ = "PaperSprite'/Game/UI/Atlas/Share/Frames/UI_Share_Icon_QQ_png.UI_Share_Icon_QQ_png'",
    QQ_ZONE = "PaperSprite'/Game/UI/Atlas/Share/Frames/UI_Share_Icon_QQSpace_png.UI_Share_Icon_QQSpace_png'",
    QQ_PINDAO = "PaperSprite'/Game/UI/Atlas/Share/Frames/UI_Share_Icon_QQChannel_png.UI_Share_Icon_QQChannel_png'",
    WEIBO = "PaperSprite'/Game/UI/Atlas/Share/Frames/UI_Share_Icon_SinaWeibo_png.UI_Share_Icon_SinaWeibo_png'",
    SMS = "PaperSprite'/Game/UI/Atlas/Share/Frames/UI_Share_Icon_SMS_png.UI_Share_Icon_SMS_png'",
    TAPTAP = "PaperSprite'/Game/UI/Atlas/Share/Frames/UI_Share_Icon_Tap_png.UI_Share_Icon_Tap_png'",
    TIKTOK = "PaperSprite'/Game/UI/Atlas/Share/Frames/UI_Share_Icon_TikTok_png.UI_Share_Icon_TikTok_png'",
    WECHAT = "PaperSprite'/Game/UI/Atlas/Share/Frames/UI_Share_Icon_WeChat_png.UI_Share_Icon_WeChat_png'",
    WHATSAPP = "PaperSprite'/Game/UI/Atlas/Share/Frames/UI_Share_Icon_WhatsApp_png.UI_Share_Icon_WhatsApp_png'",
}

local ShareObjectClassPath = {
    [SharePlatformEnum.WECHAT] = 'Game/Share/WeChatShareObject',
    [SharePlatformEnum.WECHAT_CIRCLE] = 'Game/Share/WeChatCircleShareObject',
    [SharePlatformEnum.WECHAT_VIDEO] = 'Game/Share/WeChatVideoShareObject',
    [SharePlatformEnum.FACEBOOK] = 'Game/Share/FacebookShareObject',
    [SharePlatformEnum.TWITTER] = 'Game/Share/TwitterShareObject',
    [SharePlatformEnum.WHATSAPP] = 'Game/Share/WhatsAppShareObject',
    [SharePlatformEnum.LINE] = 'Game/Share/LineShareObject',
    [SharePlatformEnum.QQ] = 'Game/Share/QQShareObject',
    [SharePlatformEnum.QQ_ZONE] = 'Game/Share/QQZoneShareObject',
    [SharePlatformEnum.QQ_PINDAO] = 'Game/Share/QQPinDaoShareObject',
    [SharePlatformEnum.TAPTAP] = 'Game/Share/TapTapShareObject',
    [SharePlatformEnum.SMS] = 'Game/Share/SmsShareObject',
    [SharePlatformEnum.BILIBILI] = 'Game/Share/BilibiliShareObject',
    [SharePlatformEnum.SYSTEM] = 'Game/Share/SystemShareObject',
}

local EXLINK_QQ_APPS = {
    SharePlatformEnum.QQ,
    SharePlatformEnum.QQ_ZONE,
    SharePlatformEnum.BILIBILI,
    SharePlatformEnum.TAPTAP,
    SharePlatformEnum.SYSTEM,
}

local EXLINK_WECHAT_APPS = {
    SharePlatformEnum.WECHAT,
    SharePlatformEnum.WECHAT_CIRCLE,
    SharePlatformEnum.WECHAT_VIDEO,
    SharePlatformEnum.BILIBILI,
    SharePlatformEnum.TAPTAP,
    SharePlatformEnum.SYSTEM,
}

local EXLINK_OVERSEAS_APPS = {
    SharePlatformEnum.FACEBOOK,
    SharePlatformEnum.TWITTER,
    SharePlatformEnum.LINE,
    SharePlatformEnum.SMS,
    SharePlatformEnum.WHATSAPP,
    SharePlatformEnum.SYSTEM,
}

local function GetShareObjectClassPath(T)
    return T and ShareObjectClassPath[T] or nil
end 

-- 微信原生分享图片
local WxNativeSharePic = "https://game.gtimg.cn/images/ff14/shareimg/FFM2.0.jpg"

local ShareDefine = {
    SharePlatformEnum = SharePlatformEnum,
    SharePlatformIcons = SharePlatformIcons,
    ShareTypeEnum = ShareTypeEnum,
    GetShareObjectClassPath = GetShareObjectClassPath,
    EXLINK_QQ_APPS = EXLINK_QQ_APPS,
    EXLINK_WECHAT_APPS = EXLINK_WECHAT_APPS,
    EXLINK_OVERSEAS_APPS = EXLINK_OVERSEAS_APPS,
    WxNativeSharePic = WxNativeSharePic,
}


return ShareDefine