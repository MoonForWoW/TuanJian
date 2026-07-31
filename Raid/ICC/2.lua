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
local FB = "ICC"
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
    -- 战术板
    local s1, s2, s3, s4, s5, s6, s7, s8
    local spellTbl = {
        {
            title = L["1/7"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ1
        },
        {
            title = L["2/8"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ1
        },
        {
            title = L["3/9"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ1
        },
        {
            title = L["4/10"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ1
        },
        {
            title = L["5/11"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ1
        },
        {
            title = L["6/12"],
            class = { "PALADIN" },
            spell = TJ.Board_TJ1
        },
    }
    local function AutoFuc()
        local done = {}
        local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "healer", true)
        for i, v in ipairs(tbl) do
            if not done[1] then
                TJ.SetBoardEditFormNum(v, 1, 1, s1)
                TJ.SetBoardEditFormNum(v, 2, 1, s2)
                done[1] = true
                done[2] = true
            elseif not done[3] then
                TJ.SetBoardEditFormNum(v, 3, 1, s1)
                TJ.SetBoardEditFormNum(v, 4, 1, s2)
                done[3] = true
                done[4] = true
            end
        end
        local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "dps", true)
        for i, v in ipairs(tbl) do
            for i = 1, 6 do
                if not done[i] then
                    if TuanJian.talentInfo[v.name] == 4 then
                        TJ.SetBoardEditFormNum(v, i, 1, s1)
                    else
                        TJ.SetBoardEditFormNum(v, i, 1, s2)
                    end
                    done[i] = true
                    break
                end
            end
        end
        local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "tank", true)
        for i, v in ipairs(tbl) do
            for i = 1, 6 do
                if not done[i] then
                    TJ.SetBoardEditFormNum(v, i, 1, s1)
                    done[i] = true
                    break
                end
            end
        end
    end
    TJ.OnUpdateTime(function(self, t)
        if ns.isLoaded then
            self:SetScript("OnUpdate", nil)
            self:Hide()
            s1, s2, s3, s4, s5, s6, s7, s8 = ns.s1, ns.s2, ns.s3, ns.s4, ns.s5, ns.s6, ns.s7, ns.s8
        end
    end)
    local cd = 21
    local tbl = {
        {
            name = L["群体寒冰箭减伤链"],
            bossSpellID = 72905,
            arrange = 2,
            icon = 135846,
            id = 1,
            spell = spellTbl,
            sound = L["即将群体寒冰箭"],
            event = "SPELL_CAST_SUCCESS",
            canUpdate = false,
            autoNextSpell = true,
            startIndex = 1,
            bossTime = { 12, cd, cd, cd, cd, cd, cd, cd, cd, cd, cd, cd, cd, cd, cd, cd, cd, cd, cd, cd, },
        },
        AutoFuc = AutoFuc,
    }
    TJ.CreateBoard(FB, bossIndex, tbl)

    -- 站位图
    do
        local tbl = {
            { point = "TOPLEFT", xy = { 243, -164 } },
            { point = "TOPLEFT", xy = { 413, -169 } },
            { point = "TOPLEFT", xy = { 244, -241 } },
            { point = "TOPLEFT", xy = { 413, -244 } },
            { point = "TOPLEFT", xy = { 325, -114 } },
            { point = "TOPLEFT", xy = { 248, -82 } },
            { point = "TOPLEFT", xy = { 408, -80 } },
            { point = "TOPLEFT", xy = { 171, -119 } },
            { point = "TOPLEFT", xy = { 483, -123 } },
            { point = "TOPLEFT", xy = { 145, -193 } },
            { point = "TOPLEFT", xy = { 509, -195 } },
            { point = "TOPLEFT", xy = { 135, -260 } },
            { point = "TOPLEFT", xy = { 506, -274 } },
            { point = "TOPLEFT", xy = { 219, -320 } },
            { point = "TOPLEFT", xy = { 445, -327 } },
            { point = "TOPLEFT", xy = { 98, -147 } },
            { point = "TOPLEFT", xy = { 559, -151 } },
            [100] = { xy = { 326, -180 }, isNPC = "b" .. bossIndex },
        }
        local function AutoFuc()
            -- N
            do
                local tbl = TJ.SortRaidRosterInfo(TJ.healerClass, "healer", true)
                for i, v in ipairs(tbl) do
                    if v.class == "PALADIN" then
                        TJ.SetMapIconPlayerFormNum(1, v)
                        tremove(tbl, i)
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    if v.class == "PALADIN" then
                        TJ.SetMapIconPlayerFormNum(2, v)
                        tremove(tbl, i)
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    if v.class == "PRIEST" then
                        TJ.SetMapIconPlayerFormNum(3, v)
                        tremove(tbl, i)
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    if v.class == "PRIEST" then
                        TJ.SetMapIconPlayerFormNum(4, v)
                        tremove(tbl, i)
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    TJ.SetMapIconPlayer(v, { min = 1, max = 5 })
                end
            end
            -- 远程DPS
            do
                local tbl = TJ.SortRaidRosterInfo(nil, "dps2", true)
                for i, v in ipairs(tbl) do
                    if v.class == "WARLOCK" then
                        TJ.SetMapIconPlayerFormNum(6, v)
                        tremove(tbl, i)
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    if v.class == "WARLOCK" then
                        TJ.SetMapIconPlayerFormNum(7, v)
                        tremove(tbl, i)
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    if v.class == "SHAMAN" then
                        TJ.SetMapIconPlayerFormNum(8, v)
                        tremove(tbl, i)
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    if v.class == "SHAMAN" then
                        TJ.SetMapIconPlayerFormNum(9, v)
                        tremove(tbl, i)
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    if v.class == "DRUID" then
                        TJ.SetMapIconPlayerFormNum(10, v)
                        tremove(tbl, i)
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    if v.class == "DRUID" then
                        TJ.SetMapIconPlayerFormNum(11, v)
                        tremove(tbl, i)
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    if v.class == "HUNTER" then
                        TJ.SetMapIconPlayerFormNum(12, v)
                        tremove(tbl, i)
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    if v.class == "HUNTER" then
                        TJ.SetMapIconPlayerFormNum(13, v)
                        tremove(tbl, i)
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    if v.class == "MAGE" then
                        TJ.SetMapIconPlayerFormNum(14, v)
                        tremove(tbl, i)
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    if v.class == "MAGE" then
                        TJ.SetMapIconPlayerFormNum(15, v)
                        tremove(tbl, i)
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    TJ.SetMapIconPlayer(v)
                end
            end
        end
        local text = {
            L["1/2奶骑，3/4奶牧，5其他治疗。"],
            L["6/7术士。"],
            L["8/9元素萨。"],
            L["10/11鸟德。"],
            L["12/13猎人。"],
            L["14/15法师。"],
        }
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["P2站位"],
            text)
        local map = TJ.CreateMap(FB, bossIndex, tbl, 650, 435)
        local t = map:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 30, "OUTLINE")
        t:SetPoint("TOPLEFT", 20, -20)
        t:SetText(L["P2站位"])
    end

    -- P1坦克
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            for i, v in ipairs(tbl) do
                if v.class == "PALADIN" then
                    TJ.SetEditText(v, title)
                    tremove(tbl, i)
                    break
                end
            end
            for i, v in ipairs(tbl) do
                if v.class == "PALADIN" then
                    TJ.SetEditText(v, title)
                    tremove(tbl, i)
                    break
                end
            end
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["优先安排防骑。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_holy_devotionaura", L["P1坦克"],
            text, TJ.tankClass, nil, nil, nil,
            true)
        TJ.CreateEdit(FB, bossIndex, L["左坦"])
        TJ.CreateEdit(FB, bossIndex, L["右坦"])
    end
    -- P2坦克
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
                    TJ.SetEditTextFormNum(v, title, 3)
                    tremove(tbl, i)
                    break
                end
            end
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["1坦优先安排DKT，小怪优先安排防骑。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Deathknight_BloodPresence", L["P2坦克"],
            text, TJ.tankClass, nil, nil, nil, true)
        TJ.CreateEdit(FB, bossIndex, L["1坦"])
        TJ.CreateEdit(FB, bossIndex, L["2坦"])
        TJ.CreateEdit(FB, bossIndex, L["小怪"])
    end
    -- 拉追随者
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "dps", true)
            if #tbl >= 3 then
                for i, v in ipairs(tbl) do
                    TJ.SetEditText(v, title)
                end
            else
                local tbl = TJ.SortRaidRosterInfo(title.classTbl, nil, true)
                for i, v in ipairs(tbl) do
                    if TJ.Isdps(v) then
                        TJ.SetEditText(v, title)
                        tremove(tbl, i)
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    if TJ.Isdps(v) then
                        TJ.SetEditText(v, title)
                        tremove(tbl, i)
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    TJ.SetEditText(v, title)
                end
            end
        end
        local info = {
            castSuccess = {
                type = "s",
                spell = {
                    {
                        spellID = ns.sp["死亡之握"],
                        colorNum = 1
                    },
                },
            }
        }
        local text = L["优先安排输出DK。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_deathknight_strangulate", L["拉追随者"],
            text, { "DEATHKNIGHT" }, nil, info, nil,
            true)
        TJ.CreateEdit(FB, bossIndex, L["左边"])
        TJ.CreateEdit(FB, bossIndex, L["右边"])
        TJ.CreateEdit(FB, bossIndex, L["右边"])
    end
    -- 风筝巨兽
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "HUNTER" }, nil, true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            70900, -- 黑暗突变
                        },
                        colorNum = 2
                    },
                    {
                        spellID = ns.sp["扰乱射击"],
                        colorNum = 1
                    },
                },
            }
        }
        local text = L["仅安排猎人。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_arcane_blink", L["风筝巨兽"],
            text, { "HUNTER" }, nil, info)
        TJ.CreateEdit(FB, bossIndex, L["风筝巨兽"])
    end

    -- 灵魂石
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local function updateFuc(index)
            local count = 0
            for i, v in ipairs(TJ.raidRosterInfo) do
                if count >= 3 then break end
                if v.role ~= "MAINASSIST" and v.class == "WARLOCK" then
                    count = count + 1
                    local name = "|c" .. select(4, GetClassColor(v.class)) .. TJ.GetIconAndName(v) .. "|r"
                    TJ.CreateEdit(FB, bossIndex, name, index)
                end
            end
        end
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = ns.sp["灵魂石"],
                    },
                },
            }
        }
        local text = L["绑定坦克。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_shadow_soulgem", L["灵魂石"],
            text, nil, updateFuc, info)
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 统御心灵
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            71289, -- 统御心灵
                        },
                        tooltip = "health",
                        colorNum = 2,
                    },
                    {
                        spellID = {
                            33786, -- 旋风
                        },
                        tooltip = "aura",
                        colorNum = 1,
                    }
                },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 132507, L["心控"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 麻痹诅咒
    do
        local info = {
            {
                dispel = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                71237,
                            },
                            colorNum = 1
                        }
                    },
                    sourceNpcType = { "Player" },
                },
                title = { name = L["驱散"], icon = 71237 },
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                71237,
                            },
                            colorNum = 1
                        }
                    },
                },
                title = { name = L["麻痹诅咒"], icon = 71237 },
            },
            isMany = true,
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 132095, L["麻痹诅咒"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 打断
    do
        local info = {
            interrupt = {
                type = "s",
                spell = {
                    {

                    },
                },
                sourceNpcType = { "Player" }
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_frost_iceshock", L["打断"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 鬼魂
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            71544, -- 复仇冲击
                        },
                        colorNum = 1
                    },
                },
                sourceNPCID = {
                    38222, -- 怨毒之影
                },
                destNpcType = { "Player" },
                attack = true,
                attackFrameLevel = 5,
                attackColorNum = 2,
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_deathsembrace", L["鬼魂"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 误伤排名
    do
        local info = {
            dps = {
                type = "s",
                sourceNpcType = { "Player" },
                destNpcType = { "Player" },
            },
            canSend = "dps",
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 132507, L["误伤排名"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 转火小怪
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    37890,
                    37949,
                },
            },
            showRaidMember = true,
            canSend = "dps",
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_warrior_cleave", L["转火小怪"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 群体寒冰箭
    do
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                72905,
                            },
                            colorNum = 2,
                            frameLevel = 1,
                        },
                    },
                }
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                31821, -- 光掌
                            },
                            colorNum = 4
                        },
                        {
                            spellID = {
                                70940, -- 大牺牲
                            },
                            colorNum = 1
                        },
                    },
                    destNpcType = { "Player" },
                    onlyShowMe = { 70940, 31821, 64843, 48447, 48446, 26983, },
                },
                title = { name = L["神圣牺牲/光环掌握"], icon = "spell_holy_powerwordbarrier" }
            },
            isMany = true
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 135846, L["群体寒冰箭"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    TJ.frame[FB][bossIndex].BOSS_SAY = function(msg)
        if msg:match(L["看来需要我亲自上阵了"]) then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P2",
            })
            local bossSpellID = 72905
            if TJ.Board_info[bossSpellID] then
                TJ.Board_info[bossSpellID].canUpdate = true
                TJ.Board_info[bossSpellID].updateFrame.t = 0
            end
        end
    end
end
