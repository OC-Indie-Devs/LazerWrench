--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:82b23cc420b8e5aeb64b4e7e69a6f069:e8eb71e18006366075663e8689979414:d6667210a0afaaea34f55f82daeb7e79$
--
-- local sheetInfo = require("mysheet")
-- local myImageSheet = graphics.newImageSheet( "mysheet.png", sheetInfo:getSheet() )
-- local sprite = display.newSprite( myImageSheet , {frames={sheetInfo:getFrameIndex("sprite")}} )
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
    
        {
            -- Alpha/badge_1
            x=2,
            y=2,
            width=48,
            height=49,

        },
        {
            -- Alpha/badge_2
            x=52,
            y=2,
            width=48,
            height=49,

        },
        {
            -- Alpha/climb_1
            x=102,
            y=2,
            width=67,
            height=93,

        },
        {
            -- Alpha/climb_2
            x=171,
            y=2,
            width=66,
            height=93,

        },
        {
            -- Alpha/duck
            x=239,
            y=2,
            width=70,
            height=72,

        },
        {
            -- Alpha/hurt
            x=311,
            y=2,
            width=70,
            height=93,

        },
        {
            -- Alpha/idle
            x=383,
            y=2,
            width=66,
            height=93,

        },
        {
            -- Alpha/jump
            x=451,
            y=2,
            width=69,
            height=95,

        },
        {
            -- Alpha/stand
            x=522,
            y=2,
            width=66,
            height=93,

        },
        {
            -- Alpha/swim_1
            x=590,
            y=2,
            width=69,
            height=96,

        },
        {
            -- Alpha/swim_2
            x=661,
            y=2,
            width=70,
            height=98,

        },
        {
            -- Alpha/walk_1
            x=733,
            y=2,
            width=68,
            height=94,

        },
        {
            -- Alpha/walk_2
            x=803,
            y=2,
            width=71,
            height=96,

        },
        {
            -- Beta/badge_1
            x=2,
            y=102,
            width=48,
            height=48,

        },
        {
            -- Beta/badge_2
            x=52,
            y=102,
            width=48,
            height=48,

        },
        {
            -- Beta/climb_1
            x=102,
            y=102,
            width=67,
            height=93,

        },
        {
            -- Beta/climb_2
            x=171,
            y=102,
            width=66,
            height=93,

        },
        {
            -- Beta/duck
            x=239,
            y=102,
            width=68,
            height=73,

        },
        {
            -- Beta/hurt
            x=309,
            y=102,
            width=68,
            height=94,

        },
        {
            -- Beta/idle
            x=379,
            y=102,
            width=66,
            height=93,

        },
        {
            -- Beta/jump
            x=447,
            y=102,
            width=67,
            height=95,

        },
        {
            -- Beta/stand
            x=516,
            y=102,
            width=66,
            height=93,

        },
        {
            -- Beta/swim_1
            x=584,
            y=102,
            width=69,
            height=96,

        },
        {
            -- Beta/swim_2
            x=655,
            y=102,
            width=70,
            height=98,

        },
        {
            -- Beta/walk_1
            x=727,
            y=102,
            width=67,
            height=95,

        },
        {
            -- Beta/walk_2
            x=796,
            y=102,
            width=68,
            height=97,

        },
        {
            -- Delta/badge_1
            x=2,
            y=202,
            width=48,
            height=48,

        },
        {
            -- Delta/badge_2
            x=52,
            y=202,
            width=48,
            height=48,

        },
        {
            -- Delta/climb_1
            x=102,
            y=202,
            width=67,
            height=94,

        },
        {
            -- Delta/climb_2
            x=171,
            y=202,
            width=66,
            height=94,

        },
        {
            -- Delta/duck
            x=239,
            y=202,
            width=70,
            height=73,

        },
        {
            -- Delta/hurt
            x=311,
            y=202,
            width=70,
            height=94,

        },
        {
            -- Delta/idle
            x=383,
            y=202,
            width=66,
            height=94,

        },
        {
            -- Delta/jump
            x=451,
            y=202,
            width=69,
            height=95,

        },
        {
            -- Delta/stand
            x=522,
            y=202,
            width=66,
            height=94,

        },
        {
            -- Delta/swim_1
            x=590,
            y=202,
            width=69,
            height=96,

        },
        {
            -- Delta/swim_2
            x=661,
            y=202,
            width=70,
            height=97,

        },
        {
            -- Delta/walk_1
            x=733,
            y=202,
            width=68,
            height=94,

        },
        {
            -- Delta/walk_2
            x=803,
            y=202,
            width=71,
            height=96,

        },
        {
            -- Gamma/badge_1
            x=2,
            y=301,
            width=48,
            height=48,

        },
        {
            -- Gamma/badge_2
            x=52,
            y=301,
            width=48,
            height=48,

        },
        {
            -- Gamma/climb_1
            x=102,
            y=301,
            width=67,
            height=83,

        },
        {
            -- Gamma/climb_2
            x=171,
            y=301,
            width=66,
            height=83,

        },
        {
            -- Gamma/duck
            x=239,
            y=301,
            width=69,
            height=68,

        },
        {
            -- Gamma/hurt
            x=310,
            y=301,
            width=70,
            height=82,

        },
        {
            -- Gamma/idle
            x=382,
            y=301,
            width=66,
            height=83,

        },
        {
            -- Gamma/jump
            x=450,
            y=301,
            width=69,
            height=85,

        },
        {
            -- Gamma/stand
            x=521,
            y=301,
            width=66,
            height=83,

        },
        {
            -- Gamma/swim_1
            x=589,
            y=301,
            width=69,
            height=86,

        },
        {
            -- Gamma/swim_2
            x=660,
            y=301,
            width=70,
            height=88,

        },
        {
            -- Gamma/walk_1
            x=732,
            y=301,
            width=68,
            height=84,

        },
        {
            -- Gamma/walk_2
            x=802,
            y=301,
            width=71,
            height=87,

        },
        {
            -- Zeta/badge_1
            x=2,
            y=391,
            width=48,
            height=48,

        },
        {
            -- Zeta/badge_2
            x=52,
            y=391,
            width=48,
            height=48,

        },
        {
            -- Zeta/climb_1
            x=102,
            y=391,
            width=67,
            height=96,

        },
        {
            -- Zeta/climb_2
            x=171,
            y=391,
            width=66,
            height=96,

        },
        {
            -- Zeta/duck
            x=239,
            y=391,
            width=68,
            height=72,

        },
        {
            -- Zeta/hurt
            x=309,
            y=391,
            width=68,
            height=93,

        },
        {
            -- Zeta/idle
            x=379,
            y=391,
            width=66,
            height=93,

        },
        {
            -- Zeta/jump
            x=447,
            y=391,
            width=67,
            height=94,

        },
        {
            -- Zeta/stand
            x=516,
            y=391,
            width=66,
            height=93,

        },
        {
            -- Zeta/swim_1
            x=584,
            y=391,
            width=69,
            height=99,

        },
        {
            -- Zeta/swim_2
            x=655,
            y=391,
            width=70,
            height=100,

        },
        {
            -- Zeta/walk_1
            x=727,
            y=391,
            width=68,
            height=94,

        },
        {
            -- Zeta/walk_2
            x=797,
            y=391,
            width=71,
            height=97,

        },
    },
    
    sheetContentWidth = 876,
    sheetContentHeight = 493
}

SheetInfo.frameIndex =
{

    ["Alpha/badge_1"] = 1,
    ["Alpha/badge_2"] = 2,
    ["Alpha/climb_1"] = 3,
    ["Alpha/climb_2"] = 4,
    ["Alpha/duck"] = 5,
    ["Alpha/hurt"] = 6,
    ["Alpha/idle"] = 7,
    ["Alpha/jump"] = 8,
    ["Alpha/stand"] = 9,
    ["Alpha/swim_1"] = 10,
    ["Alpha/swim_2"] = 11,
    ["Alpha/walk_1"] = 12,
    ["Alpha/walk_2"] = 13,
    ["Beta/badge_1"] = 14,
    ["Beta/badge_2"] = 15,
    ["Beta/climb_1"] = 16,
    ["Beta/climb_2"] = 17,
    ["Beta/duck"] = 18,
    ["Beta/hurt"] = 19,
    ["Beta/idle"] = 20,
    ["Beta/jump"] = 21,
    ["Beta/stand"] = 22,
    ["Beta/swim_1"] = 23,
    ["Beta/swim_2"] = 24,
    ["Beta/walk_1"] = 25,
    ["Beta/walk_2"] = 26,
    ["Delta/badge_1"] = 27,
    ["Delta/badge_2"] = 28,
    ["Delta/climb_1"] = 29,
    ["Delta/climb_2"] = 30,
    ["Delta/duck"] = 31,
    ["Delta/hurt"] = 32,
    ["Delta/idle"] = 33,
    ["Delta/jump"] = 34,
    ["Delta/stand"] = 35,
    ["Delta/swim_1"] = 36,
    ["Delta/swim_2"] = 37,
    ["Delta/walk_1"] = 38,
    ["Delta/walk_2"] = 39,
    ["Gamma/badge_1"] = 40,
    ["Gamma/badge_2"] = 41,
    ["Gamma/climb_1"] = 42,
    ["Gamma/climb_2"] = 43,
    ["Gamma/duck"] = 44,
    ["Gamma/hurt"] = 45,
    ["Gamma/idle"] = 46,
    ["Gamma/jump"] = 47,
    ["Gamma/stand"] = 48,
    ["Gamma/swim_1"] = 49,
    ["Gamma/swim_2"] = 50,
    ["Gamma/walk_1"] = 51,
    ["Gamma/walk_2"] = 52,
    ["Zeta/badge_1"] = 53,
    ["Zeta/badge_2"] = 54,
    ["Zeta/climb_1"] = 55,
    ["Zeta/climb_2"] = 56,
    ["Zeta/duck"] = 57,
    ["Zeta/hurt"] = 58,
    ["Zeta/idle"] = 59,
    ["Zeta/jump"] = 60,
    ["Zeta/stand"] = 61,
    ["Zeta/swim_1"] = 62,
    ["Zeta/swim_2"] = 63,
    ["Zeta/walk_1"] = 64,
    ["Zeta/walk_2"] = 65,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
