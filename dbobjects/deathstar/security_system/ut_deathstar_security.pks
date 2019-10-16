create or replace package ut_deathstar_security as
	-- %suite(Deathstar Security)
	-- %suitepath(deathstar.defense)
	  
	-- %beforeall
	procedure setup_test_protocols;

	-- %context(low)
		-- %displayname(Protocol: Low)

		-- %beforeall
		procedure setup_protocol_low;

		-- %test(Hooded Person gets a kind welcome message)
		procedure low_welcome_message;

		-- %test(Entry to public area is allowed)
		procedure low_entry_allowed;
	-- %endcontext

	-- %context(medium)
		-- %displayname(Protocol: Medium)

		-- %beforeall
		procedure setup_protocol_medium;

		-- %test(Hooded Person gets a suspicious welcome message)
		procedure medium_welcome_message;

		-- %test(Entry to public area is denied)
		procedure medium_entry_allowed;
	-- %endcontext

	-- %context(high)
		-- %displayname(Protocol: High)

		-- %beforeall
		procedure setup_protocol_high;

		-- %test(Hooded Person is yelled at)
		procedure high_welcome_message;

		-- %test(Try to access public area throws exception)
		-- %throws(-20100)
		procedure high_entry_allowed;
	-- %endcontext
end;
/