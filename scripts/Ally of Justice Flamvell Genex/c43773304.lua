--Ally of Justice Worm 00
--Scripted by WolfSif
local s,id=GetID()
function s.initial_effect(c)
	--flip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SET)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	--Special Summon this card from your hand or GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	e2:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--switch atk/def
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,4))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_CHANGE_POS)
	e3:SetCondition(s.adcon)
	e3:SetTarget(s.adtg)
	e3:SetOperation(s.adop)
	c:RegisterEffect(e3)
	--LIGHT during Battle Phase and board
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_GRAVE,LOCATION_ONFIELD|LOCATION_GRAVE)
	e4:SetCondition(s.lightcon1)
	e4:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e4:SetValue(ATTRIBUTE_LIGHT)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCondition(s.lightcon2)
	e5:SetTargetRange(LOCATION_ONFIELD|LOCATION_GRAVE,LOCATION_GRAVE)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetTargetRange(LOCATION_GRAVE,LOCATION_GRAVE)
	e6:SetTarget(s.changegytg)
	c:RegisterEffect(e6)
	--Code check LIGHT
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e7:SetCode(id)
	e7:SetRange(LOCATION_SZONE)
	e7:SetTargetRange(0,1)
	e7:SetValue(s.attval)
	c:RegisterEffect(e7)
end
s.listed_series={SET_ALLY_OF_JUSTICE,SET_FLAMVELL}
s.ally_series={SET_ALLY_OF_JUSTICE,SET_GENEX_ALLY}
s.ally_names={40155554,59482302}
--forced Set
function s.setfilter(c)
	return c:IsSSetable() or c:IsMSetable(true,nil)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_HAND,0,1,nil) or Duel.IsExistingMatchingCard(s.setfilter,1-tp,LOCATION_HAND,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	local g2=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
	local sc1=g1:FilterSelect(tp,s.setfilter,1,1,nil):GetFirst()
	if sc1:IsMSetable(true,nil) then
		Duel.MSet(tp,sc1,true,nil)
	elseif sc1:IsSSetable(true,nil) then
		Duel.SSet(tp,sc1)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_EXC_GRAVE|RESET_PHASE|PHASE_END)
		sc1:RegisterEffect(e1)
	end
	local sc2=g2:FilterSelect(1-tp,s.setfilter,1,1,nil):GetFirst()
	if sc2:IsMSetable(true,nil) then
		Duel.MSet(1-tp,sc2,true,nil)
	elseif sc2:IsSSetable(true,nil) then
		Duel.SSet(1-tp,sc2)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_TRIGGER)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD_EXC_GRAVE|RESET_PHASE|PHASE_END)
		sc2:RegisterEffect(e2)
	end
end

--Special Summon
function s.thfilter(c,tp)
	return (c:IsRace(RACE_MACHINE) and (c:IsCode(s.ally_names) or c:IsSetCard(s.ally_series)))
	and c:IsMonster() and c:IsAbleToHand()
	and not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,nil,c:GetCode()),tp,LOCATION_ONFIELD|LOCATION_GRAVE,LOCATION_ONFIELD,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE))
		or (Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP+POS_FACEDOWN_DEFENSE,1-tp))
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
	local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP+POS_FACEDOWN_DEFENSE,1-tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	if not (b1 or b2) then return end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	local target_player=op==1 and tp or 1-tp
	local target_pos=POS_FACEDOWN_DEFENSE
	if target_player==1-tp then target_pos=target_pos+POS_FACEUP end
	Duel.SpecialSummon(c,0,tp,target_player,false,false,target_pos)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if #g>0 then
		Duel.BreakEffect()
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--swap stats
function s.adcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP)
end

function s.adtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.adop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SWAP_BASE_AD)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end

--LIGHT stats
function s.lightcon1(e,tp,eg,ep,ev,re,r,rp) 
	return Duel.IsBattlePhase() and e:GetHandler():GetControler()==e:GetHandler():GetOwner()
end
function s.lightcon2(e,tp,eg,ep,ev,re,r,rp) 
	return Duel.IsBattlePhase() and e:GetHandler():GetControler()~=e:GetHandler():GetOwner()
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
	return c:IsMonster()
end
function s.attval(e,c,re,chk)
	if chk==0 then return true end
	return ATTRIBUTE_LIGHT
end
