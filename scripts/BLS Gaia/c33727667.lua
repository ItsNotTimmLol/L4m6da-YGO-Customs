--Black Luster Soldier - Sinful Soldier
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99,s.matfilter)
	--Banish to return 1 banished card to GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1)
	e1:SetCost(s.rgcost)
	e1:SetTarget(s.rgtg)
	e1:SetOperation(s.rgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--Fusion Summon
	local fusparams = {nil,aux.FilterBoolFunction(Card.IsAbleToRemove),s.fextra,Fusion.BanishMaterial,nil,nil}
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetCondition(s.fuscon)
	e3:SetCost(s.fuscost)
	e3:SetTarget(Fusion.SummonEffTG(table.unpack(fusparams)))
	e3:SetOperation(Fusion.SummonEffOP(table.unpack(fusparams)))
	c:RegisterEffect(e3)
end
s.listed_series={SET_BLACK_LUSTER_SOLDIER,SET_CHAOS}
s.listed_names={33727667}
function s.matfilter(c,scard,sumtype,tp)
	return c:IsMonster() 
		and (c:IsSetCard(SET_BLACK_LUSTER_SOLDIER,scard,sumtype,tp) or c:ListsArchetype(SET_BLACK_LUSTER_SOLDIER) or c:ListsArchetypeAsMaterial(SET_BLACK_LUSTER_SOLDIER) or c:ListsCodeWithArchetype(SET_BLACK_LUSTER_SOLDIER) 
		or c:IsSetCard(SET_CHAOS,scard,sumtype,tp) or c:ListsArchetype(SET_CHAOS) or c:ListsArchetypeAsMaterial(SET_CHAOS) or c:ListsCodeWithArchetype(SET_CHAOS)
		or c:IsCode(7841921,47963370,12381100,85059922))
end
function s.cfilter(c,tp)
	return c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,false,true)
	and (c:IsSetCard(SET_BLACK_LUSTER_SOLDIER,fc,sumtype,tp) or c:ListsArchetype(SET_BLACK_LUSTER_SOLDIER) or c:ListsArchetypeAsMaterial(SET_BLACK_LUSTER_SOLDIER) or c:ListsCodeWithArchetype(SET_BLACK_LUSTER_SOLDIER) 
		or c:IsSetCard(SET_CHAOS,fc,sumtype,tp) or c:ListsArchetype(SET_CHAOS) or c:ListsArchetypeAsMaterial(SET_CHAOS) or c:ListsCodeWithArchetype(SET_CHAOS)) 
end
function s.rgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_ONFIELD|LOCATION_GRAVE,0,1,nil,tp) end
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_ONFIELD|LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.rgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.TRUE() end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_REMOVED)
end
function s.rgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsAbleToGrave),tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_RETURN)
	end
end
function s.fuscon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	if not a:IsControler(tp) then
		a=Duel.GetAttackTarget()
	end
	return a and a:IsSetCard(SET_BLACK_LUSTER_SOLDIER) and Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL
end
function s.fuscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(id)==0 end
	e:GetHandler():RegisterFlagEffect(id,RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
function s.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsCode,1,nil,5405694)
end
function s.fextra(e,tp,mg,sumtype)
	if not Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then
		return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove),tp,LOCATION_HAND|LOCATION_ONFIELD|LOCATION_EXTRA|LOCATION_GRAVE,0,nil)
	end
	return nil,s.fcheck
end
function s.stage2(e,tc,tp,mg,chk)
	if chk==1 then
		--It loses 2000 ATK
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-2000)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end