--Ally of Justice Worm 00
--Scripted by WolfSif
local s,id=GetID()
function s.initial_effect(c)
	--flip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SET)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsSSetable() or c:IsMSetable(true,nil)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil) or Duel.IsExistingMatchingCard(s.filter,1-tp,0,LOCATION_HAND,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	local g2=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	local sc1=g1:FilterSelect(tp,s.filter,1,1,nil):GetFirst()
	if sc1:IsMSetable(true,nil) then
		Duel.MSet(tp,sc1,true,nil)
	else
		Duel.SSet(tp,sc1)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_EXC_GRAVE|RESET_PHASE|PHASE_END)
		sc1:RegisterEffect(e1)
	end
	local sc2=g2:FilterSelect(1-tp,s.filter,1,1,nil):GetFirst()
	if sc2:IsMSetable(true,nil) then
		Duel.MSet(1-tp,sc2,true,nil)
	else
		Duel.SSet(1-tp,sc2)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_TRIGGER)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD_EXC_GRAVE|RESET_PHASE|PHASE_END)
		sc2:RegisterEffect(e2)
	end
end