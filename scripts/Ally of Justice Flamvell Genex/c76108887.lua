--W Nebula Singularity
local s,id=GetID()
function s.initial_effect(c)
	--Activate from hand
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e1:SetCondition(s.handcon)
	c:RegisterEffect(e1)
	--Negate activation
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_CHAINING)
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
	return c:IsFaceup()
		and c:IsCode(88438982)
		and c:IsSummonType(SUMMON_TYPE_FLIP)
end
--Can activate this card from the hand
function s.handcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.dimiklesfilter,tp,LOCATION_MZONE,0,1,nil)
end
--Negate
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
		and re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP)
end
function s.countercostfilter(c)
	return c:IsFaceup() and c:GetCounter(COUNTER_WORM)>0
end
function s.remfilter(c)
	return c:IsFaceup() and c:IsControler(tp)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local can_counter=false
	local can_position=false
	--Effect 1: Remove 3 Worm Counters
	local total=0
	local g=Duel.GetMatchingGroup(s.countercostfilter,tp,LOCATION_ONFIELD,0,nil)
	for tc in aux.Next(g) do
		total=total+tc:GetCounter(COUNTER_WORM)
	end
	can_counter=(total>=3)
	--Effect 2: Change monsters you own, including Worm Dimikles
	local dim=Duel.IsExistingMatchingCard(function(tc)
			return tc:IsCode(88438982)
				and tc:IsControler(tp)
				and tc:IsLocation(LOCATION_MZONE)
				and (tc:IsFaceup() or tc:IsFacedown())
		end,tp,LOCATION_MZONE,0,1,nil)
	can_position=dim
	if chk==0 then
		return can_counter or can_position
	end
	local opt
	if can_counter and can_position then
		opt=Duel.SelectOption(tp,
			aux.Stringid(id,2),
			aux.Stringid(id,3))
	elseif can_counter then
		opt=0
	else
		opt=1
	end
	e:SetLabel(opt)
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
		local ct=3
		local g=Duel.GetMatchingGroup(s.countercostfilter,tp,LOCATION_ONFIELD,0,nil)
		while ct>0 and #g>0 do
			local tc
			if ct==1 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)
				tc=g:Select(tp,1,1,nil):GetFirst()
			else
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)
				tc=g:Select(tp,1,1,nil):GetFirst()
			end
			if not tc then return end
			local remove=math.min(tc:GetCounter(COUNTER_WORM),ct)
			tc:RemoveCounter(tp,COUNTER_WORM,remove,REASON_EFFECT)
			ct=ct-remove
			g=Duel.GetMatchingGroup(s.countercostfilter,tp,LOCATION_ONFIELD,0,nil)
		end
		if ct>0 then return end
		if Duel.NegateActivation(ev) then
			Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
		end
	--Change monsters you own to Defense Position
	else
		local dim=Duel.GetMatchingGroup(function(tc)
				return tc:IsCode(88438982)
					and tc:IsControler(tp)
					and tc:IsLocation(LOCATION_MZONE)
			end,tp,LOCATION_MZONE,0,nil)
		if #dim==0 then return end
		local g=Duel.GetMatchingGroup(s.negotargetfilter,tp,LOCATION_MZONE,0,nil,tp)
		--The selected group must include Worm Dimikles.
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
		local sg=g:Select(tp,1,#g,nil)
		--If the player somehow selected a group without Dimikles,
		--force Dimikles into the group.
		if not sg:IsExists(function(tc)
			return tc:IsCode(88438982)
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
