--Ally of Justice Simulacrum
--Scripted by WolfSif
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 'Ally' monster from your hand or GY, and if you do, equip it with this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	--e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--LIGHT Lock during Main Phase
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_HAND|LOCATION_GRAVE)
	e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e2:SetValue(ATTRIBUTE_LIGHT)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetTargetRange(0,LOCATION_GRAVE)
	e3:SetTarget(s.changegytg)
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
	--[[avoid battle damage
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e7:SetRange(LOCATION_SZONE)
	e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e7:SetTargetRange(1,0)
	c:RegisterEffect(e7)
	--All your opponent's monsters must attack
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetCode(EFFECT_MUST_ATTACK)
	e8:SetRange(LOCATION_MZONE)
	e8:SetTargetRange(0,LOCATION_MZONE)
	c:RegisterEffect(e8)
	--Add to hand to shuffle into Deck and bounce to hand
	local e9=Effect.CreateEffect(c)
	e9:SetDescription(aux.Stringid(id,1))
	e9:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e9:SetCategory(CATEGORY_TOHAND)
	e9:SetProperty(EFFECT_FLAG_DELAY)
	e9:SetCode(EVENT_CHAINING)
	e9:SetRange(LOCATION_GRAVE|LOCATION_REMOVED)
	e9:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==tp and re:IsMonsterEffect() and re:GetHandler():IsSetCard(s.listed_series) and not re:GetHandler():IsType(TYPE_FUSION) end)
	e9:SetTarget(s.returntg)
	e9:SetOperation(s.returnop)
	c:RegisterEffect(e9)
	--Flamvell banish & LP Ex
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
function s.spfilter(c,e,tp,ct)
	return (c:IsCode(s.listed_names) or c:IsSetCard(s.listed_series)) 
		and c:IsType(TYPE_SYNCHRO)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		and c:IsLevelBelow(ct)
		and not c:IsPublic()
end
function s.spcostfilter(c,e,tp)
	return (c:IsCode(s.listed_names) or c:IsSetCard(s.listed_series))
		and c:IsMonster()
		and not c:IsPublic()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=Duel.GetMatchingGroup(s.spcostfilter,tp,LOCATION_HAND|LOCATION_DECK,0,nil):GetClassCount(Card.GetCode)
	if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,ct) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,ct):GetFirst()
	Duel.SetTargetCard(tc)
	e:SetLabel(tc:GetLevel())
	Duel.ConfirmCards(1-tp,tc)
	Duel.ShuffleExtra(tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,tp,0)
end
function s.rthfilter(c,tp)
	return c:IsOwner(1-tp) and c:IsAbleToHand()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lvl=e:GetLabel()
	local tc=Duel.GetFirstTarget()
	local g=Duel.GetMatchingGroup(s.spcostfilter,tp,LOCATION_HAND|LOCATION_DECK,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local rg=g:Select(tp,1,1,nil)
	g:Remove(Card.IsCode,nil,rg:GetFirst():GetCode())
	Duel.ConfirmCards(1-tp,rg)		--Seems to work for some reason?
	for i = 2,lvl do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local sg=g:Select(tp,1,1,nil)
		g:Remove(Card.IsCode,nil,sg:GetFirst():GetCode())
		Duel.ConfirmCards(1-tp,sg)		--Seems to work for some reason?
		rg:Merge(sg)
	end
	--Duel.ConfirmCards(1-tp,rg)
	local td=rg:FilterCount(Card.IsLocation,nil,LOCATION_HAND)
	Duel.SendtoDeck(rg,nil,td,REASON_EFFECT)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	if tc and #rg>0 and Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP) and Duel.Equip(tp,c,tc) then
		--Equip limit
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetValue(function(e,c) return c==tc end)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
	tc:CompleteProcedure() 
	if Duel.IsExistingMatchingCard(s.rthfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local g=Duel.SelectMatchingCard(tp,s.rthfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,td,nil,tp)
		if #g>0 then
			Duel.HintSelection(g)
			Duel.BreakEffect()
			Duel.SendtoHand(g,nil,REASON_EFFECT)
		end
	end
end

--Fix stats
function s.changegytg(e,c)
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
	if chk==0 then return c:IsAbleToHand() end --[[and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_GRAVE|LOCATION_REMOVED,LOCATION_REMOVED,1,nil)]]--
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
	--Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.returnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)>0 and c:IsLocation(LOCATION_HAND)) then return end
	Duel.ShuffleHand(tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	--local g1=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil)
	local g2=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,nil)
	if #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local hg=g2:Select(tp,1,1,nil)
		Duel.HintSelection(hg,true)
		Duel.BreakEffect()
		Duel.SendtoHand(hg,nil,REASON_EFFECT)
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