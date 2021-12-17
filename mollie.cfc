<!---
	mollie.cfc - Wrapper für Mollie API
--->

<cfcomponent displayname="mollie" output="false" hint="Mollie API v2 Wrapper">

    <!--- Pseudo-constructor --->
    <cfset variables.instance = { key = '' } />

 	<cffunction name="init" access="public" output="false" returntype="any" hint="I am the constructor method">
        <cfargument name="key" required="true" type="string" hint="I am the Mollie API key." />
       	<cfscript>
            variables.instance.key = arguments.key;
            variables.instance.baseUrl = "https://api.mollie.com/v2";
       	</cfscript>
   		<cfreturn this />
   	</cffunction>


    <cffunction name="GetNewResponse" access="public" localmode="modern" returntype="struct" output="false" hint="I return a new API response struct.">
       <!--- Create new API response. --->
       <cfset response = { Success = true, Errors = [], Data = "" } />

       <!--- Return the empty response object. --->
       <cfreturn response />
    </cffunction>
		
    
    <cffunction name="createPayment" localmode="modern" access="public" output="false" returntype="any" hint="">
        <cfargument name="currency" type="string" required="true" />
        <cfargument name="value" type="string" required="true" />
        <cfargument name="description" type="string" required="true" />
        <cfargument name="redirectUrl" type="string" required="true" />

        <cfargument name="webhookUrl" type="string" required="false" />
        <cfargument name="locale" type="string" required="false" />
        <cfargument name="metadata" type="array" required="false" />
        <cfargument name="method" type="string" required="false" />

        <cfset response = this.GetNewResponse() />
        <cfset response.success = true />

        
        <cfscript>
            dataFields = {};
            dataFields['Globals'] = {};

            dataFields.Globals['amount'] = {};
            dataFields.Globals.amount['currency'] = arguments.currency;
            dataFields.Globals.amount['value'] = NumberFormat(arguments.value, "9.00");
            
            dataFields.Globals['description'] = arguments.description;
            dataFields.Globals['redirectUrl'] = arguments.redirectUrl;

            if ( structKeyExists(arguments, "webhookUrl") ) {
                dataFields.Globals['webhookUrl'] = arguments.webhookUrl;
            }

            if ( structKeyExists(arguments, "locale") ) {
                dataFields.Globals['locale'] = arguments.locale;
            }
            
            if ( structKeyExists(arguments, "metadata") ) {
                if ( arguments.metadata.len() GT 0 ) {
                    dataFields.Globals['metadata'] = [];
                    for (currentIndex in arguments.metadata) {
                        dataFields.Globals['metadata'].append( currentIndex );
                    }
                }
            }

            if ( structKeyExists(arguments, "method") ) {
                if ( arguments.method.len() GT 0 ) {

                    dataFields.Globals['method'] = [];
                    for (item in listToArray(arguments.method, ",")) { 
                        dataFields.Globals['method'].append( item );
                    } 
                }
            }
        </cfscript>

        <cfscript>
            messageBody = {};
            messageBody = serializejson(dataFields.Globals);
        </cfscript>

       
        <cftry>
            <cfhttp result="mollieresult" method="POST" charset="utf-8" url="#variables.instance.baseUrl#/payments">
                <cfhttpparam type="header" name="Authorization" value="Bearer #variables.instance.key#" />
                <cfhttpparam type="header" name="Content-Type" value="application/json" />
                <cfhttpparam type="body" name="field" value='#messageBody#' />
            </cfhttp>
            <cfset response.data = mollieresult />
            <cfset response.body = messageBody />
            <cflog file="mollie" text="createPayment: #serializeJSON( mollieresult )#" />
            <cfcatch type="any">
                <cfset response.success = false />
                <cfset response.error = cfcatch.message />
                
                <cflog file="mollie" text="Error in createPayment: #serializeJSON( cfcatch )#" />
            </cfcatch>
        </cftry>

        <cfreturn response />
    
    </cffunction>

    <cffunction name="getPayment" localmode="modern" access="public" output="false" returntype="any" hint="">
        <cfargument name="id" type="string" required="true" />
        <cfargument name="testmode" type="boolean" default="false" required="false" />
        
        <cfset response = this.GetNewResponse() />
        <cfset response.success = true />
       
        <cftry>
            <cfhttp result="mollieresult" method="GET" charset="utf-8" url="#variables.instance.baseUrl#/payments/#arguments.id#">
                <cfhttpparam type="header" name="Authorization" value="Bearer #variables.instance.key#" />
            </cfhttp>
            <cfset response.data = mollieresult />
            <cfcatch type="any">
                <cfset response.success = false />
                <cfset response.error = cfcatch.message />
                
                <cflog file="mollie" text="Error in getPayment: #serializeJSON( cfcatch )#" />
            </cfcatch>
        </cftry>

        <cfreturn response />
    </cffunction>

    <cffunction name="updatePayment" localmode="modern" access="public" output="false" returntype="any" hint="">
        <cfargument name="id" type="string" required="true" />

        <cfargument name="description" type="string" required="false" />
        <cfargument name="redirectUrl" type="string" required="false" />
        <cfargument name="webhookUrl" type="string" required="false" />
        <cfargument name="metadata" type="array" required="false" />
        <cfargument name="method" type="string" required="false" />
        <cfargument name="locale" type="string" required="false" />

        <!--- payment method-specific parameters --->
        <cfargument name="billingEmail" type="string" required="false" />
        <cfargument name="dueDate" type="string" required="false" />
        <cfargument name="issuer" type="string" required="false" />



        <cfset response = this.GetNewResponse() />
        <cfset response.success = true />

        
        <cfscript>
            dataFields = {};
            dataFields['Globals'] = {};

            if ( structKeyExists(arguments, "description") ) {
                dataFields.Globals['description'] = arguments.description;
            }

            if ( structKeyExists(arguments, "redirectUrl") ) {
                dataFields.Globals['redirectUrl'] = arguments.redirectUrl;
            }

            if ( structKeyExists(arguments, "webhookUrl") ) {
                dataFields.Globals['webhookUrl'] = arguments.webhookUrl;
            }

            if ( structKeyExists(arguments, "metadata") ) {
                if ( arguments.metadata.len() GT 0 ) {
                    dataFields.Globals['metadata'] = [];
                    for (currentIndex in arguments.metadata) {
                        dataFields.Globals['metadata'].append( currentIndex );
                    }
                }
            }

            if ( structKeyExists(arguments, "method") ) {
                dataFields.Globals['method'] = arguments.locale;
            }

            if ( structKeyExists(arguments, "locale") ) {
                dataFields.Globals['locale'] = arguments.locale;
            }

            if ( structKeyExists(arguments, "billingEmail") ) {
                dataFields.Globals['billingEmail'] = arguments.locale;
            }

            if ( structKeyExists(arguments, "dueDate") ) {
                dataFields.Globals['dueDate'] = arguments.locale;
            }

            if ( structKeyExists(arguments, "issuer") ) {
                dataFields.Globals['issuer'] = arguments.locale;
            }
            
        </cfscript>

        <cfscript>
            messageBody = {};
            messageBody = serializejson(dataFields.Globals);
        </cfscript>

       
        <cftry>
            <cfhttp result="mollieresult" method="PATCH" charset="utf-8" url="#variables.instance.baseUrl#/#arguments.id#">
                <cfhttpparam type="header" name="Authorization" value="Bearer #variables.instance.key#" />
                <cfhttpparam type="header" name="Content-Type" value="application/json" />
                <cfhttpparam type="body" name="field" value='#messageBody#' />
            </cfhttp>
            <cfset response.data = mollieresult />
            <cfset response.body = messageBody />
            <cflog file="mollie" text="updatePayment: #serializeJSON( mollieresult )#" />
            <cfcatch type="any">
                <cfset response.success = false />
                <cfset response.error = cfcatch.message />
                
                <cflog file="mollie" text="Error in updatePayment: #serializeJSON( cfcatch )#" />
            </cfcatch>
        </cftry>

        <cfreturn response />
    
    </cffunction>

    <cffunction name="cancelPayment" localmode="modern" access="public" output="false" returntype="any" hint="">
        <cfargument name="id" type="string" required="true" />
        <cfargument name="testmode" type="boolean" default="false" required="false" />
        
        <cfset response = this.GetNewResponse() />
        <cfset response.success = true />
       
        <cftry>
            <cfhttp result="mollieresult" method="DELETE" charset="utf-8" url="#variables.instance.baseUrl#/payments/#arguments.id#">
                <cfhttpparam type="header" name="Authorization" value="Bearer #variables.instance.key#" />
            </cfhttp>
            <cfset response.data = mollieresult />
            <cfcatch type="any">
                <cfset response.success = false />
                <cfset response.error = cfcatch.message />
                
                <cflog file="mollie" text="Error in cancelPayment: #serializeJSON( cfcatch )#" />
            </cfcatch>
        </cftry>

        <cfreturn response />
    </cffunction>

    <cffunction name="listPayments" localmode="modern" access="public" output="false" returntype="any" hint="">
        <cfargument name="from" type="string" required="false" />
        <cfargument name="limit" type="numeric" required="false" />

        <cfargument name="profileId" type="string" required="false" />
        <cfargument name="testmode" type="boolean" default="false" required="false" />
        
        <cfset response = this.GetNewResponse() />
        <cfset response.success = true />

        <cfscript>
            dataFields = {};
            dataFields['Globals'] = {};

            if ( structKeyExists(arguments, "from") ) {
                dataFields.Globals['from'] = arguments.from;
            }

            if ( structKeyExists(arguments, "limit") ) {
                dataFields.Globals['limit'] = arguments.limit;
            }

            if ( structKeyExists(arguments, "profileId") ) {
                dataFields.Globals['profileId'] = arguments.profileId;
            }

            if ( structKeyExists(arguments, "testmode") ) {
                dataFields.Globals['testmode'] = arguments.testmode;
            }
            
        </cfscript>

        <cfscript>
            messageBody = {};
            messageBody = serializejson(dataFields.Globals);
        </cfscript>
       
        <cftry>
            <cfhttp result="mollieresult" method="GET" charset="utf-8" url="#variables.instance.baseUrl#/payments">
                <cfhttpparam type="header" name="Authorization" value="Bearer #variables.instance.key#" />
                <cfhttpparam type="header" name="Content-Type" value="application/json" />
                <cfhttpparam type="body" name="field" value='#messageBody#' />
            </cfhttp>
            <cfset response.data = mollieresult />
            <cfset response.body = messageBody />
            <cfcatch type="any">
                <cfset response.success = false />
                <cfset response.error = cfcatch.message />
                
                <cflog file="mollie" text="Error in listPayments: #serializeJSON( cfcatch )#" />
            </cfcatch>
        </cftry>

        <cfreturn response />
    </cffunction>


</cfcomponent>
