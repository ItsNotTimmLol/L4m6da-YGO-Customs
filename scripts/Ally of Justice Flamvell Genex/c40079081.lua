--W Nebula Terrorspace
--Scripted by WolfSif
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	--e0:SetOperation(s.actop)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Can be activated from the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_SINGLE)
	--e1:SetCondition(s.actcon)
	e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	--e2:SetCondition(s.actcon)
	c:RegisterEffect(e2)
	--[[atkchange
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetCode(EFFECT_SET_BASE_ATTACK)
	e3:SetTarget(s.atkdeftg)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_SET_BASE_DEFENSE)
	e4:SetValue(s.defval)
	c:RegisterEffect(e4)]]
	--Level 6 Reptile Worm monsters can be Summoned without Tributing
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_SUMMON_PROC)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(LOCATION_HAND,0)
	e5:SetCondition(s.ntcon)
	e5:SetTarget(aux.FieldSummonProcTg(s.nttg))
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_SET_PROC)
	e6:SetDescription(aux.Stringid(id,2))
	c:RegisterEffect(e6)
	--Add to hand
	local e7=Effect.CreateEffect(c)
	e7:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DICE)
	e7:SetType(EFFECT_TYPE_QUICK_O)
	e7:SetCode(EVENT_FREE_CHAIN)
	e7:SetRange(LOCATION_SZONE)
	e7:SetDescription(aux.Stringid(id,3))
	e7:SetCountLimit(1)
	e7:SetTarget(s.thtg)
	e7:SetOperation(s.thop)
	c:RegisterEffect(e7)
	--Set or place face-up
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,4))
	e8:SetCategory(CATEGORY_SET)
	e8:SetType(EFFECT_TYPE_QUICK_O)
	e8:SetCode(EVENT_FREE_CHAIN)
	e8:SetRange(LOCATION_SZONE)
	e8:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	e8:SetCondition(s.setcon)
	e8:SetTarget(s.settg)
	e8:SetOperation(s.setop)
	c:RegisterEffect(e8)
	--Normal Summon/Set
	local e9=Effect.CreateEffect(c)
	e9:SetDescription(aux.Stringid(id,6))
	e9:SetCategory(CATEGORY_SUMMON)
	e9:SetType(EFFECT_TYPE_QUICK_O)
	e9:SetCode(EVENT_FREE_CHAIN)
	e9:SetRange(LOCATION_SZONE)
	e9:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	e9:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e9:SetTarget(s.nstg)
	e9:SetOperation(s.nsop)
	c:RegisterEffect(e9)
	--[[Flip face-up
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,5))
	e8:SetCategory(CATEGORY_POSITION)
	e8:SetType(EFFECT_TYPE_QUICK_O)
	e8:SetRange(LOCATION_SZONE)
	e8:SetCode(EVENT_FREE_CHAIN)
	e8:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e8:SetCountLimit(1)
	e8:SetTarget(s.postg)
	e8:SetOperation(s.posop)
	c:RegisterEffect(e8)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_FLIP)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
		ge2:SetOperation(s.checkop)
		Duel.RegisterEffect(ge2,0)
	end)]]--
end
s.roll_dice=true
s.listed_names={88438982}
s.listed_series={SET_WORM}
s.w_nebula_names={18304915,30476000,40079081,53842829,55939812,76108887,90075978}
--Extra activation condition
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	local tp=e:GetHandler():GetControler()
	return Duel.IsTurnPlayer(1-tp)
end
--Activate Field Spell
function s.actfilter(c,tp)
	return c:IsCode(s.w_nebula_names) and c:GetActivateEffect() and c:GetActivateEffect():IsActivatable(tp,true)
		and c:IsType(TYPE_FIELD)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.actfilter,tp,LOCATION_DECK,0,nil,tp)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		if tc:IsType(TYPE_FIELD) then
			Duel.ActivateFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
		end
	end
end
--Dimikles buff
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	eg:GetFirst():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1)
end
function s.atkconfilter(c)
	return c:IsFaceup() and c:IsCode(88438982) and c:GetFlagEffect(id)~=0
end
function s.atkdeftg(e,c)
	return c:GetFlagEffect(id)==0
end
function s.atkval(e,c)
	local ct=Duel.GetMatchingGroupCount(s.atkconfilter,0,LOCATION_MZONE,0,nil)
	if ct<1 then ct=0.5 end
	return c:GetBaseAttack()/(ct*2)
end
function s.defval(e,c)
	local ct=Duel.GetMatchingGroupCount(s.atkconfilter,0,LOCATION_MZONE,0,nil)
	if ct<1 then ct=0.5 end
	return c:GetBaseDefense()/(ct*2)
end
--Tribute bypass
function s.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.nttg(e,c)
	return c:IsLevel(6)
end
--Roll to add
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,2)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function s.thfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsSetCard(SET_WORM)
		and c:IsMonster() and c:HasLevel() and c:IsAbleToHand()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local d1,d2=Duel.TossDice(tp,2)
	local dc=(d1+d2)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_ONFIELD|LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
	local sg=g:SelectWithSumEqual(tp,Card.GetLevel,dc,1,2)
	if #sg>0 then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end

--Normal Summon/Set
function s.nsfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsSetCard(SET_WORM)
		and c:IsMonster()
		and c:IsSummonable(true,nil)
end
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.nsfilter,tp,LOCATION_HAND,0,nil,true,nil)
	local ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)
	if chk==0 then return ft>0 and #g>0 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.nsop(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.GetMatchingGroup(s.nsfilter,tp,LOCATION_HAND,0,nil,true,nil)
	if #g1>0 then
		Duel.BreakEffect()
		Duel.ShuffleHand(tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		sg=g1:Select(tp,1,1,nil):GetFirst()
		Duel.SummonOrSet(tp,sg,true,nil)
	end
end
--Flip
function s.posfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsSetCard(SET_WORM) 
		and c:IsFacedown() and c:IsDefensePos()
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.posfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local tc=Duel.SelectMatchingCard(tp,s.posfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		local pos=Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEUP_DEFENSE)
		Duel.ChangePosition(tc,pos)
	end
end
--Set
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)<=3 or Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>=4
end
function s.setfilter(c,tp)
	return (c:IsSetCard(SET_WORM) or c:IsCode(s.w_nebula_names)) and c:IsSpell() and c:IsSSetable() and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,tp) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,nil,tp)
	if #g==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	local tc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc and not ((tc:IsFieldSpell() or (tc:IsSpell() and tc:IsType(TYPE_CONTINUOUS))) and Duel.SelectEffectYesNo(tp,c,aux.Stringid(id,5))) then
		Duel.SSet(tp,tc)
	else
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if fc and tc:IsFieldSpell() then
			Duel.SendtoGrave(fc,REASON_RULE)
			Duel.BreakEffect()
			Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		elseif not tc:IsFieldSpell() then
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		else
			Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		end
	end
end