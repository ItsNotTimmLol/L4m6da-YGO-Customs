--Flamvell Coalescence
--Scripted by WolfSif
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Shuffle card to Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e,c) return Duel.IsExistingMatchingCard(s.tdconfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) end)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
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
	local e4=e3:Clone()
	e4:SetTargetRange(LOCATION_GRAVE,0)
	e4:SetTarget(s.changegytg)
	c:RegisterEffect(e4)
	--Also treated as Flamvell
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EFFECT_ADD_SETCODE)
	e5:SetTargetRange(LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED,0)
	e5:SetTarget(s.setcodetg)
	e5:SetValue(SET_FLAMVELL)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetTargetRange(LOCATION_GRAVE,0)
	e6:SetTarget(s.changegytg)
	c:RegisterEffect(e6)
	--Ally Monsters are Pyro
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_CHANGE_RACE)
	e7:SetRange(LOCATION_SZONE)
	e7:SetTargetRange(LOCATION_MZONE,0)
	e7:SetTarget(s.setcodetg)
	e7:SetValue(RACE_PYRO)
	c:RegisterEffect(e7)
	local e8=e7:Clone()
	e8:SetTargetRange(LOCATION_GRAVE,0)
	e8:SetTarget(s.changegytg)
	c:RegisterEffect(e8)
	--Allied monsters are Fire
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_FIELD)
	e9:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e9:SetRange(LOCATION_SZONE)
	e9:SetTargetRange(LOCATION_MZONE,0)
	e9:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_FLAMVELL))
	e9:SetValue(ATTRIBUTE_FIRE)
	c:RegisterEffect(e9)
	local e10=e9:Clone()
	e10:SetTargetRange(LOCATION_GRAVE,0)
	e10:SetTarget(s.changegytg)
	c:RegisterEffect(e10)
	--Code check Pyro
	local e13=Effect.CreateEffect(c)
	e13:SetType(EFFECT_TYPE_FIELD)
	e13:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e13:SetCode(id)
	e13:SetRange(LOCATION_SZONE)
	e13:SetTargetRange(1,0)
	e13:SetValue(s.raceval)
	c:RegisterEffect(e13)
	--Code check Fire
	local e14=Effect.CreateEffect(c)
	e14:SetType(EFFECT_TYPE_FIELD)
	e14:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e14:SetCode(id)
	e14:SetRange(LOCATION_SZONE)
	e14:SetTargetRange(1,0)
	e14:SetValue(s.attval)
	c:RegisterEffect(e14)
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
s.listed_names={40155554,59482302}
s.listed_series={SET_ALLY_OF_JUSTICE,SET_FLAMVELL}

--Fix stats
function s.setcodetg(e,c)
	return (c:IsCode(s.listed_names) or c:GetOriginalSetCard()==SET_ALLY_OF_JUSTICE or c:GetOriginalSetCard()==SET_FLAMVELL) and c:IsMonster()
end
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
	return (c:IsCode(40155554) or c:IsCode(59482302) or c:GetOriginalSetCard()==SET_ALLY_OF_JUSTICE or c:GetOriginalSetCard()==SET_FLAMVELL) and c:IsMonster()
end
function s.setval(e,c,re,chk)
	if chk==0 then return true end
	return SET_ALLY_OF_JUSTICE and SET_FLAMVELL
end
function s.raceval(e,c,re,chk)
	if chk==0 then return true end
	return RACE_PYRO
end
function s.attval(e,c,re,chk)
	if chk==0 then return true end
	return ATTRIBUTE_FIRE
end


--To Deck
function s.tdconfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_FLAMVELL) and (c:IsAttackAbove(1800) or c:IsDefenseAbove(1800))
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil)
	if #sg>0 then
		Duel.HintSelection(sg)
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end

--Extender
function s.cfilter(c,tp)
	return c:IsSetCard(SET_FLAMVELL) and c:IsControler(tp)
		and not s.name_list[tp][c:GetCode()]
end
function s.sp2con(e,tp,eg,ep,ev,re,r,rp)
	for rc in aux.Next(eg) do
		if (rc:IsSetCard(SET_FLAMVELL)) and rc:IsControler(tp) then return eg:IsExists(s.cfilter,1,nil,tp) end
	end
	return false
end

function s.sp2filter(c,e,tp,ev)
	if c:GetReasonCard() and not (c:GetReasonCard():IsSetCard(SET_FLAMVELL)) then return end
	if c:GetReasonEffect() and not (c:GetReasonEffect():GetHandler():IsSetCard(SET_FLAMVELL)) then return end
	if c:GetReasonEffect()==REASON_COST and c:GetReasonEffect():IsActivated() and not (Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_SETCODES)==SET_FLAMVELL) then return end
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
