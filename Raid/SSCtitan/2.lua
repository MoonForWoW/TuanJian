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
local bossIndex = 2
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
    local mainFrame = TJ.frame[FB][bossIndex]
    -- 站位图
    do
        local tbl = {
            { point = "TOPLEFT", xy = { 208, -308 } },
            { point = "TOPLEFT", xy = { 354, -374 } },
            { point = "TOPLEFT", xy = { 364, -152 } },
            { point = "TOPLEFT", xy = { 248, -175 } },
            { point = "TOPLEFT", xy = { 423, -239 } },
            { point = "TOPLEFT", xy = { 135, -125 } },
            { point = "TOPLEFT", xy = { 146, -67 } },
            { point = "TOPLEFT", xy = { 79, -89 } },
            { point = "TOPLEFT", xy = { 509, -194 } },
            { point = "TOPLEFT", xy = { 539, -122 } },
            { point = "TOPLEFT", xy = { 581, -179 } },
            { point = "TOPLEFT", xy = { 497, -379 } },
            { point = "TOPLEFT", xy = { 576, -396 } },
            { point = "TOPLEFT", xy = { 531, -472 } },
            { point = "TOPLEFT", xy = { 189, -225 } },
            { point = "TOPLEFT", xy = { 409, -326 } },
            { point = "TOPLEFT", xy = { 264, -386 } },

            [98] = {
                xy = { 331, -206 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["近战"],
                isNPC_icon = "Interface\\Icons\\ability_steelmelee",
            },
            [99] = {
                xy = { 286, -317 },
                isNPC = true,
                isNPC_help = true,
                isNPC_text = L["坦克"],
                isNPC_icon = "Interface\\Icons\\Spell_Deathknight_BloodPresence",
            },
            [100] = { xy = { 304, -259 }, isNPC = "b" .. bossIndex },
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
        local map = TJ.CreateMap(FB, bossIndex, tbl, 650, 536)
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
        if TJ.IsTBC then
            TJ.CreateEdit(FB, bossIndex, L["1坦克"])
            TJ.CreateEdit(FB, bossIndex, L["2坦克"])
            TJ.CreateEdit(FB, bossIndex, L["3坦克"])
        else
            TJ.CreateEdit(FB, bossIndex, L["主坦克"])
            TJ.CreateEdit(FB, bossIndex, L["副坦克"])
        end
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 喷涌
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            37433
                        },
                    },
                },
                destNpcType = { "Player" },
                notMiss = true,
            },
            title = { name = L["受到%s伤害"]:format(L["喷涌"]) },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_frost_frostblast", L["喷涌(扫射)"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 喷泉
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            37478
                        },
                    },
                },
                destNpcType = { "Player" },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_frost_chillingblast", L["喷泉"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 顺劈斩
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            28168
                        },
                        combatRole = { "Isdps", "Ishealer" },
                    },
                },
                destNpcType = { "Player" },
            },
            title = { name = L["受到%s伤害"]:format(L["顺劈斩"]) },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_warrior_cleave", L["顺劈斩"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 沸水承伤
    --[[     do
        local info = {
            dps = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            37284,
                        },
                    },
                },
                destNpcType = { "Player", },
            },
            showRaidMember = true,
            canSend = "dps",
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_fire_masterofelements", L["沸水承伤"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end ]]
end
