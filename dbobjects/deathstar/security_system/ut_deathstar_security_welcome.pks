create or replace package ut_deathstar_security_welcome as
  -- %suite(Deathstar-Security: Welcome message)
  -- %suitepath(ut_deathstar.defense)

  -- %beforeall
  procedure setup_protocol;

  -- %test(We expect to receive the controlled protocol)
  procedure we_get_the_expected_protocol;

  -- %context(When protocol in Defense-Mode: BE_KIND)
		-- %name(be_kind)

		-- %beforeall
		procedure setup_protocol_be_kind;

		-- %test(Friend is welcomed)
		procedure be_kind_friend_is_welcomed;

		-- %test(Foe is shouted at)
		procedure be_kind_foe_is_shouted_at;

		-- %test(Unknown is welcomed)
		procedure be_kind_unknown_is_welcomed;
	-- %endcontext

  -- %context(When protocol in Defense-Mode: BE_SUSPICIOUS)
		-- %name(be_suspicious)

		-- %beforeall
		procedure setup_protocol_be_suspicious;

		-- %test(Friend is welcomed)
		procedure be_suspicious_friend_is_welcomed;

		-- %test(Foe is shouted at)
		procedure be_suspicious_foe_is_shouted_at;

		-- %test(Unknown is asked whether they are a jedi)
		procedure be_suspicious_unknown_is_asked;
	-- %endcontext

  -- %context(When protocol in Defense-Mode: SHOOT_FIRST_ASK_LATER)
		-- %name(be_aggressive)

		-- %beforeall
		procedure setup_protocol_be_aggressive;

		-- %test(Friend is welcomed)
		procedure be_aggressive_friend_is_welcomed;

		-- %test(Foe is shouted at)
		procedure be_aggressive_foe_is_shouted_at;

		-- %test(Unknown is shouted at)
		procedure be_aggressive_unknown_is_shouted_at;
	-- %endcontext

end;
/