local AddonName, ns = ...

local LibBG = ns.LibBG
local L = ns.L

local AddTexture = ns.AddTexture
local Round = ns.Round

local pt = print
local After = C_Timer.After
local BG = TJ

local realmID = GetRealmID()
local player = UnitName("player")


local T = {}
local FB = "TOC"
local bossIndex = 5
local function P3fuc(f, bt, playerTbl, info)
    local P3
    for _, v in pairs(TJ.GetNewCombatLog().otherTime) do
        if v.name == "P3" then
            P3 = v
            break
        end
    end
    if P3 then
        local infoType = "aura"
        local time = 0
        -- 统计BUFF在P3的持续时间
        for _, playerText in ipairs(playerTbl) do
            for _, bar in ipairs(playerText.barTbl) do
                local v = bar.v
                local yes
                for i in ipairs(info[infoType].spell) do
                    for _, spellID in ipairs(info[infoType].spell[i].spellID) do
                        if v.spellID == spellID then
                            yes = true
                            break
                        end
                    end
                    if yes then break end
                end
                if yes then
                    if v.endTime > P3.time then
                        if v.startTime >= P3.time then
                            time = time + (v.endTime - v.startTime)
                        else
                            time = time + (v.endTime - P3.time)
                        end
                    end
                end
            end
        end

        local combat = TJ.GetCombatLog()
        local duration = combat.duration
        local t = f:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 13, "OUTLINE")
        t:SetPoint("BOTTOM", f, "BOTTOM", 0, 5)
        t:SetTextColor(1, 0.82, 0)
        t:SetText(format(L["%s%s覆盖率：%s%%"], bt.name, P3.name, Round(time / (duration - P3.time) * 100)))
        return 1
    end
    return 0
end

-- 破甲覆盖率
local function P3fuc2(f, bt, playerTbl, info)
    local P2_duration = 0
    local otherTime = TJ.GetNewCombatLog().otherTime
    for i, v in ipairs(otherTime) do
        if v.name == "P1" and otherTime[i - 1] and otherTime[i - 1].name == "P2" then
            P2_duration = v.time - otherTime[i - 1].time
        end
    end
    local time = 0
    -- 统计BUFF在P3的持续时间
    local infoType = "aura"
    for _, playerText in ipairs(playerTbl) do
        for _, bar in ipairs(playerText.barTbl) do
            local v = bar.v
            local yes
            for i in ipairs(info[infoType].spell) do
                for _, spellID in ipairs(info[infoType].spell[i].spellID) do
                    if v.spellID == spellID then
                        yes = true
                        break
                    end
                end
                if yes then break end
            end
            if yes then
                time = time + (v.endTime - v.startTime)
            end
        end
    end

    local combat = TJ.GetCombatLog()
    local duration = combat.duration
    local t = f:CreateFontString()
    t:SetFont(BIAOGE_TEXT_FONT, 13, "OUTLINE")
    t:SetPoint("BOTTOM", f, "BOTTOM", 0, 5)
    t:SetTextColor(1, 0.82, 0)
    t:SetText(format(L["%s%s覆盖率：%s%%"], bt.name, L["P1+P3"], Round(time / (duration - P2_duration) * 100)))
    return 1
end

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

    -- 自动标记
    local name = "rt" .. FB .. bossIndex
    do
        mainFrame.autoRT = name
        local instanceID = TJ.FBinfo[FB].ID
        TJ.autoRaidTargetInfo[instanceID] = TJ.autoRaidTargetInfo[instanceID] or {}
        TJ.autoRaidTargetInfo[instanceID][34607] = {
            [8] = true,
            [7] = true,
            [6] = true,
            [5] = true,
            np = true,
        }

        TJ.options[name .. "reset"] = 1
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]
        local icon = TJ.SetRaidTargetingTex(8, 7, 6, 5)
        local ontext = {
        }
        local f = ns.O.CreateCheckButton(name, format(L["战斗中把中虫标记为%s（需要团长/助理）"], icon),
            mainFrame, 40, -150, ontext)
        f:ClearAllPoints()
        f:SetPoint("BOTTOMLEFT", TJ.spChild.title, "TOPRIGHT", 0, 15)
        f:SetHitRectInsets(0, 0, 0, 0)
    end

    -- 主坦克
    if TJ.IsTitan then
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
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Deathknight_BloodPresence", L["主坦克"],
            text, TJ.tankClass, nil, nil, nil, true)
        TJ.CreateEdit(FB, bossIndex, L["BOSS"])
        TJ.CreateEdit(FB, bossIndex, L["中虫"])
    end

    -- 拉冰
    if TJ.IsWLK_80 then
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, nil, true)
            if #tbl >= 3 then
                for i, v in ipairs(tbl) do
                    if TJ.Isdps(v) then
                        TJ.SetEditText(v, title)
                    end
                end
            else
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
        local text = L["有3个DK时，仅安排输出DK，否则安排任意DK。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_deathknight_strangulate", L["拉冰"],
            text, { "DEATHKNIGHT" }, nil, info)
        TJ.CreateEdit(FB, bossIndex, L["左拉冰"])
        TJ.CreateEdit(FB, bossIndex, L["右拉冰"])
    end
    -- 中虫
    if TJ.IsWLK_80 then
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            if #tbl >= 3 then
                for i, v in ipairs(tbl) do
                    if v.class == "PALADIN" or v.class == "WARRIOR" then
                        TJ.SetEditText(v, title)
                    end
                end
            end
        end
        local text = L["有3个坦克时，安排防骑/防战。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "ability_hunter_pet_spider", L["中虫"], text, TJ.tankClass)
        TJ.CreateEdit(FB, bossIndex, L["左中虫"])
        TJ.CreateEdit(FB, bossIndex, L["右中虫"])
    end
    -- 打冰
    if TJ.IsWLK_80 then
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "HUNTER" }, nil, true)
            if #tbl == 1 then
                for i, v in ipairs(tbl) do
                    TJ.SetEditTextFormNum(v, title, 1)
                    TJ.SetEditTextFormNum(v, title, 2)
                    TJ.SetEditTextFormNum(v, title, 3)
                end
            elseif #tbl == 2 then
                TJ.SetEditTextFormNum(tbl[1], title, 1)
                TJ.SetEditTextFormNum(tbl[2], title, 2)
                TJ.SetEditTextFormNum(tbl[1], title, 3)
            elseif #tbl >= 3 then
                for i, v in ipairs(tbl) do
                    TJ.SetEditText(v, title)
                end
            end
        end
        local info = {
            harmDied = {
                type = "d",
                destNPCID = {
                    34606, -- 冰霜之球
                }
            }
        }
        local text = L["仅安排猎人。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "ability_marksmanship", L["打冰"],
            text, TJ.dps2Class, nil, info)
        TJ.CreateEdit(FB, bossIndex, L["1打冰"])
        TJ.CreateEdit(FB, bossIndex, L["2打冰"])
        TJ.CreateEdit(FB, bossIndex, L["3打冰"])
    end
    -- 保护
    if TJ.IsWLK_80 then
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, nil, true)
            for i, v in ipairs(tbl) do
                if TJ.Isdps(v) then
                    TJ.SetEditText(v, title)
                end
            end
            for i, v in ipairs(tbl) do
                if TJ.Ishealer(v) then
                    TJ.SetEditText(v, title)
                end
            end
            for i, v in ipairs(tbl) do
                if TJ.Istank(v) then
                    TJ.SetEditText(v, title)
                end
            end
        end
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            67574, -- 被点名
                        },
                        colorNum = 2,
                        frameLevel = 1,
                    },
                    {
                        spellID = ns.sp["保护"],
                        colorNum = 1,
                        frameLevel = 2,
                    },
                },
            }
        }
        local text = L["优先安排惩戒骑、其次奶骑，最后防骑。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_holy_sealofprotection", L["保护"],
            text, { "PALADIN" }, nil, info)
        TJ.CreateEdit(FB, bossIndex, "1" .. L["保护"])
        TJ.CreateEdit(FB, bossIndex, "2" .. L["保护"])
        TJ.CreateEdit(FB, bossIndex, "3" .. L["保护"])
    end
    -- 刺骨
    do
        local function AutoFuc(title)
            if TJ.IsWLK_80 then
                local tbl = TJ.SortRaidRosterInfo(title.classTbl, nil, true)
                for i, v in ipairs(tbl) do
                    if v.class == "SHAMAN" and
                        (TuanJian.talentInfo[v.name] == 3 or v.combatRole == "HEALER" or TuanJian.talentInfo[v.name] == 1)
                    then
                        TJ.SetEditTextFormNum(v, title, 1)
                        tremove(tbl, i)
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    if v.class == "PRIEST" and TJ.Ishealer(v) then
                        TJ.SetEditTextFormNum(v, title, 2)
                        TJ.SetEditTextFormNum(v, title, 3)
                        tremove(tbl, i)
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    if v.class == "PRIEST" and TJ.Ishealer(v) then
                        TJ.SetEditTextFormNum(v, title, 4)
                        TJ.SetEditTextFormNum(v, title, 5)
                        tremove(tbl, i)
                        break
                    end
                end
            else
                local tbl = TJ.SortRaidRosterInfo({ "SHAMAN", "DRUID", "PRIEST", }, 'healer', true)
                for i, v in ipairs(tbl) do
                    TJ.SetEditTextFormNum(v, title, 1)
                    TJ.SetEditTextFormNum(v, title, 2)
                    TJ.SetEditTextFormNum(v, title, 3)
                    tremove(tbl, i)
                    break
                end
                for i, v in ipairs(tbl) do
                    TJ.SetEditTextFormNum(v, title, 4)
                    TJ.SetEditTextFormNum(v, title, 5)
                    tremove(tbl, i)
                    break
                end
            end
        end
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            66013,
                        },
                        tooltip = "health",
                    },
                },
            }
        }
        local text
        if TJ.IsWLK_80 then
            text = L["1刺骨安排奶萨/元素萨，23刺骨安排一个奶牧，45刺骨安排另一个奶牧。"]
        else
            text = L["1刺骨安排奶萨/元素萨，23刺骨安排一个奶牧，45刺骨安排另一个奶牧。"]
        end
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_frost_coldhearted", L["刺骨"],
            text, TJ.healerClass, nil, info)
        TJ.CreateEdit(FB, bossIndex, "1" .. L["刺骨"])
        TJ.CreateEdit(FB, bossIndex, "2" .. L["刺骨"])
        TJ.CreateEdit(FB, bossIndex, "3" .. L["刺骨"])
        TJ.CreateEdit(FB, bossIndex, "4" .. L["刺骨"])
        TJ.CreateEdit(FB, bossIndex, "5" .. L["刺骨"])
    end
    -- 致伤毒药
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, nil, true)
            for i, v in ipairs(tbl) do
                if TuanJian.talentInfo[v.name] == 2 then
                    TJ.SetEditText(v, title)
                    return
                end
            end
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = ns.sp["致伤毒药"],
                    },
                },
                destNPCID = {
                    34564, -- 小强
                },
            },
            func = P3fuc
        }
        local text = L["优先安排战斗贼，其次任意贼。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "inv_misc_herb_16", L["致伤毒药"],
            text, { "ROGUE" }, nil, info)
        TJ.CreateEdit(FB, bossIndex, L["致伤毒药"])
    end
    -- 圣光审判
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, nil, true)
            for i, v in ipairs(tbl) do
                if TJ.Isdps(v) then
                    TJ.SetEditText(v, title)
                end
            end
        end
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = ns.sp["圣光审判"],
                        colorNum = 1,
                    },
                },
                destNPCID = {
                    34564, -- 小强
                },
            },
            func = P3fuc
        }
        local text = L["仅安排惩戒骑。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_holy_righteousfury", L["圣光审判"],
            text, { "PALADIN" }, nil, info)
        TJ.CreateEdit(FB, bossIndex, L["圣光审判"])
    end
    -- 自然抗性图腾
    if TJ.IsWLK_80 then
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "dps1", true)
            if next(tbl) then
                for i, v in ipairs(tbl) do
                    TJ.SetEditText(v, title)
                    return
                end
            end
            local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "dps2", true)
            if next(tbl) then
                for i, v in ipairs(tbl) do
                    TJ.SetEditText(v, title)
                    return
                end
            end
            local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, nil, true)
            if next(tbl) then
                for i, v in ipairs(tbl) do
                    TJ.SetEditText(v, title)
                    return
                end
            end
        end
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            58750, -- 图腾
                            49071, -- 守护
                        },
                    },
                },
            }
        }
        local text = L["优先安排增强萨，其次元素/奶萨。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_natureresistancetotem", L["自然抗性图腾"],
            text, { "SHAMAN", "HUNTER" }, nil, info)
        TJ.CreateEdit(FB, bossIndex, L["自然抗性图腾"])
        mainFrame.saveAura = { [58750] = true }
    end
    -- 道标
    if TJ.IsWLK_80 then
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            if #tbl >= 3 then
                for i, v in ipairs(tbl) do
                    if v.class == "PALADIN" or v.class == "WARRIOR" then
                        TJ.SetEditText(v, title)
                    end
                end
            end
        end
        local function updateFuc(index)
            local count = 0
            for i, v in ipairs(TJ.raidRosterInfo) do
                if count >= 3 then break end
                if v.role ~= "MAINASSIST" and v.class == "PALADIN" and TJ.Ishealer(v) then
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
                        spellID = ns.sp["道标"],
                    },
                },
            }
        }
        local text = L["给中虫坦克。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "ability_paladin_beaconoflight", L["道标"],
            text, TJ.tankClass, updateFuc, info)
    end

    local destNPCID = {
        34564, -- 小强
    }
    TJ.CreateSPTitle(FB, bossIndex, destNPCID, P3fuc2)

    if TJ.IsWLK_80 then
        -- 治疗图腾
        do
            local info = {
                healingTotem = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                52042, -- 治疗图腾
                            },
                            colorNum = 1
                        },
                    },
                }
            }
            local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_spear_04", L["治疗图腾"],
                nil, nil, nil, info)
            TJ.AddSPTitle(FB, bossIndex, f)
        end
    else
        -- 追逐
        do
            local info = {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                67574,
                            },
                            colorNum = 1,
                        }
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["P2追逐点名"] },
            }
            local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_hunter_snipershot", L["追逐"],
                nil, nil, nil, info)
            TJ.AddSPTitle(FB, bossIndex, f)
        end
        -- 转火小怪
        do
            local info = {
                {
                    dps = {
                        type = "s",
                        destNPCID = {
                            34607,
                        },
                    },
                },
            }
            local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_hunter_pet_spider", L["转火中虫"],
                nil, nil, nil, info)
            TJ.AddSPTitle(FB, bossIndex, f)
        end
    end


    mainFrame.BOSS_SAY = function(msg)
        if msg:match(L["虫群会吞噬你！"]) then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P3",
            })
        elseif msg:match(L["钻入了地下"]) then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P2",
            })
        elseif msg:match(L["从地面上升起来了"]) then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P1",
            })
        end
    end
end

-- /dump TuanJian["TOC"][5].combat.otherTime
