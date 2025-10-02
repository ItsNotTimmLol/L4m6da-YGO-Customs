--Ally of Justice Simulacrum
--Scripted by WolfSif
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 'Ally' monster from your hand or GY, and if you do, equip it with this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--LIGHT Lock during Main Phase
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_HAND|LOCATION_GRAVE)
	e2:SetCondition(function(e) return Duel.IsTurnPlayer(e:GetHandlerPlayer()) end)
	e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e2:SetValue(ATTRIBUTE_LIGHT)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetTargetRange(LOCATION_GRAVE,0)
	e3:SetTarget(s.tg)
	c:RegisterEffect(e3)
	--Code check LIGHT
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetCode(id)
	e6:SetRange(LOCATION_SZONE)
	e6:SetTargetRange(0,1)
	e6:SetValue(s.attval)
	c:RegisterEffect(e6)
	--avoid battle damage
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e7:SetRange(LOCATION_SZONE)
	e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e7:SetTargetRange(1,0)
	c:RegisterEffect(e7)
	--Add to hand to shuffle into Deck and bounce to hand
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,1))
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e8:SetCategory(CATEGORY_TODECK)
	e8:SetProperty(EFFECT_FLAG_DELAY)
	e8:SetCode(EVENT_CHAINING)
	e8:SetRange(LOCATION_GRAVE|LOCATION_REMOVED)
	e8:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==tp and re:IsMonsterEffect() and re:GetHandler():IsSetCard(s.listed_series) end)
	e8:SetTarget(s.returntg)
	e8:SetOperation(s.returnop)
	c:RegisterEffect(e8)
	--[[Flamvell banish & LP Ex
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,0))
	e8:SetCategory(CATEGORY_REMOVE)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e8:SetCode(EVENT_CHAINING)
	e8:SetRange(LOCATION_SZONE)
	e8:SetCondition(s.rmcon)
	e8:SetTarget(s.rmtg)
	e8:SetOperation(s.rmop)
	c:RegisterEffect(e8]]
end
s.listed_names={40155554,59482302}
s.listed_series={SET_ALLY_OF_JUSTICE,SET_FLAMVELL}
function s.spfilter(c,e,tp)
	return (c:IsCode(s.listed_names) or (c:IsSetCard(s.listed_series) and c:IsLevelAbove(5))) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if not tc then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)>0 and Duel.Equip(tp,c,tc) then
		--Equip limit
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetValue(function(e,c) return c==tc end)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end

--Fix stats
function s.tg(e,c)
	if c:GetFlagEffect(1)==0 then
		c:RegisterFlagEffect(1,0,0,0)
		local eff={c:GetCardEffect(EFFECT_NECRO_VALLEY)}
		c:ResetFlagEffect(1)
		for _,te in ipairs(eff) do
			local op=te:GetOperation()
			if not op or op(e,c) then return false end
		end
	end
	return c:IsMonster()
end
function s.raceval(e,c,re,chk)
	if chk==0 then return true end
	return RACE_PYRO
end
function s.attval(e,c,re,chk)
	if chk==0 then return true end
	return ATTRIBUTE_LIGHT
end

--Shuffle to bounce
function s.returnfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsAbleToDeck()
end
function s.returntg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_GRAVE|LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.returnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)>0 and c:IsLocation(LOCATION_HAND)) then return end
	Duel.ShuffleHand(tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g1=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil)
	if #g1>0 then
		Duel.HintSelection(g1,true)
		local g2=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,nil)
		if Duel.SendtoDeck(g1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) and #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
			local hg=g2:Select(tp,1,1,nil)
			Duel.HintSelection(hg,true)
			Duel.BreakEffect()
			Duel.SendtoHand(hg,nil,REASON_EFFECT)
		end	
	end
end

--LP & Banish Ex
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc~=c
		and rc:IsSetCard(SET_FLAMVELL) and rc:IsControler(tp)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_DECK)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	Duel.Recover(tp,rc:GetLevel()*200,REASON_EFFECT)
	Duel.BreakEffect()
	local g=Duel.GetDecktopGroup(1-tp,1)
	Duel.DisableShuffleCheck()
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end