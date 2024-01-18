import json
from decimal import Decimal
import boto3

def lambda_handler(event, context):
    dynamodb = boto3.resource('dynamodb')
    table_name = 'Visitor_Count'
    sort_key_name = 'TotalVisitors'
    partition_key_name = 'Visitor'

    table = dynamodb.Table(table_name)

    def decimal_default(obj):
        if isinstance(obj, Decimal):
            return float(obj)
        raise TypeError

    try:
        # Set ConsistentRead to True for strongly consistent read
        response = table.query(
            Limit=1,
            ScanIndexForward=False,
            KeyConditionExpression=f'#pk = :pk AND #sk > :sk',
            ExpressionAttributeNames={'#pk': partition_key_name, '#sk': sort_key_name},
            ExpressionAttributeValues={':pk': 'visitor', ':sk': 0},
            ConsistentRead=True  # Set ConsistentRead to True for strongly consistent read
        )

        greatest_sort_key = response['Items'][0][sort_key_name] if 'Items' in response and response['Items'] else None

        return {
            'statusCode': 200,
            'body': json.dumps({'greatest_sort_key': greatest_sort_key}, default=decimal_default)
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps(str(e))
        }
