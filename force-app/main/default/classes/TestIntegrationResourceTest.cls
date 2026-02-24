/**
 * TestIntegrationResourceTest
 * Test class for TestIntegrationResource
 * Provides at least 75% code coverage
 */
@isTest
private class TestIntegrationResourceTest {
    
    /**
     * Test setup - creates test data
     */
    @TestSetup
    static void setupTestData() {
        // Create 5 test accounts
        List<Account> accountsToCreate = new List<Account>();
        for (Integer i = 1; i <= 5; i++) {
            accountsToCreate.add(new Account(Name = 'Test Account ' + i));
        }
        insert accountsToCreate;
    }
    
    /**
     * Test GET method - successful retrieval of accounts
     */
    @isTest
    static void testDoGetSuccess() {
        Test.startTest();
        
        // Call GET method
        TestIntegrationResource.ResponseWrapper response = TestIntegrationResource.doGet();
        
        Test.stopTest();
        
        // Assert results
        Assert.isNotNull(response, 'Response should not be null');
        Assert.isTrue(response.success, 'Response should indicate success');
        Assert.isNotNull(response.message, 'Message should not be null');
        Assert.isNotNull(response.data, 'Data should not be null');
        Assert.isTrue(response.data.size() > 0, 'Should return at least one account');
        Assert.isTrue(response.message.contains('successfully retrieved'), 
                     'Message should indicate successful retrieval');
    }
    
    /**
     * Test GET method - verify correct fields are returned
     */
    @isTest
    static void testDoGetFields() {
        Test.startTest();
        
        TestIntegrationResource.ResponseWrapper response = TestIntegrationResource.doGet();
        
        Test.stopTest();
        
        Assert.isTrue(response.success, 'Response should be successful');
        Assert.isTrue(response.data.size() > 0, 'Should have at least one account');
        
        Map<String, String> firstAccount = response.data.get(0);
        Assert.isTrue(firstAccount.containsKey('id'), 'Account should have id field');
        Assert.isTrue(firstAccount.containsKey('name'), 'Account should have name field');
        Assert.isFalse(String.isBlank(firstAccount.get('id')), 'Account id should not be blank');
        Assert.isFalse(String.isBlank(firstAccount.get('name')), 'Account name should not be blank');
    }
    
    /**
     * Test POST method - successful Account creation
     */
    @isTest
    static void testDoPostSuccess() {
        // Setup request body
        String requestBody = '{"Name": "New Test Account"}';
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        
        TestIntegrationResource.ResponseWrapper response = TestIntegrationResource.doPost();
        
        Test.stopTest();
        
        // Assert results
        Assert.isNotNull(response, 'Response should not be null');
        Assert.isTrue(response.success, 'Response should indicate success');
        Assert.isTrue(response.message.contains('created successfully'), 
                     'Message should indicate successful creation');
        Assert.isNotNull(response.data, 'Data should not be null');
        Assert.isTrue(response.data.size() > 0, 'Should return created account');
        Assert.areEqual(201, RestContext.response.statusCode, 'Status code should be 201');
        
        // Verify Account was created in database
        Map<String, String> createdAccount = response.data.get(0);
        Account verifyAccount = [SELECT Id, Name FROM Account WHERE Id = :createdAccount.get('id')];
        Assert.areEqual('New Test Account', verifyAccount.Name, 'Account name should match');
    }
    
    /**
     * Test POST method - Account creation with optional fields
     */
    @isTest
    static void testDoPostWithOptionalFields() {
        String requestBody = '{"Name": "Account With Fields", "BillingCity": "New York", "BillingCountry": "USA", "Phone": "1234567890", "Website": "www.example.com"}';
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        
        TestIntegrationResource.ResponseWrapper response = TestIntegrationResource.doPost();
        
        Test.stopTest();
        
        Assert.isTrue(response.success, 'Response should be successful');
        Assert.isTrue(response.data.size() > 0, 'Should have created account');
        
        Map<String, String> createdAccount = response.data.get(0);
        Account verifyAccount = [SELECT Id, Name, BillingCity, BillingCountry, Phone, Website 
                                FROM Account WHERE Id = :createdAccount.get('id')];
        Assert.areEqual('New York', verifyAccount.BillingCity, 'BillingCity should be set');
        Assert.areEqual('USA', verifyAccount.BillingCountry, 'BillingCountry should be set');
        Assert.areEqual('1234567890', verifyAccount.Phone, 'Phone should be set');
        Assert.areEqual('www.example.com', verifyAccount.Website, 'Website should be set');
    }
    
    /**
     * Test POST method - missing required Name field
     */
    @isTest
    static void testDoPostMissingNameField() {
        String requestBody = '{"BillingCity": "New York"}';
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        
        TestIntegrationResource.ResponseWrapper response = TestIntegrationResource.doPost();
        
        Test.stopTest();
        
        Assert.isNotNull(response, 'Response should not be null');
        Assert.isFalse(response.success, 'Response should indicate failure');
        Assert.isTrue(response.message.contains('Required field missing'), 
                     'Message should indicate missing required field');
        Assert.isTrue(response.message.contains('Name'), 'Message should mention Name field');
    }
    
    /**
     * Test POST method - empty Name field
     */
    @isTest
    static void testDoPostEmptyNameField() {
        String requestBody = '{"Name": ""}';
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        
        TestIntegrationResource.ResponseWrapper response = TestIntegrationResource.doPost();
        
        Test.stopTest();
        
        Assert.isFalse(response.success, 'Response should indicate failure');
        Assert.isTrue(response.message.contains('Required field missing'), 
                     'Message should indicate missing required field');
    }
    
    /**
     * Test POST method - empty request body
     */
    @isTest
    static void testDoPostEmptyRequestBody() {
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf('');
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        
        TestIntegrationResource.ResponseWrapper response = TestIntegrationResource.doPost();
        
        Test.stopTest();
        
        Assert.isFalse(response.success, 'Response should indicate failure');
        Assert.isTrue(response.message.contains('Request body cannot be empty'), 
                     'Message should indicate empty request body');
    }
    
    /**
     * Test POST method - invalid JSON format
     */
    @isTest
    static void testDoPostInvalidJSON() {
        String requestBody = '{invalid json}';
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        
        TestIntegrationResource.ResponseWrapper response = TestIntegrationResource.doPost();
        
        Test.stopTest();
        
        Assert.isFalse(response.success, 'Response should indicate failure');
        Assert.isTrue(response.message.contains('Invalid JSON format'), 
                     'Message should indicate JSON parsing error');
        Assert.areEqual(400, RestContext.response.statusCode, 'Status code should be 400');
    }
    
    /**
     * Test POST method - Account name exceeding field length
     */
    @isTest
    static void testDoPostInvalidFieldLength() {
        // Account.Name has a max length of 255 characters
        String longName = 'A'.repeat(300);
        String requestBody = '{"Name": "' + longName + '"}';
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        
        TestIntegrationResource.ResponseWrapper response = TestIntegrationResource.doPost();
        
        Test.stopTest();
        
        Assert.isFalse(response.success, 'Response should indicate failure');
        Assert.isTrue(response.message.contains('Error creating account'), 
                     'Message should indicate DML error');
        Assert.areEqual(400, RestContext.response.statusCode, 'Status code should be 400');
    }
    
    /**
     * Test response wrapper class
     */
    @isTest
    static void testResponseWrapperClass() {
        TestIntegrationResource.ResponseWrapper wrapper = new TestIntegrationResource.ResponseWrapper();
        
        Assert.isFalse(wrapper.success, 'Default success should be false');
        Assert.areEqual('', wrapper.message, 'Default message should be empty');
        Assert.isNotNull(wrapper.data, 'Data should be initialized as empty list');
        Assert.areEqual(0, wrapper.data.size(), 'Data should be empty by default');
    }
    
    /**
     * Test GET method - response message format
     */
    @isTest
    static void testDoGetResponseMessage() {
        Test.startTest();
        
        TestIntegrationResource.ResponseWrapper response = TestIntegrationResource.doGet();
        
        Test.stopTest();
        
        Assert.isTrue(response.success, 'Should be successful');
        Assert.isTrue(response.message.toLowerCase().contains('retrieved'), 
                     'Message should contain "retrieved"');
        Assert.isTrue(response.message.toLowerCase().contains('accounts'), 
                     'Message should contain "accounts"');
    }
    
    /**
     * Test POST method - Location header is set
     */
    @isTest
    static void testDoPostLocationHeader() {
        String requestBody = '{"Name": "Location Test Account"}';
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        
        TestIntegrationResource.ResponseWrapper response = TestIntegrationResource.doPost();
        
        Test.stopTest();
        
        Assert.isTrue(response.success, 'Should be successful');
        Assert.isTrue(RestContext.response.headers.containsKey('Location'), 
                     'Location header should be set');
    }
    
    /**
     * Test PUT method - successful Account update
     */
    @isTest
    static void testDoPutSuccess() {
        // Get an account ID from test data
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        String requestBody = '{"Id": "' + testAccount.Id + '", "Name": "Updated Account Name", "BillingCity": "Updated City"}';
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        
        TestIntegrationResource.ResponseWrapper response = TestIntegrationResource.doPut();
        
        Test.stopTest();
        
        Assert.isNotNull(response, 'Response should not be null');
        Assert.isTrue(response.success, 'Response should indicate success');
        Assert.isTrue(response.message.contains('updated successfully'), 
                     'Message should indicate successful update');
        Assert.areEqual(200, RestContext.response.statusCode, 'Status code should be 200');
        
        // Verify Account was updated in database
        Account verifyAccount = [SELECT Id, Name, BillingCity FROM Account WHERE Id = :testAccount.Id];
        Assert.areEqual('Updated Account Name', verifyAccount.Name, 'Account name should be updated');
        Assert.areEqual('Updated City', verifyAccount.BillingCity, 'BillingCity should be updated');
    }
    
    /**
     * Test PUT method - missing required Id field
     */
    @isTest
    static void testDoPutMissingIdField() {
        String requestBody = '{"Name": "Account Without Id"}';
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        
        TestIntegrationResource.ResponseWrapper response = TestIntegrationResource.doPut();
        
        Test.stopTest();
        
        Assert.isFalse(response.success, 'Response should indicate failure');
        Assert.isTrue(response.message.contains('Required field missing'), 
                     'Message should indicate missing Id field');
        Assert.isTrue(response.message.contains('Id'), 'Message should mention Id field');
    }
    
    /**
     * Test PUT method - Account not found
     */
    @isTest
    static void testDoPutAccountNotFound() {
        String requestBody = '{"Id": "001xx000000000AAA", "Name": "Updated Name"}';
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        
        TestIntegrationResource.ResponseWrapper response = TestIntegrationResource.doPut();
        
        Test.stopTest();
        
        Assert.isFalse(response.success, 'Response should indicate failure');
        Assert.isTrue(response.message.contains('Account not found'), 
                     'Message should indicate account not found');
        Assert.areEqual(404, RestContext.response.statusCode, 'Status code should be 404');
    }
    
    /**
     * Test PUT method - empty request body
     */
    @isTest
    static void testDoPutEmptyRequestBody() {
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf('');
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        
        TestIntegrationResource.ResponseWrapper response = TestIntegrationResource.doPut();
        
        Test.stopTest();
        
        Assert.isFalse(response.success, 'Response should indicate failure');
        Assert.isTrue(response.message.contains('Request body cannot be empty'), 
                     'Message should indicate empty body');
    }
    
    /**
     * Test PUT method - invalid JSON format
     */
    @isTest
    static void testDoPutInvalidJSON() {
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf('{invalid json}');
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        
        TestIntegrationResource.ResponseWrapper response = TestIntegrationResource.doPut();
        
        Test.stopTest();
        
        Assert.isFalse(response.success, 'Response should indicate failure');
        Assert.isTrue(response.message.contains('Invalid JSON format'), 
                     'Message should indicate JSON parsing error');
        Assert.areEqual(400, RestContext.response.statusCode, 'Status code should be 400');
    }
    
    /**
     * Test DELETE method - successful Account deletion by Id parameter
     */
    @isTest
    static void testDoDeleteSuccessByParameter() {
        Account testAccount = [SELECT Id, Name FROM Account LIMIT 1];
        
        RestRequest req = new RestRequest();
        req.params.put('Id', testAccount.Id);
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        
        TestIntegrationResource.ResponseWrapper response = TestIntegrationResource.doDelete();
        
        Test.stopTest();
        
        Assert.isNotNull(response, 'Response should not be null');
        Assert.isTrue(response.success, 'Response should indicate success');
        Assert.isTrue(response.message.contains('deleted successfully'), 
                     'Message should indicate successful deletion');
        Assert.areEqual(200, RestContext.response.statusCode, 'Status code should be 200');
        
        // Verify Account was deleted from database
        List<Account> verifyAccounts = [SELECT Id FROM Account WHERE Id = :testAccount.Id];
        Assert.areEqual(0, verifyAccounts.size(), 'Account should be deleted');
    }
    
    /**
     * Test DELETE method - successful Account deletion by request body
     */
    @isTest
    static void testDoDeleteSuccessByRequestBody() {
        Account testAccount = [SELECT Id, Name FROM Account LIMIT 1 OFFSET 1];
        
        String requestBody = '{"Id": "' + testAccount.Id + '"}';
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        
        TestIntegrationResource.ResponseWrapper response = TestIntegrationResource.doDelete();
        
        Test.stopTest();
        
        Assert.isTrue(response.success, 'Response should indicate success');
        Assert.isTrue(response.message.contains('deleted successfully'), 
                     'Message should indicate successful deletion');
        Assert.areEqual(200, RestContext.response.statusCode, 'Status code should be 200');
        
        // Verify Account was deleted from database
        List<Account> verifyAccounts = [SELECT Id FROM Account WHERE Id = :testAccount.Id];
        Assert.areEqual(0, verifyAccounts.size(), 'Account should be deleted');
    }
    
    /**
     * Test DELETE method - missing Account Id
     */
    @isTest
    static void testDoDeleteMissingId() {
        RestRequest req = new RestRequest();
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        
        TestIntegrationResource.ResponseWrapper response = TestIntegrationResource.doDelete();
        
        Test.stopTest();
        
        Assert.isFalse(response.success, 'Response should indicate failure');
        Assert.isTrue(response.message.contains('Account Id parameter is required'), 
                     'Message should indicate missing Id');
        Assert.areEqual(400, RestContext.response.statusCode, 'Status code should be 400');
    }
    
    /**
     * Test DELETE method - Account not found
     */
    @isTest
    static void testDoDeleteAccountNotFound() {
        RestRequest req = new RestRequest();
        req.params.put('Id', '001xx000000000AAA');
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        
        TestIntegrationResource.ResponseWrapper response = TestIntegrationResource.doDelete();
        
        Test.stopTest();
        
        Assert.isFalse(response.success, 'Response should indicate failure');
        Assert.isTrue(response.message.contains('Account not found'), 
                     'Message should indicate account not found');
        Assert.areEqual(404, RestContext.response.statusCode, 'Status code should be 404');
    }
    
    /**
     * Test DELETE method - invalid JSON format
     */
    @isTest
    static void testDoDeleteInvalidJSON() {
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf('{invalid json}');
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        Test.startTest();
        
        TestIntegrationResource.ResponseWrapper response = TestIntegrationResource.doDelete();
        
        Test.stopTest();
        
        Assert.isFalse(response.success, 'Response should indicate failure');
        Assert.isTrue(response.message.contains('Invalid JSON format'), 
                     'Message should indicate JSON parsing error');
        Assert.areEqual(400, RestContext.response.statusCode, 'Status code should be 400');
    }
}
