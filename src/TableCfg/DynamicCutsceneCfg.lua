-- AUTO GENERATED CODE BEGIN, PLEASE DON'T MODIFY

local CfgBase = require("TableCfg/CfgBase")

local CS = {
    _1_1 = 'LevelSequence\'/Game/Assets/Cut/ffxiv/bostit/bostit00010/bostit00110.bostit00110\'',
    _1_2 = 'LevelSequence\'/Game/Assets/Cut/ffxiv/bostit/bostit00120/bostit00120_proj/bostit00120.bostit00120\'',
}

---@class DynamicCutsceneCfg : CfgBase
local DynamicCutsceneCfg = {
	TableName = "c_dynamic_cutscene_cfg",
    LruKeyType = nil,
	KeyName = "ID",
    bEncrypted = false,
	Localization = {
        Config = {}
    },
    DefaultValues = {
        AnimationCondition = 0,
        DisableOcclusionCull = 0,
        FadeOutTime = 1.0,
        FadeOutWhiteColor = 0,
        ForbidLoadLayerSet = 0,
        ForbidLoadLevelStreaming = 0,
        ForbidWaitAvatarLoadFinish = 0,
        ID = 1,
        IsResetFadeWhenStop = 0,
        LoadAllSubLevels = 0,
        SceneCharacterShowType = 0,
        SequencePath = '',
    },
	LuaData = {
        {
            ForbidWaitAvatarLoadFinish = 1,
            LoadAllSubLevels = 1,
            SequencePath = CS._1_1,
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 2,
            LoadAllSubLevels = 1,
            SequencePath = CS._1_2,
        },
        {
            ID = 3,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/bosifr/bosifr00110/bosifr00110_proj/bosifr00110.bosifr00110\'',
        },
        {
            ID = 4,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/bosifr/bosifr00120/bosifr00120_proj/bosifr00120.bosifr00120\'',
        },
        {
            ID = 5,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/bosgar/bosgar00110/bosgar00110_proj/bosgar00110.bosgar00110\'',
        },
        {
            ID = 6,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/bosgar/bosgar00120/bosgar00120_proj/bosgar00120.bosgar00120\'',
        },
        {
            ID = 7,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manwil/manwil00510/manwil00510_proj/manwil00510.manwil00510\'',
        },
        {
            ID = 10,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunsea/dunsea1d110/dunsea1d110_proj/dunsea1d110.dunsea1d110\'',
        },
        {
            ID = 11,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunsea/dunsea1d120/dunsea1d120_proj/dunsea1d120.dunsea1d120\'',
        },
        {
            ID = 12,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunsea/dunsea1d130/dunsea1d130_proj/dunsea1d130.dunsea1d130\'',
        },
        {
            ID = 13,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunfst/dunfst1d110/dunfst1d110_proj/dunfst1d110.dunfst1d110\'',
        },
        {
            ID = 14,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunfst/dunfst1d120/dunfst1d120_proj/dunfst1d120.dunfst1d120\'',
        },
        {
            ID = 15,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunfst/dunfst1d130/dunfst1d130_proj/dunfst1d130.dunfst1d130\'',
        },
        {
            ID = 16,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunwil/dunwil1d110/dunwil1d110_proj/dunwil1d110.dunwil1d110\'',
        },
        {
            ID = 17,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunwil/dunwil1d120/dunwil1d120_proj/dunwil1d120.dunwil1d120\'',
        },
        {
            ID = 18,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunwil/dunwil1d130/dunwil1d130_proj/dunwil1d130.dunwil1d130\'',
        },
        {
            ID = 19,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunfst/dunfst1r110/dunfst1r110.dunfst1r110\'',
        },
        {
            ID = 20,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunfst/dunfst1r120/dunfst1r120.dunfst1r120\'',
        },
        {
            ID = 21,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunfst/dunfst1r130/dunfst1r130.dunfst1r130\'',
        },
        {
            ID = 22,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunfst/dunfst1d210/dunfst1d210_proj/dunfst1d210.dunfst1d210\'',
        },
        {
            ID = 23,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunfst/dunfst1d220/dunfst1d220_proj/dunfst1d220.dunfst1d220\'',
        },
        {
            ID = 24,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunfst/dunfst1d230/dunfst1d230_proj/dunfst1d230.dunfst1d230\'',
        },
        {
            ID = 25,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunsea/dunsea1d210/dunsea1d210.dunsea1d210\'',
        },
        {
            ID = 26,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunsea/dunsea1d220/dunsea1d220.dunsea1d220\'',
        },
        {
            ID = 27,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunsea/dunsea1d230/dunsea1d230.dunsea1d230\'',
        },
        {
            ID = 28,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunroc/dunroc1d110/dunroc1d110_proj/dunroc1d110.dunroc1d110\'',
        },
        {
            ID = 29,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunroc/dunroc1d120/dunroc1d120_proj/dunroc1d120.dunroc1d120\'',
        },
        {
            ID = 30,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunroc/dunroc1d130/dunroc1d130_proj/dunroc1d130.dunroc1d130\'',
        },
        {
            ID = 31,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst50320/manfst50320_proj/manfst50320.manfst50320\'',
        },
        {
            ID = 32,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunwil/dunwil1d502/dunwil1d502_proj/dunwil1d502.dunwil1d502\'',
        },
        {
            ID = 33,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst50310/manfst50310_proj/manfst50310.manfst50310\'',
        },
        {
            ID = 34,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst50323/manfst50323_proj/manfst50323.manfst50323\'',
        },
        {
            ID = 35,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst50220/manfst50220_proj/manfst50220.manfst50220\'',
        },
        {
            ID = 36,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst50230/manfst50230_proj/manfst50230.manfst50230\'',
        },
        {
            ID = 37,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst20940/manfst20940_proj/manfst20940.manfst20940\'',
        },
        {
            ID = 38,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst31220/manfst31220_proj/manfst31220.manfst31220\'',
        },
        {
            ID = 39,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst40460/manfst40460_proj/manfst40460.manfst40460\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 40,
            LoadAllSubLevels = 1,
            SequencePath = CS._1_2,
        },
        {
            ID = 41,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst50330/manfst50330_proj/manfst50330.manfst50330\'',
        },
        {
            ID = 42,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunwil/dunwil1d401/dunwil1d401_proj/dunwil1d401.dunwil1d401\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 43,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/bosult/bosult00010/bosult00010_proj/bosult00010.bosult00010\'',
        },
        {
            ID = 44,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/bosult/bosult00020/bosult00020_proj/bosult00020.bosult00020\'',
        },
        {
            ID = 45,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunlak/dunlak1r120/dunlak1r120_proj/dunlak1r120.dunlak1r120\'',
        },
        {
            ID = 46,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunlak/dunlak1r130/dunlak1r130_proj/dunlak1r130.dunlak1r130\'',
        },
        {
            ID = 47,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunlak/dunlak1r140/dunlak1r140_proj/dunlak1r140.dunlak1r140\'',
        },
        {
            ID = 48,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/subwil/subwil03510/subwil03510_proj/subwil03510.subwil03510\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 54,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manwil/manwil00720/manwil00720_proj/manwil00720.manwil00720\'',
        },
        {
            ID = 55,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manwil/manwil00730/manwil00730_proj/manwil00730.manwil00730\'',
        },
        {
            ID = 56,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manwil/manwil00740/manwil00740_proj/manwil00740.manwil00740\'',
        },
        {
            ID = 67,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst20510/manfst20510_proj/manfst20510.manfst20510\'',
        },
        {
            ID = 68,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst20520/manfst20520_proj/manfst20520.manfst20520\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 69,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst20530/manfst20530_proj/manfst20530.manfst20530\'',
        },
        {
            ID = 70,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst20540/manfst20540_proj/manfst20540.manfst20540\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 77,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst20910/manfst20910_proj/manfst20910.manfst20910\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 78,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst20920/manfst20920_proj/manfst20920.manfst20920\'',
        },
        {
            ID = 79,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst20930/manfst20930_proj/manfst20930.manfst20930\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 89,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst30210/manfst30210_proj/manfst30210.manfst30210\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 90,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/mansea/mansea30210/mansea30210_proj/mansea30210.mansea30210\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 91,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manwil/manwil30210/manwil30210_proj/manwil30210.manwil30210\'',
        },
        {
            ID = 97,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst30610/manfst30610_proj/manfst30610.manfst30610\'',
        },
        {
            ID = 108,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst31210/manfst31210_proj/manfst31210.manfst31210\'',
        },
        {
            ID = 114,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst40210/manfst40210_proj/manfst40210.manfst40210\'',
        },
        {
            ID = 122,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst40450/manfst40450_proj/manfst40450.manfst40450\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 130,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst40610/manfst40610_proj/manfst40610.manfst40610\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 135,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst40620/manfst40620_proj/manfst40620.manfst40620\'',
        },
        {
            ID = 136,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst40630/manfst40630_proj/manfst40630.manfst40630\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 137,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst40720/manfst40720_proj/manfst40720.manfst40720\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 138,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst40730/manfst40730_proj/manfst40730.manfst40730\'',
        },
        {
            ID = 151,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunsea/dunsea1b140/dunsea1b140_proj/dunsea1b140.dunsea1b140\'',
        },
        {
            ID = 152,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunsea/dunsea1b150/dunsea1b150_proj/dunsea1b150.dunsea1b150\'',
        },
        {
            ID = 154,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunsea/dunsea1b530/dunsea1b530_proj/dunsea1b530.dunsea1b530\'',
        },
        {
            ID = 155,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunsea/dunsea1b540/dunsea1b540_proj/dunsea1b540.dunsea1b540\'',
        },
        {
            ID = 157,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunfst/dunfst1b130/dunfst1b130_proj/dunfst1b130.dunfst1b130\'',
        },
        {
            ID = 158,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunfst/dunfst1b140/dunfst1b140_proj/dunfst1b140.dunfst1b140\'',
        },
        {
            ID = 159,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunfst/dunfst1b430/dunfst1b430_proj/dunfst1b430.dunfst1b430\'',
        },
        {
            ID = 160,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunfst/dunfst1b111/dunfst1b111_proj/dunfst1b111.dunfst1b111\'',
        },
        {
            ID = 161,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunfst/dunfst1b421/dunfst1b421_proj/dunfst1b421.dunfst1b421\'',
        },
        {
            ID = 162,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunfst/dunfst1b431/dunfst1b431_proj/dunfst1b431.dunfst1b431\'',
        },
        {
            ID = 163,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunsea/dunsea1b210/dunsea1b210_proj/dunsea1b210.dunsea1b210\'',
        },
        {
            ID = 164,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunsea/dunsea1b220/dunsea1b220_proj/dunsea1b220.dunsea1b220\'',
        },
        {
            ID = 165,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunsea/dunsea1b310/dunsea1b310_proj/dunsea1b310.dunsea1b310\'',
        },
        {
            ID = 166,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunsea/dunsea1b410/dunsea1b410_proj/dunsea1b410.dunsea1b410\'',
        },
        {
            ID = 167,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunsea/dunsea1b420/dunsea1b420_proj/dunsea1b420.dunsea1b420\'',
        },
        {
            ID = 168,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunfst/dunfst1b220/dunfst1b220_proj/dunfst1b220.dunfst1b220\'',
        },
        {
            ID = 169,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunfst/dunfst1b230/dunfst1b230_proj/dunfst1b230.dunfst1b230\'',
        },
        {
            ID = 170,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunfst/dunfst1b240/dunfst1b240_proj/dunfst1b240.dunfst1b240\'',
        },
        {
            ID = 171,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunfst/dunfst1b330/dunfst1b330_proj/dunfst1b330.dunfst1b330\'',
        },
        {
            ID = 172,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunfst/dunfst1b340/dunfst1b340_proj/dunfst1b340.dunfst1b340\'',
        },
        {
            ID = 173,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunfst/dunfst1b221/dunfst1b221_proj/dunfst1b221.dunfst1b221\'',
        },
        {
            ID = 174,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunfst/dunfst1b321/dunfst1b321_proj/dunfst1b321.dunfst1b321\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 176,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobwhm/jobwhm00030/jobwhm00030_proj/jobwhm00030.jobwhm00030\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 177,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobwhm/jobwhm00040/jobwhm00040_proj/jobwhm00040.jobwhm00040\'',
        },
        {
            ID = 178,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clsexc/clsexc05010/clsexc05010_proj/clsexc05010.clsexc05010\'',
        },
        {
            ID = 179,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clsexc/clsexc20010/clsexc20010_proj/clsexc20010.clsexc20010\'',
        },
        {
            DisableOcclusionCull = 1,
            ID = 180,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clsexc/clsexc20020/clsexc20020_proj/clsexc20020.clsexc20020\'',
        },
        {
            ID = 181,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clsexc/clsexc30010/clsexc30010_proj/clsexc30010.clsexc30010\'',
        },
        {
            ID = 182,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clsexc/clsexc30020/clsexc30020_proj/clsexc30020.clsexc30020\'',
        },
        {
            ID = 183,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobwar/jobwar00010/jobwar00010_proj/jobwar00010.jobwar00010\'',
        },
        {
            ID = 184,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobwar/jobwar00020/jobwar00020_proj/jobwar00020.jobwar00020\'',
        },
        {
            ID = 186,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clspgl/clspgl15010/clspgl15010_proj/clspgl15010.clspgl15010\'',
        },
        {
            ID = 187,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clspgl/clspgl20010/clspgl20010_proj/clspgl20010.clspgl20010\'',
        },
        {
            ID = 188,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clspgl/clspgl30010/clspgl30010_proj/clspgl30010.clspgl30010\'',
        },
        {
            ID = 189,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clspgl/clspgl30020/clspgl30020_proj/clspgl30020.clspgl30020\'',
        },
        {
            ID = 190,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobmnk/jobmnk00010/jobmnk00010_proj/jobmnk00010.jobmnk00010\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 192,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clsarc/clsarc00430/clsarc00430_proj/clsarc00430.clsarc00430\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 193,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clsarc/clsarc00440/clsarc00440_proj/clsarc00440.clsarc00440\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 194,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clsarc/clsarc00610/clsarc00610_proj/clsarc00610.clsarc00610\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 195,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clsarc/clsarc00620/clsarc00620_proj/clsarc00620.clsarc00620\'',
        },
        {
            ID = 196,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobblm/jobblm00030/jobblm00030_proj/jobblm00030.jobblm00030\'',
        },
        {
            ID = 197,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobblm/jobblm00040/jobblm00040_proj/jobblm00040.jobblm00040\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 199,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clscnj/clscnj00420/clscnj00420_proj/clscnj00420.clscnj00420\'',
        },
        {
            ID = 200,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clscnj/clscnj00430/clscnj00430_proj/clscnj00430.clscnj00430\'',
        },
        {
            ID = 201,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clscnj/clscnj00610/clscnj00610_proj/clscnj00610.clscnj00610\'',
        },
        {
            ID = 202,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clscnj/clscnj00620/clscnj00620_proj/clscnj00620.clscnj00620\'',
        },
        {
            ID = 203,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobwhm/jobwhm00010/jobwhm00010_proj/jobwhm00010.jobwhm00010\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 205,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clsgla/clsgla15010/clsgla15010_proj/clsgla15010.clsgla15010\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 206,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clsgla/clsgla20010/clsgla20010_proj/clsgla20010.clsgla20010\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 207,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clsgla/clsgla30010/clsgla30010_proj/clsgla30010.clsgla30010\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 208,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clsgla/clsgla30020/clsgla30020_proj/clsgla30020.clsgla30020\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 211,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobdrg/jobdrg00030/jobdrg00030_proj/jobdrg00030.jobdrg00030\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 212,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobdrg/jobdrg00040/jobdrg00040_proj/jobdrg00040.jobdrg00040\'',
        },
        {
            ID = 214,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clsacn/clsacn15010/clsacn15010_proj/clsacn15010.clsacn15010\'',
        },
        {
            ID = 215,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clsacn/clsacn15020/clsacn15020_proj/clsacn15020.clsacn15020\'',
        },
        {
            ID = 217,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clsacn/clsacn30010/clsacn30010_proj/clsacn30010.clsacn30010\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 218,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clsacn/clsacn30020/clsacn30020_proj/clsacn30020.clsacn30020\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 219,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobsmn/jobsmn00010/jobsmn00010_proj/jobsmn00010.jobsmn00010\'',
        },
        {
            ID = 220,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobsch/jobsch00010/jobsch00010_proj/jobsch00010.jobsch00010\'',
        },
        {
            ID = 221,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobpld/jobpld00020/jobpld00020_proj/jobpld00020.jobpld00020\'',
        },
        {
            ID = 222,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobpld/jobpld00030/jobpld00030_proj/jobpld00030.jobpld00030\'',
        },
        {
            ID = 223,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobpld/jobpld00040/jobpld00040_proj/jobpld00040.jobpld00040\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 224,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobpld/jobpld00050/jobpld00050_proj/jobpld00050.jobpld00050\'',
        },
        {
            ID = 226,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clslnc/clslnc00420/clslnc00420_proj/clslnc00420.clslnc00420\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 227,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clslnc/clslnc00430/clslnc00430_proj/clslnc00430.clslnc00430\'',
        },
        {
            ID = 228,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clslnc/clslnc00620/clslnc00620_proj/clslnc00620.clslnc00620\'',
        },
        {
            ID = 229,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clslnc/clslnc00610/clslnc00610_proj/clslnc00610.clslnc00610\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 232,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobmnk/jobmnk00030/jobmnk00030_proj/jobmnk00030.jobmnk00030\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 233,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobmnk/jobmnk00040/jobmnk00040_proj/jobmnk00040.jobmnk00040\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 234,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobsch/jobsch00020/jobsch00020_proj/jobsch00020.jobsch00020\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 235,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobsch/jobsch00030/jobsch00030_proj/jobsch00030.jobsch00030\'',
        },
        {
            ID = 236,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobsch/jobsch00040/jobsch00040_proj/jobsch00040.jobsch00040\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 237,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobsch/jobsch00050/jobsch00050_proj/jobsch00050.jobsch00050\'',
        },
        {
            ID = 238,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobsch/jobsch00060/jobsch00060_proj/jobsch00060.jobsch00060\'',
        },
        {
            ID = 239,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobbrd/jobbrd00010/jobbrd00010_proj/jobbrd00010.jobbrd00010\'',
        },
        {
            ID = 240,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobbrd/jobbrd00020/jobbrd00020_proj/jobbrd00020.jobbrd00020\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 241,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobbrd/jobbrd00030/jobbrd00030_proj/jobbrd00030.jobbrd00030\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 242,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobbrd/jobbrd00040/jobbrd00040_proj/jobbrd00040.jobbrd00040\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 244,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobwar/jobwar00040/jobwar00040_proj/jobwar00040.jobwar00040\'',
        },
        {
            ID = 245,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobwar/jobwar00050/jobwar00050_proj/jobwar00050.jobwar00050\'',
        },
        {
            ID = 246,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobsmn/jobsmn00020/jobsmn00020_proj/jobsmn00020.jobsmn00020\'',
        },
        {
            ID = 247,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobsmn/jobsmn00030/jobsmn00030_proj/jobsmn00030.jobsmn00030\'',
        },
        {
            ID = 248,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobsmn/jobsmn00040/jobsmn00040_proj/jobsmn00040.jobsmn00040\'',
        },
        {
            ID = 249,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobsmn/jobsmn00050/jobsmn00050_proj/jobsmn00050.jobsmn00050\'',
        },
        {
            DisableOcclusionCull = 1,
            ForbidWaitAvatarLoadFinish = 1,
            ID = 250,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobsmn/jobsmn00060/jobsmn00060_proj/jobsmn00060.jobsmn00060\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 251,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobsmn/jobsmn00070/jobsmn00070_proj/jobsmn00070.jobsmn00070\'',
        },
        {
            ID = 253,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clsthm/clsthm15010/clsthm15010_proj/clsthm15010.clsthm15010\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 255,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clsthm/clsthm30010/clsthm30010_proj/clsthm30010.clsthm30010\'',
        },
        {
            ID = 256,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clsthm/clsthm30020/clsthm30020_proj/clsthm30020.clsthm30020\'',
        },
        {
            ID = 273,
        },
        {
            ID = 276,
        },
        {
            ID = 277,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunfst/dunfst1b440/dunfst1b440_proj/dunfst1b440.dunfst1b440\'',
        },
        {
            ID = 279,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunfst/dunfst1b210/dunfst1b210_proj/dunfst1b210.dunfst1b210\'',
        },
        {
            ID = 280,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunfst/dunfst1b320/dunfst1b320_proj/dunfst1b320.dunfst1b320\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 281,
            LoadAllSubLevels = 1,
            SequencePath = CS._1_1,
        },
        {
            ID = 288,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/chofst/chofst00010/chofst00010_proj/chofst00010.chofst00010\'',
        },
        {
            ID = 292,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/chosea/chosea00010/chosea00010_proj/chosea00010.chosea00010\'',
        },
        {
            ID = 293,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manwil/manwil05020/manwil05020_proj/manwil05020.manwil05020\'',
        },
        {
            DisableOcclusionCull = 1,
            ForbidLoadLayerSet = 1,
            ForbidLoadLevelStreaming = 1,
            ID = 294,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manwil/manwil00010/manwil00010_proj/manwil00010.manwil00010\'',
        },
        {
            DisableOcclusionCull = 1,
            ForbidWaitAvatarLoadFinish = 1,
            ID = 295,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manwil/manwil00030/manwil00030_proj/manwil00030.manwil00030\'',
        },
        {
            ID = 297,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst00000/manfst00000_proj/manfst00000.manfst00000\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 298,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manwil/manwil00020/manwil00020_proj/manwil00020.manwil00020\'',
        },
        {
            ID = 299,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst05010/manfst05010_proj/manfst05010.manfst05010\'',
        },
        {
            ID = 302,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/linsea/linsea00010/linsea00010_proj/linsea00010.linsea00010\'',
        },
        {
            ID = 303,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/linsea/linsea00020/linsea00020_proj/linsea00020.linsea00020\'',
        },
        {
            ID = 304,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/linwil/linwil00010/linwil00010_proj/linwil00010.linwil00010\'',
        },
        {
            ID = 305,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/linwil/linwil00020/linwil00020_proj/linwil00020.linwil00020\'',
        },
        {
            ID = 306,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gldttd/gldttd05410/gldttd05410_proj/gldttd05410.gldttd05410\'',
        },
        {
            ID = 307,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/trehnt/trehnt00010/trehnt00010_proj/trehnt00010.trehnt00010\'',
        },
        {
            ID = 308,
            LoadAllSubLevels = 1,
        },
        {
            ID = 309,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunwil/dunwil1d503/dunwil1d503_proj/dunwil1d503.dunwil1d503\'',
        },
        {
            ID = 310,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst50315/manfst50315_proj/manfst50315.manfst50315\'',
        },
        {
            ID = 311,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunwil/dunwil1d506/dunwil1d506_proj/dunwil1d506.dunwil1d506\'',
        },
        {
            ID = 314,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst50335/manfst50335_proj/manfst50335.manfst50335\'',
        },
        {
            ID = 320,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst50328/manfst50328_proj/manfst50328.manfst50328\'',
        },
        {
            ID = 326,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst50120/manfst50120_proj/manfst50120.manfst50120\'',
        },
        {
            ID = 327,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst50130/manfst50130_proj/manfst50130.manfst50130\'',
        },
        {
            ID = 332,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst50125/manfst50125_proj/manfst50125.manfst50125\'',
        },
        {
            ID = 333,
        },
        {
            ID = 334,
        },
        {
            ID = 335,
        },
        {
            ID = 336,
        },
        {
            ID = 337,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gldfst/gldfst1f010/gldfst1f010_proj/gldfst1f010.gldfst1f010\'',
        },
        {
            ID = 338,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gldsea/gldsea1f010/gldsea1f010_proj/gldsea1f010.gldsea1f010\'',
        },
        {
            ID = 339,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gldwil/gldwil1f010/gldwil1f010_proj/gldwil1f010.gldwil1f010\'',
        },
        {
            ID = 340,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv_m/guisea/guisea00010/guisea00010.guisea00010\'',
        },
        {
            ID = 341,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv_m/bostit/bostit00010/bostit00010.bostit00010\'',
        },
        {
            ID = 342,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv_m/bostit/bostit00020/bostit00020.bostit00020\'',
        },
        {
            ID = 343,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/bosifr/bosifr00010/bosifr00010_proj/bosifr00010.bosifr00010\'',
        },
        {
            ID = 344,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/bosifr/bosifr00020/bosifr00020_proj/bosifr00020.bosifr00020\'',
        },
        {
            ID = 345,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/bosgar/bosgar00010/bosgar00010_proj/bosgar00010.bosgar00010\'',
        },
        {
            ID = 346,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/bosgar/bosgar00020/bosgar00020_proj/bosgar00020.bosgar00020\'',
        },
        {
            ID = 347,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunwil/dunwil1d210/dunwil1d210_proj/dunwil1d210.dunwil1d210\'',
        },
        {
            ID = 348,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunwil/dunwil1d220/dunwil1d220_proj/dunwil1d220.dunwil1d220\'',
        },
        {
            ID = 349,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunwil/dunwil1d230/dunwil1d230_proj/dunwil1d230.dunwil1d230\'',
        },
        {
            ID = 350,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunwil/dunwil1d310/dunwil1d310_proj/dunwil1d310.dunwil1d310\'',
        },
        {
            ID = 351,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunwil/dunwil1d320/dunwil1d320_proj/dunwil1d320.dunwil1d320\'',
        },
        {
            ID = 352,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunwil/dunwil1d330/dunwil1d330_proj/dunwil1d330.dunwil1d330\'',
        },
        {
            ID = 353,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunroc/dunroc1r210/dunroc1r210_proj/dunroc1r210.dunroc1r210\'',
        },
        {
            ID = 354,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunroc/dunroc1r220/dunroc1r220_proj/dunroc1r220.dunroc1r220\'',
        },
        {
            ID = 355,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunroc/dunroc1r230/dunroc1r230_proj/dunroc1r230.dunroc1r230\'',
        },
        {
            ID = 356,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv_m/manfst/manfst05011/manfst05011_proj/manfst05011.manfst05011\'',
        },
        {
            ID = 357,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv_m/manwil/manwil00021/manwil00021.manwil00021\'',
        },
        {
            FadeOutWhiteColor = 1,
            ID = 358,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/boslev/boslev00020/boslev00020_proj/boslev00020.boslev00020\'',
        },
        {
            FadeOutWhiteColor = 1,
            ID = 359,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/boslev/boslev00110/boslev00110_proj/boslev00110.boslev00110\'',
        },
        {
            FadeOutWhiteColor = 1,
            ID = 360,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/boslev/boslev00120/boslev00120_proj/boslev00120.boslev00120\'',
        },
        {
            ID = 361,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/bosram/bosram00010/bosram00010_proj/bosram00010.bosram00010\'',
        },
        {
            ID = 362,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/bosram/bosram00020/bosram00020_proj/bosram00020.bosram00020\'',
        },
        {
            ID = 363,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/bosram/bosram00110/bosram00110_proj/bosram00110.bosram00110\'',
        },
        {
            ID = 364,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/bosram/bosram00120/bosram00120_proj/bosram00120.bosram00120\'',
        },
        {
            ID = 365,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv_m/dunfst/dunfst1b421/dunfst1b421_proj/dunfst1b421.dunfst1b421\'',
        },
        {
            ID = 3000000,
            SequencePath = 'LevelSequence\'/Game/EditorRes/StaffRoll/StaffRoll_20000.StaffRoll_20000\'',
        },
        {
            ID = 3000001,
            SequencePath = 'LevelSequence\'/Game/EditorRes/StaffRoll/StaffRoll_30000.StaffRoll_30000\'',
        },
        {
            ID = 3000002,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv_m/manwil/manwil00110/manwil00110_proj/manwil00110.manwil00110\'',
        },
        {
            ID = 3000003,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv_m/dunsea/dunsea1b140/dunsea1b140_proj/dunsea1b140.dunsea1b140\'',
        },
        {
            ID = 3000004,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv_m/dunsea/dunsea1b141/dunsea1b141_proj/dunsea1b141.dunsea1b141\'',
        },
        {
            ID = 8000001,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manwil/manwil00520/manwil00520_proj/manwil00520.manwil00520\'',
        },
        {
            ID = 8000002,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manwil/manwil00540/manwil00540_proj/manwil00540.manwil00540\'',
        },
        {
            ID = 8000003,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/subwil/subwil03520/subwil03520_proj/subwil03520.subwil03520\'',
        },
        {
            ID = 8000004,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/subwil/subwil03530/subwil03530_proj/subwil03530.subwil03530\'',
        },
        {
            ID = 8000005,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/subwil/subwil03540/subwil03540_proj/subwil03540.subwil03540\'',
        },
        {
            ID = 8000006,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manwil/manwil00750/manwil00750_proj/manwil00750.manwil00750\'',
        },
        {
            ID = 8000007,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manwil/manwil00710/manwil00710_proj/manwil00710.manwil00710\'',
        },
        {
            ID = 8000008,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manwil/manwil00745/manwil00745_proj/manwil00745.manwil00745\'',
        },
        {
            ID = 8000009,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manwil/manwil20010/manwil20010_proj/manwil20010.manwil20010\'',
        },
        {
            ID = 8000010,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manwil/manwil20030/manwil20030_proj/manwil20030.manwil20030\'',
        },
        {
            ID = 8000011,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manwil/manwil00910/manwil00910_proj/manwil00910.manwil00910\'',
        },
        {
            ID = 8000012,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manwil/manwil20020/manwil20020_proj/manwil20020.manwil20020\'',
        },
        {
            ID = 8000013,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manwil/manwil20040/manwil20040_proj/manwil20040.manwil20040\'',
        },
        {
            ID = 8000014,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manwil/manwil20000/manwil20000_proj/manwil20000.manwil20000\'',
        },
        {
            ID = 8000015,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manwil/manwil20004/manwil20004_proj/manwil20004.manwil20004\'',
        },
        {
            ID = 8000016,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manwil/manwil00925/manwil00925_proj/manwil00925.manwil00925\'',
        },
        {
            ID = 8000017,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manwil/manwil20002/manwil20002_proj/manwil20002.manwil20002\'',
        },
        {
            ID = 8000019,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst20610/manfst20610_proj/manfst20610.manfst20610\'',
        },
        {
            ID = 8000020,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst20620/manfst20620_proj/manfst20620.manfst20620\'',
        },
        {
            ID = 8000021,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst20630/manfst20630_proj/manfst20630.manfst20630\'',
        },
        {
            ID = 8000022,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/mansea/mansea20540/mansea20540_proj/mansea20540.mansea20540\'',
        },
        {
            ID = 8000023,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manwil/manwil20540/manwil20540_proj/manwil20540.manwil20540\'',
        },
        {
            ID = 8000024,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst20710/manfst20710_proj/manfst20710.manfst20710\'',
        },
        {
            ID = 8000026,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst20950/manfst20950_proj/manfst20950.manfst20950\'',
        },
        {
            ID = 8000027,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst30010/manfst30010_proj/manfst30010.manfst30010\'',
        },
        {
            ID = 8000028,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst30020/manfst30020_proj/manfst30020.manfst30020\'',
        },
        {
            ID = 8000029,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst30030/manfst30030_proj/manfst30030.manfst30030\'',
        },
        {
            ID = 8000030,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst30040/manfst30040_proj/manfst30040.manfst30040\'',
        },
        {
            ID = 8000031,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst30050/manfst30050_proj/manfst30050.manfst30050\'',
        },
        {
            ID = 8000032,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst30025/manfst30025_proj/manfst30025.manfst30025\'',
        },
        {
            ID = 8000033,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst30035/manfst30035_proj/manfst30035.manfst30035\'',
        },
        {
            ID = 8000034,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst30045/manfst30045_proj/manfst30045.manfst30045\'',
        },
        {
            ID = 8000035,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst30310/manfst30310_proj/manfst30310.manfst30310\'',
        },
        {
            ID = 8000036,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/mansea/mansea30310/mansea30310_proj/mansea30310.mansea30310\'',
        },
        {
            ID = 8000037,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst30410/manfst30410_proj/manfst30410.manfst30410\'',
        },
        {
            ID = 8000038,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst30420/manfst30420_proj/manfst30420.manfst30420\'',
        },
        {
            ID = 8000039,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manwil/manwil30310/manwil30310_proj/manwil30310.manwil30310\'',
        },
        {
            ID = 8000041,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst30810/manfst30810_proj/manfst30810.manfst30810\'',
        },
        {
            ID = 8000042,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst30620/manfst30620_proj/manfst30620.manfst30620\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 8000043,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst30630/manfst30630_proj/manfst30630.manfst30630\'',
        },
        {
            ID = 8000044,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst30710/manfst30710_proj/manfst30710.manfst30710\'',
        },
        {
            ID = 8000045,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst30640/manfst30640_proj/manfst30640.manfst30640\'',
        },
        {
            ID = 8000046,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst30910/manfst30910_proj/manfst30910.manfst30910\'',
        },
        {
            ID = 8000047,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst31120/manfst31120_proj/manfst31120.manfst31120\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 8000048,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst31150/manfst31150_proj/manfst31150.manfst31150\'',
        },
        {
            ID = 8000049,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst31320/manfst31320_proj/manfst31320.manfst31320\'',
        },
        {
            ID = 8000050,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst31205/manfst31205_proj/manfst31205.manfst31205\'',
        },
        {
            ID = 8000052,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst31310/manfst31310_proj/manfst31310.manfst31310\'',
        },
        {
            ID = 8000053,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst31330/manfst31330_proj/manfst31330.manfst31330\'',
        },
        {
            ID = 8000054,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst40010/manfst40010_proj/manfst40010.manfst40010\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 8000055,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst31207/manfst31207_proj/manfst31207.manfst31207\'',
        },
        {
            ID = 8000056,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst40110/manfst40110_proj/manfst40110.manfst40110\'',
        },
        {
            ID = 8000058,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst40220/manfst40220_proj/manfst40220.manfst40220\'',
        },
        {
            ID = 8000059,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst40310/manfst40310_proj/manfst40310.manfst40310\'',
        },
        {
            ID = 8000060,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst40410/manfst40410_proj/manfst40410.manfst40410\'',
        },
        {
            ID = 8000061,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst40420/manfst40420_proj/manfst40420.manfst40420\'',
        },
        {
            ID = 8000062,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst40430/manfst40430_proj/manfst40430.manfst40430\'',
        },
        {
            ID = 8000063,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst40440/manfst40440_proj/manfst40440.manfst40440\'',
        },
        {
            ID = 8000064,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst40470/manfst40470_proj/manfst40470.manfst40470\'',
        },
        {
            ID = 8000066,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst40480/manfst40480_proj/manfst40480.manfst40480\'',
        },
        {
            ID = 8000067,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst40445/manfst40445_proj/manfst40445.manfst40445\'',
        },
        {
            ID = 8000068,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst40510/manfst40510_proj/manfst40510.manfst40510\'',
        },
        {
            ID = 8000069,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst40520/manfst40520_proj/manfst40520.manfst40520\'',
        },
        {
            ID = 8000070,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst40530/manfst40530_proj/manfst40530.manfst40530\'',
        },
        {
            ID = 8000071,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst40540/manfst40540_proj/manfst40540.manfst40540\'',
        },
        {
            DisableOcclusionCull = 1,
            ID = 8000072,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst40550/manfst40550_proj/manfst40550.manfst40550\'',
        },
        {
            ID = 8000073,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst40710/manfst40710_proj/manfst40710.manfst40710\'',
        },
        {
            ID = 8000074,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst40740/manfst40740_proj/manfst40740.manfst40740\'',
        },
        {
            ID = 8000075,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst40810/manfst40810_proj/manfst40810.manfst40810\'',
        },
        {
            ID = 8000076,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst40820/manfst40820_proj/manfst40820.manfst40820\'',
        },
        {
            ID = 8000077,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst40750/manfst40750_proj/manfst40750.manfst40750\'',
        },
        {
            ID = 8000078,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst40735/manfst40735_proj/manfst40735.manfst40735\'',
        },
        {
            ID = 8000079,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst40745/manfst40745_proj/manfst40745.manfst40745\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 8000080,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst40705/manfst40705_proj/manfst40705.manfst40705\'',
        },
        {
            ID = 8000081,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst40732/manfst40732_proj/manfst40732.manfst40732\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 8000082,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst50210/manfst50210_proj/manfst50210.manfst50210\'',
        },
        {
            ID = 8000083,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst00530/manfst00530_proj/manfst00530.manfst00530\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 8000084,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst00920/manfst00920_proj/manfst00920.manfst00920\'',
        },
        {
            ID = 8000085,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst20008/manfst20008_proj/manfst20008.manfst20008\'',
        },
        {
            ID = 8000086,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst20006/manfst20006_proj/manfst20006.manfst20006\'',
        },
        {
            ID = 8000087,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/airfst/airfst00020/airfst00020_proj/airfst00020.airfst00020\'',
        },
        {
            ID = 8000088,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobwhm/jobwhm00020/jobwhm00020_proj/jobwhm00020.jobwhm00020\'',
        },
        {
            ID = 8000089,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clspgl/clspgl05010/clspgl05010_proj/clspgl05010.clspgl05010\'',
        },
        {
            ID = 8000090,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clsarc/clsarc00110/clsarc00110_proj/clsarc00110.clsarc00110\'',
        },
        {
            ID = 8000091,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clscnj/clscnj00110/clscnj00110_proj/clscnj00110.clscnj00110\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 8000092,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clsgla/clsgla05010/clsgla05010_proj/clsgla05010.clsgla05010\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 8000093,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobpld/jobpld00010/jobpld00010_proj/jobpld00010.jobpld00010\'',
        },
        {
            ID = 8000094,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobdrg/jobdrg00020/jobdrg00020_proj/jobdrg00020.jobdrg00020\'',
        },
        {
            ID = 8000095,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clsacn/clsacn05010/clsacn05010_proj/clsacn05010.clsacn05010\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 8000096,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clsacn/clsacn25010/clsacn25010_proj/clsacn25010.clsacn25010\'',
        },
        {
            ID = 8000097,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clslnc/clslnc00110/clslnc00110_proj/clslnc00110.clslnc00110\'',
        },
        {
            ID = 8000098,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobdrg/jobdrg00010/jobdrg00010_proj/jobdrg00010.jobdrg00010\'',
        },
        {
            ID = 8000099,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobmnk/jobmnk00020/jobmnk00020_proj/jobmnk00020.jobmnk00020\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 8000100,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobwar/jobwar00030/jobwar00030_proj/jobwar00030.jobwar00030\'',
        },
        {
            ID = 8000101,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clsthm/clsthm05010/clsthm05010_proj/clsthm05010.clsthm05010\'',
        },
        {
            ID = 8000102,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clsthm/clsthm20010/clsthm20010_proj/clsthm20010.clsthm20010\'',
        },
        {
            ID = 8000103,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobblm/jobblm00010/jobblm00010_proj/jobblm00010.jobblm00010\'',
        },
        {
            ID = 8000104,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/jobblm/jobblm00020/jobblm00020_proj/jobblm00020.jobblm00020\'',
        },
        {
            ID = 8000105,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clsfsh/clsfsh50010/clsfsh50010_proj/clsfsh50010.clsfsh50010\'',
        },
        {
            ID = 8000106,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clsmin/clsmin50010/clsmin50010_proj/clsmin50010.clsmin50010\'',
        },
        {
            ID = 8000107,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clswvr/clswvr50010/clswvr50010_proj/clswvr50010.clswvr50010\'',
        },
        {
            ID = 8000108,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clsgld/clsgld50010/clsgld50010_proj/clsgld50010.clsgld50010\'',
        },
        {
            ID = 8000109,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clsbsm/clsbsm50010/clsbsm50010_proj/clsbsm50010.clsbsm50010\'',
        },
        {
            ID = 8000110,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clswdk/clswdk50010/clswdk50010_proj/clswdk50010.clswdk50010\'',
        },
        {
            ID = 8000111,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clsalc/clsalc50010/clsalc50010_proj/clsalc50010.clsalc50010\'',
        },
        {
            ID = 8000112,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clscul/clscul50010/clscul50010_proj/clscul50010.clscul50010\'',
        },
        {
            ID = 8000113,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clshrv/clshrv50010/clshrv50010_proj/clshrv50010.clshrv50010\'',
        },
        {
            ID = 8000114,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clstan/clstan50010/clstan50010_proj/clstan50010.clstan50010\'',
        },
        {
            ID = 8000115,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/clsarm/clsarm50010/clsarm50010_proj/clsarm50010.clsarm50010\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 8000128,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiusd/gaiusd20410/gaiusd20410_proj/gaiusd20410.gaiusd20410\'',
        },
        {
            ID = 8000129,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiusd/gaiusd20310/gaiusd20310_proj/gaiusd20310.gaiusd20310\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 8000130,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiusd/gaiusd20420/gaiusd20420_proj/gaiusd20420.gaiusd20420\'',
        },
        {
            ID = 8000131,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiusd/gaiusd20510/gaiusd20510_proj/gaiusd20510.gaiusd20510\'',
        },
        {
            ID = 8000132,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiusd/gaiusd20520/gaiusd20520_proj/gaiusd20520.gaiusd20520\'',
        },
        {
            ID = 8000133,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiusd/gaiusd20110/gaiusd20110_proj/gaiusd20110.gaiusd20110\'',
        },
        {
            ID = 8000135,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gldwil/gldwil1f410/gldwil1f410_proj/gldwil1f410.gldwil1f410\'',
        },
        {
            DisableOcclusionCull = 1,
            ID = 8000136,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gldwil/gldwil1e010/gldwil1e010_proj/gldwil1e010.gldwil1e010\'',
        },
        {
            ID = 8000137,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/subcts/subcts80110/subcts80110_proj/subcts80110.subcts80110\'',
        },
        {
            DisableOcclusionCull = 1,
            ForbidWaitAvatarLoadFinish = 1,
            ID = 8000142,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manwil/manwil00110/manwil00110_proj/manwil00110.manwil00110\'',
        },
        {
            ID = 8000146,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/chowil/chowil00010/chowil00010_proj/chowil00010.chowil00010\'',
        },
        {
            ID = 8000147,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst20810/manfst20810_proj/manfst20810.manfst20810\'',
        },
        {
            ID = 8000152,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst50325/manfst50325_proj/manfst50325.manfst50325\'',
        },
        {
            ID = 8000154,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst50340/manfst50340_proj/manfst50340.manfst50340\'',
        },
        {
            ForbidWaitAvatarLoadFinish = 1,
            ID = 8000155,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst50345/manfst50345_proj/manfst50345.manfst50345\'',
        },
        {
            ID = 8000156,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst50350/manfst50350_proj/manfst50350.manfst50350\'',
        },
        {
            ID = 8000157,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst50355/manfst50355_proj/manfst50355.manfst50355\'',
        },
        {
            ID = 8000158,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst50360/manfst50360_proj/manfst50360.manfst50360\'',
        },
        {
            ID = 8000160,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst60020/manfst60020_proj/manfst60020.manfst60020\'',
        },
        {
            ID = 8000161,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst60030/manfst60030_proj/manfst60030.manfst60030\'',
        },
        {
            ID = 8000162,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst60040/manfst60040_proj/manfst60040.manfst60040\'',
        },
        {
            ID = 8000163,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst60050/manfst60050_proj/manfst60050.manfst60050\'',
        },
        {
            ID = 8000169,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst60027/manfst60027_proj/manfst60027.manfst60027\'',
        },
        {
            ID = 8000170,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst50342/manfst50342_proj/manfst50342.manfst50342\'',
        },
        {
            ID = 8000179,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst50010/manfst50010_proj/manfst50010.manfst50010\'',
        },
        {
            ID = 8000180,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst50110/manfst50110_proj/manfst50110.manfst50110\'',
        },
        {
            ID = 8000182,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst50135/manfst50135_proj/manfst50135.manfst50135\'',
        },
        {
            ID = 8000183,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/manfst/manfst50140/manfst50140_proj/manfst50140.manfst50140\'',
        },
        {
            ID = 8000184,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/airsea/airsea00010/airsea00010_proj/airsea00010.airsea00010\'',
        },
        {
            ID = 8000190,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse10110/gaiuse10110_proj/gaiuse10110.gaiuse10110\'',
        },
        {
            ID = 8000191,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse10120/gaiuse10120_proj/gaiuse10120.gaiuse10120\'',
        },
        {
            ID = 8000192,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse10410/gaiuse10410_proj/gaiuse10410.gaiuse10410\'',
        },
        {
            ID = 8000193,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse10510/gaiuse10510_proj/gaiuse10510.gaiuse10510\'',
        },
        {
            ID = 8000194,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse11510/gaiuse11510_proj/gaiuse11510.gaiuse11510\'',
        },
        {
            ID = 8000195,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse11810/gaiuse11810_proj/gaiuse11810.gaiuse11810\'',
        },
        {
            ID = 8000196,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse11820/gaiuse11820_proj/gaiuse11820.gaiuse11820\'',
        },
        {
            ID = 8000197,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse11830/gaiuse11830_proj/gaiuse11830.gaiuse11830\'',
        },
        {
            ID = 8000198,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse11850/gaiuse11850_proj/gaiuse11850.gaiuse11850\'',
        },
        {
            ID = 8000199,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse11910/gaiuse11910_proj/gaiuse11910.gaiuse11910\'',
        },
        {
            ID = 8000200,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse11920/gaiuse11920_proj/gaiuse11920.gaiuse11920\'',
        },
        {
            ID = 8000201,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse20110/gaiuse20110_proj/gaiuse20110.gaiuse20110\'',
        },
        {
            ID = 8000202,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse20310/gaiuse20310_proj/gaiuse20310.gaiuse20310\'',
        },
        {
            ID = 8000203,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse20320/gaiuse20320_proj/gaiuse20320.gaiuse20320\'',
        },
        {
            ID = 8000204,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse20810/gaiuse20810_proj/gaiuse20810.gaiuse20810\'',
        },
        {
            ID = 8000205,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse21110/gaiuse21110_proj/gaiuse21110.gaiuse21110\'',
        },
        {
            ID = 8000206,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse21120/gaiuse21120_proj/gaiuse21120.gaiuse21120\'',
        },
        {
            ID = 8000207,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse21130/gaiuse21130_proj/gaiuse21130.gaiuse21130\'',
        },
        {
            ID = 8000208,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse21510/gaiuse21510_proj/gaiuse21510.gaiuse21510\'',
        },
        {
            ID = 8000209,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse21520/gaiuse21520_proj/gaiuse21520.gaiuse21520\'',
        },
        {
            ID = 8000210,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse21610/gaiuse21610_proj/gaiuse21610.gaiuse21610\'',
        },
        {
            ID = 8000211,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse21720/gaiuse21720_proj/gaiuse21720.gaiuse21720\'',
        },
        {
            ID = 8000212,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse21730/gaiuse21730_proj/gaiuse21730.gaiuse21730\'',
        },
        {
            ID = 8000213,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse21910/gaiuse21910_proj/gaiuse21910.gaiuse21910\'',
        },
        {
            ID = 8000214,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse21920/gaiuse21920_proj/gaiuse21920.gaiuse21920\'',
        },
        {
            ID = 8000215,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse30120/gaiuse30120_proj/gaiuse30120.gaiuse30120\'',
        },
        {
            ID = 8000216,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse30410/gaiuse30410_proj/gaiuse30410.gaiuse30410\'',
        },
        {
            ID = 8000217,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse30510/gaiuse30510_proj/gaiuse30510.gaiuse30510\'',
        },
        {
            ID = 8000218,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse30520/gaiuse30520_proj/gaiuse30520.gaiuse30520\'',
        },
        {
            ID = 8000219,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse30530/gaiuse30530_proj/gaiuse30530.gaiuse30530\'',
        },
        {
            ID = 8000220,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse31310/gaiuse31310_proj/gaiuse31310.gaiuse31310\'',
        },
        {
            ID = 8000221,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse31710/gaiuse31710_proj/gaiuse31710.gaiuse31710\'',
        },
        {
            ID = 8000222,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse31720/gaiuse31720_proj/gaiuse31720.gaiuse31720\'',
        },
        {
            ID = 8000223,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse31810/gaiuse31810_proj/gaiuse31810.gaiuse31810\'',
        },
        {
            ID = 8000224,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse31820/gaiuse31820_proj/gaiuse31820.gaiuse31820\'',
        },
        {
            ID = 8000225,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse31230/gaiuse31230_proj/gaiuse31230.gaiuse31230\'',
        },
        {
            ID = 8000226,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse31510/gaiuse31510_proj/gaiuse31510.gaiuse31510\'',
        },
        {
            ID = 8000227,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse31920/gaiuse31920_proj/gaiuse31920.gaiuse31920\'',
        },
        {
            ID = 8000228,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse31110/gaiuse31110_proj/gaiuse31110.gaiuse31110\'',
        },
        {
            ID = 8000229,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse31120/gaiuse31120_proj/gaiuse31120.gaiuse31120\'',
        },
        {
            ID = 8000230,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse31130/gaiuse31130_proj/gaiuse31130.gaiuse31130\'',
        },
        {
            ID = 8000231,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse32010/gaiuse32010_proj/gaiuse32010.gaiuse32010\'',
        },
        {
            ID = 8000232,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse32020/gaiuse32020_proj/gaiuse32020.gaiuse32020\'',
        },
        {
            ID = 8000233,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse31930/gaiuse31930_proj/gaiuse31930.gaiuse31930\'',
        },
        {
            ID = 8000234,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse31935/gaiuse31935_proj/gaiuse31935.gaiuse31935\'',
        },
        {
            FadeOutWhiteColor = 1,
            ID = 8000316,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/pvpmks/pvpmks06000/pvpmks06000_proj/pvpmks06000.pvpmks06000\'',
        },
        {
            FadeOutWhiteColor = 1,
            ID = 8000319,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiusd/gaiusd40110/gaiusd40110_proj/gaiusd40110.gaiusd40110\'',
        },
        {
            FadeOutWhiteColor = 1,
            ID = 8000320,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiusd/gaiusd40120/gaiusd40120_proj/gaiusd40120.gaiusd40120\'',
        },
        {
            FadeOutWhiteColor = 1,
            ID = 8000321,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiusd/gaiusd40130/gaiusd40130_proj/gaiusd40130.gaiusd40130\'',
        },
        {
            FadeOutWhiteColor = 1,
            ID = 8000322,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiusd/gaiusd40140/gaiusd40140_proj/gaiusd40140.gaiusd40140\'',
        },
        {
            FadeOutWhiteColor = 1,
            ID = 8000323,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiusd/gaiusd40150/gaiusd40150_proj/gaiusd40150.gaiusd40150\'',
        },
        {
            FadeOutWhiteColor = 1,
            ID = 8000324,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiusd/gaiusd40160/gaiusd40160_proj/gaiusd40160.gaiusd40160\'',
        },
        {
            FadeOutWhiteColor = 1,
            ID = 8000325,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiusd/gaiusd40170/gaiusd40170_proj/gaiusd40170.gaiusd40170\'',
        },
        {
            ID = 8000361,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv_m/moogle/moogle00020/moogle00020_1.moogle00020_1\'',
        },
        {
            ID = 8000362,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv_m/moogle/moogle00020/moogle00020_2.moogle00020_2\'',
        },
        {
            ID = 8000363,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv_m/moogle/moogle00020/moogle00020_3.moogle00020_3\'',
        },
        {
            ID = 8000364,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv_m/moogle/moogle00020/moogle00020_4.moogle00020_4\'',
        },
        {
            ID = 8000365,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv_m/moogle/moogle00020/moogle00020_5.moogle00020_5\'',
        },
        {
            ID = 8000366,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv_m/moogle/moogle00020/moogle00020_6.moogle00020_6\'',
        },
        {
            ID = 8000367,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv_m/moogle/moogle00020/moogle00020_7.moogle00020_7\'',
        },
        {
            ID = 8000368,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv_m/moogle/moogle00020/moogle00020_8.moogle00020_8\'',
        },
        {
            ID = 8000369,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv_m/moogle/moogle00020/moogle00020_9.moogle00020_9\'',
        },
        {
            ID = 8000370,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv_m/moogle/moogle00020/moogle00020_10.moogle00020_10\'',
        },
        {
            ID = 8000371,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv_m/moogle/moogle00020/moogle00020_11.moogle00020_11\'',
        },
        {
            ID = 8000372,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv_m/moogle/moogle00020/moogle00020_12.moogle00020_12\'',
        },
        {
            ID = 8000373,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv_m/moogle/moogle00020/moogle00020_13.moogle00020_13\'',
        },
        {
            ID = 8000374,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv_m/moogle/moogle00020/moogle00020_14.moogle00020_14\'',
        },
        {
            ID = 8000375,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv_m/moogle/moogle00020/moogle00020_15.moogle00020_15\'',
        },
        {
            ID = 8000376,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv_m/moogle/moogle00020/moogle00020_16.moogle00020_16\'',
        },
        {
            ID = 8000377,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv_m/moogle/moogle00020/moogle00020_17.moogle00020_17\'',
        },
        {
            ID = 8000378,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv_m/moogle/moogle00020/moogle00020_18.moogle00020_18\'',
        },
        {
            ID = 8000379,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv_m/moogle/moogle00020/moogle00020_19.moogle00020_19\'',
        },
        {
            ID = 8000380,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv_m/moogle/moogle00020/moogle00020_20.moogle00020_20\'',
        },
        {
            ID = 8000381,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv_m/moogle/moogle00020/moogle00020_21.moogle00020_21\'',
        },
        {
            ID = 8000382,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv_m/moogle/moogle00020/moogle00020_22.moogle00020_22\'',
        },
        {
            ID = 8000383,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv_m/moogle/moogle00020/moogle00020_23.moogle00020_23\'',
        },
        {
            ID = 8000384,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv_m/moogle/moogle00020/moogle00020_24.moogle00020_24\'',
        },
        {
            ID = 8000385,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv_m/moogle/moogle00020/moogle00020_25.moogle00020_25\'',
        },
        {
            ID = 8000386,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv_m/moogle/moogle00010/moogle00010.moogle00010\'',
        },
        {
            ID = 8000387,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/bosmog/bosmog00010/bosmog00010_proj/bosmog00010.bosmog00010\'',
        },
        {
            ID = 8000388,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/bosmog/bosmog00020/bosmog00020_proj/bosmog00020.bosmog00020\'',
        },
        {
            ID = 8000389,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/gaiuse/gaiuse21710/gaiuse21710_proj/gaiuse21710.gaiuse21710\'',
        },
        {
            ID = 8000392,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunlak/dunlak1r210/dunlak1r210_proj/dunlak1r210.dunlak1r210\'',
        },
        {
            ID = 8000393,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunlak/dunlak1r220/dunlak1r220_proj/dunlak1r220.dunlak1r220\'',
        },
        {
            ID = 8000394,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunlak/dunlak1r230/dunlak1r230_proj/dunlak1r230.dunlak1r230\'',
        },
        {
            ID = 8000395,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunsea/dunsea1b710/dunsea1b710_proj/dunsea1b710.dunsea1b710\'',
        },
        {
            ID = 8000396,
            LoadAllSubLevels = 1,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunfst/dunfst1b420/dunfst1b420_proj/dunfst1b420.dunfst1b420\'',
        },
        {
            ID = 8000399,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunsea/dunsea1b110/dunsea1b110_proj/dunsea1b110.dunsea1b110\'',
        },
        {
            ID = 8000400,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunsea/dunsea1b120/dunsea1b120_proj/dunsea1b120.dunsea1b120\'',
        },
        {
            ID = 8000401,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunsea/dunsea1b130/dunsea1b130_proj/dunsea1b130.dunsea1b130\'',
        },
        {
            ID = 8000402,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunsea/dunsea1b510/dunsea1b510_proj/dunsea1b510.dunsea1b510\'',
        },
        {
            ID = 8000403,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunsea/dunsea1b520/dunsea1b520_proj/dunsea1b520.dunsea1b520\'',
        },
        {
            ID = 8000404,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunsea/dunsea1b720/dunsea1b720_proj/dunsea1b720.dunsea1b720\'',
        },
        {
            ID = 8000405,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunfst/dunfst1b110/dunfst1b110_proj/dunfst1b110.dunfst1b110\'',
        },
        {
            ID = 8000406,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunfst/dunfst1b120/dunfst1b120_proj/dunfst1b120.dunfst1b120\'',
        },
        {
            ID = 8000407,
            SequencePath = 'LevelSequence\'/Game/Assets/Cut/ffxiv/dunfst/dunfst1b510/dunfst1b510_proj/dunfst1b510.dunfst1b510\'',
        },
        {
            ID = 21403809,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21403809.LCut_21403809\'',
        },
        {
            ID = 21404802,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21404802.LCut_21404802\'',
        },
        {
            ID = 21404803,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21404803.LCut_21404803\'',
        },
        {
            ID = 21405902,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21405902.LCut_21405902\'',
        },
        {
            ID = 21405904,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21405904.LCut_21405904\'',
        },
        {
            ID = 21408405,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21408405.LCut_21408405\'',
        },
        {
            ID = 21408406,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21408406.LCut_21408406\'',
        },
        {
            ID = 21409203,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21409203.LCut_21409203\'',
        },
        {
            ID = 21409204,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21409204.LCut_21409204\'',
        },
        {
            ID = 21410204,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21410204.LCut_21410204\'',
        },
        {
            ID = 21522811,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21522811.LCut_21522811\'',
        },
        {
            ID = 21522902,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21522902.LCut_21522902\'',
        },
        {
            ID = 21522903,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21522903.LCut_21522903\'',
        },
        {
            ID = 21523706,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21523706.LCut_21523706\'',
        },
        {
            ID = 21523911,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21523911.LCut_21523911\'',
        },
        {
            ID = 21524404,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21524404.LCut_21524404\'',
        },
        {
            ID = 21525204,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21525204.LCut_21525204\'',
        },
        {
            ID = 21525702,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21525702.LCut_21525702\'',
        },
        {
            ID = 21603010,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21603010.LCut_21603010\'',
        },
        {
            ID = 21603110,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21603110.LCut_21603110\'',
        },
        {
            ID = 21603210,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21603210.LCut_21603210\'',
        },
        {
            ID = 21604404,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21604404.LCut_21604404\'',
        },
        {
            ID = 21604405,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21604405.LCut_21604405\'',
        },
        {
            ID = 21605105,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21605105.LCut_21605105\'',
        },
        {
            ID = 21605106,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21605106.LCut_21605106\'',
        },
        {
            ID = 21606907,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21606907.LCut_21606907\'',
        },
        {
            ID = 21606908,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21606908.LCut_21606908\'',
        },
        {
            ID = 21608102,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21608102.LCut_21608102\'',
        },
        {
            ID = 21720609,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21720609.LCut_21720609\'',
        },
        {
            ID = 21720901,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21720901.LCut_21720901\'',
        },
        {
            ID = 21720902,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21720902.LCut_21720902\'',
        },
        {
            ID = 21721120,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21721120.LCut_21721120\'',
        },
        {
            ID = 21721701,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21721701.LCut_21721701\'',
        },
        {
            ID = 21721901,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21721901.LCut_21721901\'',
        },
        {
            ID = 21721902,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21721902.LCut_21721902\'',
        },
        {
            ID = 21723601,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21723601.LCut_21723601\'',
        },
        {
            ID = 21724001,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21724001.LCut_21724001\'',
        },
        {
            ID = 21724002,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21724002.LCut_21724002\'',
        },
        {
            ID = 21724003,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21724003.LCut_21724003\'',
        },
        {
            ID = 21724201,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21724201.LCut_21724201\'',
        },
        {
            ID = 21724701,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21724701.LCut_21724701\'',
        },
        {
            ID = 21725601,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21725601.LCut_21725601\'',
        },
        {
            ID = 21725801,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21725801.LCut_21725801\'',
        },
        {
            ID = 21725802,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21725802.LCut_21725802\'',
        },
        {
            ID = 21725901,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21725901.LCut_21725901\'',
        },
        {
            ID = 21726001,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21726001.LCut_21726001\'',
        },
        {
            ID = 21800704,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21800704.LCut_21800704\'',
        },
        {
            ID = 21800705,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21800705.LCut_21800705\'',
        },
        {
            ID = 21801317,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_21801317.LCut_21801317\'',
        },
        {
            ID = 22004312,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_22004312.LCut_22004312\'',
        },
        {
            ID = 22004401,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_22004401.LCut_22004401\'',
        },
        {
            ID = 22004601,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_22004601.LCut_22004601\'',
        },
        {
            ID = 22004602,
            SequencePath = 'LevelSequence\'/Game/EditorRes/Dialogue/Sequence/LCut_22004602.LCut_22004602\'',
        },
	},
}

setmetatable(DynamicCutsceneCfg, { __index = CfgBase })

DynamicCutsceneCfg:InitCfg()

-- AUTO GENERATED CODE END, PLEASE DON'T MODIFY

return DynamicCutsceneCfg
