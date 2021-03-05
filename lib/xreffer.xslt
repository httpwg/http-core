<!--
    Process <xref>s to <x:has> elements, and remove those which are in use.

    Copyright (c) 2018-2021, Julian Reschke (julian.reschke@greenbytes.de)
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
               xmlns:x="http://purl.org/net/xml2rfc/ext"
               version="1.0" 
>

<xsl:output encoding="UTF-8" />

<!-- rules for identity transformations -->

<xsl:template match="*|comment()|text()|@*"><xsl:copy><xsl:apply-templates select="node()|@*" /></xsl:copy></xsl:template>
<xsl:template match="processing-instruction()"><xsl:copy><xsl:apply-templates select="node()|@*" /></xsl:copy><xsl:if test="not(ancestor::rfc)"><xsl:text>&#10;</xsl:text></xsl:if></xsl:template>

<!-- filter location info -->
<xsl:template match="processing-instruction('rfc-ext')[contains(.,'line-no=')]"/>

<xsl:template match="/">
	<xsl:copy><xsl:apply-templates select="node()" /></xsl:copy>
</xsl:template>

<xsl:template match="xref">
  <xsl:variable name="t" select="@target"/>
  <xsl:variable name="n" select="//*[@anchor=$t]"/>
  <xsl:choose>
    <xsl:when test="$n/self::x:has and $n/@target">
      <xref target="{$n/../../@anchor}" x:rel="#{$n/@target}"/>
    </xsl:when>
    <xsl:when test="$n/self::x:has">
      <xref target="{$n/../../@anchor}" x:rel="#{$t}"/>
    </xsl:when>
    <xsl:otherwise>
    	<xsl:copy><xsl:apply-templates select="@*|node()" /></xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Strip x:has tags that are in use -->
<xsl:template match="x:has[@anchor=//*/@target]"/>

</xsl:transform>