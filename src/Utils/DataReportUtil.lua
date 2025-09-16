local TimeUtil = require("Utils/TimeUtil")
local CommonUtil = require("Utils/CommonUtil")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local Json = require("Core/Json")
local MSDKDefine = require("Define/MSDKDefine")

local DataReportUtil = {}

DataReportUtil.ReportInterval = 500  --毫秒

DataReportUtil.LastReportTime = 0

DataReportUtil.ASAAdInfoUrlTest = "http://119.147.3.250:31010/rpc.fgame.profile.Forward/ForwardEvent"
DataReportUtil.ASAAdInfoUrl = "https://profile.fmgame.qq.com:30443/rpc.fgame.profile.Forward/ForwardEvent"
DataReportUtil.IPCheckUrl = "https://api64.ipify.org?format=json"
DataReportUtil.IPCheckUrlList = {
	"https://ipinfo.io/json",
	"https://httpbin.org/ip"
}

DataReportUtil.IsIPAddressInfoInited = false
DataReportUtil.IPV4Address = ""
DataReportUtil.IPV6Address = ""

local CommonStringDataCache

function DataReportUtil.GetIPAddressInfo()
	if not DataReportUtil.IsIPAddressInfoInited then
		local IPAddressList = _G.UE.UPlatformUtil.GetIPAddressList(false)
		local LocalPattern = "^192%.168%.%d+%.%d+$"
		local IPV4Pattern = "^%d+%.%d+%.%d+%.%d+$"
		local IPV6Pattern = "^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$"
		for Index = 1, IPAddressList:Length() do
			local IPAddress = IPAddressList:GetRef(Index)
			if not string.isnilorempty(IPAddress) then
				if string.match(IPAddress, IPV4Pattern) and
					not string.match(IPAddress, LocalPattern) then
					DataReportUtil.IPV4Address = IPAddress
				end

				if string.match(IPAddress, IPV6Pattern) then
					DataReportUtil.IPV6Address = IPAddress
				end
			end
		end
		if DataReportUtil.IPV4Address ~= "" or DataReportUtil.IPV4Address ~= "" then
			DataReportUtil.IsIPAddressInfoInited = true
		end
	end
end

function DataReportUtil.SendPublicIPAddressInfoRequest()
	--if not DataReportUtil.IsIPAddressInfoInited then
		-- if _G.HttpMgr:Get(DataReportUtil.IPCheckUrl, "", "", DataReportUtil.SendPublicIPAddressInfoRequestCallback, DataReportUtil, false) then
		-- 	_G.FLOG_INFO("DataReportUtil.SendPublicIPAddressInfoRequest success")
		-- end
		for _, Url in ipairs(DataReportUtil.IPCheckUrlList) do
			if _G.HttpMgr:Get(Url, "", "", DataReportUtil.SendPublicIPAddressInfoRequestCallback, DataReportUtil, false) then
				_G.FLOG_INFO("DataReportUtil.SendPublicIPAddressInfoRequest success, url: %s", Url)
			end
		end
	--end
end

function DataReportUtil.SendPublicIPAddressInfoRequestCallback(MsgBody, Result)
    _G.FLOG_INFO("DataReportUtil.SendPublicIPAddressInfoRequestCallback, Result: %s", tostring(Result))
	local IPAddressInfoStr = tostring(Result)
	if not string.isnilorempty(IPAddressInfoStr) then
		local IPAddressInfo = Json.decode(IPAddressInfoStr)
		if nil ~= IPAddressInfo then
			local IPAddress = ""

			if not string.isnilorempty(IPAddressInfo.ip) then
				IPAddress = IPAddressInfo.ip
			elseif not string.isnilorempty(IPAddressInfo.origin) then
				IPAddress = IPAddressInfo.origin
			end
			local LocalPattern = "^192%.168%.%d+%.%d+$"
			local IPV4Pattern = "^%d+%.%d+%.%d+%.%d+$"
			--local IPV6Pattern = "^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$"
			if string.match(IPAddress, IPV4Pattern) and not string.match(IPAddress, LocalPattern) then
				DataReportUtil.IPV4Address = IPAddress
			end
			if string.find(IPAddress, ":") then
				DataReportUtil.IPV6Address = IPAddress
			end
			if DataReportUtil.IPV6Address == "" then
				DataReportUtil.IPV6Address = DataReportUtil.IPV4Address
			end
		else
			_G.FLOG_WARNING("DataReportUtil.SendPublicIPAddressInfoRequestCallback, failed to get public IP address info!")
		end
	else
		_G.FLOG_WARNING("DataReportUtil.SendPublicIPAddressInfoRequestCallback, Result is empty.")
	end

	_G.FLOG_INFO("DataReportUtil.SendPublicIPAddressInfoRequestCallback, IPV4Address: %s, IPV6Address: %s",
		DataReportUtil.IPV4Address, DataReportUtil.IPV6Address)
	-- if DataReportUtil.IPV4Address ~= "" then
	-- 	DataReportUtil.IsIPAddressInfoInited = true
	-- end
end

function DataReportUtil.InitBaseReportData()
	if nil == DataReportUtil.TGLogBaseReportData then
		DataReportUtil.TGLogBaseReportData = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	else
		DataReportUtil.TGLogBaseReportData:Clear()
	end
	local Platform = CommonUtil.GetPlatformName()
	local WorldID = _G.LoginMgr:GetWorldID()
	local OpenID = _G.LoginMgr:GetOpenID()
	DataReportUtil.TGLogBaseReportData:Add("GameSvrId", "")
	--local GameAppId = _G.UE.UTDMMgr.Get():GetGameAppId()
	if _G.LoginMgr:IsQQLogin() then
		DataReportUtil.TGLogBaseReportData:Add("GameAppId", MSDKDefine.Config.QQAPPID)
	elseif _G.LoginMgr:IsWeChatLogin() then
		DataReportUtil.TGLogBaseReportData:Add("GameAppId", MSDKDefine.Config.WechatAppID)
	else
		DataReportUtil.TGLogBaseReportData:Add("GameAppId", "")
	end
	if Platform == "Android" then
		DataReportUtil.TGLogBaseReportData:Add("PlatID", "1")
	elseif Platform == "IOS" then
		DataReportUtil.TGLogBaseReportData:Add("PlatID", "0")
	end
	DataReportUtil.TGLogBaseReportData:Add("WorldID", tostring(WorldID))
	DataReportUtil.TGLogBaseReportData:Add("OpenID", tostring(OpenID))


	if nil == DataReportUtil.DeviceTGLogReportData then
		DataReportUtil.DeviceTGLogReportData = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	else
		DataReportUtil.DeviceTGLogReportData:Clear()
	end
	local AndroidOAID = ""
	local IosCAID = ""
	if Platform == "Android" then
		AndroidOAID = _G.UE.UTDMMgr.Get():GetDeviceInfo("OAID")
	elseif Platform == "IOS" then
		IosCAID = _G.UE.UTDMMgr.Get():GetDeviceInfo("CAID")
	end
	DataReportUtil.DeviceTGLogReportData:Add("TelecomOper", "")  -- 获取不到(GCloud和MSDK均无此功能)
	local DeviceId = _G.UE.UPlatformUtil.GetDeviceId()
	DataReportUtil.DeviceTGLogReportData:Add("DeviceId", DeviceId)
	--DataReportUtil.GetIPAddressInfo()
	DataReportUtil.DeviceTGLogReportData:Add("ClientIP", DataReportUtil.IPV4Address)
	DataReportUtil.DeviceTGLogReportData:Add("ClientIPV6", DataReportUtil.IPV6Address)
	DataReportUtil.DeviceTGLogReportData:Add("ANDROID_OAID", AndroidOAID)
	DataReportUtil.DeviceTGLogReportData:Add("IOS_CAID", IosCAID)
	local IsWithEmulatorMode = _G.UE.UUIMgr.Get():IsWithEmulator()
	if IsWithEmulatorMode then
		DataReportUtil.DeviceTGLogReportData:Add("IsSimulator", "1")
	else
		DataReportUtil.DeviceTGLogReportData:Add("IsSimulator", "0")
	end

	--选填
	local AppVersion = _G.UE.UVersionMgr.GetAppVersion()
	DataReportUtil.DeviceTGLogReportData:Add("ClientVersion", AppVersion)
	local OSVersion = _G.UE.UPlatformUtil.GetOSVersion()
	DataReportUtil.DeviceTGLogReportData:Add("SystemSoftware", OSVersion)
	local DeviceName = _G.UE.UPlatformUtil.GetDeviceName()
	DataReportUtil.DeviceTGLogReportData:Add("SystemHardware", DeviceName)
	local NetworkType = CommonUtil.GetNetworkConnectionType()
	DataReportUtil.DeviceTGLogReportData:Add("Network", NetworkType)
	local ViewportSize = UIUtil.GetViewportSize()
	DataReportUtil.DeviceTGLogReportData:Add("ScreenWidth", tostring(ViewportSize.X))
	DataReportUtil.DeviceTGLogReportData:Add("ScreenHight", tostring(ViewportSize.Y))
	DataReportUtil.DeviceTGLogReportData:Add("Density", "")
	local DeviceMakeAndModel = _G.UE.UPlatformUtil.GetDeviceMakeAndModel()
	DataReportUtil.DeviceTGLogReportData:Add("CpuHardware", DeviceMakeAndModel)
	local TotalMemory = _G.UE.UPlatformUtil.GetAvailablePhysicalMemory() + _G.UE.UPlatformUtil.GetUsedPhysicalMemory()
	DataReportUtil.DeviceTGLogReportData:Add("Memory", tostring(TotalMemory))
	DataReportUtil.DeviceTGLogReportData:Add("GLRender", "")
	DataReportUtil.DeviceTGLogReportData:Add("GLVersion", "")
	DataReportUtil.DeviceTGLogReportData:Add("IsGamematrix", "")


	if nil == DataReportUtil.RoleBaseReportData then
		DataReportUtil.RoleBaseReportData = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	else
		DataReportUtil.RoleBaseReportData:Clear()
	end
	local AttributeComponent = MajorUtil.GetMajorAttributeComponent()
	if nil ~= AttributeComponent then
		DataReportUtil.RoleBaseReportData:Add("RoleID", tostring(AttributeComponent.RoleID))
		DataReportUtil.RoleBaseReportData:Add("RoleName", AttributeComponent.ActorName)
		DataReportUtil.RoleBaseReportData:Add("Level", tostring(AttributeComponent.Level))
		DataReportUtil.RoleBaseReportData:Add("ProfID", tostring(AttributeComponent.ProfID))
		DataReportUtil.RoleBaseReportData:Add("Gender", tostring(AttributeComponent.Gender))
		DataReportUtil.RoleBaseReportData:Add("Race", tostring(AttributeComponent.RaceID))
		DataReportUtil.RoleBaseReportData:Add("Branch", tostring(AttributeComponent.TribeID))
	else
		DataReportUtil.RoleBaseReportData:Add("RoleID", "")
		DataReportUtil.RoleBaseReportData:Add("RoleName", "")
		DataReportUtil.RoleBaseReportData:Add("Level", "")
		DataReportUtil.RoleBaseReportData:Add("ProfID", "")
		DataReportUtil.RoleBaseReportData:Add("Gender", "")
		DataReportUtil.RoleBaseReportData:Add("Race", "")
		DataReportUtil.RoleBaseReportData:Add("Branch", "")
	end
	--选填
	DataReportUtil.RoleBaseReportData:Add("VipLevel", "")
end

function DataReportUtil.InsertBaseReportData(ReportData, IsNeedTGLogBase, IsNeedDeviceBase, IsNeedRoleBase)
	DataReportUtil.InitBaseReportData()
	if nil ~= IsNeedTGLogBase and IsNeedTGLogBase == true and nil ~= DataReportUtil.TGLogBaseReportData then
		for Key, Value in pairs(DataReportUtil.TGLogBaseReportData) do
			ReportData:Add(Key, Value)
		end
	end

	if nil ~= IsNeedDeviceBase and IsNeedDeviceBase == true and nil ~= DataReportUtil.DeviceTGLogReportData then
		for Key, Value in pairs(DataReportUtil.DeviceTGLogReportData) do
			ReportData:Add(Key, Value)
		end
	end

	if nil ~= IsNeedRoleBase and IsNeedRoleBase == true and nil ~= DataReportUtil.RoleBaseReportData then
		for Key, Value in pairs(DataReportUtil.RoleBaseReportData) do
			ReportData:Add(Key, Value)
		end
	end
end

---InsertCommonStringData
---@param Arg1 string 自定义数据
---@param Arg2 string 自定义数据
---@param Arg3 string 自定义数据
---@param Arg4 string 自定义数据
---@param Arg5 string 自定义数据
---@param Arg6 string 自定义数据
function DataReportUtil.InsertCommonStringData(Datas, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6)
	Datas:Add("Arg1", Arg1 or "")
	Datas:Add("Arg2", Arg2 or "")
	Datas:Add("Arg3", Arg3 or "")
	Datas:Add("Arg4", Arg4 or "")
	Datas:Add("Arg5", Arg5 or "")
	Datas:Add("Arg6", Arg6 or "")
end

function DataReportUtil.SendASAAdInfo(ASAAdInfo)
	local Token = _G.LoginMgr:GetToken()
	local Os
	if CommonUtil.IsAndroidPlatform() then
		Os = "1"
	elseif CommonUtil.IsIOSPlatform() then
		Os = "2"
	else
		Os = "5"
	end
	--local BytesBody = string.pack("s", ASAAdInfo)
	local SendData = {}
	local ChannelId = _G.LoginMgr:GetChannelID()
	if ChannelId == "10" then
		ChannelId = "101"
	end
	SendData.Login = {
		ChannelID = ChannelId,
		Os = Os,
		OpenID = tostring(_G.LoginMgr:GetOpenID()),
		Token = Token,
		WorldID = tostring(_G.LoginMgr:GetWorldID()),
	}
	SendData.Cmd = 1
	SendData.Body = ASAAdInfo

	local SendDataStr = Json.encode(SendData)
	local Url = DataReportUtil.ASAAdInfoUrl
	if not CommonUtil.IsShipping() then
        Url = DataReportUtil.ASAAdInfoUrlTest
    end
	_G.FLOG_INFO("DataReportUtil.SendASAAdInfo, url:%s, SendDataStr:%s", Url, SendDataStr)
	if _G.HttpMgr:Post(Url, Token, SendDataStr, DataReportUtil.SendASAAdInfoCallback, DataReportUtil) then
        _G.FLOG_INFO("DataReportUtil.SendASAAdInfo success")
    end
end

function DataReportUtil.SendASAAdInfoCallback(MsgBody, Result)
    _G.FLOG_INFO("DataReportUtil.SendASAAdInfoCallback, result: %s", tostring(Result))
end

function DataReportUtil.GetCommonStringData()
	if not CommonStringDataCache then
		CommonStringDataCache = _G.UE.FCommonStringData()
	end
	CommonStringDataCache.ArgName1 = ""
	CommonStringDataCache.ArgName2 = ""
	CommonStringDataCache.ArgName3 = ""
	CommonStringDataCache.ArgName4 = ""
	CommonStringDataCache.ArgName5 = ""
	CommonStringDataCache.ArgName6 = ""
	CommonStringDataCache.Arg1 = ""
	CommonStringDataCache.Arg2 = ""
	CommonStringDataCache.Arg3 = ""
	CommonStringDataCache.Arg4 = ""
	CommonStringDataCache.Arg5 = ""
	CommonStringDataCache.Arg6 = ""
	return CommonStringDataCache
end

---ReportData
---@param EventName string 日志英文名
---@param IsNeedTGLogBase bool 是否需要TgLogBaseInfo
---@param IsNeedDeviceBase bool 是否需要DeviceTgLogInfo
---@param IsNeedRoleBase bool 是否需要RoleBaseInfo
---@param ... string 必须成对出现的可变参数（字段名称1, 值1, 字段名称2, 值2, 字段名称3, 值3, 字段名称4, 值4, ...）
function DataReportUtil.ReportData(EventName, IsNeedTGLogBase, IsNeedDeviceBase, IsNeedRoleBase, ...)
	local StringMap = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	DataReportUtil.InsertBaseReportData(StringMap, IsNeedTGLogBase, IsNeedDeviceBase, IsNeedRoleBase)
	local KeyName = ""
	for i, Arg in ipairs({...}) do
        if i % 2 == 1 then
			if not string.isnilorempty(Arg) then
				KeyName = Arg
			end
		else
			if KeyName ~= "" and nil ~= Arg then
				StringMap:Add(KeyName, Arg)
			end
			KeyName = ""
        end
    end

	--_G.UE.UTDMMgr.Get():SetEnableLog(true)
	_G.UE.UDataReportUtil.ReportKVData(EventName, StringMap)
end

---ReportButtonClickData
---@param ButtonTypes string
---@param Reasons string
---@param UserDataInt1 number 自定义数据
---@param UserDataInt2 number 自定义数据
---@param UserDataInt3 number 自定义数据
---@param UserDataInt4 number 自定义数据
---@param UserDataStr1 string 自定义数据
---@param UserDataStr2 string 自定义数据
---@param UserDataStr3 string 自定义数据
---@param UserDataStr4 string 自定义数据
function DataReportUtil.ReportButtonClickData(ButtonTypes, Reasons,
	UserDataInt1, UserDataInt2, UserDataInt3, UserDataInt4,
	UserDataStr1, UserDataStr2, UserDataStr3, UserDataStr4)
	local CurServerTime = TimeUtil.GetServerTimeMS()
	if (CurServerTime - DataReportUtil.LastReportTime) < DataReportUtil.ReportInterval then
		return
	end
	DataReportUtil.LastReportTime = CurServerTime

	local StringMap = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	DataReportUtil.InsertBaseReportData(StringMap, true)
	local MajorRoleID = MajorUtil.GetMajorRoleID()
	StringMap:Add("vRoleID", tostring(MajorRoleID))
	StringMap:Add("ButtonTypes", ButtonTypes or "")
	StringMap:Add("iReasons", Reasons or "")
	--非必填项
	StringMap:Add("UserDataInt1", nil == UserDataInt1 and "" or tostring(UserDataInt1))
	StringMap:Add("UserDataInt2", nil == UserDataInt2 and "" or tostring(UserDataInt2))
	StringMap:Add("UserDataInt3", nil == UserDataInt3 and "" or tostring(UserDataInt3))
	StringMap:Add("UserDataInt4", nil == UserDataInt4 and "" or tostring(UserDataInt4))
	StringMap:Add("UserDataStr1", UserDataStr1 or "")
	StringMap:Add("UserDataStr2", UserDataStr2 or "")
	StringMap:Add("UserDataStr3", UserDataStr3 or "")
	StringMap:Add("UserDataStr4", UserDataStr4 or "")
	StringMap:Add("ClientVersion", _G.UE.UVersionMgr.GetAppVersion())
	StringMap:Add("DeviceClientVersion", _G.UE.UPlatformUtil.GetOSVersion())

	_G.UE.UDataReportUtil.ReportKVData("ButtonClick", StringMap)
end

---ReportSystemFlowData
---@param Eventname string
---@param Type string
---@param Arg1 string 自定义数据
---@param Arg2 string 自定义数据
---@param Arg3 string 自定义数据
---@param Arg4 string 自定义数据
---@param Arg5 string 自定义数据
---@param Arg6 string 自定义数据
function DataReportUtil.ReportSystemFlowData(Eventname, Type,
	Arg1, Arg2, Arg3, Arg4, Arg5, Arg6)
	local StringMap = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	DataReportUtil.InsertBaseReportData(StringMap, true, false, true)
	StringMap:Add("Type", Type or "")
	DataReportUtil.InsertCommonStringData(StringMap, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6)

	_G.UE.UDataReportUtil.ReportKVData(Eventname, StringMap)
end

function DataReportUtil.ReportHotelData(Eventname, Type,
	Arg1, Arg2, Arg3, Arg4, Arg5, Arg6)
	local StringMap = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	DataReportUtil.InsertBaseReportData(StringMap, true, false, true)
	StringMap:Add("HotelType", Type or "")
	DataReportUtil.InsertCommonStringData(StringMap, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6)

	_G.UE.UDataReportUtil.ReportKVData(Eventname, StringMap)
end

---ReportRecommendTaskData
---@param Eventname string
---@param Type string
---@param Arg1 string 自定义数据
---@param Arg2 string 自定义数据
---@param Arg3 string 自定义数据
---@param Arg4 string 自定义数据
---@param Arg5 string 自定义数据
---@param Arg6 string 自定义数据
function DataReportUtil.ReportRecommendTaskData(Eventname, Type,
	Arg1, Arg2, Arg3, Arg4, Arg5, Arg6)
	local StringMap = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	DataReportUtil.InsertBaseReportData(StringMap, true, false, true)
	StringMap:Add("ReTasksType", Type or "")
	DataReportUtil.InsertCommonStringData(StringMap, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6)

	_G.UE.UDataReportUtil.ReportKVData(Eventname, StringMap)
end

---ReportFirstChargeData
---@param Eventname string
---@param ActivityID string
---@param Type string
---@param Arg1 string 自定义数据
---@param Arg2 string 自定义数据
---@param Arg3 string 自定义数据
---@param Arg4 string 自定义数据
---@param Arg5 string 自定义数据
---@param Arg6 string 自定义数据
function DataReportUtil.ReportFirstChargeData(Eventname, ActivityID, Type,
	Arg1, Arg2, Arg3, Arg4, Arg5, Arg6)
	local StringMap = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	DataReportUtil.InsertBaseReportData(StringMap, true, false, true)
	StringMap:Add("ActivityID", ActivityID or "")
	StringMap:Add("OperationPageActionType", Type or "")
	DataReportUtil.InsertCommonStringData(StringMap, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6)

	_G.UE.UDataReportUtil.ReportKVData(Eventname, StringMap)
end

---ReportBattlePassData
---@param Eventname string
---@param ActivityID string
---@param Type string
---@param Arg1 string 自定义数据
---@param Arg2 string 自定义数据
---@param Arg3 string 自定义数据
---@param Arg4 string 自定义数据
---@param Arg5 string 自定义数据
---@param Arg6 string 自定义数据
function DataReportUtil.ReportBattlePassData(ScanDest,
	Arg1, Arg2, Arg3, Arg4, Arg5, Arg6)
	local StringMap = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	DataReportUtil.InsertBaseReportData(StringMap, true, false, true)
	StringMap:Add("ScanDest", ScanDest or "")
	DataReportUtil.InsertCommonStringData(StringMap, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6)

	_G.UE.UDataReportUtil.ReportKVData("SeasonPassScanFlow", StringMap)
end

--ReportTutorialData
---@param ID string 引导组ID
---@param Finish string 是否完成(0-非正常完成 1-完成)
function DataReportUtil.ReportTutorialData(ID, Finish, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6)
	local StringMap = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	DataReportUtil.InsertBaseReportData(StringMap, true, false, true)
	StringMap:Add("GuideID", ID or "")
	StringMap:Add("isFinish", Finish or "")
	DataReportUtil.InsertCommonStringData(StringMap, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6)

	_G.UE.UDataReportUtil.ReportKVData("GuideSystemFlow", StringMap)
end

--ReportTutorialGuideData
---@param ID string 指南ID
function DataReportUtil.ReportTutorialGuideData(ID, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6)
	local StringMap = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	DataReportUtil.InsertBaseReportData(StringMap, true, false, true)
	StringMap:Add("GuideID", ID or "")
	DataReportUtil.InsertCommonStringData(StringMap, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6)

	_G.UE.UDataReportUtil.ReportKVData("GuideCheckFlow", StringMap)
end

---ReportButtonClickData
---@param Optype string 操作类型 1-进入理发屋，2-退出理发屋
---@param OpTime string 操作时长-退出理发屋时上报停留时长，单位：秒
---@param IsHairSalon string 是否理发-退出理发屋时上报用户是否进行了对应行为
---@param Arg1 string 自定义数据-原发型ID
---@param Arg2 string 自定义数据-原发性颜色ID
---@param Arg3 string 自定义数据-新发型ID
---@param Arg4 string 自定义数据-新发型颜色ID
---@param Arg5 string 自定义数据
---@param Arg6 string 自定义数据
function DataReportUtil.ReportHairSalonData(Optype, OpTime, IsHairSalon,
	Arg1, Arg2, Arg3, Arg4, Arg5, Arg6)
	local StringMap = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	DataReportUtil.InsertBaseReportData(StringMap, true, false, true)
	StringMap:Add("Optype", Optype or "")
	StringMap:Add("OpTime", OpTime or "")
	StringMap:Add("IsHairSalon", IsHairSalon or "")
	DataReportUtil.InsertCommonStringData(StringMap, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6)

	_G.UE.UDataReportUtil.ReportKVData("HairSalonInfo", StringMap)
end

---@type 拼装剪影数据上报
---@param Time number 用时
function DataReportUtil.ReportGunbreakerFlowData(Time, GameID, EndType)
	local StringMap = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	DataReportUtil.InsertBaseReportData(StringMap, true, false, true)
	StringMap:Add("Time", tostring(Time))
	StringMap:Add("GameID", tostring(GameID))
	StringMap:Add("GameType", tostring(EndType))

	_G.UE.UDataReportUtil.ReportKVData("GunbreakerFlow", StringMap)
end

--- 界面进入金碟游乐场上报
function DataReportUtil.ReportEnterEntertainSceneByUI()
	local StringMap = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	StringMap:Add("EntertainID", "32")
	StringMap:Add("Type", "")

	DataReportUtil.InsertCommonStringData(StringMap)

	_G.UE.UDataReportUtil.ReportKVData("EntertainPlayerInfo", StringMap)
end

---@type 生产职业技能流水
---@param SkillStat string 技能使用情况
function DataReportUtil.ReportProductionSkillFlowData(SkillStat)
	local StringMap = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	DataReportUtil.InsertBaseReportData(StringMap, true, false, true)
	StringMap:Add("SkillStat", SkillStat)

	_G.UE.UDataReportUtil.ReportKVData("ProductionSkillFlow", StringMap)
end

--- 宠物流水上报
function DataReportUtil.ReportCompanionData(EventName, Type, Arg1, Arg2)
	local StringMap = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	StringMap:Add("EntertainID", "116")
	StringMap:Add("Type", Type or "")
	DataReportUtil.InsertCommonStringData(StringMap, Arg1, Arg2)

	_G.UE.UDataReportUtil.ReportKVData(EventName, StringMap)
end

function DataReportUtil.ReportMountInterfaceFlowData(EventName, Type, MountID)
	local StringMap = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	DataReportUtil.InsertBaseReportData(StringMap, true, false, true)
	StringMap:Add("Type", tostring(Type))
	StringMap:Add("MountID", tostring(MountID))
	_G.UE.UDataReportUtil.ReportKVData(EventName, StringMap)
end

function DataReportUtil.ReportSequenceFlowData(Route, TP, iSSkip)
	local StringMap = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	DataReportUtil.InsertBaseReportData(StringMap, true, false, true)
	StringMap:Add("Route", tostring(Route))
	StringMap:Add("TP", tostring(TP))
	StringMap:Add("iSSkip", tostring(iSSkip))
	_G.UE.UDataReportUtil.ReportKVData("SkipDramaFlow", StringMap)
end

function DataReportUtil.ReportQuestRecieveFlowData(QuestID, RecieveType)
	local StringMap = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	DataReportUtil.InsertBaseReportData(StringMap, true, false, true)
	StringMap:Add("QuestID", tostring(QuestID))
	StringMap:Add("RecieveType", tostring(RecieveType))
	_G.UE.UDataReportUtil.ReportKVData("QuestRecieveFlow", StringMap)
end

-- 登录流程
function DataReportUtil.ReportLoginFlowData(PhaseId)
	local StringMap = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	DataReportUtil.InsertBaseReportData(StringMap, true, false, false)

	StringMap:Add("Type", tostring(PhaseId))
	StringMap:Add("Arg1", _G.UE.UPlatformUtil.GetDeviceName())
	StringMap:Add("Arg2", _G.LoginMgr:GetOpenID() or "")
	StringMap:Add("Arg3", tostring(CommonUtil.GetAppStartTime()))
	StringMap:Add("Arg5", tostring(_G.UE.UVersionMgr.GetResourceVersion()))
	StringMap:Add("InstallChannel", tostring(_G.LoginMgr:GetInstallChannel()))
	StringMap:Add("LoginChannel", _G.LoginMgr.ChannelID or "")

	_G.UE.UDataReportUtil.ReportKVData("LoginAndCreateRole", StringMap)
end

-- 创角流程
function DataReportUtil.ReportLoginCreateData(Type, Arg1, Arg2, Arg3, Arg4)
	local StringMap = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	DataReportUtil.InsertBaseReportData(StringMap, true, true, true)

	StringMap:Add("Type", Type or "")

	StringMap:Add("Arg1", Arg1 or "")
	StringMap:Add("Arg2", Arg2 or "")
	StringMap:Add("Arg3", Arg3 or "")
	StringMap:Add("Arg4", Arg4 or "")
	StringMap:Add("Arg5", tostring(_G.UE.UVersionMgr.GetResourceVersion()))
	StringMap:Add("InstallChannel", tostring(_G.LoginMgr:GetInstallChannel()))
	StringMap:Add("LoginChannel", _G.LoginMgr.ChannelID or "")

	_G.UE.UDataReportUtil.ReportKVData("LoginAndCreateRole", StringMap)
end

--- 授权
---@param PlayerInfoState boolean 个人信息是否已授权
---@param PlayerInfoState boolean 好友链是否已授权
function DataReportUtil.ReportAuthFlowData(AllState, PlayerInfoState, FriendState)
	local StringMap = _G.UE.TMap(_G.UE.FString, _G.UE.FString)

	local AuthState = ""
	if AllState == nil then
		AuthState = AllState and "{\"1\":1}" or "{\"1\":0}"
	else
		local playerInfoValue = PlayerInfoState and 1 or 0
		local friendValue = FriendState and 1 or 0
		AuthState = string.format("{\"2\":%d, \"3\":%d}", playerInfoValue, friendValue)
	end
	StringMap:Add("platformusertag", AuthState)

	_G.UE.UDataReportUtil.ReportKVData("playerusertagchg", StringMap)
end

--- 授权
---@param PlayerInfoState boolean 个人信息是否已授权
---@param PlayerInfoState boolean 好友链是否已授权
function DataReportUtil.ReportPlayerLoginForUA(PlayerInfoState, FriendState)
	local StringMap = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	local Platform = CommonUtil.GetPlatformName()
	local OldCAID = ""
	local UserAgent = ""
	DataReportUtil.InsertBaseReportData(StringMap, true, true, true)

	StringMap:Add("PlayerFriendsNum", "0")
	StringMap:Add("LoginChannel", tostring(_G.LoginMgr:GetInstallChannel()))
	StringMap:Add("vGameAppid", _G.LoginMgr.ChannelID or "")
	StringMap:Add("HeaderID", "0")
	StringMap:Add("Equipmentgrade", "0")
	StringMap:Add("CountryRe", "cn")
	StringMap:Add("CountryLogin", "cn")

	local CurCultureName = CommonUtil.GetCurrentCultureName()
	if string.isnilorempty(CurCultureName) then
		CurCultureName = "zh"
	end
	StringMap:Add("Language", CurCultureName)

	if Platform == "Android" then
		--AndroidOAID = _G.UE.UTDMMgr.Get():GetDeviceInfo("OAID")
	elseif Platform == "IOS" then
		OldCAID = _G.UE.UGPMMgr.Get():GetDataFromTGPA("DeviceToken", "PreVersion")
		--IosCAID = _G.UE.UTDMMgr.Get():GetDeviceInfo("CAID")
		UserAgent = _G.UE.UTDMMgr.Get():GetDeviceInfo("UserAgent")
	end
	StringMap:Add("OldCAID", OldCAID)
	StringMap:Add("UserAgent", UserAgent)

	local AuthState = ""
	if PlayerInfoState and FriendState then
		if PlayerInfoState == true and FriendState == true then
			AuthState = "{\"1\":1} "
		elseif PlayerInfoState == false and FriendState == false then
			AuthState = "{\"1\":0} "
		else
			if PlayerInfoState == true then
				AuthState = "{\"2\":1, \"3\":0}"
			end
			if FriendState == false then
				AuthState = "{\"2\":0, \"3\":1}"
			end
		end
	end
	StringMap:Add("PlatformUserTag", AuthState)

	_G.UE.UDataReportUtil.ReportKVData("PlayerLoginforUA", StringMap)
end

--乐器演奏设置
function DataReportUtil.ReportPerformanceSetFlowData(EventName, PerformanceMode, ButtonSize)
	local StringMap = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	DataReportUtil.InsertBaseReportData(StringMap, true, false, true)
	StringMap:Add("PerformanceMode", tostring(PerformanceMode))
	StringMap:Add("ButtonSize", tostring(ButtonSize))
	_G.UE.UDataReportUtil.ReportKVData(EventName, StringMap)
end

--预览进入界面
function DataReportUtil.ReportPreviewFlowData(EventName, OpType, PreviewlD, PreviewType)
	local StringMap = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	DataReportUtil.InsertBaseReportData(StringMap, true, false, true)
	StringMap:Add("OpType", tostring(OpType))
	StringMap:Add("PreviewlD", tostring(PreviewlD))
	StringMap:Add("PreviewType", tostring(PreviewType))
	_G.UE.UDataReportUtil.ReportKVData(EventName, StringMap)
end

-- 活动内点击流水
function DataReportUtil.ReportActivityClickFlowData(ActivityID, OperationPageActionType, 
	Arg1, Arg2, Arg3, Arg4, Arg5, Arg6)
	local StringMap = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	DataReportUtil.InsertBaseReportData(StringMap, true, false, true)
	StringMap:Add("ActivityID", tostring(ActivityID))
	StringMap:Add("OperationPageActionType", tostring(OperationPageActionType))
	DataReportUtil.InsertCommonStringData(StringMap, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6)
	_G.UE.UDataReportUtil.ReportKVData("ActivityClickFlow", StringMap)
end
--时尚配饰点击流水
function DataReportUtil.ReportFashiondecoData(EventName, OpType,
	Arg1, Arg2)
	local StringMap = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	DataReportUtil.InsertBaseReportData(StringMap, true, false, true)
	StringMap:Add("OpType", tostring(OpType))
	DataReportUtil.InsertCommonStringData(StringMap, Arg1, Arg2)
	_G.UE.UDataReportUtil.ReportKVData(EventName, StringMap)
end

---@param Eventname string
---@param ActivityID string
---@param Type string
---@param Arg1 string 自定义数据
---@param Arg2 string 自定义数据
---@param Arg3 string 自定义数据
---@param Arg4 string 自定义数据
---@param Arg5 string 自定义数据
---@param Arg6 string 自定义数据
function DataReportUtil.ReportActivityFlowData(EventName, ActivityID, OperationPageActionType, 
	Arg1, Arg2, Arg3, Arg4, Arg5, Arg6)
	local StringMap = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	DataReportUtil.InsertBaseReportData(StringMap, true, false, true)
	StringMap:Add("ActivityID", tostring(ActivityID))
	StringMap:Add("OperationPageActionType", tostring(OperationPageActionType))
	DataReportUtil.InsertCommonStringData(StringMap, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6)
	_G.UE.UDataReportUtil.ReportKVData(EventName, StringMap)
end

--【【客户端】P4-CBT2需求总单-分享流水表】 https://tapd.tencent.com/tapd_fe/20420083/story/detail/1020420083121986125
---@type 分享上报
---@param ShareType 分享类型 1-获得物品分享，2-首次分享（有分享奖励），3-立即分享（无分享奖ShareType励）4-等等
---@param ShareDest 分享目的地 
---@param ActID 活动ID(如有)
function DataReportUtil.ReportShareFlowData(ShareType, ShareDest, ActID, 
	Arg1, Arg2, Arg3, Arg4, Arg5, Arg6)
	local StringMap = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	DataReportUtil.InsertBaseReportData(StringMap, true, false, true)
	StringMap:Add("ShareType", tostring(ShareType))
	StringMap:Add("ShareDest", tostring(ShareDest))
	StringMap:Add("ActID", tostring(ActID))
	DataReportUtil.InsertCommonStringData(StringMap, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6)
	_G.UE.UDataReportUtil.ReportKVData("ShareFlow", StringMap)
end

-- 巡回乐团客户端上报
---ReportTouringBandFlowData
---@param Type string
---@param MapID string
---@param BandID string
---@param Arg1 string
function DataReportUtil.ReportTouringBandFlowData(Type, MapID, BandID, Arg1)
	local StringMap = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	DataReportUtil.InsertBaseReportData(StringMap, true, false, true)
	StringMap:Add("Type", Type or "")
	StringMap:Add("MapID", MapID or "")
	StringMap:Add("BandID", BandID or "")
	StringMap:Add("Arg1", Arg1 or "")
	_G.UE.UDataReportUtil.ReportKVData("TouringBandFlow", StringMap)
end

-- 跨界传送客户端上报
---@param Source 水晶ID
function DataReportUtil.ReportCrossServerFlowData(Source, Arg1, Arg2, Arg3)
	local MaxCPLv =  MajorUtil.GetMaxCombatProfLevel()
	local StringMap = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	DataReportUtil.InsertBaseReportData(StringMap, true, false, true)
	StringMap:Add("Source", Source or "")
	StringMap:Add("MaxCPLv" ,MaxCPLv)
	DataReportUtil.InsertCommonStringData(StringMap, Arg1, Arg2, Arg3)
	_G.UE.UDataReportUtil.ReportKVData("CrossServerTeleportVisitFLow", StringMap)
end

--设置界面点击流水
--当OpTab = 1时，OpType = 具体操作模块（1-返回登录、2-切换角色、3-移动方式、4-脱离卡死、5-遭受攻击自动选中目标、6-显示目标线、7-显示联系线、8-有限切换目标、9-自动跳过已经看过一次的过场动画、10-自动跳过任务剧情动画）
--当OpTab = 8时，OpType =具体操作模块（1-兑换码）
function DataReportUtil.ReportSettingClickFlowData(Eventname, OpTab, OpType, OpResult,
	Arg1, Arg2, Arg3, Arg4, Arg5, Arg6)
	local StringMap = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	DataReportUtil.InsertBaseReportData(StringMap, true, false, true)
	StringMap:Add("OpTab", OpTab or "")
	StringMap:Add("OpType", OpType or "")
	StringMap:Add("OpResult", OpResult or "")
	DataReportUtil.InsertCommonStringData(StringMap, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6)

	_G.UE.UDataReportUtil.ReportKVData(Eventname, StringMap)
end

--收集所有滑杆和下拉列表、调色盘、弹出自定义ui的设置数据进行上报
function DataReportUtil.ReportSettingData(Eventname)
	local StringMap = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	DataReportUtil.InsertBaseReportData(StringMap, true, false, true)

	_G.SettingsMgr:CollectReportData(StringMap)

	_G.UE.UDataReportUtil.ReportKVData(Eventname, StringMap)
end

--坐骑系统客户端上报
---@type 坐骑系统埋点上报
function DataReportUtil.ReportMountInterSystemFlowData(OpType, Arg1, Arg2, Arg3)
	local StringMap = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	DataReportUtil.InsertBaseReportData(StringMap, true, false, true)
	StringMap:Add("OpType", OpType or "")
	StringMap:Add("Arg1", Arg1 or "")
	StringMap:Add("Arg2", Arg2 or "")
	StringMap:Add("Arg3", Arg3 or "")
	_G.UE.UDataReportUtil.ReportKVData("MountInterSystemFlow", StringMap)
end

--个性定制界面客户端上报
---@type 个性定制界面埋点上报
---@param MountID string 坐骑id
---@param MountName string 坐骑名称
---@param OpenSource string 打开来源 1-图鉴 2-列表 3-商城
function DataReportUtil.ReportPersonalizedUIData(MountID, MountName, OpenSource)
	local StringMap = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	DataReportUtil.InsertBaseReportData(StringMap, true, false, true)
	StringMap:Add("MountID", MountID or "")
	StringMap:Add("MountName", MountName or "")
	StringMap:Add("OpenSource", OpenSource or "")
	_G.UE.UDataReportUtil.ReportKVData("PersonalizedUI", StringMap)
end

--涂装镜头客户端上报
---@type 涂装镜头埋点上报
---@param MountID string 坐骑id
---@param MountName string 坐骑名称
---@param AppearanceID string 外观id
---@param AppearanceName string 外观名称
---@param Type string 类型 1-涂装 2-涂装镜头
---@param Arg1 string 涂装镜头：特性镜头id
---@param Arg2 string 涂装镜头：特性镜头名称
function DataReportUtil.ReportPersonalizedViewData(MountID, MountName, AppearanceID, AppearanceName, Type,
	Arg1, Arg2,Arg3, Arg4, Arg5, Arg6)
	local StringMap = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	DataReportUtil.InsertBaseReportData(StringMap, true, false, true)
	StringMap:Add("MountID", MountID or "")
	StringMap:Add("MountName", MountName or "")
	StringMap:Add("AppearanceID", AppearanceID or "")
	StringMap:Add("AppearanceName", AppearanceName or "")
	DataReportUtil.InsertCommonStringData(StringMap, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6)
	_G.UE.UDataReportUtil.ReportKVData("PersonalizedView", StringMap)
end

--购买漏斗客户端上报
---@type 购买漏斗埋点上报
---@param MountID string 坐骑id
---@param MountName string 坐骑名称
---@param AppearanceID string 外观id
---@param AppearanceName string 外观名称
---@param Type string 类型 1-点击“购买“按钮并弹出二次确认弹框，2-二次确认弹框点击行为
---@param Arg1 string 二次确认弹框点击行为：0-点击“取消”按钮，1-点击“确认购买”按钮且成功购买，2-点击“确认购买”按钮且购买失败，3-关闭二次确认界面
function DataReportUtil.ReportPurchaseFunnelData(MountID, MountName, AppearanceID, AppearanceName, Type, Arg1)
	local StringMap = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	DataReportUtil.InsertBaseReportData(StringMap, true, false, true)
	StringMap:Add("MountID", MountID or "")
	StringMap:Add("MountName", MountName or "")
	StringMap:Add("AppearanceID", AppearanceID or "")
	StringMap:Add("AppearanceName", AppearanceName or "")
	StringMap:Add("Type", Type or "")
	StringMap:Add("Arg1", Arg1 or "")
	_G.UE.UDataReportUtil.ReportKVData("PurchaseFunnel", StringMap)
end

--个性定制流水客户端上报
---@type 个性定制流水埋点上报
---@param Type string 操作类型 
---@param MountID string 坐骑id
---@param MountName string 坐骑名称
---@param AppearanceID string 外观id
---@param AppearanceName string 外观名称
function DataReportUtil.ReportCustomizeUIFlowData(Type, MountID, MountName, AppearanceID, AppearanceName, Arg1,
	Arg2, Arg3, Arg4, Arg5, Arg6)
	local StringMap = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	DataReportUtil.InsertBaseReportData(StringMap, true, false, true)
	StringMap:Add("Type", Type or "")
	StringMap:Add("MountID", MountID or "")
	StringMap:Add("MountName", MountName or "")
	StringMap:Add("AppearanceID", AppearanceID or "")
	StringMap:Add("AppearanceName", AppearanceName or "")
	DataReportUtil.InsertCommonStringData(StringMap, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6)
	_G.UE.UDataReportUtil.ReportKVData("CustomizeUIFlow", StringMap)
end

-- 物品获取路径点击上报
---@param 	ItemID 	物品ID
---@param   Source 	系统Source  BagDefine.ItemGetWaySource
function DataReportUtil.ReportItemAccessGetWayData(ItemID, Source)
	local StringMap = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	DataReportUtil.InsertBaseReportData(StringMap, true, false, true)
	StringMap:Add("ItemID", ItemID or "")
	StringMap:Add("Source", Source or "")
	_G.UE.UDataReportUtil.ReportKVData("ItemGetWayClickFlow", StringMap)
end
--快捷使用上报
function DataReportUtil.ReportEasyUseFlowData(OpType, OpTab, OpTabOld,
	Arg1, Arg2, Arg3, Arg4)
	local StringMap = _G.UE.TMap(_G.UE.FString, _G.UE.FString)
	DataReportUtil.InsertBaseReportData(StringMap, true, false, true)
	StringMap:Add("OpType", OpType == nil and "" or tostring(OpType))
	StringMap:Add("OpTab", OpTab == nil and "" or tostring(OpTab))
	StringMap:Add("OpTabOld", OpTabOld == nil and "" or tostring(OpTabOld))
	DataReportUtil.InsertCommonStringData(StringMap, Arg1, Arg2, Arg3, Arg4)

	_G.UE.UDataReportUtil.ReportKVData("QuickInterfaceFlow", StringMap)
end

return DataReportUtil
