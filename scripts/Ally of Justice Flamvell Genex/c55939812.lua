--W Nebula Invasion
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DICE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_STANDBY_PHASE,0)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sstg)
	e1:SetOperation(s.ssop)
	c:RegisterEffect(e1)
	--If this face-up card leaves the field: Set 1 "W Nebula" Quick-Play Spell or Trap
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_SET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.sstg)
	e2:SetOperation(s.applyop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(function(e) return (e:GetHandler():IsPreviousLocation(LOCATION_SZONE) and e:GetHandler():IsPreviousPosition(POS_FACEUP)) end)
	c:RegisterEffect(e3)
end
s.roll_dice=true
s.listed_names={22959079,28506708}
s.listed_series={SET_WORM}
s.w_nebula_names={18304915,30476000,40079081,53842829,55939812,76108887,90075978}
--Special Summon
function s.sscheckfilter(c,e,tp,controler)
	return c:IsRace(RACE_REPTILE) and c:IsSetCard(SET_WORM)
		and c:GetAttack()>0
		and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE|POS_FACEDOWN_DEFENSE,controler)
end
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local controler=c:GetControler()
	local owner=c:GetOwner()
	if c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEUP) then controler=1-owner end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.sscheckfilter,owner,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp,controler)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,c:GetOwner(),LOCATION_HAND|LOCATION_DECK)
end
function s.ssfilter(c,e,tp,controler,maxatk)
	return c:IsRace(RACE_REPTILE) and c:IsSetCard(SET_WORM)
		and c:GetAttack()>0 and c:GetAttack()<=maxatk
		and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE|POS_FACEDOWN_DEFENSE,controler)
end
function s.rescon(sg,e,tp,mg)
	local tc=sg:GetFirst()
	if not tc then return true end
	return sg:GetClassCount(Card.GetCode)==1,sg:GetClassCount(Card.GetCode)~=1
end
--[[Buff during opponent's turn?
function s.rollfilter(c,tp)
	return c:IsOwner(1-tp)
end]]--
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local controler=c:GetControler()
	local owner=c:GetOwner()
	--local die=Duel.GetMatchingGroupCount(s.rollfilter,controler,0,LOCATION_ONFIELD,nil,tp)
	--Roll a six-sided die.
	local roll=Duel.TossDice(tp,1)
	--The "same name" is the name of the monster the opponent Special Summoned.
	--If that monster did not remain on the field, use its original code.
	local g=Duel.GetMatchingGroup(s.ssfilter,owner,LOCATION_HAND|LOCATION_DECK,0,nil,e,tp,controler,roll*100)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local maxct=math.min(#g,ft)
	if maxct<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local ss=aux.SelectUnselectGroup(g,e,owner,1,maxct,s.rescon,1,tp,HINTMSG_SPSUMMON)
	--Summon each selected monster to field.
	Duel.SpecialSummon(ss,0,owner,tp,false,false,POS_FACEUP_DEFENSE|POS_FACEDOWN_DEFENSE)
	if not Duel.SelectYesNo(owner,aux.Stringid(id,3)) and Duel.GetLocationCount(owner,LOCATION_SZONE)<=0 and not Duel.IsExistingMatchingCard(s.setfilter,owner,LOCATION_DECK,0,1,nil) then return end
	local g=Duel.GetMatchingGroup(s.setfilter,owner,LOCATION_DECK,0,nil)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,owner,HINTMSG_SET)
	local tc=g:Select(owner,1,1,nil):GetFirst()
	if not tc then return end
	Duel.SSet(owner,tc)
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
function s.setfilter(c)
	return c:IsCode(s.w_nebula_names)
		and (c:IsType(TYPE_QUICKPLAY) or c:IsType(TYPE_TRAP))
		and c:IsSSetable()
end

--Opponent's apply
function s.applyop(e,tp,eg,ep,ev,re,r,rp)
	s.ssop(e,1-tp,eg,ep,ev,re,r,rp)
end


--Set
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SET,nil,1,tp,LOCATION_DECK)
end
