local s,id=GetID()
function s.initial_effect(c)
	--Copy Normal Spell/Trap
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Can be activated from the hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e2)
	--Shuffle to add Sorcerer of DM or Eff monster with DM 
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE|LOCATION_REMOVED)
	e3:SetCost(s.tdcost)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_DARK_MAGICIAN}
function s.copfilter(c)
	return c:IsAbleToGraveAsCost() and c:ListsCodeWithArchetype(SET_DARK_MAGICIAN,SET_DARK_MAGICIAN_GIRL) 
		and c:IsNormalSpellTrap() and not c:IsCode(id) and c:CheckActivateEffect(false,true,false)~=nil
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.copfilter,tp,LOCATION_HAND|LOCATION_ONFIELD|LOCATION_DECK,0,1,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	if chk==0 then return Duel.IsExistingMatchingCard(s.copfilter,tp,LOCATION_HAND|LOCATION_ONFIELD|LOCATION_DECK,0,1,nil) end
	local g=Duel.SelectMatchingCard(tp,s.copfilter,tp,LOCATION_HAND|LOCATION_ONFIELD|LOCATION_DECK,0,1,1,nil,tp)
	local sg=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_HAND|LOCATION_ONFIELD|LOCATION_DECK,0,nil,g:GetFirst():GetCode())
	if not Duel.SendtoGrave(sg,REASON_COST) then return end
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	Duel.ClearTargetCard()
	g:GetFirst():CreateEffectRelation(e)
	local tg=te:GetTarget()
	e:SetProperty(te:GetProperty())
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	Duel.ClearOperationInfo(0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te or not te:GetHandler():IsRelateToEffect(e) then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then
		op(e,tp,eg,ep,ev,re,r,rp)
	end
end
function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() and Duel.IsExistingMatchingCard(Card.IsAbleToDeckAsCost,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,c) end
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeckAsCost,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,c)
	g:AddCard(c)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.tdfilter(c)
	return (c:IsCode(CARD_DARK_MAGICIAN,88619463) or c:ListsCode(CARD_DARK_MAGICIAN,CARD_DARK_MAGICIAN_GIRL,40737112) or c:IsCode(1784686,40737112,49702428))
end
function s.spfilter(c,e,tp)
	return (c:IsCode(CARD_DARK_MAGICIAN,88619463) or c:ListsCode(CARD_DARK_MAGICIAN,CARD_DARK_MAGICIAN_GIRL,40737112) or c:IsCode(1784686,40737112,49702428)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsNonEffectMonster()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_REMOVED|LOCATION_GRAVE)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local ct1=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	local ct2=Duel.GetFieldGroupCount(tp,LOCATION_HAND|LOCATION_REMOVED|LOCATION_GRAVE,0)
	local tc1=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_DECK,0,1,1,nil,ct1):GetFirst()
	if tc1:IsAbleToDeck() then 
		Duel.ShuffleDeck(tp)
		Duel.MoveToDeckTop(tc1)
	end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetTurnPlayer()==1-tp and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_REMOVED|LOCATION_GRAVE,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		local tc2=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_REMOVED|LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
		Duel.SpecialSummon(tc2,0,tp,tp,false,false,POS_FACEUP)
	end
end