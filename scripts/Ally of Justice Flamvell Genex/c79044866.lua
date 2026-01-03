--Genex Core
--Scripted by WolfSif
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 'Ally' monster from your hand or GY, and if you do, equip it with this card
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP+CATEGORY_TOGRAVE)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	--e0:SetCost(s.spcost)
	e0:SetTarget(s.sptg)
	e0:SetOperation(s.spop)
	c:RegisterEffect(e0)
	--equipped monster becomes "Genex Controller"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetValue(68505803)
	c:RegisterEffect(e1)
	--[[LIGHT Lock during Main Phase
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_HAND|LOCATION_GRAVE)
	e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e2:SetValue(ATTRIBUTE_LIGHT)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetTargetRange(0,LOCATION_GRAVE)
	e3:SetTarget(s.changegytg)
	c:RegisterEffect(e3)
	--Code check LIGHT
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(id)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,1)
	e3:SetValue(s.attval)
	c:RegisterEffect(e3)]]--
end
s.listed_names={68505803}
s.listed_series={SET_ALLY_OF_JUSTICE,SET_FLAMVELL,SET_GENEX}
function s.spfilter(c,e,tp,lvl)
	return (c:IsCode(s.listed_names) or c:IsSetCard(s.listed_series)) 
		and c:IsType(TYPE_SYNCHRO)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		and c:IsLevelBelow(lvl)
		and not c:IsPublic()
end
function s.spcostfilter1(c,e,tp)
	return (c:IsCode(s.listed_names) or c:IsSetCard(s.listed_series))
		and c:IsMonster()
		and c:IsAbleToGrave()
		--and not c:IsPublic()
end
function s.spcostfilter2(c,e,tp,tc)
	return (c:IsCode(s.listed_names) or c:IsSetCard(s.listed_series))
		and c:IsMonster()
		and not c:IsCode(tc:GetCode())
		and c:IsAbleToGrave()
		--and not c:IsPublic()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=Duel.GetMatchingGroup(s.spcostfilter1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,nil):GetClassCount(Card.GetCode)
	local lvl=math.floor((ct-1)/2)
	if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,lvl) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lvl):GetFirst()
	Duel.SetTargetCard(tc)
	e:SetLabel(2*tc:GetLevel())
	Duel.ConfirmCards(1-tp,tc)
	Duel.ShuffleExtra(tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,lvl,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,tp,0)
end
function s.rthfilter(c,tp)
	return c:IsAbleToHand() and not c:IsCode(id)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lvl=e:GetLabel()
	local tc=Duel.GetFirstTarget()
	local g=Duel.GetMatchingGroup(s.spcostfilter2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,nil,e,tp,tc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	if #g>lvl then 
		local rg=Group.CreateGroup()
		for i = 1,lvl do
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local sg=g:Select(tp,1,1,nil)
			g:Remove(Card.IsCode,nil,sg:GetFirst():GetCode())
			Duel.ConfirmCards(1-tp,sg)
			rg:Merge(sg)
		end
		local td=rg:FilterCount(Card.IsLocation,nil,LOCATION_HAND)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		Duel.SendtoGrave(rg,REASON_EFFECT)
		if tc and #rg>0 and Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP) and Duel.Equip(tp,c,tc) then
			--Equip limit
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetValue(function(e,c) return c==tc end)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			c:RegisterEffect(e1)
		end
		tc:CompleteProcedure() 
		if Duel.IsExistingMatchingCard(s.rthfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,tp)
			and td>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
			local g=Duel.SelectMatchingCard(tp,s.rthfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,td,nil,tp)
			if #g>0 then
				Duel.HintSelection(g)
				Duel.BreakEffect()
				Duel.SendtoHand(g,nil,REASON_EFFECT)
			end
		end
	end
end

--Fix stats
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
