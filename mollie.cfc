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
                <cfif structKeyExists(arguments, "testmode")><cfhttpparam type="url" name="testmode" value="#arguments.testmode#" /></cfif>
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

        <cftry>
            <cfhttp result="mollieresult" method="GET" charset="utf-8" url="#variables.instance.baseUrl#/payments">
                <cfhttpparam type="header" name="Authorization" value="Bearer #variables.instance.key#" />
                <cfif structKeyExists(arguments, "from")><cfhttpparam type="url" name="from" value="#arguments.from#" /></cfif>
                <cfif structKeyExists(arguments, "limit")><cfhttpparam type="url" name="limit" value="#arguments.limit#" /></cfif>
                <cfif structKeyExists(arguments, "profileId")><cfhttpparam type="url" name="profileId" value="#arguments.profielId#" /></cfif>
                <cfif structKeyExists(arguments, "testmode")><cfhttpparam type="url" name="testmode" value="#arguments.testmode#" /></cfif>
            </cfhttp>
            <cfset response.data = mollieresult />
            <cfcatch type="any">
                <cfset response.success = false />
                <cfset response.error = cfcatch.message />
                
                <cflog file="mollie" text="Error in listPayments: #serializeJSON( cfcatch )#" />
            </cfcatch>
        </cftry>

        <cfreturn response />
    </cffunction>

    <!--- Methods API: List payment methods --->
    <cffunction name="listMethods" localmode="modern" access="public" output="false" returntype="any" hint="">
        <cfargument name="sequenceType" type="string" required="false" />
        <cfargument name="locale" type="string" required="false" />
        <cfargument name="currency" type="string" required="false" />
        <cfargument name="value" type="string" required="false" />
        <cfargument name="resource" type="string" required="false" />
        <cfargument name="billingCountry" type="string" required="false" />
        <cfargument name="includeWallets" type="string" required="false" />
        <cfargument name="orderLineCategories" type="string" required="false" />
        <cfargument name="profileId" type="string" required="false" />
        <cfargument name="testmode" type="boolean" default="false" required="false" />
        
        <cfset response = this.GetNewResponse() />
        <cfset response.success = true />

        <cftry>
            <cfhttp result="mollieresult" method="GET" charset="utf-8" url="#variables.instance.baseUrl#/methods">
                <cfhttpparam type="header" name="Authorization" value="Bearer #variables.instance.key#" />
                <cfhttpparam type="url" name="sequenceType" value="#arguments.sequenceType#" />
                
            </cfhttp>
            <cfset response.data = mollieresult />
            <cfcatch type="any">
                <cfset response.success = false />
                <cfset response.error = cfcatch.message />
                
                <cflog file="mollie" text="Error in listMethods: #serializeJSON( cfcatch )#" />
            </cfcatch>
        </cftry>

        <cfreturn response />
    </cffunction>

    <cffunction name="listAllMethods" localmode="modern" access="public" output="false" returntype="any" hint="">
        <cfargument name="locale" type="string" required="false" />
        <cfargument name="currency" type="string" required="false" />
        <cfargument name="value" type="string" required="false" />
        <cfargument name="profileId" type="string" required="false" />
        
        <cfset response = this.GetNewResponse() />
        <cfset response.success = true />

        <cftry>
            <cfhttp result="mollieresult" method="GET" charset="utf-8" url="#variables.instance.baseUrl#/methods/all">
                <cfhttpparam type="header" name="Authorization" value="Bearer #variables.instance.key#" />
                <cfif structKeyExists(arguments, "locale")><cfhttpparam type="url" name="locale" value="#arguments.locale#" /></cfif>
                <cfif structKeyExists(arguments, "currency") AND structKeyExists(arguments, "value")>
                  <cfhttpparam type="url" name="amount[value]" value="#arguments.value#" />
                  <cfhttpparam type="url" name="amount[currency]" value="#arguments.currency#" />
                </cfif>
                <cfif structKeyExists(arguments, "profileId")><cfhttpparam type="url" name="profileId" value="#arguments.profielId#" /></cfif>                
            </cfhttp>
            <cfset response.data = mollieresult />
            <cfcatch type="any">
                <cfset response.success = false />
                <cfset response.error = cfcatch.message />
                
                <cflog file="mollie" text="Error in listAllMethods: #serializeJSON( cfcatch )#" />
            </cfcatch>
        </cftry>

        <cfreturn response />
    </cffunction>

    <cffunction name="getMethod" localmode="modern" access="public" output="false" returntype="any" hint="">
        <cfargument name="id" type="string" required="true" />

        <cfargument name="locale" type="string" required="false" />
        <cfargument name="currency" type="string" required="false" />
        <cfargument name="profileId" type="string" required="false" />
        <cfargument name="testmode" type="boolean" default="false" required="false" />
        
        <cfset response = this.GetNewResponse() />
        <cfset response.success = true />

        <cftry>
            <cfhttp result="mollieresult" method="GET" charset="utf-8" url="#variables.instance.baseUrl#/methods/#arguments.id#">
                <cfhttpparam type="header" name="Authorization" value="Bearer #variables.instance.key#" />
                <cfif structKeyExists(arguments, "locale")><cfhttpparam type="url" name="locale" value="#arguments.locale#" /></cfif>
                <cfif structKeyExists(arguments, "currency")><cfhttpparam type="url" name="currency" value="#arguments.currency#" /></cfif>
                <cfif structKeyExists(arguments, "profileId")><cfhttpparam type="url" name="profileId" value="#arguments.profielId#" /></cfif> 
                <cfif structKeyExists(arguments, "testmode")><cfhttpparam type="url" name="testmode" value="#arguments.testmode#" /></cfif>               
            </cfhttp>
            <cfset response.data = mollieresult />
            <cfcatch type="any">
                <cfset response.success = false />
                <cfset response.error = cfcatch.message />
                
                <cflog file="mollie" text="Error in getMethod: #serializeJSON( cfcatch )#" />
            </cfcatch>
        </cftry>

        <cfreturn response />
    </cffunction>

    <cffunction name="createRefund" localmode="modern" access="public" output="false" returntype="any" hint="">
        <cfargument name="paymentId" type="string" required="true" />
        <cfargument name="currency" type="string" required="true" />
        <cfargument name="value" type="string" required="true" />

        <cfargument name="description" type="string" required="false" />
        <cfargument name="metadata" type="array" required="false" />
        <cfargument name="testmode" type="boolean" default="false" required="false" />
        <cfargument name="reverseRouting" type="boolean" default="false" required="false" />

        <cfset response = this.GetNewResponse() />
        <cfset response.success = true />

        
        <cfscript>
            dataFields = {};
            dataFields['Globals'] = {};

            dataFields.Globals['amount'] = {};
            dataFields.Globals.amount['currency'] = arguments.currency;
            dataFields.Globals.amount['value'] = NumberFormat(arguments.value, "9.00");
            
            if ( structKeyExists(arguments, "description") ) {
                dataFields.Globals['description'] = arguments.description;
            }
            
            if ( structKeyExists(arguments, "metadata") ) {
                if ( arguments.metadata.len() GT 0 ) {
                    dataFields.Globals['metadata'] = [];
                    for (currentIndex in arguments.metadata) {
                        dataFields.Globals['metadata'].append( currentIndex );
                    }
                }
            }

            if ( structKeyExists(arguments, "reverseRouting") ) {
                 dataFields.Globals['reverseRouting'] = arguments.reverseRouting;
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
            <cfhttp result="mollieresult" method="POST" charset="utf-8" url="#variables.instance.baseUrl#/payments/#arguments.paymentId#/refunds">
                <cfhttpparam type="header" name="Authorization" value="Bearer #variables.instance.key#" />
                <cfhttpparam type="header" name="Content-Type" value="application/json" />
                <cfhttpparam type="body" name="field" value='#messageBody#' />
            </cfhttp>
            <cfset response.data = mollieresult />
            <cfset response.body = messageBody />
            <cflog file="mollie" text="createRefund: #serializeJSON( mollieresult )#" />
            <cfcatch type="any">
                <cfset response.success = false />
                <cfset response.error = cfcatch.message />
                
                <cflog file="mollie" text="Error in createRefund: #serializeJSON( cfcatch )#" />
            </cfcatch>
        </cftry>

        <cfreturn response />
    
    </cffunction>

    <cffunction name="getRefund" localmode="modern" access="public" output="false" returntype="any" hint="">
        <cfargument name="id" type="string" required="true" />
        <cfargument name="paymentId" type="string" required="true" />
        <cfargument name="testmode" type="boolean" default="false" required="false" />
        
        <cfset response = this.GetNewResponse() />
        <cfset response.success = true />
       
        <cftry>
            <cfhttp result="mollieresult" method="GET" charset="utf-8" url="#variables.instance.baseUrl#/payments/#arguments.paymentId#/refunds/#arguments.id#">
                <cfhttpparam type="header" name="Authorization" value="Bearer #variables.instance.key#" />
                <cfif structKeyExists(arguments, "testmode")><cfhttpparam type="url" name="testmode" value="#arguments.testmode#" /></cfif>
            </cfhttp>
            <cfset response.data = mollieresult />
            <cfcatch type="any">
                <cfset response.success = false />
                <cfset response.error = cfcatch.message />
                
                <cflog file="mollie" text="Error in getRefund: #serializeJSON( cfcatch )#" />
            </cfcatch>
        </cftry>

        <cfreturn response />
    </cffunction>

    <cffunction name="cancelRefund" localmode="modern" access="public" output="false" returntype="any" hint="">
        <cfargument name="id" type="string" required="true" />
        <cfargument name="paymentId" type="string" required="true" />
        <cfargument name="testmode" type="boolean" default="false" required="false" />
        
        <cfset response = this.GetNewResponse() />
        <cfset response.success = true />
       
        <cftry>
            <cfhttp result="mollieresult" method="DELETE" charset="utf-8" url="#variables.instance.baseUrl#/payments/#arguments.paymentId#/refunds/#arguments.id#">
                <cfhttpparam type="header" name="Authorization" value="Bearer #variables.instance.key#" />
                <cfif structKeyExists(arguments, "testmode")><cfhttpparam type="url" name="testmode" value="#arguments.testmode#" /></cfif>
            </cfhttp>
            <cfset response.data = mollieresult />
            <cfcatch type="any">
                <cfset response.success = false />
                <cfset response.error = cfcatch.message />
                
                <cflog file="mollie" text="Error in cancelRefund: #serializeJSON( cfcatch )#" />
            </cfcatch>
        </cftry>

        <cfreturn response />
    </cffunction>

    <cffunction name="listRefunds" localmode="modern" access="public" output="false" returntype="any" hint="">
        <cfargument name="paymentId" type="string" required="true" />

        <cfargument name="from" type="string" required="false" />
        <cfargument name="limit" type="numeric" required="false" />

        <cfargument name="testmode" type="boolean" default="false" required="false" />
        
        <cfset response = this.GetNewResponse() />
        <cfset response.success = true />

        <cftry>
            <cfhttp result="mollieresult" method="GET" charset="utf-8" url="#variables.instance.baseUrl#/payments/#arguments.paymentId#/refunds">
                <cfhttpparam type="header" name="Authorization" value="Bearer #variables.instance.key#" />
                <cfif structKeyExists(arguments, "from")><cfhttpparam type="url" name="from" value="#arguments.from#" /></cfif>
                <cfif structKeyExists(arguments, "limit")><cfhttpparam type="url" name="limit" value="#arguments.limit#" /></cfif>
                <cfif structKeyExists(arguments, "testmode")><cfhttpparam type="url" name="testmode" value="#arguments.testmode#" /></cfif>
            </cfhttp>
            <cfset response.data = mollieresult />
            <cfcatch type="any">
                <cfset response.success = false />
                <cfset response.error = cfcatch.message />
                
                <cflog file="mollie" text="Error in listRefunds: #serializeJSON( cfcatch )#" />
            </cfcatch>
        </cftry>

        <cfreturn response />
    </cffunction>

    <cffunction name="listAllRefunds" localmode="modern" access="public" output="false" returntype="any" hint="">
        <cfargument name="from" type="string" required="false" />
        <cfargument name="limit" type="numeric" required="false" />

        <cfargument name="profileId" type="string" required="false" />
        <cfargument name="testmode" type="boolean" default="false" required="false" />
        
        <cfset response = this.GetNewResponse() />
        <cfset response.success = true />

        <cftry>
            <cfhttp result="mollieresult" method="GET" charset="utf-8" url="#variables.instance.baseUrl#/refunds">
                <cfhttpparam type="header" name="Authorization" value="Bearer #variables.instance.key#" />
                <cfif structKeyExists(arguments, "from")><cfhttpparam type="url" name="from" value="#arguments.from#" /></cfif>
                <cfif structKeyExists(arguments, "limit")><cfhttpparam type="url" name="limit" value="#arguments.limit#" /></cfif>
                <cfif structKeyExists(arguments, "profileId")><cfhttpparam type="url" name="profileId" value="#arguments.profielId#" /></cfif>
                <cfif structKeyExists(arguments, "testmode")><cfhttpparam type="url" name="testmode" value="#arguments.testmode#" /></cfif>
            </cfhttp>
            <cfset response.data = mollieresult />
            <cfcatch type="any">
                <cfset response.success = false />
                <cfset response.error = cfcatch.message />
                
                <cflog file="mollie" text="Error in listAllRefunds: #serializeJSON( cfcatch )#" />
            </cfcatch>
        </cftry>

        <cfreturn response />
    </cffunction>

</cfcomponent>
