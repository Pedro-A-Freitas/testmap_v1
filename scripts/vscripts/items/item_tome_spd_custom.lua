item_tome_spd_custom = class({})
LinkLuaModifier("modifier_tome_spd_bonus", "items/item_tome_spd_custom", LUA_MODIFIER_MOTION_NONE)

function item_tome_spd_custom:OnSpellStart()
    if not IsServer() then return end

    local caster = self:GetCaster()
    
    -- Efeitos Visuais e Sonoros
    caster:EmitSound("Item.TomeOfKnowledge.Consume")
    local pfx = ParticleManager:CreateParticle("particles/generic_hero_status/hero_levelup.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:ReleaseParticleIndex(pfx)

    -- Verifica se o herói já tem o modificador invisível
    local modifier = caster:FindModifierByName("modifier_tome_spd_bonus")
    if not modifier then
        -- Se não tiver, cria. Usamos "nil" no lugar da habilidade para que o 
        -- bônus não suma quando o item for deletado do inventário
        modifier = caster:AddNewModifier(caster, nil, "modifier_tome_spd_bonus", {})
    end

    -- Adiciona 1 stack ao modificador
    if modifier then
        modifier:IncrementStackCount()
    end

    -- Consome a carga do item
    self:SpendCharge()
end

---------------------------------------------------------------------------
-- O MODIFICADOR INVISÍVEL QUE DÁ O BÔNUS
---------------------------------------------------------------------------
modifier_tome_spd_bonus = class({})

function modifier_tome_spd_bonus:IsHidden() return true end         -- Fica invisível pro jogador
function modifier_tome_spd_bonus:IsPurgable() return false end      -- Não pode ser removido (tipo por Diffusal)
function modifier_tome_spd_bonus:RemoveOnDeath() return false end   -- O herói não perde ao morrer

function modifier_tome_spd_bonus:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
    }
end

function modifier_tome_spd_bonus:GetModifierMoveSpeedBonus_Constant()
    -- Multiplica os Stacks por 50. 
    -- 1 Tomo = 50 MS | 2 Tomos = 100 MS e assim vai.
    return self:GetStackCount() * 50
end