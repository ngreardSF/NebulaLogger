//------------------------------------------------------------------------------------------------//
// This file is part of the Nebula Logger project, released under the MIT License.                //
// See LICENSE file or go to https://github.com/jongpie/NebulaLogger for full license details.    //
//------------------------------------------------------------------------------------------------//
trigger LoggerBatchApexErrorEventTrigger on BatchApexErrorEvent(after insert) {
  LoggerSObjectHandler.getHandler(Schema.BatchApexErrorEvent.SObjectType, new LoggerBatchApexErrorEventHandler()).execute();
}
