--Flamvell Coalescence
--Scripted by WolfSif
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Set 1 "Rekindling" or "Descending Lost Star" from your Deck during End Phase
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	--Extender
		--Sent
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.sp2con)
	e2:SetTarget(s.sp2tg)
	e2:SetOperation(s.sp2op)
	c:RegisterEffect(e2)
		--Banished
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
	--Also treated as Ally of Justice
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_ADD_SETCODE)
	e3:SetTargetRange(LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED,0)
	e3:SetTarget(s.setcodetg)
	e3:SetValue(SET_ALLY_OF_JUSTICE)
	c:RegisterEffect(e3)
	--register names
	aux.GlobalCheck(s,function()
		s.name_list={}
		s.name_list[0]={}
		s.name_list[1]={}
		aux.AddValuesReset(function()
			s.name_list[0]={}
			s.name_list[1]={}
		end)
	end)
end
s.listed_names={40155554,59482302,42079445,74845897}
s.listed_series={SET_ALLY_OF_JUSTICE,SET_FLAMVELL}

--Fix stats
function s.setcodetg(e,c)
	return (c:IsCode(40155554) or c:IsCode(59482302) or c:GetOriginalSetCard()==SET_ALLY_OF_JUSTICE or c:GetOriginalSetCard()==SET_FLAMVELL) and c:IsMonster()
end
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
	return (c:IsCode(40155554) or c:IsCode(59482302) or c:GetOriginalSetCard()==SET_ALLY_OF_JUSTICE or c:GetOriginalSetCard()==SET_FLAMVELL) and c:IsMonster()
end
function s.raceval(e,c,re,chk)
	if chk==0 then return true end
	return RACE_PYRO
end
function s.attval(e,c,re,chk)
	if chk==0 then return true end
	return ATTRIBUTE_FIRE
end


--Set
function s.setfilter(c)
	return (c:IsCode(42079445) or c:IsCode(74845897))
		and c:IsSpellTrap() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end

--Extender
function s.cfilter(c,tp)
	return c:IsSetCard(SET_FLAMVELL) and c:IsControler(tp)
		and not s.name_list[tp][c:GetCode()]
end
function s.sp2con(e,tp,eg,ep,ev,re,r,rp)
	for rc in aux.Next(eg) do
		if (rc:IsSetCard(SET_ALLY_OF_JUSTICE) or rc:IsSetCard(SET_FLAMVELL)) and rc:IsControler(tp) then return eg:IsExists(s.cfilter,1,nil,tp) end
	end
	return false
end

function s.sp2filter(c,e,tp,ev)
	if c:GetReasonCard() and not (c:GetReasonCard():IsSetCard(SET_ALLY_OF_JUSTICE) or c:GetReasonCard():IsSetCard(SET_FLAMVELL)) then return end
	if c:GetReasonEffect() and not (c:GetReasonEffect():GetHandler():IsSetCard(SET_ALLY_OF_JUSTICE) or c:GetReasonEffect():GetHandler():IsSetCard(SET_FLAMVELL) ) then return end
	if c:GetReasonEffect()==REASON_COST and c:GetReasonEffect():IsActivated() and not (Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_SETCODES)==SET_ALLY_OF_JUSTICE or Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_SETCODES)==SET_FLAMVELL) then return end
	return s.cfilter(c,tp) and c:IsMonster() and c:IsCanBeEffectTarget(e) and c:IsFaceup() 
		and (c:IsAbleToHand()
		or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP,tp))
		or (Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP,1-tp)))
end
	--Activation legality
function s.sp2tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.sp2filter,nil,e,tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>0 end
	local c=nil
	if #g>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		c=g:Select(tp,1,1,nil):GetFirst()
	else
		c=g:GetFirst()
	end
	Duel.SetTargetCard(c)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
	if c:IsLocation(LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
	end
end
function s.sp2op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	s.name_list[tp][tc:GetCode()]=true
	if not tc:IsRelateToEffect(e) then return end
	local b1=true
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,true,false)
	local b3=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP,1-tp)
	if not (b1 or b2 or b3) then return end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)},
		{b3,aux.Stringid(id,4)})
	if op==1 then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	elseif op==2 or op==3 then
		local target_player=op==2 and tp or 1-tp
		if Duel.SpecialSummon(tc,0,tp,target_player,true,false,POS_FACEUP)==0 then return end
	end
end
