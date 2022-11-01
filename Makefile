xml2rfc = xml2rfc
saxpath = lib/saxon.jar
saxon = java -classpath $(saxpath) net.sf.saxon.Transform -l -versionmsg:off

rfcdiff = rfcdiff --width 78 --stdout
stylesheet = lib/myxml2rfc.xslt
reduction  = lib/clean-for-xml2rfc-v3.xslt
xreffer    = lib/xreffer.xslt
bap = bap
bd  = build

VPATH = build
GPATH = build

draftname = draft-ietf-httpbis

CACHE       = $(draftname)-cache-latest
MESSAGING   = $(draftname)-messaging-latest
SEMANTICS   = $(draftname)-semantics-latest

TARGETS_XML = $(MESSAGING).xml \
              $(SEMANTICS).xml \
              $(CACHE).xml \
              rfc9110.xml rfc9111.xml rfc9112.xml

TARGETS_TXT= $(TARGETS_XML:.xml=.txt)
TARGETS_HTML= $(TARGETS_XML:.xml=.html)
TARGETS_XHTML= $(addprefix $(bd)/,$(TARGETS_XML:.xml=.xhtml))
TARGETS_REDXML= $(addprefix $(bd)/,$(TARGETS_XML:.xml=.redxml))

TARGETS_ABNF = $(bd)/$(MESSAGING).abnf \
               $(bd)/$(SEMANTICS).abnf \
               $(bd)/$(CACHE).abnf
TARGETS_ABNFAPPENDIX= $(TARGETS_ABNF:.abnf=.abnf-appendix)
TARGETS_PARSEDABNF= $(TARGETS_ABNF:.abnf=.parsed-abnf)

TARGETS = $(TARGETS_HTML) \
          $(TARGETS_REDXML) \
          $(TARGETS_TXT) \
          $(TARGETS_ABNF) \
          $(TARGETS_PARSEDABNF) \
          $(TARGETS_ABNFAPPENDIX) \
          $(bd)/$(MESSAGING).iana-headers \
          $(bd)/$(SEMANTICS).iana-headers \
          $(bd)/$(SEMANTICS).iana-methods	\
          $(bd)/$(SEMANTICS).iana-status-codes \
          $(bd)/$(CACHE).iana-headers \
          $(bd)/$(CACHE).cache-directives \
          httpbis-errata-status.html \
          httpbis.abnf

all: $(TARGETS)

ci: $(TARGETS_HTML) $(bd)/$(MESSAGING).iana-headers \
          $(bd)/$(SEMANTICS).iana-headers \
          $(bd)/$(SEMANTICS).iana-methods	\
          $(bd)/$(SEMANTICS).iana-status-codes \
          $(bd)/$(CACHE).iana-headers \
          $(bd)/$(CACHE).cache-directives

clean:
	rm -f $(TARGETS)

diff:
	$(rfcdiff) diffs/frankenRFC723x_sem.txt $(SEMANTICS).txt  | \
          egrep -v -- '^<\!-- ' > diffs/diff_semantics.html
	$(rfcdiff) diffs/frankenRFC723x_msg.txt $(MESSAGING).txt  | \
          egrep -v -- '^<\!-- ' > diffs/diff_messaging.html
	$(rfcdiff) diffs/frankenRFC723x_cache.txt $(CACHE).txt  | \
          egrep -v -- '^<\!-- ' > diffs/diff_cache.html

diff00:
	$(rfcdiff) 00/$(draftname)-messaging-00.txt $(MESSAGING).txt | \
          egrep -v -- '^<\!-- ' > diffs/diff_messaging_since_00.html
	$(rfcdiff) 00/$(draftname)-semantics-00.txt $(SEMANTICS).txt | \
          egrep -v -- '^<\!-- ' > diffs/diff_semantics_since_00.html
	$(rfcdiff) 00/$(draftname)-conditional-00.txt $(CONDITIONAL).txt | \
          egrep -v -- '^<\!-- ' > diffs/diff_conditional_since_00.html
	$(rfcdiff) 00/$(draftname)-range-00.txt $(RANGE).txt | \
          egrep -v -- '^<\!-- ' > diffs/diff_range_since_00.html
	$(rfcdiff) 00/$(draftname)-cache-00.txt $(CACHE).txt | \
          egrep -v -- '^<\!-- ' > diffs/diff_cache_since_00.html
	$(rfcdiff) 00/$(draftname)-auth-00.txt $(AUTH).txt | \
          egrep -v -- '^<\!-- ' > diffs/diff_auth_since_00.html

%.html: %.xml $(stylesheet)
	$(saxon) $< $(xreffer) | $(saxon) -now:$(shell date -r $< -u +%Y-%m-%dT%H:%M:%SZ) - $(stylesheet) xml2rfc-ext-maxwidth=700 xml2rfc-ext-styles="ff-noto ffb-sans-serif fft-sans-serif header-bw" xml2rfc-ext-paragraph-links=yes xml2rfc-ext-abort-on=ERROR | awk -f lib/html5doctype.awk > $@

$(bd)/%.redxml: %.xml $(reduction)
	$(saxon) $< $(xreffer) | $(saxon) - $(reduction) > $@

%.txt: $(bd)/%.redxml
	$(xml2rfc) --v3 --legacy-list-symbols --legacy-date-format --table-borders=minimal --bom $< -o $@

$(bd)/%.abnf: %.xml lib/extract-artwork.xslt
	$(saxon) $< lib/xreffer.xslt | $(saxon) - lib/extract-artwork.xslt type="abnf7230" >$@

$(bd)/%.parsed-abnf: $(bd)/%.abnf
	$(bap)/bap -i $(bap)/core.abnf -L2 -X rfc7405 < $< | LC_COLLATE=C sort | $(bap)/bap -k -i $(bap)/core.abnf -X rfc7405 -l 69 >$@

$(bd)/%.abnf-appendix: $(bd)/%.parsed-abnf
	$(saxon) $*.xml lib/abnf2xml2rfc.xslt abnf="../$<" >$@

$(bd)/%.xhtml: %.xml lib/rfc2629toXHTML.xslt
	$(saxon) $< lib/xreffer.xslt | $(saxon) - lib/rfc2629toXHTML.xslt > $@

$(bd)/%.iana-headers: %.xml lib/extract-header-defs.xslt
	$(saxon) $< lib/extract-header-defs.xslt > $@

$(bd)/%.iana-methods: %.xml lib/extract-method-defs.xslt
	$(saxon) $< lib/extract-method-defs.xslt > $@

$(bd)/%.iana-status-codes: %.xml lib/extract-status-code-defs.xslt
	$(saxon) $< lib/extract-status-code-defs.xslt > $@

$(bd)/%.cache-directives: %.xml lib/extract-cache-directives.xslt
	$(saxon) $< lib/extract-cache-directives.xslt > $@

outlineALL.html: $(TARGETS_XHTML) lib/extractOutline.xslt
	$(saxon) lib/extractOutline.xslt lib/extractOutline.xslt > $@

httpbis.abnf: $(TARGETS_ABNF)
	lib/common-abnf.sh $^ > $@

saxonjar:
	[ -f lib/saxon.jar ] || curl https://repo1.maven.org/maven2/net/sf/saxon/Saxon-HE/10.8/Saxon-HE-10.8.jar -o lib/saxon.jar

consistency.txt: $(TARGETS_XML)
	rm -f $@
	echo P1 >> $@
	echo >> $@
	saxon $(MESSAGING).xml lib/consistency-check.xslt >> $@
	echo >> $@
	echo P2 >> $@
	echo >> $@
	saxon $(SEMANTICS).xml lib/consistency-check.xslt >> $@
	echo >> $@
	echo P4 >> $@
	echo >> $@
	saxon $(CONDITIONAL).xml lib/consistency-check.xslt >> $@
	echo >> $@
	echo P5 >> $@
	echo >> $@
	saxon $(RANGE).xml lib/consistency-check.xslt >> $@
	echo >> $@
	echo P6 >> $@
	echo >> $@
	saxon $(CACHE).xml lib/consistency-check.xslt >> $@
	echo >> $@
	echo P7 >> $@
	echo >> $@
	saxon $(AUTH).xml lib/consistency-check.xslt >> $@
	echo >> $@

removetrailingwhitespace:
	sed -i 's/[[:space:]]*$$//' $(CACHE).xml
	sed -i 's/[[:space:]]*$$//' $(MESSAGING).xml
	sed -i 's/[[:space:]]*$$//' $(SEMANTICS).xml

