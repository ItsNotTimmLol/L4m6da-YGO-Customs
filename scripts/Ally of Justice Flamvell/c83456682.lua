--Ally of Justice Field
--Scripted by WolfSif
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--change attribute
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(0,LOCATION_MZONE|LOCATION_HAND|LOCATION_GRAVE)
	e1:SetCondition(s.lightcon)
	e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e1:SetValue(ATTRIBUTE_LIGHT)
	c:RegisterEffect(e1)
	--Monsters whose ATK is different from their original ATK are unaffected by your opponent's activated effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.immtg)
	e2:SetValue(s.immval)
	c:RegisterEffect(e2)
	--SS if monster leaves opponent's field
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return eg:IsExists(Card.IsControler,1,nil,1-tp) end)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
	--[[avoid battle damage
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(function(e,c) return c:IsSetCard(SET_FLAMVELL) end)
	e3:SetValue(1)
	c:RegisterEffect(e3)]]
	--[[Flamvell banish mill
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCondition(s.rmcon)
	e4:SetTarget(s.rmtg)
	e4:SetOperation(s.rmop)
	c:RegisterEffect(e4)
	--Change damage
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCode(EFFECT_CHANGE_DAMAGE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetTargetRange(0,1)
	e4:SetValue(s.val)
	c:RegisterEffect(e4)]]
	--[[Flamvell monsters are Pyro
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CHANGE_RACE)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_FLAMVELL))
	e5:SetValue(RACE_PYRO)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetTargetRange(LOCATION_GRAVE,0)
	e6:SetTarget(s.tg)
	c:RegisterEffect(e6)
	--Flamvell monsters are Fire
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e7:SetRange(LOCATION_FZONE)
	e7:SetTargetRange(LOCATION_MZONE,0)
	e7:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_FLAMVELL))
	e7:SetValue(ATTRIBUTE_FIRE)
	c:RegisterEffect(e7)
	local e8=e7:Clone()
	e8:SetTargetRange(LOCATION_GRAVE,0)
	e8:SetTarget(s.tg)
	c:RegisterEffect(e8)
	--Code check Pyro
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_FIELD)
	e9:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e9:SetCode(id)
	e9:SetRange(LOCATION_FZONE)
	e9:SetTargetRange(1,0)
	e9:SetValue(s.raceval)
	c:RegisterEffect(e9)
	--Code check Fire
	local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_FIELD)
	e10:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e10:SetCode(id)
	e10:SetRange(LOCATION_FZONE)
	e10:SetTargetRange(1,0)
	e10:SetValue(s.attval)
	c:RegisterEffect(e10)]]
	
end
s.listed_names={40155554,59482302}
s.listed_series={SET_ALLY_OF_JUSTICE,SET_FLAMVELL}
--immune
function s.immtg(e,c)
	return (c:IsCode(40155554) or c:IsSetCard(SET_ALLY_OF_JUSTICE) or c:IsSetCard(SET_FLAMVELL)) and c:IsMonster() and not c:IsAttack(c:GetBaseAttack())
end
function s.immval(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

function s.lightcon(e)
	return Duel.IsExistingMatchingCard(s.lightfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.lightfilter(c)
	return c:IsSetCard(s.listed_series)
		and (c:IsType(TYPE_NORMAL) or c:IsLevelAbove(7))
		and c:IsMonster() and c:IsFaceup()
end

--Spam
function s.spconfilter(c,tp)
	return c:IsMonster() --and c:IsPreviousControler(1-tp) --and c:IsAttributeExcept(ATTRIBUTE_LIGHT) --s.exfilter(c,tp)
end
function s.exfilter(c,tp)
	return not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spconfilter,1,nil,tp)
end
function s.spfilter(c,e,tp)
	return (c:IsSetCard(s.listed_series) or c:IsCode(59482302))
		and ((Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,nil,tp)) or (Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)))
		and c:IsMonster() and c:IsLevelBelow(3)
		--and not Duel.IsExistingMatchingCard(s.uniquefilter,tp,LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,c:GetCode())
end
function s.uniquefilter(c,code)
	return c:IsCode(code) and c:IsFaceup() and c:IsMonster()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		--and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(s.firstsummon,1,nil,e,tp,sg)
end
function s.firstsummon(c,e,tp,sg)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and sg:IsExists(s.secondsummon,1,c,e,tp) --exclude 'c'
end
function s.secondsummon(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	--[[if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 or Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)<1 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_SPSUMMON)
	if #sg~=2 then return end
	local sc1=sg:FilterSelect(tp,s.firstsummon,1,1,nil,e,tp,sg):GetFirst()
	local sc2=sg:RemoveCard(sc1):GetFirst()
	Duel.SpecialSummonStep(sc1,0,tp,tp,false,false,POS_FACEUP)
	Duel.SpecialSummonStep(sc2,0,tp,1-tp,false,false,POS_FACEUP)
	Duel.SpecialSummonComplete]]
end


--To hand
function s.thfilter(c)
	return c:IsSetCard(SET_FLAMVELL) --[[and c:IsMonster()]] and c:IsAbleToHand()
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

--x2 damage test
function s.val(e,re,val,r,rp)
	if r&REASON_EFFECT==REASON_EFFECT and re and re:IsMonsterEffect() then
		local rc=re:GetHandler()
		if rc:IsFaceup() and rc:IsSetCard(SET_FLAMVELL) then
			return val*2
		end
	end
	return val
end



--LP & Banish Ex
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:IsMonsterEffect() and re:GetHandler():IsSetCard(SET_FLAMVELL) 
		and re:GetHandler():IsControler(tp)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_DECK)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	--[[local rc=re:GetHandler()
	Duel.Recover(tp,rc:GetLevel()*200,REASON_EFFECT)
	Duel.BreakEffect()]]--
	local g=Duel.GetDecktopGroup(1-tp,1)
	Duel.DisableShuffleCheck()
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end

--Fix stats
function s.tg(e,c)
	if c:GetFlagEffect(1)==0 then
		c:RegisterFlagEffect(1,0,0,0)
		local eff={c:GetCardEffect(EFFECT_NECRO_VALLEY)}
		c:ResetFlagEffect(1)
		for _,te in ipairs(eff) do
			local op=te:GetOperation()
			if not op or op(e,c) then return false end
		end
	end
	return c:IsSetCard(SET_FLAMVELL) and c:IsMonster()
end
function s.raceval(e,c,re,chk)
	if chk==0 then return true end
	return RACE_PYRO
end
function s.attval(e,c,re,chk)
	if chk==0 then return true end
	return ATTRIBUTE_FIRE
end
