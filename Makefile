xml2rfc = xml2rfc
saxpath = "$(HOME)/java/saxon-9-7/saxon9he.jar"
saxon = java -classpath $(saxpath) net.sf.saxon.Transform -l -versionmsg:off

stylesheet = lib/myxml2rfc.xslt
reduction  = lib/clean-for-DTD.xslt
bap = bap

AUTH=draft-fielding-httpbis-http-auth-latest
CACHE=draft-fielding-httpbis-http-cache-latest
CONDITIONAL=draft-fielding-httpbis-http-conditional-latest
MESSAGING=draft-fielding-httpbis-http-messaging-latest
RANGE=draft-fielding-httpbis-http-range-latest
SEMANTICS=draft-fielding-httpbis-http-semantics-latest

TARGETS_XML= $(MESSAGING).xml \
          $(SEMANTICS).xml \
          $(CONDITIONAL).xml \
          $(RANGE).xml \
          $(CACHE).xml \
          $(AUTH).xml

TARGETS_ABNF= $(MESSAGING).abnf \
          $(SEMANTICS).abnf \
          $(CONDITIONAL).abnf \
          $(RANGE).abnf \
          $(CACHE).abnf \
          $(AUTH).abnf

TARGETS_ABNFAPPENDIX= $(TARGETS_ABNF:.abnf=.abnf-appendix)
TARGETS_HTML= $(TARGETS_XML:.xml=.html)
TARGETS_XHTML= $(TARGETS_XML:.xml=.xhtml)
TARGETS_PARSEDABNF= $(TARGETS_ABNF:.abnf=.parsed-abnf)
TARGETS_REDXML= $(TARGETS_XML:.xml=.redxml)
TARGETS_TXT= $(TARGETS_XML:.xml=.txt)

TARGETS = $(TARGETS_HTML) \
          $(TARGETS_REDXML) \
          $(TARGETS_TXT) \
          $(TARGETS_ABNF) \
          $(TARGETS_PARSEDABNF) \
          $(TARGETS_ABNFAPPENDIX) \
          $(MESSAGING).iana-headers \
          $(SEMANTICS).iana-headers \
          $(SEMANTICS).iana-methods	\
          $(SEMANTICS).iana-status-codes \
          $(CONDITIONAL).iana-headers \
          $(CONDITIONAL).iana-status-codes \
          $(RANGE).iana-headers \
          $(RANGE).iana-status-codes \
          $(CACHE).iana-headers \
          $(CACHE).iana-warn-codes \
          $(CACHE).cache-directives \
          $(AUTH).iana-headers \
          $(AUTH).iana-status-codes \
          httpbis.abnf

all: $(TARGETS)

clean:
	rm -f $(TARGETS)

%.html: %.xml $(stylesheet)
	$(saxon) $< $(stylesheet) | awk -f lib/html5doctype.awk > $@

%.redxml: %.xml $(reduction)
	$(saxon) $< $(reduction) > $@

%.txt: %.redxml
	$(xml2rfc) $< $@

%.abnf: %.xml lib/extract-artwork.xslt
	$(saxon) $< lib/extract-artwork.xslt type="abnf2616" >$@

%.parsed-abnf: %.abnf
	$(bap)/bap -i $(bap)/core.abnf < $< | LC_COLLATE=C sort | $(bap)/bap -k -i $(bap)/core.abnf -l 69 >$@

%.abnf-appendix: %.parsed-abnf
	$(saxon) $(basename $<).xml abnf2xml2rfc.xslt abnf="$<" >$@

%.xhtml: %.xml ../../rfc2629xslt/rfc2629toXHTML.xslt
	$(saxon) $< ../lib/rfc2629toXHTML.xslt > $@

%.iana-headers: %.xml extract-header-defs.xslt
	$(saxon) $< extract-header-defs.xslt > $@

%.iana-methods: %.xml extract-method-defs.xslt
	$(saxon) $< extract-method-defs.xslt > $@

%.iana-status-codes: %.xml extract-status-code-defs.xslt
	$(saxon) $< extract-status-code-defs.xslt > $@

%.iana-warn-codes: %.xml extract-warn-code-defs.xslt
	$(saxon) $< extract-warn-code-defs.xslt > $@

%.cache-directives: %.xml extract-cache-directives.xslt
	$(saxon) $< extract-cache-directives.xslt > $@

outlineALL.html:	$(TARGETS_XHTML) \
	extractOutline.xslt
	$(saxon) extractOutline.xslt extractOutline.xslt > $@
	rm p*.xhtml

httpbis.abnf:	$(TARGETS_ABNF)
	./common-abnf.sh $^ > $@

consistency.txt:	$(TARGETS_XML)
	rm -f $@
	echo P1 >> $@
	echo >> $@
	saxon $(MESSAGING).xml consistency-check.xslt >> $@
	echo >> $@
	echo P2 >> $@
	echo >> $@
	saxon $(SEMANTICS).xml consistency-check.xslt >> $@
	echo >> $@
	echo P4 >> $@
	echo >> $@
	saxon $(CONDITIONAL).xml consistency-check.xslt >> $@
	echo >> $@
	echo P5 >> $@
	echo >> $@
	saxon $(RANGE).xml consistency-check.xslt >> $@
	echo >> $@
	echo P6 >> $@
	echo >> $@
	saxon $(CACHE).xml consistency-check.xslt >> $@
	echo >> $@
	echo P7 >> $@
	echo >> $@
	saxon $(AUTH).xml consistency-check.xslt >> $@
	echo >> $@
