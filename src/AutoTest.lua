--
-- Author: jianweili
-- Date: 2021-04-25
-- Description: 利用AutoRobot实现一些自动测试功能，比如WebGM，后续可继续扩展自动化测试功能（只适应于测试环境）
--
local AutoTest = {}
local TestModule = _G.UE.UTestModule

AutoTest.CatchGMRecvMsg=false
AutoTest.GMSvr=""
AutoTest.GMCmd=""
AutoTest.Timer_0=nil
AutoTest.CatchRollTreasureMsg = false

--监听客户端同学开发的WebGM消息
function AutoTest.OnReceiveAutoTest(CmdType, CmdString)
    print ("[AutoTest]CmdType: "..CmdType..", CmdString: "..CmdString)
    if CmdType == nil or CmdString == nil then
        return
    end

    if CmdType == "text" then
        CmdString = string.gsub(CmdString, "^[%s\n\r\t]*(.-)[%s\n\r\t]*$", "%1")
        if string.sub(CmdString, 1, 4) == "[gm]" then
            --GM指令
            local GMCmd = string.sub(CmdString, 5)
            GMMgr:ReqGM(GMCmd)
        elseif string.sub(CmdString, 1, 5) == "[lua]" then
            --Lua脚本
            local LuaScript = string.sub(CmdString, 6)
            local LuaFunc = load(LuaScript)
            if LuaFunc then
                LuaFunc()
            else
                FLOG_ERROR("[AutoTest]Lua error, please check lua script")
            end
        else
            --控制台命令
            _G.UE.UAutoTestMgr.ExeConsole(CmdString)
        end
    else
        FLOG_ERROR("[AutoTest]Error type: "..CmdType)
    end
end

--监听后台同学开发的WebGM消息（更便捷：可绑定至帐号、角色，可选服）
function AutoTest.OnReceiveGM(MsgBody)
    --MsgBody.Result中保存的是控制台指令或者Lua脚本
    --使用方式：
    --          1. 开启代码输入
    --          2. Web下方输入框输入client cmd，中间输入框输入控制台指令
    --          3. Web下方输入框输入client lua，中间输入框输入Lua脚本
    local WebContent = MsgBody.Cmd
    if WebContent == "" then
        return
    end

    if MsgBody.Svr == "cmd" then
        --执行控制台命令，如stat#unit，表示执行stat unit，注意：指令中的空格输入时替换为#
        _G.UE.UAutoTestMgr.ExeConsole(string.gsub(WebContent, "#", " "))
    elseif MsgBody.Svr == "lua" then
        --执行Lua脚本，如function TestFunc() print("web exe lua success!") end TestFunc()，表示执行Lua脚本
        local LuaFunc = load(WebContent)
        if LuaFunc then
            LuaFunc()
        else
            FLOG_ERROR("[WebGM]Lua error, please check lua script")
        end
	elseif MsgBody.Svr == "client" then
		_G.GMMgr:DoClientInput(WebContent)
    end
end

function AutoTest.GetMajorLocation()
	local MajorUtil = require("Utils/MajorUtil")
	local MajorActor = MajorUtil.GetMajor()
	--local ReturnStr = "0,0,0"
	local MajorPos = _G.UE.FVector(0, 0, 0)
	if nil ~= MajorActor then
		MajorPos = MajorActor:FGetActorLocation()
		--ReturnStr = tostring(MajorPos.X) .. "," .. tostring(MajorPos.Y) .. "," .. tostring(MajorPos.Z)
	else
		print("kevinwhli:MajorActor nil")
	end
	--AutoTest.GetLuaReturnVal(ReturnStr)
	--print("AutoTest.GetMajorLocation: " .. tostring(MajorPos.X) .. "," .. tostring(MajorPos.Y) .. "," .. tostring(MajorPos.Z) )
	return MajorPos
end

function AutoTest.GetLuaReturnVal(var)
	if TestModule ~= nil then
		print("call AutoTest.GetLuaReturnVal")
		TestModule.GetLuaReturnVal(tostring(var))
	end
end


function AutoTest.TeleportToCoord(X, Y, Z)
	if TestModule ~= nil then
		print("call AutoTest.TeleportToCoord")
		local GMMgr = require("Game/GM/GMMgr")
		cmd = "cell move pos "..tostring(X).." "..tostring(Y).." "..tostring(Z)
		GMMgr:ReqGM(cmd)
		AutoTest.GetLuaReturnVal("TeleportTo:"..tostring(X)..","..tostring(Y)..","..tostring(Z))
	end
end

function AutoTest.SetActorFacePoint(X, Y, Z)
	if TestModule ~= nil then
		print("call AutoTest.SetActorFacePoint")
		local GMMgr = require("Game/GM/GMMgr")
		local TargetPos = _G.UE.FVector(X, Y, Z)
		GMMgr:LookAtPos(TargetPos)
		AutoTest.GetLuaReturnVal("set face point:"..tostring(X)..","..tostring(Y)..","..tostring(Z))
	end
end

function AutoTest.MoveTo(X, Y, Z)
	if TestModule ~= nil then
		print("call AutoTest.MoveTo")
		local GMMgr = require("Game/GM/GMMgr")
		local TargetPos = _G.UE.FVector(X, Y, Z)
		GMMgr:MoveTo(TargetPos)
		AutoTest.GetLuaReturnVal("Move To point:"..tostring(X)..","..tostring(Y)..","..tostring(Z))
	end
end

function AutoTest.AutoMove(DirAngle, Distance)
	if TestModule ~= nil then
		print("call AutoTest.AutoMove")
		local ProtoCommon = require("Protocol/ProtoCommon")
		local MoveTimeMicro = math.ceil((1000 * Distance) / (_G.UE.UMajorUtil.GetAttrValue(ProtoCommon.attr_type.attr_move_speed)))
		print("MoveTimeMicro:" .. tostring(MoveTimeMicro))
		TestModule.AutoMove(DirAngle, MoveTimeMicro);
	end
end

function AutoTest.AutoTestGetDrawCallDetail()
	if TestModule ~= nil then
		print("call AutoTestGetDrawCallDetail")
		TestModule.GetDrawCallDetail();
	end
end

function AutoTest.AutoTestGetPrimitivesDetail()
	if TestModule ~= nil then
		print("call AutoTestGetPrimitivesDetail")
		TestModule.GetPrimitivesDetail();
	end
end

function AutoTest.AutoTestGetRenderTimeDetail()
	if TestModule ~= nil then
		print("call AutoTestGetRenderTimeDetail")
		TestModule.GetRenderTimeDetail();
	end
end

function AutoTest.AutoTestGetMemoryDetail()
	if TestModule ~= nil then
		print("call AutoTestGetMemoryDetail")
		TestModule.GetMemoryDetail();
	end
end

function AutoTest.AutoTestGetRuntimeStats()
	if TestModule ~= nil then
		print("call AutoTestGetRuntimeStats")
		TestModule.GetRuntimeStats();
	end
end

function AutoTest.AutoTestGetScreenLightNum()
	if TestModule ~= nil then
		print("call AutoTestGetScreenLightNum")
		TestModule.GetScreenLightNum();
	end
end

function AutoTest.GetTotalFoliageMemoryBytes()
	if _G.UE.UAutoTestUtil ~= nil then
		local TotalFoliageMemoryBytes = _G.UE.UAutoTestUtil.GetTotalFoliageMemoryBytes()
		AutoTest.GetLuaReturnVal(tostring(TotalFoliageMemoryBytes))
		return TotalFoliageMemoryBytes
	else
		AutoTest.GetLuaReturnVal("0")
		return 0
	end
end

function AutoTest.FindWidget(Text, WidgetName, PathName, IsPrecise)
	if TestModule ~= nil then
		print("call AutoTestFindWidget")
		TestModule.FindWidget(Text, WidgetName, PathName, IsPrecise);
	end
end

function AutoTest.GetTextByWidgetName(TextBlockName, IsPrecise)
	if TestModule ~= nil then
		print("call AutoTestGetTextByWidgetName")
		TestModule.GetTextByWidgetName(TextBlockName, IsPrecise);
	end
end

function AutoTest.ClickTextBlock(MyText, TextBlockName, PathName, IsPrecise)
	if TestModule ~= nil then
		print("call AutoTestClickTextBlock")
		TestModule.ClickTextBlock(MyText, TextBlockName, PathName, IsPrecise)
	end
end

function AutoTest.StatsCommand(cmdstr)
	if TestModule ~= nil then
		print("call AutoTest.StatsCommand:" .. cmdstr)
		TestModule.StatsCommand(cmdstr);
	end
end

function AutoTest.RotateToFacePoint( x, y, z )
	if TestModule ~= nil then
    	TestModule.RotateToFacePoint(x,y,z)
	end
end

function AutoTest.ClickButton(path ,  duringtime,  start_x,  start_y,  end_x,  end_y,  p_TouchIndex,  p_ControllerId, screensize_x, screensize_y, usepos)
	if TestModule ~= nil then
		print("call AutoTest:ClickButton")
		TestModule.ClickButton(path ,  duringtime,  start_x,  start_y,  end_x,  end_y,  p_TouchIndex,  p_ControllerId, screensize_x, screensize_y, usepos)
	end
end

function AutoTest.Swipe(path ,  duringtime,  start_x,  start_y,  end_x,  end_y,  p_TouchIndex,  p_ControllerId, screensize_x, screensize_y)
	if TestModule ~= nil then
		print("call AutoTest:Swipe")
		TestModule.Swipe(path ,  duringtime,  start_x,  start_y,  end_x,  end_y,  p_TouchIndex,  p_ControllerId, screensize_x, screensize_y)
	end
end

function AutoTest.MoveSlider(SliderPath, InValue)
	if TestModule ~= nil then
		print(string.format("call AutoTest:MoveSlider %s %s", tostring(SliderPath), tostring(InValue)))
		TestModule.MoveSlider(SliderPath, InValue)
	end
end

function AutoTest.RegisterInputProcessor()
	if TestModule ~= nil then
		print("call AutoTest:RegisterInputProcessor")
		TestModule.RegisterInputProcessor()
	end
end

function AutoTest.RegisterInputProcessorBySyncSvr()
	if TestModule ~= nil then
		print("call AutoTest:RegisterInputProcessorBySyncSvr")
		TestModule.RegisterInputProcessorBySyncSvr()
	end
end

function AutoTest.StartRecordInput(cmdstr, needIgnoreSvrMove)
	if needIgnoreSvrMove == nil then
		needIgnoreSvrMove = true
	end

	if TestModule ~= nil then
		--AutoTest.RegisterInputProcessor()
		print("call AutoTest:StartRecordInput")

		if needIgnoreSvrMove then
			local Major = AutoTest.GetMajorCharacter()
			if Major ~= nil then
				Major:DoClientModeEnter()
			end
		end

		TestModule.StartRecordInput(cmdstr)
	end
end

function AutoTest.StartRecordInputByMutiPlayer(CmdStr, gameid, testid, playernum, needIgnoreSvrMove)
	if needIgnoreSvrMove == nil then
		needIgnoreSvrMove = true
	end

	if TestModule ~= nil then
		print("call AutoTest:StartRecordInputByMutiPlayer")

		if needIgnoreSvrMove then
			local Major = AutoTest.GetMajorCharacter()
			if Major ~= nil then
				Major:DoClientModeEnter()
			end
		end

		TestModule.StartRecordInputByMutiPlayer(CmdStr, gameid, testid, playernum)
	end
end

function AutoTest.StopRecordInput()
	if TestModule ~= nil then
		print("call AutoTest:StopRecordInput")
		TestModule.StopRecordInput()

		local Major = AutoTest.GetMajorCharacter()
		if Major ~= nil then
			Major:DoClientModeExit()
		end
	end
end

function AutoTest.StopRecordInputByMutiPlayer()
	if TestModule ~= nil then
		print("call AutoTest:StopRecordInputByMutiPlayer")
		TestModule.StopRecordInputByMutiPlayer()

		local Major = AutoTest.GetMajorCharacter()
		if Major ~= nil then
			Major:DoClientModeExit()
		end
	end
end

function AutoTest.StartPlayInput(filename, needIgnoreSvrMove)
	if needIgnoreSvrMove == nil then
		needIgnoreSvrMove = true
	end

	if TestModule ~= nil then
		--AutoTest.RegisterInputProcessor()
		print("call AutoTest:StartPlayInput")

		if needIgnoreSvrMove then
			local Major = AutoTest.GetMajorCharacter()
			if Major ~= nil then
				Major:DoClientModeEnter()
			end
		end

		TestModule.StartPlayInput(filename)
	end
end

function AutoTest.StartPlayInputByMutiPlayer(filename, gameid, testid, playernum, needIgnoreSvrMove)
	if needIgnoreSvrMove == nil then
		needIgnoreSvrMove = true
	end
	
	if TestModule ~= nil then
		print("call AutoTest:StartPlayInputByMutiPlayer")

		if needIgnoreSvrMove then
			local Major = AutoTest.GetMajorCharacter()
			if Major ~= nil then
				Major:DoClientModeEnter()
			end
		end

		TestModule.StartPlayInputByMutiPlayer(filename, gameid, testid, playernum)
	end
end

function AutoTest.StopPlayInput()
	if TestModule ~= nil then
		print("call AutoTest:StopPlayInput")
		TestModule.StopPlayInput()

		local Major = AutoTest.GetMajorCharacter()
		if Major ~= nil then
			Major:DoClientModeExit()
		end
	end
end

function AutoTest.StopPlayInputByMutiPlayer()
	if TestModule ~= nil then
		print("call AutoTest:StopPlayInputByMutiPlayer")
		TestModule.StopPlayInputByMutiPlayer()

		local Major = AutoTest.GetMajorCharacter()
		if Major ~= nil then
			Major:DoClientModeExit()
		end
	end
end

function AutoTest.PausePlayInput()
	if TestModule ~= nil then
		print("call AutoTest:PausePlayInput")
		TestModule.PausePlayInput()
	end
end

function AutoTest.ContinuePlayInput()
	if TestModule ~= nil then
		print("call AutoTest:ContinuePlayInput")
		TestModule.ContinuePlayInput()
	end
end

function AutoTest.SwitchCamera(Distance, Pitch, Yaw, Roll)
	local CameraMgr = require("Game/Camera/LuaCameraMgr")
	local DialogCamera = CameraMgr:GetExtraCamera()
	if DialogCamera == nil then
		AutoTest.GetLuaReturnVal("Fail")
		print("No DialogCamera")
		return nil
	end

	local MajorUtil = require("Utils/MajorUtil")
	local MajorActor = MajorUtil.GetMajor()
	local MajorPos = _G.UE.FVector(0, 0, 0)
	if nil ~= MajorActor then
		MajorPos = MajorActor:FGetActorLocation()
	else
		AutoTest.GetLuaReturnVal("Fail")
		print("No Major")
		return nil
	end

	local SocketOffset = _G.UE.FVector(0, 0, 0)
	local Rotation = _G.UE.FRotator(Pitch, Yaw, Roll)

    DialogCamera:SetViewDistance(Distance, false)
    DialogCamera:SetTargetLocation(MajorPos, false)
    DialogCamera:SetSocketOffset(SocketOffset, false)
    DialogCamera:Rotate(Rotation, false)
	DialogCamera:SwitchCollision(false)
	
    _G.UE.UCameraMgr.Get():SwitchCamera(DialogCamera, 0) -- 每次都切一下避免调用者忘了切
    -- 设置FOV要放在 SwitchCamera 后面，因为里面会拷贝主摄像机的FOV
    DialogCamera:SetFOVY(70)

	AutoTest.GetLuaReturnVal("Success")
end

function AutoTest.ResetCamera()
	local CameraMgr = _G.UE.UCameraMgr.Get()
    if CameraMgr ~= nil then
        CameraMgr:ResumeCamera(0, true, nil)
    end
end

function AutoTest.GetMajorCharacter()
	return _G.UE.UActorManager:Get():GetMajor()
end

function AutoTest.GetMajorCameraData()
	if _G.UE.UAutoTestUtil ~= nil then
		return _G.UE.UAutoTestUtil.GetMajorCameraData()
	else
		return nil
	end
end

function AutoTest.GetMajorAvatarCompsLod(EntityID)
	if _G.UE.UAutoTestUtil ~= nil then
		AutoTest.GetLuaReturnVal(tostring(_G.UE.UAutoTestUtil.GetMajorAvatarCompsLod(EntityID)))
	else
		AutoTest.GetLuaReturnVal("Fail, No AutoTestUtil")
	end
end

function AutoTest.GetMajorSkeletalMeshComponent()
	if _G.UE.UAutoTestUtil ~= nil then
		return _G.UE.UAutoTestUtil.GetMajorSkeletalMeshComponent()
	else
		return nil
	end
end

function AutoTest.GetMajorHipHeight()
	if _G.UE.UAutoTestUtil ~= nil then
		AutoTest.GetLuaReturnVal(tostring(_G.UE.UAutoTestUtil.GetMajorHipHeight()))
	else
		AutoTest.GetLuaReturnVal("Fail, No AutoTestUtil")
	end
end

function AutoTest.GetChairTopHeight(x, y, z)
	if _G.UE.UAutoTestUtil ~= nil then
		AutoTest.GetLuaReturnVal(tostring(_G.UE.UAutoTestUtil.GetChairTopHeight(x, y, z)))
	else
		AutoTest.GetLuaReturnVal("Fail, No AutoTestUtil")
	end
end

function AutoTest.UnSelectTarget()
	if TestModule ~= nil then
		print("call AutoTest:UnSelectTarget")
		TestModule.UnSelectTarget()
	end
end

function AutoTest.SelectNPC(NPCName)
	local MajorUtil = require("Utils/MajorUtil")
	local ActorUtil = require("Utils/ActorUtil")
	local MajorActor = MajorUtil.GetMajor()
	local MajorPos = MajorActor:FGetActorLocation()
	local MinDistance = 9999999

	local ActorManager = _G.UE.UActorManager.Get()
	local EActorType = _G.UE.EActorType
	local AllNPCs = ActorManager:GetActorsByType(EActorType.Npc)
	local Length = AllNPCs:Length()
	local EntityID = 0
	for i = 1, Length do
		local NPC = AllNPCs:GetRef(i)
		if NPCName == ActorUtil.GetActorName(NPC:GetAttributeComponent().EntityID) then
			local NPCPos = NPC:FGetActorLocation()
			local NPCDistance = math.sqrt(((NPCPos.X - MajorPos.X) ^ 2) + ((NPCPos.Y - MajorPos.Y) ^ 2) + ((NPCPos.Z - MajorPos.Z) ^ 2))
			if NPCDistance < MinDistance then
				MinDistance = NPCDistance
				EntityID = NPC:GetAttributeComponent().EntityID
			end
		end
	end
	
	if EntityID == 0 then
		AutoTest.GetLuaReturnVal("Fail to Find NPC!")
	else
		SwitchTarget:SwitchToTarget(EntityID)
		AutoTest.GetLuaReturnVal("Succeed to Select NPC!")
	end
end

function AutoTest.GetNPCFaceDegreeToMajor(NPCName)
	local MajorUtil = require("Utils/MajorUtil")
	local ActorUtil = require("Utils/ActorUtil")
	local MajorActor = MajorUtil.GetMajor()
	local MajorPos = MajorActor:FGetActorLocation()
	local MinDistance = 9999999

	local ActorManager = _G.UE.UActorManager.Get()
	local EActorType = _G.UE.EActorType
	local AllNPCs = ActorManager:GetActorsByType(EActorType.Npc)
	local Length = AllNPCs:Length()
	local NPCRot = nil
	local NPCPos = nil
	local MinDistNPCName = nil
	for i = 1, Length do
		local NPC = AllNPCs:GetRef(i)
		if NPCName == ActorUtil.GetActorName(NPC:GetAttributeComponent().EntityID) or NPCName == nil then
			local PosTemp = NPC:FGetActorLocation()
			local NPCDistance = math.sqrt(((PosTemp.X - MajorPos.X) ^ 2) + ((PosTemp.Y - MajorPos.Y) ^ 2) + ((PosTemp.Z - MajorPos.Z) ^ 2))
			if NPCDistance < MinDistance then
				MinDistance = NPCDistance
				NPCRot = NPC:FGetActorRotation():GetForwardVector()
				NPCPos = PosTemp
				MinDistNPCName = ActorUtil.GetActorName(NPC:GetAttributeComponent().EntityID)
			end
		end
	end

	if NPCRot == nil then
		AutoTest.GetLuaReturnVal("Fail to Find NPC!")
	else
		local NPC2Major = { X = MajorPos.X - NPCPos.X, Y = MajorPos.Y - NPCPos.Y}
		local NPCDegree = (180 / math.pi) * math.acos((NPC2Major.X * NPCRot.X + NPC2Major.Y * NPCRot.Y) / ((math.sqrt(NPC2Major.X ^ 2 + NPC2Major.Y ^ 2)) * (math.sqrt(NPCRot.X ^ 2 + NPCRot.Y ^ 2))))
		if NPCName == nil then
			AutoTest.GetLuaReturnVal(tostring(NPCDegree) .. ";" .. MinDistNPCName)
		else
			AutoTest.GetLuaReturnVal(tostring(NPCDegree))
		end
	end
end

function AutoTest.SelectMonster(MonsterName)
	local ActorUtil = require("Utils/ActorUtil")
	local MajorUtil = require("Utils/MajorUtil")
	local MajorActor = MajorUtil.GetMajor()
	local MajorPos = MajorActor:FGetActorLocation()
	local MinDistance = 9999999

	local ActorManager = _G.UE.UActorManager.Get()
	local EActorType = _G.UE.EActorType
	local AllMonsters = ActorManager:GetAllMonsters()
    local Length = AllMonsters:Length()
	local EntityID = 0
	for i = 1, Length do
		local Monster = AllMonsters:GetRef(i)
		if MonsterName == ActorUtil.GetActorName(Monster:GetAttributeComponent().EntityID) then
			local MonsterPos = Monster:FGetActorLocation()
			local MonsterDistance = math.sqrt(((MonsterPos.X - MajorPos.X) ^ 2) + ((MonsterPos.Y - MajorPos.Y) ^ 2) + ((MonsterPos.Z - MajorPos.Z) ^ 2))
			if MonsterDistance < MinDistance then
				MinDistance = MonsterDistance
				EntityID = Monster:GetAttributeComponent().EntityID
			end
		end
	end
	
	if EntityID == 0 then
		AutoTest.GetLuaReturnVal("Fail to Find Monster!")
	else
		SwitchTarget:SwitchToTarget(EntityID)
		AutoTest.GetLuaReturnVal("Succeed to Select Monster!")
	end
end

function AutoTest.ScreenShot(FileName)
	if TestModule ~= nil then
		print("call AutoTest:ScreenShot " .. FileName)
		TestModule.ScreenShot(FileName)
	end
end

function AutoTest.FrameScreenShot(FolderPath, FrameNum, TimeInterval)
	if TestModule ~= nil then
		print("call AutoTest:FrameScreenShot " .. FolderPath .. " " .. FrameNum .. " " .. TimeInterval)
		TestModule.FrameScreenShot(FolderPath, FrameNum, TimeInterval)
	end
end

function AutoTest.GetMonsterInfo(Radius)
	local MajorUtil = require("Utils/MajorUtil")
	local ActorUtil = require("Utils/ActorUtil")
	local MonsterCfg = require("TableCfg/MonsterCfg")
	local EnmityCfg = require("TableCfg/EnmityCfg")
	local MajorActor = MajorUtil.GetMajor()
	local MajorPos = MajorActor:FGetActorLocation()

	local ActorManager = _G.UE.UActorManager.Get()
	local AllMonsters = ActorManager:GetAllMonsters()
    local Length = AllMonsters:Length()
	local ResultTable = {}
    for i = 1, Length do
		local Monster = AllMonsters:GetRef(i)

		local MonsterPos = Monster:FGetActorLocation()
		if ((MonsterPos.X - MajorPos.X) ^ 2) + ((MonsterPos.Y - MajorPos.Y) ^ 2) + ((MonsterPos.Z - MajorPos.Z) ^ 2) < (Radius ^ 2) then
			local EntityID = Monster:GetAttributeComponent().EntityID
			local ResID = ActorUtil.GetActorResID(EntityID)
			local MonsterHP = ActorUtil.GetActorHP(EntityID)

			local MonsterLevel = 0
			if Monster:GetAttributeComponent().Level > 0 then
				MonsterLevel = Monster:GetAttributeComponent().Level
			end

			local Cfg = MonsterCfg:FindCfgByKey(ResID)
			local IsActive = EnmityCfg:FindValue(Cfg.EnmityID, "IsActiveEnmity")

			if MonsterHP > 0 then
				local MonsterInfo = string.format("{\"entity_id\":%s,\"res_id\":%s,\"position\":[%s,%s,%s],\"hp\":%s,\"level\":%s,\"isactive\":%s}", tostring(EntityID), tostring(ResID), tostring(MonsterPos.X), tostring(MonsterPos.Y), tostring(MonsterPos.Z), tostring(MonsterHP), tostring(MonsterLevel), tostring(IsActive))
				table.insert(ResultTable, MonsterInfo)
			end
		end
	end

	if ResultTable ~= nil then
		AutoTest.GetLuaReturnVal("[" .. table.concat(ResultTable, ",") .. "]")
	else
		AutoTest.GetLuaReturnVal("No Monster!")
	end
end

function AutoTest.GetAllMonsterSortByResID()
	local ActorUtil = require("Utils/ActorUtil")
	local ActorManager = _G.UE.UActorManager.Get()
	local AllMonsters = ActorManager:GetAllMonsters()
    local Length = AllMonsters:Length()
	local ResultTable = {}
	for i = 1, Length do
		local Monster = AllMonsters:GetRef(i)
		local MonsterPos = Monster:FGetActorLocation()
		local MonsterIndex = tostring(ActorUtil.GetActorResID(Monster:GetAttributeComponent().EntityID)) .. " " .. tostring(ActorUtil.GetActorName(Monster:GetAttributeComponent().EntityID))
		if ResultTable[MonsterIndex] ~= nil then
			ResultTable[MonsterIndex] = ResultTable[MonsterIndex] .. string.format(",[%s,%s,%s]", tostring(MonsterPos.X), tostring(MonsterPos.Y), tostring(MonsterPos.Z))
		else
			ResultTable[MonsterIndex] = string.format("[%s,%s,%s]", tostring(MonsterPos.X), tostring(MonsterPos.Y), tostring(MonsterPos.Z))
		end
	end

	if ResultTable ~= nil then
		local ResultTempTable = {}
		for k, v in pairs(ResultTable) do
			table.insert(ResultTempTable, string.format("\"%s\":\"%s\"", k, v))
		end
		AutoTest.GetLuaReturnVal("[" .. table.concat(ResultTempTable, ",") .. "]")
	else
		AutoTest.GetLuaReturnVal("Fail to Find Monster!")
	end
end

function AutoTest.GetAllNPCSortByResID()
	local ActorUtil = require("Utils/ActorUtil")
	local ActorManager = _G.UE.UActorManager.Get()
	local EActorType = _G.UE.EActorType
	local AllNPCs = ActorManager:GetActorsByType(EActorType.Npc)
	local Length = AllNPCs:Length()
	local ResultTable = {}
	for i = 1, Length do
		local NPC = AllNPCs:GetRef(i)
		local NPCPos = NPC:FGetActorLocation()
		local NPCIndex = tostring(ActorUtil.GetActorResID(NPC:GetAttributeComponent().EntityID)) .. " " .. tostring(ActorUtil.GetActorName(NPC:GetAttributeComponent().EntityID))
		if ResultTable[NPCIndex] ~= nil then
			ResultTable[NPCIndex] = ResultTable[NPCIndex] .. string.format(",[%s,%s,%s]", tostring(NPCPos.X), tostring(NPCPos.Y), tostring(NPCPos.Z))
		else
			ResultTable[NPCIndex] = string.format("[%s,%s,%s]", tostring(NPCPos.X), tostring(NPCPos.Y), tostring(NPCPos.Z))
		end
	end

	if ResultTable ~= nil then
		local ResultTempTable = {}
		for k, v in pairs(ResultTable) do
			table.insert(ResultTempTable, string.format("\"%s\":\"%s\"", k, v))
		end
		AutoTest.GetLuaReturnVal("[" .. table.concat(ResultTempTable, ",") .. "]")
	else
		AutoTest.GetLuaReturnVal("Fail to Find NPC!")
	end
end

function AutoTest.SimulateEnter()
	if TestModule ~= nil then
		print("call AutoTest:SimulateEnter")
		TestModule.SimulateEnter()
	end
end

function AutoTest.ConstructRecordUI()
	if TestModule ~= nil then
		print("call AutoTest:ConstructRecordUI")
		TestModule.ConstructRecordUI()
	end
end

function AutoTest.DestructRecordUI()
	if TestModule ~= nil then
		print("call AutoTest:DestructRecordUI")
		TestModule.DestructRecordUI()
	end
end

function AutoTest.TestRot()
	if TestModule ~= nil then
		print("call AutoTest:TestRot ")
		TestModule.TestRot()
	end
	--local FriendPanelView = _G.UIViewMgr:FindVisibleView(UIViewID.SocialMainPanel) 
	--local SearchInputView = FriendPanelView.FriendAddPanel.SearchInput
	--if SearchInputView ~= nil then
		--print("SearchInputView")
		--SearchInputView:TriggerOnEnterCommit()
	--end
end

function AutoTest.ScanMap(Radius, DeformationDistance, MapName) 
	if TestModule ~= nil then
		print(string.format("call AutoTest: ScanMap(%s, %s, %s)", tostring(Radius), tostring(DeformationDistance), tostring(MapName)))
		if MapName ==nil then
			TestModule.ScanMap(Radius, DeformationDistance, '')
		else
			TestModule.ScanMap(Radius, DeformationDistance, MapName)
		end
	end
end

function AutoTest.GetActorsLocation(ActorsName)
	if TestModule ~= nil then
		print(string.format("call AutoTest: GetActorsLocation(%s)", tostring(ActorsName)))
		TestModule.GetActorsLocation(ActorsName)
	else
		print("No TestModule")
	end
end

function AutoTest.ExcuteConsoleCMD(CmdString)
	print(string.format("call AutoTest.ExcuteConsoleCMD:%s", CmdString))
	_G.UE.UAutoTestMgr.ExeConsole(CmdString)
end


function AutoTest.ExcuteGM(GMString)
	AutoTest.CatchGMRecvMsg = false
	AutoTest.GMCmd = ""
	print(string.format("call AutoTest.ExcuteGM:%s", GMString))
	GMMgr:ReqGM(GMString)
end

function AutoTest.ExcuteGM_GetRecvMsg(GMString)
	local cmdstart,_ = string.find(GMString, " ", 1)
	AutoTest.GMSvr = string.sub(GMString, 1, cmdstart - 1)
	cmdstart = cmdstart + 1
	local cmdend,_ = string.find(GMString, " ", cmdstart)
	if cmdend ~= nil then
		AutoTest.GMCmd = string.sub(GMString, cmdstart, cmdend - 1)
	else
		AutoTest.GMCmd = string.sub(GMString, cmdstart)
	end

	AutoTest.CatchGMRecvMsg = true
	GMMgr:ReqGM(GMString)
end

function AutoTest:RegisterRollNetMsg()
    print("AutoTest: RegisterRollNetMsg")
    local GameNetMsgRegister = require("Register/GameNetMsgRegister")
    local Register = self.RollNetMsgRegister
    if nil == Register then
        print("AutoTest: RegisterRollNetMsg GameNetMsgRegister.New()")
        Register = GameNetMsgRegister.New()
        self.RollNetMsgRegister = Register
    end

    if nil ~= Register then
        local ProtoCS = require("Protocol/ProtoCS")
        local CS_CMD = ProtoCS.CS_CMD
		local CS_ROLL_CMD = ProtoCS.CS_ROLL_CMD
        Register:Register(CS_CMD.CS_CMD_ROLL, CS_ROLL_CMD.RollQuery, self, self.OnRollQuery)
    end
end

function AutoTest:UnRegisterRollNetMsg()
    if nil ~= self.RollNetMsgRegister then
        print("AutoTest: UnRegisterRollNetMsg")
        local ProtoCS = require("Protocol/ProtoCS")
        local CS_CMD = ProtoCS.CS_CMD
		local CS_ROLL_CMD = ProtoCS.CS_ROLL_CMD
        self.RollNetMsgRegister:UnRegister(CS_CMD.CS_CMD_ROLL, CS_ROLL_CMD.RollQuery, self, self.OnRollQuery)
    end
end

function AutoTest:OnRollQuery(MsgBody)
    if self.CatchRollTreasureMsg == true then
        print("AutoTest:OnRollQuery")
        self.CatchRollTreasureMsg = false
        self.GetLuaReturnVal(table.tostring(MsgBody))
    end
end

function AutoTest.RequestRollInfo()
    if AutoTest.RollNetMsgRegister == nil then
        AutoTest:RegisterRollNetMsg()
    end

    AutoTest.CatchRollTreasureMsg = true
    local RollMgr = require("Game/Roll/RollMgr")
	local TeamMgr = require("Game/Team/TeamMgr")
	local TeamID = TeamMgr:GetTeamID()
	print(TeamID)
    RollMgr:SendMsgQueryReq(TeamID)
end

function AutoTest.OpenNetRecord()
	if TestModule ~= nil then
		print("call AutoTest: OpenNetRecord")
		TestModule.OpenNetRecord()
	else
		print("No TestModule")
	end
end

function AutoTest.CloseNetRecord()
	if TestModule ~= nil then
		print("call AutoTest: CloseNetRecord")
		TestModule.CloseNetRecord()
	else
		print("No TestModule")
	end
end

function AutoTest.IsNetRecord()
	if TestModule ~= nil then
		local IsNetRecord = TestModule.IsNetRecord()
		return IsNetRecord
	else
		return false
	end
end

function AutoTest.SendBuffer(Buffer, Length)
	if TestModule ~= nil then
		TestModule.SendBuffer(Buffer, Length)
	end
end

function AutoTest.TansmitData(MsgID, SubMsgID, Buffer)
	local AutoTestGameNetworkMgr = _G.UE.UGameNetworkMgr.Get()
	if AutoTestGameNetworkMgr ~= nil then
		--print(string.format("AutoTest.TansmitData MsgID %s SubMsgID %s", tostring(MsgID), tostring(SubMsgID)))
		AutoTestGameNetworkMgr:SendDataUint8(MsgID, SubMsgID, Buffer)
	end
end

function AutoTest.SwitchKeepCastSkill(CastSkillState)
	if TestModule ~= nil then
		TestModule.SwitchKeepCastSkill(CastSkillState)
	end
end

function AutoTest.SetGamePaused(IsPause)
	if TestModule ~= nil then
		TestModule.SetGamePaused(IsPause)
	end
end

function AutoTest.TakeActorScreenShot(FileName, PointX, PointY, PointZ, ExtentX, ExtentY, ExtentZ)
	if TestModule ~= nil then
		local Point = _G.UE.FVector(PointX, PointY, PointZ)
		local BoxExtent = _G.UE.FVector(ExtentX + 100, ExtentY + 100, ExtentZ + 100)

		TestModule.DrawBox(Point, BoxExtent)

		local GMMgr = require("Game/GM/GMMgr")
		GMMgr:LookAtPos(_G.UE.FVector(PointX, PointY, PointZ))

		local MajorUtil = require("Utils/MajorUtil")
		local MajorActor = MajorUtil.GetMajor()
		local MajorPos = MajorActor:FGetActorLocation()
		Pitch = math.deg(math.atan(PointZ - MajorPos.Z, math.sqrt((PointX - MajorPos.X)^2 + (PointY - MajorPos.Y)^2)))
		print(tostring(Pitch))
		AutoTest.SetMajorCamera(2 * ExtentX + 1500, Pitch, 0, 0)
		
		AutoTest.Timer_0 = _G.TimerMgr:AddTimer(self, function(FileName)
			TestModule.SetGamePaused(true)
			TestModule.ScreenShot(FileName.FileName .. "_Frame")
			AutoTest.Timer_0 = nil
		end, 1.0, 0, 1, {FileName = FileName})
	end
end

function AutoTest.RegisterAnimProcessor()
        if TestModule ~= nil then
                print("call AutoTest.RegisterAnimProcessor")
                TestModule.RegisterAnimProcessor()
        end
end

function AutoTest.StartRecordBaseVersion(RaceName, InRecordFrame, InRecordTime, InEmoId)
        if TestModule ~= nil then
                print("call AutoTest.StartRecordBaseVersion")
                TestModule.StartRecordBaseVersion(RaceName, InRecordFrame, InRecordTime, InEmoId)
        end
end

function AutoTest.StartRecordOtherVersion(RaceName, InRecordFrame, InRecordTime, InEmoId)
        if TestModule ~= nil then
                print("call AutoTest.StartRecordOtherVersion")
                TestModule.StartRecordOtherVersion(RaceName, InRecordFrame, InRecordTime, InEmoId)
        end
end

function AutoTest.StartAnimCmp(RaceName, InEmoId)
        if TestModule ~= nil then
                print("call AutoTest.StartAnimCmp")
                TestModule.StartAnimCmp(RaceName, InEmoId)
        end
end

function AutoTest.StartScreenShot(RaceName, InRecordFrame, InRecordTime, InEmoId)
        if TestModule ~= nil then
                print("call AutoTest.StartScreenShot")
                TestModule.StartScreenShot(RaceName, InRecordFrame, InRecordTime, InEmoId)
        end
end

function AutoTest.ChangeThreshold(FTransformThreshold, InFrameTimeTolerance)
	if TestModule ~= nil then
		print("call AutoTest.ChangeThreshold")
		TestModule.ChangeThreshold(FTransformThreshold, InFrameTimeTolerance)
	end
end

function AutoTest.GetDialogueLabelContent(FuncName, Params)
	local DialogueUtil = require("Utils/DialogueUtil")
	funcname = string.lower(FuncName)
	if DialogueUtil.FuncList[funcname] ~= nil then
		if Params ~= nil then
			AutoTest.GetLuaReturnVal(tostring(DialogueUtil.FuncList[funcname](Params)))
		else
			AutoTest.GetLuaReturnVal(tostring(DialogueUtil.FuncList[funcname]()))
		end
	else
		AutoTest.GetLuaReturnVal(tostring(FuncName))
	end
end

function AutoTest:OnAutoMoveStop()
	AutoTest.GetLuaReturnVal("AutoMove Stop!")
end

function AutoTest:RegisterAutoMoveStop()
	_G.EventMgr:RegisterEvent(EventID.StopAutoPathMove, self, self.OnAutoMoveStop, "AutoTest")
end

function AutoTest:UnRegisterAutoMoveStop()
	_G.EventMgr:UnRegisterEvent(EventID.StopAutoPathMove, self, self.OnAutoMoveStop)
end

function AutoTest.RecordScreenShotLQA(Path)
	if TestModule ~= nil then
		TestModule.RecordScreenShotLQA(Path)
	end
end

function AutoTest.RecordLuaStr(LuaStr)
	if TestModule ~= nil then
		LuaStr = "AutoTest=require('AutoTest') " .. LuaStr
		TestModule.RecordLuaStr(LuaStr)
	end
end

function AutoTest.TestSequence(SequencePath)
	local TestSequenceCmd = string.format("client seqp LevelSequence'%s'", SequencePath)
	print("kevinwhli" .. TestSequenceCmd)
	AutoTest.ExcuteGM(TestSequenceCmd)
end

return AutoTest
