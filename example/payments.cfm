<cfset myMollie = createObject("component", "mollie").init( key = server.system.environment.MOLLIE_KEY ) />

    <cfscript>
        metadata = arrayNew(1);
        newStruct = {};
        newStruct.insert("orderid", "001");
        metadata.append( newStruct );
    </cfscript>

    <cfset ergebnis = myMollie.createPayment(
        currency = "EUR",
        value = "20.00",
        description = "My Item",
        redirectUrl = "https://ticker.icetestng.com/dimstreamdone.cfm",
        webhookUrl = "https://ticker.icetestng.com/cybertoltmollie.cfm",
        locale = "de_de",
        method = "sofort,giropay,creditcard,applepay,ideal,eps",
        metadata = metadata
    ) />

    
    <cfset resMollie = deserializeJSON( ergebnis.DATA.filecontent ) />
    
    
    <cfdump var="#resMollie#" />
    