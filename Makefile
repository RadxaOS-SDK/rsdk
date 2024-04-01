#
# Documentation
#
.PHONY: serve
serve:
	mdbook serve

.PHONY: serve_zh-CN
serve_zh-CN:
	MDBOOK_BOOK__LANGUAGE=zh-CN mdbook serve -d book/zh-CN

.PHONY: translate
translate:
	MDBOOK_OUTPUT='{"xgettext": {"pot-file": "messages.pot"}}' mdbook build -d po
	for i in po/*.po; \
	do \
		msgmerge --update $$i po/messages.pot; \
	done

.PHONY: update-admonish
update-admonish:
	mdbook-admonish install --css-dir theme/css
