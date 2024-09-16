//------------------------------------------------------------------------------------------------//
// This file is part of the Nebula Logger project, released under the MIT License.                //
// See LICENSE file or go to https://github.com/jongpie/NebulaLogger for full license details.    //
//------------------------------------------------------------------------------------------------//

@SuppressWarnings('PMD.ApexDoc, PMD.MethodNamingConventions')
@IsTest(IsParallel=true)
private class LoggerRestResource_Tests {
  /* Start of common endpoint functionality tests */
  @IsTest
  static void endpoint_request_correctly_parses_system_rest_request_without_endpoint_particle() {
    String expectedEndpointName = 'some-endpoint-name';
    String expectedRequestBody = 'some string that may or may not be valid JSON (but hopefully it is)';
    System.RestRequest restRequest = new System.RestRequest();
    restRequest.addHeader('X-some-header', 'some-value');
    restRequest.addHeader('X-another-header', 'another-value');
    restRequest.addParameter('verbose', 'true');
    restRequest.addParameter('some-other-parameter', 'someValue');
    restRequest.requestBody = Blob.valueOf(expectedRequestBody);
    restRequest.requestUri = LoggerRestResource.REQUEST_URI_BASE + '/' + expectedEndpointName + '/';

    LoggerRestResource.EndpointRequest endpointRequest = new LoggerRestResource.EndpointRequest(restRequest);

    System.Assert.areEqual(expectedRequestBody, endpointRequest.body);
    System.Assert.areEqual(expectedEndpointName, endpointRequest.name);
    System.Assert.isNull(endpointRequest.particle);
    System.Assert.areEqual(new List<String>(restRequest.headers.keySet()), endpointRequest.headerKeys);
    System.Assert.areEqual(restRequest.params, endpointRequest.parameters);
    System.Assert.areEqual(restRequest.requestUri, endpointRequest.uri);
  }

  @IsTest
  static void endpoint_request_correctly_parses_system_rest_request_with_endpoint_particle() {
    String expectedEndpointName = 'some-endpoint-name';
    String expectedEndpointParticle = System.UUID.randomUUID().toString();
    String expectedRequestBody = 'some string that may or may not be valid JSON (but hopefully it is)';
    System.RestRequest restRequest = new System.RestRequest();
    restRequest.addHeader('X-some-header', 'some-value');
    restRequest.addHeader('X-another-header', 'another-value');
    restRequest.addParameter('verbose', 'true');
    restRequest.addParameter('some-other-parameter', 'someValue');
    restRequest.requestBody = Blob.valueOf(expectedRequestBody);
    restRequest.requestUri = LoggerRestResource.REQUEST_URI_BASE + '/' + expectedEndpointName + '/' + expectedEndpointParticle;

    LoggerRestResource.EndpointRequest endpointRequest = new LoggerRestResource.EndpointRequest(restRequest);

    System.Assert.areEqual(expectedRequestBody, endpointRequest.body);
    System.Assert.areEqual(expectedEndpointName, endpointRequest.name);
    System.Assert.areEqual(expectedEndpointParticle, endpointRequest.particle);
    System.Assert.areEqual(new List<String>(restRequest.headers.keySet()), endpointRequest.headerKeys);
    System.Assert.areEqual(restRequest.params, endpointRequest.parameters);
    System.Assert.areEqual(restRequest.requestUri, endpointRequest.uri);
  }

  @IsTest
  static void unknown_endpoint_get_throws_an_exception() {
    String unknownEndpoint = 'some-endpoint-that-definitely-should-not-exist';
    String someParameters = '/?i-hope=true';
    System.RestContext.request = new System.RestRequest();
    System.RestContext.request.requestUri = LoggerRestResource.REQUEST_URI_BASE + '/' + unknownEndpoint + someParameters;

    LoggerRestResource.handleGet();

    System.Assert.areEqual(404, System.RestContext.response.statusCode);
    System.Assert.areEqual('application/json', System.RestContext.response.headers.get('Content-Type'));
    System.Assert.isNotNull(System.RestContext.response.responseBody);
    LoggerRestResource.EndpointResponse endpointResponse = (LoggerRestResource.EndpointResponse) System.JSON.deserialize(
      System.RestContext.response.responseBody.toString(),
      LoggerRestResource.EndpointResponse.class
    );
    System.Assert.isFalse(endpointResponse.isSuccess);
    System.Assert.areEqual(1, endpointResponse.errors.size());
    System.Assert.areEqual('Unknown endpoint provided: ' + unknownEndpoint, endpointResponse.errors.get(0).message);
  }

  @IsTest
  static void unknown_endpoint_post_throws_an_exception() {
    String unknownEndpoint = 'some-endpoint-that-definitely-should-not-exist';
    String someParameters = '/?i-hope=true';
    System.RestContext.request = new System.RestRequest();
    System.RestContext.request.requestUri = LoggerRestResource.REQUEST_URI_BASE + '/' + unknownEndpoint + someParameters;

    LoggerRestResource.handlePost();

    System.Assert.areEqual(404, System.RestContext.response.statusCode);
    System.Assert.areEqual('application/json', System.RestContext.response.headers.get('Content-Type'));
    System.Assert.isNotNull(System.RestContext.response.responseBody);
    LoggerRestResource.EndpointResponse endpointResponse = (LoggerRestResource.EndpointResponse) System.JSON.deserialize(
      System.RestContext.response.responseBody.toString(),
      LoggerRestResource.EndpointResponse.class
    );
    System.Assert.isFalse(endpointResponse.isSuccess);
    System.Assert.areEqual(1, endpointResponse.errors.size());
    System.Assert.areEqual('Unknown endpoint provided: ' + unknownEndpoint, endpointResponse.errors.get(0).message);
  }

  @IsTest
  static void base_response_excludes_system_context_in_endpoint_response_on_post_when_verbose_parameter_is_excluded() {
    String someEndpointName = 'any-endpoint-even-if-it-is-not-valid-we-do-not-care-for-this-test-k-thx-bye';
    System.RestContext.request = new System.RestRequest();
    System.RestContext.request.requestUri = LoggerRestResource.REQUEST_URI_BASE + '/' + someEndpointName;

    LoggerRestResource.handlePost();

    LoggerRestResource.EndpointResponse endpointResponse = (LoggerRestResource.EndpointResponse) System.JSON.deserialize(
      System.RestContext.response.responseBody.toString(),
      LoggerRestResource.EndpointResponse.class
    );
    // System.Assert.isNull(endpointResponse.endpoint, System.JSON.serializePretty(endpointResponse.endpoint));
    System.Assert.isNull(endpointResponse.logger, System.JSON.serializePretty(endpointResponse.logger));
    System.Assert.isNull(endpointResponse.organization);
    System.Assert.isNull(endpointResponse.user, System.JSON.serializePretty(endpointResponse.user));
  }

  @IsTest
  static void base_response_excludes_system_context_in_endpoint_response_on_post_when_verbose_parameter_is_false() {
    String someEndpointName = 'any-endpoint-even-if-it-is-not-valid-we-do-not-care-for-this-test-k-thx-bye';
    System.RestContext.request = new System.RestRequest();
    System.RestContext.request.addParameter('verbose', 'false');
    System.RestContext.request.requestUri = LoggerRestResource.REQUEST_URI_BASE + '/' + someEndpointName;

    LoggerRestResource.handlePost();

    LoggerRestResource.EndpointResponse endpointResponse = (LoggerRestResource.EndpointResponse) System.JSON.deserialize(
      System.RestContext.response.responseBody.toString(),
      LoggerRestResource.EndpointResponse.class
    );
    // // System.Assert.isNull(endpointResponse.endpoint, System.JSON.serializePretty(endpointResponse.endpoint));
    System.Assert.isNull(endpointResponse.logger, System.JSON.serializePretty(endpointResponse.logger));
    System.Assert.isNull(endpointResponse.organization);
    System.Assert.isNull(endpointResponse.user, System.JSON.serializePretty(endpointResponse.user));
  }

  @IsTest
  static void base_response_includes_system_context_in_endpoint_response_on_post_when_verbose_parameter_is_true() {
    String someEndpointName = 'any-endpoint-even-if-it-is-not-valid-we-do-not-care-for-this-test-k-thx-bye';
    System.RestContext.request = new System.RestRequest();
    System.RestContext.request.addParameter('verbose', 'true');
    System.RestContext.request.addHeader('X-some-header', 'some-value');
    System.RestContext.request.requestUri = LoggerRestResource.REQUEST_URI_BASE + '/' + someEndpointName;

    LoggerRestResource.handlePost();

    LoggerRestResource.EndpointResponse endpointResponse = (LoggerRestResource.EndpointResponse) System.JSON.deserialize(
      System.RestContext.response.responseBody.toString(),
      LoggerRestResource.EndpointResponse.class
    );
    // // System.Assert.isNotNull(endpointResponse.endpoint, System.JSON.serializePretty(endpointResponse.endpoint));
    // System.Assert.areEqual(new List<String>(System.RestContext.request.headers.keySet()), endpointResponse.endpoint.headerKeys);
    // System.Assert.areEqual(someEndpointName, endpointResponse.endpoint.name);
    // System.Assert.areEqual(System.RestContext.request.params, endpointResponse.endpoint.parameters);
    // System.Assert.areEqual(System.RestContext.request.requestUri, endpointResponse.endpoint.uri);
    System.Assert.isNotNull(endpointResponse.logger, System.JSON.serializePretty(endpointResponse.logger));
    System.Assert.isNotNull(endpointResponse.logger.userSettings, System.JSON.serializePretty(endpointResponse.logger.userSettings));
    System.Assert.areEqual(Logger.isEnabled(), endpointResponse.logger.userSettings.isEnabled);
    System.Assert.areEqual(Logger.getUserLoggingLevel().name(), endpointResponse.logger.userSettings.loggingLevel);
    System.Assert.areEqual(Logger.getSaveMethod()?.name(), endpointResponse.logger.userSettings.saveMethod);
    System.Assert.areEqual(Logger.getVersionNumber(), endpointResponse.logger.versionNumber);
    // FIXME Logger.getOrganizationApiVersion() is public (not global), so it isn't available in the managed package
    String expectedOrganizationApiVersion = System.JSON.serialize(new Schema.User(Id = System.UserInfo.getUserId()));
    expectedOrganizationApiVersion = expectedOrganizationApiVersion.substringAfter('/data/').substringBefore('/sobjects/User');
    System.Assert.areEqual(expectedOrganizationApiVersion, endpointResponse.organization.apiVersion);
    System.Assert.isNotNull(endpointResponse.organization, System.JSON.serializePretty(endpointResponse.organization));
    System.Assert.areEqual(System.URL.getOrgDomainUrl()?.toExternalForm(), endpointResponse.organization.baseDomain);
    System.Assert.areEqual(System.UserInfo.getOrganizationId(), endpointResponse.organization.id);
    System.Assert.areEqual(System.UserInfo.getOrganizationName(), endpointResponse.organization.name);
    System.Assert.isNotNull(endpointResponse.user, System.JSON.serializePretty(endpointResponse.user));
    System.Assert.areEqual(System.UserInfo.getUserId(), endpointResponse.user.id);
    System.Assert.areEqual(System.UserInfo.getUserType(), endpointResponse.user.type);
  }
  /* End of common endpoint functionality tests */

  /* Start of SObject --> DTO conversion tests */
  @IsTest
  static void dto_classes_have_tests_added() {
    System.Assert.fail('TODO add tests to cover expected functionality for converting SObject records to DTOs');
  }
  /* End of SObject --> DTO conversion tests */

  /* Start of '/logs' endpoint tests */
  @IsTest
  static void logs_endpoint_get_returns_is_success_false_when_no_matching_transaction_id_found() {
    String fakeTransactionId = System.UUID.randomUUID().toString();
    System.RestContext.request = new System.RestRequest();
    System.RestContext.request.requestBody = null;
    System.RestContext.request.requestUri = LoggerRestResource.REQUEST_URI_BASE + '/logs/' + fakeTransactionId;

    LoggerRestResource.handleGet();

    System.Assert.areEqual(LoggerRestResource.STATUS_CODE_200_OK, System.RestContext.response.statusCode);
    System.Assert.areEqual('application/json', System.RestContext.response.headers.get('Content-Type'));
    System.Assert.isNotNull(System.RestContext.response.responseBody);
    LoggerRestResource.EndpointResponse endpointResponse = (LoggerRestResource.EndpointResponse) System.JSON.deserialize(
      System.RestContext.response.responseBody.toString(),
      LoggerRestResource.EndpointResponse.class
    );
    System.Assert.isFalse(endpointResponse.isSuccess);
    System.Assert.areEqual(1, endpointResponse.errors.size());
    System.Assert.areEqual('No matching logs found for transaction ID: ' + fakeTransactionId, endpointResponse.errors.get(0).message);
    System.Assert.areEqual(System.NoDataFoundException.class.getName(), endpointResponse.errors.get(0).type);
  }

  @IsTest
  static void logs_endpoint_get_successfully_returns_log_when_matching_transaction_id_is_found() {
    Log__c log = new Log__c(TransactionId__c = System.UUID.randomUUID().toString());
    insert log;
    System.RestContext.request = new System.RestRequest();
    System.RestContext.request.requestBody = null;
    System.RestContext.request.requestUri = LoggerRestResource.REQUEST_URI_BASE + '/logs/' + log.TransactionId__c + '/?some-parameter=true';

    LoggerRestResource.handleGet();

    System.Assert.areEqual(LoggerRestResource.STATUS_CODE_200_OK, System.RestContext.response.statusCode);
    System.Assert.areEqual('application/json', System.RestContext.response.headers.get('Content-Type'));
    System.Assert.isNotNull(System.RestContext.response.responseBody);
    LoggerRestResource.EndpointResponse endpointResponse = (LoggerRestResource.EndpointResponse) System.JSON.deserialize(
      System.RestContext.response.responseBody.toString(),
      LoggerRestResource.EndpointResponse.class
    );
    System.Assert.isTrue(endpointResponse.isSuccess);
    System.Assert.areEqual(0, endpointResponse.errors.size());
    // System.Assert.isNotNull(endpointResponse.result);
    LoggerRestResource.LogDTO logResult = (LoggerRestResource.LogDTO) endpointResponse.result;
    System.Assert.areEqual(log.TransactionId__c, logResult.transactionId);
    System.Assert.fail('TODO add more asserts, including asserts for log entry & tags');
  }

  @IsTest
  static void logs_endpoint_post_throws_an_exception_when_no_json_data_is_provided() {
    System.RestContext.request = new System.RestRequest();
    System.RestContext.request.requestBody = null;
    System.RestContext.request.requestUri = LoggerRestResource.REQUEST_URI_BASE + '/logs';

    LoggerRestResource.handlePost();

    System.Assert.areEqual(LoggerRestResource.STATUS_CODE_400_BAD_REQUEST, System.RestContext.response.statusCode);
    System.Assert.areEqual('application/json', System.RestContext.response.headers.get('Content-Type'));
    System.Assert.isNotNull(System.RestContext.response.responseBody);
    LoggerRestResource.EndpointResponse endpointResponse = (LoggerRestResource.EndpointResponse) System.JSON.deserialize(
      System.RestContext.response.responseBody.toString(),
      LoggerRestResource.EndpointResponse.class
    );
    System.Assert.isFalse(endpointResponse.isSuccess);
    System.Assert.areEqual(1, endpointResponse.errors.size());
    System.Assert.areEqual('No data provided', endpointResponse.errors.get(0).message);
    System.Assert.areEqual(System.IllegalArgumentException.class.getName(), endpointResponse.errors.get(0).type);
    // System.Assert.isNull(endpointResponse.result);
  }

  @IsTest
  static void logs_endpoint_post_throws_an_exception_when_null_origin_system_name_is_provided() {
    LoggerRestResource.LogDTO logCreateRequest = new LoggerRestResource.LogDTO();
    logCreateRequest.originSystemName = null;
    System.RestContext.request = new System.RestRequest();
    System.RestContext.request.requestBody = Blob.valueOf(System.JSON.serialize(logCreateRequest));
    System.RestContext.request.requestUri = LoggerRestResource.REQUEST_URI_BASE + '/logs';

    LoggerRestResource.handlePost();

    System.Assert.areEqual(LoggerRestResource.STATUS_CODE_400_BAD_REQUEST, System.RestContext.response.statusCode);
    System.Assert.areEqual('application/json', System.RestContext.response.headers.get('Content-Type'));
    System.Assert.isNotNull(System.RestContext.response.responseBody);
    LoggerRestResource.EndpointResponse endpointResponse = (LoggerRestResource.EndpointResponse) System.JSON.deserialize(
      System.RestContext.response.responseBody.toString(),
      LoggerRestResource.EndpointResponse.class
    );
    System.Assert.isFalse(endpointResponse.isSuccess);
    System.Assert.areEqual(1, endpointResponse.errors.size());
    System.Assert.areEqual('No data provided for required property "originSystemName"', endpointResponse.errors.get(0).message);
    System.Assert.areEqual(System.IllegalArgumentException.class.getName(), endpointResponse.errors.get(0).type);
    // System.Assert.isNull(endpointResponse.result);
  }

  @IsTest
  static void logs_endpoint_post_throws_an_exception_when_null_log_entries_list_is_provided() {
    LoggerRestResource.LogDTO logCreateRequest = new LoggerRestResource.LogDTO();
    logCreateRequest.originSystemName = 'some source system';
    logCreateRequest.logEntries = null;
    System.RestContext.request = new System.RestRequest();
    System.RestContext.request.requestBody = Blob.valueOf(System.JSON.serialize(logCreateRequest));
    System.RestContext.request.requestUri = LoggerRestResource.REQUEST_URI_BASE + '/logs';

    LoggerRestResource.handlePost();

    System.Assert.areEqual(LoggerRestResource.STATUS_CODE_400_BAD_REQUEST, System.RestContext.response.statusCode);
    System.Assert.areEqual('application/json', System.RestContext.response.headers.get('Content-Type'));
    System.Assert.isNotNull(System.RestContext.response.responseBody);
    LoggerRestResource.EndpointResponse endpointResponse = (LoggerRestResource.EndpointResponse) System.JSON.deserialize(
      System.RestContext.response.responseBody.toString(),
      LoggerRestResource.EndpointResponse.class
    );
    System.Assert.isFalse(endpointResponse.isSuccess);
    System.Assert.areEqual(1, endpointResponse.errors.size());
    System.Assert.areEqual('No data provided for required property "logEntries"', endpointResponse.errors.get(0).message);
    System.Assert.areEqual(System.IllegalArgumentException.class.getName(), endpointResponse.errors.get(0).type);
    // System.Assert.isNull(endpointResponse.result);
  }

  @IsTest
  static void logs_endpoint_post_throws_an_exception_when_empty_log_entries_list_is_provided() {
    LoggerRestResource.LogDTO logCreateRequest = new LoggerRestResource.LogDTO();
    logCreateRequest.originSystemName = 'some source system';
    logCreateRequest.logEntries = new List<LoggerRestResource.LogEntryDTO>();
    System.RestContext.request = new System.RestRequest();
    System.RestContext.request.requestBody = Blob.valueOf(System.JSON.serialize(logCreateRequest));
    System.RestContext.request.requestUri = LoggerRestResource.REQUEST_URI_BASE + '/logs';

    LoggerRestResource.handlePost();

    System.Assert.areEqual(LoggerRestResource.STATUS_CODE_400_BAD_REQUEST, System.RestContext.response.statusCode);
    System.Assert.areEqual('application/json', System.RestContext.response.headers.get('Content-Type'));
    System.Assert.isNotNull(System.RestContext.response.responseBody);
    LoggerRestResource.EndpointResponse endpointResponse = (LoggerRestResource.EndpointResponse) System.JSON.deserialize(
      System.RestContext.response.responseBody.toString(),
      LoggerRestResource.EndpointResponse.class
    );
    System.Assert.isFalse(endpointResponse.isSuccess);
    System.Assert.areEqual(1, endpointResponse.errors.size());
    System.Assert.areEqual('No data provided for required property "logEntries"', endpointResponse.errors.get(0).message);
    System.Assert.areEqual(System.IllegalArgumentException.class.getName(), endpointResponse.errors.get(0).type);
    // System.Assert.isNull(endpointResponse.result);
  }

  @IsTest
  static void logs_endpoint_post_successsfully_saves_otel_log_when_log_entries_are_provided() {
    LoggerRestResource.LogEntryDTO firstLogEntryCreateRequest = new LoggerRestResource.LogEntryDTO();
    firstLogEntryCreateRequest.loggingLevel = System.LoggingLevel.INFO.name();
    firstLogEntryCreateRequest.message = 'some message for INFO';
    firstLogEntryCreateRequest.timestamp = System.now().addDays(-1);
    LoggerRestResource.LogEntryDTO secondLogEntryCreateRequest = new LoggerRestResource.LogEntryDTO();
    secondLogEntryCreateRequest.loggingLevel = System.LoggingLevel.WARN.name();
    secondLogEntryCreateRequest.message = 'some message for WARN';
    secondLogEntryCreateRequest.timestamp = System.now().addDays(-1);
    LoggerRestResource.LogDTO logCreateRequest = new LoggerRestResource.LogDTO();
    logCreateRequest.originSystemName = 'some source system';
    logCreateRequest.logEntries = new List<LoggerRestResource.LogEntryDTO>();
    logCreateRequest.logEntries.add(firstLogEntryCreateRequest);
    logCreateRequest.logEntries.add(secondLogEntryCreateRequest);
    System.RestContext.request = new System.RestRequest();
    System.RestContext.request.requestBody = Blob.valueOf(System.JSON.serialize(logCreateRequest));
    System.RestContext.request.requestUri = LoggerRestResource.REQUEST_URI_BASE + '/logs';

    LoggerRestResource.handlePost();
    System.Test.getEventBus().deliver();

    System.Assert.areEqual(LoggerRestResource.STATUS_CODE_201_CREATED, System.RestContext.response.statusCode);
    System.Assert.areEqual('application/json', System.RestContext.response.headers.get('Content-Type'));
    System.Assert.isNotNull(System.RestContext.response.responseBody);
    LoggerRestResource.EndpointResponse endpointResponse = (LoggerRestResource.EndpointResponse) System.JSON.deserialize(
      System.RestContext.response.responseBody.toString(),
      LoggerRestResource.EndpointResponse.class
    );
    System.Assert.isTrue(endpointResponse.isSuccess);
    System.Assert.areEqual(0, endpointResponse.errors.size());
    System.Assert.areEqual(System.Request.getCurrent().getRequestId(), endpointResponse.requestId);
    System.Assert.areEqual(Logger.getTransactionId(), endpointResponse.transactionId);
    // System.Assert.isNotNull(endpointResponse.result);
    // TODO Revisit to add a specific count of log entries saved
    // System.Assert.isNotNull(endpointResponse.result.logEntriesSaved);
    // System.Assert.areEqual(logCreateRequest.logEntries.size(), endpointResponse.result.logEntriesSent);
    Log__c log = [SELECT Id, TransactionId__c FROM Log__c];
    System.Assert.areEqual(Logger.getTransactionId(), log.TransactionId__c);
    LogEntry__c firstLogEntry = [
      SELECT Id, LoggingLevel__c, Message__c, Timestamp__c, TransactionEntryNumber__c
      FROM LogEntry__c
      WHERE Log__c = :log.Id AND LoggingLevel__c = :firstLogEntryCreateRequest.loggingLevel
    ];
    System.Assert.areEqual(firstLogEntryCreateRequest.loggingLevel, firstLogEntry.LoggingLevel__c);
    System.Assert.areEqual(firstLogEntryCreateRequest.message, firstLogEntry.Message__c);
    // System.Assert.areEqual(firstLogEntryCreateRequest.timestamp, firstLogEntry.Timestamp__c);
    System.Assert.areEqual(1, firstLogEntry.TransactionEntryNumber__c);
    LogEntry__c secondLogEntry = [
      SELECT Id, LoggingLevel__c, Message__c, Timestamp__c, TransactionEntryNumber__c
      FROM LogEntry__c
      WHERE Log__c = :log.Id AND LoggingLevel__c = :secondLogEntryCreateRequest.loggingLevel
    ];
    System.Assert.areEqual(secondLogEntryCreateRequest.loggingLevel, secondLogEntry.LoggingLevel__c);
    System.Assert.areEqual(secondLogEntryCreateRequest.message, secondLogEntry.Message__c);
    // System.Assert.areEqual(secondLogEntryCreateRequest.timestamp, secondLogEntry.Timestamp__c);
    System.Assert.areEqual(2, secondLogEntry.TransactionEntryNumber__c);
  }

  @IsTest
  static void logs_endpoint_post_successsfully_saves_when_log_entries_are_provided() {
    LoggerRestResource.LogEntryDTO firstLogEntryCreateRequest = new LoggerRestResource.LogEntryDTO();
    firstLogEntryCreateRequest.loggingLevel = System.LoggingLevel.INFO.name();
    firstLogEntryCreateRequest.message = 'some message for INFO';
    firstLogEntryCreateRequest.timestamp = System.now().addDays(-1);
    LoggerRestResource.LogEntryDTO secondLogEntryCreateRequest = new LoggerRestResource.LogEntryDTO();
    secondLogEntryCreateRequest.loggingLevel = System.LoggingLevel.WARN.name();
    secondLogEntryCreateRequest.message = 'some message for WARN';
    secondLogEntryCreateRequest.timestamp = System.now().addDays(-1);
    LoggerRestResource.LogDTO logCreateRequest = new LoggerRestResource.LogDTO();
    logCreateRequest.originSystemName = 'some source system';
    logCreateRequest.logEntries = new List<LoggerRestResource.LogEntryDTO>();
    logCreateRequest.logEntries.add(firstLogEntryCreateRequest);
    logCreateRequest.logEntries.add(secondLogEntryCreateRequest);
    System.RestContext.request = new System.RestRequest();
    System.RestContext.request.requestBody = Blob.valueOf(System.JSON.serialize(logCreateRequest));
    System.RestContext.request.requestUri = LoggerRestResource.REQUEST_URI_BASE + '/logs';

    LoggerRestResource.handlePost();
    System.Test.getEventBus().deliver();

    System.Assert.areEqual(LoggerRestResource.STATUS_CODE_201_CREATED, System.RestContext.response.statusCode);
    System.Assert.areEqual('application/json', System.RestContext.response.headers.get('Content-Type'));
    System.Assert.isNotNull(System.RestContext.response.responseBody);
    LoggerRestResource.EndpointResponse endpointResponse = (LoggerRestResource.EndpointResponse) System.JSON.deserialize(
      System.RestContext.response.responseBody.toString(),
      LoggerRestResource.EndpointResponse.class
    );
    System.Assert.isTrue(endpointResponse.isSuccess);
    System.Assert.areEqual(0, endpointResponse.errors.size());
    System.Assert.areEqual(System.Request.getCurrent().getRequestId(), endpointResponse.requestId);
    System.Assert.areEqual(Logger.getTransactionId(), endpointResponse.transactionId);
    // System.Assert.isNotNull(endpointResponse.result);
    // TODO Revisit to add a specific count of log entries saved
    // System.Assert.isNotNull(endpointResponse.result.logEntriesSaved);
    // System.Assert.areEqual(logCreateRequest.logEntries.size(), endpointResponse.result.logEntriesSent);
    Log__c log = [SELECT Id, TransactionId__c FROM Log__c];
    System.Assert.areEqual(Logger.getTransactionId(), log.TransactionId__c);
    LogEntry__c firstLogEntry = [
      SELECT Id, LoggingLevel__c, Message__c, Timestamp__c, TransactionEntryNumber__c
      FROM LogEntry__c
      WHERE Log__c = :log.Id AND LoggingLevel__c = :firstLogEntryCreateRequest.loggingLevel
    ];
    System.Assert.areEqual(firstLogEntryCreateRequest.loggingLevel, firstLogEntry.LoggingLevel__c);
    System.Assert.areEqual(firstLogEntryCreateRequest.message, firstLogEntry.Message__c);
    // System.Assert.areEqual(firstLogEntryCreateRequest.timestamp, firstLogEntry.Timestamp__c);
    System.Assert.areEqual(1, firstLogEntry.TransactionEntryNumber__c);
    LogEntry__c secondLogEntry = [
      SELECT Id, LoggingLevel__c, Message__c, Timestamp__c, TransactionEntryNumber__c
      FROM LogEntry__c
      WHERE Log__c = :log.Id AND LoggingLevel__c = :secondLogEntryCreateRequest.loggingLevel
    ];
    System.Assert.areEqual(secondLogEntryCreateRequest.loggingLevel, secondLogEntry.LoggingLevel__c);
    System.Assert.areEqual(secondLogEntryCreateRequest.message, secondLogEntry.Message__c);
    // System.Assert.areEqual(secondLogEntryCreateRequest.timestamp, secondLogEntry.Timestamp__c);
    System.Assert.areEqual(2, secondLogEntry.TransactionEntryNumber__c);
  }

  @IsTest
  static void logs_endpoint_post_sets_parent_log_transaction_id_when_provided() {
    Log__c parentLog = new Log__c(TransactionId__c = 'some fake parent transaction id');
    insert parentLog;
    LoggerRestResource.LogEntryDTO logEntryCreateRequest = new LoggerRestResource.LogEntryDTO();
    logEntryCreateRequest.loggingLevel = System.LoggingLevel.INFO.name();
    logEntryCreateRequest.message = 'some message';
    logEntryCreateRequest.timestamp = System.now().addDays(-1);
    LoggerRestResource.LogDTO logCreateRequest = new LoggerRestResource.LogDTO();
    logCreateRequest.originSystemName = 'some source system';
    logCreateRequest.logEntries = new List<LoggerRestResource.LogEntryDTO>();
    logCreateRequest.logEntries.add(logEntryCreateRequest);
    logCreateRequest.parentLogTransactionId = parentLog.TransactionId__c;
    System.RestContext.request = new System.RestRequest();
    System.RestContext.request.requestBody = Blob.valueOf(System.JSON.serialize(logCreateRequest));
    System.RestContext.request.requestUri = LoggerRestResource.REQUEST_URI_BASE + '/logs';

    LoggerRestResource.handlePost();
    System.Test.getEventBus().deliver();

    System.Assert.areEqual(LoggerRestResource.STATUS_CODE_201_CREATED, System.RestContext.response.statusCode);
    System.Assert.areEqual('application/json', System.RestContext.response.headers.get('Content-Type'));
    System.Assert.isNotNull(System.RestContext.response.responseBody);
    LoggerRestResource.EndpointResponse endpointResponse = (LoggerRestResource.EndpointResponse) System.JSON.deserialize(
      System.RestContext.response.responseBody.toString(),
      LoggerRestResource.EndpointResponse.class
    );
    System.Assert.isTrue(endpointResponse.isSuccess);
    System.Assert.areEqual(0, endpointResponse.errors.size());
    System.Assert.areEqual(System.Request.getCurrent().getRequestId(), endpointResponse.requestId);
    System.Assert.areEqual(Logger.getTransactionId(), endpointResponse.transactionId);
    // System.Assert.isNotNull(endpointResponse.result);
    // TODO Revisit to add a specific count of log entries saved
    // System.Assert.isNotNull(endpointResponse.result.logEntriesSaved);
    // System.Assert.areEqual(logCreateRequest.logEntries.size(), endpointResponse.result.logEntriesSent);
    Log__c log = [SELECT Id, ParentLog__c, TransactionId__c FROM Log__c WHERE Id != :parentLog.Id];
    System.Assert.areEqual(parentLog.Id, log.ParentLog__c);
    System.Assert.areEqual(Logger.getTransactionId(), log.TransactionId__c);
  }

  @IsTest
  static void logs_endpoint_post_sets_scenario_when_provided() {
    LoggerRestResource.LogEntryDTO logEntryCreateRequest = new LoggerRestResource.LogEntryDTO();
    logEntryCreateRequest.loggingLevel = System.LoggingLevel.INFO.name();
    logEntryCreateRequest.message = 'some message';
    logEntryCreateRequest.timestamp = System.now().addDays(-1);
    LoggerRestResource.LogDTO logCreateRequest = new LoggerRestResource.LogDTO();
    logCreateRequest.originSystemName = 'some source system';
    logCreateRequest.logEntries = new List<LoggerRestResource.LogEntryDTO>();
    logCreateRequest.logEntries.add(logEntryCreateRequest);
    logCreateRequest.transactionScenario = 'some scenario';
    System.RestContext.request = new System.RestRequest();
    System.RestContext.request.requestBody = Blob.valueOf(System.JSON.serialize(logCreateRequest));
    System.RestContext.request.requestUri = LoggerRestResource.REQUEST_URI_BASE + '/logs';

    LoggerRestResource.handlePost();
    System.Test.getEventBus().deliver();

    System.Assert.areEqual(LoggerRestResource.STATUS_CODE_201_CREATED, System.RestContext.response.statusCode);
    System.Assert.areEqual('application/json', System.RestContext.response.headers.get('Content-Type'));
    System.Assert.isNotNull(System.RestContext.response.responseBody);
    LoggerRestResource.EndpointResponse endpointResponse = (LoggerRestResource.EndpointResponse) System.JSON.deserialize(
      System.RestContext.response.responseBody.toString(),
      LoggerRestResource.EndpointResponse.class
    );
    System.Assert.isTrue(endpointResponse.isSuccess);
    System.Assert.areEqual(0, endpointResponse.errors.size());
    System.Assert.areEqual(System.Request.getCurrent().getRequestId(), endpointResponse.requestId);
    System.Assert.areEqual(Logger.getTransactionId(), endpointResponse.transactionId);
    // System.Assert.isNotNull(endpointResponse.result);
    // TODO Revisit to add a specific count of log entries saved
    // System.Assert.isNotNull(endpointResponse.result.logEntriesSaved);
    // System.Assert.areEqual(logCreateRequest.logEntries.size(), endpointResponse.result.logEntriesSent);
    Log__c log = [SELECT Id, TransactionScenario__r.Name FROM Log__c];
    System.Assert.areEqual(logCreateRequest.transactionScenario, log.TransactionScenario__r.Name);
    List<LogEntry__c> logEntries = [SELECT Id, EntryScenario__r.Name FROM LogEntry__c];
    System.Assert.areEqual(logCreateRequest.logEntries.size(), logEntries.size());
    for (LogEntry__c logEntry : logEntries) {
      System.Assert.areEqual(logCreateRequest.transactionScenario, logEntry.EntryScenario__r.Name);
    }
  }

  @IsTest
  static void logs_endpoint_post_sets_related_record_id_when_provided() {
    String recordId = System.UserInfo.getUserId();
    LoggerRestResource.LogEntryDTO logEntryCreateRequest = new LoggerRestResource.LogEntryDTO();
    logEntryCreateRequest.loggingLevel = System.LoggingLevel.INFO.name();
    logEntryCreateRequest.message = 'some message';
    logEntryCreateRequest.relatedRecordId = recordId;
    logEntryCreateRequest.timestamp = System.now().addDays(-1);
    LoggerRestResource.LogDTO logCreateRequest = new LoggerRestResource.LogDTO();
    logCreateRequest.originSystemName = 'some source system';
    logCreateRequest.logEntries = new List<LoggerRestResource.LogEntryDTO>();
    logCreateRequest.logEntries.add(logEntryCreateRequest);
    System.RestContext.request = new System.RestRequest();
    System.RestContext.request.requestBody = Blob.valueOf(System.JSON.serialize(logCreateRequest));
    System.RestContext.request.requestUri = LoggerRestResource.REQUEST_URI_BASE + '/logs';

    LoggerRestResource.handlePost();
    System.Test.getEventBus().deliver();

    System.Assert.areEqual(LoggerRestResource.STATUS_CODE_201_CREATED, System.RestContext.response.statusCode);
    System.Assert.areEqual('application/json', System.RestContext.response.headers.get('Content-Type'));
    System.Assert.isNotNull(System.RestContext.response.responseBody);
    LoggerRestResource.EndpointResponse endpointResponse = (LoggerRestResource.EndpointResponse) System.JSON.deserialize(
      System.RestContext.response.responseBody.toString(),
      LoggerRestResource.EndpointResponse.class
    );
    System.Assert.isTrue(endpointResponse.isSuccess);
    System.Assert.areEqual(0, endpointResponse.errors.size());
    System.Assert.areEqual(System.Request.getCurrent().getRequestId(), endpointResponse.requestId);
    System.Assert.areEqual(Logger.getTransactionId(), endpointResponse.transactionId);
    // System.Assert.isNotNull(endpointResponse.result);
    // TODO Revisit to add a specific count of log entries saved
    // System.Assert.isNotNull(endpointResponse.result.logEntriesSaved);
    // System.Assert.areEqual(logCreateRequest.logEntries.size(), endpointResponse.result.logEntriesSent);
    LogEntry__c logEntry = [
      SELECT Id, RecordId__c
      FROM LogEntry__c
      WHERE Log__r.TransactionId__c = :endpointResponse.transactionId
    ];
    System.Assert.areEqual(logEntryCreateRequest.relatedRecordId, logEntry.RecordId__c);
  }

  @IsTest
  static void logs_endpoint_post_stores_tags_when_provided() {
    LoggerRestResource.LogEntryDTO logEntryCreateRequest = new LoggerRestResource.LogEntryDTO();
    logEntryCreateRequest.loggingLevel = System.LoggingLevel.INFO.name();
    logEntryCreateRequest.message = 'some message';
    logEntryCreateRequest.timestamp = System.now().addDays(-1);
    logEntryCreateRequest.tags = new List<String>{ 'some tag', 'another tag' };
    LoggerRestResource.LogDTO logCreateRequest = new LoggerRestResource.LogDTO();
    logCreateRequest.originSystemName = 'some source system';
    logCreateRequest.logEntries = new List<LoggerRestResource.LogEntryDTO>();
    logCreateRequest.logEntries.add(logEntryCreateRequest);
    System.RestContext.request = new System.RestRequest();
    System.RestContext.request.requestBody = Blob.valueOf(System.JSON.serialize(logCreateRequest));
    System.RestContext.request.requestUri = LoggerRestResource.REQUEST_URI_BASE + '/logs';

    LoggerRestResource.handlePost();
    System.Test.getEventBus().deliver();

    System.Assert.areEqual(LoggerRestResource.STATUS_CODE_201_CREATED, System.RestContext.response.statusCode);
    System.Assert.areEqual('application/json', System.RestContext.response.headers.get('Content-Type'));
    System.Assert.isNotNull(System.RestContext.response.responseBody);
    LoggerRestResource.EndpointResponse endpointResponse = (LoggerRestResource.EndpointResponse) System.JSON.deserialize(
      System.RestContext.response.responseBody.toString(),
      LoggerRestResource.EndpointResponse.class
    );
    LogEntry__c logEntry = [
      SELECT Id, (SELECT Id, Tag__r.Name FROM LogEntryTags__r)
      FROM LogEntry__c
    ];
    System.Assert.areEqual(logEntryCreateRequest.tags.size(), logEntry.LogEntryTags__r.size());
    Set<String> providedTags = new Set<String>(logEntryCreateRequest.tags);
    for (LogEntryTag__c logEntryTag : logEntry.LogEntryTags__r) {
      System.Assert.isTrue(providedTags.contains(logEntryTag.Tag__r.Name));
    }
  }
  /* End of '/logs' endpoint tests */

  /* Start of '/log-entries' endpoint tests */
  @IsTest
  static void log_entries_endpoint_has_tests_added() {
    System.Assert.fail('TODO add tests to cover expected functionality for /log-entries endpoint');
  }
  /* End of '/log-entries' endpoint tests */

  /* Start of '/logger-scenarios' endpoint tests */
  @IsTest
  static void logger_scenarios_endpoint_has_tests_added() {
    System.Assert.fail('TODO add tests to cover expected functionality for /logger-scenarios endpoint');
  }
  /* End of '/logger-scenarios' endpoint tests */

  /* Start of '/logger-tags' endpoint tests */
  @IsTest
  static void logger_tags_endpoint_has_tests_added() {
    System.Assert.fail('TODO add tests to cover expected functionality for /logger-tags endpoint');
  }
  /* End of '/logger-tags' endpoint tests */
}