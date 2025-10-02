--Ally of Justice Flamvell Contractor
--Scripted by WolfSif
local s,id=GetID()
function s.initial_effect(c)
	--fusion summon
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,s.mfilter1,s.mfilter2)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.splimit)
	--Must be either Fusion Summoned or Special Summoned by alternate procedure
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	--[[Alternate Summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.selfspcon)
	e1:SetTarget(s.selfsptg)
	e1:SetOperation(s.selfspop)
	c:RegisterEffect(e1)]]
	--Cannot be used as Link Material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	c:RegisterEffect(e2)
	--nontuner
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_NONTUNER)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_SYNCHRO_CHECK)
	e4:SetValue(function(_,c) return c:AssumeProperty(ASSUME_RACE,RACE_PYRO) end)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetValue(function(_,c) return c:AssumeProperty(ASSUME_ATTRIBUTE,ATTRIBUTE_FIRE) end)
	c:RegisterEffect(e5)
	--Search
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e6:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e6:SetCode(EVENT_LEAVE_FIELD)
	e6:SetCondition(s.thcon)
	e6:SetTarget(s.thtg)
	e6:SetOperation(s.thop)
	c:RegisterEffect(e6)
	--banish face-down
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,0))
	e7:SetCategory(CATEGORY_REMOVE)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e7:SetProperty(EFFECT_FLAG_DELAY)
	e7:SetCode(EVENT_SPSUMMON_SUCCESS)
	e7:SetCondition(s.remcon)
	e7:SetTarget(s.remtg)
	e7:SetOperation(s.remop)
	c:RegisterEffect(e7)
	--[[local e8=e7:Clone()
	e8:SetCondition(function(e) return e:GetHandler():IsFusionSummoned() end)
	c:RegisterEffect(e8)]]--
	local e9=Effect.CreateEffect(c)
    e9:SetType(EFFECT_TYPE_FIELD)
    e9:SetCode(EFFECT_DECREASE_TRIBUTE)
    e9:SetRange(LOCATION_MZONE)
    e9:SetTargetRange(LOCATION_HAND,0)
    e9:SetTarget(aux.TargetBoolFunction(Card.IsLevelAbove,7))
    e9:SetValue(0x1)
    c:RegisterEffect(e9)
	
end
s.listed_names={40155554,59482302}
s.listed_series={SET_ALLY_OF_JUSTICE,SET_FLAMVELL}
function s.mfilter1(c,fc,sumtype,tp,sub,mg,sg)
	return c:IsMonster() and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
		and ((c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK)) or c:IsSetCard(SET_FLAMVELL,fc,sumtype,tp))
end
function s.mfilter2(c,fc,sumtype,tp,sub,mg,sg)
	return c:IsMonster() and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
		and (c:IsCode(40155554) or c:IsCode(59482302) or c:IsAttribute(ATTRIBUTE_FIRE) or c:IsSetCard(SET_ALLY_OF_JUSTICE,fc,sumtype,tp))
end
--Modified Summoning Conditions
function s.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToDeckOrExtraAsCost,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_GRAVE,0,nil)
end
function s.contactop(g,tp)
	local fu,fd=g:Split(Card.IsFaceup,nil)
	if #fu>0 then Duel.HintSelection(fu,true) end
	if #fd>0 then Duel.ConfirmCards(1-tp,fd) end
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST|REASON_MATERIAL)
end
--Alt Summoning Procedure
function s.selfspfilter(c,tp,sc)
	return (c:IsCode(40155554) or c:IsCode(59482302) or c:IsSetCard(SET_ALLY_OF_JUSTICE,fc,sumtype,tp) or c:IsSetCard(SET_FLAMVELL,fc,sumtype,tp)) and c:IsMonster() and not c:IsType(TYPE_FUSION) and c:IsAbleToDeckOrExtraAsCost() and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end
function s.selfspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.IsExistingMatchingCard(s.selfspfilter,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE|LOCATION_GRAVE,0,1,nil)
end
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.SelectMatchingCard(tp,s.selfspfilter,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE|LOCATION_GRAVE,0,1,1,nil)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
	return true
	end
	return false
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	c:SetMaterial(g)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST|REASON_MATERIAL)
	g:DeleteGroup()
end
--Add
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and not c:IsLocation(LOCATION_EXTRA)
end
function s.thfilter(c)
	return c:IsSetCard(s.listed_series) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.remcon(e,tp,eg,ep,ev,re,r,rp)
	local mg=e:GetHandler():GetMaterial()
	return mg and e:GetHandler():IsSummonLocation(LOCATION_EXTRA) and mg:IsExists(Card.IsType,1,nil,TYPE_NORMAL)
end
function s.remtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD|LOCATION_GRAVE,LOCATION_ONFIELD|LOCATION_GRAVE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,LOCATION_ONFIELD|LOCATION_GRAVE)
end
function s.remop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD|LOCATION_GRAVE,LOCATION_ONFIELD|LOCATION_GRAVE,1,1,nil)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end