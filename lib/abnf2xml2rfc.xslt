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
  
  <xsl:variable name="generated"><section title="Collected ABNF" anchor="collected.abnf">
    <t>
      <xsl:choose>
        <xsl:when test="not(starts-with(/rfc/@docName,'draft-ietf-httpbis-semantics'))">In the collected ABNF below, list rules are expanded as per <xref target='SEMANTICS' x:rel='#abnf.extension.sender'/>.</xsl:when>
        <xsl:otherwise>In the collected ABNF below, list rules are expanded as per <xref target="abnf.extension.sender"/>.</xsl:otherwise>
      </xsl:choose>
    </t>
    <sourcecode type="abnf" name="{x:basename($abnf)}">
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
              <xsl:when test="$src//*[@anchor=$term] or $src//x:anchor-alias[@value=$term] or $src//x:defines=$term">
                <x:ref><xsl:value-of select="$term"/></x:ref>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$term"/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:text> = </xsl:text>
          </xsl:matching-substring>
          <xsl:non-matching-substring>
            <xsl:analyze-string select="." regex='(.*) see \[([A-Za-z0-9\-]+)\], Section ([A-Za-z0-9\.]+)>' flags="sm">
              <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:text> see </xsl:text>
                <xref target="{regex-group(2)}" x:fmt="," x:sec="{regex-group(3)}"/>
                <xsl:text>&gt;</xsl:text>
              </xsl:matching-substring>
              <xsl:non-matching-substring>
                <xsl:value-of select="."/>
              </xsl:non-matching-substring>
            </xsl:analyze-string>
          </xsl:non-matching-substring>
        </xsl:analyze-string>
        <xsl:text>&#10;</xsl:text>
      </xsl:for-each>
    </sourcecode>
    <xsl:text>&#10;</xsl:text>
    
    <xsl:variable name="diags">
      <xsl:for-each select="$lines[substring(.,1,2)='; ']">
        <xsl:variable name="prod" select="substring-before(substring-after(.,'; '),' defined but not used')"/>
        <xsl:choose>
          <xsl:when test="$prod!='' and $src//iref[@item='Header Fields' and @subitem=$prod]">
            <!-- header field; expected not to be reference -->
          </xsl:when>
          <xsl:when test="$prod!='' and $src//iref[@item='Grammar' and @subitem=$prod and comment()='terminal production']">
            <!-- known to be a terminal production -->
          </xsl:when>
          <xsl:when test="$prod!='' and $src//iref[@item='Grammar' and @subitem=$prod and comment()='exported production']">
            <!-- known to be used in another part -->
          </xsl:when>
          <xsl:when test="$prod!='' and $src//iref[@item='Grammar' and @subitem=$prod and comment()='unused production']">
            <!-- known to be unused, but we want to include it anyway -->
          </xsl:when>
          <xsl:when test="$prod!='' and $src//x:ref=$prod">
            <!-- referenced otherwise -->
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="."/>
            <xsl:text>&#10;</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>
    
    <xsl:if test="$diags!=''">
      <figure>
        <preamble>ABNF diagnostics:</preamble>
        <artwork type="inline">
          <xsl:text>&#10;</xsl:text>
          <xsl:value-of select="$diags"/>
      </artwork></figure>
    </xsl:if>
  </section></xsl:variable>

  <xsl:copy-of select="$generated"/>

  <!-- check whether it's up-to-date... -->
  <xsl:variable name="src">
    <xsl:for-each select="//section[@anchor='collected.abnf']//sourcecode">
      <xsl:value-of select="."/>
    </xsl:for-each>
  </xsl:variable>
  
  <xsl:variable name="new">
    <xsl:value-of select="$generated//sourcecode"/>
  </xsl:variable>
  
  <xsl:if test="not(//section[@anchor='collected.abnf']) or normalize-space($src) != normalize-space($new)">
    <xsl:message>WARNING: appendix contained inside source document needs to be updated</xsl:message>
    <xsl:call-template name="showdiff">
      <xsl:with-param name="actual" select="normalize-space($src)"/>
      <xsl:with-param name="expected" select="normalize-space($new)"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template name="showdiff">
  <xsl:param name="actual"/>
  <xsl:param name="expected"/>
  <xsl:param name="prev"/>
  
  <xsl:choose>
    <xsl:when test="$actual=''">
      <!-- done -->
    </xsl:when>
    <xsl:when test="substring($actual,1,1)=substring($expected,1,1)">
      <xsl:call-template name="showdiff">
        <xsl:with-param name="actual" select="substring($actual,2)"/>
        <xsl:with-param name="expected" select="substring($expected,2)"/>
        <xsl:with-param name="prev" select="concat($prev,substring($actual,1,1))"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message>WARNING: at position <xsl:value-of select="string-length($prev)"/></xsl:message>
      <xsl:message>WARNING: prefix <xsl:value-of select="$prev"/></xsl:message>
      <xsl:message>WARNING: actual text is: '<xsl:value-of select="substring($actual,1,20)"/>...' expected was: '<xsl:value-of select="substring($expected,1,20)"/>...'</xsl:message>
    </xsl:otherwise>
  </xsl:choose>
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
  
<xsl:function name="x:basename">
  <xsl:param name="s"/>

  <xsl:choose>
    <xsl:when test="not(contains($s,'/'))">
      <xsl:value-of select="$s"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="x:basename(substring-after($s,'/'))"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:function>
  
</xsl:transform>
