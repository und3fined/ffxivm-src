
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local CommonUtil = require("Utils/CommonUtil")

local UHttpHelper 
local XPCall

local ContentTypeMap = {
    -- 文本类
    Json = "application/json; charset=utf-8",

    -- 表单类
    Form = "application/x-www-form-urlencoded"
}

---@class HttpMgr : MgrBase
local Class = LuaClass(MgrBase)

function Class:OnInit()
	self.ReqCallbackInfos = {}
    self.DownLoadCallbackInfos = {}
    self.DownLoadProgressCallbackInfos = {}
end

function Class:OnBegin()
	UHttpHelper = _G.UE.UHttpHelper.Get()
	XPCall = CommonUtil.XPCall
end

function Class:OnEnd()

end

function Class:OnShutdown()
    self.ReqCallbackInfos = {}
    self.DownLoadCallbackInfos = {}
    self.DownLoadProgressCallbackInfos = {}
end

function Class:GetUUID(type)
    type=type or 0
    local CallbackInfos=self.ReqCallbackInfos
    if type==0 then
        CallbackInfos=self.ReqCallbackInfos;
    elseif type==1 then
        CallbackInfos=self.DownLoadCallbackInfos;
    elseif type==2 then
        CallbackInfos=self.DownLoadProgressCallbackInfos;
    end
    local Ret = math.floor(os.clock() * 1000)
    if  CallbackInfos[Ret] then
        Ret = Ret + 1
    end
    return Ret
end

--- Returns a percent-encoded version of the passed in string
---@param Str stirng @The unencoded string to convert to percent-encoding
---@return The percent-encoded string
function Class:UrlEncode(Str)
    return UHttpHelper.UrlEncode(Str)
end

--- Returns a decoded version of the percent-encoded passed in string
---@param Str stirng @ EncodedString The percent encoded string to convert to string
---@return The decoded string
function Class:UrlDecode(Str)
    return UHttpHelper.UrlDecode(Str)
end

---Http发送数据请求
---@param URL string @请求urL链接
---@param Token string @鉴权token
---@param JsonStr string @请求内容
---@param Callback string @回调函数
---@param Listener table | nil  @回调函数所属对象，可为nil
---@param ContentType string @内容类型 默认ContentTypeMap.Json
---@return boolean
function Class:Post(URL, Token, JsonStr, Callback, Listener, ContentType)
    if string.isnilorempty(URL) or string.isnilorempty(JsonStr) then
        return false
    end

    local UUID = self:GetUUID() 
    ContentType = ContentType or ContentTypeMap.Json 
    local HttpRet = UHttpHelper.HttpPost(UUID, URL, Token, JsonStr, ContentType)

	self.ReqCallbackInfos[UUID] = { Callback = Callback, Listener = Listener }

    return 0 ~= HttpRet 
end

---Http请求数据请求
---@param URL string @请求urL链接
---@param Token string @鉴权token
---@param JsonStr string @请求内容
---@param Callback string @回调函数
---@param Listener table | nil  @回调函数所属对象，可为nil
---@param NeedShowLoading boolean @是否需要转菊花
---@param ContentType string @内容类型 默认ContentTypeMap.Json
---@return boolean
function Class:Get(URL, Token, SendData, Callback, Listener, NeedShowLoading, ContentType)
    if string.isnilorempty(URL) then
        return false
    end

    if NeedShowLoading == nil then
        NeedShowLoading = true
    end

    local UUID = self:GetUUID() 
    local URLReq=self:SetGetSendData(URL,SendData)

    ContentType = ContentType or ContentTypeMap.Json 
    local HttpRet = UHttpHelper.HttpGet(UUID, URLReq, Token, ContentType)

	self.ReqCallbackInfos[UUID] = { Callback = Callback, Listener = Listener }
    if NeedShowLoading then
        _G.NetworkImplMgr:StartWaiting(UUID,5000,LSTR(10018))
    end
    return 0 ~= HttpRet 
end

---Http请求数据请求
---@param URL string @请求urL链接
---@param JsonStr string @请求内容
function Class:SetGetSendData(URL, SendData)
    if string.isnilorempty(URL) or table.is_nil_empty(SendData) then
        return URL
    end

    local queryParts = {}
    for k, v in pairs(SendData) do
        local str =_G.HttpMgr:UrlEncode(tostring(v))
        table.insert(queryParts, k.."="..str)
    end

    return URL.."?"..table.concat(queryParts, "&")
end


---Http请求数据请求
---@param URL string @请求urL链接
---@param SendData string @请求内容
---@param Callback string @回调函数
---@param Listener table | nil  @回调函数所属对象，可为nil
---@return boolean
function Class:DownLoad(URL, SavePath, SendData, Callback, Listener)
    if string.isnilorempty(URL) or string.isnilorempty(SavePath) then
        return false
    end

    local UUID = self:GetUUID(1)
    local URLReq=self:SetGetSendData(URL,SendData)
    local HttpRet = UHttpHelper.HttpDownLoad(UUID, URLReq, SavePath)

    self.DownLoadCallbackInfos[UUID] = {
        Callback = Callback,
        Listener = Listener
    }
    return 0 ~= HttpRet
end


--- Http应答
---@param UUID number @ http请求时赋予的UUID
---@param MessageBody string @
function Class.OnHttpReqComplete(UUID, MessageBody, bSucceeded)
    local HttpMgr = _G.HttpMgr
	local Info = HttpMgr.ReqCallbackInfos[UUID]
    if nil == Info then
        return
    end

    local Callback = Info.Callback
    if nil ~= Callback then
        _G.NetworkImplMgr:StopWaiting(UUID)
        XPCall(Info.Listener, Callback, MessageBody, bSucceeded)
    end

    HttpMgr.ReqCallbackInfos[UUID] = nil
end

--- Http下载结果
---@param UUID number @ http请求时赋予的UUID
function Class.OnHttpDownLoadComplete(UUID,bSuc,FileSavePath)
    local HttpMgr = _G.HttpMgr
	local Info = HttpMgr.DownLoadCallbackInfos[UUID]
    if nil == Info then
        return
    end

    local Callback = Info.Callback
    if nil ~= Callback then
        XPCall(Info.Listener, Callback, bSuc,FileSavePath)
    end

    HttpMgr.DownLoadCallbackInfos[UUID] = nil
end

--- Http下载进度
---@param UUID number @ http请求时赋予的UUID
function Class.OnHttpDownLoadProgress(UUID, Received, total)
    local progress= math.floor(Received/total * 100* 100)/100
    local HttpMgr = _G.HttpMgr
	local Info = HttpMgr.DownLoadProgressCallbackInfos[UUID]
    if nil == Info then
        return
    end
    local Callback = Info.Callback
    if nil ~= Callback then
        XPCall(Info.Listener, Callback, Received, total)
    end

    HttpMgr.DownLoadProgressCallbackInfos[UUID] = nil
end

--- Http上传结果
function Class.OnHttpUploadResult(Result,NeedRetryTips,RespStr)
    _G.LevelRecordMgr:UpLoadLogResult(Result,NeedRetryTips,RespStr)
end

return Class
