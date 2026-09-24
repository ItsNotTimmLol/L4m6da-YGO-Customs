--W Nebula Invasion
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DICE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.invtg)
	e1:SetOperation(s.invop)
	c:RegisterEffect(e1)
	--If this face-up card leaves the field: Set 1 "W Nebula" Quick-Play Spell or Trap
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,4))
	e2:SetCategory(CATEGORY_SET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
s.roll_dice=true
s.listed_names={22959079,28506708}
s.listed_series={SET_WORM}
s.w_nebula_names={18304915,30476000,40079081,53842829,55939812,76108887,90075978}
--Special Summon
function s.reveal_filter(c,e,op)
	return c:IsRace(RACE_REPTILE) and c:IsSetCard(SET_WORM)
		and c:IsCanBeSpecialSummoned(e,0,op,false,false,POS_FACEUP) and c:IsMonster()
end
function s.invtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.reveal_filter,tp,LOCATION_DECK,0,3,nil,e,1-tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_DECK)
end
function s.invfilter(c,e,tp,maxatk)
	return c:IsRace(RACE_REPTILE) and c:IsSetCard(SET_WORM)
		and c:GetAttack()>0 and c:GetAttack()<=maxatk
		and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
function s.rescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetCode)==1
end
function s.invop(e,tp,eg,ep,ev,re,r,rp)
	--Reveal 3 Worms
	local rg=Duel.SelectMatchingCard(tp,s.reveal_filter,tp,LOCATION_DECK,0,3,3,nil,e,1-tp)
	if #rg~=3 or Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then return end
	Duel.ConfirmCards(1-tp,rg)
	--Opponent chooses the monster they Special Summon
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
	local sg=rg:Select(1-tp,1,1,nil)
	local tc=sg:GetFirst()
	if not tc then
		Duel.SendtoDeck(rg,nil,SEQ_DECKSHUFFLE)
		return
	end
	Duel.SpecialSummon(sg,0,1-tp,1-tp,false,false,POS_FACEUP)
	--Shuffle the other 2 revealed cards into the Deck.
	rg:Sub(sg)
	if #rg>0 then
		Duel.SendtoDeck(rg,nil,SEQ_DECKSHUFFLE,tp)
	end
	--Roll a six-sided die.
	local roll=Duel.TossDice(tp,1)
	--The "same name" is the name of the monster the opponent Special Summoned.
	--If that monster did not remain on the field, use its original code.
	local g=Duel.GetMatchingGroup(s.invfilter,tp,LOCATION_DECK,0,nil,e,tp,roll*100)
	local self_ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local opp_ct=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	local maxct=math.min(#g,self_ct+opp_ct)
	if maxct<=0 and not Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,1)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local ss=aux.SelectUnselectGroup(g,e,tp,1,maxct,s.rescon,1,tp,HINTMSG_SPSUMMON)
	--Summon each selected monster to either field.
	for tc in aux.Next(ss) do
		local self_ok=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		local opp_ok=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		if not (self_ok or opp_ok) then break end
		local dest
		if self_ok and opp_ok then
			local op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
			dest=(op==0) and tp or (1-tp)
		elseif self_ok then
			dest=tp
		else
			dest=1-tp
		end
		Duel.SpecialSummon(Group.FromCards(tc),0,tp,dest,false,false,POS_FACEDOWN_DEFENSE)
	end
end

--Set
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsPreviousPosition(POS_FACEUP)
end
function s.setfilter(c)
	return c:IsCode(s.w_nebula_names) and not c:IsCode(id)
		and (c:IsType(TYPE_QUICKPLAY) or c:IsType(TYPE_TRAP))
		and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SET,nil,1,tp,LOCATION_DECK)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if not tc then return end
	Duel.SSet(tp,tc)
	--Can be activated this turn
	if tc:IsType(TYPE_TRAP) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	elseif tc:IsType(TYPE_QUICKPLAY) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
