<xsl:transform
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0">

<xsl:output method="xml" omit-xml-declaration="yes" indent="yes"/>
  
<xsl:param name="abnf"/>  
  
<xsl:template match="/">
  <xsl:variable name="collected" select="unparsed-text($abnf)"/>

  <section title="Collected ABNF" anchor="collected.abnf">  
<figure>
  <artwork type="abnf" name="{$abnf}">
    <xsl:value-of select="$collected"/>
  </artwork>
</figure>  
  </section>

  <!-- check whether it's up2date... -->
  
  <xsl:if test="not(//section[@anchor='collected.abnf']) or //section[@anchor='collected.abnf']//artwork != $collected">
    <xsl:message>WARNING: appendix contained inside source document needs to be updated</xsl:message>
<!--    <xsl:message>A: <xsl:value-of select="//section[@anchor='collected.abnf']//artwork"/></xsl:message>
    <xsl:message>B: <xsl:value-of select="$collected"/></xsl:message>-->
  </xsl:if>
</xsl:template>
  
  
</xsl:transform>