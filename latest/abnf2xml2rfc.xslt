<xsl:transform
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:x="http://purl.org/net/xml2rfc/ext"
  version="2.0"
  exclude-result-prefixes="xs">

<xsl:output method="xml" omit-xml-declaration="yes" indent="no"/>

<xsl:param name="abnf"/>  
  
<xsl:template match="/">
  <xsl:variable name="src" select="."/>
  <xsl:variable name="collected" select="unparsed-text($abnf)"/>

  <xsl:variable name="lines" as="xs:string*" select="tokenize($collected, '\r?\n')"/>
  
  <section title="Collected ABNF" anchor="collected.abnf">
    <xsl:text>&#10;</xsl:text>
    <figure>
      <xsl:text>&#10;</xsl:text>
      <artwork type="abnf" name="{$abnf}">
        <xsl:for-each select="$lines">
          <xsl:variable name="lineno" select="position()"/>
          <xsl:variable name="sc1" select="substring(.,1,1)"/>
          <xsl:variable name="sc0" select="substring($lines[$lineno - 1],1,1)"/>
          <xsl:if test="$sc1!=' ' and $sc0!=' ' and $sc1!=$sc0">
            <xsl:text>&#10;</xsl:text>
          </xsl:if>
          <xsl:analyze-string select="." regex='^([A-Za-z0-9\-]+) = ' flags="sm">
            <xsl:matching-substring>
              <xsl:variable name="term" select="regex-group(1)"/>
              <xsl:choose>
                <xsl:when test="$src//*[@anchor=$term] or $src//x:anchor-alias[@value=$term]">
                  <x:ref><xsl:value-of select="$term"/></x:ref>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$term"/>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:text> = </xsl:text>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
              <xsl:value-of select="."/>
            </xsl:non-matching-substring>
          </xsl:analyze-string>
          <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
      </artwork>
      <xsl:text>&#10;</xsl:text>
    </figure>  
    <xsl:text>&#10;</xsl:text>
  </section>

  <!-- check whether it's up-to-date... -->
  
  <xsl:if test="not(//section[@anchor='collected.abnf']) or normalize-space(//section[@anchor='collected.abnf']//artwork) != normalize-space($collected)">
    <xsl:message>WARNING: appendix contained inside source document needs to be updated</xsl:message>
    <!--<xsl:message>A: <xsl:value-of select="//section[@anchor='collected.abnf']//artwork"/></xsl:message>
    <xsl:message>B: <xsl:value-of select="$collected"/></xsl:message>-->
  </xsl:if>
</xsl:template>
  
  
</xsl:transform>