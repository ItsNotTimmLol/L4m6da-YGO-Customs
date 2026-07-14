--W Nebula Terrorspace
--Scripted by WolfSif
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Can be activated from the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	c:RegisterEffect(e2)
	--atkchange
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
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_SUMMON)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	e5:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e5:SetTarget(s.nstg)
	e5:SetOperation(s.nsop)
	c:RegisterEffect(e5)
	--Flip face-up
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,3))
	e6:SetCategory(CATEGORY_POSITION)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetHintTiming(0,TIMINGS_CHECK_MONSTER|TIMING_MAIN_END)
	e6:SetCountLimit(1)
	e6:SetTarget(s.postg)
	e6:SetOperation(s.posop)
	c:RegisterEffect(e6)
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
	end)
end
s.listed_names={88438982}
s.listed_series={SET_ALLY_OF_JUSTICE,SET_WORM}
s.ally_series={SET_ALLY_OF_JUSTICE}
s.ally_names={40155554,59482302}
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
	Debug.Message(ct)
	if ct<1 then ct=0.5 end
	Debug.Message(ct)
	return c:GetBaseAttack()/(ct*2)
end
function s.defval(e,c)
	local ct=Duel.GetMatchingGroupCount(s.atkconfilter,0,LOCATION_MZONE,0,nil)
	if ct<1 then ct=0.5 end
	return c:GetBaseDefense()/(ct*2)
end

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
		Duel.MSet(tp,sg,true,nil)
	end
end

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