xml2rfc = xml2rfc
saxpath = "$(HOME)/java/saxon-9-7-j/saxon97he.jar"
saxon = java -classpath $(saxpath) net.sf.saxon.Transform -l -versionmsg:off

stylesheet = lib/myxml2rfc.xslt
reduction  = lib/clean-for-DTD.xslt
bap = bap

TARGETS_XML= p1-messaging.xml \
          p2-semantics.xml \
          p4-conditional.xml \
          p5-range.xml \
          p6-cache.xml \
          p7-auth.xml

TARGETS_ABNF= p1-messaging.abnf \
          p2-semantics.abnf \
          p4-conditional.abnf \
          p5-range.abnf \
          p6-cache.abnf \
          p7-auth.abnf

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
          p1-messaging.iana-headers \
          p2-semantics.iana-headers \
          p2-semantics.iana-methods	\
          p2-semantics.iana-status-codes \
          p4-conditional.iana-headers \
          p4-conditional.iana-status-codes \
          p5-range.iana-headers \
          p5-range.iana-status-codes \
          p6-cache.iana-headers \
          p6-cache.iana-warn-codes \
          p6-cache.cache-directives \
          p7-auth.iana-headers \
          p7-auth.iana-status-codes \
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
	saxon p1-messaging.xml consistency-check.xslt >> $@
	echo >> $@
	echo P2 >> $@
	echo >> $@
	saxon p2-semantics.xml consistency-check.xslt >> $@
	echo >> $@
	echo P4 >> $@
	echo >> $@
	saxon p4-conditional.xml consistency-check.xslt >> $@
	echo >> $@
	echo P5 >> $@
	echo >> $@
	saxon p5-range.xml consistency-check.xslt >> $@
	echo >> $@
	echo P6 >> $@
	echo >> $@
	saxon p6-cache.xml consistency-check.xslt >> $@
	echo >> $@
	echo P7 >> $@
	echo >> $@
	saxon p7-auth.xml consistency-check.xslt >> $@
	echo >> $@
