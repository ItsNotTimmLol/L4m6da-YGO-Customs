--W Nebula Singularity
local s,id=GetID()
function s.initial_effect(c)
	--Activate from hand
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e1)
	--Negate activation
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCost(s.negcost)
	e2:SetCondition(s.negcon)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
	--Place 1 Worm Counter from GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.cttg)
	e3:SetOperation(s.ctop)
	c:RegisterEffect(e3)
end
s.listed_names={88438982}
s.listed_series={SET_WORM}
s.w_nebula_names={18304915,30476000,40079081,53842829,55939812,76108887,90075978}
--"Worm Dimikles" that was Flip Summoned and is currently on the field
function s.dimiklesfilter(c)
	return c:IsCode(88438982)
end
--Negate
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
		and re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
end
function s.negcostfilter(c,tp)
	return c:IsOriginalCode(88438982) and c:IsControler(tp)
		and c:IsCanChangePosition() 
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsCanRemoveCounter(tp,1,0,0xf,3,REASON_COST)
	local b2=Duel.IsExistingMatchingCard(s.negcostfilter,tp,LOCATION_MZONE,0,1,nil,tp)
	if chk==0 then return b1 or b2 end
	local opt
	if b1 and b2 then
		opt=Duel.SelectOption(tp,2,3)
	elseif b1 then
		opt=0
	else
		opt=1
	end
	if opt==0 then
		Duel.RemoveCounter(tp,1,0,0xf,3,REASON_COST)
	elseif opt==1 then
		return true
	else
		return false
	end
	e:SetLabel(opt)
end
function s.remfilter(c)
	return c:IsFaceup() and c:IsControler(tp)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsCanRemoveCounter(tp,1,0,0xf,3,REASON_COST)
	local b2=Duel.IsExistingMatchingCard(s.negcostfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp)
	if chk==0 then return b1 or b2 end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
end
function s.negotargetfilter(c,tp)
	return c:IsControler(tp)
		and c:IsLocation(LOCATION_MZONE)
		and (c:IsFaceup() or c:IsFacedown())
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local opt=e:GetLabel()
	--Remove 3 Worm Counters
	if opt==0 then
		if Duel.NegateActivation(ev) then
			Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
		end
	--Change monsters you own to Defense Position
	else
		local dim=Duel.GetMatchingGroup(s.negcostfilter,tp,LOCATION_MZONE,0,nil)
		if #dim==0 then return end
		local g=Duel.GetMatchingGroup(s.negotargetfilter,tp,LOCATION_MZONE,0,nil,tp)
		--The selected group must include Worm Dimikles.
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
		local sg=g:Select(tp,1,#g,nil)
		--If the player somehow selected a group without Dimikles,
		--force Dimikles into the group.
		if not sg:IsExists(function(tc)
			return tc:IsOriginalCode(88438982)
		end,1,nil) then
			local dc=dim:GetFirst()
			if dc then
				sg:AddCard(dc)
			end
		end
		if #sg==0 then return end
		local changed=0
		for tc in aux.Next(sg) do
			if tc:IsFaceup() then
				--Choose face-up or face-down Defense Position
				local pos=Duel.SelectOption(tp,
					aux.Stringid(id,4),
					aux.Stringid(id,5))
				if pos==0 then
					if Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)~=0 then
						changed=changed+1
					end
				else
					if Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)~=0 then
						changed=changed+1
					end
				end
			elseif tc:IsFacedown() then
				--Already face-down Defense Position
				changed=changed+1
			end
		end
		if changed>0 then
			if Duel.NegateActivation(ev) then
				Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
			end
		end
	end
end

--Place counter
function s.ctfilter(c)
	return c:IsFaceup()
		and c:IsControler(tp)
		and c:IsCanAddCounter(COUNTER_WORM,1)
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.ctfilter,tp,LOCATION_ONFIELD,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,tp,LOCATION_ONFIELD)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)
	local g=Duel.SelectMatchingCard(tp,s.ctfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		tc:AddCounter(COUNTER_WORM,1)
	end
end
