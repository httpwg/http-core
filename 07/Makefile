xml2rfc = "../../xml2rfc/xml2rfc.tcl"
saxpath = "$(HOME)/java/saxon-8-9-j/saxon8.jar"
saxon = java -classpath $(saxpath) net.sf.saxon.Transform -novw -l

stylesheet = ../myxml2rfc.xslt
reduction  = ../../rfc2629xslt/clean-for-DTD.xslt
bap  = ../../abnfparser/bap

TARGETS = p1-messaging.html \
          p2-semantics.html \
          p3-payload.html \
          p4-conditional.html \
          p5-range.html \
          p6-cache.html \
          p7-auth.html \
          p1-messaging.redxml \
          p2-semantics.redxml \
          p3-payload.redxml \
          p4-conditional.redxml \
          p5-range.redxml \
          p6-cache.redxml \
          p7-auth.redxml \
          p1-messaging.txt \
          p2-semantics.txt \
          p3-payload.txt \
          p4-conditional.txt \
          p5-range.txt \
          p6-cache.txt \
          p7-auth.txt \
          p1-messaging.abnf \
          p2-semantics.abnf \
          p3-payload.abnf \
          p4-conditional.abnf \
          p5-range.abnf \
          p6-cache.abnf \
          p7-auth.abnf \
          p1-messaging.parsed-abnf \
          p2-semantics.parsed-abnf \
          p3-payload.parsed-abnf \
          p4-conditional.parsed-abnf \
          p5-range.parsed-abnf \
          p6-cache.parsed-abnf \
          p7-auth.parsed-abnf \
          p1-messaging.abnf-appendix \
          p2-semantics.abnf-appendix \
          p3-payload.abnf-appendix \
          p4-conditional.abnf-appendix \
          p5-range.abnf-appendix \
          p6-cache.abnf-appendix \
          p7-auth.abnf-appendix \
          p1-messaging.iana-headers \
          p2-semantics.iana-headers \
          p2-semantics.iana-methods	\
          p2-semantics.iana-status-codes \
          p3-payload.iana-headers \
          p4-conditional.iana-headers \
          p5-range.iana-headers \
          p6-cache.iana-headers \
          p7-auth.iana-headers


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

outlineALL.html:	p1-messaging.xhtml \
	p2-semantics.xhtml \
	p3-payload.xhtml \
	p4-conditional.xhtml \
	p5-range.xhtml \
	p6-cache.xhtml \
	p7-auth.xhtml \
	extractOutline.xslt
	$(saxon) extractOutline.xslt extractOutline.xslt > $@
	rm p*.xhtml



