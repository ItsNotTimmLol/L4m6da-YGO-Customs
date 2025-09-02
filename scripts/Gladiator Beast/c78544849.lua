--Gladiator Beast Rudis
local s,id=GetID()
function s.initial_effect(c)
	--SS 1 monster that has "GB" in text to opp's field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.spopptg)
	e1:SetOperation(s.spoppop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCondition(s.spcon2)
	e2:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCondition(s.tgcon)
	e3:SetRange(LOCATION_MZONE)
	--e3:SetCost(s.tdcost)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_GLADIATOR_BEAST}
s.listed_names={90582719}
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetPreviousLocation()==LOCATION_HAND and (r&REASON_DISCARD)~=0
end
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
function s.spoppfilter(c,e,tp)
	return c:IsMonster() and c:IsLevelBelow(6) and (c:IsSetCard(SET_GLADIATOR_BEAST) or c:ListsArchetype(SET_GLADIATOR_BEAST)) and (c:IsCanBeSpecialSummoned(e,1,1-tp,true,false) or c:IsCanBeSpecialSummoned(e,1,tp,true,false))
end
function s.spopptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMatchingGroupCount(s.spoppfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,nil,e,tp)>1
	and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
	and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
	and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE)
end
function s.spownfilter(c,e,tp,tg)
	return c:IsCanBeSpecialSummoned(e,1,tp,true,false)
		and (tg-c):GetFirst():IsCanBeSpecialSummoned(e,1,tp,true,false,POS_FACEUP,1-tp)
end
function s.spoppop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.spoppfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,nil,e,tp)
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,nil,1,tp,HINTMSG_SPSUMMON)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local sc1=tg:FilterSelect(tp,s.spownfilter,1,1,nil,e,tp,tg):GetFirst()
	local sc2=(tg-sc1):GetFirst()
	if not sc1 or not sc2 then return end
	if Duel.SpecialSummonStep(sc1,1,tp,tp,true,false,POS_FACEUP) and Duel.SpecialSummonStep(sc2,1,tp,1-tp,true,false,POS_FACEUP) then
		sc1:RegisterFlagEffect(sc1:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD_DISABLE,0,0)
		sc2:RegisterFlagEffect(sc2:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD_DISABLE,0,0)
		local e1=Effect.CreateEffect(sc1)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(90582719)
		sc1:RegisterEffect(e1)
		--Cannot activate its effects
		local e2=Effect.CreateEffect(sc1)
		e2:SetDescription(aux.Stringid(id,3))
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e2:SetCode(EFFECT_CANNOT_TRIGGER)
		e2:SetCondition(function(e) return Duel.IsMainPhase() and e:GetHandler():IsControler(tp) end)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		sc1:RegisterEffect(e2)
		local e1=Effect.CreateEffect(sc2)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(90582719)
		sc2:RegisterEffect(e1)
		--Cannot activate its effects
		local e2=Effect.CreateEffect(sc2)
		e2:SetDescription(aux.Stringid(id,3))
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e2:SetCode(EFFECT_CANNOT_TRIGGER)
		e2:SetCondition(function(e) return Duel.IsMainPhase() and e:GetHandler():IsControler(tp) end)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		sc2:RegisterEffect(e2)
		Duel.SpecialSummonComplete()
	end
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER)
end
function s.tgfilter(c,tp)
	return (c:IsSetCard(SET_GLADIATOR_BEAST,fc,sumtype,tp) or c:ListsArchetype(SET_GLADIATOR_BEAST)) and c:IsAbleToGrave() 
	and not Duel.IsExistingMatchingCard(Card.IsOriginalCode,tp,LOCATION_GRAVE,0,1,nil,c:GetOriginalCode())
end
function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil,tp)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,1,1,aux.dncheck,0) end
	local tg=aux.SelectUnselectGroup(g,e,tp,1,1,aux.dncheck,1,tp,HINTMSG_TOGRAVE)
	Duel.SendtoGrave(tg,REASON_EFFECT)
end
function s.tdfilter(c)
	return c:ListsArchetype(SET_GLADIATOR_BEAST)
		and (c:IsLocation(LOCATION_DECK) or c:IsAbleToDeck())
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1)end
	--if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)) end
	
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	Duel.ConfirmDecktop(tp,1)
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	if (tc:ListsArchetype(SET_GLADIATOR_BEAST) or tc:IsSetCard(SET_GLADIATOR_BEAST)) and tc:IsAbleToGrave() and not Duel.IsExistingMatchingCard(Card.IsOriginalCode,tp,LOCATION_GRAVE,0,1,nil,tc:GetOriginalCode()) then
		Duel.DisableShuffleCheck()
		Duel.SendtoGrave(tc,REASON_EFFECT|REASON_EXCAVATE)
	end
	--[[Duel.Recover(tp,1000,REASON_EFFECT)
	Duel.BreakEffect()
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,ct):GetFirst()
	if tc then
		if tc:IsLocation(LOCATION_DECK) then
			Duel.ShuffleDeck(tp)
			Duel.MoveToDeckTop(tc)
		else 
			Duel.HintSelection(tc,true)
			Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
		end
		if not tc:IsLocation(LOCATION_EXTRA) then
			Duel.ConfirmDecktop(tp,1)
		end
	end]]--
end