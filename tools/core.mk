
rfcdiff = rfcdiff --width 78 --stdout
reduction  = $(tools)/clean-for-DTD.xslt
bap = $(tools)/bap
bd  = build

draftname = draft-ietf-httpbis

AUTH        = $(draftname)-auth
CACHE       = $(draftname)-cache
CONDITIONAL = $(draftname)-conditional
MESSAGING   = $(draftname)-messaging
RANGE       = $(draftname)-range
SEMANTICS   = $(draftname)-semantics

TARGETS_ABNF= $(addprefix $(bd)/,$(drafts_xml:.xml=.abnf))
TARGETS_ABNFAPPENDIX= $(TARGETS_ABNF:.abnf=.abnf-appendix)
TARGETS_PARSEDABNF= $(TARGETS_ABNF:.abnf=.parsed-abnf)

ABNF =    $(TARGETS_ABNF) \
          $(TARGETS_PARSEDABNF) \
          $(TARGETS_ABNFAPPENDIX) \
          $(bd)/$(MESSAGING).iana-headers \
          $(bd)/$(SEMANTICS).iana-headers \
          $(bd)/$(SEMANTICS).iana-methods	\
          $(bd)/$(SEMANTICS).iana-status-codes \
          $(bd)/$(CONDITIONAL).iana-headers \
          $(bd)/$(CONDITIONAL).iana-status-codes \
          $(bd)/$(RANGE).iana-headers \
          $(bd)/$(RANGE).iana-status-codes \
          $(bd)/$(CACHE).iana-headers \
          $(bd)/$(CACHE).iana-warn-codes \
          $(bd)/$(CACHE).cache-directives \
          $(bd)/$(AUTH).iana-headers \
          $(bd)/$(AUTH).iana-status-codes \
          httpbis.abnf

clean::
	rm -f $(ABNF)

$(bap)/bap:
	cd $(bap); sh configure
	cd $(bap); make

.PHONY: abnf
abnf: $(ABNF)

$(bd)/%.abnf: %.xml $(tools)/extract-artwork.xslt
	$(saxon) $< $(xreffer) | $(saxon) - $(tools)/extract-artwork.xslt type="abnf2616" >$@

$(bd)/%.parsed-abnf: $(bd)/%.abnf $(bap)/bap
	$(bap)/bap -i $(bap)/core.abnf < $< | LC_COLLATE=C sort | $(bap)/bap -k -i $(bap)/core.abnf -l 69 >$@

$(bd)/%.abnf-appendix: $(bd)/%.parsed-abnf
	$(saxon) $*.xml $(bd)/abnf2xml2rfc.xslt abnf="$*.parsed-abnf" >$@

$(bd)/%.xhtml: %.xml $(tools)/rfc2629toXHTML.xslt
	$(saxon) $< $(tools)/rfc2629toXHTML.xslt > $@

$(bd)/%.iana-headers: %.xml $(tools)/extract-header-defs.xslt
	$(saxon) $< $(tools)/extract-header-defs.xslt > $@

$(bd)/%.iana-methods: %.xml $(tools)/extract-method-defs.xslt
	$(saxon) $< $(tools)/extract-method-defs.xslt > $@

$(bd)/%.iana-status-codes: %.xml $(tools)/extract-status-code-defs.xslt
	$(saxon) $< $(tools)/extract-status-code-defs.xslt > $@

$(bd)/%.iana-warn-codes: %.xml $(tools)/extract-warn-code-defs.xslt
	$(saxon) $< $(tools)/extract-warn-code-defs.xslt > $@

$(bd)/%.cache-directives: %.xml $(tools)/extract-cache-directives.xslt
	$(saxon) $< $(tools)/extract-cache-directives.xslt > $@

outlineALL.html: $(TARGETS_XHTML) $(tools)/extractOutline.xslt
	$(saxon) $(tools)/extractOutline.xslt $(tools)/extractOutline.xslt > $@

httpbis.abnf: $(TARGETS_ABNF)
	$(tools)/common-abnf.sh $^ > $@

consistency.txt: $(TARGETS_XML)
	rm -f $@
	echo P1 >> $@
	echo >> $@
	saxon $(MESSAGING).xml $(tools)/consistency-check.xslt >> $@
	echo >> $@
	echo P2 >> $@
	echo >> $@
	saxon $(SEMANTICS).xml $(tools)/consistency-check.xslt >> $@
	echo >> $@
	echo P4 >> $@
	echo >> $@
	saxon $(CONDITIONAL).xml $(tools)/consistency-check.xslt >> $@
	echo >> $@
	echo P5 >> $@
	echo >> $@
	saxon $(RANGE).xml $(tools)/consistency-check.xslt >> $@
	echo >> $@
	echo P6 >> $@
	echo >> $@
	saxon $(CACHE).xml $(tools)/consistency-check.xslt >> $@
	echo >> $@
	echo P7 >> $@
	echo >> $@
	saxon $(AUTH).xml $(tools)/consistency-check.xslt >> $@
	echo >> $@

