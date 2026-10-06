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
	--Apply
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
s.listed_names={22959079,28506708}
s.listed_series={SET_WORM,SET_FLAMVELL}
s.ally_series={SET_ALLY_OF_JUSTICE,SET_GENEX_ALLY}
s.ally_names={40155554,59482302}
s.w_nebula_names={18304915,30476000,40079081,53842829,55939812,76108887,90075978}
--Special Summon
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local controler=c:GetControler()
	local owner=c:GetOwner()
	if (c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEUP)) then controler=1-owner end
	if chk==0 then return Duel.GetLocationCount(controler,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.ssfilter,owner,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp,controler)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,c:GetOwner(),LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.ssfilter(c,e,tp,controler)
	return ((c:IsRace(RACE_REPTILE) and c:IsSetCard(SET_WORM))
		or ((c:IsCode(s.ally_names) or c:IsSetCard(s.listed_series)) and c:IsRace(RACE_MACHINE))
		or c:IsSetCard(SET_FLAMVELL))
		and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP_DEFENSE|POS_FACEDOWN_DEFENSE,controler)
		and (c:IsLocation(LOCATION_HAND|LOCATION_DECK) or c:IsFaceup())
end
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local controler=c:GetControler()
	local owner=c:GetOwner()
	
	if (c:IsPreviousLocation(LOCATION_SZONE)
		and c:IsPreviousPosition(POS_FACEUP)) or c:IsLocation(LOCATION_REMOVED) then
		controler=1-owner
	end
	
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.ssfilter),owner,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,nil,e,tp,controler)
	local ft=Duel.GetLocationCount(controler,LOCATION_MZONE)
	if ft>1 and Duel.IsPlayerAffectedByEffect(controler,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local maxct=math.min(#g,ft)
	if maxct<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local ss=aux.SelectUnselectGroup(g,e,owner,maxct,maxct,nil,1,tp,HINTMSG_SPSUMMON)
	if #ss==0 then return end
	local fid=e:GetHandler():GetFieldID()
	local tc=ss:GetFirst()
	local pos=Duel.SelectOption(owner,
		aux.Stringid(id,1),
		aux.Stringid(id,2))
	if pos==0 then
		pos=POS_FACEUP_DEFENSE
	else
		pos=POS_FACEDOWN_DEFENSE
	end
	for tc in aux.Next(ss) do
		Duel.SpecialSummonStep(tc,0,owner,tp,true,false,pos)
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1,fid)
	end
	Duel.SpecialSummonComplete()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ADJUST)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetLabel(fid)
	e1:SetLabelObject(ss)
	e1:SetCondition(s.tdcon)
	e1:SetOperation(s.tdop)
	e1:SetReset(RESET_EVENT)
	Duel.RegisterEffect(e1,controler)
end
function s.tdfilter(c,fid)
	return c:IsLocation(LOCATION_MZONE) and c:GetFlagEffectLabel(id)==fid
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	return g and Duel.GetTurnPlayer()==tp and Duel.IsMainPhase() and g:IsExists(s.tdfilter,1,nil,e:GetLabel())
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(s.tdfilter,nil,e:GetLabel())
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end

--Opponent's apply
function s.applyop(e,tp,eg,ep,ev,re,r,rp)
	s.ssop(e,1-tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local controler=c:GetControler()
	local owner=c:GetOwner()
	local g=Duel.GetMatchingGroup(s.setfilter,owner,LOCATION_DECK,0,nil)
	if not Duel.SelectYesNo(owner,aux.Stringid(id,4)) or Duel.GetLocationCount(owner,LOCATION_SZONE)<=0 or not Duel.IsExistingMatchingCard(s.setfilter,owner,LOCATION_DECK,0,1,nil) or #g==0 then return end
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
--Set
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SET,nil,1,tp,LOCATION_DECK)
end
