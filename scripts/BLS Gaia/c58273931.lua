--Morning Twilight Knight Gaia the Fierce Knight
local s,id=GetID()
function s.initial_effect(c)
	--fusion summon
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,s.ffilter1,s.ffilter2)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,true)
	--[[
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.lvtg)
	e1:SetOperation(s.lvop)
	c:RegisterEffect(e1)]]--
	--Also treated as a DARK monster
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_ADD_ATTRIBUTE)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetValue(ATTRIBUTE_DARK)
	c:RegisterEffect(e2)
	--Apply 1 effect when Tributed or banished
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e4)
end
s.listed_names={14882493,40371092,3160805,76766706}
s.listed_series={SET_BLACK_LUSTER_SOLDIER}
function s.ffilter1(c,fc,sumtype,tp)
	return c:IsMonster() 
		and (c:IsSetCard(SET_BLACK_LUSTER_SOLDIER,fc,sumtype,tp) or c:ListsArchetype(SET_BLACK_LUSTER_SOLDIER) or c:ListsArchetypeAsMaterial(SET_BLACK_LUSTER_SOLDIER) or c:ListsCodeWithArchetype(SET_BLACK_LUSTER_SOLDIER) 
		or c:IsSetCard(SET_CHAOS,fc,sumtype,tp) or c:ListsArchetype(SET_CHAOS) or c:ListsArchetypeAsMaterial(SET_CHAOS) or c:ListsCodeWithArchetype(SET_CHAOS)
		or c:IsCode(7841921,47963370,12381100,85059922))
end
function s.ffilter2(c,fc,sumtype,tp)
	return c:IsRace(RACE_WARRIOR,fc,sumtype,tp)
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsReleasable,tp,LOCATION_HAND,0,nil)
end
function s.contactop(g)
	Duel.Release(g,REASON_COST+REASON_MATERIAL)
end
function s.splimit(e,se,sp,st)
	return aux.fuslimit(e,se,sp,st) or not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
function s.lvcon(e)
	return e:GetHandler():IsDefensePos()
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsLevel(3) end
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local a1=1
	local a2=1
	if not (a1 or a2) then return end
	local op=Duel.SelectEffect(tp,
		{a1,aux.Stringid(id,3)},
		{a2,aux.Stringid(id,4)})
	if op==1 and not c:IsLevel(1) then
		if not c then return end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	elseif op==2 and not c:IsLevel(4) then
		if not c then return end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(4)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end
function s.spfilter(c)
	return c:IsCode(14882493,40371092)
end
function s.sprescon(sg)
	return sg:FilterCount(Card.IsCode,nil,14882493)<2 and sg:FilterCount(Card.IsCode,nil,40371092)<2
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tp=e:GetHandlerPlayer()
	local g1=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,nil)
	local g2=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
	local b1=#g1>0 and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0,nil)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	local b2=#g2>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	if not (b1 or b2) then return end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	if op==1 then
		local ft=math.min(2,Duel.GetLocationCount(tp,LOCATION_MZONE))
		if ft<1 then return end
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,nil,e,tp)
		local sg=aux.SelectUnselectGroup(g,e,tp,1,ft,s.sprescon,1,tp,HINTMSG_SPSUMMON)
		Duel.BreakEffect()
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local ft=math.min(Duel.GetLocationCount(tp,LOCATION_SZONE),3)
		local sg=aux.SelectUnselectGroup(g2,e,tp,1,ft,s.rescon,1,tp,HINTMSG_SET)
		if #sg==0 then return end
		Duel.BreakEffect()
		if Duel.SSet(tp,sg)>0 then
			local c=e:GetHandler()
			for tc in sg:Iter() do
				--Can be activated this turn
				local e1=Effect.CreateEffect(c)
				e1:SetDescription(aux.Stringid(id,2))
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
				e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				tc:RegisterEffect(e1)
			end
		end
	end
end
function s.setfilter(c)
	return (c:IsCode(3160805) or c:IsCode(76766706) or c:IsCode(23701465)
		or (c:IsSetCard(SET_BLACK_LUSTER_SOLDIER,fc,sumtype,tp) or c:ListsArchetype(SET_BLACK_LUSTER_SOLDIER) or c:ListsArchetypeAsMaterial(SET_BLACK_LUSTER_SOLDIER) or c:ListsCodeWithArchetype(SET_BLACK_LUSTER_SOLDIER) 
		or c:IsSetCard(SET_CHAOS,fc,sumtype,tp) or c:ListsArchetype(SET_CHAOS) or c:ListsArchetypeAsMaterial(SET_CHAOS) or c:ListsCodeWithArchetype(SET_CHAOS))) 
		and c:IsSpellTrap() and c:IsSSetable() and not c:IsRitualSpell()
end
function s.rescon(sg,e,tp,mg)
	return #sg==1 or ((sg:IsExists(Card.IsCode,1,nil,3160805) or sg:IsExists(Card.IsCode,1,nil,76766706)) and #sg==2) or (sg:IsExists(Card.IsCode,1,nil,3160805) and sg:IsExists(Card.IsCode,1,nil,76766706) and #sg==3)
end