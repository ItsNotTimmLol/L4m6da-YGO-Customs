--Ally of Justice Simulation
--Scripted by WolfSif
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--[[Shuffle to return self to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.rthcost)
	e1:SetTarget(s.rthtg)
	e1:SetOperation(s.rthop)
	c:RegisterEffect(e1)]]
	--Change to LIGHT or face-down
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Extender--Sent
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.sp2con)
	e2:SetTarget(s.sp2tg)
	e2:SetOperation(s.sp2op)
	c:RegisterEffect(e2)
	--Banished
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)

	--[[Flamvell banish & LP Ex
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.rmcon)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,1))
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetRange(LOCATION_SZONE)
	e7:SetCountLimit(1)
	e7:SetTarget(s.tg)
	e7:SetOperation(s.op)
	c:RegisterEffect(e7)]]
	--register names
	aux.GlobalCheck(s,function()
		s.name_list={}
		s.name_list[0]={}
		s.name_list[1]={}
		aux.AddValuesReset(function()
			s.name_list[0]={}
			s.name_list[1]={}
		end)
	end)
end
s.listed_names={40155554}
s.listed_series={SET_ALLY_OF_JUSTICE,SET_FLAMVELL}

function s.posfilter(c)
	return c:IsFaceup() and (s.pos1filter(c) or s.pos2filter(c))
end
function s.pos1filter(c)
	return not c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.pos2filter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsCanTurnSet()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.posfilter,tp,LOCATION_MZONE,0,1,nil) or Duel.IsExistingTarget(s.posfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g1=Duel.SelectTarget(tp,s.posfilter,tp,LOCATION_MZONE,0,0,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g2=Duel.SelectTarget(tp,s.posfilter,tp,0,LOCATION_MZONE,#g1-1,1,nil)
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g1,2,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g1=Duel.GetTargetCards(e):Filter(s.pos1filter,nil)
	local g2=Duel.GetTargetCards(e):Filter(s.pos2filter,nil)
	if #g1>0 then
		local tc1=g1:GetFirst()
		for tc1 in aux.Next(g1) do
			--It becomes LIGHT
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e1:SetValue(ATTRIBUTE_LIGHT)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc1:RegisterEffect(e1)
		end
	elseif #g2>0 then
		local tc2=g2:GetFirst()
		for tc2 in aux.Next(g2) do
			Duel.ChangePosition(tc2,POS_FACEDOWN_DEFENSE)
		end
	end
end

--Extender
function s.cfilter(c,tp)
	return (c:IsSetCard(SET_ALLY_OF_JUSTICE) or c:IsSetCard(SET_FLAMVELL)) and c:IsControler(tp)
		and not s.name_list[tp][c:GetCode()]
end
function s.sp2con(e,tp,eg,ep,ev,re,r,rp)
	for rc in aux.Next(eg) do
		if (rc:IsSetCard(SET_ALLY_OF_JUSTICE) or rc:IsSetCard(SET_FLAMVELL)) and rc:IsControler(tp) then return eg:IsExists(s.cfilter,1,nil,tp) end
	end
	return false
end

function s.sp2filter(c,e,tp,ev)
	if c:GetReasonCard() and not (c:GetReasonCard():IsSetCard(SET_ALLY_OF_JUSTICE) or c:GetReasonCard():IsSetCard(SET_FLAMVELL)) then return end
	if c:GetReasonEffect() and not (c:GetReasonEffect():GetHandler():IsSetCard(SET_ALLY_OF_JUSTICE) or c:GetReasonEffect():GetHandler():IsSetCard(SET_FLAMVELL) ) then return end
	if c:GetReasonEffect()==REASON_COST and c:GetReasonEffect():IsActivated() and not (Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_SETCODES)==SET_ALLY_OF_JUSTICE or Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_SETCODES)==SET_FLAMVELL) then return end
	return s.cfilter(c,tp) and c:IsMonster() and c:IsCanBeEffectTarget(e) and c:IsFaceup() 
		and (c:IsAbleToHand()
		or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP,tp))
		or (Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP,1-tp)))
end
	--Activation legality
function s.sp2tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=eg:Filter(s.sp2filter,nil,e,tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>0 end
	local c=nil
	if #g>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		c=g:Select(tp,1,1,nil):GetFirst()
	else
		c=g:GetFirst()
	end
	Duel.SetTargetCard(c)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
	if c:IsLocation(LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
	end
	--Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,g:GetFirst():GetLocation())
	--Card.RegisterFlagEffect(e:GetHandler(),id,RESET_PHASE|PHASE_END+RESET_EVENT|RESET_LEAVE,0,1)
end
function s.sp2op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	s.name_list[tp][tc:GetCode()]=true
	if not tc:IsRelateToEffect(e) then return end
	local b1=true
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,true,false)
	local b3=Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP,1-tp)
	if not (b1 or b2 or b3) then return end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,3)},
		{b2,aux.Stringid(id,4)},
		{b3,aux.Stringid(id,5)})
	if op==1 then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	elseif op==2 or op==3 then
		local target_player=op==2 and tp or 1-tp
		if Duel.SpecialSummon(tc,0,tp,target_player,true,false,POS_FACEUP)==0 then return end
	end
end

--Add to hand
function s.thfilter(c)
	return ((c:IsSetCard(SET_ALLY_OF_JUSTICE) or c:IsSetCard(SET_FLAMVELL)) or c:IsCode(74845897)) --[[and not c:IsCode(id)]] and c:IsAbleToHand()
end
function s.res1con(sg,e,tp,mg)
	return sg:FilterCount(Card.IsSetCard,nil,SET_FLAMVELL)<=1 and sg:FilterCount(Card.IsCode,nil,74845897)<=1
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,2,s.res1con,1,tp,HINTMSG_ATOHAND)
		if #sg>0 then
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
--LP & Banish Ex
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:IsMonsterEffect() and re:GetHandler():IsSetCard(SET_FLAMVELL) 
		and re:GetHandler():IsControler(tp)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rc:GetLevel()*100)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	Duel.Recover(tp,rc:GetLevel()*100,REASON_EFFECT)
	Duel.BreakEffect()
end


--ATK/DEF change
function s.atk1tg(e,c)
	return c:IsFaceup() and c:IsSetCard(SET_FLAMVELL) and c:IsMonster()
end
function s.atkval(e,c)
	return c:GetBaseDefense()-200
end

--Shuffle and return to hand
function s.rthfilter(c)
	return c:IsSetCard(SET_FLAMVELL) and c:IsFaceup()
end
function s.res2con(sg,e,tp,mg)
	return sg:FilterCount(s.rthfilter,nil)>=1
end
function s.rthcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeckOrExtraAsCost,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
	if chk==0 then return #g>1 and g:IsExists(s.rthfilter,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,3,s.res2con,1,tp,HINTMSG_ATOHAND)
	Duel.SendtoDeck(sg,nil,3,REASON_COST)
end
function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	c:CreateEffectRelation(e)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	end
end
function s.sp1filter(c,e,tp)
	return c:IsSetCard(SET_FLAMVELL) and c:IsMonster() 
		and ((Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp))
		or (Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)))
end
--Onfield test
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g1=Duel.GetMatchingGroup(s.sp1filter,tp,LOCATION_DECK,0,nil,e,tp)
	local g2=Duel.GetMatchingGroup(Card.IsAbleToDeckOrExtraAsCost,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
	local b1=not Duel.HasFlagEffect(tp,id) and #g1>0
	local b2=not Duel.HasFlagEffect(tp,id+1) and #g2>2 and g2:IsExists(s.rthfilter,1,nil)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_ALL,LOCATION_GRAVE|LOCATION_REMOVED)
	elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sg=aux.SelectUnselectGroup(g2,e,tp,2,2,s.res2con,1,tp,HINTMSG_ATOHAND)
		Duel.SendtoDeck(sg,nil,3,REASON_COST)
		Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,LOCATION_GRAVE,LOCATION_GRAVE)
	end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		if not e:GetHandler():IsRelateToEffect(e) then return end
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		local g1=Duel.GetMatchingGroup(s.sp1filter,tp,LOCATION_DECK,0,nil,e,tp)
		if #g1>0 then
			local fid=e:GetHandler():GetFieldID()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local ft1=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
			if ft1>1 then ft1=1 end
			local sg1=g1:Select(tp,1,ft1,nil)
			local tc=sg1:GetFirst()
			ft1=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
			if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft1=1 end
			ft1=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
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
			if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft2=1 end
			local g2=Duel.GetMatchingGroup(s.sp1filter,tp,LOCATION_DECK,0,nil,e,tp)
			local sg2=g2:Select(tp,1,ct2,nil)
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
			e0:SetCondition(s.descon)
			e0:SetOperation(s.desop)
			Duel.RegisterEffect(e0,tp)
			--[[Cannot Special Summon monsters from Deck/GY, except Flamvell monsters
			local c=e:GetHandler()
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,1))
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetTargetRange(1,0)
			e1:SetTarget(function(e,c) return not c:IsSetCard(SET_FLAMVELL) and c:IsLocation(LOCATION_DECK|LOCATION_GRAVE) end)
			e1:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e1,tp)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			Duel.RegisterEffect(e2,tp)]]--
		end
	elseif op==2 then
		local c=e:GetHandler()
		local rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,tp)
		if c:IsRelateToEffect(e) and #rg>0 then
			--Duel.SendtoHand(c,nil,REASON_EFFECT)
			--Duel.ConfirmCards(1-tp,c)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			rg=rg:Select(tp,1,1,nil)
			Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
		end
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
end