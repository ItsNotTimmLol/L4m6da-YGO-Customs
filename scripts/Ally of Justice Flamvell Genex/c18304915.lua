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
	--Return "Worm Call"
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_FZONE)
	e4:SetOperation(s.regop)
	c:RegisterEffect(e4)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetCondition(s.thcon)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	--Set 1 "Dimensionhole" and/or "Worm Call"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	
end
s.listed_names={22959079,28506708}
s.listed_series={SET_WORM}
s.w_nebula_names={18304915,30476000,40079081,53842829,55939812,76108887,90075978}

--Bounce "Worm Call"
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if rp~=tp and re:IsCode(28506708) then
		local rc=re:GetHandler()
		rc:RegisterFlagEffect(id+1,RESET_EVENT|RESETS_STANDARD,0,1)
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET)|RESET_CHAIN,0,1)
	end
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ep~=tp and c:GetFlagEffect(id)~=0
end
function s.thfilter(c)
	return c:GetFlagEffect(id+1)==0
end
function s.thop(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND,0,nil)
	local tc=g:GetFirst()
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
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