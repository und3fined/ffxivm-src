local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local UIUtil = require("Utils/UIUtil")
local CommonDefine = require("Define/CommonDefine")
local MajorUtil = require("Utils/MajorUtil")

local LoginRoleRaceGenderVM = require("Game/LoginRole/LoginRoleRaceGenderVM")
local LoginRoleTribePageVM = require("Game/LoginRole/LoginRoleTribePageVM")
local LoginCreateSaveVM = require("Game/LoginCreate/LoginCreateSaveVM")
local CameraControlDefine = require("Game/Common/Render2D/CameraControlDefine")

local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.Profile.PreLogin.CsPreLoginCmd

local RaceFaceCfg = require("TableCfg/RaceFaceCfg")
local CustomizeFaceCfg = require("TableCfg/CustomizeFaceCfg")
local RacecolorRaceCfg = require("TableCfg/RacecolorRaceCfg")
local RacecolorCommonCfg = require("TableCfg/RacecolorCommonCfg")
local RacecolorRaceUiCfg = require("TableCfg/RacecolorRaceUiCfg")
local RacecolorCommonUiCfg = require("TableCfg/RacecolorCommonUiCfg")
local EmotionCfg = require("TableCfg/EmotionCfg")
local AnimVoiceCfg = require("TableCfg/AnimVoiceCfg")
--local FaceLookatCfg = require("TableCfg/FaceLookatCfg")
local FaceLookatParamCfg = require("TableCfg/FaceLookatParamCfg")

local EmotionAnimUtils = require("Game/Emotion/Common/EmotionAnimUtils")
local EmotionDefines = require("Game/Emotion/Common/EmotionDefines")
local ActorUtil = require("Utils/ActorUtil")

local EyebrowCfg = require("TableCfg/EyebrowCfg")
local EyeCfg = require("TableCfg/EyeCfg")
local FaceCfg = require("TableCfg/FaceCfg")
local FaceContourCfg = require("TableCfg/FaceContourCfg")
local FaceDecalCfg = require("TableCfg/FaceDecalCfg")
local LipsCfg = require("TableCfg/LipsCfg")
local NoseCfg = require("TableCfg/NoseCfg")
local TailCfg = require("TableCfg/TailCfg")
local EarCfg = require("TableCfg/EarCfg")
local HairCfg = require("TableCfg/HairCfg")
local CharaVoiceTypeChsCfg = require("TableCfg/CharaVoiceTypeChsCfg")
local CharaVoiceTypeCfg = require("TableCfg/CharaVoiceTypeCfg")
local GlobalCfg = require("TableCfg/GlobalCfg")

local LoginRoleMainPanelVM = require("Game/LoginRole/LoginRoleMainPanelVM")

local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local EventMgr
local GameNetworkMgr

---@class LoginAvatarMgr : MgrBase
local LoginAvatarMgr = LuaClass(MgrBase)

-- 系统类型
LoginAvatarMgr.FaceSystemType = LoginAvatarMgr.FaceSystemType or
{
	Login = 1, -- 创角捏脸
	Haircut = 2, -- 理发屋
}

--CustomMenueList
LoginAvatarMgr.CustomizeMainMenu = LoginAvatarMgr.CustomizeMainMenu or
{
	Face = 1,		-- 脸
	Eye = 2,		-- 五官
	Decorate = 3,   -- 妆容
	Hair = 4,		-- 头发
	Body = 5,       -- 身体
	Voice = 6,		-- 声音
}
LoginAvatarMgr.CustomizeSubType = LoginAvatarMgr.CustomizeSubType or
{
	FaceBase = 1,           -- 脸-脸部
	SkinColor = 2,          -- 脸-肤色
	FaceContour = 3,       -- 五官-脸部轮廓
	Eye = 4,               -- 五官-眼睛
	Eyebrow = 5,           -- 五官-眉毛
	Nose = 6,              -- 五官-鼻型
	Lips = 7,              -- 五官-嘴型/牙齿
	Ear = 8,               -- 五官-耳朵(形状/大小)
	PupilSize = 9,         -- 妆容-眼瞳,
	EyeColor = 10,         -- 妆容-瞳色(左/右)
	PupilContour = 11,     -- 妆容-瞳孔轮廓(类型/色号)
	ScaleJewelry = 12,     -- 妆容-鳞片饰品
	LipColor = 13,         -- 妆容-唇色(类型/色号)
	FaceDecal = 14,        -- 妆容-面妆(类型/反转)
	FaceDecalColor = 15,   -- 妆容-面妆颜色
	FaceScar = 16,         -- 妆容-胡须/黑痣伤痕
	Tattoo = 17,           -- 妆容-刺青(类型/色号)
	TattooDecor = 18,      -- 妆容-刺青装饰(类型/色号)
	Earring = 19,          -- 妆容-耳饰(类型/色号)
	Hairdo = 20,           -- 头发-发型
	HairColor = 21,        -- 头发-发色(发色/挑染）
	HeightScaleRate = 22,  -- 身体-身高
	BodyType = 23,         -- 身体-体型
	ChestSize = 24,        -- 身体-胸围
	Tail = 25,             -- 身体-尾巴(形状/长度)
	
	Voice = 26             -- 声音
}

LoginAvatarMgr.CustomizeSubMenu = LoginAvatarMgr.CustomizeSubMenu or
{
	-- [LoginAvatarMgr.CustomizeMainMenu.Face] = {"脸部", "肤色"},
	-- [LoginAvatarMgr.CustomizeMainMenu.Eye] = {"脸部轮廓", "眼睛", "眉毛", "鼻型", "嘴型", "耳朵", "牙齿"},
	-- [LoginAvatarMgr.CustomizeMainMenu.Decorate] = {"眼瞳", "瞳色", "瞳孔轮廓", "鳞片饰品", "唇色", "面妆", 
	--                                 "面妆颜色", "胡须伤痕", "黑痣伤痕", "刺青", "刺青装饰", "耳饰"},
	-- [LoginAvatarMgr.CustomizeMainMenu.Hair] = {"发型", "发色"},
	-- [LoginAvatarMgr.CustomizeMainMenu.Body] = {"身高", "体型", "胸围", "尾巴"},
	[LoginAvatarMgr.CustomizeSubType.FaceBase] = {Main = ProtoCommon.avatar_personal.AvatarFaceBase, FocusType = CameraControlDefine.FocusType.Face},
	[LoginAvatarMgr.CustomizeSubType.SkinColor] = {Main = ProtoCommon.avatar_personal.AvatarSkinColor, FocusType = CameraControlDefine.FocusType.Face},

	[LoginAvatarMgr.CustomizeSubType.FaceContour] = {Main = ProtoCommon.avatar_personal.AvatarFaceContour, FocusType = CameraControlDefine.FocusType.Face},
	[LoginAvatarMgr.CustomizeSubType.Eye] = {Main = ProtoCommon.avatar_personal.AvatarEye, FocusType = CameraControlDefine.FocusType.Face},
	[LoginAvatarMgr.CustomizeSubType.Eyebrow] = {Main = ProtoCommon.avatar_personal.AvatarEyeBrow, FocusType = CameraControlDefine.FocusType.Face},
	[LoginAvatarMgr.CustomizeSubType.Nose] = {Main = ProtoCommon.avatar_personal.AvatarNose, FocusType = CameraControlDefine.FocusType.Face},
	[LoginAvatarMgr.CustomizeSubType.Lips] = {Main = ProtoCommon.avatar_personal.AvatarLips, FocusType = CameraControlDefine.FocusType.Face},
	[LoginAvatarMgr.CustomizeSubType.Ear] = {Main = ProtoCommon.avatar_personal.AvatarSpecific2, Sub = ProtoCommon.avatar_personal.AvatarSpecific1, FocusType = CameraControlDefine.FocusType.Face},

	[LoginAvatarMgr.CustomizeSubType.PupilSize] = {Main = ProtoCommon.avatar_personal.AvatarPupilSize, FocusType = CameraControlDefine.FocusType.Face},
	[LoginAvatarMgr.CustomizeSubType.EyeColor] = {Main = ProtoCommon.avatar_personal.AvatarLeftEyeColor, Sub = ProtoCommon.avatar_personal.AvatarRightEyeColor, FocusType = CameraControlDefine.FocusType.Face},
	[LoginAvatarMgr.CustomizeSubType.PupilContour] = {Main = ProtoCommon.avatar_personal.AvatarOption, Sub = ProtoCommon.avatar_personal.AvatarOptionColor, FocusType = CameraControlDefine.FocusType.Face},
	[LoginAvatarMgr.CustomizeSubType.ScaleJewelry] = {Main = ProtoCommon.avatar_personal.AvatarOption, FocusType = CameraControlDefine.FocusType.Face},
	[LoginAvatarMgr.CustomizeSubType.LipColor] = {Main = ProtoCommon.avatar_personal.AvatarLipsColor, Sub = ProtoCommon.avatar_personal.AvatarLipMode, FocusType = CameraControlDefine.FocusType.Face},
	[LoginAvatarMgr.CustomizeSubType.FaceDecal] = {Main = ProtoCommon.avatar_personal.AvatarFaceDecal, Sub = ProtoCommon.avatar_personal.AvatarFaceDecalFlip, FocusType = CameraControlDefine.FocusType.Face},
	[LoginAvatarMgr.CustomizeSubType.FaceDecalColor] = {Main = ProtoCommon.avatar_personal.AvatarFaceDecalColor, FocusType = CameraControlDefine.FocusType.Face},
	[LoginAvatarMgr.CustomizeSubType.FaceScar] = {Main = ProtoCommon.avatar_personal.AvatarOption, FocusType = CameraControlDefine.FocusType.Face},
	[LoginAvatarMgr.CustomizeSubType.Tattoo] = {Main = ProtoCommon.avatar_personal.AvatarOption, Sub = ProtoCommon.avatar_personal.AvatarOptionColor, FocusType = CameraControlDefine.FocusType.Face},
	[LoginAvatarMgr.CustomizeSubType.TattooDecor] = {Main = ProtoCommon.avatar_personal.AvatarOption, Sub = ProtoCommon.avatar_personal.AvatarOptionColor, FocusType = CameraControlDefine.FocusType.Face},
	[LoginAvatarMgr.CustomizeSubType.Earring] = {Main = ProtoCommon.avatar_personal.AvatarOption, Sub = ProtoCommon.avatar_personal.AvatarOptionColor, FocusType = CameraControlDefine.FocusType.Face},

	[LoginAvatarMgr.CustomizeSubType.Hairdo] = {Main = ProtoCommon.avatar_personal.AvatarPersonalHair, FocusType = CameraControlDefine.FocusType.UpperBody},
	[LoginAvatarMgr.CustomizeSubType.HairColor] = {Main = ProtoCommon.avatar_personal.AvatarPersonalHairColor, Sub = ProtoCommon.avatar_personal.AvatarHairVariationColor, 
								    SubChild = ProtoCommon.avatar_personal.AvatarHairVariation, FocusType = CameraControlDefine.FocusType.UpperBody},

	[LoginAvatarMgr.CustomizeSubType.HeightScaleRate] = {Main = ProtoCommon.avatar_personal.AvatarHeightScaleRate, FocusType = CameraControlDefine.FocusType.WholeBody},
	[LoginAvatarMgr.CustomizeSubType.BodyType] = {Main = ProtoCommon.avatar_personal.AvatarSpecific1, FocusType = CameraControlDefine.FocusType.WholeBody},
	[LoginAvatarMgr.CustomizeSubType.ChestSize] = {Main = ProtoCommon.avatar_personal.AvatarChestSize, FocusType = CameraControlDefine.FocusType.WholeBody},
	[LoginAvatarMgr.CustomizeSubType.Tail] = {Main = ProtoCommon.avatar_personal.AvatarSpecific2, Sub = ProtoCommon.avatar_personal.AvatarSpecific1, FocusType = CameraControlDefine.FocusType.WholeBody},

	[LoginAvatarMgr.CustomizeSubType.Voice] = {Main = ProtoCommon.avatar_personal.AvatarVoice, FocusType = CameraControlDefine.FocusType.UpperBody},
}

LoginAvatarMgr.CustomizeCfgName = LoginAvatarMgr.CustomizeCfgName or
{
	[LoginAvatarMgr.CustomizeSubType.FaceBase] = {Cfg = FaceCfg},
	[LoginAvatarMgr.CustomizeSubType.FaceContour] = {Cfg = FaceContourCfg},
	[LoginAvatarMgr.CustomizeSubType.Eye] = {Cfg = EyeCfg},
	[LoginAvatarMgr.CustomizeSubType.Eyebrow] = {Cfg = EyebrowCfg},
	[LoginAvatarMgr.CustomizeSubType.Nose] = {Cfg = NoseCfg},
	[LoginAvatarMgr.CustomizeSubType.Lips] = {Cfg = LipsCfg},
	[LoginAvatarMgr.CustomizeSubType.Ear] = {Cfg = EarCfg},
	[LoginAvatarMgr.CustomizeSubType.FaceDecal] = {Cfg = FaceDecalCfg},
	[LoginAvatarMgr.CustomizeSubType.Hairdo] = {Cfg = HairCfg},
	[LoginAvatarMgr.CustomizeSubType.Tail] = {Cfg = TailCfg},
}

function LoginAvatarMgr:OnInit()
	-- 自定义界面菜单
	self.MainMenuList = {}
	self.SubMenuListMp = {}

	--控件数据
	self.ColorList = {} -- 实际使用的RGB值
	self.UIColorList = {} -- UI使用的RGB值
	-- 音色類型
	self.VoiceTypeList = {}
	--种族身高数据
	self.MinHeight = nil
	self.MaxHeight = nil

	-- 属性数据范围
	self.PropertyCacheList = {}

	-- 数据处理
	self.PresetList = {} -- 预设列表
	self.LastRoleIndex = 1
	self.CurAvatarFace = {} -- 当前捏脸数据
	self.PlayerAvatarFace = {} -- 玩家自定义捏脸数据
	self.PhaseAvatarFace = {} -- 玩家进入捏脸界面的数据
	self.bSelfCustomize = false -- 玩家是否自定义
	self.bUseSelfCustomize = false -- 玩家是否使用自定义
	self.RaceDefaultAvatarFace = {} -- 创角种族默认捏脸数据
	self.LastRoleInform = nil -- 部族性别数据
	--self.LastLookAtInform = nil
	self.LastAttachType = nil
	-- 数据撤销与恢复记录
	self.HistoryRecordList = {}
	self.RedoRecordList = {}

	-- 角色场景
	self.OriginModelLocation = nil

	-- 束发
	self.IsTieUpHair = false

	-- 当前镜头类型
	self.CurFocusType = nil
	self.SpringArmLocation = nil
	self.bResetCamera = false
	self.bLeftCamera = false

	self.SystemType = nil

	self.bSeverSaved = true

	-- 中断恢复
	self.bRecoverFace = false

	-- 流水上报数据
	self.RandomTimes = 0 -- 点击随机的次数

	-- 资源版本号
	self.VersionName = nil

end

function LoginAvatarMgr:OnBegin()
	GameNetworkMgr = _G.GameNetworkMgr
	EventMgr = _G.EventMgr
end

function LoginAvatarMgr:OnEnd()
	self:Reset()
end

function LoginAvatarMgr:OnShutdown()
end

function LoginAvatarMgr:Reset()
	self.MainMenuList = {}
	self.SubMenuListMp = {}
	self.ColorList = {}
	self.UIColorList = {}
	self.VoiceTypeList = {}

	self.MinHeight = nil
	self.MaxHeight = nil

	self.PropertyCacheList = {}

	self.PresetList = {}
	self.LastRoleIndex = 1
	self.CurAvatarFace = {}
	self.PlayerAvatarFace = {}
	self.PhaseAvatarFace = {}
	self.bSelfCustomize = false
	self.bUseSelfCustomize = false
	self.RaceDefaultAvatarFace = {}
	self.LastRoleInform = nil
	--self.LastLookAtInform = nil
	self.LastAttachType = nil

	self.HistoryRecordList = {}
	self.RedoRecordList = {}

	self.OriginModelLocation = nil

	self.IsTieUpHair = false

	self.CurFocusType = nil
	self.SpringArmLocation = nil
	-- 中断恢复
	self.bRecoverFace = false

	self.RandomTimes = 0
end

function LoginAvatarMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.LoginCameraReset, self.OnLoginCameraReset)
end

function LoginAvatarMgr:RaceReset()
	self.MainMenuList = {}
	self.SubMenuListMp = {}

	--控件数据
	self.ColorList = {} -- 实际使用的RGB值
	self.UIColorList = {} -- UI色板使用的RGB值
	--种族身高数据
	self.MinHeight = nil
	self.MaxHeight = nil

	-- 属性数据范围
	self.PropertyCacheList = {}

	-- 数据处理
	self.PresetList = {} -- 预设列表
	self.LastRoleIndex = 1
	--self.CurAvatarFace = {} -- 当前捏脸数据
	self.PlayerAvatarFace = {} -- 玩家自定义捏脸数据
	self.bSelfCustomize = false -- 玩家是否自定义
	self.bUseSelfCustomize = false -- 玩家是否使用自定义

	-- 数据撤销与恢复记录
	self.HistoryRecordList = {}
	self.RedoRecordList = {}

end

function LoginAvatarMgr:ResetParam(Name, bList)
	if bList == true then
		self[Name] = {}
	else
		self[Name] = nil
	end
end

function LoginAvatarMgr:ResetPhaseData()
	self:ResetRecordList()
end

-- 设置系统类型
function LoginAvatarMgr:SetSystemType(Type)
	self.SystemType = Type
end
--TODO 预设一旦修改，自定义选项则发生变化，同时记得操作列表清空（只有预设选项变更及修改后）


-- 获取流水上报信息-捏脸点击随机次数
function LoginAvatarMgr:GetReportRdTimes()
	return self.RandomTimes
end

--获取流水上报信息 -捏类型脸1:预设 2:自定义
function LoginAvatarMgr:GetReportOpType()
	return self.bUseSelfCustomize and 2 or 1
end

-- 获取前阶段设置的角色信息
function LoginAvatarMgr:GetCreateRoleBase()
	local CurrentRaceCfg = LoginRoleRaceGenderVM.CurrentRaceCfg
	local RoleBase = {Gender = CurrentRaceCfg.Gender, RaceID = CurrentRaceCfg.RaceID, RaceName = CurrentRaceCfg.RaceName, TribeName = LoginRoleTribePageVM.TribeName}
	return RoleBase
end

-- 初始捏脸菜单信息
function LoginAvatarMgr:InitMenuData()
	local CurrentRaceCfg = LoginRoleRaceGenderVM.CurrentRaceCfg
	if CurrentRaceCfg == nil then return end
	local AllCustomizeFaceCfg = CustomizeFaceCfg:FindCfgByRaceIDTribeGender(CurrentRaceCfg.RaceID, CurrentRaceCfg.Tribe, CurrentRaceCfg.Gender)
	local MainList = {}
	local SubListMp = {}
	for _, CustomizeCfg in ipairs(AllCustomizeFaceCfg) do
		local MainTile = CustomizeCfg.MainMenu
 
		if  SubListMp[MainTile] == nil then
			SubListMp[MainTile] = {}
			table.insert(MainList, MainTile)
		end
		table.insert(SubListMp[MainTile], {Index = CustomizeCfg.SubType, Name = CustomizeCfg.SubMenu, MaxValue = CustomizeCfg.MaxValue, bCanHaircut = CustomizeCfg.IsCanHaircut})
	end
	self.MainMenuList = MainList
	self.SubMenuListMp = SubListMp
end

function LoginAvatarMgr:GetMainMenuList()
	return self.MainMenuList
end

function LoginAvatarMgr:GetSubMenuList(Name)
	return self.SubMenuListMp[Name]
end


-- 实际颜色
function LoginAvatarMgr:InitColorData()
	local List = {}
	local Low = self:GetRaceColorID(0)
	local High = self:GetRaceColorID(192)
	local ColorRaceCfg = RacecolorRaceCfg:FindRangeColorCfg(Low, High)
	List[ProtoCommon.avatar_personal.AvatarPersonalHairColor] = {}
	List[ProtoCommon.avatar_personal.AvatarSkinColor] = {}
	for _, v in ipairs(ColorRaceCfg) do
		List[ProtoCommon.avatar_personal.AvatarPersonalHairColor][v.ID] = {R = v.HairR, G = v.HairG, B = v.HairB, A = v.HairA}
		List[ProtoCommon.avatar_personal.AvatarSkinColor][v.ID] = {R = v.SkinR, G = v.SkinG, B = v.SkinB, A = v.SkinA}
	end
	local ColorCommonCfg = RacecolorCommonCfg:FindAllColorCfg()
	List[ProtoCommon.avatar_personal.AvatarLeftEyeColor] = {}
	List[ProtoCommon.avatar_personal.AvatarRightEyeColor] = {}
	List[ProtoCommon.avatar_personal.AvatarHairVariationColor] = {}
	List[ProtoCommon.avatar_personal.AvatarLipsColor] = {}
	List[ProtoCommon.avatar_personal.AvatarFaceDecalColor] = {}
	List[ProtoCommon.avatar_personal.AvatarOptionColor] = {}

	for i, v in ipairs(ColorCommonCfg) do
		List[ProtoCommon.avatar_personal.AvatarLeftEyeColor][i] = {R = v.EyeR, G = v.EyeG, B = v.EyeB, A = v.EyeA}
		List[ProtoCommon.avatar_personal.AvatarRightEyeColor][i] = {R = v.EyeR, G = v.EyeG, B = v.EyeB, A = v.EyeA}
		List[ProtoCommon.avatar_personal.AvatarHairVariationColor][i] = {R = v.HairHighlightsR, G = v.HairHighlightsG, B = v.HairHighlightsB, A = v.HairHighlightsA}
		List[ProtoCommon.avatar_personal.AvatarLipsColor][i] = {R = v.LipR, G = v.LipG, B = v.LipB, A = v.LipA}
		List[ProtoCommon.avatar_personal.AvatarFaceDecalColor][i] = {R = v.DecalR, G = v.DecalG, B = v.DecalB, A = v.DecalA}
		List[ProtoCommon.avatar_personal.AvatarOptionColor][i] = {R = v.OptionR, G = v.OptionG, B = v.OptionB, A = v.OptionA}
	end
	self.ColorList = List
end

-- 色板颜色
function LoginAvatarMgr:InitUIColorData()
	local List = {}
	local Low = self:GetRaceColorID(0)
	local High = self:GetRaceColorID(192)
	local ColorRaceCfg = RacecolorRaceUiCfg:FindRangeColorCfg(Low, High)
	List[ProtoCommon.avatar_personal.AvatarPersonalHairColor] = {}
	List[ProtoCommon.avatar_personal.AvatarSkinColor] = {}
	for _, v in ipairs(ColorRaceCfg) do
		List[ProtoCommon.avatar_personal.AvatarPersonalHairColor][v.ID] = {R = v.HairR, G = v.HairG, B = v.HairB, A = v.HairA}
		List[ProtoCommon.avatar_personal.AvatarSkinColor][v.ID] = {R = v.SkinR, G = v.SkinG, B = v.SkinB, A = v.SkinA}
	end
	local ColorCommonCfg = RacecolorCommonUiCfg:FindAllColorCfg()
	List[ProtoCommon.avatar_personal.AvatarLeftEyeColor] = {}
	List[ProtoCommon.avatar_personal.AvatarRightEyeColor] = {}
	List[ProtoCommon.avatar_personal.AvatarHairVariationColor] = {}
	List[ProtoCommon.avatar_personal.AvatarLipsColor] = {}
	List[ProtoCommon.avatar_personal.AvatarFaceDecalColor] = {}
	List[ProtoCommon.avatar_personal.AvatarOptionColor] = {}

	for i, v in ipairs(ColorCommonCfg) do
		List[ProtoCommon.avatar_personal.AvatarLeftEyeColor][i] = {R = v.EyeR, G = v.EyeG, B = v.EyeB, A = v.EyeA}
		List[ProtoCommon.avatar_personal.AvatarRightEyeColor][i] = {R = v.EyeR, G = v.EyeG, B = v.EyeB, A = v.EyeA}
		List[ProtoCommon.avatar_personal.AvatarHairVariationColor][i] = {R = v.HairHighlightsR, G = v.HairHighlightsG, B = v.HairHighlightsB, A = v.HairHighlightsA}
		List[ProtoCommon.avatar_personal.AvatarLipsColor][i] = {R = v.LipR, G = v.LipG, B = v.LipB, A = v.LipA}
		List[ProtoCommon.avatar_personal.AvatarFaceDecalColor][i] = {R = v.DecalR, G = v.DecalG, B = v.DecalB, A = v.DecalA}
		List[ProtoCommon.avatar_personal.AvatarOptionColor][i] = {R = v.OptionR, G = v.OptionG, B = v.OptionB, A = v.OptionA}
	end
	self.UIColorList = List
end

function LoginAvatarMgr:GetColorListByType(Type)
	if self.ColorList == nil then return end
	return self.ColorList[Type]
end

function LoginAvatarMgr:GetUIColorListByType(Type)
	if self.UIColorList == nil then return end
	return self.UIColorList[Type]
end

-- 颜色映射
function LoginAvatarMgr:GetRaceColorID(ColorID)
	local CurrentRaceCfg = LoginRoleRaceGenderVM.CurrentRaceCfg
	if CurrentRaceCfg == nil then return 0 end
	local Race = CurrentRaceCfg.RaceID -1
	local Tribe = CurrentRaceCfg.Tribe
	local Sex = CurrentRaceCfg.Gender == 1 and 0 or 1 -- Gender(1,2):(0,1)
	local bIsSubsp = Tribe%2 == 1 and 0 or 1
	local Prefix = (Race * 2 + bIsSubsp) * 2 + Sex;
	return Prefix * 1000 + ColorID + 1
end

-- 身高处理
function LoginAvatarMgr:InitRaceHeight()
	-- 缩放比例范围
	local MinHeightScale = 1
	local MaxHeightScale = 1
	self.MinHeight = 0
	self.MaxHeight = 0
	local UIComplexCharacter = _G.LoginUIMgr:GetUIComplexCharacter()
	if UIComplexCharacter == nil then return end
	MinHeightScale, MaxHeightScale = UIComplexCharacter:GetHeightScaleRange(MinHeightScale, MaxHeightScale)
	-- 种族的正常身高
	local RaceCfg = LoginRoleRaceGenderVM.CurrentRaceCfg
	if RaceCfg == nil then return end
	local NormalHeight = RaceCfg.Height
	local ModelScaling = RaceCfg.ModelScaling
	if ModelScaling == nil or ModelScaling == 0 then
		ModelScaling = 1
	end
	self.MinHeight = NormalHeight / ModelScaling * MinHeightScale
	self.MaxHeight = NormalHeight / ModelScaling * MaxHeightScale
end

function LoginAvatarMgr:GetRealHeight(Percent)
	local Min =  self.MinHeight
	local Max = self.MaxHeight
	if Min == nil or Max == nil then
		self:InitRaceHeight()
	end
	if Min ~= nil and Max ~= nil then
		return Min + (Max - Min) * Percent
	else
		return 0
	end
end

-- 脸型数据转换
function LoginAvatarMgr:GetFaceBaseFromName(ModelName)
	if ModelName == nil or string.len(ModelName) < 5 then return 0 end
	local ModelString = string.sub(ModelName, -4)
	local ModelID = tonumber(ModelString)
	return ModelID
	-- Refer to FProfileCustomizeData::GetFaceModelName
	-- local CurrentRaceCfg = LoginRoleRaceGenderVM.CurrentRaceCfg
	-- local TribeID = CurrentRaceCfg.Tribe
	-- local FaceID = ModelID
	-- if TribeID == 12 and ModelID <= 100 then -- TRIBE_TYPE_TWILIGHT
	-- 	FaceID = ModelID + 100
	-- elseif TribeID == 16 and ModelID <= 100 then -- TRIBE_TYPE_STRAY
	-- 	FaceID = ModelID + 100
	-- elseif TribeID == 14 and ModelID <= 100 then -- TRIBE_TYPE_MOUNTAIN
	-- 	FaceID = ModelID + 100
	-- end
	-- -- Refer to FProfileCustomizeData::GetFaceID
	-- local bIsSubsp = TribeID%2 == 1 and 0 or 1
	-- local TribeOffset = bIsSubsp * 100
	-- if FaceID <= 100 + TribeOffset then
	-- 	return FaceID - TribeOffset
	-- else
	-- 	return FaceID
	-- end
end
-- 面妆数据转换
function LoginAvatarMgr:GetDecalIDFromName(ModelName)
	if ModelName == nil or string.len(ModelName) == 0 then return 0 end
	local ModelString = string.sub(ModelName, 8, -1)
	return tonumber(ModelString)
end
-- 发型数据转换
function LoginAvatarMgr:GetHairIDFromName(ModelName)
	local HairID = 0
	local StringLen = string.len(ModelName)
	if StringLen > 0 then
		local ModelString = string.sub(ModelName, -StringLen + 1)
		HairID = tonumber(ModelString)
	end
	return HairID
end

-- 音色数据
function LoginAvatarMgr:InitVoiceType()
	local TableList = {}
	local CurrentRaceCfg = LoginRoleRaceGenderVM.CurrentRaceCfg
	if CurrentRaceCfg == nil then
		_G.FLOG_ERROR("InitVoiceType:LoginRoleRaceGenderVM.CurrentRaceCfg is nil")
		return
	end
	if CommonDefine.bChsVersion then
		TableList = CharaVoiceTypeChsCfg:FindCfgByRaceIDTribeGender(CurrentRaceCfg.RaceID, CurrentRaceCfg.Tribe, CurrentRaceCfg.Gender)
	else
		TableList = CharaVoiceTypeCfg:FindCfgByRaceIDTribeGender(CurrentRaceCfg.RaceID, CurrentRaceCfg.Tribe, CurrentRaceCfg.Gender)
	end
	if TableList ~= nil and table.size(TableList) > 0 then
		self.VoiceTypeList = TableList[1].VoiceType
	end
end

function LoginAvatarMgr:GetVoiceTypeList(bCached)
	if self.VoiceTypeList == nil or table.size(self.VoiceTypeList) == 0 or bCached == false then
		self:InitVoiceType()
	end
	return self.VoiceTypeList
end
-- 读表获取属性数据的数据列表
function LoginAvatarMgr:GetPropertyList(SubType)
	local List = self.PropertyCacheList[SubType]
	if List ~= nil or LoginAvatarMgr.CustomizeCfgName[SubType] == nil then return List end
	local TableList = nil
	local TableCfg = LoginAvatarMgr.CustomizeCfgName[SubType].Cfg
	local CurrentRaceCfg = LoginRoleRaceGenderVM.CurrentRaceCfg
	if CurrentRaceCfg == nil then return end
	if SubType == LoginAvatarMgr.CustomizeSubType.Hairdo then
		local CfgList = TableCfg:FindCfgByRaceIDTribeGender(CurrentRaceCfg.RaceID, CurrentRaceCfg.Tribe, CurrentRaceCfg.Gender)
		TableList = self:FilterHairList(CfgList)
	else
		TableList = TableCfg:FindCfgByRaceIDTribeGender(CurrentRaceCfg.RaceID, CurrentRaceCfg.Tribe, CurrentRaceCfg.Gender)
	end
	return TableList
end

-- 筛选发型
function LoginAvatarMgr:FilterHairList(CfgList)
	if CfgList == nil then return CfgList end
	if self.VersionName == nil then
		self:UpdateVersionName()
	end
	local GameVersion = self.VersionName
	local TableList = {}
	for _, Cfg in ipairs(CfgList) do
		local bInlcude = self:IsIncludeVersion(Cfg.VersionName, GameVersion)
		if bInlcude then
			local bLogin = self.SystemType == LoginAvatarMgr.FaceSystemType.Login and Cfg.IsCanCreate == 1
			local bHaircut = self.SystemType == LoginAvatarMgr.FaceSystemType.Haircut and Cfg.HaircutType > 0
			if bLogin or bHaircut then
				table.insert(TableList, Cfg)
			end
		end
	end
	return TableList
end

function LoginAvatarMgr:UpdateVersionName()
	local GameVersionName = GlobalCfg:FindCfgByKey(ProtoRes.global_cfg_id.GLOBAL_CFG_GAME_VERSION)
    local VersionName = GameVersionName.Value
    if not table.is_nil_empty(VersionName) then
        VersionName = string.format("%d.%d.%d",VersionName[1],VersionName[2],VersionName[3])
    else
        _G.FLOG_ERROR("LoginAvatarMgr:GetGameVersionName GameVersionName.Value is nil")
        VersionName = "3.0.0"
    end
	self.VersionName = VersionName
end

function LoginAvatarMgr:IsIncludeVersion(DataVersion, GameVersion)
	local DataValue = string.gsub(DataVersion, '%.', '')
	local GameValue = string.gsub(GameVersion, '%.', '')
	return tonumber(DataValue) <= tonumber(GameValue)
end

-- 获取Option图标
function LoginAvatarMgr:GetOptionIconList(FaceIndex)
	local TableList =self:GetPropertyList(LoginAvatarMgr.CustomizeSubType.FaceBase)
	local IconList = {}
	if TableList ~= nil and TableList[FaceIndex] ~= nil then
		IconList = TableList[FaceIndex].OptionIconList
	end
	return IconList
end
function LoginAvatarMgr:GetOptionIconListByValue(FaceValue)
	local TableList =self:GetPropertyList(LoginAvatarMgr.CustomizeSubType.FaceBase)
	local IconList = {}
	for _, Item in ipairs(TableList) do
		if self:GetFaceBaseFromName(Item.ModelName) == FaceValue then
			IconList = Item.OptionIconList
		end
	end
	return IconList
end
-- 更新创角预设（ Todo Chris那边调用 ）
---@param Tribe number @部族ID
---@param Gender number @性别
---@param ComformCallback function @确定回调
---@param CancelCallback function @取消回调
function LoginAvatarMgr:UpdateRoleFacePreset(Tribe, Gender, ComformCallback, CancelCallback, bReadAvatarRecord)
	-- 理发屋单独处理
	local PWorldInfo = _G.PWorldMgr:GetCurrPWorldTableCfg()
	local bCustomzieHaircut = PWorldInfo and PWorldInfo.MainPanelUIType == _G.LoginMapType.HairCut
	if bCustomzieHaircut then
		self:SetAllAvatarCustomize()
		return
	end

	local CurFaceCfg = RaceFaceCfg:FindCfgByTribeIDAndGender(Tribe, Gender)
	if nil == CurFaceCfg then
		FLOG_ERROR("LoginAvatarMgr:UpdateRoleFacePreset, RaceFaceCfg is nil")
		return
	end
	local PresetList = CurFaceCfg.PresetList
	if nil == PresetList or #PresetList == 0 then
		FLOG_ERROR("LoginAvatarMgr:UpdateRoleFacePreset, PresetList is Empty")
		return
	end
	-- 中断恢复
	if self.bRecoverFace then
		self.LastRoleInform = {Tribe = Tribe, Gender = Gender }
		self:RecoverAvatarFace()
		return
	end
	-- 初始化
	if self.CurAvatarFace == nil or #self.CurAvatarFace == 0 or self.LastRoleInform == nil then
		self:InitRolePreset(PresetList[1]) -- 加载预设表第一个
		self.LastRoleInform = {Tribe = Tribe, Gender = Gender }
		return
	end
	-- 替换
	local function NewComformCallback()
		self:InitRolePreset(PresetList[1])
		self.LastRoleInform = {Tribe = Tribe, Gender = Gender }
		if ComformCallback ~= nil then
			ComformCallback()
		end
	end

	-- 性别/部族切换后且修改了预设数据弹出确定框
	local bChangeRole = self.LastRoleInform.Gender ~= Gender or self.LastRoleInform.Tribe ~= Tribe
	-- if bChangeRole and table.compare_table(self.RaceDefaultAvatarFace, self.CurAvatarFace) == false then
	-- 	local Content = _G.LSTR(980004)
	-- 	_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, _G.LSTR(980022), Content, NewComformCallback, CancelCallback, _G.LSTR(980007), _G.LSTR(980035))
	-- else
	if bChangeRole and not bReadAvatarRecord then
		self:InitRolePreset(PresetList[1])
		self.LastRoleInform = {Tribe = Tribe, Gender = Gender }
		self:SetAllAvatarCustomize()
	else
		self:SetAllAvatarCustomize()
	end
end

--GenderNotChanged在切换种族时传入true,此时上层使用的是种族配置的默认性别男性，并不是实际性别，所以可能会导致弹窗判断逻辑出错，需要特殊处理
function LoginAvatarMgr:CheckUpdateRoleFacePreset(Tribe, Gender, ComformCallback, CancelCallback, GenderNotChanged)
	--幻想药首次切换必定弹窗
	local bFirstFantasiaChange = false
	if _G.LoginUIMgr.IsInFantasia and _G.LoginUIMgr.bFirstChangeAvatar then
		bFirstFantasiaChange = true
	end
	-- 替换
	local function NewComformCallback()
		--确认切换后更新幻想药首次弹窗标记
		_G.LoginUIMgr.bFirstChangeAvatar = false
		if ComformCallback ~= nil then
			ComformCallback()
		end
	end
	
	local function NewCancelCallback()
		if CancelCallback ~= nil then
			CancelCallback()
		end
	end

	local CurFaceCfg = RaceFaceCfg:FindCfgByTribeIDAndGender(Tribe, Gender)
	if nil == CurFaceCfg then
		FLOG_ERROR("LoginAvatarMgr:UpdateRoleFacePreset, RaceFaceCfg is nil")
		NewCancelCallback()

		return
	end

	local PresetList = CurFaceCfg.PresetList
	if nil == PresetList or #PresetList == 0 then
		FLOG_ERROR("LoginAvatarMgr:UpdateRoleFacePreset, PresetList is Empty")
		NewCancelCallback()

		return
	end

	-- 初始化
	if self.CurAvatarFace == nil or #self.CurAvatarFace == 0 or self.LastRoleInform == nil then
		NewComformCallback()
		return
	end

	-- 性别/部族切换后且修改了预设数据弹出确定框
	local bChangeRole = (not GenderNotChanged and self.LastRoleInform.Gender ~= Gender ) or self.LastRoleInform.Tribe ~= Tribe
	if bChangeRole and (bFirstFantasiaChange or table.compare_table(self.RaceDefaultAvatarFace, self.CurAvatarFace) == false) then
		local Content = _G.LSTR(980005)
		_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, _G.LSTR(980022), Content, NewComformCallback
			, NewCancelCallback, _G.LSTR(980007), _G.LSTR(980035), {CloseClickCB = NewCancelCallback})

		return
	end

	NewComformCallback()
end

function LoginAvatarMgr:InitRolePreset(PresetID)
	self:RaceReset() --清空部分数据
	self:SetPresetByID(PresetID)
	if self.CurAvatarFace ~= nil then
		self.RaceDefaultAvatarFace = table.clone(self.CurAvatarFace)
	end
end

-- 加载预设
function LoginAvatarMgr:GetPresetIDList()
	local CurrentRaceCfg = LoginRoleRaceGenderVM.CurrentRaceCfg
	if CurrentRaceCfg == nil then return end
	local CurFaceCfg = RaceFaceCfg:FindCfgByTribeIDAndGender(CurrentRaceCfg.Tribe, CurrentRaceCfg.Gender)
	return CurFaceCfg.PresetList
end

function LoginAvatarMgr:GetPresetIconList()
	local CurrentRaceCfg = LoginRoleRaceGenderVM.CurrentRaceCfg
	if CurrentRaceCfg == nil then return end
	local CurFaceCfg = RaceFaceCfg:FindCfgByTribeIDAndGender(CurrentRaceCfg.Tribe, CurrentRaceCfg.Gender)
	return CurFaceCfg.PresetIcon
end
-- 设置捏脸预设
function LoginAvatarMgr:SetPresetByID(PresetID)
	local Preset = nil
	--local Preset = self.PresetList[PresetID]
	--if Preset == nil then
		local OutPresetMap = _G.UE.TMap(_G.UE.int32, _G.UE.int32)
		local UIComplexCharacter = _G.LoginUIMgr:GetUIComplexCharacter()
		if UIComplexCharacter ~= nil then
			OutPresetMap = UIComplexCharacter:GetAvatarComponent():GetPresetRoleAvatar(PresetID)
			Preset = self:GetCustomizeFromMap(OutPresetMap)
			self.PresetList[PresetID] = Preset
		end
	--end
	self. CurAvatarFace= Preset
	-- 默认音效第一个
	local VoiceKey = ProtoCommon.avatar_personal.AvatarVoice
	local VoiceList = self:GetVoiceTypeList(false)
	if VoiceList ~= nil and table.size(VoiceList) > 0 and self.CurAvatarFace ~= nil then
		self.CurAvatarFace[VoiceKey] = VoiceList[1]
	end
	-- 断点存档
	if self.CurAvatarFace ~= nil then
		--_G.LoginUIMgr.LoginReConnectMgr:SaveValue("AvatarFace", self.CurAvatarFace)
		self:SaveSparseTable("AvatarFace", self.CurAvatarFace)
	end
	if self.IsTieUpHair then
		-- 束发保持发型不变
		self:TieUpHair(true)
	end
end

function LoginAvatarMgr:GetCustomizeFromMap(PresetMap)
	local PresetData = {} -- Todo获取总的
	for key, value in pairs(PresetMap) do
		PresetData[key] = value
	end
	return PresetData
end

-- 预设列表的选项
function LoginAvatarMgr:SetRoleListIndex(Index)
	self.LastRoleIndex = Index
end

function LoginAvatarMgr:GetRoleListIndex()
	return self.LastRoleIndex
end

-- 获取当前的数据
function LoginAvatarMgr:GetCurAvatarFace()
	return self.CurAvatarFace
end

function LoginAvatarMgr:GetCurCustomizeValue(PartKey)
	--self.CurAvatarFace[ProtoCommon.avatar_personal.AvatarFaceBase] = 6 -- test
	if self.CurAvatarFace ~= nil and table.size(self.CurAvatarFace) > 0 then
		return self.CurAvatarFace[PartKey]
	else
		_G.FLOG_ERROR(string.format("[LoginAvatarMgr]GetCurCustomizeValue is null, key is: %d.", PartKey))
		return 0
	end
end

function LoginAvatarMgr:SetCurAvatarFace(CurData)
	if CurData == nil then return end
	if self.CurAvatarFace == nil or table.compare_table(self.CurAvatarFace, CurData) == false then
		self.CurAvatarFace = table.clone(CurData)
		self:SetAllAvatarCustomize()
	end
end

-- 获取玩家自定义数据
function LoginAvatarMgr:GetPlayerAvatarFace()
	return self.PlayerAvatarFace
end

function LoginAvatarMgr:RefreshPlayerAvatarFace()
	self.LastRoleIndex = 0 -- 选中最后一个
	if self.CurAvatarFace ~= nil then
		self.PlayerAvatarFace = table.clone(self.CurAvatarFace)
	end
end

function LoginAvatarMgr:SetPlayerAvatarFace()
	if table.compare_table(self.CurAvatarFace, self.PlayerAvatarFace) == true then return end
	self.CurAvatarFace = table.clone(self.PlayerAvatarFace)
	self:SetAllAvatarCustomize()
end
-- 获取自定义状态
function LoginAvatarMgr:GetSelfCustomize()
	return self.bSelfCustomize
end

function LoginAvatarMgr:SetSelfCustomize(bChanged)
	self.bSelfCustomize = bChanged
end

function LoginAvatarMgr:GetUseSelfCustomize()
	return self.bUseSelfCustomize
end

function LoginAvatarMgr:SetUseSelfCustomize(bChanged)
	self.bUseSelfCustomize = bChanged
end

--获取存档数据
function LoginAvatarMgr:InitServerCustomize()
	-- todo get customize
	--self.PlayerAvatarFace = 
	--self.CurAvatarFace
	self.bSelfCustomize = false
end

-- 数据的撤销与恢复
function LoginAvatarMgr:ResetRecordList()
	self.HistoryRecordList = {}
	self.RedoRecordList = {}
end

-- HisRecord = {PartKey = 0, PartValue = 0, MainIndex = 1, SubIndex = 1, bOperateSub = false, bExtend = false, bUsePart = false}
function LoginAvatarMgr:AddHistory(HisRecord)
	if self.CurAvatarFace == nil or HisRecord == nil then return end
	-- 存入的是每次玩家操作前的一次操作数据或重置操作的一组数据
	local PairValue = (HisRecord.PartKey == 0 or HisRecord.bUsePart) and HisRecord.PartValue or self.CurAvatarFace[HisRecord.PartKey]
	local HistoryPair = {Key = HisRecord, Value = PairValue}
	local HisNum = table.size(self.HistoryRecordList)
	if HisNum > 0 and table.compare_table(HistoryPair, self.HistoryRecordList[HisNum]) then
		-- 重复数据不处理
		return
	end
	table.insert(self.HistoryRecordList, HistoryPair)
	if table.size(self.HistoryRecordList) > 50 then -- 上限50步
		table.remove(self.HistoryRecordList, 1)
	end
	self.RedoRecordList = {}
end

function LoginAvatarMgr:SetRefreshHistory()
	if self.CurAvatarFace == nil then return end
	-- local HistoryNum = table.size(self.HistoryRecordList)
	-- if HistoryNum > 0 then
	-- 	self.HistoryRecordList[HistoryNum] = {Key = 0, Value = table.clone(self.CurAvatarFace)}
	-- end
	--self:AddHistory(0, table.clone(self.CurAvatarFace))
	local HisRecord = {PartKey = 0, PartValue = table.clone(self.CurAvatarFace), bUsePart = false}
	self:AddHistory(HisRecord)
end

function LoginAvatarMgr:UndoAvatar()
	local HisRecord = {}
	if self.CurAvatarFace == nil then return HisRecord end
	-- 撤销操作
	local HistoryNum = table.size(self.HistoryRecordList)
	if HistoryNum > 0 then
		local LastPair = self.HistoryRecordList[HistoryNum]
		local CurPairValue = LastPair.Key.PartKey == 0 and self.CurAvatarFace or self.CurAvatarFace[LastPair.Key.PartKey]
		local CurPair = {Key = LastPair.Key, Value = CurPairValue}
		table.insert(self.RedoRecordList, CurPair)
		table.remove(self.HistoryRecordList, HistoryNum)
		self:OperateAvatar(LastPair.Key.PartKey, LastPair.Value)
		HisRecord = CurPair.Key
	end
	return HisRecord
end

function LoginAvatarMgr:RedoAvatar()
	local HisRecord = {}
	-- 恢复操作
	local RedoNum = table.size(self.RedoRecordList)
	if RedoNum > 0 then
		local LastPair = self.RedoRecordList[RedoNum]
		local CurPairValue = LastPair.Key.PartKey == 0 and self.CurAvatarFace or self.CurAvatarFace[LastPair.Key.PartKey]
		local CurPair = {Key = LastPair.Key, Value = CurPairValue}
		table.insert(self.HistoryRecordList, CurPair)
		table.remove(self.RedoRecordList, RedoNum)
		self:OperateAvatar(LastPair.Key.PartKey, LastPair.Value)
		HisRecord = CurPair.Key
	end
	return HisRecord
end

-- 操作撤销和恢复数据
function LoginAvatarMgr:OperateAvatar(Key, Value)
	if type(Value) == "table" then
		-- 重置操作的历史
		self.CurAvatarFace = table.clone(Value)
		self:SetAllAvatarCustomize()
	else
		self:SetAvatarCustomizeByPart(Key, Value)
	end
end

-- 随机外貌
function LoginAvatarMgr:SetRandomAvatar()
	local RandomAvatar = {}

	local FaceData = self:GetRandomFromTypeList(self:GetPropertyList(LoginAvatarMgr.CustomizeSubType.FaceBase))
	RandomAvatar[ProtoCommon.avatar_personal.AvatarFaceBase] = self:GetFaceBaseFromName(FaceData.ModelName)
	RandomAvatar[ProtoCommon.avatar_personal.AvatarSkinColor] = self:GetRandomFromColorList(false)

	RandomAvatar[ProtoCommon.avatar_personal.AvatarFaceContour] = self:GetRandomFromTypeList(self:GetPropertyList(LoginAvatarMgr.CustomizeSubType.FaceContour)).TypeID
	RandomAvatar[ProtoCommon.avatar_personal.AvatarEye] = self:GetRandomFromTypeList(self:GetPropertyList(LoginAvatarMgr.CustomizeSubType.Eye)).TypeID
	RandomAvatar[ProtoCommon.avatar_personal.AvatarEyeBrow] = self:GetRandomFromTypeList(self:GetPropertyList(LoginAvatarMgr.CustomizeSubType.Eyebrow)).TypeID
	RandomAvatar[ProtoCommon.avatar_personal.AvatarNose] = self:GetRandomFromTypeList(self:GetPropertyList(LoginAvatarMgr.CustomizeSubType.Nose)).TypeID
	RandomAvatar[ProtoCommon.avatar_personal.AvatarLips] = self:GetRandomFromTypeList(self:GetPropertyList(LoginAvatarMgr.CustomizeSubType.Lips)).TypeID
	RandomAvatar[ProtoCommon.avatar_personal.AvatarSpecific1] = math.floor(math.random(1, 101)) - 1
	RandomAvatar[ProtoCommon.avatar_personal.AvatarSpecific2] = math.floor(math.random(1, 4))

	RandomAvatar[ProtoCommon.avatar_personal.AvatarPupilSize] = math.floor(math.random(1, 2)) - 1
	RandomAvatar[ProtoCommon.avatar_personal.AvatarLeftEyeColor] = self:GetRandomFromColorList(false)
	RandomAvatar[ProtoCommon.avatar_personal.AvatarRightEyeColor] = self:GetRandomFromColorList(false)
	RandomAvatar[ProtoCommon.avatar_personal.AvatarOption] = math.floor(math.random(1, 128)) - 1
	RandomAvatar[ProtoCommon.avatar_personal.AvatarOptionColor] = self:GetRandomFromColorList(false)
	RandomAvatar[ProtoCommon.avatar_personal.AvatarLipsColor] = self:GetRandomFromColorList(true)
	RandomAvatar[ProtoCommon.avatar_personal.AvatarLipMode] = math.floor(math.random(1, 3)) - 1
	local DecalData = self:GetRandomFromTypeList(self:GetPropertyList(LoginAvatarMgr.CustomizeSubType.FaceDecal))
	if DecalData ~= nil and type(DecalData) == "table" then
		RandomAvatar[ProtoCommon.avatar_personal.AvatarFaceDecal] = self:GetDecalIDFromName(DecalData.ModelName)
	else
		RandomAvatar[ProtoCommon.avatar_personal.AvatarFaceDecal] = 0
	end
	RandomAvatar[ProtoCommon.avatar_personal.AvatarFaceDecalFlip] = math.floor(math.random(1, 2))
	RandomAvatar[ProtoCommon.avatar_personal.AvatarFaceDecalColor] = self:GetRandomFromColorList(true)

	local HairData = self:GetRandomFromTypeList(self:GetPropertyList(LoginAvatarMgr.CustomizeSubType.Hairdo))
	if HairData ~= nil and type(HairData) == "table" then
		RandomAvatar[ProtoCommon.avatar_personal.AvatarPersonalHair] = self:GetHairIDFromName(HairData.ModelName)
	else
		RandomAvatar[ProtoCommon.avatar_personal.AvatarPersonalHair] = 1
	end
	RandomAvatar[ProtoCommon.avatar_personal.AvatarPersonalHairColor] = self:GetRandomFromColorList(false)
	RandomAvatar[ProtoCommon.avatar_personal.AvatarHairVariation] = (math.floor(math.random(1, 2)) - 1) * 128
	RandomAvatar[ProtoCommon.avatar_personal.AvatarHairVariationColor] = self:GetRandomFromColorList(false)

	RandomAvatar[ProtoCommon.avatar_personal.AvatarHeightScaleRate] = math.floor(math.random(1, 101)) - 1
	RandomAvatar[ProtoCommon.avatar_personal.AvatarChestSize] = math.floor(math.random(1, 101)) - 1
	RandomAvatar[ProtoCommon.avatar_personal.AvatarVoice] = self:GetRandomFromTypeList(self:GetVoiceTypeList(false))
	self.CurAvatarFace = RandomAvatar

	-- Todo
	self:SetAllAvatarCustomize()

	self.RandomTimes = self.RandomTimes + 1
end
-- 类型的随机
function LoginAvatarMgr:GetRandomFromTypeList(ValueList)
	if ValueList == nil then
		return 1
	end
	local ListNum = table.size(ValueList)
	local RandomValue = 1
	if ListNum > 1 then
		local ValueIndex = math.floor(math.random(1, ListNum))
		RandomValue = ValueList[ValueIndex]
	end
	return RandomValue
end
-- 颜色的随机
function LoginAvatarMgr:GetRandomFromColorList(bDoubleColor)
	local ColorIndex = 0
	if bDoubleColor then
		ColorIndex = math.floor(math.random(1, 96)) - 1 + (math.floor(math.random(1, 2)) - 1) * 128
	else
		ColorIndex = math.floor(math.random(1, 192)) - 1
	end
	return ColorIndex
end

-- Todo播放情感动作
function LoginAvatarMgr:PlayEmotion(Index)
	local AnimVoiceTable = AnimVoiceCfg:FindCfg("ID = " .. Index)
    local EmotionCfg = EmotionCfg:FindCfgByKey(AnimVoiceTable.AnimID)
    local UIComplexCharacter = _G.LoginUIMgr:GetUIComplexCharacter()
    if EmotionCfg and UIComplexCharacter then
        local AnimPath = EmotionAnimUtils.GetActorEmotionAnimPath(EmotionCfg.AnimPath
                            , UIComplexCharacter, EmotionDefines.AnimType.EMOT)
        local Render2DView = _G.LoginUIMgr:GetCommonRender2DView()
        if Render2DView then
            _G.AnimMgr:PlayActionTimeLineByActor(UIComplexCharacter, AnimPath, nil)
        end
    end
end
-- Todo播放情感动作,下一帧播放
function LoginAvatarMgr:PlayEmotionNextTick(Index)
	local AnimVoiceTable = AnimVoiceCfg:FindCfg("ID = " .. Index)
    local EmotionCfg = EmotionCfg:FindCfgByKey(AnimVoiceTable.AnimID)
    local UIComplexCharacter = _G.LoginUIMgr:GetUIComplexCharacter()
    if EmotionCfg and UIComplexCharacter then
        local AnimPath = EmotionAnimUtils.GetActorEmotionAnimPath(EmotionCfg.AnimPath
                            , UIComplexCharacter, EmotionDefines.AnimType.EMOT)
        local Render2DView = _G.LoginUIMgr:GetCommonRender2DView()
        if Render2DView then
            _G.AnimMgr:PlayActionTimeLineByActorNextTick(UIComplexCharacter, AnimPath, nil)
        end
    end
end
-------------------------------------------- Deal Model Start -----------------------------------------------------
-- 模型移动
function LoginAvatarMgr:ModelMoveToLeft(bMoveLeft, bReset)
	-- local UIComplexCharacter = _G.LoginUIMgr:GetUIComplexCharacter()
	-- local ModelLocation = self.OriginModelLocation
	-- if bMoveLeft == true then
	-- 	self.OriginModelLocation = UIComplexCharacter:K2_GetActorLocation()
	-- 	ModelLocation = self.OriginModelLocation + _G.UE.FVector(0.0, 18.0, 0.0) -- Todo
	-- end
	-- if ModelLocation ~= nil then
	-- 	local Common_Render2D_UIBP = _G.LoginUIMgr:GetCommonRender2DView()
	-- 	UIComplexCharacter:K2_SetActorLocation(ModelLocation, false, nil, false)
	-- end
	local Common_Render2D_UIBP = _G.LoginUIMgr:GetCommonRender2DView()
	--local SpringArmRotation = Common_Render2D_UIBP:GetSpringArmRotation()
	--self.Common_Render2D_UIBP:SetSpringArmRotation(CameraFocusCfg.Pitch, SpringArmRotation.Yaw, SpringArmRotation.Roll, true)
	--self.Common_Render2D_UIBP:SetCameraFOV(CameraFocusCfg.FOV)
	if Common_Render2D_UIBP == nil or self.SpringArmLocation == nil then return end
	if bMoveLeft == true then
		self.SpringArmLocation = Common_Render2D_UIBP:GetSpringArmLocation()
		self.SpringArmLocation.y = 0 --插值速导致快速点击存在问题
		--if self.SpringArmLocation == nil or self.SpringArmLocation.y < 0 then return end
		Common_Render2D_UIBP:EnableZoom(false)
		-- local CameraParams = Common_Render2D_UIBP:GetCameraControlParams()
		-- if CameraParams == nil then return end

		--local ViewportSize = UIUtil.GetViewportSize()/DPIScale
		--local UIX = ViewportSize.X/2 - 200
		--local UIY = ViewportSize.Y/2
		--local ScreenPos = _G.UE.FVector2D(0, 0)
		--local SpringArmLocation = Common_Render2D_UIBP:GetSpringArmLocation()
		--UIUtil.ProjectWorldLocationToScreen(SpringArmLocation, ScreenPos)
		--UIX = ScreenPos.X - 300
		--UIY = ScreenPos.Y
		--SetCameraFocusScreenLocation的方法有偏差
		--Common_Render2D_UIBP:SetCameraFocusScreenLocation(UIX * DPIScale, UIY * DPIScale, CameraParams.FocusEID, Common_Render2D_UIBP:GetSpringArmDistance())
		-- local DPIScale = _G.UE.UWidgetLayoutLibrary.GetViewportScale(self)
		-- local UIX = 300 * DPIScale --目前固定值，看需求改为配置
		-- local WorldPosition = _G.UE.FVector()
		-- local WorldDirection = _G.UE.FVector()
		-- local ScreenLocation = _G.UE.FVector2D(UIX, 0)
		-- local PlayerIndex = 1
		-- if CommonDefine.NoCreateController == true then
		-- 	PlayerIndex = 0
		-- end
		-- UIUtil.DeprojectScreenToWorld(ScreenLocation, WorldPosition, WorldDirection, PlayerIndex)
		-- WorldPosition = WorldPosition + WorldDirection * Common_Render2D_UIBP:GetSpringArmDistance()
		--local TargetLocation = self.SpringArmLocation - _G.UE.FVector(0, WorldPosition.Y, 0)
		local TargetLocation = self.SpringArmLocation - _G.UE.FVector(0, Common_Render2D_UIBP:GetSpringArmDistance() * 0.22, 0)
		Common_Render2D_UIBP:SetSpringArmLocation(TargetLocation.x, TargetLocation.y, TargetLocation.z, true)
		self.bLeftCamera = true
	elseif self.bLeftCamera == true then
		Common_Render2D_UIBP:EnableZoom(true)
		Common_Render2D_UIBP:SetSpringArmLocation(self.SpringArmLocation.x, self.SpringArmLocation.y, self.SpringArmLocation.z, true)
		self.bLeftCamera = false
	end
	self.bResetCamera = bReset
	--local Location = Common_Render2D_UIBP:GetSpringArmLocation()
	--_G.FLOG_ERROR(string.format("ModelMoveToLeft End: Location Y = %f ditance %f", Location.y, Common_Render2D_UIBP:GetSpringArmDistance()))
end

function LoginAvatarMgr:OnLoginCameraReset()
	if self.bLeftCamera then
		self:ModelMoveToLeft(true, false)
	end
end

function LoginAvatarMgr:InitSpringArm()
	local Common_Render2D_UIBP = _G.LoginUIMgr:GetCommonRender2DView()
	if Common_Render2D_UIBP == nil then return end
	local SpringArmLocation = Common_Render2D_UIBP:GetSpringArmLocation()
	if SpringArmLocation ~= nil and SpringArmLocation.y < 0 then return end
	self.SpringArmLocation = SpringArmLocation
end

function LoginAvatarMgr:ResetSpringArm()
	--local Common_Render2D_UIBP = _G.LoginUIMgr:GetCommonRender2DView()
	--if Common_Render2D_UIBP == nil then return end
	if self.bResetCamera then
		--Common_Render2D_UIBP:SetSpringArmLocation(self.SpringArmLocation.x, self.SpringArmLocation.y, self.SpringArmLocation.z, true)
		--Common_Render2D_UIBP:ResetViewDistance(true)
		local FocusParam = {FocusType = CameraControlDefine.FocusType.WholeBody, bIgnoreAssember = false}
		_G.EventMgr:SendEvent(EventID.LoginCreateCameraChange, FocusParam)
	end
	if self.bLeftCamera == true then
		self:ModelMoveToLeft(true, self.bResetCamera)
	end
end

-- 相机镜头变化
function LoginAvatarMgr:SetCameraFocus(SubType, bReset, bIgnoreAssember)
	local Common_Render2D_UIBP = _G.LoginUIMgr:GetCommonRender2DView()
	if Common_Render2D_UIBP == nil then return end
	if self.SpringArmLocation ~= nil and self.SpringArmLocation ~= Common_Render2D_UIBP:GetSpringArmLocation() and self.bLeftCamera then
		-- 展开色板后镜头参数不被重置
		local FocusParam = {FocusType = nil, bIgnoreAssember = true}
		_G.EventMgr:SendEvent(EventID.LoginCreateCameraChange, FocusParam)
		return
	end
	local InFocusType = nil
	if bReset == true then
		InFocusType = CameraControlDefine.FocusType.WholeBody
	else
		InFocusType = SubType == 0 and CameraControlDefine.FocusType.UpperBody or LoginAvatarMgr.CustomizeSubMenu[SubType].FocusType
	end
	if self.CurFocusType ~= InFocusType then
		local FocusParam = {FocusType = InFocusType, bIgnoreAssember = bIgnoreAssember}
		_G.EventMgr:SendEvent(EventID.LoginCreateCameraChange, FocusParam)
		self.CurFocusType = InFocusType
	end
end

function LoginAvatarMgr:UpdateFocusLocation()
	local Common_Render2D_UIBP = _G.LoginUIMgr:GetCommonRender2DView()
	if Common_Render2D_UIBP ~= nil then
		Common_Render2D_UIBP:UpdateFocusLocation()
	end
end
-------------------------------------------- Deal Model End -----------------------------------------------------
-- 束发处理
function LoginAvatarMgr:TieUpHair(bBind)
	local PartKey = ProtoCommon.avatar_personal.AvatarPersonalHair
	local HairValue = 0
	local CurrentRaceCfg = LoginRoleRaceGenderVM.CurrentRaceCfg
	if CurrentRaceCfg == nil then return end
	if bBind then
		local CurFaceCfg = RaceFaceCfg:FindCfgByTribeIDAndGender(CurrentRaceCfg.Tribe, CurrentRaceCfg.Gender)
		local SpecialID = CurFaceCfg.SpecialHairID
		local CurCfg = HairCfg:FindCfgByID(SpecialID)
		if CurCfg ~= nil then
			HairValue = self:GetHairIDFromName(CurCfg.ModelName)
		end
	elseif self.CurAvatarFace ~= nil and table.size(self.CurAvatarFace) > 0 then
		HairValue = self.CurAvatarFace[PartKey]
	elseif _G.LoginUIMgr:GetCurRolePhase() == LoginRolePhase.SelectRole then
		-- 选角取消束发
		local RoleSimple = LoginRoleMainPanelVM:GetSelectRoleSimple()
		if RoleSimple and RoleSimple.Avatar and RoleSimple.Avatar.Face then
			HairValue = RoleSimple.Avatar.Face[PartKey]
		else
			FLOG_WARNING("LoginAvatarMgr:TieUpHair RoleSimple or RoleSimple.Avatar is Empty")
		end
	end

	local UIComplexCharacter = _G.LoginUIMgr:GetUIComplexCharacter()
	if HairValue ~= nil and HairValue ~= 0 and UIComplexCharacter ~= nil then
		UIComplexCharacter:SetAvatarPartCustomize(PartKey, HairValue, false)
	end
	self.IsTieUpHair = bBind

	if self.bLeftCamera then
		self:SetCameraFocus(0, true, true)
	end
	self.bResetCamera = false
end

function LoginAvatarMgr:GetTieUpHairState()
	return self.IsTieUpHair
end

function LoginAvatarMgr:SetTieUpHairState(bBind)
	self.IsTieUpHair = bBind
end
-- 角色单属性修改外貌
function LoginAvatarMgr:SetAvatarCustomizeByPart(PartKey, Value)
	if self.CurAvatarFace == nil or self.CurAvatarFace[PartKey] == Value then return end
	self.CurAvatarFace[PartKey] = Value
	if PartKey == ProtoCommon.avatar_personal.AvatarPersonalHair and self.IsTieUpHair then
		-- 束发保持发型不变
		local Content = _G.LSTR(980016)
		_G.MsgTipsUtil.ShowTips(Content)
		return
	end
	local UIComplexCharacter = _G.LoginUIMgr:GetUIComplexCharacter()
	if UIComplexCharacter == nil then return end
	UIComplexCharacter:SetAvatarPartCustomize(PartKey, Value, false)
	--_G.FLOG_ERROR(string.format("SetAvatarPartCustomize: PartKey = %d, Value = %d", PartKey, Value))
	-- 断点存档
	--_G.LoginUIMgr.LoginReConnectMgr:SaveValue("AvatarFace", self.CurAvatarFace)
	self:SaveSparseTable("AvatarFace", self.CurAvatarFace)
end

-- 设置所有的捏脸数据形象
function LoginAvatarMgr:SetAllAvatarCustomize()
	local UIComplexCharacter = _G.LoginUIMgr:GetUIComplexCharacter()
	ActorUtil.SetCustomizeAvatarFace(UIComplexCharacter, self.CurAvatarFace)
	if self.IsTieUpHair then
		-- 束发保持发型不变
		self:TieUpHair(true)
		-- local Content = _G.LSTR(980016)
		-- _G.MsgTipsUtil.ShowTips(Content)
	end
	-- 断点存档
	if self.CurAvatarFace ~= nil and table.size(self.CurAvatarFace) > 0 then
		--_G.LoginUIMgr.LoginReConnectMgr:SaveValue("AvatarFace", self.CurAvatarFace)
		self:SaveSparseTable("AvatarFace", self.CurAvatarFace)
	end
end

-- 遊戲內使用
function LoginAvatarMgr:SetMajorAvatarCustomize(CurAvatarFace)
	local MajorCharacter = MajorUtil.GetMajor()
	if MajorCharacter ~= nil and CurAvatarFace ~= nil then
		ActorUtil.SetCustomizeAvatarFace(MajorCharacter, CurAvatarFace)
	end
end

-- 中断数据恢复
function LoginAvatarMgr:RecoverAvatarFace()
	--self.CurAvatarFace = _G.LoginUIMgr.LoginReConnectMgr:GetValue()
	self.CurAvatarFace = self:GetSparseTable("AvatarFace")
	self:EnsureCurAvatarFace()
	self:SetAllAvatarCustomize()
	self:RefreshPlayerAvatarFace() -- 预设出现自定义数据
	self.bRecoverFace = false
	self.bResetCamera = false
	return self.CurAvatarFace
end

-- 中断数据提前预设
function LoginAvatarMgr:RecoverPlayerData()
	--self.CurAvatarFace = _G.LoginUIMgr.LoginReConnectMgr:GetValue("AvatarFace")
	self.CurAvatarFace = self:GetSparseTable("AvatarFace")
	self:RefreshPlayerAvatarFace() -- 预设出现自定义数据
end

-- 确保CurAvatarFace有值
function LoginAvatarMgr:EnsureCurAvatarFace()
	if self.CurAvatarFace == nil or table.size(self.CurAvatarFace) < 26 then
		if self.LastRoleInform == nil then
			local CurrentRaceCfg = LoginRoleRaceGenderVM.CurrentRaceCfg
			self.LastRoleInform = {Tribe = CurrentRaceCfg.Tribe, Gender = CurrentRaceCfg.Gender }
		end
		-- 数据未存取预设
		_G.FLOG_WARNING("LoginAvatarMgr:EnsureCurAvatarFace Get Reconnect Json Data Error! Recover To Preset!")
		local CurFaceCfg = RaceFaceCfg:FindCfgByTribeIDAndGender(self.LastRoleInform.Tribe, self.LastRoleInform.Gender)
		local PresetList = CurFaceCfg.PresetList
		if PresetList ~= nil and table.size(PresetList) > 0 then
			self:InitRolePreset(PresetList[1])
		end
	end
end

function LoginAvatarMgr:SetRecoverFlag()
	self.bRecoverFace = true
end
-- 通用角色外貌设置接口
-- function LoginAvatarMgr:SetAllCustomizeByCharacter(Character, AvatarFace)
-- 	if Character == nil or Character:GetAvatarComponent() == nil then return end
-- 	local FaceMap = _G.UE.TMap(_G.UE.int32, _G.UE.int32)
-- 	for key, value in pairs(AvatarFace) do
-- 		FaceMap:Add(key, value)
-- 	end
-- 	Character:GetAvatarComponent():SetAvatarAllCustomize(FaceMap)
-- end

-- 协议文件参考 cscreateroledata.proto
-----------------------------------------------Rsp start-----------------------------------------------
-- 创角存档数据
-- message CreateRoleFaceInfo
-- {
--   int32 Gender = 1;
--   int32 Race = 2;
--   map<int32, int32> FaceList = 3;
-- }
function LoginAvatarMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PRELOGIN, SUB_MSG_ID.CS_PRELOGIN_CMD_GET, self.OnNetMsgRoleQuery) -- 读档的请求返回
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_PRELOGIN, SUB_MSG_ID.CS_PRELOGIN_FACE_CMD_SAVE, self.OnNetMsgRoleCreate) -- 存档的请求返回
end

function LoginAvatarMgr:OnNetMsgRoleQuery(MsgBody)
	if MsgBody == nil or MsgBody.Get == nil or MsgBody.Get.OpenID ~= tostring(_G.LoginMgr.OpenID) then return end
	-- 无存档则弹出对应的提示
	local FaceData = MsgBody.Get.FaceList
	if (FaceData == nil or #FaceData == 0) and self.bSeverSaved == false then
		local Content = _G.LSTR(980025)
		_G.MsgTipsUtil.ShowTips(Content)
	elseif LoginCreateSaveVM.bFirstShow then
		local Params = {IsSaved = false}
		UIViewMgr:ShowView(UIViewID.LoginCreateSaveWin, Params)
		LoginCreateSaveVM.bFirstShow = false
	else
		self:SetSaveListInform(FaceData)
	end
end

function LoginAvatarMgr:OnNetMsgRoleCreate(MsgBody)
	if MsgBody == nil or MsgBody.Save == nil then return end
	self:SetSaveListInform(MsgBody.Save.FaceList)
	-- 更新保存状态
	LoginCreateSaveVM.bCommited = true
end

function LoginAvatarMgr:SetSaveListInform(DataList)
	if DataList == nil then return end
	local RecordNum = table.size(DataList)
	--最多五条
	while RecordNum > 5 do
		table.remove(DataList, 1)
		RecordNum = RecordNum - 1
	end
	LoginCreateSaveVM.SaveList = DataList
	_G.EventMgr:SendEvent(EventID.LoginCreateFaceSave)
end
-----------------------------------------------Rsp end-----------------------------------------------

-----------------------------------------------Req start-----------------------------------------------
-- 存档 - 请求
-- message CreateRoleInfoReq
-- {
--   map<int32, int32> roleInfo = 1;
--   int32 Gender = 2;
--   int32 Race = 3;
-- }
--- 读档请求
function LoginAvatarMgr:SendMsgRoleQuery()
	--for Name, _, Type in require("pb").types() do print(Name, Type) end
	local SubMsgID = SUB_MSG_ID.CS_PRELOGIN_CMD_GET
	local MsgID = CS_CMD.CS_CMD_PRELOGIN
	local Info = {OpenID = tostring(_G.LoginMgr.OpenID)}
	local MsgBody = {Cmd = SubMsgID, Get = Info}
	--local MsgBody = {Cmd = SubMsgID, WorldID = _G.LoginMgr.WorldID, OpenID = tostring(_G.LoginMgr.OpenID)}
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 存档请求
function LoginAvatarMgr:SendMsgRoleCreate(SaveIndex)
	local CurrentRaceCfg = LoginRoleRaceGenderVM.CurrentRaceCfg
	if CurrentRaceCfg == nil then return end
	if nil == self.CurAvatarFace then
		-- todo 临时
		self:InitRolePreset(CurrentRaceCfg.Tribe, CurrentRaceCfg.Gender)
	end
	local AvatarFace = self.CurAvatarFace
	if table.size(AvatarFace) == 0 then
		local RoleSimple = LoginRoleMainPanelVM:GetSelectRoleSimple()
		if RoleSimple and RoleSimple.Avatar then
			AvatarFace = RoleSimple.Avatar.Face
		end
	end
	local SubMsgID = SUB_MSG_ID.CS_PRELOGIN_FACE_CMD_SAVE
	local MsgID = CS_CMD.CS_CMD_PRELOGIN
	local Face = {ID = SaveIndex, DataList = AvatarFace, Gender = CurrentRaceCfg.Gender, Tribe = CurrentRaceCfg.Tribe, WorldID = _G.LoginMgr.WorldID}
	local Info = {OpenID = tostring(_G.LoginMgr.OpenID), FaceData = Face}
	local MsgBody = {Cmd = SubMsgID, Save = Info}
	-- local MsgBody = {WorldID = _G.LoginMgr.WorldID, OpenID = tostring(_G.LoginMgr.OpenID), ID = SaveIndex,
	-- 	             RoleInfo = self.CurAvatarFace, Gender = CurrentRaceCfg.Gender, Race = CurrentRaceCfg.RaceID, Tribe = CurrentRaceCfg.Tribe
	-- }
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

-----------------------------------------------Req end-----------------------------------------------
-- 存档读档操作
function LoginAvatarMgr:DealServerFace(bSaved)
	self.bSeverSaved = bSaved
	if bSaved then
		local Params = {IsSaved = true}
		UIViewMgr:ShowView(UIViewID.LoginCreateSaveWin, Params)
	else
		self:SendMsgRoleQuery()
		LoginCreateSaveVM.bFirstShow = true
	end

end

--- 加载所选存档
function LoginAvatarMgr:LoadServerAvatar(SaveData)
	local function Callback()
		self.CurAvatarFace = SaveData.DataList
		-- 修改部族的接口
		local TribeID = SaveData.Tribe
		local RaceID = math.floor((TribeID - 1) / 2 + 1)
		--清空缓存的身上穿的套装、职业装
		_G.LoginUIMgr:ClearRoleWearSuit()
		_G.LoginUIMgr:RecordProfSuit(nil)
		
		_G.LoginUIMgr:ChangeRenderActor(RaceID, TribeID, SaveData.Gender, true)
		-- 设置外貌
		self:SetAllAvatarCustomize()

		self.LastRoleInform = {Tribe = TribeID, Gender = SaveData.Gender}
		self:RefreshPlayerAvatarFace()

		-- 如果在自定义界面，直接刷新界面默认菜单第一个
		_G.EventMgr:SendEvent(EventID.LoginCreatFaceServerReset, true)

	end
	local CurrentRaceCfg = LoginRoleRaceGenderVM.CurrentRaceCfg
	if CurrentRaceCfg == nil then return end
	if CurrentRaceCfg.Gender == SaveData.Gender and CurrentRaceCfg.Tribe == SaveData.Tribe then
		self:SetServerAvatar(SaveData)
	else
		local Content = _G.LSTR(980040)
		_G.MsgBoxUtil.ShowMsgBoxTwoOp(self, _G.LSTR(980022), Content, Callback, nil, _G.LSTR(980007), _G.LSTR(980035))
	end
end
-- 处理切换数据后的状态变化
function LoginAvatarMgr:SetServerAvatar(SaveData)
	self.CurAvatarFace = SaveData.DataList
	self:SetAllAvatarCustomize()
	self:RefreshPlayerAvatarFace()
	-- 如果在捏脸界面则刷新界面控件
	_G.EventMgr:SendEvent(EventID.LoginCreatFaceServerReset, false)
end

-- 记录进入捏脸界面前的数据
function LoginAvatarMgr:RecordPhaseAvatar()
	if self.CurAvatarFace ~= nil then
		self.PhaseAvatarFace = table.clone(self.CurAvatarFace)
	end
end

function LoginAvatarMgr:GetPhaseAvatarFace()
	return self.PhaseAvatarFace
end

-- 存捏脸数据，用于中断恢复
function LoginAvatarMgr:SaveSparseTable(Name, AvatarFace)
	-- 将稀疏数组转换为对象 { "1": 10, "3": 30 }
	local Obj = {}
	for k, v in pairs(AvatarFace) do
		if type(k) == "number" then
			Obj[tostring(k)] = v
		else
			Obj[k] = v
		end
	end
	_G.LoginUIMgr.LoginReConnectMgr:SaveValue(Name, Obj)
end

function LoginAvatarMgr:GetSparseTable(Name)
	local AvatarFace = {}
	local Obj = _G.LoginUIMgr.LoginReConnectMgr:GetValue(Name)
	if Obj then
		for k, v in pairs(Obj) do
			AvatarFace[tonumber(k) or k] = v
		end
	end
	return AvatarFace
end

-- 设置创角Lookat的数据
function LoginAvatarMgr:UpdateLookAtLimit()
	local UIComplexCharacter = _G.LoginUIMgr:GetUIComplexCharacter()
	if UIComplexCharacter == nil then return end
	local AvatarComp = UIComplexCharacter:GetAvatarComponent()
    if AvatarComp then
        local AttachType = AvatarComp:GetAttachType()
		if self.LastAttachType == AttachType then return end
		local LookAtCfg = FaceLookatParamCfg:FindCfgByAttachType(AttachType)
		if LookAtCfg and LookAtCfg.LookAtList then
			local BoneList = _G.UE.TMap(_G.UE.FString, _G.UE.FLookAtBoneParam)
			local BoneParam = _G.UE.FLookAtBoneParam()
			for _, value in ipairs(LookAtCfg.LookAtList) do
				BoneParam.Priority = value.Priority
				BoneParam.TotalAngle = value.TotalAngle
				BoneParam.MaxPitch = value.MaxPitch
				BoneParam.MinPitch = value.MinPitch
				BoneParam.MaxYaw = value.MaxYaw
				BoneParam.MinYaw = value.MinYaw
				BoneList:Add(value.BoneName, BoneParam)
			end
			UIComplexCharacter:SetBoneLookAtList(BoneList)
			self.LastAttachType = AttachType
		end
    end
	-- LoginAnim Set Limit
	-- local CurrentRaceCfg = LoginRoleRaceGenderVM.CurrentRaceCfg
	-- if self.LastLookAtInform then
	-- 	if CurrentRaceCfg == nil then return end
	-- 	if self.LastLookAtInform.RaceID == CurrentRaceCfg.RaceID and
	-- 	   self.LastLookAtInform.Tribe == CurrentRaceCfg.Tribe and 
	-- 	   self.LastLookAtInform.Gender == CurrentRaceCfg.Gender then
	-- 		return
	-- 	end
	-- end
	-- local LookAtLimit = nil
	-- local CfgList = FaceLookatCfg:FindCfgByRaceIDTribeGender(CurrentRaceCfg.RaceID, CurrentRaceCfg.Tribe, CurrentRaceCfg.Gender)
	-- 	if CfgList then 
	-- 		local Cfg = CfgList[1]
	-- 		if Cfg then
	-- 			LookAtLimit = {
	-- 				HeadPitchMin = Cfg.HeadPitchMin,
	-- 				HeadPitchMax = Cfg.HeadPitchMax,
	-- 				HeadYawMin = Cfg.HeadYawMin,
	-- 				HeadYawMax = Cfg.HeadYawMax,
	-- 				EyePitchMin = Cfg.EyePitchMin,
	-- 				EyePitchMax = Cfg.EyePitchMax,
	-- 				EyeYawMin = Cfg.EyeYawMin,
	-- 				EyeYawMax = Cfg.EyeYawMax
	-- 			}
	-- 		end
	-- 	end
	-- local UIComplexCharacter = _G.LoginUIMgr:GetUIComplexCharacter()
	-- if UIComplexCharacter then
	-- 	local AnimComp = UIComplexCharacter:GetAnimationComponent()
	-- 	if AnimComp then
	-- 		local AnimInst = AnimComp:GetAnimInstance()
	-- 		if AnimInst and LookAtLimit then
	-- 			AnimInst:SetLookAtLimit(LookAtLimit.HeadYawMin, LookAtLimit.HeadPitchMin, LookAtLimit.HeadYawMax, LookAtLimit.HeadPitchMax)
	-- 			AnimInst:SetLookAtEyeLimit(LookAtLimit.EyeYawMin, LookAtLimit.EyePitchMin, LookAtLimit.EyeYawMax, LookAtLimit.EyePitchMax)
	-- 			self.LastLookAtInform = {RaceID = CurrentRaceCfg.RaceID, Tribe = CurrentRaceCfg.Tribe, Gender = CurrentRaceCfg.Gender}
	-- 		end
	-- 	end
	-- end
end

return LoginAvatarMgr