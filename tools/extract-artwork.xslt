<!--
    Extract named artwork elements.

    Copyright (c) 2006-2009, Julian Reschke (julian.reschke@greenbytes.de)
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

<xsl:import href="clean-for-DTD.xslt"/>

<xsl:output method="text" encoding="UTF-8"/>

<xsl:param name="name" />
<xsl:param name="except-name" />
<xsl:param name="type" />

<xsl:template match="/" priority="9">
  
  <xsl:choose>
    <xsl:when test="$name!=''">
      <xsl:variable name="artwork" select="//artwork[@name=$name]"/>
      
      <xsl:choose>
        <xsl:when test="$artwork">
          <xsl:for-each select="$artwork">
            <xsl:value-of select="@x:extraction-note"/>
            <xsl:apply-templates select="." mode="cleanup"/>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>Artwork element named '<xsl:value-of select="$name"/>' not found.</xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="$type!=''">
      <xsl:variable name="artwork" select="//artwork[@type=$type]"/>
      
      <xsl:choose>
        <xsl:when test="$artwork">
          <xsl:for-each select="$artwork">
            <xsl:choose>
              <xsl:when test="$except-name!='' and @name=$except-name">
                <!-- do not emit this one -->
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@x:extraction-note"/>
                <xsl:apply-templates select="." mode="cleanup"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>Artwork element typed '<xsl:value-of select="$type"/>' not found.</xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:message>Please specify either name or type parameter.</xsl:message>
    </xsl:otherwise>
  </xsl:choose>
  

</xsl:template>


</xsl:transform>