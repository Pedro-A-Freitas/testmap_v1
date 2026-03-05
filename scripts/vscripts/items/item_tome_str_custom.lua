item_tome_str_custom = class({})

function item_tome_str_custom:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local item = self

    if caster and caster:IsRealHero() then
        caster:ModifyStrength(5)
        caster:CalculateStatBonus(true)
        caster:EmitSound("Item.TomeOfKnowledge.Consume")

        -- Deleta o item com um delay minúsculo para evitar crash
        GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("destroy_item"), function()
            if not item:IsNull() then
                item:Destroy()
            end
            return nil
        end, 0.1)
    end
end