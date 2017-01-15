<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:sr="http://www.w3.org/2005/sparql-results#" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:vcard="http://www.w3.org/2006/vcard/ns#" 
xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:adms="http://www.w3.org/ns/adms#" xmlns:dct="http://purl.org/dc/terms/" xmlns:dcat="http://www.w3.org/ns/dcat#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:locn="http://www.w3.org/ns/locn#" xmlns:owl="http://www.w3.org/2002/07/owl#" xmlns:schema="http://schema.org/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:skos="http://www.w3.org/2004/02/skos/core#" xmlns:spdx="http://spdx.org/rdf/terms#" xmlns:vcard="http://www.w3.org/2006/vcard/ns#" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:gn-fn-metadata="http://geonetwork-opensource.org/xsl/functions/metadata" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:saxon="http://saxon.sf.net/" xmlns:fn-rdf="http://geonetwork-opensource.org/xsl/functions/rdf" version="2.0" extension-element-prefixes="saxon">
	<!-- Tell the XSL processor to output XML. -->
	<xsl:output method="xml" indent="yes"/>
	<!-- Default language for plain literals. -->
	<xsl:variable name="defaultLang">nl</xsl:variable>
	<!-- dcat:Catalog -->
	<xsl:template match="/">
		<xsl:variable name="results" select="/sr:sparql/sr:results/sr:result"/>
		<xsl:variable name="catalogs" select="$results[sr:binding[@name='predicate']/sr:uri = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type' and
																		sr:binding[@name='object']/sr:uri = 'http://www.w3.org/ns/dcat#Catalog']"/>
		<rdf:RDF>
			<!-- Set the xsi:schemaLocation attribute, used for validation -->
			<xsl:attribute name="xsi:schemaLocation" select="'http://www.w3.org/1999/02/22-rdf-syntax-ns# ../schema/rdf.xsd'"/>
			<xsl:for-each select="$catalogs">
				<xsl:variable name="catalogURI" select="./sr:binding[@name='subject']/sr:uri"/>
				<dcat:Catalog rdf:about="{$catalogURI}">
					<!-- dct:title -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="$catalogURI"/>
						<xsl:with-param name="predicate" select="fn:QName('http://purl.org/dc/terms/','dct:title')"/>
					</xsl:call-template>
					<!-- dct:description -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="$catalogURI"/>
						<xsl:with-param name="predicate" select="fn:QName('http://purl.org/dc/terms/','dct:description')"/>
					</xsl:call-template>
					<!-- dct:publisher -->
					<xsl:call-template name="agents">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="agentURIs" select="$results[sr:binding[@name='predicate']/sr:uri = 'http://purl.org/dc/terms/publisher' and
											sr:binding[@name='subject']/sr:uri = $catalogURI]/sr:binding[@name='object']/sr:uri"/>
						<xsl:with-param name="predicate" select="fn:QName('http://purl.org/dc/terms/','dct:publisher')"/>
					</xsl:call-template>
					<!-- dcat:dataset -->
					<xsl:call-template name="datasets">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="datasetURIs" select="$results[sr:binding[@name='predicate']/sr:uri = 'http://www.w3.org/ns/dcat#dataset' and
											sr:binding[@name='subject']/sr:uri = $catalogURI]/sr:binding[@name='object']/sr:uri"/>
						<xsl:with-param name="predicate" select="fn:QName('http://www.w3.org/ns/dcat#','dcat:dataset')"/>
					</xsl:call-template>
				</dcat:Catalog>
			</xsl:for-each>
			<!-- if no catalog information found -->
			<xsl:if test="fn:count($catalogs) = 0">
				<!-- dcat:dataset -->
				<dcat:Catalog>
					<dct:title>Put here the catalog title</dct:title>
					<dct:description>Put here the catalog description</dct:description>
					<dct:publisher>
						<foaf:Agent rdf:about="http://purl.org/mydomain/myidentifer">
							<foaf:name>Put here the publisher name</foaf:name>
						</foaf:Agent>
					</dct:publisher>
					<xsl:call-template name="datasets">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="datasetURIs" select="$results[sr:binding[@name='predicate']/sr:uri = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type' and
																					  sr:binding[@name='object']/sr:uri = 'http://www.w3.org/ns/dcat#Dataset']/sr:binding[@name='subject']/sr:uri"/>
						<xsl:with-param name="predicate" select="fn:QName('http://www.w3.org/ns/dcat#','dcat:dataset')"/>
					</xsl:call-template>
				</dcat:Catalog>
			</xsl:if>
		</rdf:RDF>
	</xsl:template>
	<!-- dcat:Dataset -->
	<xsl:template name="datasets">
		<xsl:param name="results"/>
		<xsl:param name="datasetURIs"/>
		<xsl:param name="predicate"/>
		<xsl:for-each select="$datasetURIs">
			<xsl:element name="{$predicate}">
				<dcat:Dataset rdf:about="{.}">
					<!-- dct:title -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://purl.org/dc/terms/','dct:title')"/>
					</xsl:call-template>
					<!-- dct:description -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://purl.org/dc/terms/','dct:description')"/>
					</xsl:call-template>
					<!-- dcat:contactPoint -->
					<xsl:call-template name="organizations">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="organizationURIs" select="$results[sr:binding[@name='predicate']/sr:uri = 'http://www.w3.org/ns/dcat#contactPoint' and
											sr:binding[@name='subject']/sr:uri = $datasetURIs]/sr:binding[@name='object']/*"/>
						<xsl:with-param name="predicate" select="fn:QName('http://www.w3.org/ns/dcat#','dcat:contactPoint')"/>
					</xsl:call-template>
					<!-- dcat:distribution -->
					<xsl:call-template name="distributions">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="distributionURIs" select="$results[sr:binding[@name='predicate']/sr:uri = 'http://www.w3.org/ns/dcat#distribution' and
											sr:binding[@name='subject']/sr:uri = $datasetURIs]/sr:binding[@name='object']/*"/>
						<xsl:with-param name="predicate" select="fn:QName('http://www.w3.org/ns/dcat#','dcat:distribution')"/>
					</xsl:call-template>
					<!-- dcat:keyword -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://www.w3.org/ns/dcat#','dcat:keyword')"/>
					</xsl:call-template>
					<!-- dct:publisher -->
					<xsl:call-template name="agents">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="agentURIs" select="$results[sr:binding[@name='predicate']/sr:uri = 'http://purl.org/dc/terms/publisher' and
											sr:binding[@name='subject']/sr:uri = $datasetURIs]/sr:binding[@name='object']/*"/>
						<xsl:with-param name="predicate" select="fn:QName('http://purl.org/dc/terms/publisher','dct:publisher')"/>
					</xsl:call-template>
					<!-- dcat:theme -->
					<xsl:call-template name="concepts">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="conceptURIs" select="$results[sr:binding[@name='predicate']/sr:uri = 'http://www.w3.org/ns/dcat#theme' and
											sr:binding[@name='subject']/sr:uri = $datasetURIs]/sr:binding[@name='object']/*"/>
						<xsl:with-param name="predicate" select="fn:QName('http://www.w3.org/ns/dcat#','dcat:theme')"/>
					</xsl:call-template>
					<!-- dct:accessRights -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://purl.org/dc/terms/','dct:accessRights')"/>
					</xsl:call-template>
					<!-- dct:conformsTo -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://purl.org/dc/terms/','dct:conformsTo')"/>
					</xsl:call-template>
					<!-- foaf:page -->
					<xsl:call-template name="documents">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="documentURIs" select="$results[sr:binding[@name='predicate']/sr:uri = 'http://xmlns.com/foaf/0.1/page' and
											sr:binding[@name='subject']/sr:uri = $datasetURIs]/sr:binding[@name='object']/*"/>
						<xsl:with-param name="predicate" select="fn:QName('http://xmlns.com/foaf/0.1/','foaf:page')"/>
					</xsl:call-template>
					<!-- dct:accrualPeriod -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://purl.org/dc/terms/','dct:accrualPeriod')"/>
					</xsl:call-template>
					<!-- dct:hasVersion -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://purl.org/dc/terms/','dct:hasVersion')"/>
					</xsl:call-template>
					<!-- dct:identifier -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://purl.org/dc/terms/','dct:identifier')"/>
					</xsl:call-template>
					<!-- dct:isVersionOf-->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://purl.org/dc/terms/','dct:isVersionOf')"/>
					</xsl:call-template>
					<!-- dcat:landingPage-->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://www.w3.org/ns/dcat#','dcat:landingPage')"/>
					</xsl:call-template>
					<!-- dct:language-->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://purl.org/dc/terms/','dct:language')"/>
					</xsl:call-template>
					<!-- adms:identifier -->
					<xsl:call-template name="identifiers">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="identifierURIs" select="$results[sr:binding[@name='predicate']/sr:uri = 'http://www.w3.org/ns/adms#identifier' and
											sr:binding[@name='subject']/sr:uri = $datasetURIs]/sr:binding[@name='object']/*"/>
						<xsl:with-param name="predicate" select="fn:QName('http://www.w3.org/ns/adms#','adms:identifier')"/>
					</xsl:call-template>
					<!-- dct:provenance-->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://purl.org/dc/terms/','dct:provenance')"/>
					</xsl:call-template>
					<!-- dct:relation-->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://purl.org/dc/terms/','dct:relation')"/>
					</xsl:call-template>
					<!-- dct:issued-->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://purl.org/dc/terms/','dct:issued')"/>
					</xsl:call-template>
					<!-- adms:sample -->
					<xsl:call-template name="distributions">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="distributionURIs" select="$results[sr:binding[@name='predicate']/sr:uri = 'http://www.w3.org/ns/adms#sample' and
											sr:binding[@name='subject']/sr:uri = $datasetURIs]/sr:binding[@name='object']/*"/>
						<xsl:with-param name="predicate" select="fn:QName('http://www.w3.org/ns/adms#','adms:sample')"/>
					</xsl:call-template>
					<!-- dct:source-->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://purl.org/dc/terms/','dct:source')"/>
					</xsl:call-template>
					<!-- dct:spatial -->
					<xsl:call-template name="locations">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="locationURIs" select="$results[sr:binding[@name='predicate']/sr:uri = 'http://purl.org/dc/terms/spatial' and
											sr:binding[@name='subject']/sr:uri = $datasetURIs]/sr:binding[@name='object']/*"/>
						<xsl:with-param name="predicate" select="fn:QName('http://purl.org/dc/terms/','dct:spatial')"/>
					</xsl:call-template>
					<!-- dct:temporal -->
					<xsl:call-template name="periods">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="periodURIs" select="$results[sr:binding[@name='predicate']/sr:uri = 'http://purl.org/dc/terms/temporal' and
											sr:binding[@name='subject']/sr:uri = $datasetURIs]/sr:binding[@name='object']/*"/>
						<xsl:with-param name="predicate" select="fn:QName('http://purl.org/dc/terms/','dct:temporal')"/>
					</xsl:call-template>
					<!-- dct:type-->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://purl.org/dc/terms/','dct:type')"/>
					</xsl:call-template>
					<!-- dct:modified-->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://purl.org/dc/terms/','dct:modified')"/>
					</xsl:call-template>
					<!-- owl:versionInfo -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://www.w3.org/2002/07/owl#','owl:versionInfo')"/>
					</xsl:call-template>
					<!-- adms:versionNotes -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://www.w3.org/ns/adms#','adms:versionNotes')"/>
					</xsl:call-template>
				</dcat:Dataset>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>
	<!-- foaf:Agent -->
	<xsl:template name="agents">
		<xsl:param name="results"/>
		<xsl:param name="agentURIs"/>
		<xsl:param name="predicate"/>
		<!-- for each agent -->
		<xsl:for-each select="$agentURIs">
			<xsl:element name="{$predicate}">
				<foaf:Agent rdf:about="{.}">
					<!-- foaf:name -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://xmlns.com/foaf/0.1/','foaf:name')"/>
					</xsl:call-template>
					<!-- dct:type -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://purl.org/dc/terms/','dct:type')"/>
					</xsl:call-template>
				</foaf:Agent>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>
	<!-- foaf:Document -->
	<xsl:template name="documents">
		<xsl:param name="results"/>
		<xsl:param name="documentURIs"/>
		<xsl:param name="predicate"/>
		<!-- for each agent -->
		<xsl:for-each select="$documentURIs">
			<xsl:element name="{$predicate}">
				<foaf:Document rdf:about="{.}">
					<!-- foaf:name -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://xmlns.com/foaf/0.1/','foaf:name')"/>
					</xsl:call-template>
					<!-- dct:type -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://purl.org/dc/terms/','dct:type')"/>
					</xsl:call-template>
				</foaf:Document>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>
	<!-- dct:Location -->
	<xsl:template name="locations">
		<xsl:param name="results"/>
		<xsl:param name="locationURIs"/>
		<xsl:param name="predicate"/>
		<xsl:for-each select="$locationURIs">
			<xsl:element name="{$predicate}">
				<dct:Location rdf:about="{.}">
					<!-- locn:geometry (TODO: now still dct:geometry) -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://www.w3.org/ns/locn#','locn:geometry')"/>
					</xsl:call-template>
					<!-- skos:prefLabel -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://www.w3.org/2004/02/skos/core#','skos:prefLabel')"/>
					</xsl:call-template>
				</dct:Location>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>
	<!-- dct:PeriodOfTime -->
	<xsl:template name="periods">
		<xsl:param name="results"/>
		<xsl:param name="periodURIs"/>
		<xsl:param name="predicate"/>
		<xsl:for-each select="$periodURIs">
			<xsl:element name="{$predicate}">
				<dct:PeriodOfTime rdf:about="{.}">
					<!-- locn:geometry (TODO: now still dct:geometry) -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://schema.org/','schema:startDate')"/>
					</xsl:call-template>
					<!-- skos:prefLabel -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://schema.org/','schema:endDate')"/>
					</xsl:call-template>
				</dct:PeriodOfTime>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>
	<!-- skos:Concept -->
	<xsl:template name="concepts">
		<xsl:param name="results"/>
		<xsl:param name="conceptURIs"/>
		<xsl:param name="predicate"/>
		<xsl:for-each select="$conceptURIs">
			<xsl:element name="{$predicate}">
				<skos:Concept rdf:about="{.}">
					<!-- foaf:name -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://xmlns.com/foaf/0.1/','foaf:name')"/>
					</xsl:call-template>
					<!-- dct:type -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://purl.org/dc/terms/','dct:type')"/>
					</xsl:call-template>
				</skos:Concept>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>
	<!-- adms:Identifier -->
	<xsl:template name="identifiers">
		<xsl:param name="results"/>
		<xsl:param name="identifierURIs"/>
		<xsl:param name="predicate"/>
		<xsl:for-each select="$identifierURIs">
			<xsl:element name="{$predicate}">
				<adms:Identifier rdf:about="{.}">
					<!-- skos:notation -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://www.w3.org/2004/02/skos/core#','skos:notation')"/>
					</xsl:call-template>
				</adms:Identifier>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>
	<!-- vcard:Address-->
	<xsl:template name="addresses">
		<xsl:param name="results"/>
		<xsl:param name="addressURIs"/>
		<xsl:param name="predicate"/>
		<xsl:for-each select="$addressURIs">
			<xsl:element name="{$predicate}">
				<vcard:Address rdf:about="{.}">
					<!-- vcard:street-address -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://www.w3.org/2006/vcard/ns#','vcard:street-address')"/>
					</xsl:call-template>
					<!-- vvcard:locality -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://www.w3.org/2006/vcard/ns#','vcard:locality')"/>
					</xsl:call-template>
					<!-- vcard:postal-code -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://www.w3.org/2006/vcard/ns#','vcard:postal-code')"/>
					</xsl:call-template>
					<!-- vcard:country-name -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://www.w3.org/2006/vcard/ns#','vcard:country-name')"/>
					</xsl:call-template>
				</vcard:Address>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>
	<!-- vcard:Organization -->
	<xsl:template name="organizations">
		<xsl:param name="results"/>
		<xsl:param name="organizationURIs"/>
		<xsl:param name="predicate"/>
		<xsl:for-each select="$organizationURIs">
			<xsl:element name="{$predicate}">
				<vcard:Organization rdf:about="{.}">
					<!-- vcard:fn -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://www.w3.org/2006/vcard/ns#','vcard:fn')"/>
					</xsl:call-template>
					<!-- vcard:organization-name -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://www.w3.org/2006/vcard/ns#','vcard:organization-name')"/>
					</xsl:call-template>
					<!-- vcard:hasAddress -->
					<xsl:call-template name="addresses">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="addressURIs" select="$results[sr:binding[@name='predicate']/sr:uri = 'http://www.w3.org/2006/vcard/ns#hasAddress' and
											sr:binding[@name='subject']/sr:uri = $organizationURIs]/sr:binding[@name='object']/*"/>
						<xsl:with-param name="predicate" select="fn:QName('http://www.w3.org/2006/vcard/ns#','vcard:hasAddress')"/>
					</xsl:call-template>
					<!-- vcard:hasEmail -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://www.w3.org/2006/vcard/ns#','vcard:hasEmail')"/>
					</xsl:call-template>
					<!-- vcard:hasTelephone -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://www.w3.org/2006/vcard/ns#','vcard:hasTelephone')"/>
					</xsl:call-template>
					<!-- dct:type -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://purl.org/dc/terms/','dct:type')"/>
					</xsl:call-template>
				</vcard:Organization>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>
	<!-- dcat:Distribution -->
	<xsl:template name="distributions">
		<xsl:param name="results"/>
		<xsl:param name="distributionURIs"/>
		<xsl:param name="predicate"/>
		<xsl:for-each select="$distributionURIs">
			<xsl:element name="{$predicate}">
				<dcat:Distribution rdf:about="{.}">
					<!-- dcat:accessURL -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://www.w3.org/ns/dcat#','dcat:accessURL')"/>
					</xsl:call-template>
					<!-- dct:description -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://purl.org/dc/terms/','dct:description')"/>
					</xsl:call-template>
					<!-- dct:format -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://purl.org/dc/terms/','dct:format')"/>
					</xsl:call-template>
					<!-- dct:license -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://purl.org/dc/terms/','dct:license')"/>
					</xsl:call-template>
					<!-- dcat:byteSize -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://www.w3.org/ns/dcat#','dcat:byteSize')"/>
					</xsl:call-template>
					<!-- spdx:checksum -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://xmlns.com/foaf/0.1/','spdx:checksum')"/>
					</xsl:call-template>
					<!-- foaf:page -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://xmlns.com/foaf/0.1/','foaf:page')"/>
					</xsl:call-template>
					<!-- dcat:downloadURL -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://www.w3.org/ns/dcat#','dcat:downloadURL')"/>
					</xsl:call-template>
					<!-- dct:language -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://purl.org/dc/terms/','dct:language')"/>
					</xsl:call-template>
					<!-- dct:conformsTo-->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://purl.org/dc/terms/','dct:conformsTo')"/>
					</xsl:call-template>
					<!-- dcat:mediaType -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://www.w3.org/ns/dcat#','dcat:mediaType')"/>
					</xsl:call-template>
					<!-- dct:issued -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://purl.org/dc/terms/','dct:issued')"/>
					</xsl:call-template>
					<!-- dct:rights -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://purl.org/dc/terms/','dct:rights')"/>
					</xsl:call-template>
					<!-- adms:status -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://www.w3.org/ns/adms#','adms:status')"/>
					</xsl:call-template>
					<!-- dct:title -->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://purl.org/dc/terms/','dct:title')"/>
					</xsl:call-template>
					<!-- dct:modified-->
					<xsl:call-template name="properties">
						<xsl:with-param name="results" select="$results"/>
						<xsl:with-param name="subject" select="."/>
						<xsl:with-param name="predicate" select="fn:QName('http://purl.org/dc/terms/','dct:modified')"/>
					</xsl:call-template>
				</dcat:Distribution>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>
	<!-- simple properties -->
	<xsl:template name="properties">
		<xsl:param name="results"/>
		<xsl:param name="subject"/>
		<xsl:param name="predicate"/>
		<xsl:variable name="predicateString" select="concat(fn:namespace-uri-from-QName($predicate),fn:local-name-from-QName($predicate))"/>
		<!-- Select all objects matching the subject and predicate pattern -->
		<xsl:for-each select="$results[sr:binding[@name='subject']/* = $subject and
											sr:binding[@name='predicate']/sr:uri = $predicateString]/sr:binding[@name='object']">
			<xsl:choose>
				<!-- plain literals -->
				<xsl:when test="./sr:literal">
					<xsl:element name="{$predicate}">
						<!-- rdf:datatype attribute -->
						<xsl:if test="fn:exists(./sr:literal/@datatype)">
							<xsl:attribute name="rdf:datatype" select="./sr:literal/@datatype"/>
						</xsl:if>
						<!-- language tag attriburte -->
						<xsl:choose>
							<xsl:when test="fn:exists(./sr:literal/@lang)">
								<xsl:attribute name="xml:lang" select="./sr:literal/@lang"/>
							</xsl:when>
							<xsl:when test="fn:local-name-from-QName($predicate) = ('description', 'title', 'keyword', 'name')">
								<xsl:attribute name="xml:lang" select="$defaultLang"/>
							</xsl:when>
						</xsl:choose>
						<xsl:value-of select="./sr:literal"/>
					</xsl:element>
				</xsl:when>
				<!-- URIs -->
				<xsl:when test="./sr:uri">
					<xsl:element name="{$predicate}">
						<xsl:attribute name="rdf:resource" select="./sr:uri"/>
					</xsl:element>
				</xsl:when>
				<!-- blank nodes -->
				<xsl:when test="./sr:bnode">
					<xsl:element name="{$predicate}">
						<xsl:attribute name="rdf:resource" select="./sr:bnode"/>
					</xsl:element>
				</xsl:when>				
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>