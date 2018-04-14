saxpath = "$(HOME)/java/saxon-9-7/saxon9he.jar"
saxon = java -classpath $(saxpath) net.sf.saxon.Transform -l -versionmsg:off -ext:on
tools = tools

xreffer    = $(tools)/xreffer.xslt
stylesheet = $(tools)/myxml2rfc.xslt

clean::
	rm -f diff*.html

%.cleanxml: %.xml $(tools)/clean-for-DTD.xslt abnf
	$(saxon) $< $(xreffer) | $(saxon) - $(tools)/clean-for-DTD.xslt > $@

%.htmltmp: %.xml $(stylesheet) abnf
	$(saxon) $< $(xreffer) | $(saxon) - $(stylesheet) | awk -f $(tools)/html5doctype.awk > $@
