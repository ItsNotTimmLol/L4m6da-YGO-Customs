--Ally of Justice Release Reverse
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
	e1:SetCondition(function(e) return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)==0 and Duel.IsBattlePhase() end)
	e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e1)
	--extra Tribute material
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(0,LOCATION_MZONE)
	e5:SetValue(POS_FACEUP|POS_FACEDOWN)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_HAND,0)
	e3:SetTarget(function(e,c) return c:IsMonster() and c:IsAttribute(ATTRIBUTE_DARK) and (c:IsCode(s.ally_names) or c:IsSetCard(SET_ALLY_OF_JUSTICE) or c:IsSetCard(SET_GENEX_ALLY)) end)
	e3:SetLabelObject(e5)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SUMMON_COST)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
	e4:SetTarget(s.sumtg)
	e4:SetCost(s.ccost)
	e4:SetOperation(s.acop)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SUMMON)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
end
s.listed_series={SET_ALLY_OF_JUSTICE,SET_WORM}
s.ally_series={SET_ALLY_OF_JUSTICE}
s.ally_names={40155554,59482302}
function s.sumtg(e,c,tp)
	local tp=e:GetHandlerPlayer()
	local ct=c:GetMaterial():Filter(Card.IsPreviousControler,nil,1-tp):GetSum(Card.GetBaseAttack)
	if ct>0 then e:SetLabel(ct) end
	Debug.Message("Labeltg: "..(ct))
	return ct>0
end
function s.ccost(e,c,tp)
	local ct=e:GetLabel()>=0
	Debug.Message("Labelcost: "..(ct))
	return Duel.CheckLPCost(tp,ct)
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()>=0
	Debug.Message("Labelop: "..(ct))
	Duel.Hint(HINT_CARD,0,id)
	Duel.PayLPCost(tp,ct)
end
function s.spfilter(c,e,tp)
	return (c:IsCode(s.ally_names) or c:IsSetCard(s.listed_series)) 
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp)
		and c:IsMonster()
end
function s.nsfilter(c)
	return (c:IsCode(s.ally_names) or c:IsSetCard(s.listed_series)) 
		and c:IsMonster()
		and c:IsSummonable(true,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,nil,e,tp)
	local g2=Duel.GetMatchingGroup(s.nsfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,nil,e,tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then return #g1>0 and #ft>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g1=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g1>0 then
		Duel.SpecialSummon(g1,0,tp,1-tp,false,false,POS_FACEUP)
	end
	local g2=Duel.GetMatchingGroup(s.nsfilter,tp,LOCATION_HAND,0,nil,true,nil)
	if #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.BreakEffect()
		Duel.ShuffleHand(tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
		sg=g2:Select(tp,1,1,nil):GetFirst()
		Duel.Summon(tp,sg,true,nil)
	end
end