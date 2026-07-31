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
local FB = "TOC"
local bossIndex = 3
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

    local instanceID = TJ.FBinfo[FB].ID
    TJ.autoRaidTargetInfo[instanceID] = TJ.autoRaidTargetInfo[instanceID] or {}

    -- 萨满
    for i, npcID in ipairs({
        34470, 34444, -- 奶萨
        34463, 34455  -- 增强
    }) do
        TJ.autoRaidTargetInfo[instanceID][npcID] = {
            [8] = true,
            np = true,
        }
    end
    -- 战士
    for i, npcID in ipairs({
        34475, 34453, -- 战士
    }) do
        TJ.autoRaidTargetInfo[instanceID][npcID] = {
            [7] = true,
            np = true,
        }
    end
    -- 其他近战
    for i, npcID in ipairs({
        34472, 34454, -- 盗贼
        34471, 34456, -- 惩戒
        34467, 34448, -- 猎人
    }) do
        TJ.autoRaidTargetInfo[instanceID][npcID] = {
            [6] = true,
            [5] = true,
            [4] = true,
            np = true,
        }
    end
    -- 治疗
    for i, npcID in ipairs({
        34465, 34445, -- 奶骑
        34469, 34459, -- 奶德
        34466, 34447, -- 奶牧
    }) do
        TJ.autoRaidTargetInfo[instanceID][npcID] = {
            [3] = true,
            [2] = true,
            [1] = true,
            np = true,
        }
    end

    -- 34461,34458,  "DEATHKNIGHT",  --DK
    -- 34468,34449,  "MAGE",  --Mage
    -- 34460,34451,  "DRUID",  --Moonkin
    -- 34474,34450,  "WARLOCK",  --Warlock
    -- 34473,34441,  "PRIEST",  --Shadow


    --[[
34461,34458,  "DEATHKNIGHT",  --DK
34460,34451,  "DRUID",  --Moonkin
34469,34459,  "DRUID",  --Tree 奶德
34467,34448,  "HUNTER",  --Hunter
34468,34449,  "MAGE",  --Mage
34465,34445,  "PALADIN",  --Holy 奶骑
34471,34456,  "PALADIN",  --Ret 惩戒
34466,34447,  "PRIEST",  --Disc 奶牧
34473,34441,  "PRIEST",  --Shadow
34472,34454,  "ROGUE",  --Rogue
34463,34455,  "SHAMAN",  --Enhan 增强
34470,34444,  "SHAMAN",  --Resto 奶萨
34474,34450,  "WARLOCK",  --Warlock
34475,34453,  "WARRIOR",  --Warrior
    ]]

    -- 坦克主治疗
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["仅安排奶骑。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Holy_HolyBolt", L["坦克主治疗"],
            text, TJ.healerClass)
        TJ.CreateEdit(FB, bossIndex, L["坦克主治疗"])
    end

    -- 主驱散
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "healer", true)
            for i, v in ipairs(tbl) do
                if TuanJian.talentInfo[v.name] == 1 then
                    TJ.SetEditText(v, title)
                    return
                end
            end
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local info = {
            dispel = {
                type = "s",
                spell = nil,
                sourceNpcType = { "Player" },
            }
        }
        local text = L["仅安排戒律牧。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_holy_wordfortitude", L["主驱散"],
            text, { "PRIEST" }, nil, info)
        TJ.CreateEdit(FB, bossIndex, L["主驱散"])
    end

    -- 打断奶骑
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, nil, true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
                return
            end
        end
        local info = {
            interrupt = {
                type = "s",
                spell = {
                    {},
                },
                sourceNpcType = { "Player" },
            }
        }
        local text = L["安排一个盗贼。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "ability_kick", L["打断奶骑"],
            text, { "ROGUE" }, nil, info)
        TJ.CreateEdit(FB, bossIndex, L["打断奶骑"])
    end

    -- 放逐奶德
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, nil, true)
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
                        spellID = ns.sp["放逐"],
                    },
                },
            }
        }
        local text = L["安排一个术士。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_shadow_cripple", L["放逐奶德"],
            text, { "WARLOCK" }, nil, info)
        TJ.CreateEdit(FB, bossIndex, L["放逐奶德"])
    end

    -- 保护
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "SHAMAN", "DRUID", "PRIEST" }, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
            local tbl = TJ.SortRaidRosterInfo(nil, "dps2", true)
            for i = #tbl, 1, -1 do
                local v = tbl[i]
                if v then
                    if v.class == "WARLOCK" then
                        TJ.SetEditText(v, title)
                        tremove(tbl, i)
                    end
                end
            end
            for i = #tbl, 1, -1 do
                local v = tbl[i]
                if v then
                    if v.class == "SHAMAN" then
                        TJ.SetEditText(v, title)
                        tremove(tbl, i)
                    end
                end
            end
            for i = #tbl, 1, -1 do
                local v = tbl[i]
                if v then
                    if v.class == "DRUID" then
                        TJ.SetEditText(v, title)
                        tremove(tbl, i)
                    end
                end
            end
            for i = #tbl, 1, -1 do
                local v = tbl[i]
                if v then
                    if v.class == "PRIEST" then
                        TJ.SetEditText(v, title)
                        tremove(tbl, i)
                    end
                end
            end
        end
        local function updateFuc(index)
            for i, v in ipairs(TJ.raidRosterInfo) do
                if v.role ~= "MAINASSIST" and v.class == "PALADIN" then
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
                        spellID = ns.sp["保护"],
                    },
                },
            }
        }
        local text = L["优先给奶牧/奶德/奶萨，其次远程DPS（术士/元素萨/鸟德/暗牧）"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_holy_sealofprotection", L["保护"],
            text, nil, updateFuc, info)
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)
end
