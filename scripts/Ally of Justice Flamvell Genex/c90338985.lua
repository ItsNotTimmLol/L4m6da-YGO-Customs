--Genex Spark
--Scripted by WolfSif
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_ALLY_OF_JUSTICE,SET_FLAMVELL,SET_GENEX}
s.ally_names={40155554,59482302}
--Basically soul charge
function s.sp1filter(c,e,tp)
	return (c:IsCode(s.ally_names) or c:IsSetCard(s.listed_series)) 
		and ((Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp))
			or (Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)))
		and c:IsMonster()
end
function s.sp2filter(c,e,tp)
	return (c:IsCode(s.ally_names) or c:IsSetCard(s.listed_series)) 
		and ((Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp))
			or (Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)))
		and not Duel.IsExistingMatchingCard(s.uniquefilter,tp,LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,c:GetCode())
		and c:IsMonster() 
end
function s.uniquefilter(c,code)
	return c:IsCode(code) and c:IsFaceup() and c:IsMonster()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g1=Duel.GetMatchingGroup(s.sp1filter,tp,LOCATION_DECK,0,nil,e,tp)
	local g2=Duel.GetMatchingGroup(s.sp2filter,tp,LOCATION_DECK,0,nil,e,tp)
	g1:Merge(g2)
	if chk==0 then return #g1>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_ALL,LOCATION_DECK)
end
function s.rescon1(sg,e,tp,mg)
	return sg:FilterCount(Card.IsSetCard,nil,SET_FLAMVELL)<=1 and sg:FilterCount(Card.IsCode,nil,40155554)<=1 and sg:FilterCount(Card.IsCode,nil,59482302)<=1
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local fid=e:GetHandler():GetFieldID()
	local g1=Duel.GetMatchingGroup(s.sp1filter,tp,LOCATION_DECK,0,nil,e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local ft1=1
	local sg1=aux.SelectUnselectGroup(g1,e,tp,1,ft1,s.rescon1,1,tp,HINTMSG_SPSUMMON)
	local tc=sg1:GetFirst()
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft1=1 end
	if ft1>0 then
		for tc in aux.Next(sg1) do
			Duel.SpecialSummonStep(tc,0,tp,1-tp,false,false,POS_FACEUP)
			tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1,fid)
		end
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
	local ct2=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	local ft2=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft2<ct2 then ct2=ft2 end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ct2=1 end
	local g2=Duel.GetMatchingGroup(s.sp2filter,tp,LOCATION_DECK,0,nil,e,tp)
	if Duel.GetFlagEffect(tp,id)==0 and #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2))then
		local sg2=aux.SelectUnselectGroup(g2,e,tp,0,ct2,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
	tc=sg2:GetFirst()
		for tc in aux.Next(sg2) do
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1,fid)Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
			sg1:Merge(sg2)
		end
		Duel.SpecialSummonComplete()
	end
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
	Duel.RegisterEffect(e2,tp)
end
--Special Summon during End Phase
function s.sp3filter(c,e,tp)
	return (c:IsCode(s.ally_names) or c:IsSetCard(s.listed_series)) and c:IsMonster() 
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
	local fid=e:GetHandler():GetFieldID()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	--if ft>3 then ft=3 end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local sg=Duel.GetMatchingGroup(s.sp3filter,tp,LOCATION_DECK,0,nil,e,tp)
	local g=aux.SelectUnselectGroup(sg,e,tp,1,1,nil,1,tp,HINTMSG_SPSUMMON)
	if #g>0 then
		local tc=g:GetFirst()
		for tc in aux.Next(g) do
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1,fid)
		end
	end
	Duel.SpecialSummonComplete()
	Duel.BreakEffect()
	--Destroy during End Phase
	g:KeepAlive()
	local e0=Effect.CreateEffect(e:GetHandler())
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_PHASE+PHASE_END)
	e0:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetReset(RESET_PHASE|PHASE_END)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCountLimit(1)
	e0:SetLabel(fid)
	e0:SetLabelObject(g)
	e0:SetCondition(s.descon)
	e0:SetOperation(s.desop)
	Duel.RegisterEffect(e0,tp)
end
--Destroy during End Phase
function s.desfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
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
	local g=e:GetLabelObject()
	local tg=g:Filter(s.desfilter,nil,e:GetLabel())
	g:DeleteGroup()
	Duel.Destroy(tg,REASON_EFFECT)
end
