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
	e5:SetCondition(s.chaincon)
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
--Give control, draw, return
function s.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_WORM) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.chaincon(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.GetMZoneCount(1-tp,g,tp)>0 and Duel.IsExistingMatchingCard(s.chainfilter,tp,LOCATION_MZONE,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	return re:GetHandler()~=e:GetHandler() and (b1 or b2)
end
function s.chainfilter(c)
	return (c:IsRace(RACE_REPTILE) and c:IsSetCard(SET_WORM)) and c:IsControlerCanBeChanged()
end
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.GetMZoneCount(1-tp,g,tp)>0 and Duel.IsExistingMatchingCard(s.chainfilter,tp,LOCATION_MZONE,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	if not (b1 or b2) then return end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,3)},
		{b2,aux.Stringid(id,4)})
	if op==1 then
		--Give control to draw 
		local g=Duel.GetMatchingGroup(s.chainfilter,tp,LOCATION_MZONE,0,nil)
		if #g==0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
		local sg=g:Select(tp,1,1,nil)
		if sg and Duel.GetControl(sg,1-tp) and Duel.IsPlayerCanDraw(tp) then
			Duel.BreakEffect()
			Duel.Draw(tp,#sg,REASON_EFFECT)
		end
	elseif op==2 then
		--Return to hand
		local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if #tc>0 then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end

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