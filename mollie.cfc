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
		
    <!--- 
    ******************************* PAYMENTS API ******************************
    --->

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
            <cfhttp result="mollieresult" method="PATCH" charset="utf-8" url="#variables.instance.baseUrl#/payments/#arguments.id#">
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
        
        <cfset response = this.GetNewResponse() />
        <cfset response.success = true />

        <cftry>
            <cfhttp result="mollieresult" method="GET" charset="utf-8" url="#variables.instance.baseUrl#/payments">
                <cfhttpparam type="header" name="Authorization" value="Bearer #variables.instance.key#" />
                <cfif structKeyExists(arguments, "from")><cfhttpparam type="url" name="from" value="#arguments.from#" /></cfif>
                <cfif structKeyExists(arguments, "limit")><cfhttpparam type="url" name="limit" value="#arguments.limit#" /></cfif>
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

    <!--- 
    ******************************* METHODS API ******************************
    --->

    <cffunction name="listMethods" localmode="modern" access="public" output="false" returntype="any" hint="">
        <cfargument name="sequenceType" type="string" required="false" />
        <cfargument name="locale" type="string" required="false" />
        <cfargument name="currency" type="string" required="false" />
        <cfargument name="value" type="string" required="false" />
        <cfargument name="resource" type="string" required="false" />
        <cfargument name="billingCountry" type="string" required="false" />
        <cfargument name="includeWallets" type="string" required="false" />
        <cfargument name="orderLineCategories" type="string" required="false" />
        
        <cfset response = this.GetNewResponse() />
        <cfset response.success = true />

        <cftry>
            <cfhttp result="mollieresult" method="GET" charset="utf-8" url="#variables.instance.baseUrl#/methods">
                <cfhttpparam type="header" name="Authorization" value="Bearer #variables.instance.key#" />
                <cfif structKeyExists(arguments, "sequenceType")><cfhttpparam type="url" name="sequenceType" value="#arguments.sequenceType#" /></cfif>
                <cfif structKeyExists(arguments, "locale")><cfhttpparam type="url" name="locale" value="#arguments.locale#" /></cfif>
                <cfif structKeyExists(arguments, "currency")><cfhttpparam type="url" name="amount[currency]" value="#arguments.currency#" /></cfif>
                <cfif structKeyExists(arguments, "value")><cfhttpparam type="url" name="amount[value]" value="#arguments.value#" /></cfif>
                <cfif structKeyExists(arguments, "resource")><cfhttpparam type="url" name="resource" value="#arguments.resource#" /></cfif>
                <cfif structKeyExists(arguments, "billingCountry")><cfhttpparam type="url" name="billingCountry" value="#arguments.billingCountry#" /></cfif>
                <cfif structKeyExists(arguments, "includeWallets")><cfhttpparam type="url" name="includeWallets" value="#arguments.includeWallets#" /></cfif>
                <cfif structKeyExists(arguments, "orderLineCategories")><cfhttpparam type="url" name="orderLineCategories" value="#arguments.orderLineCategories#" /></cfif>

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
        
        <cfset response = this.GetNewResponse() />
        <cfset response.success = true />

        <cftry>
            <cfhttp result="mollieresult" method="GET" charset="utf-8" url="#variables.instance.baseUrl#/methods/#arguments.id#">
                <cfhttpparam type="header" name="Authorization" value="Bearer #variables.instance.key#" />
                <cfif structKeyExists(arguments, "locale")><cfhttpparam type="url" name="locale" value="#arguments.locale#" /></cfif>
                <cfif structKeyExists(arguments, "currency")><cfhttpparam type="url" name="currency" value="#arguments.currency#" /></cfif>
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

    <!--- 
    ******************************* REFUNDS API ******************************
    --->

    <cffunction name="createRefund" localmode="modern" access="public" output="false" returntype="any" hint="">
        <cfargument name="paymentId" type="string" required="true" />
        <cfargument name="currency" type="string" required="true" />
        <cfargument name="value" type="string" required="true" />

        <cfargument name="description" type="string" required="false" />
        <cfargument name="metadata" type="array" required="false" />
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
        
        <cfset response = this.GetNewResponse() />
        <cfset response.success = true />
       
        <cftry>
            <cfhttp result="mollieresult" method="GET" charset="utf-8" url="#variables.instance.baseUrl#/payments/#arguments.paymentId#/refunds/#arguments.id#">
                <cfhttpparam type="header" name="Authorization" value="Bearer #variables.instance.key#" />
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
        
        <cfset response = this.GetNewResponse() />
        <cfset response.success = true />

        <cftry>
            <cfhttp result="mollieresult" method="GET" charset="utf-8" url="#variables.instance.baseUrl#/payments/#arguments.paymentId#/refunds">
                <cfhttpparam type="header" name="Authorization" value="Bearer #variables.instance.key#" />
                <cfif structKeyExists(arguments, "from")><cfhttpparam type="url" name="from" value="#arguments.from#" /></cfif>
                <cfif structKeyExists(arguments, "limit")><cfhttpparam type="url" name="limit" value="#arguments.limit#" /></cfif>
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
        
        <cfset response = this.GetNewResponse() />
        <cfset response.success = true />

        <cftry>
            <cfhttp result="mollieresult" method="GET" charset="utf-8" url="#variables.instance.baseUrl#/refunds">
                <cfhttpparam type="header" name="Authorization" value="Bearer #variables.instance.key#" />
                <cfif structKeyExists(arguments, "from")><cfhttpparam type="url" name="from" value="#arguments.from#" /></cfif>
                <cfif structKeyExists(arguments, "limit")><cfhttpparam type="url" name="limit" value="#arguments.limit#" /></cfif>
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

    <!--- 
    ***************************** CHARGEBACKS API ****************************
    --->

    <cffunction name="getChargeback" localmode="modern" access="public" output="false" returntype="any" hint="">
        <cfargument name="id" type="string" required="true" />
        <cfargument name="paymentId" type="string" required="true" />
        
        <cfset response = this.GetNewResponse() />
        <cfset response.success = true />
       
        <cftry>
            <cfhttp result="mollieresult" method="GET" charset="utf-8" url="#variables.instance.baseUrl#/payments/#arguments.paymentId#/chargebacks/#arguments.id#">
                <cfhttpparam type="header" name="Authorization" value="Bearer #variables.instance.key#" />
            </cfhttp>
            <cfset response.data = mollieresult />
            <cfcatch type="any">
                <cfset response.success = false />
                <cfset response.error = cfcatch.message />
                
                <cflog file="mollie" text="Error in getChargeback: #serializeJSON( cfcatch )#" />
            </cfcatch>
        </cftry>

        <cfreturn response />
    </cffunction>

    <cffunction name="listChargebacks" localmode="modern" access="public" output="false" returntype="any" hint="">
        <cfargument name="paymentId" type="string" required="true" />

        <cfargument name="from" type="string" required="false" />
        <cfargument name="limit" type="numeric" required="false" />

        <cfset response = this.GetNewResponse() />
        <cfset response.success = true />

        <cftry>
            <cfhttp result="mollieresult" method="GET" charset="utf-8" url="#variables.instance.baseUrl#/payments/#arguments.paymentId#/chargebacks">
                <cfhttpparam type="header" name="Authorization" value="Bearer #variables.instance.key#" />
                <cfif structKeyExists(arguments, "from")><cfhttpparam type="url" name="from" value="#arguments.from#" /></cfif>
                <cfif structKeyExists(arguments, "limit")><cfhttpparam type="url" name="limit" value="#arguments.limit#" /></cfif>
            </cfhttp>
            <cfset response.data = mollieresult />
            <cfcatch type="any">
                <cfset response.success = false />
                <cfset response.error = cfcatch.message />
                
                <cflog file="mollie" text="Error in listChargebacks: #serializeJSON( cfcatch )#" />
            </cfcatch>
        </cftry>

        <cfreturn response />
    </cffunction>

    <cffunction name="listAllChargebacks" localmode="modern" access="public" output="false" returntype="any" hint="">
        <cfargument name="from" type="string" required="false" />
        <cfargument name="limit" type="numeric" required="false" />
        
        <cfset response = this.GetNewResponse() />
        <cfset response.success = true />

        <cftry>
            <cfhttp result="mollieresult" method="GET" charset="utf-8" url="#variables.instance.baseUrl#/chargebacks">
                <cfhttpparam type="header" name="Authorization" value="Bearer #variables.instance.key#" />
                <cfif structKeyExists(arguments, "from")><cfhttpparam type="url" name="from" value="#arguments.from#" /></cfif>
                <cfif structKeyExists(arguments, "limit")><cfhttpparam type="url" name="limit" value="#arguments.limit#" /></cfif>
            </cfhttp>
            <cfset response.data = mollieresult />
            <cfcatch type="any">
                <cfset response.success = false />
                <cfset response.error = cfcatch.message />
                
                <cflog file="mollie" text="Error in listAllChargebacks: #serializeJSON( cfcatch )#" />
            </cfcatch>
        </cftry>

        <cfreturn response />
    </cffunction>

    <!--- 
    ******************************* CUSTOMERS API ******************************
    --->

    <cffunction name="createCustomer" localmode="modern" access="public" output="false" returntype="any" hint="">
        <cfargument name="name" type="string" required="false" />
        <cfargument name="email" type="string" required="false" />
        <cfargument name="locale" type="string" required="false" />
        <cfargument name="metadata" type="array" required="false" />

        <cfset response = this.GetNewResponse() />
        <cfset response.success = true />

        
        <cfscript>
            dataFields = {};
            dataFields['Globals'] = {};

            if ( structKeyExists(arguments, "name") ) {
                dataFields.Globals['name'] = arguments.name;
            }

            if ( structKeyExists(arguments, "email") ) {
                dataFields.Globals['email'] = arguments.email;
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
        </cfscript>

        <cfscript>
            messageBody = {};
            messageBody = serializejson(dataFields.Globals);
        </cfscript>

       
        <cftry>
            <cfhttp result="mollieresult" method="POST" charset="utf-8" url="#variables.instance.baseUrl#/customers">
                <cfhttpparam type="header" name="Authorization" value="Bearer #variables.instance.key#" />
                <cfhttpparam type="header" name="Content-Type" value="application/json" />
                <cfhttpparam type="body" name="field" value='#messageBody#' />
            </cfhttp>
            <cfset response.data = mollieresult />
            <cfset response.body = messageBody />
            <cflog file="mollie" text="createCustomer: #serializeJSON( mollieresult )#" />
            <cfcatch type="any">
                <cfset response.success = false />
                <cfset response.error = cfcatch.message />
                
                <cflog file="mollie" text="Error in createCustomer: #serializeJSON( cfcatch )#" />
            </cfcatch>
        </cftry>

        <cfreturn response />
    
    </cffunction>

    <cffunction name="getCustomer" localmode="modern" access="public" output="false" returntype="any" hint="">
        <cfargument name="id" type="string" required="true" />
        
        <cfset response = this.GetNewResponse() />
        <cfset response.success = true />
       
        <cftry>
            <cfhttp result="mollieresult" method="GET" charset="utf-8" url="#variables.instance.baseUrl#/customers/#arguments.id#">
                <cfhttpparam type="header" name="Authorization" value="Bearer #variables.instance.key#" />
            </cfhttp>
            <cfset response.data = mollieresult />
            <cfcatch type="any">
                <cfset response.success = false />
                <cfset response.error = cfcatch.message />
                
                <cflog file="mollie" text="Error in getCustomer: #serializeJSON( cfcatch )#" />
            </cfcatch>
        </cftry>

        <cfreturn response />
    </cffunction>

    <cffunction name="updateCustomer" localmode="modern" access="public" output="false" returntype="any" hint="">
        <cfargument name="id" type="string" required="true" />

        <cfargument name="name" type="string" required="false" />
        <cfargument name="email" type="string" required="false" />
        <cfargument name="locale" type="string" required="false" />
        <cfargument name="metadata" type="array" required="false" />

        <cfset response = this.GetNewResponse() />
        <cfset response.success = true />

        
        <cfscript>
            dataFields = {};
            dataFields['Globals'] = {};

            if ( structKeyExists(arguments, "name") ) {
                dataFields.Globals['name'] = arguments.name;
            }

            if ( structKeyExists(arguments, "email") ) {
                dataFields.Globals['email'] = arguments.email;
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
            
        </cfscript>

        <cfscript>
            messageBody = {};
            messageBody = serializejson(dataFields.Globals);
        </cfscript>

       
        <cftry>
            <cfhttp result="mollieresult" method="PATCH" charset="utf-8" url="#variables.instance.baseUrl#/customers/#arguments.id#">
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

    <cffunction name="deleteCustomer" localmode="modern" access="public" output="false" returntype="any" hint="">
        <cfargument name="id" type="string" required="true" />
        
        <cfset response = this.GetNewResponse() />
        <cfset response.success = true />
       
        <cftry>
            <cfhttp result="mollieresult" method="DELETE" charset="utf-8" url="#variables.instance.baseUrl#/customers/#arguments.id#">
                <cfhttpparam type="header" name="Authorization" value="Bearer #variables.instance.key#" />
            </cfhttp>
            <cfset response.data = mollieresult />
            <cfcatch type="any">
                <cfset response.success = false />
                <cfset response.error = cfcatch.message />
                
                <cflog file="mollie" text="Error in deleteCustomer: #serializeJSON( cfcatch )#" />
            </cfcatch>
        </cftry>

        <cfreturn response />
    </cffunction>

    <cffunction name="listCustomers" localmode="modern" access="public" output="false" returntype="any" hint="">
        <cfargument name="from" type="string" required="false" />
        <cfargument name="limit" type="numeric" required="false" />
        
        <cfset response = this.GetNewResponse() />
        <cfset response.success = true />

        <cftry>
            <cfhttp result="mollieresult" method="GET" charset="utf-8" url="#variables.instance.baseUrl#/chargebacks">
                <cfhttpparam type="header" name="Authorization" value="Bearer #variables.instance.key#" />
                <cfif structKeyExists(arguments, "from")><cfhttpparam type="url" name="from" value="#arguments.from#" /></cfif>
                <cfif structKeyExists(arguments, "limit")><cfhttpparam type="url" name="limit" value="#arguments.limit#" /></cfif>
            </cfhttp>
            <cfset response.data = mollieresult />
            <cfcatch type="any">
                <cfset response.success = false />
                <cfset response.error = cfcatch.message />
                
                <cflog file="mollie" text="Error in listAllChargebacks: #serializeJSON( cfcatch )#" />
            </cfcatch>
        </cftry>

        <cfreturn response />
    </cffunction>

    <cffunction name="createCustomerPayment" localmode="modern" access="public" output="false" returntype="any" hint="">
        <cfargument name="customerId" type="string" required="true" />

        <cfargument name="currency" type="string" required="true" />
        <cfargument name="value" type="string" required="true" />
        <cfargument name="description" type="string" required="true" />

        <cfargument name="redirectUrl" type="string" required="false" />
        <cfargument name="sequenceType" type="string" required="false" />
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

            if ( structKeyExists(arguments, "redirectUrl") ) {
                dataFields.Globals['redirectUrl'] = arguments.redirectUrl;
            }

            if ( structKeyExists(arguments, "sequenceType") ) {
                dataFields.Globals['sequenceType'] = arguments.sequenceType;
            }

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
            <cfhttp result="mollieresult" method="POST" charset="utf-8" url="#variables.instance.baseUrl#/customers/#arguments.customerId#/payments">
                <cfhttpparam type="header" name="Authorization" value="Bearer #variables.instance.key#" />
                <cfhttpparam type="header" name="Content-Type" value="application/json" />
                <cfhttpparam type="body" name="field" value='#messageBody#' />
            </cfhttp>
            <cfset response.data = mollieresult />
            <cfset response.body = messageBody />
            <cflog file="mollie" text="createCustomerPayment: #serializeJSON( mollieresult )#" />
            <cfcatch type="any">
                <cfset response.success = false />
                <cfset response.error = cfcatch.message />
                
                <cflog file="mollie" text="Error in createCustomerPayment: #serializeJSON( cfcatch )#" />
            </cfcatch>
        </cftry>

        <cfreturn response />
    
    </cffunction>

    <cffunction name="listCustomerPayments" localmode="modern" access="public" output="false" returntype="any" hint="">
        <cfargument name="customerId" type="string" required="true" />

        <cfargument name="from" type="string" required="false" />
        <cfargument name="limit" type="numeric" required="false" />

        <cfset response = this.GetNewResponse() />
        <cfset response.success = true />

        <cftry>
            <cfhttp result="mollieresult" method="GET" charset="utf-8" url="#variables.instance.baseUrl#/customers/#arguments.customerId#/payments">
                <cfhttpparam type="header" name="Authorization" value="Bearer #variables.instance.key#" />
                <cfif structKeyExists(arguments, "from")><cfhttpparam type="url" name="from" value="#arguments.from#" /></cfif>
                <cfif structKeyExists(arguments, "limit")><cfhttpparam type="url" name="limit" value="#arguments.limit#" /></cfif>
            </cfhttp>
            <cfset response.data = mollieresult />
            <cfcatch type="any">
                <cfset response.success = false />
                <cfset response.error = cfcatch.message />
                
                <cflog file="mollie" text="Error in listCustomerPayments: #serializeJSON( cfcatch )#" />
            </cfcatch>
        </cftry>

        <cfreturn response />
    </cffunction>

    <!--- 
    ******************************* MANDATES API ******************************
    --->

    <cffunction name="createMandate" localmode="modern" access="public" output="false" returntype="any" hint="">
        <cfargument name="customerId" type="string" required="true" />

        <cfargument name="method" type="string" required="true" />
        <cfargument name="consumerName" type="string" required="true" />

        <cfargument name="consumerAccount" type="string" required="false" />
        <cfargument name="consumerBic" type="string" required="false" />
        <cfargument name="consumerEmail" type="string" required="false" />
        <cfargument name="signatureDate" type="date" required="false" />
        <cfargument name="mandateReference" type="string" required="false" />
        <cfargument name="paypalBillingAgreementId" type="string" required="false" />

        <cfset response = this.GetNewResponse() />
        <cfset response.success = true />

        <cfscript>
            dataFields = {};
            dataFields['Globals'] = {};
            
            dataFields.Globals['method'] = arguments.method;
            dataFields.Globals['consumerName'] = arguments.consumerName;

            if ( structKeyExists(arguments, "consumerAccount") ) {
                dataFields.Globals['consumerAccount'] = arguments.consumerAccount;
            }

            if ( structKeyExists(arguments, "consumerBic") ) {
                dataFields.Globals['consumerBic'] = arguments.consumerBic;
            }

            if ( structKeyExists(arguments, "consumerEmail") ) {
                dataFields.Globals['consumerEmail'] = arguments.consumerEmail;
            }

            if ( structKeyExists(arguments, "signatureDate") ) {
                dataFields.Globals['signatureDate'] = arguments.signatureDate;
            }

            if ( structKeyExists(arguments, "mandateReference") ) {
                dataFields.Globals['mandateReference'] = arguments.mandateReference;
            }

            if ( structKeyExists(arguments, "paypalBillingAgreementId") ) {
                dataFields.Globals['paypalBillingAgreementId'] = arguments.paypalBillingAgreementId;
            }
                        
        </cfscript>

        <cfscript>
            messageBody = {};
            messageBody = serializejson(dataFields.Globals);
        </cfscript>
       
        <cftry>
            <cfhttp result="mollieresult" method="POST" charset="utf-8" url="#variables.instance.baseUrl#/customers/#arguments.customerId#/mandates">
                <cfhttpparam type="header" name="Authorization" value="Bearer #variables.instance.key#" />
                <cfhttpparam type="header" name="Content-Type" value="application/json" />
                <cfhttpparam type="body" name="field" value='#messageBody#' />
            </cfhttp>
            <cfset response.data = mollieresult />
            <cfset response.body = messageBody />
            <cflog file="mollie" text="createMandate: #serializeJSON( mollieresult )#" />
            <cfcatch type="any">
                <cfset response.success = false />
                <cfset response.error = cfcatch.message />
                
                <cflog file="mollie" text="Error in createMandate: #serializeJSON( cfcatch )#" />
            </cfcatch>
        </cftry>

        <cfreturn response />
    
    </cffunction>

    <cffunction name="getMandate" localmode="modern" access="public" output="false" returntype="any" hint="">
        <cfargument name="customerId" type="string" required="true" />
        <cfargument name="id" type="string" required="true" />
        
        <cfset response = this.GetNewResponse() />
        <cfset response.success = true />
       
        <cftry>
            <cfhttp result="mollieresult" method="GET" charset="utf-8" url="#variables.instance.baseUrl#/customers/#arguments.customerId#/mandates/#arguments.id#">
                <cfhttpparam type="header" name="Authorization" value="Bearer #variables.instance.key#" />
            </cfhttp>
            <cfset response.data = mollieresult />
            <cfcatch type="any">
                <cfset response.success = false />
                <cfset response.error = cfcatch.message />
                
                <cflog file="mollie" text="Error in getMandate: #serializeJSON( cfcatch )#" />
            </cfcatch>
        </cftry>

        <cfreturn response />
    </cffunction>

    <cffunction name="revokeMandate" localmode="modern" access="public" output="false" returntype="any" hint="">
        <cfargument name="customerId" type="string" required="true" />
        <cfargument name="id" type="string" required="true" />
        
        <cfset response = this.GetNewResponse() />
        <cfset response.success = true />
       
        <cftry>
            <cfhttp result="mollieresult" method="DELETE" charset="utf-8" url="#variables.instance.baseUrl#/customers/#arguments.customerId#/mandates/#arguments.id#">
                <cfhttpparam type="header" name="Authorization" value="Bearer #variables.instance.key#" />
            </cfhttp>
            <cfset response.data = mollieresult />
            <cfcatch type="any">
                <cfset response.success = false />
                <cfset response.error = cfcatch.message />
                
                <cflog file="mollie" text="Error in revokeMandate: #serializeJSON( cfcatch )#" />
            </cfcatch>
        </cftry>

        <cfreturn response />
    </cffunction>

    <cffunction name="listMandates" localmode="modern" access="public" output="false" returntype="any" hint="">
        <cfargument name="customerId" type="string" required="true" />

        <cfargument name="from" type="string" required="false" />
        <cfargument name="limit" type="numeric" required="false" />

        <cfset response = this.GetNewResponse() />
        <cfset response.success = true />

        <cftry>
            <cfhttp result="mollieresult" method="GET" charset="utf-8" url="#variables.instance.baseUrl#/customers/#arguments.customerId#/mandates">
                <cfhttpparam type="header" name="Authorization" value="Bearer #variables.instance.key#" />
                <cfif structKeyExists(arguments, "from")><cfhttpparam type="url" name="from" value="#arguments.from#" /></cfif>
                <cfif structKeyExists(arguments, "limit")><cfhttpparam type="url" name="limit" value="#arguments.limit#" /></cfif>
            </cfhttp>
            <cfset response.data = mollieresult />
            <cfcatch type="any">
                <cfset response.success = false />
                <cfset response.error = cfcatch.message />
                
                <cflog file="mollie" text="Error in listMandates: #serializeJSON( cfcatch )#" />
            </cfcatch>
        </cftry>

        <cfreturn response />
    </cffunction>

</cfcomponent>
