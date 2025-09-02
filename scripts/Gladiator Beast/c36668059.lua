--Gladiator Beast Rudiarius
local s,id=GetID()
function s.initial_effect(c)
	--fusion summon
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,s.matfilter,2)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
	--Can activate Spells/Traps that have "GB" in text from hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetTarget(function(_,c) return s.gbhandfilter(c) end)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	c:RegisterEffect(e2)
	--Related cards in hand and GY become "Colosseum - Cage of the Gladiator Beasts"
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CHANGE_CODE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_HAND|LOCATION_ONFIELD|LOCATION_GRAVE,0)
	e3:SetTarget(function(_,c) return s.gbfilter(c) end)
	e3:SetValue(52518793)
	c:RegisterEffect(e3)
	--Code check 52518793
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(id)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(1,0)
	e4:SetValue(s.val)
	c:RegisterEffect(e4)
	--Reveal 1 "GB" monster to SS monster that mentions it
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetCountLimit(1)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCost(s.spcost)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
end
s.listed_names={52518793}
s.listed_series={SET_GLADIATOR_BEAST}
function s.matfilter(c,fc,sumtype,tp,sub,mg,sg)
	return c:IsMonster() and (c:IsSetCard(SET_GLADIATOR_BEAST,fc,sumtype,tp) or c:ListsArchetype(SET_GLADIATOR_BEAST)) and (not sg or not sg:IsExists(s.fusfilter,1,c,c:GetCode(fc,sumtype,tp),fc,sumtype,tp))
end
function s.fusfilter(c,code,fc,tp)
	return c:IsSummonCode(fc,SUMMON_TYPE_FUSION,tp,code) and not c:IsHasEffect(511002961)
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(function(c) return c:IsMonster() and c:IsAbleToDeckOrExtraAsCost() and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) end,tp,LOCATION_HAND|LOCATION_REMOVED,0,nil)
end
function s.contactop(g,tp)
	Duel.ConfirmCards(1-tp,g)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST+REASON_MATERIAL)
end
function s.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
function s.gbhandfilter(c)
	return c:IsSetCard(SET_GLADIATOR_BEAST) and (c:IsTrap() or c:IsQuickPlaySpell())
end
function s.gbfilter(c)
	return (c:IsSetCard(SET_GLADIATOR_BEAST) or c:ListsArchetype(SET_GLADIATOR_BEAST))
end
function s.val(e,c,re,chk)
	if chk==0 then return true end
	return 52518793
end
function s.costfilter(c,e,tp)
	return c:IsSetCard(SET_GLADIATOR_BEAST) and c:IsMonster() and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp,c:GetOriginalCode()) and not c:IsPublic()
end
function s.spfilter(c,e,tp,code)
	return c:ListsCode(code) and not c:IsOriginalCode(code) and c:IsCanBeSpecialSummoned(e,1,tp,true,false)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local tc=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	Duel.ConfirmCards(1-tp,tc)
	Duel.SetTargetCard(tc)
	if tc:IsLocation(LOCATION_HAND) then Duel.ShuffleHand(tp) end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp,tc:GetOriginalCode()):GetFirst()
	if g and Duel.SpecialSummon(g,1,tp,tp,true,false,POS_FACEUP)~=0 and g:RegisterFlagEffect(g:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD_DISABLE,0,0)then
		--[[Cannot be destroyed by battle
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3000)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		g:RegisterEffect(e1)]]--
	end
end