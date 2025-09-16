local ProtoCommon = require("Protocol/ProtoCommon")
local GUIDE_TYPE = ProtoCommon.GUIDE_TYPE
local LSTR = _G.LSTR

local NPCEmotionID = { YES = 43, NO = 25 }   --Q情感动作表 id
local NPCAuthenticationBubbleText = LSTR(760006)
local GuideResignText = LSTR(760015)

-- GUIDE_TYPE.GUIDE_TYPE_NONE 没有数据时的空界面
local FinishTabs = {
	[ GUIDE_TYPE.GUIDE_TYPE_NONE ] = {
		Type = GUIDE_TYPE.GUIDE_TYPE_NONE, 
		-- MentorMainPanel_UIBP
		TextTitle = LSTR(760022),
		TextTips = LSTR(760024),
		ImgMentorIcon =  "PaperSprite'/Game/UI/Atlas/Mentor/Frames/UI_Mentor_Icon_FightMentor_png.UI_Mentor_Icon_FightMentor_png'",
		ImgAttitude = "Texture2D'/Game/UI/Texture/Mentor/UI_Mentor_Image_WellDone.UI_Mentor_Image_WellDone'",
		-- MentorAuthenticationPanel_UIBP
		AuthenticationPanelTextTips = LSTR(760021),
		AuthenticationPanelImgMentorIcon = "PaperSprite'/Game/UI/Atlas/Mentor/Frames/UI_Mentor_Icon_FightMentor_png.UI_Mentor_Icon_FightMentor_png'",
		MentorTypeText = LSTR(760020),
		UnlockIcon = "Texture2D'/Game/UI/Texture/InfoTips/ContentUnlock/UI_InfoTips_Img_Mentor.UI_InfoTips_Img_Mentor'",
		UnlockIconMask = "Texture2D'/Game/UMG/UI_Effect/Texture/Mask/T_DX_Mask_Mentor.T_DX_Mask_Mentor'",
	},
	[ GUIDE_TYPE.GUIDE_TYPE_FIGHT ] = {
		Type = GUIDE_TYPE.GUIDE_TYPE_FIGHT, 
		-- MentorMainPanel_UIBP
		TextTitle = LSTR(760019),
		TextTips = LSTR(760012),
		ImgMentorIcon = "PaperSprite'/Game/UI/Atlas/Mentor/Frames/UI_Mentor_Icon_FightMentor_png.UI_Mentor_Icon_FightMentor_png'",
		ImgAttitude = "Texture2D'/Game/UI/Texture/Mentor/UI_Mentor_Image_WellDone.UI_Mentor_Image_WellDone'",
		-- MentorAuthenticationPanel_UIBP
		AuthenticationPanelTextTips = LSTR(760018),
		AuthenticationPanelImgMentorIcon = "PaperSprite'/Game/UI/Atlas/Mentor/Frames/UI_Mentor_Icon_FightMentor_png.UI_Mentor_Icon_FightMentor_png'",
		MentorTypeText = LSTR(760017),
		UnlockIcon = "Texture2D'/Game/UI/Texture/InfoTips/ContentUnlock/UI_InfoTips_Img_Mentor.UI_InfoTips_Img_Mentor'",
		UnlockIconMask = "Texture2D'/Game/UMG/UI_Effect/Texture/Mask/T_DX_Mask_Mentor.T_DX_Mask_Mentor'",
	},
	[ GUIDE_TYPE.GUIDE_TYPE_GATHER ] = {
		Type = GUIDE_TYPE.GUIDE_TYPE_GATHER,
		-- MentorMainPanel_UIBP
		TextTitle = LSTR(760010),
		TextTips = LSTR(760011),
		ImgMentorIcon = "PaperSprite'/Game/UI/Atlas/Mentor/Frames/UI_Mentor_Icon_GatherMentor_png.UI_Mentor_Icon_GatherMentor_png'",
		ImgAttitude = "Texture2D'/Game/UI/Texture/Mentor/UI_Mentor_Image_WellDone.UI_Mentor_Image_WellDone'",
		-- MentorAuthenticationPanel_UIBP
		AuthenticationPanelTextTips = LSTR(760009),
		AuthenticationPanelImgMentorIcon = "PaperSprite'/Game/UI/Atlas/Mentor/Frames/UI_Mentor_Icon_GatherMentor_png.UI_Mentor_Icon_GatherMentor_png'",
		MentorTypeText = LSTR(760008),
		UnlockIcon = "Texture2D'/Game/UI/Texture/InfoTips/ContentUnlock/UI_InfoTips_Img_Mentor.UI_InfoTips_Img_Mentor'",
		UnlockIconMask = "Texture2D'/Game/UMG/UI_Effect/Texture/Mask/T_DX_Mask_Mentor.T_DX_Mask_Mentor'",
	},
	[ GUIDE_TYPE.GUIDE_TYPE_SENIOR ] = {
		Type = GUIDE_TYPE.GUIDE_TYPE_SENIOR,
		-- MentorMainPanel_UIBP
		TextTitle = LSTR(760028),
		TextTips = LSTR(760013),
		ImgMentorIcon =  "PaperSprite'/Game/UI/Atlas/Mentor/Frames/UI_Mentor_Icon_Mentor_png.UI_Mentor_Icon_Mentor_png'",
		ImgAttitude = "Texture2D'/Game/UI/Texture/Mentor/UI_Mentor_Image_WellDone.UI_Mentor_Image_WellDone'",
		-- MentorAuthenticationPanel_UIBP
		AuthenticationPanelTextTips = LSTR(760027),
		AuthenticationPanelImgMentorIcon = "PaperSprite'/Game/UI/Atlas/Mentor/Frames/UI_Mentor_Icon_Mentor_png.UI_Mentor_Icon_Mentor_png'",
		MentorTypeText = LSTR(760026),
		UnlockIcon = "Texture2D'/Game/UI/Texture/InfoTips/ContentUnlock/UI_InfoTips_Img_Mentor.UI_InfoTips_Img_Mentor'",
		UnlockIconMask = "Texture2D'/Game/UMG/UI_Effect/Texture/Mask/T_DX_Mask_Mentor.T_DX_Mask_Mentor'",
	},
	[ GUIDE_TYPE.GUIDE_TYPE_RED_FLOWER ] = {
		Type = GUIDE_TYPE.GUIDE_TYPE_RED_FLOWER,
		MentorTypeText = LSTR(760007),
		UnlockIcon = "Texture2D'/Game/UI/Texture/InfoTips/ContentUnlock/UI_InfoTips_Img_LittleRedFlower.UI_InfoTips_Img_LittleRedFlower'",
		UnlockIconMask = "Texture2D'/Game/UMG/UI_Effect/Texture/Mask/T_DX_Mask_LittleRedFlower.T_DX_Mask_LittleRedFlower'",
	}
}

local ProceedTabs = {
	[ GUIDE_TYPE.GUIDE_TYPE_NONE ] = {
		Type = GUIDE_TYPE.GUIDE_TYPE_NONE, 
		-- MentorMainPanel_UIBP
		TextTitle = LSTR(760022),
		TextTips = LSTR(760024),
		ImgMentorIcon =  "PaperSprite'/Game/UI/Atlas/Mentor/Frames/UI_Mentor_Icon_FightMentor_png.UI_Mentor_Icon_FightMentor_png'",
		ImgAttitude = "Texture2D'/Game/UI/Texture/Mentor/UI_Mentor_Image_WellDone.UI_Mentor_Image_WellDone'",
	},
	[ GUIDE_TYPE.GUIDE_TYPE_FIGHT ] = {
		Type = GUIDE_TYPE.GUIDE_TYPE_FIGHT,
		-- MentorMainPanel_UIBP
		TextTitle = LSTR(760019),
		TextTips = LSTR(760004),
		ImgMentorIcon =  "PaperSprite'/Game/UI/Atlas/Mentor/Frames/UI_Mentor_Icon_FightMentor_png.UI_Mentor_Icon_FightMentor_png'",
		ImgAttitude = "Texture2D'/Game/UI/Texture/Mentor/UI_Mentor_Image_KeepGoing.UI_Mentor_Image_KeepGoing'",
	},
	[ GUIDE_TYPE.GUIDE_TYPE_GATHER ] = {
		Type = GUIDE_TYPE.GUIDE_TYPE_GATHER,
		-- MentorMainPanel_UIBP
		TextTitle = LSTR(760010),
		TextTips = LSTR(760003),
		ImgMentorIcon =  "PaperSprite'/Game/UI/Atlas/Mentor/Frames/UI_Mentor_Icon_GatherMentor_png.UI_Mentor_Icon_GatherMentor_png'",
		ImgAttitude = "Texture2D'/Game/UI/Texture/Mentor/UI_Mentor_Image_KeepGoing.UI_Mentor_Image_KeepGoing'",
	},
	[ GUIDE_TYPE.GUIDE_TYPE_SENIOR ] = {
		Type = GUIDE_TYPE.GUIDE_TYPE_SENIOR,
		-- MentorMainPanel_UIBP
		TextTitle = LSTR(760028),
		TextTips = LSTR(760005),
		ImgMentorIcon =  "PaperSprite'/Game/UI/Atlas/Mentor/Frames/UI_Mentor_Icon_Mentor_png.UI_Mentor_Icon_Mentor_png'",
		ImgAttitude = "Texture2D'/Game/UI/Texture/Mentor/UI_Mentor_Image_KeepGoing.UI_Mentor_Image_KeepGoing'",
	},
	[ GUIDE_TYPE.GUIDE_TYPE_RED_FLOWER ] = {
		Type = GUIDE_TYPE.GUIDE_TYPE_RED_FLOWER,
		MentorTypeText = LSTR(760007),
	}
}

local MentorDefine = {
	FinishTabs = FinishTabs,
	ProceedTabs = ProceedTabs,
	GuideType = GUIDE_TYPE,
	NPCEmotionID = NPCEmotionID,
	GuideResignText = GuideResignText,
	NPCAuthenticationBubbleText = NPCAuthenticationBubbleText,
}

return MentorDefine



--[[       指导者多语言id 内容注释
    760001,    --%d天后可重新认证
    760002,    --※辞去指导者未满%d天，无法进行指导者认证
    760003,    --以你的经验不足以担任制作采集指导者啊......\n回去练练再来吧!
    760004,    --以你的经验不足以担任战斗指导者啊......\n回去练练再来吧! 
    760005,    --以你的经验不足以担任资深指导者啊......\n回去练练再来吧!
    760006,    --你愿意担负起指导者的责任吗？
    760007,    --内测指导者
    760008,    --制作采集指导者
    760009,    --制作采集指导者的认证
    760010,    --制作采集指导者的认证情况
    760011,    --太厉害了!!\n你有资格成为制作采集指导者!
    760012,    --太厉害了!!\n你有资格成为战斗指导者!
    760013,    --太厉害了!!\n你有资格成为资深指导者!
    760014,    --已认证
    760015,    --已辞去所有指导者身份
    760016,    --开始认证
	760017,    --战斗指导者
	760018,    --战斗指导者的认证
	760019,    --战斗指导者的认证情况
	760020,    --指导者
	760021,    --指导者的认证
	760022,    --指导者的认证情况
	760023,    --是否辞去指导者身份？ \n所拥有的战斗指导者、制作采集指导者、资深指导者身份将全部辞去
	760024,    --暂没相关数据
	760025,    --认证成功
	760026,    --资深指导者
	760027,    --资深指导者的认证
	760028,    --资深指导者的认证情况
	760029,    --辞去指导者
	760030,    --辞去身份
	760031,    --返回游戏
	760032,    --指导者需要在如下方面起到领头表率作用
	760033,    --· 指导新人了解游戏基本操作 ...
	760034,    --*不当的指导行为存在遭到举报的风险
	760035,    --关于“指导者资格更新”的通知
	760036,    --指导者的认证条件变更了。 ...
	760037,    --*资格更新期若未进行指导者资格的重新认证，更新期结束后指导者资格将自动失效且无法继续使用任何指导者功能，建议尽早进行重新认证。
	760038,    --不再显示此通知
	760039,    --确认认证
	760040,	   --关  闭
]]--
