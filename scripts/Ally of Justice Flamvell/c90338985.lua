--Flamvell Kindling
--Scripted by WolfSif
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--[[Add this card to the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCondition(s.sp2con)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.sp2tg)
	e2:SetOperation(s.sp2op)
	c:RegisterEffect(e2)]]--
end
s.listed_names={40155554,59482302}
s.listed_series={SET_ALLY_OF_JUSTICE,SET_FLAMVELL}
--Basically soul charge
function s.sp1filter(c,e,tp)
	return (c:IsCode(59482302) or c:IsSetCard(SET_FLAMVELL)) and c:IsMonster() 
		and ((Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp))
		or (Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)))
end
function s.sp2filter(c,e,tp)
	return (c:IsCode(40155554) or c:IsCode(59482302) or c:IsSetCard(SET_ALLY_OF_JUSTICE) or c:IsSetCard(SET_FLAMVELL))
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
	local ft1=1--Duel.GetLocationCount(1-tp,LOCATION_MZONE)
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
	local ct2=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	local ft2=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft2<ct2 then ct2=ft2 end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ct2=1 end
	local g2=Duel.GetMatchingGroup(s.sp2filter,tp,LOCATION_DECK,0,nil,e,tp)
	local sg2=aux.SelectUnselectGroup(g2,e,tp,1,ct2,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
	tc=sg2:GetFirst()
	for tc in aux.Next(sg2) do
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1,fid)
	end
	Duel.SpecialSummonComplete()
	sg1:Merge(sg2)
	sg1:KeepAlive()
	local e0=Effect.CreateEffect(e:GetHandler())
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_PHASE+PHASE_END)
	e0:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetReset(RESET_PHASE|PHASE_END)
	e0:SetCountLimit(1)
	e0:SetLabel(fid)
	e0:SetLabelObject(sg1)
	e0:SetDescription(aux.Stringid(id,1))
	e0:SetCondition(s.descon)
	e0:SetOperation(s.desop)
	Duel.RegisterEffect(e0,tp)
	--Flag for End Phase
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE|PHASE_END)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_PHASE|PHASE_END)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCondition(s.sp2con)
	e1:SetTarget(s.sp2tg)
	e1:SetOperation(s.sp2op)
	Duel.RegisterEffect(e1,tp)
end
--Special Summon during End Phase
function s.sp3filter(c,e,tp)
	return c:IsSetCard(SET_FLAMVELL) and c:IsMonster() 
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
	if ft>3 then ft=3 end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local sg=Duel.GetMatchingGroup(s.sp3filter,tp,LOCATION_DECK,0,nil,e,tp)
	local g=aux.SelectUnselectGroup(sg,e,tp,1,ft,nil,1,tp,HINTMSG_SPSUMMON)
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
	e0:SetDescription(aux.Stringid(id,1))
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

--[[
function s.thfilter(c)
	return c:IsMonster() and c:IsSetCard(SET_FLAMVELL) and c:IsAbleToHand()
end
function s.spfilter(c,e,tp)
	return c:IsMonster() and c:IsSetCard(SET_FLAMVELL)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0	
		--[[and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,3,1-tp,LOCATION_GRAVE)
end
function s.sumfilter(c)
	return c:IsSetCard(SET_FLAMVELL) and c:IsSummonable(true,nil,1)
end
function s.controlfilter(c)
	return c:IsSetCard(SET_FLAMVELL) and c:IsControlerCanBeChanged() and c:IsFaceup()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	--Add
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g1=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SendtoHand(g1,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,g1)
	--Summon
	local fid=e:GetHandler():GetFieldID()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g2=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	local sg2=g2:Select(tp,1,1,nil)
	local tc=sg2:GetFirst()
	for tc in aux.Next(sg2) do
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1,fid)
	end
	Duel.SpecialSummonComplete()
	--Apply effect
	local g3=Duel.GetMatchingGroup(s.sumfilter,tp,LOCATION_HAND,0,nil)
	local g4=Duel.GetMatchingGroup(s.controlfilter,tp,LOCATION_MZONE,0,nil)
	local g5=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,nil)
	local b1=Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND,0,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.controlfilter,tp,LOCATION_MZONE,0,1,nil)
	local b3=Duel.GetFieldGroupCount(tp,0,LOCATION_GRAVE)>=3
	if not (b1 or b2 or b3) then return end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b3,aux.Stringid(id,3)})
	if op==1 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
		local sc=g3:Select(tp,1,1,nil):GetFirst()
		Duel.ShuffleHand(tp)
		Duel.Summon(tp,sc,true,nil,1)
	elseif op==2 then
		Duel.BreakEffect()
		local sc1=g4:Select(tp,1,99,nil)
		Duel.GetControl(sc1,1-tp)
	elseif op==3 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local sc=g5:Select(tp,3,3,nil)
		Duel.Remove(sc,POS_FACEUP,REASON_EFFECT)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE|PHASE_END)
		e1:SetCountLimit(1)
		e1:SetReset(RESET_PHASE|PHASE_END)
		e1:SetCondition(s.sp2con)
		e1:SetTarget(s.sp2tg)
		e1:SetOperation(s.sp2op)
		Duel.RegisterEffect(e1,tp)
		--Your Flamvell monsters are unaffected by your opponent's card effects
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetDescription(aux.Stringid(id,0))
		e2:SetCode(EFFECT_IMMUNE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e2:SetTargetRange(LOCATION_MZONE,0)
		e2:SetTarget(s.ufilter)
		e2:SetValue(s.efilter)
		e2:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.ufilter(e,c)
	return c:IsFaceup() and c:IsSetCard(SET_FLAMVELL)
end
function s.efilter(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
--Add to hand
function s.cfilter(c,tp)
	return c:GetControler()~=tp and not c:IsPreviousControler(tp) and not c:IsType(TYPE_TOKEN)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end

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
end]]