'use strict';

/**
 * Sample Lambda handler — consumes SQS records, writes them to DynamoDB,
 * and archives the raw payload to S3. This is the deployment package
 * referenced by var.lambda_s3_bucket / var.lambda_s3_key.
 */

exports.handler = async (event) => {
  for (const record of event.Records || []) {
    const body = JSON.parse(record.body);
    console.log('Processing event:', body.eventId || body.MessageId);
    // Wire in DynamoDB PutItem / S3 PutObject here using the
    // DYNAMODB_TABLE and ARCHIVE_BUCKET environment variables.
  }

  return { statusCode: 200, processed: (event.Records || []).length };
};
