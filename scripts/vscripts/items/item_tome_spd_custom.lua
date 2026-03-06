item_tome_spd_custom = class({})
LinkLuaModifier("modifier_tome_spd_bonus", "items/item_tome_spd_custom", LUA_MODIFIER_MOTION_NONE)

function item_tome_spd_custom:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local item = self

    if caster and caster:IsRealHero() then
        -- VERIFICAÇÃO DE LIMITE (MÁXIMO 5)
        local modifier = caster:FindModifierByName("modifier_tome_spd_bonus")
        if modifier and modifier:GetStackCount() >= 5 then
            return 
        end

        if not modifier then
            modifier = caster:AddNewModifier(caster, nil, "modifier_tome_spd_bonus", {})
        end
        if modifier then
            modifier:IncrementStackCount()
        end

        caster:EmitSound("Item.TomeOfKnowledge.Consume")

        -- LÓGICA DE DESTRUIÇÃO IDÊNTICA AO SEU DE AGI
        GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("destroy_item"), function()
            if not item:IsNull() then
                item:Destroy()
            end
            return nil
        end, 0.1)
    end
end

---------------------------------------------------------------------------
modifier_tome_spd_bonus = class({})

-- ATIVANDO O VISUAL:
function modifier_tome_spd_bonus:IsHidden() return false end       -- Agora ele aparece no HUD
function modifier_tome_spd_bonus:IsPurgable() return false end
function modifier_tome_spd_bonus:RemoveOnDeath() return false end

-- Define qual ícone vai aparecer no buff (estou usando o da bota)
function modifier_tome_spd_bonus:GetTexture()
    return "boots_of_speed"
end

function modifier_tome_spd_bonus:DeclareFunctions() 
    return { MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT } 
end

function modifier_tome_spd_bonus:GetModifierMoveSpeedBonus_Constant() 
    return self:GetStackCount() * 50 
end