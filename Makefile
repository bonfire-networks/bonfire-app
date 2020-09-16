.PHONY: update-deps

update-deps:
	mix deps.update pointers \
		cpub_accounts cpub_blocks cpub_characters cpub_emails \
		cpub_local_auth cpub_profiles cpub_users

clean-deps:
	mix deps.clean pointers \
		cpub_accounts cpub_blocks cpub_characters cpub_emails \
		cpub_local_auth cpub_profiles cpub_users --build
