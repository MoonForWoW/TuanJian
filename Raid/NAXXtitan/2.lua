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
local FB = "NAXXtitan"
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

    -- 战术板
    do
        local isload
        local init = function()
            isload = true
            local spellTbl = {
                {
                    title = L["第8秒"],
                    class = {"PALADIN"},
                    spell = TJ.Board_TJ6,
                    onlyTitle = true,
                },
                {
                    title = L["第14秒"],
                    class = {"PALADIN"},
                    spell = TJ.Board_TJ6,
                    onlyTitle = true,
                },
                {
                    title = L["第20秒"],
                    class = {"PALADIN"},
                    spell = TJ.Board_TJ6,
                    onlyTitle = true,
                },
            }

            local function AutoFuc()
                local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "healer", true)
                local done = {}
                for i, v in ipairs(tbl) do
                    for i = 1, #spellTbl do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, 1, ns.s2)
                            done[i] = true
                            break
                        end
                    end
                end
                local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "dps", true)
                for i, v in ipairs(tbl) do
                    if TuanJian.talentInfo[v.name] == 3 then
                        for i = 1, #spellTbl do
                            if not done[i] then
                                TJ.SetBoardEditFormNum(v, i, 1, ns.s2)
                                done[i] = true
                                break
                            end
                        end
                    end
                end
            end

            local tbl = {
                {
                    name = L["专注光掌链（应对沉默）"],
                    bossSpellID = 54093,
                    arrange = 1,
                    icon = 135872,
                    id = 1,
                    spell = spellTbl,
                    event = "SPELL_CAST_SUCCESS",
                    canUpdate = true,
                    autoNextSpell = nil,
                    timeEndNextSpell = true,
                    startIndex = 1,
                    maxIndex = 3,
                    bossTime = { 8, 6, 6 },
                },
                AutoFuc = AutoFuc,
            }

            TJ.frame[FB][bossIndex].Board_test = function()
                TJ.Board_ENCOUNTER_START(FB, bossIndex, true)
            end

            TJ.CreateBoard(FB, bossIndex, tbl)
        end
        tinsert(TJ.boardCallback, init)
        if TJ.boardInited and not isload then init() end
    end

    -- 坦克
    do
        local function AutoFuc(title)
            local dk = TJ.SortRaidRosterInfo({ "DEATHKNIGHT" }, "tank", true)
            for i, v in ipairs(dk) do
                TJ.SetEditTextFormNum(v, title, 1)
                tremove(dk, i)
                break
            end
            local fq = TJ.SortRaidRosterInfo({ "PALADIN" }, "tank", true)
            for i, v in ipairs(fq) do
                TJ.SetEditTextFormNum(v, title, 2)
                tremove(fq, i)
                break
            end
            local tbl = TJ.SortRaidRosterInfo({ "WARRIOR", "DRUID" }, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
            for i, v in ipairs(dk) do
                TJ.SetEditText(v, title)
            end
            for i, v in ipairs(fq) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排坦克。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Deathknight_BloodPresence", L["坦克"],
            text, TJ.tankClass, nil, nil, nil,
            true)
        TJ.CreateEdit(FB, bossIndex, L["BOSS"])
        TJ.CreateEdit(FB, bossIndex, L["小怪"])
    end

    -- 净化图腾
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排萨满。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_diseasecleansingtotem", L["净化图腾"],
            text, { "SHAMAN" }, nil, nil)
        TJ.CreateEdit(FB, bossIndex, L["插净化图腾"])
        TJ.CreateEdit(FB, bossIndex, L["插净化图腾"])
        TJ.CreateEdit(FB, bossIndex, L["插净化图腾"])
        TJ.CreateEdit(FB, bossIndex, L["插净化图腾"])
        TJ.CreateEdit(FB, bossIndex, L["插净化图腾"])
        TJ.CreateEdit(FB, bossIndex, L["插净化图腾"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 火焰之雨
    do
        local info = {
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                54099
                            },
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["受到%s伤害"]:format(L["火焰之雨"]) },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_rainoffire", L["火焰之雨"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 沉默
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            54093,
                        },
                        colorNum = 1,
                    }
                },
                destNpcType = { "Player" },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_holy_silence", L["沉默"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 驱散
    do
        local info = {
            {
                dispel = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                54098,
                            },
                            colorNum = 1
                        }
                    },
                },
                title = { name = L["驱散毒液箭雨"] },
                notShowDead = true,
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_corrosivebreath", L["驱散"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
        TJ.AddDispelInfo(54098, 4, FB, bossIndex)
    end

    -- 狂乱
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            54100,
                        },
                        colorNum = 1,
                    }
                },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_unholyfrenzy", L["狂乱"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火小怪
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    16506,
                    16505,
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_fire_flamebolt", L["小怪伤害"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    mainFrame.BOSS_SAY = function(msg)
        if msg:match("") then
            return
        end
    end
end
