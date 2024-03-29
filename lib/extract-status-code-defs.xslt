<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:x="http://purl.org/net/xml2rfc/ext"
               xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#'
               version="1.0"
               exclude-result-prefixes="rdf x"
>

<xsl:output indent="yes" omit-xml-declaration="yes"/>

<xsl:template match="/">
  <xsl:variable name="table">
    <table anchor="iana.status.code.registration.table">
      <thead>
        <tr>
          <th>Value</th>
          <th>Description</th>
          <th>Section</th>
        </tr>
      </thead>
      <tbody>
        <xsl:apply-templates select="//section[iref[contains(@item,' (status code)') and @primary='true']]">
          <xsl:sort select="iref[contains(@item,' (status code)') and @primary='true']/@item"/>
        </xsl:apply-templates>
      </tbody>
    </table>
    <xsl:text>&#10;</xsl:text>
  </xsl:variable>

  <xsl:comment>AUTOGENERATED FROM extract-status-code-defs.xslt, do not edit manually</xsl:comment>
  <xsl:text>&#10;</xsl:text>
  <xsl:copy-of select="$table"/>
  <xsl:comment>(END)</xsl:comment>
  <xsl:text>&#10;</xsl:text>

  <!-- check against current version -->
  <xsl:variable name="oldtable" select="//table[@anchor='iana.status.code.registration.table']" />

  <xsl:variable name="s">
    <xsl:apply-templates select="$table//table" mode="tostring"/>
  </xsl:variable>
  
  <xsl:variable name="s1">
    <xsl:apply-templates select="$oldtable" mode="tostring"/>
  </xsl:variable>

  <xsl:if test="$s != $s1">
    <xsl:message>WARNING: table contained inside source document needs to be updated</xsl:message>
    <xsl:message><xsl:value-of select="$s"/></xsl:message>
    <xsl:message><xsl:value-of select="$s1"/></xsl:message>
  </xsl:if>

</xsl:template>

<xsl:template match="*" mode="tostring">
  <xsl:text>&lt;</xsl:text>
  <xsl:value-of select="name()"/>
  <xsl:for-each select="@*">
    <xsl:sort select="name()"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:text>=</xsl:text>
    <xsl:value-of select="."/>
  </xsl:for-each>
  <xsl:text>&gt;</xsl:text>
  
  <xsl:apply-templates select="node()" mode="tostring"/>
  
  <xsl:text>&lt;/</xsl:text>
  <xsl:value-of select="name()"/>
  <xsl:text>&gt;</xsl:text>

</xsl:template>

<xsl:template match="text()" mode="tostring">
  <xsl:value-of select="."/>
</xsl:template>

<xsl:template match="table/text()" mode="tostring"/>
<xsl:template match="tr/text()" mode="tostring"/>
<xsl:template match="thead/text()" mode="tostring"/>
<xsl:template match="tbody/text()" mode="tostring"/>
<xsl:template match="td[xref]/text()" mode="tostring"/>

<xsl:template match="section">
  <xsl:variable name="t" select="iref[contains(@item,'(status code)')]/@item"/>
  <xsl:variable name="text" select="substring-before($t,' (status code)')"/>
  <xsl:variable name="redirects-to-other-part" xmlns:p2="urn:ietf:id:draft-ietf-httpbis-p2-semantics#" select="rdf:Description/p2:redirects-to"/>

  <xsl:if test="not($redirects-to-other-part)">
    <xsl:text>&#10;</xsl:text>
    <tr>
      <td><xsl:value-of select="substring-before($text,' ')"/></td>
      <td><xsl:value-of select="substring($text,2+string-length(substring-before($text,' ')))"/></td>
      <td><xref target="{@anchor}" format="counter"/></td>
    </tr>
  </xsl:if>
</xsl:template>

</xsl:transform>