/**
 * TestIntegrationResource
 * Simple REST API endpoint for Account management
 * Endpoint: /services/apexrest/integration/test
 * Supports GET, POST, PUT, and DELETE methods
 */
@RestResource(urlMapping='/integration/test/*')
global with sharing class TestIntegrationResource {
    
    /**
     * HTTP GET method
     * Returns a list of 5 Accounts with Id and Name
     * @return JSON response with list of Accounts
     */
    @HttpGet
    global static ResponseWrapper doGet() {
        ResponseWrapper response = new ResponseWrapper();
        
        try {
            // Query 5 Accounts ordered by creation date
            List<Account> accounts = [
                SELECT Id, Name
                FROM Account
                ORDER BY CreatedDate DESC
                LIMIT 5
            ];
            
            if (accounts.isEmpty()) {
                response.success = true;
                response.message = 'No accounts found';
                response.data = new List<Map<String, String>>();
            } else {
                List<Map<String, String>> accountList = new List<Map<String, String>>();
                
                for (Account acc : accounts) {
                    Map<String, String> accMap = new Map<String, String>();
                    accMap.put('id', acc.Id);
                    accMap.put('name', acc.Name);
                    accountList.add(accMap);
                }
                
                response.success = true;
                response.message = 'successfully retrieved ' + accounts.size() + ' accounts';
                response.data = accountList;
            }
            
        } catch (QueryException ex) {
            response.success = false;
            response.message = 'Error querying accounts: ' + ex.getMessage();
            System.debug(LoggingLevel.ERROR, 'Query Exception: ' + ex.getStackTraceString());
        } catch (Exception ex) {
            response.success = false;
            response.message = 'Unexpected error: ' + ex.getMessage();
            System.debug(LoggingLevel.ERROR, 'Exception: ' + ex.getStackTraceString());
        }
        
        return response;
    }
    
    /**
     * HTTP POST method
     * Creates a new Account from JSON request body
     * Required field: Name
     * @return JSON response with created Account details
     */
    @HttpPost
    global static ResponseWrapper doPost() {
        ResponseWrapper response = new ResponseWrapper();
        
        try {
            // Get request body
            String requestBody = RestContext.request.requestBody.toString();
            
            if (String.isBlank(requestBody)) {
                response.success = false;
                response.message = 'Request body cannot be empty';
                return response;
            }
            
            // Parse JSON request
            Map<String, Object> requestData = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            
            // Validate required field
            if (!requestData.containsKey('Name') || String.isBlank((String) requestData.get('Name'))) {
                response.success = false;
                response.message = 'Required field missing: Name';
                return response;
            }
            
            // Create Account
            Account newAccount = new Account();
            newAccount.Name = (String) requestData.get('Name');
            
            // Optional fields
            if (requestData.containsKey('BillingCity')) {
                newAccount.BillingCity = (String) requestData.get('BillingCity');
            }
            if (requestData.containsKey('BillingCountry')) {
                newAccount.BillingCountry = (String) requestData.get('BillingCountry');
            }
            if (requestData.containsKey('Phone')) {
                newAccount.Phone = (String) requestData.get('Phone');
            }
            if (requestData.containsKey('Website')) {
                newAccount.Website = (String) requestData.get('Website');
            }
            
            // Insert Account
            insert newAccount;
            
            // Build response
            Map<String, String> createdAccountMap = new Map<String, String>();
            createdAccountMap.put('id', newAccount.Id);
            createdAccountMap.put('name', newAccount.Name);
            
            response.success = true;
            response.message = 'created successfully';
            response.data = new List<Map<String, String>> { createdAccountMap };
            
            // Set HTTP status code and location header
            RestContext.response.statusCode = 201;
            RestContext.response.addHeader('Location', '/services/data/v57.0/sobjects/Account/' + newAccount.Id);
            
        } catch (JSONException ex) {
            response.success = false;
            response.message = 'Invalid JSON format: ' + ex.getMessage();
            System.debug(LoggingLevel.ERROR, 'JSON Exception: ' + ex.getStackTraceString());
            RestContext.response.statusCode = 400;
        } catch (DmlException ex) {
            response.success = false;
            response.message = 'Error creating account: ' + ex.getDmlMessage(0);
            System.debug(LoggingLevel.ERROR, 'DML Exception: ' + ex.getStackTraceString());
            RestContext.response.statusCode = 400;
        } catch (Exception ex) {
            response.success = false;
            response.message = 'Unexpected error: ' + ex.getMessage();
            System.debug(LoggingLevel.ERROR, 'Exception: ' + ex.getStackTraceString());
            RestContext.response.statusCode = 500;
        }
        
        return response;
    }
    
    /**
     * HTTP PUT method
     * Updates an existing Account from JSON request body
     * Required: Id field in request body
     * @return JSON response with updated Account details
     */
    @HttpPut
    global static ResponseWrapper doPut() {
        ResponseWrapper response = new ResponseWrapper();
        
        try {
            // Get request body
            String requestBody = RestContext.request.requestBody.toString();
            
            if (String.isBlank(requestBody)) {
                response.success = false;
                response.message = 'Request body cannot be empty';
                return response;
            }
            
            // Parse JSON request
            Map<String, Object> requestData = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            
            // Validate required Id field
            if (!requestData.containsKey('Id') || String.isBlank((String) requestData.get('Id'))) {
                response.success = false;
                response.message = 'Required field missing: Id';
                return response;
            }
            
            String accountId = (String) requestData.get('Id');
            
            // Query existing Account
            List<Account> accountsToUpdate = [
                SELECT Id, Name, BillingCity, BillingCountry, Phone, Website
                FROM Account
                WHERE Id = :accountId
                LIMIT 1
            ];
            
            if (accountsToUpdate.isEmpty()) {
                response.success = false;
                response.message = 'Account not found with Id: ' + accountId;
                RestContext.response.statusCode = 404;
                return response;
            }
            
            // Update Account fields
            Account accountToUpdate = accountsToUpdate.get(0);
            
            if (requestData.containsKey('Name')) {
                accountToUpdate.Name = (String) requestData.get('Name');
            }
            if (requestData.containsKey('BillingCity')) {
                accountToUpdate.BillingCity = (String) requestData.get('BillingCity');
            }
            if (requestData.containsKey('BillingCountry')) {
                accountToUpdate.BillingCountry = (String) requestData.get('BillingCountry');
            }
            if (requestData.containsKey('Phone')) {
                accountToUpdate.Phone = (String) requestData.get('Phone');
            }
            if (requestData.containsKey('Website')) {
                accountToUpdate.Website = (String) requestData.get('Website');
            }
            
            // Update Account
            update accountToUpdate;
            
            // Build response
            Map<String, String> updatedAccountMap = new Map<String, String>();
            updatedAccountMap.put('id', accountToUpdate.Id);
            updatedAccountMap.put('name', accountToUpdate.Name);
            
            response.success = true;
            response.message = 'updated successfully';
            response.data = new List<Map<String, String>> { updatedAccountMap };
            RestContext.response.statusCode = 200;
            
        } catch (JSONException ex) {
            response.success = false;
            response.message = 'Invalid JSON format: ' + ex.getMessage();
            System.debug(LoggingLevel.ERROR, 'JSON Exception: ' + ex.getStackTraceString());
            RestContext.response.statusCode = 400;
        } catch (DmlException ex) {
            response.success = false;
            response.message = 'Error updating account: ' + ex.getDmlMessage(0);
            System.debug(LoggingLevel.ERROR, 'DML Exception: ' + ex.getStackTraceString());
            RestContext.response.statusCode = 400;
        } catch (Exception ex) {
            response.success = false;
            response.message = 'Unexpected error: ' + ex.getMessage();
            System.debug(LoggingLevel.ERROR, 'Exception: ' + ex.getStackTraceString());
            RestContext.response.statusCode = 500;
        }
        
        return response;
    }
    
    /**
     * HTTP DELETE method
     * Deletes an Account by Id
     * Id can be passed as URL parameter or in request body
     * @return JSON response confirming deletion
     */
    @HttpDelete
    global static ResponseWrapper doDelete() {
        ResponseWrapper response = new ResponseWrapper();
        
        try {
            // Get Account Id from URL parameter or request body
            String accountId = RestContext.request.params.get('Id');
            
            if (String.isBlank(accountId)) {
                // Try to get from request body
                String requestBody = RestContext.request.requestBody.toString();
                if (!String.isBlank(requestBody)) {
                    Map<String, Object> requestData = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
                    if (requestData.containsKey('Id')) {
                        accountId = (String) requestData.get('Id');
                    }
                }
            }
            
            if (String.isBlank(accountId)) {
                response.success = false;
                response.message = 'Account Id parameter is required';
                RestContext.response.statusCode = 400;
                return response;
            }
            
            // Query Account to verify it exists
            List<Account> accountsToDelete = [
                SELECT Id, Name
                FROM Account
                WHERE Id = :accountId
                LIMIT 1
            ];
            
            if (accountsToDelete.isEmpty()) {
                response.success = false;
                response.message = 'Account not found with Id: ' + accountId;
                RestContext.response.statusCode = 404;
                return response;
            }
            
            // Store deleted account info for response
            Account deletedAccount = accountsToDelete.get(0);
            Map<String, String> deletedAccountMap = new Map<String, String>();
            deletedAccountMap.put('id', deletedAccount.Id);
            deletedAccountMap.put('name', deletedAccount.Name);
            
            // Delete Account
            delete accountsToDelete;
            
            response.success = true;
            response.message = 'deleted successfully';
            response.data = new List<Map<String, String>> { deletedAccountMap };
            RestContext.response.statusCode = 200;
            
        } catch (JSONException ex) {
            response.success = false;
            response.message = 'Invalid JSON format: ' + ex.getMessage();
            System.debug(LoggingLevel.ERROR, 'JSON Exception: ' + ex.getStackTraceString());
            RestContext.response.statusCode = 400;
        } catch (DmlException ex) {
            response.success = false;
            response.message = 'Error deleting account: ' + ex.getDmlMessage(0);
            System.debug(LoggingLevel.ERROR, 'DML Exception: ' + ex.getStackTraceString());
            RestContext.response.statusCode = 400;
        } catch (Exception ex) {
            response.success = false;
            response.message = 'Unexpected error: ' + ex.getMessage();
            System.debug(LoggingLevel.ERROR, 'Exception: ' + ex.getStackTraceString());
            RestContext.response.statusCode = 500;
        }
        
        return response;
    }
    
    /**
     * ResponseWrapper
     * Wrapper class for structured JSON response
     */
    global class ResponseWrapper {
        @AuraEnabled
        global Boolean success { get; set; }
        
        @AuraEnabled
        global String message { get; set; }
        
        @AuraEnabled
        global List<Map<String, String>> data { get; set; }
        
        /**
         * Default constructor
         */
        public ResponseWrapper() {
            this.success = false;
            this.message = '';
            this.data = new List<Map<String, String>>();
        }
    }
}
