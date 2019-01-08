<!--
    Strip rfc2629.xslt extensions, generating XML input for "official" xml2rfc

    Copyright (c) 2006-2019, Julian Reschke (julian.reschke@greenbytes.de)
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice,
      this list of conditions and the following disclaimer in the documentation
      and/or other materials provided with the distribution.
    * Neither the name of Julian Reschke nor the names of its contributors
      may be used to endorse or promote products derived from this software
      without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
    AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
    IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
    ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
    LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
    CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
    SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
    INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
    CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
    ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
-->

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0"
                xmlns:exslt="http://exslt.org/common"
                xmlns:ed="http://greenbytes.de/2002/rfcedit"
                xmlns:grddl="http://www.w3.org/2003/g/data-view#"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:svg="http://www.w3.org/2000/svg"
                xmlns:x="http://purl.org/net/xml2rfc/ext"
                xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="ed exslt grddl rdf svg x xi xhtml"
>

<!-- re-use some of the default RFC2629.xslt rules -->
<xsl:import href="rfc2629.xslt"/>

<!-- undo strip-space decls -->
<xsl:preserve-space elements="*"/>

<!-- generate DTD-valid output, override all values imported from rfc2629.xslt -->
<xsl:output doctype-system="rfc2629.dtd" doctype-public="" method="xml" version="1.0" encoding="UTF-8" cdata-section-elements="artwork sourcecode" />

<!-- Workaround for http://trac.tools.ietf.org/tools/xml2rfc/trac/ticket/297 -->
<xsl:param name="xml2rfc-ext-strip-vbare">false</xsl:param>

<!-- xml2rfc target -->
<xsl:param name="xml2rfc-ext-xml2rfc-backend">
  <xsl:variable name="default">
    <xsl:choose>
      <xsl:when test="$pub-yearmonth &gt;= 201705">201706</xsl:when>
      <xsl:when test="$pub-yearmonth &gt; 201612">201610</xsl:when>
      <xsl:otherwise>201510</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:call-template name="parse-pis">
    <xsl:with-param name="nodes" select="/processing-instruction('rfc-ext')"/>
    <xsl:with-param name="attr" select="'xml2rfc-backend'"/>
    <xsl:with-param name="default" select="$default"/>
  </xsl:call-template>
</xsl:param>

<!-- kick into cleanup mode -->
<xsl:template match="/">
  <xsl:text>&#10;</xsl:text>
  <xsl:comment>
    This XML document is the output of clean-for-DTD.xslt; a tool that strips
    extensions to RFC 7749 from documents for processing with xml2rfc.
</xsl:comment>
<xsl:text>&#10;</xsl:text>
<xsl:comment>TARGET-GENERATOR: <xsl:value-of select="$xml2rfc-ext-xml2rfc-backend"/></xsl:comment>
  <xsl:apply-templates select="/" mode="cleanup"/>
</xsl:template>

<!-- rules for identity transformations -->

<xsl:template match="processing-instruction()" mode="cleanup">
  <xsl:text>&#10;</xsl:text>
  <xsl:copy/>
</xsl:template>

<xsl:template match="comment()|@*" mode="cleanup"><xsl:copy/></xsl:template>

<xsl:template match="text()" mode="cleanup"><xsl:copy/></xsl:template>

<xsl:template match="/" mode="cleanup">
	<xsl:copy><xsl:apply-templates select="node()" mode="cleanup" /></xsl:copy>
</xsl:template>

<xsl:template match="*" mode="cleanup">
  <xsl:element name="{local-name()}">
  	<xsl:apply-templates select="node()|@*" mode="cleanup" />
  </xsl:element>
</xsl:template>


<!-- remove PI extensions -->

<xsl:template match="processing-instruction('rfc-ext')" mode="cleanup"/>
<xsl:template match="processing-instruction('BEGININC')" mode="cleanup"/>
<xsl:template match="processing-instruction('ENDINC')" mode="cleanup"/>

<!-- process include PI -->
<xsl:template match="processing-instruction('rfc')" mode="cleanup">
  <xsl:variable name="include">
    <xsl:call-template name="parse-pis">
      <xsl:with-param name="nodes" select="."/>
      <xsl:with-param name="attr" select="'include'"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="$include=''">
      <xsl:text>&#10;</xsl:text>
      <xsl:copy/>
    </xsl:when>
    <xsl:when test="substring($include, string-length($include) - 3) != '.xml'">
      <xsl:copy-of select="document(concat($include,'.xml'))"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="document($include)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- add issues appendix -->

<xsl:template match="back" mode="cleanup">
  <back>
    <xsl:apply-templates select="node()|@*" mode="cleanup" />
    <xsl:if test="not(/*/@ed:suppress-issue-appendix='yes') and //ed:issue[@status='closed']">
      <section title="Resolved issues (to be removed by RFC Editor before publication)">
        <t>
          Issues that were either rejected or resolved in this version of this
          document.
        </t>
        <xsl:apply-templates select="//ed:issue[@status='closed']" mode="issues" />
      </section>
    </xsl:if>
    <xsl:if test="not(/*/@ed:suppress-issue-appendix='yes') and //ed:issue[@status='open']">
      <section title="Open issues (to be removed by RFC Editor prior to publication)">
        <xsl:apply-templates select="//ed:issue[@status!='closed']" mode="issues" />
      </section>
    </xsl:if>
  </back>
</xsl:template>


<!-- V3 features -->

<xsl:template match="boilerplate" mode="cleanup"/>
<xsl:template match="link" mode="cleanup"/>
<xsl:template match="rfc/@scripts" mode="cleanup"/>
<xsl:template match="rfc/@version" mode="cleanup"/>
<xsl:template match="@pn" mode="cleanup"/>

<!-- extensions -->

<xsl:template match="x:abnf-char-sequence" mode="cleanup">
  <xsl:choose>
    <xsl:when test="substring(.,1,1) != '&quot;' or substring(.,string-length(.),1) != '&quot;'">
      <xsl:call-template name="error">
        <xsl:with-param name="inline">no</xsl:with-param>
        <xsl:with-param name="msg" select="'contents of x:abnf-char-sequence needs to be quoted.'" />
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>%x</xsl:text>
      <xsl:call-template name="to-abnf-char-sequence">
        <xsl:with-param name="chars" select="substring(.,2,string-length(.)-2)"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="x:anchor-alias" mode="cleanup"/>

<xsl:template match="x:bcp14|bcp14" mode="cleanup">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="x:assign-section-number" mode="cleanup"/>  
<xsl:template match="x:link" mode="cleanup"/>
<xsl:template match="x:source" mode="cleanup"/>
<xsl:template match="x:feedback" mode="cleanup"/>

<xsl:template match="x:parse-xml" mode="cleanup">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="x:prose" mode="cleanup">
  <xsl:variable name="text" select="."/>
  <xsl:comment>Converted from rfc2629.xslt x:prose extension</xsl:comment>
  <xsl:choose>
    <xsl:when test="contains($text,' ')">
      <seriesInfo name="{substring-before($text,' ')}" value="{substring-after($text,' ')}"/>
    </xsl:when>
    <xsl:otherwise>
      <seriesInfo name="" value="{$text}"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="refcontent" mode="cleanup">
  <xsl:variable name="text">
    <xsl:apply-templates mode="cleanup"/>
  </xsl:variable>
  <xsl:comment>Converted from rfc2629.xslt refcontent extension</xsl:comment>
  <xsl:choose>
    <xsl:when test="contains($text,' ')">
      <seriesInfo name="{substring-before($text,' ')}" value="{substring-after($text,' ')}"/>
    </xsl:when>
    <xsl:otherwise>
      <seriesInfo name="" value="{$text}"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="postalLine" mode="cleanup">
  <xsl:comment>converted from v3 &lt;postalLine&gt;</xsl:comment>
  <street><xsl:value-of select="."/></street>
</xsl:template>

<xsl:template match="x:ref" mode="cleanup">
  <xsl:variable name="val" select="normalize-space(.)"/>
  <xsl:variable name="target" select="//*[@anchor and (@anchor=$val or x:anchor-alias/@value=$val)][not(ancestor::ed:del)] | //reference/x:source[x:defines=$val]"/>
  <xsl:if test="count($target)>1">
    <xsl:message terminate="yes">FATAL: multiple x:ref targets found for <xsl:value-of select="$val"/>.</xsl:message>
  </xsl:if>
  <xsl:choose>
    <xsl:when test="$target/self::x:source">
      <!-- drop it-->
      <xsl:value-of select="."/>
    </xsl:when>
    <xsl:when test="$target">
      <xsl:variable name="current" select="."/>
      <xsl:for-each select="$target">
        <!-- make it the context -->
        <xsl:choose>
          <xsl:when test="self::preamble">
            <!-- it's not an element we can link to -->
            <xsl:call-template name="warning">
              <xsl:with-param name="msg">couldn't create the link as <xsl:value-of select="name()"/> does not support the anchor attribute.</xsl:with-param>
            </xsl:call-template>
            <xsl:value-of select="$current"/>
          </xsl:when>
          <xsl:otherwise>
            <xref target="{$target/@anchor}" format="none"><xsl:value-of select="$current"/></xref>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:when>
    <xsl:when test="//x:source">
      <xsl:variable name="ref" select="."/>
      <xsl:variable name="out">
        <!-- try referenced documents one by one -->
        <xsl:for-each select="//reference[x:source]">
          <xsl:variable name="extdoc" select="document(x:source/@href)"/>
          <xsl:variable name="nodes" select="$extdoc//*[@anchor and (x:anchor-alias/@value=$val)]"/>
          <xsl:choose>
            <xsl:when test="not($nodes)">
              <xsl:call-template name="trace">
                <xsl:with-param name="msg">Anchor '<xsl:value-of select="$val"/>' not found in source file '<xsl:value-of select="x:source/@href"/>'.</xsl:with-param>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="info">
                <xsl:with-param name="msg">Anchor '<xsl:value-of select="$val"/>' found in source file '<xsl:value-of select="x:source/@href"/>'.</xsl:with-param>
              </xsl:call-template>
              <xsl:value-of select="$ref"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:variable>
      <xsl:copy-of select="$out"/>
      <xsl:if test="string-length($out)=0">
        <xsl:call-template name="warning">
          <xsl:with-param name="msg">Anchor '<xsl:value-of select="$val"/>' not found anywhere in references.</xsl:with-param>
        </xsl:call-template>
        <xsl:value-of select="$val"/>
      </xsl:if>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="warning">
        <xsl:with-param name="msg">internal link target for '<xsl:value-of select="$val"/>' does not exist.</xsl:with-param>
      </xsl:call-template>
      <xsl:value-of select="."/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="x:blockquote|blockquote" mode="cleanup">
  <t><list>
    <xsl:choose>
      <xsl:when test="t|ul|ol|dl|artwork|figure|sourcecode">
        <xsl:apply-templates mode="cleanup" />
      </xsl:when>
      <xsl:otherwise>
        <t>
          <xsl:apply-templates mode="cleanup" />
        </t>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="@quotedFrom">
      <t>
        <xsl:text>&#8212; </xsl:text>
        <xsl:choose>
          <xsl:when test="@cite"><eref target="{@cite}"><xsl:value-of select="@quotedFrom"/></eref></xsl:when>
          <xsl:otherwise><xsl:value-of select="@quotedFrom"/></xsl:otherwise>
        </xsl:choose>
      </t>
    </xsl:if>
  </list>
  </t>
</xsl:template>

<xsl:template match="li/blockquote" mode="cleanup">
  <list style="empty">
    <xsl:choose>
      <xsl:when test="t|ul|ol|dl|artwork|figure|sourcecode">
        <xsl:apply-templates mode="cleanup" />
      </xsl:when>
      <xsl:otherwise>
        <t>
          <xsl:apply-templates mode="cleanup" />
        </t>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="@quotedFrom">
      <t>
        <xsl:text>&#8212; </xsl:text>
        <xsl:choose>
          <xsl:when test="@cite"><eref target="{@cite}"><xsl:value-of select="@quotedFrom"/></eref></xsl:when>
          <xsl:otherwise><xsl:value-of select="@quotedFrom"/></xsl:otherwise>
        </xsl:choose>
      </t>
    </xsl:if>
  </list>
</xsl:template>

<xsl:template match="x:h" mode="cleanup">
  <xsl:apply-templates mode="cleanup" />
</xsl:template>

<xsl:template match="x:highlight" mode="cleanup">
  <xsl:apply-templates mode="cleanup" />
</xsl:template>

<xsl:template match="x:lt" mode="cleanup">
  <t>
    <xsl:apply-templates select="@hangText|@anchor" mode="cleanup"/>
    <xsl:for-each select="t">
      <xsl:apply-templates mode="cleanup"/>
      <xsl:if test="position()!=last()">
        <vspace blankLines="1"/>
      </xsl:if>
    </xsl:for-each>
  </t>
</xsl:template>

<xsl:template match="x:note|aside" mode="cleanup">
  <t>
    <xsl:apply-templates select="@anchor" mode="cleanup"/>
    <list>
      <xsl:apply-templates mode="cleanup"/>
    </list>
  </t>
</xsl:template>

<xsl:template match="x:q" mode="cleanup">
  <xsl:text>"</xsl:text>
  <xsl:apply-templates mode="cleanup"/>
  <xsl:text>"</xsl:text>
</xsl:template>

<xsl:template match="x:dfn" mode="cleanup">
  <!-- help xml2rfc to keep dfn and following text on the same page -->
  <!-- removed for now because it broke httpbis-p2 (def of 200 OK in -25)
  <xsl:if test="not(preceding-sibling::x:dfn) and count(following-sibling::list)=1 and normalize-space(../text()='')">
    <xsl:processing-instruction name="rfc">needLines="4"</xsl:processing-instruction>
  </xsl:if>-->
  <xsl:apply-templates mode="cleanup"/>
</xsl:template>

<xsl:template match="x:sup|sup" mode="cleanup">
  <xsl:text>^</xsl:text>
  <xsl:apply-templates mode="cleanup" />
</xsl:template>

<xsl:template match="sub" mode="cleanup">
  <xsl:text>_</xsl:text>
  <xsl:apply-templates mode="cleanup" />
</xsl:template>

<xsl:template match="x:span" mode="cleanup">
  <xsl:apply-templates mode="cleanup" />
</xsl:template>
<xsl:template match="x:span/@anchor" mode="cleanup"/>

<xsl:template match="author/@asciiFullname" mode="cleanup"/>
<xsl:template match="author/@asciiInitials" mode="cleanup"/>
<xsl:template match="author/@asciiSurname" mode="cleanup"/>

<xsl:template match="author/@surname" mode="cleanup">
  <xsl:choose>
    <xsl:when test="../@asciiSurname!=''">
      <xsl:attribute name="surname"><xsl:value-of select="../@asciiSurname"/></xsl:attribute>
      <xsl:call-template name="warning">
        <xsl:with-param name="msg">Replacing surname <xsl:value-of select="../@surname"/> by <xsl:value-of select="../@asciiSurname"/>.</xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise><xsl:copy/></xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="author/@fullname" mode="cleanup">
  <xsl:choose>
    <xsl:when test="../@asciiFullname!=''">
      <xsl:attribute name="fullname"><xsl:value-of select="../@asciiFullname"/></xsl:attribute>
      <xsl:call-template name="warning">
        <xsl:with-param name="msg">Replacing fullname <xsl:value-of select="../@fullname"/> by <xsl:value-of select="../@asciiFullname"/>.</xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise><xsl:copy/></xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="author/@initials" mode="cleanup">
  <xsl:choose>
    <xsl:when test="../@asciiInitials!=''">
      <xsl:attribute name="initials"><xsl:value-of select="../@asciiInitials"/></xsl:attribute>
      <xsl:call-template name="warning">
        <xsl:with-param name="msg">Replacing initials <xsl:value-of select="../@initials"/> by <xsl:value-of select="../@asciiInitials"/>.</xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise><xsl:copy/></xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="author/@anchor" mode="cleanup"/>
<xsl:template match="x:include-author" mode="cleanup">
  <t>
    <xsl:value-of select="/*/front/author[@anchor=current()/@target]"/>
  </t>
  <t>
    (see Authors Section)
  </t>
</xsl:template>

<xsl:template match="organization/@ascii" mode="cleanup"/>
<xsl:template match="organization" mode="cleanup">
  <organization>
    <xsl:apply-templates select="@*" mode="cleanup"/>
    <xsl:choose>
      <xsl:when test="@ascii!=''">
        <xsl:value-of select="@ascii"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="text()"/>
      </xsl:otherwise>
    </xsl:choose>
  </organization>
</xsl:template>

<xsl:template match="title/@ascii" mode="cleanup"/>
<xsl:template match="title" mode="cleanup">
  <title>
    <xsl:apply-templates select="@*" mode="cleanup"/>
    <xsl:choose>
      <xsl:when test="@ascii!=''">
        <xsl:value-of select="@ascii"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="text()"/>
      </xsl:otherwise>
    </xsl:choose>
  </title>
</xsl:template>

<xsl:template match="@ascii" mode="cleanup"/>
<xsl:template match="postal/*[@ascii]" mode="cleanup">
  <xsl:element name="{local-name()}">
    <xsl:apply-templates select="@*" mode="cleanup"/>
    <xsl:choose>
      <xsl:when test="@ascii!=''">
        <xsl:value-of select="@ascii"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="text()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:element>
</xsl:template>

<xsl:template match="postal" mode="cleanup">
  <postal>
    <xsl:apply-templates select="@*" mode="cleanup"/>
    <xsl:if test="not(street) and not(postalLine)">
      <!-- street is mandatory in V2 -->
      <street/>
    </xsl:if>
    <xsl:apply-templates select="node()" mode="cleanup"/>
  </postal>
</xsl:template>

<!-- not supported -->
<xsl:template match="relref/@format" mode="cleanup"/>

<xsl:template match="xref[(@x:fmt or @x:sec or @x:rel or @section or @sectionFormat or @relative) and not(*|text())]|relref[not(*|text())]" mode="cleanup">
  <xsl:call-template name="insert-iref-for-xref"/>
  <xsl:variable name="is-xref" select="self::xref"/>
  <xsl:variable name="node" select="$src//*[@anchor=current()/@target]" />

  <xsl:variable name="ssec">
    <xsl:call-template name="get-section-xref-section"/>
  </xsl:variable>

  <xsl:variable name="tsec">
    <xsl:choose>
      <xsl:when test="starts-with(@x:rel,'#') and $ssec='' and $node/x:source/@href">
        <xsl:variable name="extdoc" select="document($node/x:source/@href)"/>
        <xsl:for-each select="$extdoc//*[@anchor=substring-after(current()/@x:rel,'#')]">
          <xsl:variable name="t">
            <xsl:call-template name="get-section-number"/>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="starts-with($t,$unnumbered)">
              <xsl:choose>
                <xsl:when test="ancestor::back">A@</xsl:when>
                <xsl:otherwise>S@</xsl:otherwise>
              </xsl:choose>
              <xsl:call-template name="get-title-as-string">
                <xsl:with-param name="node" select="."/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$t"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$ssec"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="sec">
    <xsl:choose>
      <xsl:when test="contains($tsec,'@')">"<xsl:value-of select="substring-after($tsec,'@')"/>"</xsl:when>
      <xsl:otherwise><xsl:value-of select="$tsec"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="secterm">
    <xsl:choose>
      <!-- starts with letter or unnumbered? -->
      <xsl:when test="translate(substring($sec,1,1),$ucase,'')='' or starts-with($tsec,'A@')">Appendix</xsl:when>
      <xsl:otherwise>Section</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="sfmt">
    <xsl:call-template name="get-section-xref-format">
      <xsl:with-param name="default">
        <xsl:choose>
          <xsl:when test="ancestor::artwork">comma</xsl:when>
          <xsl:otherwise>of</xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:variable>
  
  <xsl:choose>
    <xsl:when test="$sfmt='comma'">
      <xref>
        <xsl:apply-templates select="@target|@format|@pageno|text()|*" mode="cleanup"/>
      </xref>
      <xsl:text>, </xsl:text>
      <xsl:value-of select="$secterm"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="$sec"/>
    </xsl:when>
    <xsl:when test="$sfmt='section'">
      <xsl:value-of select="$secterm"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="$sec"/>
    </xsl:when>
    <xsl:when test="$sfmt='number-only'">
      <xsl:value-of select="$sec"/>
    </xsl:when>
    <xsl:when test="$sfmt='parens'">
      <xref>
        <xsl:apply-templates select="@target|@format|@pageno|text()|*" mode="cleanup"/>
      </xref>
      <xsl:text> (</xsl:text>
      <xsl:value-of select="$secterm"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="$sec"/>
      <xsl:text>)</xsl:text>
    </xsl:when>
    <xsl:when test="$sfmt='of'">
      <xsl:value-of select="$secterm"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="$sec"/>
      <xsl:text> of </xsl:text>
      <xref>
        <xsl:apply-templates select="@target|@format|@pageno|text()|*" mode="cleanup"/>
      </xref>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy>
        <xsl:apply-templates select="node()" mode="cleanup"/>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="xref[(@x:fmt or @x:sec or @x:rel) and (*|text())]|relref[*|text()]" mode="cleanup">
  <xsl:call-template name="insert-iref-for-xref"/>
  <xsl:choose>
    <xsl:when test="self::relref">
      <xsl:apply-templates mode="cleanup"/>
    </xsl:when>
    <xsl:when test="@x:fmt='none'">
      <xsl:apply-templates mode="cleanup"/>
    </xsl:when>
    <xsl:when test="not(@x:fmt)">
      <xref>
        <xsl:copy-of select="@target|@format"/>
        <xsl:apply-templates mode="cleanup"/>
      </xref>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message>Unsupported x:fmt attribute.</xsl:message>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="xref[node() and (@target=//preamble/@anchor or @target=//spanx/@anchor or @target=//name//@anchor or @target=//references/@anchor)]" mode="cleanup">
  <!-- remove the link -->
  <xsl:apply-templates select="node()" mode="cleanup"/>
</xsl:template>

<xsl:template match="xref[node() and @format='none' and @target=//artwork//@anchor]" mode="cleanup">
  <!-- remove the link -->
  <xsl:apply-templates select="node()" mode="cleanup"/>
</xsl:template>

<xsl:template match="xref[not(node()) and (@target=//preamble/@anchor or @target=//spanx/@anchor or @target=//references/@anchor)]" mode="cleanup">
  <xsl:variable name="content">
    <xsl:apply-templates select="."/>
  </xsl:variable>
  <xsl:value-of select="$content"/>
</xsl:template>

<xsl:template match="xref[not(node()) and (not(@format) or @format='default') and (@target=//section[@numbered='false']/@anchor)]" mode="cleanup">
  <!-- link to unnumbered section -->
  <xsl:copy>
    <xsl:copy-of select="@target"/>
    <xsl:variable name="content">
      <xsl:apply-templates select="."/>
    </xsl:variable>
    <xsl:value-of select="$content"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="xref" mode="cleanup" priority="0">
  <xsl:call-template name="insert-iref-for-xref"/>
  <xref>
    <xsl:apply-templates select="@target|@format" mode="cleanup"/>
    <xsl:apply-templates mode="cleanup"/>
  </xref>
</xsl:template>

<xsl:template name="insert-iref-for-xref">
  <xsl:if test="$xml2rfc-ext-include-references-in-index='yesxxx' and $xml2rfc-ext-include-index='yes'">
    <xsl:if test="@target=/rfc/back//reference/@anchor">
      <iref item="{@target}"/>
      <xsl:if test="@x:sec">
        <xsl:choose>
          <xsl:when test="translate(substring(@x:sec,1,1),$ucase,'')=''">
            <iref item="{@target}" subitem="Appendix {@x:sec}"/>
          </xsl:when>
          <xsl:otherwise>
            <iref item="{@target}" subitem="Section {@x:sec}"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:if>
  </xsl:if>
</xsl:template>

<!-- drop index gen extension -->
<xsl:template match="iref" mode="cleanup">
  <xsl:if test="$xml2rfc-ext-include-index='yes'">
    <iref>
      <xsl:apply-templates select="@*|node()" mode="cleanup"/>
    </iref>
  </xsl:if>
</xsl:template>


<!-- issue tracking extensions -->

<xsl:template match="@xml:lang" mode="cleanup"/>
<xsl:template match="@xml:lang" />

<xsl:template match="ed:*" mode="cleanup"/>
<xsl:template match="ed:*" />

<xsl:template match="@ed:*" mode="cleanup"/>
<xsl:template match="@ed:*" />

<xsl:template match="ed:annotation" mode="cleanup" />

<xsl:template match="ed:replace" mode="cleanup">
  <xsl:apply-templates mode="cleanup" />
</xsl:template>

<xsl:template match="ed:replace">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="ed:ins" mode="cleanup">
  <xsl:apply-templates mode="cleanup"/>
</xsl:template>

<xsl:template match="ed:ins">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="ed:issue" mode="issues">
  <section title="{@name}">
    <xsl:variable name="sec">
      <xsl:call-template name="get-section-number"/>
    </xsl:variable>

    <xsl:if test="$sec!=''">
      <t>
        In Section <xsl:value-of select="$sec"/>:
      </t>
    </xsl:if>
    
    <t>
      Type: <xsl:value-of select="@type" />
    </t>
    <xsl:if test="@href">
      <t>
        <!-- temp. removed because of xml2rfc's handling of erefs when producing TXT-->
        <!--<eref target="{@href}" /> -->
        <xsl:text>&lt;</xsl:text>
        <xsl:value-of select="@href"/>
        <xsl:text>></xsl:text>
        <xsl:if test="@alternate-href">
          <xsl:text>, &lt;</xsl:text>
          <xsl:value-of select="@alternate-href"/>
          <xsl:text>></xsl:text>
        </xsl:if>
      </t>
    </xsl:if>
    <xsl:for-each select="ed:item">
      <t>
        <xsl:if test="@entered-by or @date">
          <xsl:choose>
            <xsl:when test="not(@entered-by)">
              <xsl:value-of select="concat('(',@date,') ')" />
            </xsl:when>
            <xsl:when test="not(@date)">
              <xsl:value-of select="concat(@entered-by,': ')" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat(@entered-by,' (',@date,'): ')" />
            </xsl:otherwise>
          </xsl:choose>      
        </xsl:if>
        <xsl:if test="not(xhtml:p)">
          <xsl:apply-templates select="node()" mode="issues"/>
        </xsl:if>
      </t>
      <xsl:if test="xhtml:p|xhtml:pre">
        <xsl:for-each select="node()">
          <xsl:choose>
            <xsl:when test="self::xhtml:p">
              <t>
                <xsl:apply-templates select="node()" mode="issues"/>
              </t>
            </xsl:when>
            <xsl:when test="self::xhtml:pre">
              <figure>
                <artwork><xsl:apply-templates select="node()" mode="issues"/></artwork>
              </figure>
            </xsl:when>
            <xsl:otherwise>
              <t>
                <xsl:apply-templates select="." mode="issues"/>
              </t>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:if>
    </xsl:for-each> 
    <xsl:if test="ed:resolution">
      <t>
        <xsl:text>Resolution</xsl:text>
        <xsl:if test="ed:resolution/@datetime"> (<xsl:value-of select="ed:resolution/@datetime"/>)</xsl:if>
        <xsl:text>: </xsl:text>
        <xsl:value-of select="ed:resolution" />
      </t>
    </xsl:if>
  </section>
</xsl:template>

<xsl:template match="ed:issueref" mode="cleanup">
  <xsl:apply-templates mode="cleanup"/>
</xsl:template>

<xsl:template match="*" mode="issues">
  <xsl:apply-templates mode="issues"/>
</xsl:template>

<xsl:template match="xhtml:q" mode="issues">
  <list><t>
    <xsl:text>"</xsl:text>
    <xsl:apply-templates mode="issues"/>
    <xsl:text>"</xsl:text>
    <xsl:if test="@cite">
      <xsl:text> -- </xsl:text>
      <eref target="{@cite}"><xsl:value-of select="@cite"/></eref>
    </xsl:if>
  </t></list>
</xsl:template>

<xsl:template match="xhtml:br" mode="issues">
  <vspace/>
</xsl:template>

<xsl:template match="xhtml:del" mode="issues">
  <xsl:text>&lt;del></xsl:text>
    <xsl:apply-templates mode="issues"/>
  <xsl:text>&lt;/del></xsl:text>
</xsl:template>

<xsl:template match="xhtml:em" mode="issues">
  <spanx style="emph">
    <xsl:apply-templates mode="issues"/>
  </spanx>
</xsl:template>

<xsl:template match="xhtml:ins" mode="issues">
  <xsl:text>&lt;ins></xsl:text>
    <xsl:apply-templates mode="issues"/>
  <xsl:text>&lt;/ins></xsl:text>
</xsl:template>

<xsl:template match="xhtml:tt" mode="issues">
  <xsl:apply-templates mode="issues"/>
</xsl:template>

<xsl:template match="ed:eref" mode="issues">
  <xsl:text>&lt;</xsl:text>
  <xsl:value-of select="."/>
  <xsl:text>&gt;</xsl:text>
</xsl:template>

<xsl:template match="ed:issueref" mode="issues">
  <xsl:apply-templates mode="issues"/>
</xsl:template>

<xsl:template match="text()" mode="issues">
  <xsl:value-of select="." />
</xsl:template>

<!-- workgroup format -->
<xsl:template match="workgroup" mode="cleanup">
  <workgroup>
    <xsl:variable name="v" select="normalize-space(.)"/>
    <xsl:variable name="h">
      <!-- when a single name, append WG/RG postfix automatically -->
      <xsl:choose>
        <xsl:when test="not(contains($v, ' ')) and starts-with(/rfc/@docName,'draft-ietf-') and $submissionType='IETF'">
          <xsl:value-of select="concat($v, ' Working Group')"/>
        </xsl:when>
        <xsl:when test="not(contains($v, ' ')) and starts-with(/rfc/@docName,'draft-irtf-') and $submissionType='IRTF'">
          <xsl:value-of select="concat($v, ' Research Group')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$v"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="$h"/>
  </workgroup>
</xsl:template>

<!-- markup inside artwork element -->

<xsl:template match="figure" mode="cleanup">
  <!-- move up iref elements -->
  <xsl:for-each select=".//artwork//xref">
    <xsl:if test="not(ancestor::ed:del)">
      <xsl:call-template name="insert-iref-for-xref"/>
    </xsl:if>
  </xsl:for-each>
  <figure>
    <xsl:apply-templates select="@align|@alt|@anchor|@height|@src|@suppress-title|@width" mode="cleanup" />
    <xsl:variable name="title">
      <xsl:choose>
        <xsl:when test="name">
          <xsl:variable name="hold">
            <xsl:apply-templates select="name/node()"/>
          </xsl:variable>
          <xsl:value-of select="normalize-space($hold)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@title"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$title!=''">
      <xsl:attribute name="title"><xsl:value-of select="$title"/></xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select=".//artwork//iref" mode="cleanup"/>
    <xsl:apply-templates select="iref|preamble|artwork|sourcecode|postamble|ed:replace|ed:ins|ed:del" mode="cleanup" />
  </figure>
</xsl:template>
<xsl:template match="figure/name" mode="cleanup"/>

<xsl:template name="insert-begin-code"/>
<xsl:template name="insert-end-code"/>
<xsl:template match="@x:is-code-component" mode="cleanup"/>

<xsl:template match="artwork[svg:svg]" mode="cleanup">
<xsl:call-template name="warning">
  <xsl:with-param name="msg">SVG image removed.</xsl:with-param>
</xsl:call-template>
<artwork>(see SVG image in HTML version)</artwork>
</xsl:template>

<xsl:template match="artwork" mode="cleanup">
  <xsl:variable name="content2"><xsl:apply-templates select="node()"/></xsl:variable>
  <xsl:variable name="content" select="translate($content2,'&#160;&#x2500;&#x2502;&#x2508;&#x250c;&#x2510;&#x2514;&#x2518;&#x251c;&#x2524;',' -|+++++++')"/>
  <artwork>
    <xsl:apply-templates select="@*" mode="cleanup" />
    <xsl:if test="@x:is-code-component='yes'">
      <xsl:if test="starts-with(.,'&#10;')">
        <xsl:text>&#10;</xsl:text>
      </xsl:if>
      <xsl:value-of select="@x:indent-with"/>
      <xsl:text>&lt;CODE BEGINS&gt;&#10;</xsl:text>
    </xsl:if>
    <xsl:if test="starts-with(.,'&#10;')">
      <xsl:text>&#10;</xsl:text>
      <xsl:value-of select="@x:indent-with"/>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="@x:indent-with!=''">
        <xsl:call-template name="indent">
          <xsl:with-param name="content" select="$content"/>
          <xsl:with-param name="with" select="@x:indent-with"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$content"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="@x:is-code-component='yes'">&#10;&lt;CODE ENDS&gt;&#10;</xsl:if>
  </artwork>  
</xsl:template>

<xsl:template match="@x:indent-with" mode="cleanup"/>
<xsl:template match="@x:lang" mode="cleanup"/>

<xsl:template name="indent">
  <xsl:param name="content"/>
  <xsl:param name="with"/>

  <xsl:value-of select="substring($content,1,1)"/>
  <xsl:if test="substring($content,1,1)='&#10;'">
    <xsl:value-of select="$with"/>
  </xsl:if>
  
  <xsl:choose>
    <xsl:when test="$content=''" />
    <xsl:otherwise>
      <xsl:call-template name="indent">
        <xsl:with-param name="content" select="substring($content,2)"/>
        <xsl:with-param name="with" select="$with"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
  
</xsl:template>

<!-- email repetitions -->
<xsl:template match="email" mode="cleanup">
  <!-- combine in a single element -->
  <xsl:if test="not(preceding-sibling::email)">
    <email>
      <xsl:for-each select="../email">
        <xsl:value-of select="."/>
        <xsl:if test="position()!=last()">
          <xsl:text>, </xsl:text>
        </xsl:if>
      </xsl:for-each>
    </email>
  </xsl:if>
</xsl:template>

<!-- markup inside cref -->
<xsl:template match="cref//eref" mode="cleanup">
  <xsl:text>&lt;</xsl:text>
  <xsl:value-of select="@target"/>
  <xsl:text>&gt;</xsl:text>
</xsl:template>

<xsl:template match="cref//xref|cref//x:dfn|cref//x:ref" mode="cleanup" priority="9">
  <xsl:variable name="text">
    <xsl:apply-templates select="."/>
  </xsl:variable>
  <xsl:value-of select="$text"/>
</xsl:template>

<!-- annotations -->
<xsl:template match="@x:annotation" mode="cleanup">
  <xsl:comment>
    <xsl:value-of select="."/>
  </xsl:comment>
  <xsl:call-template name="warning">
    <xsl:with-param name="msg">Dropping annotation on <xsl:value-of select="local-name(..)"/> element.</xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!-- artwork extensions -->
<xsl:template match="artwork/@x:extraction-note" mode="cleanup"/>

<!-- list formatting -->
<xsl:template match="list/@x:indent" mode="cleanup"/>

<!-- rewrite to 'hanging' for now -->
<xsl:template match="list[@style='x:dictionary']" mode="cleanup">
  <list style="hanging">
    <xsl:copy-of select="@hangIndent"/>
    <xsl:apply-templates select="*" mode="cleanup"/>
  </list>
</xsl:template>

<!-- referencing extensions -->
<xsl:template match="iref/@x:for-anchor" mode="cleanup"/>

<!-- GRRDL info stripped -->
<xsl:template match="@grddl:transformation" mode="cleanup"/>

<!-- maturity level stripped -->
<xsl:template match="@x:maturity-level" mode="cleanup"/>

<!-- normativity stripped -->
<xsl:template match="@x:nrm" mode="cleanup"/>

<!-- table extensions -->
<xsl:template match="texttable/@x:caption-side" mode="cleanup"/>

<!-- title extensions -->
<xsl:template match="title/@x:quotes" mode="cleanup"/>

<!-- RDF info stripped -->
<xsl:template match="rdf:*" mode="cleanup"/>

<!-- cases where xml2rfc does not allow anchors -->
<xsl:template match="c/@anchor" mode="cleanup"/>
<xsl:template match="preamble/@anchor" mode="cleanup"/>
<xsl:template match="spanx/@anchor" mode="cleanup"/>

<!-- Workaround for http://trac.tools.ietf.org/tools/xml2rfc/trac/ticket/297 -->
<xsl:template match="spanx[@style='vbare']" mode="cleanup">
  <xsl:choose>
    <xsl:when test="$xml2rfc-ext-strip-vbare='true'">
      <xsl:apply-templates mode="cleanup"/>
    </xsl:when>
    <xsl:otherwise>
      <spanx style="vbare">
        <xsl:apply-templates mode="cleanup"/>
      </spanx>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- v3 features -->
<xsl:template match="rfc/@sortRefs" mode="cleanup"/>
<xsl:template match="rfc/@symRefs" mode="cleanup"/>
<xsl:template match="rfc/@tocInclude" mode="cleanup"/>
<xsl:template match="rfc/@tocDepth" mode="cleanup"/>

<xsl:template match="rfc" mode="cleanup">
  <xsl:if test="@sortRefs='true'">
    <xsl:processing-instruction name="rfc">sortrefs="yes"</xsl:processing-instruction>
  </xsl:if>
  <xsl:if test="@symRefs='false'">
    <xsl:processing-instruction name="rfc">symrefs="no"</xsl:processing-instruction>
  </xsl:if>
  <xsl:if test="@parsedTocDepth!=3">
    <xsl:processing-instruction name="rfc">tocdepth="<xsl:value-of select="$parsedTocDepth"/>"</xsl:processing-instruction>
  </xsl:if>
  <xsl:if test="@version and (not(@tocInclude) or @tocInclude='true')">
    <xsl:processing-instruction name="rfc">toc="yes"</xsl:processing-instruction>
  </xsl:if>
  <rfc>
    <xsl:apply-templates select="@*|node()" mode="cleanup"/>
  </rfc>
</xsl:template>

<xsl:template match="strong" mode="cleanup">
  <xsl:choose>
    <xsl:when test="*">
      <xsl:call-template name="warning">
        <xsl:with-param name="msg">strong not translated when including child elements</xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates mode="cleanup"/>
    </xsl:when>
    <xsl:otherwise>
      <spanx style="strong">
        <xsl:apply-templates mode="cleanup"/>
      </spanx>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="em" mode="cleanup">
  <xsl:choose>
    <xsl:when test="*">
      <xsl:call-template name="warning">
        <xsl:with-param name="msg">em not translated when including child elements</xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates mode="cleanup"/>
    </xsl:when>
    <xsl:otherwise>
      <spanx style="emph">
        <xsl:apply-templates mode="cleanup"/>
      </spanx>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="tt" mode="cleanup">
  <xsl:choose>
    <xsl:when test="*">
      <xsl:call-template name="warning">
        <xsl:with-param name="msg">tt not translated when they include child elements</xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates mode="cleanup"/>
    </xsl:when>
    <xsl:otherwise>
      <spanx style="verb">
        <xsl:apply-templates mode="cleanup"/>
      </spanx>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="references/@anchor" mode="cleanup"/>

<!-- New reference attributes -->
<xsl:template match="reference/@quoteTitle" mode="cleanup">
  <xsl:if test="$xml2rfc-ext-xml2rfc-backend >= 201706">
    <xsl:attribute name="quote-title"><xsl:value-of select="."/></xsl:attribute>
  </xsl:if>
</xsl:template>

<xsl:template match="reference/front/abstract" mode="cleanup"/>

<xsl:template match="reference" mode="cleanup">
  <reference>
    <xsl:apply-templates select="@anchor|@target|@quoteTitle" mode="cleanup"/>
    <xsl:choose>
      <xsl:when test="not(@target) and $xml2rfc-ext-link-rfc-to-info-page='yes' and seriesInfo[@name='BCP'] and starts-with(@anchor,'BCP')">
        <xsl:variable name="uri">
          <xsl:call-template name="compute-rfc-info-uri">
            <xsl:with-param name="type" select="'bcp'"/>
            <xsl:with-param name="no" select="seriesInfo[@name='BCP']/@value"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:attribute name="target"><xsl:value-of select="$uri"/></xsl:attribute>
      </xsl:when>
      <xsl:when test="not(@target) and $xml2rfc-ext-link-rfc-to-info-page='yes' and seriesInfo[@name='RFC']">
        <xsl:variable name="uri">
          <xsl:call-template name="compute-rfc-info-uri">
            <xsl:with-param name="type" select="'rfc'"/>
            <xsl:with-param name="no" select="seriesInfo[@name='RFC']/@value"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:attribute name="target"><xsl:value-of select="$uri"/></xsl:attribute>
      </xsl:when>
      <xsl:when test="not(@target) and $xml2rfc-ext-link-rfc-to-info-page='yes' and not(seriesInfo) and document(x:source/@href)/rfc/@number">
        <xsl:variable name="uri">
          <xsl:call-template name="compute-rfc-info-uri">
            <xsl:with-param name="type" select="'rfc'"/>
            <xsl:with-param name="no" select="document(x:source/@href)/rfc/@number"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:attribute name="target"><xsl:value-of select="$uri"/></xsl:attribute>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="front">
        <xsl:apply-templates select="front" mode="cleanup"/>
      </xsl:when>
      <xsl:when test="x:source">
        <xsl:variable name="d" select="document(x:source/@href)"/>
        <xsl:comment>included from <xsl:value-of select="x:source/@href"/></xsl:comment>
        <front>
          <xsl:apply-templates select="$d/rfc/front/title" mode="cleanup"/>
          <xsl:apply-templates select="$d/rfc/front/author" mode="cleanup"/>
          <xsl:choose>
            <xsl:when test="$d/rfc/front/date/@*">
              <!-- any date info present? -->
              <xsl:apply-templates select="$d/rfc/front/date" mode="cleanup"/>
            </xsl:when>
            <xsl:otherwise>
              <!-- let defaults apply -->
              <date year="{$xml2rfc-ext-pub-year}" month="{$xml2rfc-ext-pub-month}"/>
            </xsl:otherwise>
          </xsl:choose>
        </front>
        <xsl:if test="not(seriesInfo) and document(x:source/@href)/rfc/@docName">
          <seriesInfo name="Internet-Draft" value="{document(x:source/@href)/rfc/@docName}"/>
        </xsl:if>
        <xsl:if test="not(seriesInfo) and document(x:source/@href)/rfc/@number">
          <seriesInfo name="RFC" value="{document(x:source/@href)/rfc/@number}"/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
    <xsl:apply-templates select="seriesInfo|front/seriesInfo" mode="cleanup"/>

    <!-- Insert DOI for RFCs -->
    <xsl:variable name="doi">
      <xsl:choose>
        <xsl:when test="seriesInfo|front/seriesInfo">
          <xsl:call-template name="compute-doi"/>
        </xsl:when>
        <xsl:when test="document(x:source/@href)/rfc/@number">
          <xsl:call-template name="compute-doi">
            <xsl:with-param name="rfc" select="document(x:source/@href)/rfc/@number"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$xml2rfc-ext-insert-doi='yes' and $doi!='' and not(seriesInfo[@name='DOI']|front/seriesInfo[@name='DOI'])">
      <seriesInfo name="DOI" value="{$doi}"/>
    </xsl:if>

    <xsl:apply-templates select="*[not(self::front) and not(self::seriesInfo)]" mode="cleanup"/>
  </reference>
</xsl:template>

<xsl:template match="seriesInfo" mode="cleanup">
  <xsl:choose>
    <xsl:when test="@name='Internet-Draft' and $rfcno > 7375">
      <!-- special case in RFC formatting since 2015 -->
      <seriesInfo name="Work in Progress," value="{@value}"/>
    </xsl:when>
    <xsl:otherwise>
      <seriesInfo name="{@name}" value="{@value}"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
<xsl:template match="front" mode="cleanup">
  <front>
    <xsl:apply-templates select="title|author" mode="cleanup"/>
    <xsl:apply-templates select="date" mode="cleanup"/>
    <xsl:if test="not(date)">
      <!-- mandatory in v2 -->
      <date/>
    </xsl:if>
    <xsl:apply-templates select="text()|node()[not(self::seriesInfo or self::title or self::author or self::date)]" mode="cleanup"/>
  </front>
</xsl:template>

<!-- Note titles -->
<xsl:template match="note" mode="cleanup">
  <note>
    <xsl:copy-of select="@anchor"/>
    <xsl:variable name="title">
      <xsl:choose>
        <xsl:when test="name">
          <xsl:variable name="hold">
            <xsl:apply-templates select="name/node()"/>
          </xsl:variable>
          <xsl:value-of select="normalize-space($hold)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@title"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:attribute name="title"><xsl:value-of select="$title"/></xsl:attribute>
    <xsl:if test="@removeInRFC='true' and (not(t) or t[1]!=$note-removeInRFC)">
      <t><xsl:value-of select="$note-removeInRFC"/></t>
    </xsl:if>
    <xsl:apply-templates mode="cleanup"/>
  </note>
</xsl:template>
<xsl:template match="note/name" mode="cleanup"/>

<!-- References titles -->
<xsl:template match="references" mode="cleanup">
  <references>
    <xsl:apply-templates select="@anchor|@toc" mode="cleanup"/>
    <xsl:variable name="title">
      <xsl:choose>
        <xsl:when test="name">
          <xsl:variable name="hold">
            <xsl:apply-templates select="name/node()"/>
          </xsl:variable>
          <xsl:value-of select="normalize-space($hold)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@title"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$title!=''">
      <xsl:attribute name="title"><xsl:value-of select="$title"/></xsl:attribute>
    </xsl:if>
    <xsl:apply-templates mode="cleanup"/>
  </references>
</xsl:template>
<xsl:template match="references/name" mode="cleanup"/>

<!-- Section titles -->
<xsl:template match="section" mode="cleanup">
  <section>
    <xsl:copy-of select="@anchor|@toc"/>
    <xsl:choose>
      <xsl:when test="$xml2rfc-ext-xml2rfc-backend >= 201706">
        <xsl:copy-of select="@numbered"/>
      </xsl:when>
      <xsl:when test="$xml2rfc-ext-xml2rfc-backend >= 201610 and @numbered='false'">
        <!-- rewrite false to no, see https://trac.tools.ietf.org/tools/xml2rfc/trac/ticket/313 -->
        <xsl:attribute name="numbered">no</xsl:attribute>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
    <xsl:attribute name="title">
      <xsl:choose>
        <xsl:when test="name">
          <xsl:variable name="hold">
            <xsl:apply-templates select="name/node()"/>
          </xsl:variable>
          <xsl:value-of select="normalize-space($hold)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@title"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:if test="@removeInRFC='true' and (not(t) or t[1]!=$section-removeInRFC)">
      <t><xsl:value-of select="$section-removeInRFC"/></t>
    </xsl:if>
    <xsl:apply-templates mode="cleanup"/>
  </section>
  <xsl:if test="(@numbered='no' or @numbered='false') and $xml2rfc-ext-xml2rfc-backend &lt; 201610">
    <xsl:call-template name="warning">
      <xsl:with-param name="msg">unnumbered sections not supported</xsl:with-param>
    </xsl:call-template>
  </xsl:if>
</xsl:template>
<xsl:template match="section/name" mode="cleanup"/>

<!-- Definition Lists -->
<xsl:template match="dl" mode="cleanup">
  <xsl:choose>
    <xsl:when test="parent::dd">
      <xsl:call-template name="process-dl"/>
    </xsl:when>
    <xsl:otherwise>
      <t>
        <xsl:call-template name="process-dl"/>
      </t>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="process-dl">
  <xsl:variable name="newl" select="@newline"/>
  <xsl:variable name="spac" select="@spacing"/>
  <xsl:if test="parent::section">
    <!-- avoid adding PIs into nested lists due to xml2rfc bug -->
    <xsl:processing-instruction name="rfc">
      <xsl:choose>
        <xsl:when test="not($spac='compact')">subcompact='no'</xsl:when>
        <xsl:otherwise>subcompact='yes'</xsl:otherwise>
      </xsl:choose>
    </xsl:processing-instruction>
  </xsl:if>
  <list style="hanging">
    <xsl:variable name="indent" select="@indent"/>
    <xsl:if test="number($indent)=$indent">
      <xsl:attribute name="hangIndent"><xsl:value-of select="$indent"/></xsl:attribute>
    </xsl:if>
    <xsl:for-each select="dt">
      <xsl:variable name="txt">
        <xsl:apply-templates select="." mode="cleanup"/>
      </xsl:variable>
      <!-- TODO: check for more block-level elements -->
      <xsl:variable name="desc" select="following-sibling::dd[1]"/>
      <xsl:variable name="block-level-children" select="$desc/t | $desc/dl | $desc/ol | $desc/ul"/>
      <t hangText="{normalize-space($txt)}">
        <xsl:copy-of select="@anchor"/>
        <xsl:if test="$newl='true'">
          <xsl:choose>
            <xsl:when test="$block-level-children">
              <vspace blankLines="1"/>
            </xsl:when>
            <xsl:otherwise>
              <vspace blankLines="0"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
        <xsl:apply-templates select="iref" mode="cleanup"/>
        <xsl:choose>
          <xsl:when test="$block-level-children">
            <xsl:for-each select="$block-level-children">
              <xsl:choose>
                <xsl:when test="self::t">
                  <xsl:apply-templates select="node()" mode="cleanup"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates select="." mode="cleanup"/>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:if test="position()!=last()">
                <xsl:choose>
                  <xsl:when test="not($spac='compact')"><vspace blankLines="1"/></xsl:when>
                  <xsl:otherwise><vspace blankLines="0"/></xsl:otherwise>
                </xsl:choose>
              </xsl:if>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="$desc/node()" mode="cleanup"/>
          </xsl:otherwise>
        </xsl:choose>
      </t>
    </xsl:for-each>
  </list>
</xsl:template>

<!-- List items -->
<xsl:template match="li" mode="cleanup">
  <t>
    <xsl:copy-of select="@anchor"/>
    <xsl:apply-templates mode="cleanup"/>
  </t>
</xsl:template>
<xsl:template match="li/t" mode="cleanup">
  <xsl:apply-templates mode="cleanup"/>
  <xsl:if test="position()!=last()">
    <vspace blankLines="1"/>
  </xsl:if>
</xsl:template>
<xsl:template match="li/ul" mode="cleanup">
  <list style="symbols">
    <xsl:apply-templates mode="cleanup"/>
  </list>
  <xsl:if test="position()!=last()">
    <vspace blankLines="1"/>
  </xsl:if>
</xsl:template>
<xsl:template match="li/ol" mode="cleanup">
  <list style="numbers">
    <xsl:apply-templates mode="cleanup"/>
  </list>
  <xsl:if test="position()!=last()">
    <vspace blankLines="1"/>
  </xsl:if>
</xsl:template>

<!-- Ordered Lists -->
<xsl:template match="ol[not(@type) or string-length(@type)=1]" mode="cleanup">
  <t>
    <xsl:copy-of select="@anchor"/>
    <xsl:if test="@start and @start!='1'">
      <xsl:call-template name="error">
        <xsl:with-param name="inline">no</xsl:with-param>
        <xsl:with-param name="msg">list start != 1 not supported</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="@group">
      <xsl:call-template name="error">
        <xsl:with-param name="inline">no</xsl:with-param>
        <xsl:with-param name="msg">ol/@group not supported</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:variable name="style">
      <xsl:choose>
        <xsl:when test="not(@type) or @type='1'">numbers</xsl:when>
        <xsl:when test="@type='a'">letters</xsl:when>
        <xsl:when test="@type='A'">
          <xsl:call-template name="error">
            <xsl:with-param name="inline">no</xsl:with-param>
            <xsl:with-param name="msg">ol/@type=<xsl:value-of select="@type"/> not supported (defaulting to 'a')</xsl:with-param>
          </xsl:call-template>
          <xsl:text>letters</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="error">
            <xsl:with-param name="inline">no</xsl:with-param>
            <xsl:with-param name="msg">ol/@type=<xsl:value-of select="@type"/> not supported (defaulting to '1')</xsl:with-param>
          </xsl:call-template>
          <xsl:text>numbers</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <list style="{$style}">
      <xsl:apply-templates mode="cleanup"/>
    </list>
  </t>
</xsl:template>

<xsl:template match="ol[string-length(@type)>1]" mode="cleanup">
  <t>
    <xsl:if test="@start and @start!='1'">
      <xsl:call-template name="error">
        <xsl:with-param name="inline">no</xsl:with-param>
        <xsl:with-param name="msg">list start != 1 not supported</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <list style="format {@type}">
      <xsl:if test="@group">
        <xsl:attribute name="counter"><xsl:value-of select="@group"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates mode="cleanup"/>
    </list>
  </t>
</xsl:template>

<!-- Unordered Lists -->
<xsl:template match="ul" mode="cleanup">
  <t>
    <xsl:choose>
      <xsl:when test="@empty='true'">
        <list style="empty">
          <xsl:apply-templates mode="cleanup"/>
        </list>
      </xsl:when>
      <xsl:otherwise>
        <list style="symbols">
          <xsl:apply-templates mode="cleanup"/>
        </list>
      </xsl:otherwise>
    </xsl:choose>
  </t>
</xsl:template>

<!-- Source Code -->
<xsl:template match="sourcecode" mode="cleanup">
  <xsl:variable name="content2"><xsl:apply-templates select="node()"/></xsl:variable>
  <xsl:variable name="content" select="translate($content2,'&#160;&#x2500;&#x2502;&#x2508;&#x250c;&#x2510;&#x2514;&#x2518;&#x251c;&#x2524;',' -|+++++++')"/>

  <xsl:choose>
    <xsl:when test="parent::figure">
      <artwork>
        <xsl:copy-of select="@anchor|@type"/>
        <xsl:if test="starts-with(.,'&#10;')">
          <xsl:text>&#10;</xsl:text>
          <xsl:value-of select="@x:indent-with"/>
        </xsl:if>
        <xsl:value-of select="$content"/>
      </artwork>
    </xsl:when>
    <xsl:otherwise>
      <figure>
        <artwork>
          <xsl:copy-of select="@anchor|@type"/>
          <xsl:if test="starts-with(.,'&#10;')">
            <xsl:text>&#10;</xsl:text>
            <xsl:value-of select="@x:indent-with"/>
          </xsl:if>
          <xsl:value-of select="$content"/>
        </artwork>
      </figure>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Tables -->
<xsl:template match="table" mode="cleanup">
  <texttable>
    <xsl:apply-templates select="@anchor|@align" mode="cleanup"/>
    <xsl:variable name="title">
      <xsl:choose>
        <xsl:when test="name">
          <xsl:variable name="hold">
            <xsl:apply-templates select="name/node()"/>
          </xsl:variable>
          <xsl:value-of select="normalize-space($hold)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@title"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$title!=''">
      <xsl:attribute name="title"><xsl:value-of select="$title"/></xsl:attribute>
    </xsl:if>
    <xsl:for-each select="thead/tr/*">
      <xsl:variable name="p" select="position()"/>
      <!-- in texttable the whole column has the same alignment; we try
      either the first non-header row or the header itself-->
      <xsl:variable name="align">
        <xsl:choose>
          <xsl:when test="tbody/tr[1]/*[1] and tbody/tr[1]/*[1]/@align"><xsl:value-of select="tbody/tr[1]/*[1]/@align"/></xsl:when>
          <xsl:when test="@align"><xsl:value-of select="@align"/></xsl:when>
          <xsl:otherwise>center</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <ttcol align="{$align}">
        <xsl:apply-templates mode="cleanup"/>
      </ttcol>
    </xsl:for-each>
    <xsl:for-each select="tbody/tr/*">
      <c>
        <xsl:if test="position()=1">
          <xsl:copy-of select="../../../iref"/>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="t|sourcecode|ol|dl|uo">
            <xsl:apply-templates select="t/node()|sourcecode/node()|ol/li/node()|ul/li/node()|dl/*/node()" mode="cleanup"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates mode="cleanup"/>
          </xsl:otherwise>
        </xsl:choose>
      </c>
      <xsl:if test="@rowspan and @rowspan!='1'">
        <xsl:call-template name="error">
          <xsl:with-param name="inline">no</xsl:with-param>
          <xsl:with-param name="msg">rowspan attribute not supported (dropped, table will be ugly)</xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="@colspan and @colspan!='1'">
        <xsl:call-template name="error">
          <xsl:with-param name="inline">no</xsl:with-param>
          <xsl:with-param name="msg">colspan attribute not supported (dropped, table will be ugly)</xsl:with-param>
        </xsl:call-template>
      </xsl:if>
    </xsl:for-each>
    <xsl:if test="tfoot">
      <xsl:call-template name="error">
        <xsl:with-param name="inline">no</xsl:with-param>
        <xsl:with-param name="msg">tfoot element not supported (dropped)</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </texttable>
</xsl:template>

<!-- date formats -->
<xsl:template match="/rfc/front/date/@month" mode="cleanup">
  <xsl:attribute name="month">
    <xsl:choose>
      <xsl:when test="string(number(.))!='NaN' and number(.)&gt;0 and number(.)&lt;13">
        <xsl:call-template name="get-month-as-name">
          <xsl:with-param name="month" select="."/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:attribute>
</xsl:template>

<!-- x:contributor -->
<xsl:template match="x:contributor" mode="cleanup">
  <xsl:variable name="content">
    <xsl:apply-templates select="."/>
  </xsl:variable>
  <t>
    <xsl:apply-templates select="exslt:node-set($content)/*" mode="text"/>
  </t>
</xsl:template>
<xsl:template match="*" mode="text">
  <xsl:apply-templates mode="text"/>
</xsl:template>
<xsl:template match="text()" mode="text">
  <xsl:value-of select="."/>
</xsl:template>
<xsl:template match="br" mode="text">
  <vspace blankLines="0"/>
</xsl:template>

<!-- x:include -->
<xsl:template match="/rfc/back/references/xi:include" mode="cleanup">
  <xsl:copy-of select="document(@href)"/>
</xsl:template>

<!-- Display names for references -->
<xsl:template match="displayreference" mode="cleanup"/>
<xsl:template match="reference/@anchor[.=/rfc/back/displayreference/@target]" mode="cleanup">
  <xsl:attribute name="anchor">
    <xsl:call-template name="generate-ref-name"/>
  </xsl:attribute>
</xsl:template>
<xsl:template match="xref/@target[.=/rfc/back/displayreference/@target]" mode="cleanup">
  <xsl:attribute name="target">
    <xsl:call-template name="generate-ref-name"/>
  </xsl:attribute>
</xsl:template>

<xsl:template name="generate-ref-name">
  <xsl:variable name="tnewname">
    <xsl:value-of select="/rfc/back/displayreference[@target=current()]/@to"/>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="count(/rfc/back/displayreference[@to=current()])>1 or //reference[@anchor=$tnewname]">
      <xsl:value-of select="current()"/>
      <xsl:call-template name="warning">
        <xsl:with-param name="msg">Not rewriting reference name <xsl:value-of select="current()"/> as it would conflict</xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="translate(substring($tnewname,1,1),$digits,'')=''">
      <xsl:value-of select="concat('_',$tnewname)"/>
      <xsl:call-template name="warning">
        <xsl:with-param name="msg">rewriting reference name '<xsl:value-of select="$tnewname"/>' to '<xsl:value-of select="concat('_',$tnewname)"/>' due to illegal start character</xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$tnewname"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:transform>