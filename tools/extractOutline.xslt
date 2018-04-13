<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:data="#data"               
               version="1.0"
               xmlns:xhtml="http://www.w3.org/1999/xhtml"
               exclude-result-prefixes="xhtml data"
>

<xsl:output method="html" encoding="UTF-8" version="4.0"
            doctype-public="-//W3C//DTD HTML 4.01//EN" indent="yes"/>
            
<data:specs>
  <data:name>draft-ietf-httpbis-messaging-latest</data:name>
  <data:name>draft-ietf-httpbis-semantics-latest</data:name>
  <data:name>draft-ietf-httpbis-conditional-latest</data:name>
  <data:name>draft-ietf-httpbis-range-latest</data:name>
  <data:name>draft-ietf-httpbis-cache-latest</data:name>
  <data:name>draft-ietf-httpbis-auth-latest</data:name>
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
        <div id="content">
          <h1>HTTP/1.1 Drafts: Combined Table of Contents</h1>
          <xsl:for-each select="document('')//data:specs/data:name">
            <xsl:variable name="doc" select="document(concat('../build/',.,'.xhtml'))"/>
            <h2>
              <a href="{concat(.,'.html')}">
                <xsl:value-of select="$doc//xhtml:title"/>
              </a>
            </h2>
            <xsl:apply-templates select="$doc//xhtml:nav/xhtml:ul[@class='toc']" mode="tocgen"/>
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
  <xsl:variable name="basename" select="substring-after(//xhtml:meta[@name='dcterms.identifier']/@content,'urn:ietf:id:')"/>
  <a href="{$basename}.html{@href}">
    <xsl:apply-templates mode="tocgen"/>
  </a>
</xsl:template> 

</xsl:transform>
