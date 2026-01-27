--Genex Spark
--Scripted by WolfSif
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	--e1:SetTarget(s.sptg)
	--e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_FLAMVELL,SET_GENEX}
s.aoj_series={SET_ALLY_OF_JUSTICE,SET_FLAMVELL,SET_GENEX}
s.ally_names={40155554,59482302}
function s.nsfilter(c)
	return (c:IsSetCard(s.aoj_series) or c:IsCode(s.ally_names))
		and c:IsMonster()
		and c:IsSummonable(true,nil)
end
function s.scfilter(c)
	return (c:IsSetCard(s.aoj_series) or c:IsCode(s.ally_names)) 
		and c:IsSynchroSummonable(nil)
end
function s.lfilter(c)
	return (c:IsSetCard(s.aoj_series) or c:IsCode(s.ally_names))
		and c:IsLinkSummonable(nil)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.GetMatchingGroup(s.sp1filter,tp,LOCATION_DECK,0,nil,e,tp)
	local g2=Duel.GetMatchingGroup(s.sp2filter,tp,LOCATION_DECK,0,nil,e,tp)
	local g3=Duel.GetMatchingGroup(s.nsfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,nil,e,tp)
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<ct then ct=ft end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ct=1 end
	local b1=#g1>0
	local b2=(ct>0 and #g2>0 and Duel.GetFlagEffect(tp,id)==0)
	local b3=#g3>0
	local b4=(Duel.IsExistingMatchingCard(s.scfilter,tp,LOCATION_EXTRA,0,1,nil) or Duel.IsExistingMatchingCard(s.lfilter,tp,LOCATION_EXTRA,0,1,nil))
	if chk==0 then return b1 or b2 or (b1 and b2) or b3 or b4 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.nontunerfilter(c)
	return (c:IsSetCard(s.aoj_series) or c:IsCode(s.ally_names))
		and c:IsMonster()
		and not c:IsType(TYPE_TUNER)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(s.sp1filter,tp,LOCATION_DECK,0,nil,e,tp)
	local g2=Duel.GetMatchingGroup(s.sp2filter,tp,LOCATION_DECK,0,nil,e,tp)
	local g3=Duel.GetMatchingGroup(s.nsfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,nil,e,tp)
	local ct1=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	local b1=#g1>0
	local b2=(ct1>0 and #g2>0 and Duel.GetFlagEffect(tp,id)==0)
	local b3=#g3>0
	local b4=(Duel.IsExistingMatchingCard(s.scfilter,tp,LOCATION_EXTRA,0,1,nil) or Duel.IsExistingMatchingCard(s.lfilter,tp,LOCATION_EXTRA,0,1,nil))
	if not (b1 or b2 or (b1 and b2) or (b2 and b3) or b3 or b4) then return end
	local breakeffect=false
	if b1 and (not (b2 or b3 or b4) or Duel.SelectYesNo(tp,aux.Stringid(id,1))) then
		local sg1=aux.SelectUnselectGroup(g1,e,tp,1,1,nil,1,tp,HINTMSG_SPSUMMON)
		local tc1=sg1:GetFirst()
		if tc1 then
			for tc1 in aux.Next(sg1) do
				Duel.SpecialSummonStep(tc1,0,tp,1-tp,false,false,POS_FACEUP)
				--tc1:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,5))
			end
		end
		Duel.SpecialSummonComplete()
		breakeffect=true
	end
	local ct2=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	b2=(ct2>0 and #g2>0 and Duel.GetFlagEffect(tp,id)==0)
	if b2 and (not (b3 or b4) or Duel.SelectYesNo(tp,aux.Stringid(id,2)) or not breakeffect) then
		g2=Duel.GetMatchingGroup(s.sp2filter,tp,LOCATION_DECK,0,nil,e,tp)
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft<ct2 then ct2=ft end
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ct2=1 end
		if breakeffect then Duel.BreakEffect() end
		local sg2=aux.SelectUnselectGroup(g2,e,tp,0,ct2,nil,1,tp,HINTMSG_SPSUMMON)
		local tc2=sg2:GetFirst()
		for tc2 in aux.Next(sg2) do
			Duel.SpecialSummonStep(tc2,0,tp,tp,false,false,POS_FACEUP)
			--tc2:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,5))
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
			--sg1:Merge(sg2)
		end
		Duel.SpecialSummonComplete()
		--Special Summon during End Phase
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE|PHASE_END)
		e1:SetReset(RESET_PHASE|PHASE_END)
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetCountLimit(1)
		e1:SetCondition(s.sp2con)
		e1:SetTarget(s.sp2tg)
		e1:SetOperation(s.sp2op)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetDescription(aux.Stringid(id,6))
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e2:SetTargetRange(1,0)
		e2:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e2,tp)
		breakeffect=true
	end
	g3=Duel.GetMatchingGroup(s.nsfilter,tp,LOCATION_HAND,0,nil,e,tp)
	b3=#g3>0
	local summon=false
	if b3 and (Duel.SelectYesNo(tp,aux.Stringid(id,3)) or not breakeffect) then
		g3=Duel.GetMatchingGroup(s.nsfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,nil,e,tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
		if breakeffect then Duel.BreakEffect() end
		local tc3=Duel.SelectMatchingCard(tp,s.nsfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil):GetFirst()
		if tc3 then
			Duel.SummonOrSet(tp,tc3,true,nil)
			breakeffect=true
			summon=true
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e3:SetCode(EVENT_SUMMON_SUCCESS)
			e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
			e3:SetCountLimit(1)
			e3:SetOperation(s.g4chain)
			Duel.RegisterEffect(e3,tp)
		end
	end
	g4=(Duel.IsExistingMatchingCard(s.scfilter,tp,LOCATION_EXTRA,0,1,nil) or Duel.IsExistingMatchingCard(s.lfilter,tp,LOCATION_EXTRA,0,1,nil))
	b4=g4
	if b4 and not summon and (Duel.SelectYesNo(tp,aux.Stringid(id,4)) or not breakeffect) then
		local sg=Duel.GetMatchingGroup(s.scfilter,tp,LOCATION_EXTRA,0,nil)
		local sg2=Duel.GetMatchingGroup(s.lfilter,tp,LOCATION_EXTRA,0,nil)
		sg:Merge(sg2)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=sg:Select(tp,1,1,nil):GetFirst()
		if not sc then return end
		if sc:IsType(TYPE_SYNCHRO) then
			Duel.SynchroSummon(tp,sc)
		elseif sc:IsType(TYPE_LINK) then
			Duel.LinkSummon(tp,sc)
		end
	end
	--[[
	local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetReset(RESET_PHASE|PHASE_END)
	e4:SetDescription(aux.Stringid(id,8))
	e4:SetCountLimit(1)
	--e4:SetLabel(fid)
	--e4:SetLabelObject(g)
	--e4:SetCondition(s.descon)
	e4:SetOperation(s.desop)
	Duel.RegisterEffect(e4,tp)]]--
end
function s.g4chain(e,tp,eg,ep,ev,re,r,rp)
	local b4=(Duel.IsExistingMatchingCard(s.scfilter,tp,LOCATION_EXTRA,0,1,nil) or Duel.IsExistingMatchingCard(s.lfilter,tp,LOCATION_EXTRA,0,1,nil))
	if not (b4 and Duel.SelectYesNo(tp,aux.Stringid(id,4))) then return end
	Duel.BreakEffect()
	local sg=Duel.GetMatchingGroup(s.scfilter,tp,LOCATION_EXTRA,0,nil)
	local sg2=Duel.GetMatchingGroup(s.lfilter,tp,LOCATION_EXTRA,0,nil)
	sg:Merge(sg2)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=sg:Select(tp,1,1,nil):GetFirst()
	if not sc then return end
	if sc:IsType(TYPE_SYNCHRO) then
		Duel.SynchroSummon(tp,sc)
	elseif sc:IsType(TYPE_LINK) then
		Duel.LinkSummon(tp,sc)
	end
end

--[[
make tuners
	local g3=Duel.GetMatchingGroup(s.nontunerfilter,tp,LOCATION_MZONE,0,nil,e,tp)
	b3=#g3>0
	if b3 and (not b4 or Duel.SelectYesNo(tp,aux.Stringid(id,3)) or not breakeffect) then
		local tc3=g3:GetFirst()
		for tc3 in aux.Next(g3) do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_ADD_TYPE)
			e1:SetValue(TYPE_TUNER)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc3:RegisterEffect(e1)
			tc3:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,7))
		end
		breakeffect=true
	end
	]]--



--Basically soul charge
--To opp
function s.sp1filter(c,e,tp)
	return (c:IsCode(s.ally_names) or c:IsSetCard(s.aoj_series)) 
		--and ((Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp))
			and (Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp))--)
		and c:IsMonster()
end
--To tp
function s.sp2filter(c,e,tp)
	return (c:IsCode(s.ally_names) or c:IsSetCard(s.aoj_series)) 
		and ((Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp)))
			--or (Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)))
		--and not Duel.IsExistingMatchingCard(s.uniquefilter,tp,LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,c:GetCode())
		and c:IsMonster() 
end
function s.uniquefilter(c,code)
	return c:IsCode(code) and c:IsFaceup() and c:IsMonster()
end
--[[ s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g1=Duel.GetMatchingGroup(s.sp1filter,tp,LOCATION_HAND,0,nil,e,tp)
	local g2=Duel.GetMatchingGroup(s.sp2filter,tp,LOCATION_DECK,0,nil,e,tp)
	if chk==0 then return #g1>0 or (Duel.GetFlagEffect(tp,id)==0 and #g2>0) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_ALL,LOCATION_DECK)
end
function s.rescon1(sg,e,tp,mg)
	return sg:FilterCount(Card.IsSetCard,nil,SET_FLAMVELL)<=1 and sg:FilterCount(Card.IsCode,nil,40155554)<=1 and sg:FilterCount(Card.IsCode,nil,59482302)<=1
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local fid=e:GetHandler():GetFieldID()
	local g1=Duel.GetMatchingGroup(s.sp1filter,tp,LOCATION_HAND,0,nil,e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local ft1=1
	local sg1=aux.SelectUnselectGroup(g1,e,tp,1,ft1,nil,1,tp,HINTMSG_SPSUMMON)
	local tc=sg1:GetFirst()
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft1=1 end
	if ft1>0 then
		for tc in aux.Next(sg1) do
			Duel.SpecialSummonStep(tc,0,tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)
			tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
		end
	end
	Duel.SpecialSummonComplete()
	local ct2=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	local ft2=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft2<ct2 then ct2=ft2 end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ct2=1 end
	local g2=Duel.GetMatchingGroup(s.sp2filter,tp,LOCATION_DECK,0,nil,e,tp)
	if Duel.GetFlagEffect(tp,id)==0 and #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		local sg2=aux.SelectUnselectGroup(g2,e,tp,0,ct2,nil,1,tp,HINTMSG_SPSUMMON)
	tc=sg2:GetFirst()
		for tc in aux.Next(sg2) do
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
			sg1:Merge(sg2)
		end
		Duel.SpecialSummonComplete()
		--Special Summon during End Phase
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE|PHASE_END)
		e1:SetReset(RESET_PHASE|PHASE_END)
		e1:SetDescription(aux.Stringid(id,0))
		e1:SetCountLimit(1)
		e1:SetCondition(s.sp2con)
		e1:SetTarget(s.sp2tg)
		e1:SetOperation(s.sp2op)
		Duel.RegisterEffect(e1,tp)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,4))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
	--[[
	sg1:KeepAlive()
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetReset(RESET_PHASE|PHASE_END)
	e2:SetCountLimit(1)
	e2:SetLabel(fid)
	e2:SetLabelObject(sg1)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCondition(s.descon)
	e2:SetOperation(s.desop)
	Duel.RegisterEffect(e2,tp)]]--
--end

--Special Summon during End Phase
function s.sp3filter(c,e,tp)
	return (c:IsCode(s.ally_names) or c:IsSetCard(s.aoj_series)) and c:IsMonster() 
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp)
end
function s.sp2con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount()~=e:GetLabel()
end
function s.sp2tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sp3filter,tp,LOCATION_DECK,0,1,nil,e,tp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.sp2op(e,tp,eg,ep,ev,re,r,rp)
	--local fid=e:GetHandler():GetFieldID()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>3 then ft=3 end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local sg=Duel.GetMatchingGroup(s.sp3filter,tp,LOCATION_DECK,0,nil,e,tp)
	local g=aux.SelectUnselectGroup(sg,e,tp,1,ft,nil,1,tp,HINTMSG_SPSUMMON)
	if #g>0 and ft>0 then
		local tc=g:GetFirst()
		for tc in aux.Next(g) do
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			--tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1,fid)
			tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,5))
		end
	end
	Duel.SpecialSummonComplete()
	--Destroy during End Phase
	--g:KeepAlive()
	local e0=Effect.CreateEffect(e:GetHandler())
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_PHASE+PHASE_END)
	e0:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetReset(RESET_PHASE|PHASE_END)
	e0:SetDescription(aux.Stringid(id,6))
	e0:SetCountLimit(1)
	--e0:SetLabel(fid)
	--e0:SetLabelObject(g)
	--e0:SetCondition(s.descon)
	e0:SetOperation(s.desop)
	Duel.RegisterEffect(e0,tp)
end
--Destroy during End Phase
function s.desfilter(c)
	return c:HasFlagEffect(id)--c:GetFlagEffectLabel(id)==fid
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(s.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	--local g=e:GetLabelObject()
	--local tg=g:Filter(s.desfilter,nil,e:GetLabel())
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	--g:DeleteGroup()
	Duel.Destroy(g,REASON_EFFECT)
end
