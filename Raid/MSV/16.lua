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
local FB = "TES"
local bossIndex = 4
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
    local bossSpellID = 120629
    do
        local isload
        local init = function()
            isload = true
            local s1, s2, s3, s4, s5, s6, s7 = ns.s1, ns.s2, ns.s3, ns.s4, ns.s5, ns.s6, ns.s7
            local spellTbl = {
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
                local tbl = TJ.SortRaidRosterInfo({ "WARRIOR" }, nil, true)
                local startIndex = #tbl + 1
                for i, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, s2)
                    TJ.SetBoardEditFormNum(v, i, nil, s3)
                end
                local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "", true)
                for i, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, s1)
                end
                local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "dps", true)
                for i, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, ns.s9)
                    TJ.SetBoardEditFormNum(v, i, nil, ns.s10)
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "healer", true)
                for i, v in ipairs(tbl) do
                    for i = startIndex, 4, 1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, s7)
                            TJ.SetBoardEditFormNum(v, i, nil, ns.s9)
                            TJ.SetBoardEditFormNum(v, i, nil, ns.s8)
                            done[i] = true
                            break
                        end
                    end
                end
                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "ROGUE" }, nil, true)
                for i, v in ipairs(tbl) do
                    for i = startIndex, 4, 1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, s6)
                            done[i] = true
                            break
                        end
                    end
                end
                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "dps", true)
                for i, v in ipairs(tbl) do
                    for i = startIndex, 4, 1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, ns.s14)
                            done[i] = true
                            break
                        end
                    end
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "DRUID" }, "healer", true)
                for i, v in ipairs(tbl) do
                    for i = 4, 1, -1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, ns.s12)
                            done[i] = true
                            break
                        end
                    end
                end
                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "healer", true)
                for i, v in ipairs(tbl) do
                    for i = 4, 1, -1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, TuanJian.talentInfo[v.name] == 1 and s5 or ns.s13)
                            done[i] = true
                            break
                        end
                    end
                end
                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "MONK" }, "healer", true)
                for i, v in ipairs(tbl) do
                    for i = 4, 1, -1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, ns.s11)
                            done[i] = true
                            break
                        end
                    end
                end
            end

            local tbl = {
                {
                    name = L["畏惧蜷缩减伤链"],
                    bossSpellID = bossSpellID,
                    arrange = 6,
                    icon = "spell_shadow_psychicscream",
                    id = 1,
                    spell = spellTbl,
                    event = "SPELL_CAST_START",
                    canUpdate = nil,
                    autoNextSpell = nil,
                    startIndex = 1,
                    bossTime = { 1, 1 },
                    autoHide = true,
                    now = true,
                },
                AutoFuc = AutoFuc,
            }

            mainFrame.Board_test = function()
                TJ.Board_ENCOUNTER_START(FB, bossIndex, true)
                TJ.Board_info[bossSpellID].canUpdate = true
            end
            local cd = {}
            mainFrame.Board_SPELL_AURA_APPLIED = function(info, ...)
                local tbl = { ... }
                local spellID = tbl[12]
                if spellID == bossSpellID and not TJ.SetCD(cd, 3) then
                    TJ.Board_info[bossSpellID].canUpdate = true
                    TJ.Board_info[bossSpellID].updateFrame.t = 0
                    After(0, function()
                        info[bossSpellID].index = info[bossSpellID].index + info[bossSpellID].step
                    end)
                end
            end

            TJ.CreateBoard(FB, bossIndex, tbl)
            --[[
/run TJ.Board_ENCOUNTER_START("TES", 4)
/run TJ.Board_SPELL_AURA_APPLIED(nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,120629)
 ]]
        end
        tinsert(TJ.boardCallback, init)
        if TJ.boardInited and not isload then init() end
    end

    -- 技能提醒
    if TJ.canUseTips then
        local name = "tips1" .. FB .. bossIndex

        local spellTbl = {
            { boss = L["杨国师"], msg = L["6点集合，右边2箭后，往右移至5点，结束后回到6点。"], spellID = 119593 },
            { boss = L["康成"], msg = L["7点集合，右边1箭后，往右移至6点，结束后回到7点。"], spellID = 119692 },
            { boss = L["昆锦纶"], msg = L["11点集合，左边1箭后，往左移至12点，结束后回到11点。"], spellID = 119693 },
        }

        local f = CreateFrame("Frame")
        function f:Start(duration)
            f.t = duration - 3
            f:SetScript("OnUpdate", function(self, t)
                f.t = f.t - t
                if f.t <= 0 then
                    f:SetScript("OnUpdate", nil)
                    if TJ.IsLeader() and IsInRaid(1) then
                        SendMsg()
                    end
                end
            end)
        end

        local canWhisper
        mainFrame.SPELL_CAST_START = function(...)
            if TuanJian.options[name] == 1 and TJ.IsLeader() then
                local tbl = { ... }
                local spellID = tbl[12]
                for i, v in ipairs(spellTbl) do
                    if spellID == v.spellID then
                        canWhisper = i
                        After(3, function()
                            canWhisper = nil
                        end)
                        return
                    end
                end
            end
        end
        mainFrame.SPELL_AURA_APPLIED = function(...)
            local tbl = { ... }
            local spellID = tbl[12]
            if spellID == 129147 and tbl[9] and spellTbl[canWhisper] then
                SendChatMessage(spellTbl[canWhisper].boss .. L["："] .. spellTbl[canWhisper].msg, "WHISPER", nil, tbl[9])
            end
        end

        TJ.options[name .. "reset"] = 1
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]
        local ontext = {
            L["自动密语台子躲避方法"],
            L["当BOSS把人传送到台子时，自动密语该团员对应台子的躲避方法。"],
            L["需要你是团长或助理，该功能才生效。"],
            " ",
            L["密语内容如下："],
        }
        for i, v in ipairs(spellTbl) do
            tinsert(ontext, "|cffffffff" .. v.boss .. L["|r："] .. v.msg)
        end
        local f = ns.O.CreateCheckButton(name, AddTexture(132323) .. L["自动密语台子躲避方法（需要团长/助理）"],
            TJ.frame[FB][bossIndex], 40, -150, ontext)
        f:ClearAllPoints()
        f:SetPoint("BOTTOMLEFT", TJ.spChild.title, "TOPRIGHT", 0, 15)
        f:SetHitRectInsets(0, 0, 0, 0)
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
        TJ.CreateEdit(FB, bossIndex, L["1坦克"])
        TJ.CreateEdit(FB, bossIndex, L["2坦克"])
        TJ.CreateEdit(FB, bossIndex, L["3坦克"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 痛击
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 131996, },
                            colorNum = 1,
                        },
                        {
                            spellID = { 132007 },
                            colorNum = 9,
                        },
                    },
                }
            },
        }
        for i, v in ipairs(TJ.combatInfoTank) do
            tinsert(info, v)
        end
        tinsert(info, {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = { 120669 },
                    },
                },
            },
            title = { name = L["赤裸惊恐"], icon = "ability_rogue_dismantle" }
        }
        )
        local f = TJ.CreateTitle(FB, bossIndex, nil, "sha_spell_fire_blueimmolation", L["痛击"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 恐惧吐息
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            119414,
                            125786,
                        },
                        colorNum = 1
                    },
                },
                destNpcType = { "Player" },
                notMiss = true,
            },
            canSend = "count",
            title = { name = L["受到恐惧吐息伤害"] },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_devouringplague", L["恐惧吐息"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 不详蔑笑
    do
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 119593, 119692, 119693 },
                            colorNum = 2,
                        },
                    },
                    showCount = true,
                    barText = function(spellID)
                        if spellID == 119593 then
                            return L["杨国师"]
                        elseif spellID == 119692 then
                            return L["康成"]
                        elseif spellID == 119693 then
                            return L["昆锦纶"]
                        end
                    end
                },
                title = { name = L["施放不详蔑笑"] },
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 129147 },
                        },
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                },
                notShowDead = true,
                title = L["点名"],
            },

        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 236279, L["不详蔑笑"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 恐惧喷射
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = { 119985 },
                    },
                },
                destNpcType = { "Player" },
                showCount = true,
            },
            notShowDead = true,
            title = { name = L["不会躲恐惧喷射（连中两箭）"] },
            canSend = "count",
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_theblackarrow", L["恐惧喷射"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 死亡之花
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            119887,
                        },
                        colorNum = 1
                    },
                },
                destNpcType = { "Player" },
                notMiss = true,
            },
            title = { name = L["受到死亡之花伤害"] },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_hunter_resistanceisfutile", L["死亡之花"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 煞能宝珠
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = { 129189 },
                    },
                },
                destNpcType = { "Player" },
                showCount = true,
            },
            notShowDead = true,
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 348536, L["煞能宝珠"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 宿怨打击
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            120672,
                        },
                        colorNum = 1
                    },
                },
                destNpcType = { "Player" },
            },
            title = { name = L["受到%s伤害"]:format(L["宿怨打击"]) },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "achievement_dungeon_icecrown_pitofsaron", L["宿怨打击"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 龙卷水涌
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            120521,
                        },
                        colorNum = 1
                    },
                },
                destNpcType = { "Player" },
            },
            title = { name = L["受到龙卷水涌伤害"] },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_elemental_primal_water", L["龙卷水涌"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 畏惧蜷缩
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 120629 },
                            tooltip = "aura+health",
                        },
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                },
                canSend = "count",
            },
        }
        tinsert(info, TJ.combatInfoMore)
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_psychicscream", L["畏惧蜷缩"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 传光
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = { 120388 },
                    },
                },
                destNpcType = { "Player" },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_holy_searinglightpriest", L["传光"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 转火小怪
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    61003,
                },
            },
            showRaidMember = true,
            canSend = "dps",
            title = { name = L["转火P2小怪"], icon = "sha_ability_rogue_envelopingshadows" }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "sha_ability_rogue_envelopingshadows", L["转火小怪"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    TJ.frame[FB][bossIndex].BOSS_SAY = function(msg)
        if msg:match("内心的恐惧") then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P2",
            })
            return
        end
    end
end
