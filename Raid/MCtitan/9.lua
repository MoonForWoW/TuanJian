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
local FB = "MCtitan"
local bossIndex = 9
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
    -- 自动标记
    local instanceID = TJ.FBinfo[FB].ID
    TJ.autoRaidTargetInfo[instanceID][11663] = TJ.autoRaidTargetIcon3 -- 医师
    TJ.autoRaidTargetInfo[instanceID][11664] = TJ.autoRaidTargetIcon2 -- 精英

    -- 战术板
    do
        local isload
        local init = function()
            isload = true
            local s1, s2, s3 = ns.s1, ns.s2, ns.s3
            local s51 = ns.s51 -- 小牺
            local s52 = ns.s52 -- 压制
            local s53 = ns.s5  -- 守护之魂
            local s54 = ns.s54 -- 树皮

            local spellTbl = {
                {
                    title = L["第1"],
                    class = nil,
                    spell = TJ.Board_TJ5
                },
                {
                    title = L["第2"],
                    class = nil,
                    spell = TJ.Board_TJ5
                },
                {
                    title = L["第3"],
                    class = nil,
                    spell = TJ.Board_TJ5
                },
            }
            local spellTbl2 = {
                {
                    title = L["第1"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
                {
                    title = L["第2"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
            }
            local spellTbl3 = {
                {
                    title = L["1/5"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
                {
                    title = L["2/6"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
                {
                    title = L["3/7"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
                {
                    title = L["4/8"],
                    class = nil,
                    spell = TJ.Board_TJ1
                },
            }

            local function AutoFuc()
                -- 坦克
                local tbl = TJ.SortRaidRosterInfo({ "DRUID" }, "healer", true)
                for i, v in ipairs(TJ.SortRaidRosterInfo({ "PALADIN" }, "healer", true)) do
                    tinsert(tbl, v)
                end
                for i, v in ipairs(TJ.SortRaidRosterInfo({ "PRIEST" }, "healer", true)) do
                    tinsert(tbl, v)
                end
                for i, v in ipairs(TJ.SortRaidRosterInfo({ "PALADIN" }, "dps", true)) do
                    tinsert(tbl, v)
                end
                local function GetSpell(v)
                    if v.class == "DRUID" then
                        return s54
                    elseif v.class == "PALADIN" then
                        return s51
                    elseif v.class == "PRIEST" and TuanJian.talentInfo[v.name] == 1 then
                        return s52
                    end
                end
                local done = {}
                for i, v in ipairs(tbl) do
                    for i = 1, 3 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, 1, GetSpell(v))
                            done[i] = true
                            break
                        end
                    end
                end

                -- 冲击波
                local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "healer", true)
                local done = {}
                for i, v in ipairs(tbl) do
                    for i = 1, 2 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, 1, s1, 2)
                            done[i] = true
                            break
                        end
                    end
                end

                -- 反射
                local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "tank", true)
                for i, v in ipairs(TJ.SortRaidRosterInfo({ "WARRIOR" }, "tank", true)) do
                    tinsert(tbl, v)
                end
                local function GetSpell(v)
                    if v.class == "PALADIN" then
                        return s1
                    elseif v.class == "WARRIOR" then
                        return s3
                    end
                end
                local done = {}
                for i, v in ipairs(tbl) do
                    for i = 1, 4 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, 1, GetSpell(v), 3)
                            done[i] = true
                            break
                        end
                    end
                end
            end

            local tbl = {
                {
                    name = L["坦克起手减伤"],
                    bossSpellID = 1,
                    arrange = 1,
                    icon = "spell_holy_sealofsacrifice",
                    id = 1,
                    spell = spellTbl,
                    event = "SPELL_CAST_SUCCESS",
                    canUpdate = true,
                    autoNextSpell = nil,
                    timeEndNextSpell = true,
                    startIndex = 1,
                    maxIndex = 3,
                    bossTime = { 3, 10, },
                },
                {
                    name = L["冲击波起手减伤"],
                    bossSpellID = 2,
                    arrange = 1,
                    icon = "spell_holy_excorcism_02",
                    id = 2,
                    spell = spellTbl2,
                    event = "SPELL_CAST_SUCCESS",
                    canUpdate = true,
                    autoNextSpell = nil,
                    timeEndNextSpell = true,
                    startIndex = 1,
                    maxIndex = 2,
                    bossTime = { 10, 6, },
                },
                {
                    name = L["反射减伤链"],
                    bossSpellID = 3,
                    arrange = 2,
                    icon = "spell_shadow_antishadow",
                    id = 3,
                    spell = spellTbl3,
                    event = "SPELL_CAST_SUCCESS",
                    canUpdate = true,
                    autoNextSpell = nil,
                    timeEndNextSpell = nil,
                    startIndex = 1,
                    bossTime = { 27, 30, },
                },
                AutoFuc = AutoFuc,
            }

            TJ.frame[FB][bossIndex].Board_SPELL_CAST_SUCCESS = function(info, ...)
                local tbl = { ... }
                local spell = tbl[12]
                if (spell == 21075 or spell == 20619) and info[3] then
                    TJ.Board_NextSpell(3)
                end
            end

            TJ.frame[FB][bossIndex].Board_test = function()
                TJ.Board_ENCOUNTER_START(FB, bossIndex, true)
            end

            TJ.CreateBoard(FB, bossIndex, tbl)
        end
        tinsert(TJ.boardCallback, init)
        if TJ.boardInited and not isload then init() end
    end

    -- BOSS
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            for i, v in ipairs(tbl) do
                if v.class == "DEATHKNIGHT" then
                    TJ.SetEditTextFormNum(v, title, 1)
                    tremove(tbl, i)
                    break
                end
            end
            for i, v in ipairs(tbl) do
                if v.class == "PALADIN" then
                    TJ.SetEditTextFormNum(v, title, 2)
                    tremove(tbl, i)
                    break
                end
            end
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["BOSS优先安排DKT，小怪优先安排防骑。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Deathknight_BloodPresence", L["坦克"],
            text, TJ.tankClass, nil, nil, nil, nil)
        TJ.CreateEdit(FB, bossIndex, L["BOSS坦"])
        TJ.CreateEdit(FB, bossIndex, L["中怪坦"])
        TJ.CreateEdit(FB, bossIndex, L["中怪坦"])
    end

    -- 羊小怪
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "MAGE" }, nil, true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
            local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, nil, true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
                return
            end
        end
        local info = {
            aura = {
                type = "s",
                spell = {
                    {
                        spellID = ns.sp["羊"],
                    },
                },
            },
        }
        local text = L["安排法师和萨满。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_polymorph", L["羊医师"],
            text, { "MAGE", "SHAMAN" }, nil, info)
        TJ.CreateEdit(FB, bossIndex, L["羊星星"] .. TJ.SetRaidTargetingIcons(nil, "xingxing"))
        TJ.CreateEdit(FB, bossIndex, L["羊大饼"] .. TJ.SetRaidTargetingIcons(nil, "dabing"))
        TJ.CreateEdit(FB, bossIndex, L["羊紫菱"] .. TJ.SetRaidTargetingIcons(nil, "ziling"))
        TJ.CreateEdit(FB, bossIndex, L["羊三角"] .. TJ.SetRaidTargetingIcons(nil, "sanjiao"))
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)
end
