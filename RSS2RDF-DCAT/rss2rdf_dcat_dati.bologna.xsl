<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:dct="http://purl.org/dc/terms/"
	xmlns:content="http://purl.org/rss/1.0/modules/content/" 
	xmlns:r="http://backend.userland.com/rss2"
	xmlns:dcat="http://www.w3.org/ns/dcat#"
	xmlns:void="http://rdfs.org/ns/void#"
	xmlns:foaf="http://xmlns.com/foaf/0.1/"
	xmlns:oddi_tags="http://data.opendataday.it/resource/tag/"
	xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns="http://purl.org/rss/1.0/" version="2.0"
	xmlns:url="http://whatever/java/java.net.URLEncoder"
	xmlns:opendatacobo="http://dati.comune.bologna.it/rss/">
	
	<!-- <xsl:output indent="yes" cdata-section-elements="content:encoded" /> -->
	<xsl:output indent="yes" encoding="UTF-8" />
	
	<xsl:variable name="apos">'</xsl:variable>
	
	<!-- CONFIGURATION PARAMETERS: dati.comune.bologna.it -->
	<!-- base uri di input da sottrarre (rss:item/rss:link o rss:item/rss:guid) per ottenere il solo ID del dataset da concatenare al base URI di output -->
	<xsl:variable name="input_dataset_base_URI">http://dati.comune.bologna.it/node/</xsl:variable>
	
	<!-- base uri di input da sottrarre (rss:item/rss:enclosure) per ottenere il solo ID della distribution da concatenare al base URI di output -->
	<xsl:variable name="input_distribution_base_URI">http://dati.comune.bologna.it/file/dataset/</xsl:variable>
	
	<xsl:variable name="output_catalog_URI">http://data.opendataday.it/resource/dati.bologna</xsl:variable>
	
	<xsl:variable name="output_dataset_base_URI">http://data.opendataday.it/resource/dati.bologna/</xsl:variable>
	
	<xsl:variable name="output_theme_base_URI">http://data.opendataday.it/resource/tag/</xsl:variable>
	

	<!-- SPECIFICI PER: dati.comune.bologna.it -->
	<!-- ####################################################################### -->
	<xsl:template match="opendatacobo:version">
		<dct:hasVersion>
			<xsl:value-of select="." />
		</dct:hasVersion>
	</xsl:template>
	
	<xsl:template match="opendatacobo:license">
		<xsl:choose>
			<xsl:when test=".='CC0'">
						<dct:license rdf:resource="http://opendefinition.org/licenses/cc-zero" />
			</xsl:when>
			<xsl:when test=".='CC-BY'">
						<dct:license rdf:resource="http://opendefinition.org/licenses/cc-by" />
			</xsl:when>
			<xsl:when test=".='CC BY-NC-SA 3.0'">
						<dct:license rdf:resource="http://creativecommons.org/licenses/by-nc-sa/3.0/" />
			</xsl:when>			
			<xsl:otherwise>
				<dct:license>
					<xsl:value-of select="." />
				</dct:license>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="opendatacobo:coverage" />
	<!-- ####################################################################### -->


	<!-- general element conversions -->
	<xsl:template match="/">
		<rdf:RDF>
			<xsl:apply-templates />
		</rdf:RDF>
	</xsl:template>
	<xsl:template match="*">
		<xsl:choose>
			<xsl:when
				test="namespace-uri()='' or namespace-uri()='http://backend.userland.com/rss2'">
<!-- 				<xsl:element name="{name()}" namespace="http://purl.org/rss/1.0/"> -->
<!-- 					<xsl:apply-templates select="*|@*|text()" /> -->
<!-- 				</xsl:element> -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy>
					<xsl:apply-templates select="*|@*|text()" />
				</xsl:copy>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="@*">
		<!-- <xsl:copy><xsl:value-of select="." /></xsl:copy> -->
	</xsl:template>
	<xsl:template match="text()">
		<xsl:value-of select="normalize-space(.)" />
	</xsl:template>
	<xsl:template match="rss|r:rss">
		<xsl:copy-of select="namespace::*" />
		<xsl:apply-templates select="channel|r:channel" />		
		<xsl:apply-templates select="channel/item[guid|link]|r:channel/r:item[r:guid|r:link]" mode="dataset_instance" />	
		<xsl:apply-templates select="channel/item[*]/category|r:channel/r:item[*]/r:category" mode="theme_instance" />
		<xsl:apply-templates select="channel/item[*]/enclosure|r:channel/r:item[*]/r:enclosure" mode="distribution_instance" />
	</xsl:template>
	<xsl:template match="channel|r:channel">
		<dcat:Catalog rdf:about="{$output_catalog_URI}"> 
			<!-- <xsl:apply-templates /> -->
			<xsl:apply-templates select="item|r:item" mode="dataset_property_value" />
		</dcat:Catalog>
	</xsl:template>
	<!-- channel content conversions -->
	<xsl:template match="title|r:title">
		<dc:title>
<!-- 			<xsl:value-of select="." /> -->
			<xsl:call-template name="removeTags" />
		</dc:title>
	</xsl:template>
<!-- 	<xsl:template match="description|r:description"> -->
<!-- 		<dct:description> -->
<!-- 			<xsl:value-of select="." /> -->
<!-- 		</dct:description> -->
<!-- 	</xsl:template> -->
	<xsl:template match="language|r:language">
		<dc:language>
			<xsl:value-of select="." />
		</dc:language>
	</xsl:template>
	<xsl:template match="copyright|r:copyright">
		<dc:rights>
			<xsl:value-of select="." />
		</dc:rights>
	</xsl:template>
	<xsl:template match="lastBuildDate|pubdate|r:lastBuildDate|r:pubdate">
		<dct:created>
			<!-- <xsl:call-template name="date" /> -->
			<xsl:value-of select="." />
		</dct:created>
	</xsl:template>
	<xsl:template match="managingEditor|r:managingEditor">
		<dc:creator>
			<xsl:value-of select="." />
		</dc:creator>
	</xsl:template>
	<!-- elements from 0.94 not converted: webMaster category generator docs 
		cloud ttl image textInput skipHours skipDays -->
	<!-- item content conversions -->
	<xsl:template match="item/description|r:item/r:description">
		<dct:description>
			<xsl:call-template name="removeTags" />
		</dct:description>
<!-- 		<xsl:if test="not(../content:encoded)"> -->
<!-- 			<content:encoded> -->
<!-- 				<xsl:value-of select="." /> -->
<!-- 			</content:encoded> -->
<!-- 		</xsl:if> -->
	</xsl:template>
	<xsl:template match="category|r:category">
		<dcat:theme>
		  <xsl:attribute name="resource" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
    		<xsl:value-of select="concat($output_theme_base_URI, translate(translate(translate(translate(translate(translate(.,' ' ,'-' ), 'à', 'a'), 'ù', 'u'), 'ò', 'o'), 'é', 'e'), 'è', 'e'))" />
 		 </xsl:attribute>
		 </dcat:theme>
	</xsl:template>
	<xsl:template match="enclosure|r:enclosure">
		<xsl:choose>
			<xsl:when test="../guid|../r:guid">
				<dcat:distribution>
				  <xsl:attribute name="resource" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
		    		<xsl:value-of select="concat($output_dataset_base_URI, substring-after(../guid, $input_dataset_base_URI), '/distribution/', substring(substring-after(., $input_distribution_base_URI), 0, string-length(substring-after(., $input_distribution_base_URI))-3) )" />
		 		 </xsl:attribute>
				 </dcat:distribution>			
			</xsl:when> 
			<xsl:when test="../link|../r:link">
				<dcat:distribution>
				  <xsl:attribute name="resource" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
		    		<xsl:value-of select="concat($output_dataset_base_URI, substring-after(../guid, $input_dataset_base_URI), '/distribution/', substring-after(., $input_distribution_base_URI))" />
		 		 </xsl:attribute>
				 </dcat:distribution>			
			</xsl:when>			
		</xsl:choose>	
	</xsl:template>	
	<xsl:template match="pubDate|r:pubDate">
		<dct:created>
			<!-- <xsl:call-template name="date" /> -->
			<xsl:value-of select="." />
		</dct:created>
	</xsl:template>
	<xsl:template match="source|r:source">
		<dc:source>
			<xsl:attribute name="resource" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
		    	<xsl:value-of select="@url" />
		 	</xsl:attribute>		
		</dc:source>
	</xsl:template>
	<xsl:template match="author|r:author">
		<dc:publisher>
			<xsl:value-of select="." />
		</dc:publisher>
	</xsl:template>
			
	<!-- elements from 0.94 not converted: category comments enclosure -->
	<!-- item templates -->
	<xsl:template match="item|r:item" mode="li">
		<xsl:choose>
			<xsl:when test="link|r:link">
				<rdf:li rdf:resource="{link|r:link}" />
			</xsl:when>
			<xsl:when test="guid|r:guid">
				<rdf:li rdf:resource="{guid|r:guid}" />
			</xsl:when>
			<xsl:otherwise>
				<rdf:li rdf:parseType="Resource">
					<xsl:apply-templates />
				</rdf:li>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="item|r:item" mode="dataset_property_value">
		<xsl:choose>
			<xsl:when test="link|r:link">
				<dcat:dataset>
					<xsl:attribute name="resource" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">		
    					<xsl:value-of select="concat($output_dataset_base_URI,  translate(translate(translate(translate(translate(translate(translate(translate(translate(translate(translate(title, 'à', 'a'), 'ù', 'u'), 'ò', 'o'), 'é', 'e'), 'è', 'e'), '(', ''), ')', ''), ',', '_'), '.', '_'), ' ', '_'), '&amp;#039;', '_'), '_', substring-after(link, $input_dataset_base_URI))" />
 		 			</xsl:attribute>
				</dcat:dataset> 
			</xsl:when>
			<xsl:when test="guid|r:guid">
				<dcat:dataset>
					<xsl:attribute name="resource" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">		
    					<xsl:value-of select="concat($output_dataset_base_URI,  translate(translate(translate(translate(translate(translate(translate(translate(translate(translate(translate(title, 'à', 'a'), 'ù', 'u'), 'ò', 'o'), 'é', 'e'), 'è', 'e'), '(', ''), ')', ''), ',', '_'), '.', '_'), ' ', '_'), '&amp;#039;', '_'), '_', substring-after(guid, $input_dataset_base_URI))" /> 
 		 			</xsl:attribute>
				</dcat:dataset> 
			</xsl:when>
			<xsl:otherwise>
				<dcat:dataset rdf:parseType="Resource">
					<xsl:apply-templates />
				</dcat:dataset>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>	
	<xsl:template match="item[link]|r:item[r:link]" mode="dataset_instance">
		<dcat:Dataset>
			<xsl:attribute name="about" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">		
    			<xsl:value-of select="concat($output_dataset_base_URI,  translate(translate(translate(translate(translate(translate(translate(translate(translate(translate(translate(title, 'à', 'a'), 'ù', 'u'), 'ò', 'o'), 'é', 'e'), 'è', 'e'), '(', ''), ')', ''), ',', '_'), '.', '_'), ' ', '_'), '&amp;#039;', '_'), '_', substring-after(link, $input_dataset_base_URI))" />
 		 	</xsl:attribute>
			<xsl:apply-templates />
		</dcat:Dataset>
	</xsl:template>
	<xsl:template match="item[guid][not(link)]|r:item[r:guid][not(r:link)]"	mode="dataset_instance">
		<dcat:Dataset>
			<xsl:attribute name="about" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">		
    			<xsl:value-of select="concat($output_dataset_base_URI,  translate(translate(translate(translate(translate(translate(translate(translate(translate(translate(translate(title, 'à', 'a'), 'ù', 'u'), 'ò', 'o'), 'é', 'e'), 'è', 'e'), '(', ''), ')', ''), ',', '_'), '.', '_'), ' ', '_'), '&amp;#039;', '_'), '_', substring-after(guid, $input_dataset_base_URI))" />
 		 	</xsl:attribute>
			<xsl:apply-templates />
		</dcat:Dataset>
	</xsl:template>
	<xsl:template match="channel/item[*]/category|r:channel/r:item[*]/r:category" mode="theme_instance">
		<skos:Concept> 
		  	<xsl:attribute name="about" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
    			<!-- <xsl:value-of select="concat($output_theme_base_URI, translate(translate(translate(translate(translate(translate(translate(translate(translate(translate(translate(translate(.,'-',''),' ', '-'), 'à', 'a'), 'ù', 'u'), 'ò', 'o'), 'é', 'e'), 'è', 'e'), '(', ''), ')', ''), ',', '_'), '.', '_'), '&amp;#039;', '_'))" /> -->
    			<xsl:value-of select="concat($output_theme_base_URI, translate(translate(translate(translate(translate(translate(.,' ' ,'-' ), 'à', 'a'), 'ù', 'u'), 'ò', 'o'), 'é', 'e'), 'è', 'e'))" />
 		 	</xsl:attribute>
 		 	<skos:prefLabel><xsl:value-of select="."/></skos:prefLabel>
 		 	<rdfs:label><xsl:value-of select="."/></rdfs:label>
 		 	<dc:creator rdf:resource="{$output_catalog_URI}" />			
		</skos:Concept>
	</xsl:template>	
	<xsl:template match="channel/item[*]/enclosure|r:channel/r:item[*]/r:enclosure" mode="distribution_instance">
		<xsl:choose>
			<xsl:when test="../guid|../r:guid">
				<dcat:Distribution>
					<xsl:attribute name="about" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">				
		    			<xsl:value-of select="concat($output_dataset_base_URI, substring-after(../guid, $input_dataset_base_URI), '/distribution/', substring(substring-after(., $input_distribution_base_URI), 0, string-length(substring-after(., $input_distribution_base_URI))-3) )" />
		 		 	</xsl:attribute>
		 		 	<dcat:accessURL>
		 		 		<xsl:attribute name="resource" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">				
		    				<xsl:value-of select="." />
		 		 		</xsl:attribute>
		 		 	</dcat:accessURL>
		 		 	<void:format>			
		    				<xsl:value-of select="substring(substring-after(., $input_distribution_base_URI), string-length(substring-after(., $input_distribution_base_URI))-2)" />
		 		 	</void:format>
		 		 			 		 	
				</dcat:Distribution>		
			</xsl:when> 
			<xsl:when test="../link|../r:link">
				<dcat:Distribution>
					<xsl:attribute name="about" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">				
		    			<xsl:value-of select="concat($output_dataset_base_URI, substring-after(../link, $input_dataset_base_URI), '/distribution/', substring-after(., $input_distribution_base_URI))" />
		 		 	</xsl:attribute>
		 		 	<dcat:accessURL>
		 		 		<xsl:attribute name="resource" namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#">				
		    				<xsl:value-of select="concat($output_dataset_base_URI, substring-after(../link, $input_dataset_base_URI), '/distribution/', substring-after(., $input_distribution_base_URI))" />
		 		 		</xsl:attribute>
		 		 	</dcat:accessURL>
				</dcat:Distribution>		
			</xsl:when>			
		</xsl:choose>		
	</xsl:template>	
	<!-- utility templates -->
	<xsl:template match="channel/link|r:channel/r:link" />
	<xsl:template match="channel/item|r:channel/r:item" />
	<xsl:template match="item/guid|r:item/r:guid">
		<foaf:homepage rdf:resource="{.}"/>
	</xsl:template>
	<xsl:template match="item/link|r:item/r:link" />
<!-- 	<xsl:template name="date"> -->
<!-- 		<xsl:variable name="m" select="substring(., 9, 3)" /> -->
<!-- 		<xsl:value-of select="substring(., 13, 4)" /> -->
<!-- 		- -->
<!-- 		<xsl:choose> -->
<!-- 			<xsl:when test="$m='Jan'"> -->
<!-- 				01 -->
<!-- 			</xsl:when> -->
<!-- 			<xsl:when test="$m='Feb'"> -->
<!-- 				02 -->
<!-- 			</xsl:when> -->
<!-- 			<xsl:when test="$m='Mar'"> -->
<!-- 				03 -->
<!-- 			</xsl:when> -->
<!-- 			<xsl:when test="$m='Apr'"> -->
<!-- 				04 -->
<!-- 			</xsl:when> -->
<!-- 			<xsl:when test="$m='May'"> -->
<!-- 				05 -->
<!-- 			</xsl:when> -->
<!-- 			<xsl:when test="$m='Jun'"> -->
<!-- 				06 -->
<!-- 			</xsl:when> -->
<!-- 			<xsl:when test="$m='Jul'"> -->
<!-- 				07 -->
<!-- 			</xsl:when> -->
<!-- 			<xsl:when test="$m='Aug'"> -->
<!-- 				08 -->
<!-- 			</xsl:when> -->
<!-- 			<xsl:when test="$m='Sep'"> -->
<!-- 				09 -->
<!-- 			</xsl:when> -->
<!-- 			<xsl:when test="$m='Oct'"> -->
<!-- 				10 -->
<!-- 			</xsl:when> -->
<!-- 			<xsl:when test="$m='Nov'"> -->
<!-- 				11 -->
<!-- 			</xsl:when> -->
<!-- 			<xsl:when test="$m='Dec'"> -->
<!-- 				12 -->
<!-- 			</xsl:when> -->
<!-- 			<xsl:otherwise> -->
<!-- 				00 -->
<!-- 			</xsl:otherwise> -->
<!-- 		</xsl:choose> -->
<!-- 		- -->
<!-- 		<xsl:value-of select="substring(., 6, 2)" /> -->
<!-- 		T -->
<!-- 		<xsl:value-of select="substring(., 18, 8)" /> -->
<!-- 	</xsl:template> -->
	<xsl:template name="removeTags">
		<xsl:param name="html" select="." />
		<xsl:choose>
			<xsl:when test="contains($html,'&lt;')">
				<xsl:call-template name="removeEntities">
					<xsl:with-param name="html" select="substring-before($html,'&lt;')" />
				</xsl:call-template>
				<xsl:call-template name="removeTags">
					<xsl:with-param name="html" select="substring-after($html, '&gt;')" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="removeEntities">
					<xsl:with-param name="html" select="$html" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="removeEntities">
		<xsl:param name="html" select="." />
		<xsl:choose>
			<xsl:when test="contains($html,'&amp;')">
				<xsl:value-of select="substring-before($html,'&amp;')" />
				<xsl:variable name="x"
					select="substring-before($html,'&amp;')" />
				<xsl:variable name="c"
					select="substring-before(substring-after($html,'&amp;'),';')" />
				<xsl:choose>
					<xsl:when test="$c='nbsp'"> </xsl:when>
					<xsl:when test="$c='lt'">&lt;</xsl:when>
					<xsl:when test="$c='gt'">&gt;</xsl:when>
					<xsl:when test="$c='amp'">&amp;</xsl:when>
					<xsl:when test="$c='quot'">"</xsl:when>
					<xsl:when test="$c='apos'">'</xsl:when>
					<xsl:when test="$c='agrave'">à</xsl:when>
					<xsl:when test="$c='egrave'">è</xsl:when>
					<xsl:when test="$c='ugrave'">ù</xsl:when>
					<xsl:when test="$c='ograve'">ò</xsl:when>
					<xsl:when test="$c='rsquo'">'</xsl:when>
					<xsl:when test="$c='#39'">'</xsl:when>
					<xsl:when test="$c='#039'">'</xsl:when>
					<xsl:otherwise>??</xsl:otherwise>
				</xsl:choose>
				<xsl:call-template name="removeTags">
					<xsl:with-param name="html" select="substring-after(substring-after($html, concat(substring-before($html,'&amp;'), '&amp;' ,substring-before(substring-after($html,'&amp;'),';'))), ';')" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$html" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:transform>	