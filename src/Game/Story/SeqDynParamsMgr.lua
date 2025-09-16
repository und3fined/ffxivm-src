
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")

local SeqDynParamsMgr = LuaClass(MgrBase)

-- function SeqDynParamsMgr:OnInit()
-- end

function SeqDynParamsMgr:OnBegin()
	self:Reset()
end

function SeqDynParamsMgr:OnEnd()
	self:Reset()
end

-- function SeqDynParamsMgr:OnShutdown()
-- end

function SeqDynParamsMgr:Reset()
	_G.FLOG_INFO("SeqDynParamsMgr:Reset")
	self.IntParam1 = nil
	self.IntParam2 = nil
	self.IntParam3 = nil
	self.IntParam4 = nil
	self.IntParam5 = nil
	self.IntParam6 = nil
end

-- 关卡配置的参数列表按顺序传入，根据LcutType分开解析
function SeqDynParamsMgr:SetDynParams(LcutType, StrArgs)
	local Args = string.split(StrArgs, ",")
	-- BP SequenceDynamicParamsEnum
	if LcutType == 2 then
		self:TreasureHuntOpenDoor(tonumber(Args[1]), tonumber(Args[2]))
		_G.FLOG_INFO("SeqDynParamsMgr:SetDynParams, %s, %s", Args[1], Args[2])
	else
		_G.FLOG_ERROR("SeqDynParamsMgr:SetDynParams invalid LcutType %d", LcutType or -1)
	end
end

function SeqDynParamsMgr:GetSeqDynParam(KeyName)
	local Value = self[KeyName] or -1
	_G.FLOG_INFO("SeqDynParamsMgr:GetSeqDynParam, KeyName %s, Value %d", KeyName, Value)
	return Value
end

function SeqDynParamsMgr:TreasureHuntOpenDoor(roomIndex, doorIndex)

	-- roomIndex ・・・ 0から始まる宝部屋インデックス
	-- doorIndex ・・・ 0から始まる扉インデックスで0が左で1が右
	-- isSuccess ・・・  解錠成功したかで1が成功で0が失敗
	-- livenUpType ・・・演出タイプ 0:通常成功/失敗 1:フェイント成功 2:警報付きフェイント成功

	--Lcutマーカー
	local lcutMarkerDoor = 0
	local lcutMarkerAlert = 0
	-- ------------------------
	-- マーカー格納：部屋1
	if roomIndex == 0 then
		--左の扉
		if doorIndex == 0 then
			lcutMarkerDoor = 6402827
			lcutMarkerAlert = 6402887
		--右の扉
		elseif doorIndex == 1 then
			lcutMarkerDoor = 6402828
			lcutMarkerAlert = 6404192
		end
	-- ------------------------
	-- マーカー格納：部屋2
	elseif roomIndex == 1 then
		--左の扉
		if doorIndex == 0 then
			lcutMarkerDoor = 6404849
			lcutMarkerAlert = 6404851
		--右の扉
		elseif doorIndex == 1 then
			lcutMarkerDoor = 6404850
			lcutMarkerAlert = 6404852
		end
	-- ------------------------
	-- マーカー格納：部屋3
	elseif roomIndex == 2 then
		--左の扉
		if doorIndex == 0 then
			lcutMarkerDoor = 6404853
			lcutMarkerAlert = 6404855
		--右の扉
		elseif doorIndex == 1 then
			lcutMarkerDoor = 6404854
			lcutMarkerAlert = 6404856
		end
	-- ------------------------
	-- マーカー格納：部屋4
	elseif roomIndex == 3 then
		--左の扉
		if doorIndex == 0 then
			lcutMarkerDoor = 6404857
			lcutMarkerAlert = 6404871
		--右の扉
		elseif doorIndex == 1 then
			lcutMarkerDoor = 6404870
			lcutMarkerAlert = 6404872
		end
	-- ------------------------
	-- マーカー格納：部屋5
	elseif roomIndex == 4 then
		--左の扉
		if doorIndex == 0 then
			lcutMarkerDoor = 6404873
			lcutMarkerAlert = 6404875
		--右の扉
		elseif doorIndex == 1 then
			lcutMarkerDoor = 6404874
			lcutMarkerAlert = 6404876
		end
	-- ------------------------
	-- マーカー格納：部屋6
	elseif roomIndex == 5 then
		--左の扉
		if doorIndex == 0 then
			lcutMarkerDoor = 6404869
			lcutMarkerAlert = 6404878
		--右の扉
		elseif doorIndex == 1 then
			lcutMarkerDoor = 6404877
			lcutMarkerAlert = 6404879
		end
	end

    self.IntParam2 = doorIndex
    self.IntParam5 = lcutMarkerDoor
    self.IntParam6 = lcutMarkerAlert

    -- PlayLandscapeCamera 坐标点种在场景里，c++ GetAllActorsOfClass APositionMarker 查找名字里含ID的坐标点
end

return SeqDynParamsMgr
