--W Nebula Wormhole
--Scripted by WolfSif
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	--e0:SetDescription(aux.Stringid(id,0))
	--e0:SetTarget(s.thtg)
	--e0:SetOperation(s.actop)
	c:RegisterEffect(e0)
	--Negate
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_DISABLE)
	e6:SetRange(LOCATION_FZONE)
	e6:SetTargetRange(0,LOCATION_MZONE)
	e6:SetTarget(s.negtg)
	c:RegisterEffect(e6)
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
	local e4=e2:Clone()
	e4:SetCode(EFFECT_MUST_ATTACK)
	e4:SetTargetRange(0,LOCATION_MZONE)
	c:RegisterEffect(e4)
	--Return "Worm Call"
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_CHAIN_SOLVING)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCondition(s.regcon)
	e4:SetOperation(s.regop)
	c:RegisterEffect(e4)
	--Set 1 "Dimensionhole" and/or "Worm Call"
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetCategory(CATEGORY_SET)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_FZONE)
	e6:SetCountLimit(1)
	e6:SetTarget(s.settg)
	e6:SetOperation(s.setop)
	c:RegisterEffect(e6)
	--remove
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_REMOVE)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetRange(LOCATION_FZONE)
	e6:SetCode(EVENT_PHASE+PHASE_END)
	e6:SetCountLimit(1)
	e6:SetTarget(s.rmtg)
	e6:SetOperation(s.rmop)
	c:RegisterEffect(e6)
	--Register "Dimensionhole" activation
	aux.GlobalCheck(s,function()
		local ge6=Effect.CreateEffect(c)
		ge6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge6:SetCode(EVENT_CHAINING)
		ge6:SetOperation(s.checkop)
		Duel.RegisterEffect(ge6,0)
	end)
end
s.listed_names={22959079,28506708}
s.listed_series={SET_WORM}
s.w_nebula_names={18304915,30476000,40079081,53842829,55939812,76108887,90075978}
--Buff Dimensionhole
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for tc in eg:Iter() do
		if tc:IsCode(22959079) then
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,2)
		end
	end
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		 and Duel.HasFlagEffect(tp,id) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,0)
		Debug.Message(2)
end
function s.rmfilter(c)
	return c:IsAbleToRemove()
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,99,nil)
	if #g>0 then
		Duel.HintSelection(g)
		if Duel.Remove(g,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)~=0 then
			g=g:Filter(Card.IsLocation,nil,LOCATION_REMOVED)
			g:KeepAlive()
			local tc=g:GetFirst()
			while tc do
				tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,2)
				--Return it in the End Phase
				local e6=Effect.CreateEffect(e:GetHandler())
				e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e6:SetCode(EVENT_PHASE+PHASE_END)
				e6:SetReset(RESET_PHASE|PHASE_END,2)
				e6:SetLabelObject(tc)
				e6:SetCountLimit(1)
				e6:SetCondition(s.retcon)
				e6:SetOperation(s.retop)
				e6:SetLabel(Duel.GetTurnCount())
				Duel.RegisterEffect(e6,tp)
				tc=g:GetNext()
			end
			e:SetLabelObject(g)
		end
	end
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount()>e:GetLabel() and e:GetLabelObject():GetFlagEffect(id)~=0
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
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
function s.atkcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.atkconfilter,tp,LOCATION_MZONE,0,1,nil)
end

--Bounce "Worm Call"
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	local p,code6,code2=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_CONTROLER,CHAININFO_TRIGGERING_CODE,CHAININFO_TRIGGERING_CODE2)
	return p==tp and (code6==28506708 or code2==28506708) 
		and re:GetHandler():IsCode(28506708)
		and re:GetHandler():IsOnField() and not re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if rc:IsCode(28506708) then
		Duel.SendtoHand(rc,nil,REASON_EFFECT)
	end
end

--Set
function s.setfilter(c)
	return c:IsCode(s.listed_names) and c:IsSpellTrap() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
	if #g==0 then return end
	local ft=math.min(Duel.GetLocationCount(tp,LOCATION_SZONE),2)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,ft,aux.dncheck,1,tp,HINTMSG_SET)
	if #sg>0 then
		Duel.SSet(tp,sg)
	end
end