--
-- Author: anypkvcai
-- Date: 2020-09-12 09:52:07
-- Description: 
--

local UCommonUtil = _G.UE.UCommonUtil
local UPlatformUtil = _G.UE.UPlatformUtil
local LogMgr = require("Log/LogMgr")
local GameplayStaticsUtil = require("Utils/GameplayStaticsUtil")
local CommonDefine = require("Define/CommonDefine")
local CultureName = CommonDefine.CultureName
local Json = require("Core/Json")
local ProtoRes = require ("Protocol/ProtoRes")
local SettingsDefine = require("Game/Settings/SettingsDefine")
local GameDataKey = require("Define/GameDataKey")

--浮点数比较相等的默认精度
local FLOAT_EQUAL_PRECISION = 0.001
local TGPA_TASK_CHECK_INTERVAL = 5
local ENABLE_TGPA_TASK_CHECK = true
local TGPA_GAME_DATA_REPORT_INTERVAL = 5
local ENABLE_TGPA_GAME_DATA_REPORT = true

local ANDROID_NO_STORAGE_PERMISSION = 100

local FLOG_INFO = _G.FLOG_INFO

---@class CommonUtil
local CommonUtil = {
	PlatformName = nil,
	WithEditor = nil,
	CustomErrorLimitMap = {},
	TGPATaskCheckTimeID = nil,
	TGPAGameDataReportTimerID = nil
}

---XPCallLog
---@param msg string            @xpcall 日志函数
function CommonUtil.XPCallLog(msg)
	LogMgr.Error(msg)

	local luaStackStr = debug.traceback()
	LogMgr.Info(luaStackStr)

	local CrashSightMgr = _G.UE.UCrashSightMgr.Get()
	if CrashSightMgr then
		CrashSightMgr:ReportLuaCallError(msg, luaStackStr, "")
	end
end

--统一接口，后续可以统一关
function CommonUtil.GetLuaTraceback()
	return debug.traceback()
end

--Msg：每次上报的自定义字符串
--LuaStack：自定义的当做堆栈的字符串，可以将多次上报汇总到1个堆栈，1个上报id
--ExtraInfo：每次上报的额外数据，是在extraMessage.txt中
--IgnoreLimit：true是每次都上报，否则1次启动客户端的过程中只上报1次
function CommonUtil.ReportCustomError(Msg, LuaStack, ExtraInfo, IgnoreLimit)
	LuaStack = string.format("%s_%s", "FMCustomError", LuaStack)
	local IsReport = false
	Msg = Msg or ""
	ExtraInfo = ExtraInfo or ""
	local KeyStr = LuaStack .. Msg .. ExtraInfo
	if not CommonUtil.CustomErrorLimitMap[KeyStr] then
		CommonUtil.CustomErrorLimitMap[KeyStr] = true
		IsReport = true
	end

	if IgnoreLimit or IsReport then
		local CrashSightMgr = _G.UE.UCrashSightMgr.Get()
		if CrashSightMgr then
			CrashSightMgr:ReportLuaCallError(Msg, LuaStack, ExtraInfo)
		end
	end
end

-- _G.XPCallLog = CommonUtil.XPCallLog

---FloatIsEqual
---@param A number
---@param B number
---@param Precision number @默认是 FLOAT_EQUAL_PRECISION
function CommonUtil.FloatIsEqual(A, B, Precision)
	if nil == Precision then
		Precision = FLOAT_EQUAL_PRECISION
	end
	return math.abs(A - B) < Precision
end

---XPCall
---@param Object any
---@param Function function
function CommonUtil.XPCall(Object, Function, ...)
	if nil == Object then
		return xpcall(Function, CommonUtil.XPCallLog, ...)
	else
		return xpcall(Function, CommonUtil.XPCallLog, Object, ...)
	end
end

---IsA
---@param Object table
---@param ClassType table
function CommonUtil.IsA(Object, ClassType)
	if nil == Object or nil == ClassType then
		return false
	end

	if type(Object) ~= "table" then
		return false
	end

	if Object.__BaseType == ClassType then
		return true
	end

	local MetaTable = getmetatable(Object)
	if nil ~= MetaTable and MetaTable.__index == ClassType then
		return true
	end

	return CommonUtil.IsA(Object.__BaseType, ClassType)
end

function CommonUtil.DisableShowJoyStick(bShowJoyStick)
	CommonUtil.bDisableShowJoyStick = bShowJoyStick
end

---IsDisableShowJoyStick
---@return boolean
function CommonUtil.IsDisableShowJoyStick()
	return CommonUtil.bDisableShowJoyStick
end

---ShowJoyStick
function CommonUtil.ShowJoyStick()
	if (CommonUtil.bDisableShowJoyStick) then
		return
	end

	_G.UE.UActorManager:Get():SetVirtualJoystickVisibility(true)
end

---HideJoyStick
function CommonUtil.HideJoyStick()
	_G.UE.UActorManager:Get():SetVirtualJoystickVisibility(false)
end

---SetJoyStickVisible
---@param IsVisible boolean
function CommonUtil.SetJoyStickVisible(IsVisible)
	_G.UE.UActorManager:Get():SetVirtualJoystickVisibility(IsVisible)
end

---GetPlatformName
---@return string   @Platform names include Windows, Mac, IOS, Android, PS4, XboxOne, Linux
function CommonUtil.GetPlatformName()
	if nil == CommonUtil.PlatformName then
		CommonUtil.PlatformName = _G.UE.UGameplayStatics.GetPlatformName()
	end

	return CommonUtil.PlatformName
end

---IsWithEditor
---@return boolean
function CommonUtil.IsWithEditor()
	if nil == CommonUtil.WithEditor then
		CommonUtil.WithEditor = UPlatformUtil.IsWithEditor()
	end
	return CommonUtil.WithEditor
end

local bIsShipping = UCommonUtil.IsShipping()

---IsShipping
---@return boolean
function CommonUtil.IsShipping()
	return bIsShipping
end

---IsAndroidPlatform
---@return boolean
function CommonUtil.IsAndroidPlatform()
	return CommonUtil.GetPlatformName() == "Android"
end

---IsIOSPlatform
---@return boolean
function CommonUtil.IsIOSPlatform()
	return CommonUtil.GetPlatformName() == "IOS"
end

---IsMobilePlatform
---@return boolean
function CommonUtil.IsMobilePlatform()
	local Name = CommonUtil.GetPlatformName()
	return Name == "Android" or Name == "IOS"
end

---GetTextFromStringWithSpecialCharacter
---@param str string
---@return string
function CommonUtil.GetTextFromStringWithSpecialCharacter(str)
	if string.isnilorempty(str) then
		return ""
	end
	local SpecialCharacterCfg = require("TableCfg/SpecialCharacterCfg")
	local ReplacedStr = str:gsub("<(%d+)>", function(IdStr)
		local ID = tonumber(IdStr, 10)
		local cfg = SpecialCharacterCfg:FindCfgByKey(ID)
		if cfg == nil then
			return ""
		end
		local Unicode = tonumber(cfg.Unicode)
		if Unicode == nil then
			return ""
		end
		return utf8.char(Unicode)
	end)

	return ReplacedStr
	--return UCommonUtil.GetTextFromStringWithUnicode(str)
end

function CommonUtil.PreviewGameLocalization()
	if CommonUtil.IsWithEditor() then
		local Language = UCommonUtil.GetConfiguredGameLocalizationPreviewLanguage()
		if string.isnilorempty(Language) then
			Language = CultureName.Chinese 
		end

		UCommonUtil.EnableGameLocalizationPreview(Language, true)

		FLOG_INFO("[Localization] PreviewGameLocalization,%s", Language)
	end

end

function CommonUtil.GetCultureList()
	local ListData={}
	for _, v in pairs(SettingsDefine.LanguagesDesc or {}) do
		table.insert(ListData, { Name = v.._ })
	end
	return ListData
end

---SetCurrentCulture
---@param InCultureName string
---@param InSaveToConfig boolean
function CommonUtil.SetCurrentCulture(InCultureName, InSaveToConfig)
	return UCommonUtil.SetCurrentCulture(InCultureName, InSaveToConfig)
end

---GetCurrentCultureName
function CommonUtil.GetCurrentCultureName()
	local Name = UCommonUtil.GetCurrentCultureName()
	if Name == "zh-CN" then
		Name = CultureName.Chinese
	end
	return Name
end

---当前语言是否为 简体中文
function CommonUtil.IsCurCultureChinese()
	return CommonUtil.GetCurrentCultureName() == CultureName.Chinese
end

---当前语言是否为 英文 
function CommonUtil.IsCurCultureEnglish()
	return CommonUtil.GetCurrentCultureName() == CultureName.English
end

---当前语言是否为 日文 
function CommonUtil.IsCurCultureJapanese()
	return CommonUtil.GetCurrentCultureName() == CultureName.Japanese
end

---当前语言是否为 韩文 
function CommonUtil.IsCurCultureKorean()
	return CommonUtil.GetCurrentCultureName() == CultureName.Korean
end

---当前语言是否为 法文 
function CommonUtil.IsCurCultureFrench()
	return CommonUtil.GetCurrentCultureName() == CultureName.French
end

---当前语言是否为 德文 
function CommonUtil.IsCurCultureGerman()
	return CommonUtil.GetCurrentCultureName() == CultureName.German
end

---当前语言版本是否为国内版本
function CommonUtil.IsInternationalChina()
	return UCommonUtil.IsInternationalChina()
end

---GetBatteryLevel 获取电池电量
---@return number 电池电量
function CommonUtil.GetBatteryLevel()
	return UPlatformUtil.GetBatteryLevel()
end

---SpawnActor
---@param Class
---@param NewLocation FVector
---@param NewRotation FRotator
function CommonUtil.SpawnActor(Class, NewLocation, NewRotation)
	if NewLocation == nil then
		NewLocation = _G.UE.FVector(0, 0, 100000000)
	end

	if NewRotation == nil then
		NewRotation = _G.UE.FRotator(0, 0, 0)
	end

	return UCommonUtil.SpawnActor(Class, NewLocation, NewRotation)
end

---SpawnActorAsync
---@param Class
---@param NewLocation FVector
---@param NewRotation FRotator
---@param SuccessCallBack function
function CommonUtil.SpawnActorAsync(Class, NewLocation, NewRotation, SuccessCallBack)
	if NewLocation == nil then
		NewLocation = _G.UE.FVector(0, 0, 100000000)
	end

	if NewRotation == nil then
		NewRotation = _G.UE.FRotator(0, 0, 0)
	end

	local SuccessDelegatePair = CommonUtil.GetCallbackDelegatePairs(SuccessCallBack)

	return UCommonUtil.SpawnActorAsync(Class, NewLocation, NewRotation, SuccessDelegatePair)
end

---DestroyActor
---@param Actor
function CommonUtil.DestroyActor(Actor)
	return UCommonUtil.DestroyActor(Actor)
end

function CommonUtil.IsObjectValid(UEObj)
	return UCommonUtil.IsObjectValid(UEObj)
end

---QuitGame
function CommonUtil.QuitGame()
	_G.WorldMsgMgr:MarkLevelFinished()
	local Name = CommonUtil.GetPlatformName()
	if Name == "IOS" or Name == "Android" then
		UPlatformUtil.RequestExit(true)
	else
		local World = GameplayStaticsUtil.GetWorld()
		if nil == World then
			return
		end

		_G.UE.UKismetSystemLibrary.QuitGame(World, nil, _G.UE.EQuitPreference.Quit, false)
	end
end

---RestartGame
function CommonUtil.RestartGame()
	UCommonUtil.RestartGame()
end

---ClipboardCopy
---@param str string @拷贝到剪切板的字符串
function CommonUtil.ClipboardCopy(str)
	UPlatformUtil.ClipboardCopy(str)
end

---ClipboardPaste
---@return string @返回剪贴板的拷贝字段
function CommonUtil.ClipboardPaste()
	return UPlatformUtil.ClipboardPaste()
end

function CommonUtil.ConsoleCommand(Cmd)
	local Controller = GameplayStaticsUtil.GetPlayerController()
	if nil == Controller then
		return
	end

	Controller:ConsoleCommand(Cmd, false)
end

---ShallowCopyArray @浅拷贝数组类型table，不拷贝元表，也不做任何元表的处理
---@param Array table
---@return table
function CommonUtil.ShallowCopyArray(Array)
	if nil == Array then
		return
	end

	local Copy = {}
	local Length = #Array

	for i = 1, Length do
		Copy[i] = Array[i]
	end

	return Copy
end

---ShallowCopyDict @浅拷贝字典类型table，不拷贝元表，也不做任何元表的处理
---@param Dict table
---@return table
function CommonUtil.ShallowCopyDict(Dict)
	if nil == Dict then
		return
	end

	local Copy = {}

	for k, v in pairs(Dict) do
		Copy[k] = v
	end

	return Copy
end

function CommonUtil.GetIntPart(FloatValue)
	if FloatValue <= 0 then
		return math.ceil(FloatValue);
	end

	local IntNum = math.ceil(FloatValue);
	if IntNum == FloatValue then
		return IntNum;
	else
		return (IntNum - 1);
	end
end

--- 将策划配置的路径修改成加载Class的路径
---@param CfgPath string @策划配置的路径
function CommonUtil.ParseBPPath(CfgPath)
	if string.endsWith(CfgPath, "_C'") == false then
		return CfgPath:sub(1, -2) .. "_C'"
	else
		return CfgPath
	end
end

-- 网络连接类型
function CommonUtil.GetNetworkConnectionType()
	local ENetworkConnectionType = _G.UE.ENetworkConnectionType
	local connectType = UPlatformUtil.GetNetworkConnectionType()
	local typeStr = "Unknown"
	if connectType == ENetworkConnectionType.Unknown then
		typeStr = "Unknown"
	elseif connectType == ENetworkConnectionType.None then
		typeStr = "None"
	elseif connectType == ENetworkConnectionType.AirplaneMode then
		typeStr = "AirplaneMode"
	elseif connectType == ENetworkConnectionType.Cell then
		typeStr = "Cell"
	elseif connectType == ENetworkConnectionType.WiFi then
		typeStr = "WiFi"
	elseif connectType == ENetworkConnectionType.WiMAX then
		typeStr = "WiMAX"
	elseif connectType == ENetworkConnectionType.Bluetooth then
		typeStr = "Bluetooth"
	elseif connectType == ENetworkConnectionType.Ethernet then
		typeStr = "Ethernet"
	end

	return typeStr
end

--设备类型ios 0 android 1  2-windows，3-mac，4-其他 5-模拟器
function CommonUtil.GetDeviceType()
	local DeviceType = 0
	local PlatformName = CommonUtil.GetPlatformName()
	if PlatformName == "Android" then
		DeviceType = 1
	elseif PlatformName == "IOS" then
		DeviceType = 0
	elseif PlatformName == "Windows" then
		DeviceType = 2
	elseif PlatformName == "Mac" then
		DeviceType = 3
	else
		DeviceType = 4
	end

	local IsWithEmulatorMode = _G.UE.UUIMgr.Get():IsWithEmulator()
	if IsWithEmulatorMode then
		DeviceType = 5
	end

	return DeviceType
end

function CommonUtil.GetOAIDorCAID()
	-- local PlatformName = CommonUtil.GetPlatformName()
	-- if PlatformName == "IOS" then
	--     return UTOAAFunctionLibrary.GetCAID_IOS(), 0
	-- elseif PlatformName == "Android" then
	--     return UTOAAFunctionLibrary.GetOAID_Android(), 1
	-- end
	return ""
end

---取消键盘焦点
function CommonUtil.ClearKeyboardFocus()
	UCommonUtil.ClearKeyboardFocus()
end

---隐藏虚拟键盘
function CommonUtil.HideVirtualKeyboard()
	UCommonUtil.HideVirtualKeyboard()
end

-------------------------------------------------------------------------------------------------
---字符串

---删除字符串中的特殊字符
---@param s string @字符串
---@return result string
function CommonUtil.RemoveSpecialChars(s)
	if nil == s then
		return
	end

    local code_points = {}

    for _, v in utf8.codes(s) do
        -- print("RemoveSpecialChars:", v, string.format("%x", v), utf8.char(v))
		---Unicode编码参考（https://blog.csdn.net/hherima/article/details/9045765）
        if (v >= 0x0000 and v <= 0x007E) -- ASCII码
        or (v >= 0x00A0 and v <= 0x00BF) -- 某些特殊符号（比如 · ）
        or (v >= 0x00C0 and v <= 0x00FF) -- 德文的一些特殊字符（如ö、ü） 
        or (v >= 0x1100 and v <= 0x11FF) -- 朝鲜文
        or (v >= 0x2000 and v <= 0x206F and v ~= 0x200D) -- 常用标点(0x200D为ios表情链接)
		or (v >= 0x232B and v <= 0x2332) -- 道具特殊字符（详见T特殊字符表.xlsx）
        or (v >= 0x3000 and v <= 0x302F) -- CJK符号和标点
        or (v >= 0x3130 and v <= 0x318F) -- 朝鲜文兼容字母
		or (v >= 0x3040 and v <= 0x30FF) -- 日文
        or (v >= 0x4E00 and v <= 0x9FBF) -- 中文
        or (v >= 0xAC00 and v <= 0xD7AF) -- 朝鲜文音节
        or (v >= 0xFE30 and v <= 0xFE4F) -- CJK兼容
        or (v >= 0xFF00 and v <= 0xFFCF) -- 半角全角
        then
            table.insert(code_points, v)
        end
    end

    if not next(code_points) then
        return ""
    end

    return utf8.char(table.unpack(code_points))
end

---获取字符串长度
---非单字符算作2个单位的长度，比如一个汉字的长度为2个单位
---@param s string @字符串
---@return result number 
function CommonUtil.GetStrLen(s)
    local r = 0

    for v in string.gmatch(s, utf8.charpattern) do -- [\0-\x7F\xC2-\xFD][\x80-\xBF]*
        r = r + (#v == 1 and 1 or 2)
    end

    return r
end

-- helper function
local Posrelat = function (p, l)
	return p < 0 and (l + p + 1) or p
end

---获取指定位置的子字符串
---@param s string @字符串
---@param i number @起始位置
---@param j number @终点位置，默认为s的长度
---@return result string
function CommonUtil.SubStr(s, i, j)
    local l = CommonUtil.GetStrLen(s)

    i =       Posrelat(i, l)
    j = j and Posrelat(j, l) or l

    if i < 1 then i = 1 end
    if j > l then j = l end

    if i > j then return '' end

    l = 0
    local c = 0

    local i2, j2 = -1, -1

    for v in string.gmatch(s, utf8.charpattern) do  -- [\0-\x7F\xC2-\xFD][\x80-\xBF]*
        local cn = #v
        local u = cn == 1 and 1 or 2
        l = l + u

        if i2 < 0 and i <= l then
            i2 = c + 1
        end

        if j2 < 0 and j < l then
            j2 = c
            break
        end

        c = c + cn
    end

    return string.sub(s, i2, j2)
end

function CommonUtil.LoadJsonFile(path)
    local data = _G.UE.USaveMgr.LoadFileToString(path)
    if data == "" then
        return false
    end

    return Json.decode(data)
end

function CommonUtil.SaveJsonFile(path, data)
    local data = Json.encode(data)
    _G.UE.USaveMgr.SaveStringToFile(path, data)
end

function CommonUtil.DeleteFile(path)
    _G.UE.USaveMgr.DeleteFile(path)
end
-------------------------------------------------------------------------------------------------

local ULuaDelegateProxy = _G.UE.ULuaDelegateProxy
local ULuaDelegateMgr
local NewObject = _G.NewObject
local UnLuaRef = _G.UnLua.Ref

---获取传给C++ DynamicDelegate的DelegatePair
---@param InFunc function
---@param bIsLevelLife boolean 是否切关卡的时候强制销毁
function CommonUtil.GetDelegatePair(InFunc, bIsLevelLife)
	if type(InFunc) ~= "function" then
		return nil
	end
	if not ULuaDelegateMgr then
		ULuaDelegateMgr = _G.UE.ULuaDelegateMgr.Get()
	end

	local Proxy
	if bIsLevelLife then
		Proxy = ULuaDelegateMgr:NewLevelLifeDelegateProxy()
	else
		Proxy = NewObject(ULuaDelegateProxy)
	end
	local Ref = UnLuaRef(Proxy)

	local WrappedFunc = function(...)
		InFunc(...)
		Ref = nil
	end
	return { Proxy, WrappedFunc }
end

---获取传给C++ DynamicDelegate的DelegatePair
---@param SuccessCallBack function
function CommonUtil.GetCallbackDelegatePairs(SuccessCallBack)
	local Proxy = NewObject(ULuaDelegateProxy)
	local Ref =  UnLuaRef(Proxy)

	local SuccessDelegate = {
		Proxy,
		function(...)
			if type(SuccessCallBack) == "function" then
				SuccessCallBack(...)
			end
			Ref = nil
		end
	}

	return SuccessDelegate
end

local StaticBegin = _G.UE.FProfileTag.UnsafeStaticBegin
local StaticEnd = _G.UE.FProfileTag.UnsafeStaticEnd

local ProfileTag = {}
setmetatable(ProfileTag, {
	__close = StaticEnd
})

---利用Lua5.4 to-be-closed 的特性, 保证离开变量作用域后自动调用一次StaticEnd
---使用方式: 在合适的作用域 local _ <close> = CommonUtil.MakeProfileTag(Name)
---注意一定加上<close>, 不然没用
---@param Name string Tag的名字
---@return table
function CommonUtil.MakeProfileTag(Name)
	if not bIsShipping and Name then
		StaticBegin(Name)
		return ProfileTag
	end
end

function CommonUtil.ReviseRegexSpecialCharsPattern(str)
    return str:gsub("([%-%*%?%[%]%{%}%(%)%.%%%+%^%$])", "%%%1")
end

function CommonUtil.GetAppStartTime()
	return UCommonUtil.GetAppStartTime()
end

---ShouldDownloadRes             			@提审版本资源检查
function CommonUtil.ShouldDownloadRes()
	return _G.LoginMgr:IsModuleSwitchOn(ProtoRes.module_type.MODULE_VERIFY) and
		not _G.UE.UVersionMgr.Get():IsFullResDownloaded() and
		not CommonUtil.IsWithEditor()
end

---ShowResDownloadMsgBox             		@资源下载提示弹窗
function CommonUtil.ShowDownloadResMsgBox()
	local UVersionMgr = _G.UE.UVersionMgr:Get()
	local ExcludeCategories = _G.UE.TArray(_G.UE.FString)
	ExcludeCategories:Add("Movies")
	ExcludeCategories:Add("Languages")
	ExcludeCategories:Add("Voices")
	local TotalSize = UVersionMgr:GetPkgChunkers(_G.UE.EPkgPakCategoty.Outside, ExcludeCategories).TotalSize

	local MsgBoxUtil = require("Utils/MsgBoxUtil")
	local LSTR = _G.LSTR
	-- 10013-资源下载
	-- 10014-当前版本有%.2fGB的资源更新，需要重启游戏，下载全部资源后才能体验该内容（建议WIFI环境下更新）
	MsgBoxUtil.ShowMsgBoxTwoOp(nil, LSTR(10013), 
		string.format(LSTR(10014), TotalSize / 1024 / 1024 / 1024),
		function()
			local SaveKey = require("Define/SaveKey")
			_G.UE.USaveMgr.SetString(SaveKey.DownResDuringAuditing, UVersionMgr.GetAppVersion() .. ":true", false)
			CommonUtil.QuitGame()
		end, nil, LSTR(10003), LSTR(10002), nil)  -- 10002-确认, 10003-取消
end

function CommonUtil.GetStringByteCount(InString)
	return _G.UE.UCommonUtil.GetStringByteCount(InString)
end

function CommonUtil.GetBase64String(InString)
	return _G.UE.UCommonUtil.GetBase64String(InString)
end

function CommonUtil.DecodeBase64String(InString)
	return _G.UE.UCommonUtil.DecodeBase64String(InString)
end

function CommonUtil.GetMD5String(InString)
	return _G.UE.UCommonUtil.GetMD5String(InString)
end

function CommonUtil.GetUrlEncodeStr(Str)
	if string.isnilorempty(Str) then
		return ""
	end
	Str = string.gsub(Str, "([^%w%-%.%_%~])", function(Char)
		return string.format("%%%02X", string.byte(Char))
	end)
	return Str
end

function CommonUtil.SaveToGallery(SourcePath)
	FLOG_INFO("[CommonUtil.SaveToGallery] saving %s to gallery...", SourcePath)
	local PathMgr = require("Path/PathMgr")
	if CommonUtil.IsAndroidPlatform() then
		local RetCode = _G.UE.UMediaUtil.CheckStoragePermission()
		if RetCode == 0 then
			_G.UE.UMediaUtil.SaveImageToAndroidGallery(SourcePath)
			_G.MsgTipsUtil.ShowTipsByID(172022)
		elseif RetCode == ANDROID_NO_STORAGE_PERMISSION then
			-- 10068 申请存储权限以便正常使用游戏内截图功能
			_G.UIViewMgr:ShowView(_G.UIViewID.PermissionTips, {TipsStr = _G.LSTR(10068), SourcePath = SourcePath})
		end
	elseif CommonUtil.IsIOSPlatform() then
		_G.UE.UMediaUtil.SaveToIOSGallery(SourcePath, 172022, 0)
	end
end

------------------------------- TGPA相关功能接口 Begin-----------------------------------
function CommonUtil.StartTGPATaskCheck()
	if ENABLE_TGPA_TASK_CHECK and not CommonUtil.TGPATaskCheckTimeID then
		CommonUtil.TGPATaskCheckTimeID = _G.TimerMgr:AddTimer(nil, function()
			if CommonUtil.IsEnableTGPATask() then
				_G.UE.UGPMMgr.Get():UpdateGameInfoEx("Transceiver", "start")
			end
		end, 0, TGPA_TASK_CHECK_INTERVAL, 0)
	end
end

function CommonUtil.IsEnableTGPATask()
	return true
end

function CommonUtil.StopTGPATaskCheck()
	if ENABLE_TGPA_TASK_CHECK and CommonUtil.TGPATaskCheckTimeID then
		_G.UE.UGPMMgr.Get():UpdateGameInfoEx("Transceiver", "stop")
		_G.TimerMgr:CancelTimer(CommonUtil.TGPATaskCheckTimeID)
		CommonUtil.TGPATaskCheckTimeID = nil
	end
end

function CommonUtil.SetQuality()
	local QualityLevel = _G.SettingsMgr:GetCurQualityLevel()
	local TargetFrameRate = _G.SettingsMgr:GetIndexBySaveKey("MaxFPS", 2)
	local CombineQuality = TargetFrameRate * 10 + (QualityLevel + 1)
	FLOG_INFO("CommonUtil.SetQuality, TargetFrameRate:%d, QualityLevel:%d, CombineQuality:%d",
		TargetFrameRate, QualityLevel, CombineQuality)
	_G.UE.UGPMMgr.Get():SetQuality(CombineQuality)
end

function CommonUtil.ReportPerformanceMetricsData()
	--_G.UE.UGPMMgr.Get():SetEnableLog(true)
	--_G.UE.UGPMMgr.Get():SetThreadTidReportInterval(1.0)
	_G.UE.UGPMMgr.Get():ReportGameDataKeyS(GameDataKey.MainVersion, _G.UE.UVersionMgr.GetAppVersion())
	_G.UE.UGPMMgr.Get():ReportGameDataKeyS(GameDataKey.SubVersion, _G.UE.UVersionMgr.GetResourceVersion())
	--CommonUtil.ReportTargetFrameRate()
	CommonUtil.ReportSceneID(GameDataKey.ScenID.Login)
	--CommonUtil.SetTargetFrameRate(_G.SettingsMgr:GetValueForReport("MaxFPS"))
	CommonUtil.ReportQualityLevel()
	CommonUtil.ReportEffectQuality()
	CommonUtil.ReportScaleFactor()
	CommonUtil.ReportVisionPlayerNum()
	CommonUtil.ReportGameDataKeyAtFixedInterval()

	--_G.UE.UGPMMgr.Get():ReportGameDataKeyI(GameDataKey.SceneType, 0)
	--_G.UE.UGPMMgr.Get():ReportGameDataKeyI(GameDataKey.LightThreadTid, 0)
	--_G.UE.UGPMMgr.Get():ReportGameDataKeyI(GameDataKey.HeavyThreadTid, 0)
	CommonUtil.ReportAntiAliasingQuality()
	CommonUtil.ReportShadowQuality()
	--_G.UE.UGPMMgr.Get():ReportGameDataKeyI(GameDataKey.ResourceUpdateProgress, 0)
	--_G.UE.UGPMMgr.Get():ReportGameDataKeyS(GameDataKey.ResourceUpdateTitle, "")
	--_G.UE.UGPMMgr.Get():ReportGameDataKeyS(GameDataKey.ResourceUpdateIcon, "")
	CommonUtil.ReportTeamVoiceStatus()
	CommonUtil.ReportThreadTid()
end

function CommonUtil.ReportSceneID(SceneID)
	--FLOG_INFO("CommonUtil.ReportSceneID, SceneID:%d", SceneID)
	_G.UE.UGPMMgr.Get():ReportGameDataKeyI(GameDataKey.Scene, SceneID)
end

function CommonUtil.SetTargetFrameRate(MaxFPSIndex)
	_G.UE.UGPMMgr.Get():ReportGameDataKeyI(GameDataKey.FPSTarget, MaxFPSIndex)
end

function CommonUtil.ReportTargetFrameRate()
	local TargetFrameRate = _G.SettingsMgr:GetMaxFPSValue()
	_G.UE.UGPMMgr.Get():SetTargetFrameRate(TargetFrameRate)
	--FLOG_INFO("CommonUtil.ReportTargetFrameRate, TargetFrameRate:%d", TargetFrameRate)
	_G.UE.UGPMMgr.Get():ReportGameDataKeyI(GameDataKey.FPSTarget, TargetFrameRate)
end

function CommonUtil.ReportQualityLevel()
	local QualityLevel = _G.SettingsMgr:GetValueForReport("QualityLevel")
	--FLOG_INFO("CommonUtil.ReportQualityLevel, QualityLevel:%d", QualityLevel)
	_G.UE.UGPMMgr.Get():ReportGameDataKeyI(GameDataKey.PictureQuality, QualityLevel)
end

function CommonUtil.ReportEffectQuality()
	local EffectQuality = _G.SettingsMgr:GetValueForReport("EffectQuality")
	--FLOG_INFO("CommonUtil.ReportEffectQuality, EffectQuality:%d", EffectQuality)
	_G.UE.UGPMMgr.Get():ReportGameDataKeyI(GameDataKey.EffectQuality, EffectQuality)
end

function CommonUtil.ReportScaleFactor()
	local ScaleFactor = _G.SettingsMgr:GetValueForReport("ScaleFactor")
	--FLOG_INFO("CommonUtil.ReportScaleFactor, ScaleFactor:%d", ScaleFactor)
	_G.UE.UGPMMgr.Get():ReportGameDataKeyI(GameDataKey.Resolution, ScaleFactor)
end

function CommonUtil.ReportVisionPlayerNum()
	local VisionPlayerNum = _G.SettingsMgr:GetValueForReport("VisionPlayerNum")
	--FLOG_INFO("CommonUtil.ReportVisionPlayerNum, VisionPlayerNum:%d", VisionPlayerNum)
	_G.UE.UGPMMgr.Get():ReportGameDataKeyI(GameDataKey.RoleCount, VisionPlayerNum)
end

function CommonUtil.ReportAntiAliasingQuality()
	local AntiAliasingQuality = _G.SettingsMgr:GetValueForReport("AntiAliasingQuality")
	--FLOG_INFO("CommonUtil.ReportAntiAliasingQuality, AntiAliasingQuality:%d", AntiAliasingQuality)
	_G.UE.UGPMMgr.Get():ReportGameDataKeyI(GameDataKey.AntiAliasing, AntiAliasingQuality)
end

function CommonUtil.ReportShadowQuality()
	local ShadowQuality = _G.SettingsMgr:GetValueForReport("ShadowQuality")
	--FLOG_INFO("CommonUtil.ReportShadowQuality, ShadowQuality:%d", ShadowQuality)
	_G.UE.UGPMMgr.Get():ReportGameDataKeyI(GameDataKey.Shadow, ShadowQuality)
end

function CommonUtil.ReportThreadTid()
	local GameThreadID = _G.UE.UGPMMgr.Get():GetGameThreadID()
	local GameThreadTime = _G.UE.UGPMMgr.Get():GetGameThreadTime()
	local RenderThreadID = _G.UE.UGPMMgr.Get():GetRenderThreadID()
	local RenderThreadTime = _G.UE.UGPMMgr.Get():GetRenderThreadTime()
	local RHIThreadID = _G.UE.UGPMMgr.Get():GetRHIThreadID()
	local RHIThreadTime = _G.UE.UGPMMgr.Get():GetRHIThreadTime()
	-- local GPUFrameTime = _G.UE.UGPMMgr.Get():GetGPUFrameTime()
	-- FLOG_INFO("CommonUtil.ReportThreadTid, GameThreadID:%d, GameThreadTime:%d, RenderThreadID:%d, RenderThreadTime:%d, RHIThreadID:%d, RHIThreadTime:%d, GPUFrameTime:%d",
	-- 	GameThreadID, GameThreadTime, RenderThreadID, RenderThreadTime, RHIThreadID, RHIThreadTime, GPUFrameTime)

	local LightThreadTid = GameThreadID
	local MinTime = GameThreadTime
	local HeavyThreadTid = RenderThreadID
	local MaxTime = RenderThreadTime

	if GameThreadTime >= RenderThreadTime then
		LightThreadTid = RenderThreadID
		MinTime = RenderThreadTime
		HeavyThreadTid = GameThreadID
		MaxTime = GameThreadTime
	end

	if RHIThreadID ~= 0 then
		if RHIThreadTime > MaxTime then
			HeavyThreadTid = RHIThreadID
		end
		if RHIThreadTime < MinTime then
			LightThreadTid = RHIThreadID
		end
	end

	--FLOG_INFO("CommonUtil.ReportThreadTid, LightThreadTid:%d, HeavyThreadTid:%d", LightThreadTid, HeavyThreadTid)
	_G.UE.UGPMMgr.Get():ReportGameDataKeyI(GameDataKey.LightThreadTid, LightThreadTid)
	_G.UE.UGPMMgr.Get():ReportGameDataKeyI(GameDataKey.HeavyThreadTid, HeavyThreadTid)
end

function CommonUtil.ReportGameDataKeyAtFixedInterval()
	--local ServerIP = _G.LoginMgr:GetServerUrl()
	--_G.UE.UGPMMgr.Get():ReportGameDataKeyS(GameDataKey.ServerIP, ServerIP)

	if ENABLE_TGPA_GAME_DATA_REPORT and not CommonUtil.TGPAGameDataReportTimerID then
		CommonUtil.TGPAGameDataReportTimerID = _G.TimerMgr:AddTimer(nil, function()
			local Rtt = _G.NetworkRTTMgr:GetSRTT()
			_G.UE.UGPMMgr.Get():ReportGameDataKeyI(GameDataKey.NetDelay, Rtt)
			local NetworkConnectionType = tostring(CommonUtil.GetNetworkConnectionType())
			_G.UE.UGPMMgr.Get():ReportGameDataKeyS(GameDataKey.NetworkType, NetworkConnectionType)
			--FLOG_INFO("CommonUtil.ReportGameDataKeyAtFixedInterval, Rtt:%d, ServerIP:%s, NetworkConnectionType:%s", Rtt, ServerIP, NetworkConnectionType)
			--CommonUtil.ReportThreadTid()
		end, 0, TGPA_GAME_DATA_REPORT_INTERVAL, 0)
	end
end

function CommonUtil.StopReportNetworkRTT()
	if ENABLE_TGPA_GAME_DATA_REPORT and CommonUtil.TGPAGameDataReportTimerID then
		_G.TimerMgr:CancelTimer(CommonUtil.TGPAGameDataReportTimerID)
		CommonUtil.TGPAGameDataReportTimerID = nil
	end
end

function CommonUtil.ReportTeamVoiceStatus()
	local Status = _G.TeamVoiceMgr:IsCurMicOn()
	Status = Status and 1 or 0
	--FLOG_INFO("CommonUtil.ReportTeamVoiceStatus, Status:%d", Status)
	_G.UE.UGPMMgr.Get():ReportGameDataKeyI(GameDataKey.Voice, Status)
end
------------------------------- TGPA相关功能接口 End-----------------------------------

return CommonUtil