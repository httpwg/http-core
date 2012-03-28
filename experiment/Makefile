xml2rfc = "../../xml2rfc/xml2rfc.tcl"
saxpath = "$(HOME)/java/saxon-8-9-j/saxon8.jar"
saxon = java -classpath $(saxpath) net.sf.saxon.Transform -novw -l

stylesheet = ../myxml2rfc.xslt
reduction  = ../../rfc2629xslt/clean-for-DTD.xslt
bap  = ../../abnfparser/bap

TARGETS_XML= p1-messaging.xml \
          p2-semantics.xml \
          p3-payload.xml \
          p4-conditional.xml \
          p5-range.xml \
          p6-cache.xml \
          p7-auth.xml

TARGETS_ABNF= $(TARGETS_XML:.xml=.abnf)
TARGETS_ABNFAPPENDIX= $(TARGETS_XML:.xml=.abnf-appendix)
TARGETS_HTML= $(TARGETS_XML:.xml=.html)
TARGETS_XHTML= $(TARGETS_XML:.xml=.xhtml)
TARGETS_PARSEDABNF= $(TARGETS_XML:.xml=.parsed-abnf)
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
	$(saxon) $< $(stylesheet) > $@

%.redxml: %.xml $(reduction)
	$(saxon) $< $(reduction) > $@

%.txt: %.redxml
	$(xml2rfc) $< $@

%.abnf: %.xml ../../rfc2629xslt/extract-artwork.xslt
	$(saxon) $< ../../rfc2629xslt/extract-artwork.xslt type="abnf2616" >$@

%.parsed-abnf: %.abnf
	$(bap)/bap -i $(bap)/core.abnf < $< | sort | $(bap)/bap -k -i $(bap)/core.abnf -l 69 >$@

%.abnf-appendix: %.parsed-abnf
	$(saxon) $(basename $<).xml abnf2xml2rfc.xslt abnf="$<" >$@

%.xhtml: %.xml ../../rfc2629xslt/rfc2629toXHTML.xslt
	$(saxon) $< ../../rfc2629xslt/rfc2629toXHTML.xslt > $@

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
