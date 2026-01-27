--Ally of Justice Field
--Scripted by WolfSif
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	--e0:SetTarget(s.acttg)
	--e0:SetOperation(s.actop)
	--e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
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
	--Add to hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp) end)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	--Change to LIGHT or face-down
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,3))
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
s.ally_series={SET_ALLY_OF_JUSTICE,SET_FLAMVELL,SET_GENEX}
s.ally_names={40155554,59482302}

--activate from hand
function s.actcostfilter(c)
	return c:IsDiscardable() 
		--and (c:IsCode(s.ally_names) or c:IsSetCard(s.ally_series)) 
		--and c:IsMonster() 
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
		and c:IsSetCard(s.ally_series) 
		and c:IsSpell() and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.GetLocationCount(tp,LOCATION_SZONE)>0 or Duel.GetLocationCount(tp,LOCATION_FZONE)>0)
		and Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,tp) end
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.GetMatchingGroup(s.actfilter,tp,LOCATION_HAND|LOCATION_DECK,0,nil,tp) 
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 and Duel.GetLocationCount(tp,LOCATION_FZONE)<=0 then return end
		local sc=Duel.SelectMatchingCard(tp,s.actfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,tp):GetFirst()
		local loc=LOCATION_SZONE
		if sc:IsType(TYPE_FIELD) then loc=LOCATION_FZONE end
		if sc then
			Duel.MoveToField(sc,tp,tp,loc,POS_FACEUP,true)
		end
	end
end

--immune
function s.immtg(e,c)
	return (c:IsCode(s.ally_names) or c:IsSetCard(s.ally_series)) 
		and c:IsMonster() 
		and (not c:IsAttack(c:GetBaseAttack()) 
		or c:IsAttributeExcept(c:GetOriginalAttribute())
		or c:IsCode(c:GetOriginalCode()))
end
function s.immval(e,te)
	return te:GetOwnerPlayer()==1-e:GetHandlerPlayer() and te:IsActivated()
end

--Add on opp monster
function s.thfilter(c)
	return (c:IsSetCard(s.listed_series) or c:IsCode(s.ally_names))
		and c:IsAbleToHand()
		and not c:IsCode(id)
		and c:IsMonster()
		--and not Duel.IsExistingMatchingCard(s.uniquefilter,tp,LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,c:GetCode())
end
function s.uniquefilter(c,code)
	return c:IsCode(code) and c:IsFaceup() and c:IsMonster()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.nsfilter(c)
	return (c:IsSetCard(s.listed_series) or c:IsCode(s.ally_names))
		and c:IsSummonable(true,nil)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,tc)
		Duel.ShuffleHand(tp)
		--Normal Summon
		--[[if Duel.IsExistingMatchingCard(s.nsfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
			local sc=Duel.SelectMatchingCard(tp,s.nsfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil):GetFirst()
			if sc then
				Duel.BreakEffect()
				Duel.SummonOrSet(tp,sc,true,nil)
			end
		end]]--
	end
end


--Change Attribute or to facedown
function s.posfilter(c)
	return c:IsFaceup() and (s.pos1filter(c) or s.pos2filter(c))
end
function s.pos1filter(c)
	return not c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.pos2filter(c)
	return (c:IsAttribute(ATTRIBUTE_LIGHT) or c:GetAttribute()==ATTRIBUTE_LIGHT) and c:IsCanTurnSet()
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
			e1:SetCode(EFFECT_ADD_ATTRIBUTE)
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

