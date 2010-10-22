<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:data="#data"               
               version="1.0"
               xmlns:xhtml="http://www.w3.org/1999/xhtml"
               exclude-result-prefixes="xhtml data"
>

<xsl:output method="html" encoding="UTF-8" version="4.0"
            doctype-public="-//W3C//DTD HTML 4.01//EN" indent="yes"/>
            
<data:specs>
  <data:name>p1-messaging</data:name>
  <data:name>p2-semantics</data:name>
  <data:name>p3-payload</data:name>
  <data:name>p4-conditional</data:name>
  <data:name>p5-range</data:name>
  <data:name>p6-cache</data:name>
  <data:name>p7-auth</data:name>
</data:specs>

<xsl:template match="/">
  <html>
    <head>
      <title>HTTP/1.1 Drafts: Combined Table of Contents</title>
      <link type="text/css" href="http://www3.tools.ietf.org/wg/httpbis/trac/chrome/common/css/trac.css" rel="stylesheet"/>
      <link type="image/x-icon" href="http://www.tools.ietf.org/ietf.ico" rel="icon"/>
      <link type="image/x-icon" href="http://www.tools.ietf.org/ietf.ico" rel="shortcut icon"/>
<style type="text/css" title="xml2rfc TOC">
ul.toc {
  list-style: none;
  margin-left: 1.5em;
  margin-right: 0em;
  margin-top: 2px;
  padding-left: 0em;
  padding-bottom: 0em;
}
li.tocline0 {
  line-height: normal;
  font-weight: normal;
  font-size: 11pt;
  margin-left: 0em;
  margin-right: 0em;
}
li.tocline1 {
  line-height: normal;
  font-weight: normal;
  font-size: 9pt;
  margin-left: 0em;
  margin-right: 0em;
}
li.tocline2 {
  font-size: 0pt;
}
#content { padding-top: 2em; position: relative }
</style>
    </head>
    <body>
      <div id="page">
        <div id="banner">
          <div id="mainnav" class="nav">
            <ul><li class="first"><a accesskey="1" href="http://www3.tools.ietf.org/wg/httpbis/trac/wiki">Wiki</a></li>
            <li><a accesskey="2" href="http://www3.tools.ietf.org/wg/httpbis/trac/timeline">Timeline</a></li>
            <li><a href="http://www3.tools.ietf.org/wg/httpbis/trac/browser">Browse Source</a></li>
            <li><a href="http://www3.tools.ietf.org/wg/httpbis/trac/report">View Tickets</a></li>
            <li class="active"><a href="outlineALL.html">Outline Parts</a></li>
            <li><a href="outline2616.html">Outline 2616</a></li>
            <li class="last"><a href="http://lists.w3.org/Archives/Public/ietf-http-wg/">Mail Archive</a></li>
            </ul>
          </div>
        </div>
        <div id="content">
          <h1>HTTP/1.1 Drafts: Combined Table of Contents</h1>
          <xsl:for-each select="document('')//data:specs/data:name">
            <xsl:variable name="doc" select="document(concat(.,'.xhtml'))"/>
            <h2>
              <a href="{concat(.,'.html')}">
                <xsl:value-of select="$doc//xhtml:title"/>
              </a>
            </h2>
            <xsl:apply-templates select="$doc//xhtml:body/xhtml:ul[@class='toc']" mode="tocgen"/>
          </xsl:for-each>
        </div>
      </div>
    </body>
  </html>
</xsl:template>

<xsl:template match="xhtml:ul" mode="tocgen">
  <ul class="{@class}">
    <xsl:apply-templates mode="tocgen"/>
  </ul>
</xsl:template> 

<xsl:template match="xhtml:li" mode="tocgen">
  <li class="{@class}">
    <xsl:apply-templates mode="tocgen"/>
  </li>
</xsl:template> 

<xsl:template match="xhtml:a" mode="tocgen">
  <xsl:variable name="basename" select="substring-after(//xhtml:meta[@name='DC.Identifier']/@content,'urn:ietf:id:')"/>
  <a href="{concat(substring-before(substring-after($basename,'draft-ietf-httpbis-'),'-latest'),'.html')}{@href}">
    <xsl:apply-templates mode="tocgen"/>
  </a>
</xsl:template> 

</xsl:transform>