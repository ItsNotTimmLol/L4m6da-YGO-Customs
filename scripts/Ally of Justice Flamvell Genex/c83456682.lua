--Ally of Justice Assimilation
--Scripted by WolfSif
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetTarget(s.thtg)
	e0:SetOperation(s.actop)
	c:RegisterEffect(e0)
	--[[Add to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp) end)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)]]--
	--LIGHT during Battle Phase and board
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_GRAVE,LOCATION_HAND|LOCATION_ONFIELD|LOCATION_GRAVE)
	e3:SetCondition(s.lightcon)
	e3:SetCode(EFFECT_ADD_ATTRIBUTE)
	e3:SetValue(ATTRIBUTE_LIGHT)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetTargetRange(LOCATION_GRAVE,LOCATION_GRAVE)
	e4:SetTarget(s.changegytg)
	c:RegisterEffect(e4)
	--Code check LIGHT
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(id)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(0,1)
	e5:SetValue(s.attval)
	c:RegisterEffect(e5)
	--extra Tribute material
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e6:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
	e6:SetRange(LOCATION_FZONE)
	e6:SetTargetRange(0,LOCATION_MZONE)
	e6:SetTarget(s.tributetarget)
	e6:SetValue(POS_FACEUP)
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e7:SetRange(LOCATION_FZONE)
	e7:SetTargetRange(LOCATION_HAND,0)
	e7:SetTarget(function(e,c) return c:IsMonster() and (c:IsCode(s.ally_names) or c:IsSetCard(SET_ALLY_OF_JUSTICE) or c:IsSetCard(SET_GENEX_ALLY)) end)
	e7:SetLabelObject(e6)
	c:RegisterEffect(e7)
	--Recycle banished
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,2))
	e8:SetCategory(CATEGORY_TODECK)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e8:SetRange(LOCATION_FZONE)
	e8:SetCode(EVENT_ATTACK_ANNOUNCE)
	e8:SetTarget(s.dttg)
	e8:SetOperation(s.dtop)
	c:RegisterEffect(e8)
end
s.listed_series={SET_ALLY_OF_JUSTICE,SET_FLAMVELL,SET_GENEX}
s.ally_series={SET_ALLY_OF_JUSTICE,SET_GENEX_ALLY}
s.ally_names={40155554,59482302}
--Fix stats
function s.confilter(c)
	return (c:IsCode(s.ally_names) or c:IsSetCard(s.listed_series)) 
		and c:IsMonster() 
		and c:IsFaceup()
end
function s.allymachinefilter(c)
	return (c:IsCode(s.ally_names) or c:IsSetCard(s.ally_series)) 
		and c:IsRace(RACE_MACHINE)
		and c:IsMonster() 
		and c:IsFaceup()
end
function s.lightcon(e) 
	--local g=Duel.GetMatchingGroup(s.confilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil) 
	return Duel.IsBattlePhase() or Duel.IsExistingMatchingCard(s.allymachinefilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,5,nil,tp) --or g:GetSum(Card.GetLevel)>20 
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
function s.raceval(e,c,re,chk)
	if chk==0 then return true end
	return RACE_PYRO
end
function s.attval(e,c,re,chk)
	if chk==0 then return true end
	return ATTRIBUTE_LIGHT
end

--Tribute targets
function s.tributetarget(e,c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) or not c:IsFaceup()
end

--Add on opp monster
function s.thfilter(c,e,tp)
	return (c:IsSetCard(s.listed_series))
		and c:IsAbleToHand()
		--and not (c:IsType(TYPE_FIELD) and c:IsType(TYPE_SPELL))
		and not c:IsCode(id)
		--and c:IsMonster()
		--and not Duel.IsExistingMatchingCard(s.uniquefilter,tp,LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,c:GetCode())
end
function s.uniquefilter(c,code)
	return c:IsCode(code) and c:IsFaceup() and c:IsMonster()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true --Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.nsfilter(c)
	return (c:IsSetCard(s.listed_series) or c:IsCode(s.ally_names))
		and c:IsSummonable(true,nil)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	if not (Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,1))) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,tc)
		Duel.ShuffleHand(tp)
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
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,tc)
		Duel.ShuffleHand(tp)
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

--Recycle
function s.dtfilter(c)
	return c:IsSetCard(s.listed_series) and c:IsAbleToDeck()
end
function s.dttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.dtfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.dtop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local tc=Duel.SelectMatchingCard(tp,s.dtfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil):GetFirst()
	if tc then
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
		if not tc:IsLocation(LOCATION_EXTRA) then
			Duel.ConfirmDecktop(tp,1)
		end
	end
end