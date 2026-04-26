--Gram, Aura of the Ice Barrier
--Scripted by Lam6da
local s,id=GetID()
function s.initial_effect(c)
	--Activate and SS
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(aux.RemainFieldCost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--cannot target other monsters for attacks, except equipped
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(s.cond)
	e2:SetValue(s.tgtg)
	c:RegisterEffect(e2)
	--Make all monsters Level 2 and WATER, then Set "Terror of Trishula"
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
s.listed_series={SET_ICE_BARRIER}
s.listed_names={06075533,92065772}
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_ICE_BARRIER) 
	and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.lfilter1(c,g)
	return g:IsExists(s.lfilter2,1,c,c:GetLevel())
end
function s.lfilter2(c,lvl)
	return c:GetLevel()==lvl
end
function s.spchk(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetLevel)==1 
	and sg:GetClassCount(Card.GetCode)>=#sg
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,nil,e,tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and g:IsExists(s.lfilter1,1,nil,g) 
		and aux.SelectUnselectGroup(g,e,tp,3,3,s.spchk,0) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,nil,e,tp)
	local sg=aux.SelectUnselectGroup(g,e,tp,3,12,s.spchk,1,tp,HINTMSG_CONFIRM,nil,false)
	Duel.ConfirmCards(1-tp,sg)
	local tg=nil
	if #sg>=5 then 
		tg=sg:Select(tp,1,1,nil)
	else 
		tg=sg:RandomSelect(1-tp,1)
	end
	local tc=tg:GetFirst()
	if c:IsRelateToEffect(e) and tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		Duel.Equip(tp,c,tc)
		--Add Equip limit
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		c:RegisterEffect(e1)
	end
	sg:RemoveCard(tc)
	Duel.SendtoGrave(sg,REASON_EFFECT)
end
function s.eqlimit(e,c)
	return e:GetOwner()==c
end
function s.cond(e)
	local tc=e:GetHandler():GetEquipTarget()
	return tc and tc:GetControler()==e:GetHandler():GetControler()
end
function s.tgtg(e,c)
	local tc=e:GetHandler():GetEquipTarget()
	return c~=tc
end

function s.setfilter(c)
	return c:IsCode(06075533) and c:IsSSetable() and (c:IsLocation(LOCATION_DECK) or c:IsFaceup())
end
--Make all monsters level 2 WATER
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e2:SetValue(ATTRIBUTE_WATER)
		tc:RegisterEffect(e2)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local sg=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,nil)
	if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local set=sg:Select(tp,1,1,nil)
		Duel.BreakEffect()
		Duel.SSet(tp,set)
	end
end


