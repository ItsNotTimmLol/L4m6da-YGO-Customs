--W Nebula Wormhole
--Scripted by WolfSif
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Negate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(s.negtg)
	c:RegisterEffect(e1)
	--Choose attack targets
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EFFECT_PATRICIAN_OF_DARKNESS)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetCondition(s.atkcon)
	c:RegisterEffect(e2)
	--must attack
	local e3=e2:Clone()
	e3:SetCode(EFFECT_MUST_ATTACK)
	e3:SetTargetRange(0,LOCATION_MZONE)
	c:RegisterEffect(e3)
	--Chain
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_CONTROL+CATEGORY_DRAW+CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_FZONE)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e5:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	e5:SetCondition(s.chaincon)
	e5:SetTarget(s.chaintg)
	e5:SetOperation(s.chainop)
	e5:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e5)
	--Set 1 "Dimensionhole" and/or "Worm Call"
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_SET)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_FZONE)
	e6:SetCountLimit(1)
	e6:SetTarget(s.settg)
	e6:SetOperation(s.setop)
	c:RegisterEffect(e6)
end
s.listed_names={22959079,28506708}
s.listed_series={SET_WORM}
s.w_nebula_names={18304915,30476000,40079081,53842829,55939812,76108887,90075978}
--Negate
function s.equipf(c)
	return c:IsSetCard(SET_WORM)
end
function s.negtg(e,c)
	return c:GetEquipGroup():IsExists(s.equipf,1,nil)
end

--Choose attack targets
function s.atkconfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsSetCard(SET_WORM)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	return #g>0 and #g==g:FilterCount(s.atkconfilter,nil)
end

--Set
function s.setfilter(c)
	return (c:IsCode(s.listed_names) or c:IsCode(s.w_nebula_names)) and c:IsSpellTrap() and not c:IsFieldSpell() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) end
end
function s.rescon(sg,e,tp,mg)
	return #sg==1 or (#sg==2 and (sg:FilterCount(Card.IsCode,nil,22959079)==1
		or sg:FilterCount(Card.IsCode,nil,28506708)==1)) or (sg:FilterCount(Card.IsCode,nil,22959079)==1
		and sg:FilterCount(Card.IsCode,nil,28506708)==1)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
	if #g==0 then return end
	local ft=math.min(Duel.GetLocationCount(tp,LOCATION_SZONE),3)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,ft,s.rescon,1,tp,HINTMSG_SET)
	if #sg>0 then
		Duel.SSet(tp,sg)
	end
end

--Give control
function s.chaincon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler()~=e:GetHandler()
end
function s.chainfilter(c,tp)
	return c:IsSetCard(SET_WORM)
		and ((c:IsRace(RACE_REPTILE) and c:IsControler(tp) and (c:IsControlerCanBeChanged() or c:IsAbleToRemove())
		or (c:IsFaceup() and c:IsCode(28506708) and (c:IsAbleToHand() or c:IsAbleToRemove()) and not c:IsCode(id))))
end
function s.chaintg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and s.chainfilter(chkc) and chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(s.chainfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.chainfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,tp)
	Duel.SetPossibleOperationInfo(0,CATEGORY_CONTROL,tc,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,tc,1,tp,LOCATION_ONFIELD)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,tc,1,tp,0)
end
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local b1=Duel.GetMZoneCount(1-tp,g,tp)>0 and tc:IsRace(RACE_REPTILE) and tc:IsControler(tp)
	local b2=tc:IsAbleToHand()
	local b3=tc:IsAbleToRemove()
	if not (b1 or b2 or b3) or not tc:IsRelateToEffect(e) then
		return
	elseif b1 and not b2 and not b3 then
		--Give control
		Duel.GetControl(tc,1-tp)
	elseif b2 and not b1 and not b3 then
		--Return to hand
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	elseif b3 and not b1 and not b2 then
		--Banish until next End Phase
		if tc:IsMonster() then
			local reset_count=1
			local return_condition=nil
			if Duel.IsEndPhase() then
				local turn_count=Duel.GetTurnCount()
				reset_count=2
				return_condition=function() return Duel.GetTurnCount()~=turn_count end
			end
			aux.RemoveUntil(tc,nil,REASON_EFFECT,PHASE_END,id,e,tp,aux.DefaultFieldReturnOp,return_condition,nil,reset_count)
		else
			aux.RemoveUntil(tc,nil,REASON_EFFECT,PHASE_END,id,e,tp,s.returnop)
		end
	else
		local op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,2)},
			{b2,aux.Stringid(id,3)},
			{b3,aux.Stringid(id,4)})
		if op==1 then
			--Give control
			Duel.GetControl(tc,1-tp)
		elseif op==2 then
			--Return to hand
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		elseif op==3 then
			--Banish until next End Phase
			if tc:IsMonster() then
				local reset_count=1
				local return_condition=nil
				if Duel.IsEndPhase() then
					local turn_count=Duel.GetTurnCount()
					reset_count=2
					return_condition=function() return Duel.GetTurnCount()~=turn_count end
				end
				aux.RemoveUntil(tc,nil,REASON_EFFECT,PHASE_END,id,e,tp,aux.DefaultFieldReturnOp,return_condition,nil,reset_count)
			else
				aux.RemoveUntil(tc,nil,REASON_EFFECT,PHASE_END,id,e,tp,s.returnop)
			end
		end
	end
end
function s.returnop(rg,e,tp,eg,ep,ev,re,r,rp)
	local tc=rg:GetFirst()
	if tc:IsFieldSpell() then
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if fc then
			Duel.SendtoGrave(fc,REASON_RULE)
			Duel.BreakEffect()
		end
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	else
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end