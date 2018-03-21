xml2rfc = "$(HOME)/bin/xml2rfc-1.33pre4/xml2rfc.tcl"
saxpath = "$(HOME)/java/saxon-8-9-j/saxon8.jar"
saxon = java -classpath $(saxpath) net.sf.saxon.Transform -novw

stylesheet = ../myxml2rfc.xslt
reduction  = ../../rfc2629xslt/clean-for-DTD.xslt

TARGETS = rfc2145.html rfc2616.html rfc2617.html rfc2817.html rfc2818.html rfc2965.html rfc4234.html rfc5234.html \
          rfc2616-symrefs.html rfc6266.html

all: $(TARGETS)

clean:
	rm -f $(TARGETS)

%.html: %.xml $(stylesheet)
	$(saxon) $< $(stylesheet) > $@

%.redxml: %.xml $(reduction)
	$(saxon) $< $(reduction) > $@

%.txt: %.redxml
	$(xml2rfc) $< $@

