--W Nebula Invasion
--Scripted by WolfSif
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Can be activated from the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	c:RegisterEffect(e2)
	--[[atkchange
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetCode(EFFECT_SET_BASE_ATTACK)
	e3:SetTarget(s.atkdeftg)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_SET_BASE_DEFENSE)
	e4:SetValue(s.defval)
	c:RegisterEffect(e4)]]
	--Set or activate on banish
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,4))
	e8:SetCategory(CATEGORY_SET)
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e8:SetCode(EVENT_REMOVE)
	e8:SetProperty(EFFECT_FLAG_DELAY)
	e8:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_CHAIN)
	e8:SetTarget(s.settg)
	e8:SetOperation(s.setop)
	c:RegisterEffect(e8)
	--Choose
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_REMOVE+CATEGORY_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_CHAIN)
	e4:SetTarget(s.eftg)
	e4:SetOperation(s.efop)
	c:RegisterEffect(e4)
	
	--[[Normal Summon
	local e9=Effect.CreateEffect(c)
	e9:SetDescription(aux.Stringid(id,7))
	e9:SetCategory(CATEGORY_SUMMON)
	e9:SetType(EFFECT_TYPE_QUICK_O)
	e9:SetCode(EVENT_FREE_CHAIN)
	e9:SetRange(LOCATION_SZONE)
	e9:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e9:SetTarget(s.nstg)
	e9:SetOperation(s.nsop)
	c:RegisterEffect(e9)]]--
end
s.listed_names={22959079,28506708}
s.listed_series={SET_WORM}
s.w_nebula_names={18304915,30476000,40079081,53842829,55939812,76108887,90075978}
--Dimikles buff
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	eg:GetFirst():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1)
end
function s.atkconfilter(c)
	return c:IsFaceup() and c:IsCode(88438982) and c:GetFlagEffect(id)~=0
end
function s.atkdeftg(e,c)
	return c:GetFlagEffect(id)==0
end
function s.atkval(e,c)
	local ct=Duel.GetMatchingGroupCount(s.atkconfilter,0,LOCATION_MZONE,0,nil)
	if ct<1 then ct=0.5 end
	return c:GetBaseAttack()/(ct*2)
end
function s.defval(e,c)
	local ct=Duel.GetMatchingGroupCount(s.atkconfilter,0,LOCATION_MZONE,0,nil)
	if ct<1 then ct=0.5 end
	return c:GetBaseDefense()/(ct*2)
end

--Roll to add
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,2)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function s.thfilter(c,dc)
	return c:IsRace(RACE_REPTILE) and c:IsSetCard(SET_WORM)
		and c:IsMonster() and c:HasLevel() and not c:IsLevel(dc/2) and c:IsAbleToHand() and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED)) 
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local dn=2
	local d1,d2=Duel.TossDice(tp,dn)
	local dc=(d1+d2)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_ONFIELD|LOCATION_DECK,0,nil,dc)
	local sg=g:SelectWithSumEqual(tp,Card.GetLevel,dc,1,2)
	if #sg>0 then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end

--Normal Summon/Set
function s.nsfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsSetCard(SET_WORM)
		and c:IsMonster()
		and c:IsSummonable(true,nil)
end
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.nsfilter,tp,LOCATION_HAND,0,nil,true,nil)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE,tp)
	if chk==0 then return ft>0 and #g>0 and  Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.nsop(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.GetMatchingGroup(s.nsfilter,tp,LOCATION_HAND,0,nil,true,nil)
	if #g1>0 then
		Duel.BreakEffect()
		Duel.ShuffleHand(tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		sg=g1:Select(tp,1,1,nil):GetFirst()
		Duel.Summon(tp,sg,true,nil)
	end
end
--Flip
function s.posfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsSetCard(SET_WORM) 
		and c:IsFacedown() and c:IsDefensePos()
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.posfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local tc=Duel.SelectMatchingCard(tp,s.posfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		local pos=Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEUP_DEFENSE)
		Duel.ChangePosition(tc,pos)
	end
end

--Set or activate S/T
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(Card.IsFacedown,e:GetHandlerPlayer(),LOCATION_SZONE,0,1,nil) --Duel.GetFieldGroupCount(tp,LOCATION_SZONE,0)<=3
end
function s.setfilter(c,tp)
	return (c:IsSetCard(SET_WORM) or c:IsCode(s.w_nebula_names)) and c:IsSpellTrap() and not c:IsCode(id)
		and (c:IsSSetable() or c:GetActivateEffect():IsActivatable(tp,true,true))
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,tp) and Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,nil,tp)
	if #g==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	local tc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	local b1=(tc:IsFieldSpell() or (tc:IsSpell() and tc:IsType(TYPE_CONTINUOUS)))
	local b2=tc
	if not b1 then 
		Duel.SSet(tp,tc)
	else
		local op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,5)},
			{b2,aux.Stringid(id,6)})
		if op==1 then
			if tc:IsFieldSpell() then
				Duel.ActivateFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
			else
				Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
				local te=tc:GetActivateEffect()
				local tep=tc:GetControler()
				local cost=te:GetCost()
				if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
				Duel.RaiseEvent(tc,id,te,0,tp,tp,Duel.GetCurrentChain())
			end
		else
			Duel.SSet(tp,tc)
		end
	end
	--[[Place
	if tc then
		if not ((tc:IsFieldSpell() or (tc:IsSpell() and tc:IsType(TYPE_CONTINUOUS))) and Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,5))) then
			Duel.SSet(tp,tc)
		else
			local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
			if fc and tc:IsFieldSpell() then
				Duel.SendtoGrave(fc,REASON_RULE)
				Duel.BreakEffect()
				Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
			elseif tc:IsFieldSpell() then
				Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
			else
				Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			end
		end
	end]]--
end

--Can Normal Summon/Set a "Worm" monster
function s.nsfilter(c)
	return c:IsSetCard(SET_WORM) and c:IsMonster()
		and c:IsRace(RACE_REPTILE) and c:IsSummonable(true,nil)
end

function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local can_remove=Duel.IsExistingMatchingCard(s.remfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil)
	local can_ns=Duel.IsExistingMatchingCard(s.nsfilter,tp,LOCATION_HAND,0,1,nil)
		or Duel.IsExistingMatchingCard(s.nsfilter,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then
		return can_remove or can_ns
	end
	local opt
	if can_remove and can_ns then
		opt=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
	elseif can_remove then
		opt=0
	else
		opt=1
	end
	e:SetLabel(opt)
	if opt==0 then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD)
	else
		Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
	end
end

function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local opt=e:GetLabel()
	--Banish 1 "Worm" or "W Nebula" card until the next End Phase
	if opt==0 then
		local g=Duel.SelectMatchingCard(tp,s.remfilter,tp,
			LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
		local tc=g:GetFirst()
		if not tc then return end
		if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)~=0 then
			--If you banished a "Worm Call" you controlled, return it immediately
			if tc:IsCode(28506708) and tc:IsControler(tp) and tc:IsLocation(LOCATION_REMOVED) then
				Duel.ReturnToField(tc)
			end
		end
	--Immediately Normal Summon 1 Reptile "Worm"
	else
		local g=Duel.GetMatchingGroup(s.nsfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
		if #g==0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		if not tc then return end
		--Or Set during opponent's turn
		if Duel.GetTurnPlayer()==tp then
			Duel.Summon(tp,tc,true,nil)
		else
			Duel.SummonOrSet(tp,tc,true,nil)
		end
	end
end