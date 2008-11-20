<xsl:transform
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="2.0">

<xsl:output method="xml" omit-xml-declaration="yes" indent="yes"/>
  
<xsl:param name="abnf"/>  
  
<xsl:template match="/">
  <section title="Collected ABNF" anchor="collected.abnf">

<figure>
  <artwork type="abnf" name="{$abnf}">
    <xsl:text>&#10;</xsl:text>
    <xsl:value-of select="unparsed-text($abnf)"/>
  </artwork>
</figure>  

  </section>
</xsl:template>
  
  
</xsl:transform>