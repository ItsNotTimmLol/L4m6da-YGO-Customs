--Ally of Justice Warp
--Scripted by WolfSif
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 or both of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.exfilter(c,e,tp,ft)
	return (c:IsSetCard(SET_ALLY_OF_JUSTICE) or c:IsSetCard(SET_FLAMVELL)) and c.material 
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp,c,ft)
end
function s.sp1filter(c,e,tp,mc,ft)
	return (c:IsCode(table.unpack(sc.material)) or c:IsCode(table.unpack(fc.material)))
		and ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sp2confilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
function s.sp2filter(c,e,tp)
	return (c:IsSetCard(SET_ALLY_OF_JUSTICE) or c:IsSetCard(SET_FLAMVELL))
		and c:IsType(TYPE_SYNCHRO) 
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return e:GetLabel()==2 and chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc,e,tp) end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE
	if ft<1 then return false end
	local b1=Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	local b2=Duel.IsExistingTarget(s.sp2confilter,tp,LOCATION_MZONE,0,1,nil,e,tp) and Duel.IsExistingMatchingCard(s.sp2filter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		e:SetProperty(0)
	elseif op==2 then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	end
	local loc=op==1 and LOCATION_DECK or LOCATION_DECK|LOCATION_GRAVE
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Special Summon 1 Level 4 Warrior monster from your Deck
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.lv4warriorspfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif op==2 then
		--Special Summon 1 EARTH Warrior monster with an equal or lower Level than the target from your Deck or GY
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		local tc=Duel.GetFirstTarget()
		if not (tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:HasLevel()) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.earthwarriorspfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp,tc:GetLevel())
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end