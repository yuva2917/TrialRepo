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
}
