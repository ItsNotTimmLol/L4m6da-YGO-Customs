--Genex Field
--Scripted by WolfSif
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetTarget(s.acttg)
	e0:SetOperation(s.actop)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e0:SetCost(s.actcost)
	c:RegisterEffect(e0)
	--Can be activated from the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCondition(function(e) return Duel.IsExistingMatchingCard(s.actcostfilter,e:GetHandlerPlayer(),LOCATION_HAND,0,1,nil) end)
	e1:SetValue(function(e,c) e:SetLabel(1) end)
	e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e1)
	e0:SetLabelObject(e1)
	--Monsters whose ATK is different from their original ATK are unaffected by your opponent's activated effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.immtg)
	e2:SetValue(s.immval)
	c:RegisterEffect(e2)
	--Change to LIGHT or face-down
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetCategory(CATEGORY_POSITION)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCountLimit(1)
	e6:SetTarget(s.nstg)
	e6:SetOperation(s.nsop)
	c:RegisterEffect(e6)
end
s.listed_series={SET_ALLY_OF_JUSTICE,SET_FLAMVELL,SET_GENEX}
s.ally_names={40155554,59482302}

--activate from hand
function s.actcostfilter(c)
	return (c:IsCode(s.ally_names) or c:IsSetCard(s.listed_series)) 
		and c:IsMonster() and c:IsDiscardable()
end
function s.actcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.actcostfilter,tp,LOCATION_HAND,0,1,c)
end

--cost
function s.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local label_obj=e:GetLabelObject()
	if chk==0 then label_obj:SetLabel(0) return true end
	if label_obj:GetLabel()>0 then
		label_obj:SetLabel(0)
		Duel.DiscardHand(tp,s.actcostfilter,1,1,REASON_COST|REASON_DISCARD)
	end
end

--place spells
function s.actfilter(c,tp)
	return (c:IsType(TYPE_FIELD) or c:IsType(TYPE_CONTINUOUS))
		and c:IsSetCard(s.listed_series) 
		and c:IsSpell() and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.GetLocationCount(tp,LOCATION_SZONE)>0 or Duel.GetLocationCount(tp,	ZONE)>0)
		and Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,tp) end
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.GetMatchingGroup(s.actfilter,tp,LOCATION_DECK|LOCATION_HAND,0,nil,tp) 
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 and Duel.GetLocationCount(tp,LOCATION_FZONE)<=0 then return end
		local sc=Duel.SelectMatchingCard(tp,s.actfilter,tp,LOCATION_DECK|LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
		local loc=LOCATION_SZONE
		if sc:IsType(TYPE_FIELD) then loc=LOCATION_FZONE end
		if sc then
			Duel.MoveToField(sc,tp,tp,loc,POS_FACEUP,true)
		end
	end
end

--immune
function s.immtg(e,c)
	return (c:IsCode(s.ally_names) or c:IsSetCard(s.listed_series)) and c:IsMonster() and not c:IsAttack(c:GetBaseAttack())
end
function s.immval(e,te)
	return te:GetOwnerPlayer()==1-e:GetHandlerPlayer() and te:IsActivated()
end

--Change Attribute or to facedown
function s.posfilter(c)
	return c:IsFaceup() and (s.pos1filter(c) or s.pos2filter(c))
end
function s.pos1filter(c)
	return c:IsAttributeExcept(ATTRIBUTE_LIGHT)
end
function s.pos2filter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsCanTurnSet()
end
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,LOCATION_MZONE,0,1,nil) or Duel.IsExistingTarget(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectTarget(tp,s.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g1=Duel.GetTargetCards(e):Filter(s.pos1filter,nil)
	local g2=Duel.GetTargetCards(e):Filter(s.pos2filter,nil)
	if #g1>0 then
		local tc1=g1:GetFirst()
		for tc1 in aux.Next(g1) do
			--It becomes LIGHT
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e1:SetValue(ATTRIBUTE_LIGHT)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc1:RegisterEffect(e1)
		end
	elseif #g2>0 then
		local tc2=g2:GetFirst()
		for tc2 in aux.Next(g2) do
			Duel.ChangePosition(tc2,POS_FACEDOWN_DEFENSE)
		end
	end
end

