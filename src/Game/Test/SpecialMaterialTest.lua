--
-- Author: chaooren
-- Date: 2021-09-10
-- Description:
--

local MajorUtil = require("Utils/MajorUtil")
local CommonUtil = require("Utils/CommonUtil")
local GameplayStaticsUtil = require("Utils/GameplayStaticsUtil")

local TestCharaceterPath = {
	["Character"] = "Blueprint'/Game/MaterialLibrary/PerformanceTesting/Character/TestCharacter.TestCharacter_C'",
}

for i = 1, 20 do
	local IndexStr = tostring(i)
	local key = "equipment" .. IndexStr
	local StrTemplate = "Blueprint'/Game/MaterialLibrary/PerformanceTesting/equipment/Character{Index}/equipmentTestCharacter{Index}.equipmentTestCharacter{Index}_C'"
	TestCharaceterPath[key] = string.gsub(StrTemplate, "{Index}", IndexStr)
end

local SpecialMaterialTest = {
	CurCharaceter = TestCharaceterPath.Character,
	CurDir = "Character"
}

function SpecialMaterialTest.CreateTestCharacter(Count)
	if Count <= 0 then return end
	local Major = MajorUtil.GetMajor()
	if not Major then return end
	local Distance = 200
	local ForwardVec = Major:GetActorForwardVector()
	local RightVec = Major:GetActorRightVector()
	local CurrentPos = Major:FGetActorLocation() - _G.UE.FVector(0, 0, Major:GetCapsuleHalfHeight())

	for i = 0, Count - 1 do
		local Col = i % 5
		local Row = math.floor((i) / 5) + 1

		local VerticalPos =  ForwardVec * Row * Distance
		local HorizontalPos = RightVec * (Col - 2) * Distance
		local CreatePos = CurrentPos + VerticalPos + HorizontalPos
		local CurActor = SpecialMaterialTest.CurCharaceter
		local function Callback()
			local TestClass = _G.ObjectMgr:GetClass(CurActor)
			if TestClass then
				CommonUtil.SpawnActor(TestClass, CreatePos)
			end
		end
		_G.ObjectMgr:LoadClassAsync(CurActor, Callback)
	end
end

function SpecialMaterialTest.CreateEquipmentCharacter()
	local Major = MajorUtil.GetMajor()
	if not Major then return end
	local Distance = 200
	local ForwardVec = Major:GetActorForwardVector()
	local RightVec = Major:GetActorRightVector()
	local CurrentPos = Major:FGetActorLocation() - _G.UE.FVector(0, 0, Major:GetCapsuleHalfHeight())
	SpecialMaterialTest.CurDir = "equipment"
	for i = 0, 19 do
		local Col = i % 5
		local Row = math.floor((i) / 5) + 1

		local VerticalPos =  ForwardVec * Row * Distance
		local HorizontalPos = RightVec * (Col - 2) * Distance
		local CreatePos = CurrentPos + VerticalPos + HorizontalPos
		local CurActor = TestCharaceterPath["equipment" .. tostring(i + 1)]
		local function Callback()
			local TestClass = _G.ObjectMgr:GetClass(CurActor)
			if TestClass then
				CommonUtil.SpawnActor(TestClass, CreatePos)
			end
		end
		_G.ObjectMgr:LoadClassAsync(CurActor, Callback)
	end
end

function SpecialMaterialTest.GetAllTestActor(CurPath)
	local AllActors = _G.UE.TArray(_G.UE.AActor)
	for _, value in pairs(TestCharaceterPath) do
		local TestClass = _G.ObjectMgr:LoadClassSync(value)
		local AllActor = _G.UE.TArray(_G.UE.AActor)
		if TestClass then
			_G.UE.UGameplayStatics.GetAllActorsOfClass(GameplayStaticsUtil.GetWorld(), TestClass, AllActor)
			AllActors:Append(AllActor)
		end

		if CurPath ~= nil and CurPath == value then
			return AllActor
		end
	end

	return AllActors
end

function SpecialMaterialTest.SwitchCharacter(Key)
	if Key ~= SpecialMaterialTest.CurDir and TestCharaceterPath[Key] ~= nil then
		SpecialMaterialTest.CurDir = Key
		SpecialMaterialTest.CurCharaceter = TestCharaceterPath[Key]

		local TestClass = _G.ObjectMgr:LoadClassSync(TestCharaceterPath[Key])
		if TestClass then
			local AllActors = SpecialMaterialTest.GetAllTestActor()
			for i = AllActors:Length(), 1, -1 do
				local Actor = AllActors:GetRef(i)
				CommonUtil.SpawnActor(TestClass, Actor:GetLocation(), Actor:GetRotation())
				CommonUtil.DestroyActor(Actor)
			end
		end
	end
end

function SpecialMaterialTest.SwitchMaterial(MaterialName, bNormal)
	if bNormal == 1 then
		bNormal = true
	else
		bNormal = false
	end
	local AllActors = _G.UE.TArray(0)
	if SpecialMaterialTest.CurDir == "equipment" then
		AllActors = SpecialMaterialTest.GetAllTestActor()
	else
		AllActors = SpecialMaterialTest.GetAllTestActor(SpecialMaterialTest.CurCharaceter)
	end
	for i = 1, AllActors:Length() do
		AllActors:GetRef(i):SwtichMaterial(MaterialName, SpecialMaterialTest.CurDir .. tostring(i % 21), bNormal)
	end
end

function SpecialMaterialTest.MergeEquipmentCharacter()
	local Major = MajorUtil.GetMajor()
	if not Major then return end
	local Distance = 200
	local ForwardVec = Major:GetActorForwardVector()
	local RightVec = Major:GetActorRightVector()
	local CurrentPos = Major:FGetActorLocation() - _G.UE.FVector(0, 0, Major:GetCapsuleHalfHeight())
	SpecialMaterialTest.CurDir = "equipment"
	for i = 0, 19 do
		local Col = i % 5
		local Row = math.floor((i) / 5) + 1

		local VerticalPos =  ForwardVec * Row * Distance
		local HorizontalPos = RightVec * (Col - 2) * Distance
		local CreatePos = CurrentPos + VerticalPos + HorizontalPos
		local CurActor = TestCharaceterPath["equipment" .. tostring(i + 1)]
		local function Callback()
			local TestClass = _G.ObjectMgr:GetClass(CurActor)
			if TestClass then
				local NewCharacter = CommonUtil.SpawnActor(TestClass, CreatePos)
				NewCharacter:MergeAllSKMesh()
			end
		end
		_G.ObjectMgr:LoadClassAsync(CurActor, Callback)
	end
end

return SpecialMaterialTest