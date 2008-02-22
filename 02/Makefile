xml2rfc = "$(HOME)/bin/xml2rfc-1.33pre4/xml2rfc.tcl"
saxpath = "$(HOME)/java/saxon-8-9-j/saxon8.jar"
saxon = java -classpath $(saxpath) net.sf.saxon.Transform -novw

stylesheet = ../myxml2rfc.xslt
reduction  = ../../rfc2629xslt/clean-for-DTD.xslt

TARGETS = p1-messaging.html \
          p2-semantics.html \
          p3-payload.html \
          p4-conditional.html \
          p5-range.html \
          p6-cache.html \
          p7-auth.html \
          p8-cookies.html \
          p1-messaging.redxml \
          p2-semantics.redxml \
          p3-payload.redxml \
          p4-conditional.redxml \
          p5-range.redxml \
          p6-cache.redxml \
          p7-auth.redxml \
          p8-cookies.redxml \
          p1-messaging.txt \
          p2-semantics.txt \
          p3-payload.txt \
          p4-conditional.txt \
          p5-range.txt \
          p6-cache.txt \
          p7-auth.txt \
          p8-cookies.txt

all: $(TARGETS)

clean:
	rm -f $(TARGETS)

%.html: %.xml $(stylesheet)
	$(saxon) $< $(stylesheet) > $@

%.redxml: %.xml $(reduction)
	$(saxon) $< $(reduction) > $@

%.txt: %.redxml
	$(xml2rfc) $< $@

%.xhtml: %.xml ../../rfc2629xslt/rfc2629toXHTML.xslt
	$(saxon) $< ../../rfc2629xslt/rfc2629toXHTML.xslt > $@

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



