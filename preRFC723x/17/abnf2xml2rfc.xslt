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

  <xsl:variable name="all-lines" as="xs:string*" select="tokenize($collected, '\r?\n')"/>
  <xsl:variable name="lines" select="$all-lines[normalize-space(.)!='']"/>
  
  <section title="Collected ABNF" anchor="collected.abnf">
    <xsl:text>&#10;</xsl:text>
    <figure>
      <xsl:text>&#10;</xsl:text>
      <artwork type="abnf" name="{$abnf}">
        <xsl:for-each select="$lines[substring(.,1,2)!='; ']">
        
          <!-- Group by start character -->
          <xsl:variable name="lineno" select="position()"/>
          <xsl:variable name="sc1" select="substring(.,1,1)"/>
          <xsl:variable name="sc0" select="x:laststartchar($lines, $lineno - 1)"/>
          <xsl:if test="$sc1!=' ' and $sc0!=' ' and $sc1!=$sc0">
            <xsl:text>&#10;</xsl:text>
          </xsl:if>

          <!-- Add cross-refs for terms -->
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
    
    <figure>
      <preamble>ABNF diagnostics:</preamble>
      <artwork type="inline">
        <xsl:text>&#10;</xsl:text>
        <xsl:for-each select="$lines[substring(.,1,2)='; ']">
          <xsl:value-of select="."/>
          <xsl:text>&#10;</xsl:text>
        </xsl:for-each>
    </artwork></figure>
  </section>

  <!-- check whether it's up-to-date... -->
  <xsl:variable name="src">
    <xsl:for-each select="//section[@anchor='collected.abnf']//artwork">
      <xsl:value-of select="."/>
    </xsl:for-each>
  </xsl:variable>
  
  <xsl:if test="not(//section[@anchor='collected.abnf']) or normalize-space($src) != normalize-space($collected)">
    <xsl:message>WARNING: appendix contained inside source document needs to be updated</xsl:message>
    <!--<xsl:message>A: <xsl:value-of select="//section[@anchor='collected.abnf']//artwork"/></xsl:message>
    <xsl:message>B: <xsl:value-of select="$collected"/></xsl:message>-->
  </xsl:if>
</xsl:template>

<xsl:function name="x:laststartchar">
  <xsl:param name="lines"/>
  <xsl:param name="position"/>
  
  <xsl:choose>
    <xsl:when test="' '!=substring($lines[$position],1,1)">
      <xsl:value-of select="substring($lines[$position],1,1)"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="x:laststartchar($lines, $position - 1)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>
  
  
</xsl:transform>