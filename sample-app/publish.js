'use strict';

/**
 * Zero-framework event publisher proving the SNS → SQS → Lambda → DynamoDB/S3
 * pipeline works end-to-end. Requires only the AWS SDK v3 SNS client.
 *
 * Usage:
 *   npm install
 *   SNS_TOPIC_ARN=$(terraform output -raw sns_topic_arn) \
 *   AWS_REGION=us-east-1 \
 *   node publish.js
 */

const { SNSClient, PublishCommand } = require('@aws-sdk/client-sns');

const TOPIC_ARN = process.env.SNS_TOPIC_ARN;
const REGION = process.env.AWS_REGION || 'us-east-1';

if (!TOPIC_ARN) {
  console.error('Set SNS_TOPIC_ARN to the output of: terraform output -raw sns_topic_arn');
  process.exit(1);
}

const client = new SNSClient({ region: REGION });

async function main() {
  const event = {
    eventId: `evt-${Date.now()}`,
    eventType: 'sample.order.created',
    payload: { orderId: 'ORD-1001', amount: 49.99, currency: 'USD' },
    emittedAt: new Date().toISOString(),
  };

  const command = new PublishCommand({
    TopicArn: TOPIC_ARN,
    Message: JSON.stringify(event),
    MessageAttributes: {
      eventType: { DataType: 'String', StringValue: event.eventType },
    },
  });

  const result = await client.send(command);
  console.log('Published event', event.eventId, '-> MessageId:', result.MessageId);
}

main().catch((err) => {
  console.error('Failed to publish event:', err);
  process.exit(1);
});
