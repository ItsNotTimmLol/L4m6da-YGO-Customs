--Flamvell Coalescence
--Scripted by WolfSif
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Fix top deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
	--Extender
		--Sent
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_SZONE)
	--e2:SetCondition(s.sp2con)
	e2:SetTarget(s.sp2tg)
	e2:SetOperation(s.sp2op)
	c:RegisterEffect(e2)
		--Banished
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
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
	--Also treated as Ally of Justice
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EFFECT_ADD_SETCODE)
	e5:SetTargetRange(LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED,0)
	e5:SetTarget(s.setcodetg)
	e5:SetValue(SET_ALLY_OF_JUSTICE)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetTargetRange(LOCATION_GRAVE,0)
	e6:SetTarget(s.changegytg)
	c:RegisterEffect(e6)
	--Also treated as Flamvell
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetRange(LOCATION_SZONE)
	e7:SetCode(EFFECT_ADD_SETCODE)
	e7:SetTargetRange(LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED,0)
	e7:SetTarget(s.setcodetg)
	e7:SetValue(SET_FLAMVELL)
	c:RegisterEffect(e7)
	local e8=e7:Clone()
	e8:SetTargetRange(LOCATION_GRAVE,0)
	e8:SetTarget(s.changegytg)
	c:RegisterEffect(e8)
	--Also treated as Genex
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_FIELD)
	e9:SetRange(LOCATION_SZONE)
	e9:SetCode(EFFECT_ADD_SETCODE)
	e9:SetTargetRange(LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED,0)
	e9:SetTarget(s.setcodetg)
	e9:SetValue(SET_GENEX)
	c:RegisterEffect(e9)
	local e10=e9:Clone()
	e10:SetTargetRange(LOCATION_GRAVE,0)
	e10:SetTarget(s.changegytg)
	c:RegisterEffect(e10)
	--Ally Monsters are Pyro
	local e11=Effect.CreateEffect(c)
	e11:SetType(EFFECT_TYPE_FIELD)
	e11:SetCode(EFFECT_ADD_RACE)
	e11:SetRange(LOCATION_SZONE)
	e11:SetTargetRange(LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED,0)
	e11:SetTarget(s.setcodetg)
	e11:SetValue(RACE_PYRO)
	c:RegisterEffect(e11)
	local e12=e11:Clone()
	e12:SetTargetRange(LOCATION_GRAVE,0)
	e12:SetTarget(s.changegytg)
	c:RegisterEffect(e12)
	--Allied monsters are Fire
	local e13=Effect.CreateEffect(c)
	e13:SetType(EFFECT_TYPE_FIELD)
	e13:SetCode(EFFECT_ADD_ATTRIBUTE)
	e13:SetRange(LOCATION_SZONE)
	e13:SetTargetRange(LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED,0)
	e13:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_FLAMVELL))
	e13:SetValue(ATTRIBUTE_FIRE)
	c:RegisterEffect(e13)
	local e14=e13:Clone()
	e14:SetTargetRange(LOCATION_GRAVE,0)
	e14:SetTarget(s.changegytg)
	c:RegisterEffect(e14)
	--Code check stats
	local e15=Effect.CreateEffect(c)
	e15:SetType(EFFECT_TYPE_FIELD)
	e15:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e15:SetCode(id)
	e15:SetRange(LOCATION_SZONE)
	e15:SetTargetRange(1,0)
	e15:SetValue(s.statval)
	c:RegisterEffect(e15)
end
s.listed_series={SET_ALLY_OF_JUSTICE,SET_FLAMVELL,SET_GENEX}
s.ally_names={40155554,59482302}

--Fix stats
function s.setcodetg(e,c)
	return (c:IsCode(s.ally_names) or c:GetOriginalSetCard()==SET_ALLY_OF_JUSTICE or c:GetOriginalSetCard()==SET_FLAMVELL or c:GetOriginalSetCard()==SET_GENEX or c:GetOriginalSetCard()==SET_R_GENEX or c:GetOriginalSetCard()==SET_GENEX_ALLY) and c:IsMonster()
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
	return (c:IsCode(40155554) or c:IsCode(59482302) or c:GetOriginalSetCard()==SET_ALLY_OF_JUSTICE or c:GetOriginalSetCard()==SET_FLAMVELL or c:GetOriginalSetCard()==SET_GENEX or c:GetOriginalSetCard()==SET_R_GENEX or c:GetOriginalSetCard()==SET_GENEX_ALLY) and c:IsMonster()
end
function s.statval(e,c,re,chk)
	if chk==0 then return true end
	return SET_ALLY_OF_JUSTICE and SET_FLAMVELL and SET_GENEX and RACE_PYRO and ATTRIBUTE_FIRE
end

--Draw and place
function s.dtop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDeckbottomGroup(tp,1):GetFirst()
	Duel.ConfirmCards(tp,g)
	local opt=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	if opt==0 then
		Duel.MoveSequence(g,opt)
	end
end

function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)==0 then return end
	Duel.ShuffleHand(tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 then
		Duel.BreakEffect()
		if Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))==0 then
			Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
		else
			Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
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
function s.confilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_FLAMVELL)
end
function s.sp2con(e,tp,eg,ep,ev,re,r,rp)
	for rc in aux.Next(eg) do
		if (rc:IsSetCard(SET_FLAMVELL)) and rc:IsControler(tp) then return eg:IsExists(s.cfilter,1,nil,tp) end
	end
	return false
end
function s.sp2filter(c,e,tp,eg)
	--if c:GetReasonCard() and not ((c:GetReasonCard():IsSetCard(SET_ALLY_OF_JUSTICE)) or (c:GetReasonCard():IsSetCard(SET_FLAMVELL))) then return end
	--if c:GetReasonEffect() and not ((c:GetReasonEffect():GetHandler():IsSetCard(SET_ALLY_OF_JUSTICE)) or (c:GetReasonEffect():GetHandler():IsSetCard(SET_FLAMVELL))) then return end
	--if c:GetReasonEffect()==REASON_COST and c:GetReasonEffect():IsActivated() and not ((Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_SETCODES)==SET_ALLY_OF_JUSTICE) or (Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_SETCODES)==SET_FLAMVELL)) then return end
	return c:IsSetCard(SET_FLAMVELL) and c:IsControler(tp)
		and not s.name_list[tp][c:GetCode()]
		and c:IsMonster() and c:IsCanBeEffectTarget(e) and c:IsFaceup() 
		and (c:IsAbleToHand()
			or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP,tp))
			or (Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP,1-tp)))
		--and eg:IsExists(s.chkfilter,1,nil,c:GetLevel())
end
function s.chkfilter(c,lvl)
	return c:GetLevel()>lvl
end
	--Activation legality
function s.sp2tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.GetMatchingGroup(s.confilter,tp,LOCATION_MZONE,0,nil)
	if chkc then return s.sp2filter(chkc,e,tp,g) end--and eg:IsContains(chkc) end
	if chk==0 then return eg and eg:IsExists(s.sp2filter,1,nil,e,tp,g) end
	local g=eg:Filter(aux.NecroValleyFilter(s.sp2filter),nil,e,tp,g)
	if chk==0 then return #g>0 end
	local c=nil
	if #g>1 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
		c=g:Select(tp,1,1,nil):GetFirst()
	else
		c=g:GetFirst()
	end
	Duel.SetTargetCard(c)
	local code=c:GetCode()
	s.name_list[tp][code]=true
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
	if c:IsLocation(LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
	end
end
function s.tgval(e,re,rp)
	return rc:GetHandler():IsCode(id)
end
function s.higherfilter(c,lv)
	return c:IsMonster() and c:IsSetCard(SET_FLAMVELL) and c:GetLevel()>lv
end
function s.sp2op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local btrue=Duel.IsExistingMatchingCard(s.higherfilter,tp,LOCATION_MZONE,0,1,nil,tc:GetLevel())
	local b1=btrue
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,true,false) and btrue
	local b3=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP,1-tp)
	if not (b1 or b2 or b3) then return end
	if b3 and not btrue then return Duel.SpecialSummon(tc,0,tp,1-tp,true,false,POS_FACEUP) end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,4)},
		{b2,aux.Stringid(id,5)},
		{b3,aux.Stringid(id,6)})
	if op==1 then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	elseif op==2 or op==3 or not (b1 and b2) then
		local target_player=op==2 and tp or 1-tp
		if Duel.SpecialSummon(tc,0,tp,target_player,true,false,POS_FACEUP)==0 then return end
	end
end
