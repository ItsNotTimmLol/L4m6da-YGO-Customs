--W Nebula Helminth
function s.initial_effect(c)
	-- Equip Spell
	c:EnableReviveLimit()
	-- Roll a die, Special Summon a "Worm", then equip this card
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DICE+CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Set "Dimensionhole", "Worm Call", and "W Nebula" card
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_TOFIELD)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	--Equip to a monster
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(s.eqtg)
	e3:SetOperation(s.eqop)
	c:RegisterEffect(e3)
	--Give control of 1 face-up or Set Reptile "Worm" monster
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_CONTROL)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,id,EFFECT_COUNT_CODE_CHAIN)
	e4:SetCondition(s.ctcon)
	e4:SetTarget(s.cttg)
	e4:SetOperation(s.ctop)
	c:RegisterEffect(e4)
end
function s.spfilter(c,e,tp,lv)
	return c:IsSetCard(SET_WORM)
		and c:IsRace(RACE_REPTILE)
		and c:IsLevel(lv)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- Check ANY Level 1-6 Worm
		for lv=1,6 do
			if Duel.IsExistingMatchingCard(s.spfilter,tp,
				LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,lv) then
				return true
			end
		end
		return false
	end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,1,tp,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local roll=Duel.TossDice(tp,1)
	local g=Duel.GetMatchingGroup(
		s.spfilter,tp,
		LOCATION_HAND+LOCATION_DECK,0,
		nil,e,tp,roll
	)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)>0 then
		-- Equip this card to the summoned monster
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			Duel.Equip(tp,c,tc)
			-- Make this card an Equip Spell equipped to that monster
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_COPY_INHERIT+EFFECT_FLAG_OWNER_RELATE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(function(e,tc)
				return tc==e:GetLabelObject()
			end)
			e1:SetLabelObject(tc)
			c:RegisterEffect(e1)
		end
		-- Then Set the three cards
		s.setop(e,tp,eg,ep,ev,re,r,rp)
	end
end
--Set
function s.setfilter(c)
	return (c:IsCode(22959079)
		or c:IsCode(28506708)
		or c:IsSetCard(SET_WORM)) -- placeholder for W Nebula
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)	end
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- "W Nebula" itself is excluded
	local g=Duel.GetMatchingGroup(
		function(tc)
			return (tc:IsCode(22959079)
				or tc:IsCode(28506708)
				or tc:IsCode(53842829))
				and tc:IsLocation(LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
		end,
		tp,
		LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,
		0,nil
	)
	-- Select at most one of each card.
	local selected=Group.CreateGroup()
	for _,code in ipairs({
		22959079,
		28506708
	}) do
		local sg=g:Filter(
			function(tc)
				return tc:IsCode(code)
			end,nil
		)

		if #sg>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
			local tc=sg:Select(tp,1,1,nil):GetFirst()

			if tc then
				selected:AddCard(tc)
			end
		end
	end

	-- "W Nebula" should be identified by its actual card code.
	-- Replace 0x???? with the set/code of your "W Nebula" card.
	local nebula=Duel.GetMatchingGroup(
		function(tc)
			return tc:IsCode(0x0) and tc:IsLocation(
				LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED
			)
		end,
		tp,
		LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,
		0,nil
	)

	if #nebula>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local tc=nebula:Select(tp,1,1,nil):GetFirst()

		if tc then
			selected:AddCard(tc)
		end
	end

	-- Set all selected cards
	for tc in aux.Next(selected) do
		if tc:IsRelateToEffect(e) or tc:IsLocation(
			LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED
		) then
			Duel.SSet(tp,tc)
		end
	end
end

----------------------------------------------------------
-- If this card is banished:
-- Target 1 monster on the field and equip this card to it.
----------------------------------------------------------

function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE)
	end

	if chk==0 then
		return Duel.IsExistingTarget(
			aux.TRUE,tp,
			LOCATION_MZONE,LOCATION_MZONE,
			1,nil
		)
	end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(
		tp,
		aux.TRUE,tp,
		LOCATION_MZONE,LOCATION_MZONE,
		1,1,nil
	)
end

function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()

	if not tc or not tc:IsRelateToEffect(e) then return end

	if not c:IsRelateToEffect(e) then
		-- The card was banished and is now in the banished zone.
		if not c:IsLocation(LOCATION_REMOVED) then return end
	end

	Duel.Equip(tp,c,tc)

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_COPY_INHERIT+EFFECT_FLAG_OWNER_RELATE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(function(e,tc)
		return tc==e:GetLabelObject()
	end)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
end

----------------------------------------------------------
-- Once per Chain, when another card/effect is activated:
-- Give control of 1 face-up or Set Reptile "Worm"
-- monster you own and control to your opponent.
----------------------------------------------------------

function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	-- "another card or effect" means this card itself
	-- cannot be the activated card.
	return re:GetHandler()~=e:GetHandler()
end

function s.ctfilter(c,tp)
	return c:IsSetCard(SET_WORM)
		and c:IsRace(RACE_REPTILE)
		and c:IsFaceup() -- remove this restriction for Set monsters
		and c:IsControler(tp)
		and c:IsAbleToChangeControler()
end

function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(
			s.ctfilter,tp,
			LOCATION_MZONE,0,
			1,nil,tp
		)
	end

	Duel.SetOperationInfo(
		0,
		CATEGORY_CONTROL,
		nil,
		1,
		1-tp,
		LOCATION_MZONE
	)
end

function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(
		s.ctfilter,tp,
		LOCATION_MZONE,0,nil,tp
	)

	if #g==0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local tc=g:Select(tp,1,1,nil):GetFirst()

	if tc then
		Duel.GetControl(tc,1-tp,PHASE_END,1)
	end
end