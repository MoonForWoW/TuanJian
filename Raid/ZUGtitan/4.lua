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
local FB = "ZUGtitan"
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

    -- 技能提醒
    if TJ.canUseTips then
        local name = "tips1" .. FB .. bossIndex

        local msg = L["你被点名凝视，请双手离开键盘，别做任何动作。"]

        mainFrame.SPELL_CAST_START = function(...)
            local tbl = { ... }
            local spellID = tbl[12]
            if spellID == 24314 and TuanJian.options[name] == 1 and TJ.IsLeader() then
                After(0.1, function()
                    local units = { "target", "focus" }
                    for i in ipairs(C_NamePlate.GetNamePlates()) do
                        tinsert(units, "nameplate" .. i)
                    end
                    for _, unit in ipairs(units) do
                        local guid = UnitGUID(unit)
                        if guid and TJ.GetNPCID(guid, true) == 11382 then
                            if UnitIsPlayer(unit .. "target") then
                                SendChatMessage(msg, "WHISPER", nil, UnitName(unit .. "target"))
                                return
                            end
                        end
                    end
                end)
            end
        end

        TJ.options[name .. "reset"] = 1
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]
        local ontext = {
            L["自动密语提醒凝视别做动作"],
            L["当有人被点名凝视，自动密语该团员。"],
            L["需要你是团长或助理，该功能才生效。"],
            " ",
            L["密语内容如下："],
            msg,
        }
        local f = ns.O.CreateCheckButton(name, AddTexture(136129) .. L["自动密语提醒凝视别做动作"] .. L["（需要团长/助理）"],
            mainFrame, 40, -150, ontext)
        f:ClearAllPoints()
        f:SetPoint("BOTTOMLEFT", TJ.spChild.title, "TOPRIGHT", 0, 15)
        f:SetHitRectInsets(0, 0, 0, 0)
        --[[
/run TJ.frame[TuanJian.FB][TuanJian.bossIndex].SPELL_CAST_START(nil,nil,nil,nil,nil,nil,nil,nil,"苍穹的小骑士",nil,nil,24314)
 ]]
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
        TJ.CreateEdit(FB, bossIndex, L["奥根"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 破甲攻击
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            24317,
                        },
                        colorNum = 1,
                    }
                },
                destNpcType = { "Player" },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_warrior_sunder", L["破甲攻击"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 威慑凝视
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            24314,
                        },
                        colorNum = 1,
                    }
                },
                destNpcType = { "Player" },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_charm", L["威慑凝视"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end



    mainFrame.BOSS_SAY = function(msg)
        if msg:match("") then
            return
        end
    end
end
