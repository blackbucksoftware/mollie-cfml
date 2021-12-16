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
    
    
    <cfdump var="#resMollie#" label="createPayment"/>


    <cfscript>
        metadatanew = arrayNew(1);
        newStruct.update("orderid", "001update");
        metadatanew.append( newStruct );
    </cfscript>

    <cfset ergebnisUpdate = myMollie.updatePayment(
        id = resMollie.id,
        metadata = metadata
    ) />

    
    <cfset resMollieUpdate = deserializeJSON( ergebnisUpdate.DATA.filecontent ) />
    
    
    <cfdump var="#resMollieUpdate#" label="updatePayment"/>
    