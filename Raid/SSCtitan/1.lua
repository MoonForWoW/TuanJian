local AddonName, ns = ...

local LibBG = ns.LibBG
local L = ns.L

local AddTexture = ns.AddTexture

local pt = print
local After = C_Timer.After
local BG = TJ

local realmID = GetRealmID()
local player = UnitName("player")


local T = {}
local FB = "SSCtitan"
local bossIndex = 1
--[[
"DEATHKNIGHT"
"PALADIN"
"WARRIOR"
"SHAMAN"
"HUNTER"
"DRUID"
"ROGUE"
"MAGE"
"WARLOCK"
"PRIEST"
 ]]

TJ.Load[FB .. bossIndex] = function()
    -- 站位图
    do
        local tbl = {
            { point = "TOPLEFT", xy = { 229,-326     } },
            { point = "TOPLEFT", xy = { 418,-336     } },
            { point = "TOPLEFT", xy = { 231,-408     } },
            { point = "TOPLEFT", xy = { 414,-408     } },
            { point = "TOPLEFT", xy = { 327,-416     } },
            { point = "TOPLEFT", xy = { 160,-184    } },
            { point = "TOPLEFT", xy = { 207,-248    } },
            { point = "TOPLEFT", xy = { 106,-248    } },
            { point = "TOPLEFT", xy = { 125,-332     } },
            { point = "TOPLEFT", xy = { 139,-420     } },
            { point = "TOPLEFT", xy = { 485,-190     } },
            { point = "TOPLEFT", xy = { 434,-250     } },
            { point = "TOPLEFT", xy = { 546,-249     } },
            { point = "TOPLEFT", xy = { 513,-327     } },
            { point = "TOPLEFT", xy = { 513,-429     } },
            { point = "TOPLEFT", xy = { 198,-484     } },
            { point = "TOPLEFT", xy = { 459,-489     } },

            [98] = {
                xy = { 327, -178 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["近战"],
                isNPC_icon = "Interface\\Icons\\ability_steelmelee",
            },
            [99] = {
                xy = { 326, -275 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["坦克"],
                isNPC_icon = "Interface\\Icons\\Spell_Deathknight_BloodPresence",
            },
            [100] = { xy = { 326, -226 }, isNPC = "b" .. bossIndex },
        }

        --[[ 
        
        ]]

        local function AutoFuc()
            local tbl = TJ.SortRaidRosterInfo(TJ.healerClass, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v, { min = 1, max = 5 })
            end

            local tbl = TJ.SortRaidRosterInfo(nil, "dps2", true)
            for i, v in ipairs(tbl) do
                TJ.SetMapIconPlayer(v)
            end
        end
        local text = {
            L["1-5：治疗。"],
            L["6-17：远程DPS。"],
        }
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["站位"],
            text)
        local map = TJ.CreateMap(FB, bossIndex, tbl, 650, 593)
        local t = map:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 30, "OUTLINE")
        t:SetPoint("TOPLEFT", 20, -20)
        t:SetText(L["冰阶段站位"])
    end

    -- 坦克
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排坦克。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Deathknight_BloodPresence", L["坦克"],
            text, TJ.tankClass, nil, nil, nil,
            nil)
        TJ.CreateEdit(FB, bossIndex, L["冰坦克"])
        TJ.CreateEdit(FB, bossIndex, L["毒坦克"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 易伤
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            38218, 38231, 38216, 40584, 38215, 38217, -- 冰
                        },
                        colorNum = 6,
                    },
                    {
                        spellID = {
                            38219,38220,38221,40583,38222,38230, -- 毒
                        },
                        colorNum = 7,
                    }
                },
                destNpcType = { "Player" },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_elementalshields", L["易伤"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 水之墓
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            38235
                        },
                        colorNum = 1,
                    }
                },
                destNpcType = { "Player" },
            },
            title = L["点名"],
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_frost_manarecharge", L["水之墓"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 肮脏淤泥
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            38246
                        },
                        colorNum = 1,
                    }
                },
                destNpcType = { "Player" },
            },
            title = L["点名"],
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_abolishmagic", L["肮脏淤泥"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火小怪
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    22035, 22036
                },
            },
            canSend = "dps",
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_frost_summonwaterelemental_2", L["转火小怪"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
end
