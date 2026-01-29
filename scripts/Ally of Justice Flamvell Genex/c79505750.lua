--Ally of Justice Contractor
--Scripted by WolfSif
local s,id=GetID()
function s.initial_effect(c)
	--fusion summon
	c:EnableReviveLimit()
	--Fusion.AddProcMix(c,true,true,s.mfilter1,s.mfilter2)
	Fusion.AddProcMixN(c,true,true,s.mfilter1,2)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
	--Only control 1
	--c:SetUniqueOnField(1,0,id)
	--Must be either Fusion Summoned or Special Summoned by alternate procedure
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	--[[Cannot be used as Link Material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetValue(s.matlimit)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	c:RegisterEffect(e2)
	--[[non-tuner
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_NONTUNER)
	c:RegisterEffect(e3)]]--
	--[[treated synchro material
	local e4=e3:Clone()
	e4:SetCode(EFFECT_SYNCHRO_CHECK)
	e4:SetValue(s.syncheck)
	c:RegisterEffect(e4)]]--
	--[[Tribute reduction
	local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetCode(EFFECT_DECREASE_TRIBUTE)
    e5:SetRange(LOCATION_MZONE)
    e5:SetTargetRange(LOCATION_HAND,0)
    e5:SetTarget(aux.TargetBoolFunction(s.allynsfilter))
    e5:SetValue(0x1)
    c:RegisterEffect(e5)]]--
	--Search
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e6:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e6:SetCode(EVENT_LEAVE_FIELD)
	e6:SetCondition(s.thcon)
	e6:SetTarget(s.thtg)
	e6:SetOperation(s.thop)
	c:RegisterEffect(e6)
	--banish
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,4))
	e7:SetCategory(CATEGORY_REMOVE)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e7:SetProperty(EFFECT_FLAG_DELAY)
	e7:SetCode(EVENT_SPSUMMON_SUCCESS)
	e7:SetCondition(s.remcon)
	e7:SetTarget(s.remtg)
	e7:SetOperation(s.remop)
	c:RegisterEffect(e7)
end
s.listed_series={SET_ALLY_OF_JUSTICE,SET_FLAMVELL,SET_GENEX}
s.ally_series={SET_ALLY_OF_JUSTICE,SET_GENEX_ALLY}
s.ally_names={40155554,59482302}
--Materials
function s.mfilter1(c,fc,sumtype,tp,sub,mg,sg)
	return c:IsMonster() 
		and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
		and (c:IsCode(s.ally_names) or c:IsSetCard(s.listed_series)) 
		and not c:IsType(TYPE_FUSION)
end
function s.mfilter2(c,fc,sumtype,tp,sub,mg,sg)
	return c:IsMonster() and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
		and (c:IsCode(s.ally_names) or c:IsSetCard(s.listed_series)) 
end


--Modified Summoning Conditions
function s.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToDeckOrExtraAsCost,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
end
function s.contactop(g,tp)
	local fu,fd=g:Split(Card.IsFaceup,nil)
	if #fu>0 then Duel.HintSelection(fu,true) end
	if #fd>0 then Duel.ConfirmCards(1-tp,fd) end
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST|REASON_MATERIAL)
end

--[[Synchro Material Check
function s.syncheck(e,c,tp) --v1
	e:GetHandler():AssumeProperty(ASSUME_RACE,RACE_PYRO)
	e:GetHandler():AssumeProperty(ASSUME_ATTRIBUTE,ATTRIBUTE_WIND|ATTRIBUTE_WATER|ATTRIBUTE_FIRE|ATTRIBUTE_EARTH)
	return true
end

--Ally Machine Normal Summon reduction
function s.allynsfilter(c) --v1
	return (c:IsCode(s.ally_names) or c:IsSetCard(SET_ALLY_OF_JUSTICE) or c:IsSetCard(SET_GENEX_ALLY))
	and c:IsRace(RACE_MACHINE)
end]]--

--Restrict summon use
function s.matlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(s.listed_series)
end


--Add
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and not c:IsLocation(LOCATION_EXTRA)
end
function s.thfilter(c)
	return c:IsSetCard(s.listed_series) 
		--and c:IsSpellTrap()
		and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) or Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spfilter(c,e,tp)
	return (c:IsCode(s.ally_names) or c:IsSetCard(s.ally_series)) 
		--and not c:IsType(TYPE_TUNER)
		and c:IsRace(RACE_MACHINE)
		and (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp))
		--and not Duel.IsExistingMatchingCard(s.uniquefilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,c:GetCode())
		and c:IsMonster() 
end
function s.uniquefilter(c,code)
	return c:IsCode(code) and c:IsFaceup() and c:IsMonster()
end
function s.rescon(sg,e,tp,mg)
	return #sg<2 or not sg:IsExists(Card.IsType,1,nil,TYPE_TUNER)--sg:IsExists(Card.IsMonster,1,nil)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	local g2=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	local b1=#g1>0
	local b2=#g2>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if not (b1 or b2) then return end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	if op==1 then
	--if b1 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g1=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g1==0 or Duel.SendtoHand(g1,nil,REASON_EFFECT)==0 then return end
		Duel.ConfirmCards(1-tp,g1)
		Duel.ShuffleHand(tp)
	--end
	elseif op==2 then
	--if b2 and (not b1 or Duel.SelectYesNo(tp,aux.Stringid(id,3))) then
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		ft=math.min(ft,2)
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=aux.SelectUnselectGroup(g2,e,tp,1,ft,nil,1,tp,HINTMSG_SPSUMMON)
		if #sg>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	local c=e:GetHandler()
	--You cannot Special Summon from the Extra Deck for the rest of this turn, except AoJ/Flamvell/Genex monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not (c:IsSetCard(s.listed_series)) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--[[old
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	local g1=aux.SelectUnselectGroup(g,e,tp,1,2,s.rescon,1,tp,HINTMSG_ATOHAND)
	--local g1=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g1==0 or Duel.SendtoHand(g1,nil,REASON_EFFECT)==0 then return end
	Duel.ConfirmCards(1-tp,g1)
	Duel.ShuffleHand(tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local g2=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		ft=math.min(ft,2)
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=aux.SelectUnselectGroup(g2,e,tp,1,1,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
		if #sg>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end]]--1
end

--Banish
function s.remcon(e,tp,eg,ep,ev,re,r,rp)
	local mg=e:GetHandler():GetMaterial()
	return mg and e:GetHandler():IsSummonLocation(LOCATION_EXTRA) and mg:IsExists(Card.IsType,1,nil,TYPE_NORMAL)
end
function s.remtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,LOCATION_ONFIELD)
end
function s.remop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end