<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:data="#data"               
               version="1.0"
               xmlns:xhtml="http://www.w3.org/1999/xhtml"
               exclude-result-prefixes="xhtml data"
>

<xsl:output method="html" encoding="UTF-8" version="4.0"
            doctype-public="-//W3C//DTD HTML 4.01//EN" indent="yes"/>
            
<data:specs>
  <data:name>draft-ietf-httpbis-semantics-latest</data:name>
  <data:name>draft-ietf-httpbis-cache-latest</data:name>
  <data:name>draft-ietf-httpbis-messaging-latest</data:name>
</data:specs>

<xsl:template match="/">
  <html>
    <head>
      <title>HTTP Core Drafts: Combined Table of Contents</title>
<style type="text/css" title="xml2rfc TOC">
@import url('https://fonts.googleapis.com/css?family=Noto+Sans:r,b,i,bi');
@import url('https://fonts.googleapis.com/css?family=Roboto+Mono:r,b,i,bi');

a {
  text-decoration: none;
}
a.smpl {
  color: black;
}
a:hover {
  text-decoration: underline;
}
a:active {
  text-decoration: underline;
}
address {
  margin-top: 1em;
  margin-left: 2em;
  font-style: normal;
}
body {
  color: black;
  font-family: 'Noto Sans', segoe, optima, arial, sans-serif, serif;
  font-size: 16px;
  line-height: 1.5;
  margin: 10px 0px 10px 10px;
}
@media screen and (min-width: 940px) {
  body {
    margin: 10px auto;
    max-width: 900px;
  }
}
samp, span.tt, code, pre {
  font-family: 'Roboto Mono', monospace;
}
cite {
  font-style: normal;
}
aside {
  margin-left: 2em;
}
dl {
  margin-left: 2em;
}
dl > dt {
  float: left;
  margin-right: 1em;
}
dl.nohang > dt {
  float: none;
}
dl > dd {
  margin-bottom: .5em;
}
dl.compact > dd {
  margin-bottom: .0em;
}
dl > dd > dl {
  margin-top: 0.5em;
}
ul.empty {
  list-style-type: none;
}
ul.empty li {
  margin-top: .5em;
}
dl p {
  margin-left: 0em;
}
dl.reference > dt {
  font-weight: bold;
}
dl.reference > dd {
  margin-left: 6em;
}
h1 {
  color: green;
  font-size: 150%;
  font-weight: bold;
  text-align: center;
  margin-top: 36pt;
  margin-bottom: 0pt;
}
h2 {
  font-size: 130%;
  page-break-after: avoid;
}
h2.np {
  page-break-before: always;
}
h3 {
  font-size: 120%;
  page-break-after: avoid;
}
h4 {
  font-size: 110%;
  page-break-after: avoid;
}
h5, h6 {
  font-size: 100%;
  page-break-after: avoid;
}
h1 a, h2 a, h3 a, h4 a, h5 a, h6 a {
  color: black;
}
img {
  margin-left: 3em;
}
li {
  margin-left: 2em;
}
ol {
  margin-left: 2em;
}
ol.la {
  list-style-type: lower-alpha;
}
ol.ua {
  list-style-type: upper-alpha;
}
ol p {
  margin-left: 0em;
}
p {
  margin-left: 2em;
}
pre {
  font-size: 90%;
  margin-left: 3em;
  background-color: lightyellow;
  padding: .25em;
  page-break-inside: avoid;
}
pre.text2 {
  border-style: dotted;
  border-width: 1px;
  background-color: #f0f0f0;
}
pre.inline {
  background-color: white;
  padding: 0em;
  page-break-inside: auto;
  border: none !important;
}
pre.text {
  border-style: dotted;
  border-width: 1px;
  background-color: #f8f8f8;
}
pre.drawing {
  border-style: solid;
  border-width: 1px;
  background-color: #f8f8f8;
  padding: 2em;
}
table {
  margin-left: 2em;
}
div.tt {
  margin-left: 2em;
} 
table.tt {
  border-collapse: collapse;
  border-color: gray;
  border-spacing: 0; 
  vertical-align: top;
 }
table.tt th {
  border-color: gray;
  padding: 3px;
}
table.tt td {
  border-color: gray;
  padding: 3px;
}
table.all {
  border-style: solid;
  border-width: 2px;
}
table.full {
  border-style: solid;
  border-width: 2px;
}
table.tt td {
  vertical-align: top;
}
table.all td {
  border-style: solid;
  border-width: 1px;
}
table.full td {
  border-style: none solid;
  border-width: 1px;
}
table.tt th {
  vertical-align: top;
}
table.all th {
  border-style: solid;
  border-width: 1px;
}
table.full th {
  border-style: solid;
  border-width: 1px 1px 2px 1px;
}
table.headers th {
  border-style: none none solid none;
  border-width: 2px;
}
table.tleft {
  margin-right: auto;
}
table.tright {
  margin-left: auto;
}
table.tcenter {
  margin-left: auto;
  margin-right: auto;
}
caption {
  caption-side: bottom;
  font-weight: bold;
  font-size: 80%;
  margin-top: .5em;
}

table.header {
  border-spacing: 1px;
  width: 95%;
  font-size: 90%;
}
td.top {
  vertical-align: top;
}
td.topnowrap {
  vertical-align: top;
  white-space: nowrap;
}
table.header td {
  width: 50%;
}
table.header a {
  color: black;
}
ul.toc, ul.toc ul {
  list-style: none;
  margin-left: 1.5em;
  padding-left: 0em;
}
ul.toc li {
  line-height: 150%;
  font-weight: bold;
  margin-left: 0em;
}
ul.toc li li {
  line-height: normal;
  font-weight: normal;
  font-size: 90%;
  margin-left: 0em;
}
li.excluded {
  font-size: 0%;
}
ul p {
  margin-left: 0em;
}
.filename, h1, h2, h3, h4 {
  font-family: 'Noto Sans', segoe, optima, arial, sans-serif;
}
ul.ind, ul.ind ul {
  list-style: none;
  margin-left: 1.5em;
  padding-left: 0em;
  page-break-before: avoid;
}
ul.ind li {
  font-weight: bold;
  line-height: 200%;
  margin-left: 0em;
}
ul.ind li li {
  font-weight: normal;
  line-height: 150%;
  margin-left: 0em;
}
.avoidbreakinside {
  page-break-inside: avoid;
}
.avoidbreakafter {
  page-break-after: avoid;
}
section.rfcEditorRemove > div:first-of-type {
  font-style: italic;
}.bcp14 {
  font-style: normal;
  text-transform: lowercase;
  font-variant: small-caps;
}
.comment {
  background-color: yellow;
}
.center {
  text-align: center;
}
.error {
  color: red;
  font-style: italic;
  font-weight: bold;
}
.figure {
  font-weight: bold;
  text-align: center;
  font-size: 80%;
}
.filename {
  color: #333333;
  font-size: 112%;
  font-weight: bold;
  line-height: 21pt;
  text-align: center;
  margin-top: 0pt;
}
.fn {
  font-weight: bold;
}
.left {
  text-align: left;
}
.right {
  text-align: right;
}
.warning {
  font-size: 130%;
  background-color: yellow;
}.feedback {
  position: fixed;
  bottom: 1%;
  right: 1%;
  padding: 3px 5px;
  color: white;
  border-radius: 5px;
  background: #006400;
  border: 1px solid silver;
  -webkit-user-select: none; 
  -moz-user-select: none;
  -ms-user-select: none;
}
.fbbutton {
  margin-left: 1em;
  color: #303030;
  font-size: small;
  font-weight: normal;
  background: #d0d000;
  padding: 1px 4px;
  border: 1px solid silver;
  border-radius: 5px;
  -webkit-user-select: none; 
  -moz-user-select: none;
  -ms-user-select: none;
}

@media screen {
  pre.text, pre.text2 {
    width: 69em;
  }
}

@media print {
  .noprint {
    display: none;
  }

  a {
    color: black;
    text-decoration: none;
  }

  table.header {
    width: 90%;
  }

  td.header {
    width: 50%;
    color: black;
    background-color: white;
    vertical-align: top;
    font-size: 110%;
  }

  ul.toc a:last-child::after {
    content: leader('.') target-counter(attr(href), page);
  }

  ul.ind li li a {
    content: target-counter(attr(href), page);
  }

  .print2col {
    column-count: 2;
    -moz-column-count: 2;
    column-fill: auto;
  }
}
@page {
  font-family: 'Noto Sans', segoe, optima, arial, sans-serif, serif;
}
</style>
    </head>
    <body>
      <div id="page">
        <div id="content">
          <h1>HTTP Core Drafts: Combined Table of Contents</h1>
          <xsl:for-each select="document('')//data:specs/data:name">
            <xsl:variable name="doc" select="document(concat('../build/',.,'.xhtml'))"/>
            <h2>
              <a href="{concat(.,'.html')}">
                <xsl:value-of select="$doc//xhtml:title"/>
              </a>
            </h2>
            <xsl:apply-templates select="$doc//xhtml:nav/xhtml:ul[@class='toc']" mode="tocgen"/>
          </xsl:for-each>
        </div>
      </div>
    </body>
  </html>
</xsl:template>

<xsl:template match="xhtml:ul" mode="tocgen">
  <ul class="{@class}">
    <xsl:apply-templates mode="tocgen"/>
  </ul>
</xsl:template> 

<xsl:template match="xhtml:li" mode="tocgen">
  <li class="{@class}">
    <xsl:apply-templates mode="tocgen"/>
  </li>
</xsl:template> 

<xsl:template match="xhtml:a" mode="tocgen">
  <xsl:variable name="basename" select="substring-after(//xhtml:meta[@name='dcterms.identifier']/@content,'urn:ietf:id:')"/>
  <a href="{$basename}.html{@href}">
    <xsl:apply-templates mode="tocgen"/>
  </a>
</xsl:template> 

</xsl:transform>
