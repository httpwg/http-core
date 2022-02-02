<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:x="http://purl.org/net/xml2rfc/ext"
               xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#'
               version="1.0"
               xmlns:my="#my"
               exclude-result-prefixes="rdf x"
>

<xsl:output method="text"/>

<xsl:variable name="p2" select="document('p2-semantics.xml')"/>

<xsl:template match="/">
  <xsl:text>Header Field Categories</xsl:text>
  <xsl:text>&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>
  <xsl:apply-templates select="//section[iref[contains(@item,' header field') and @primary='true']]">
    <xsl:sort select="iref[contains(@item,' header field') and @primary='true']/@item"/>
  </xsl:apply-templates>
  <xsl:text>&#10;</xsl:text>
  <xsl:text>&#10;</xsl:text>
</xsl:template>

<xsl:template match="section">
  <xsl:variable name="name" select="@title"/>

  <xsl:value-of select="$name"/>
  <xsl:text>&#10;</xsl:text>
  
  <xsl:variable name="cat" select="$p2//section[texttable[ttcol='Defined in...' and c=$name]]"/>
  <xsl:choose>
    <xsl:when test="$cat">
      <xsl:for-each select="$cat">
        <xsl:text>-> </xsl:text>
        <xsl:value-of select="@title"/>
        <xsl:text>&#10;</xsl:text>
      </xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>No category found in P2</xsl:text>
      <xsl:text>&#10;</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
  
  <xsl:text>&#10;</xsl:text>
</xsl:template>

</xsl:transform>