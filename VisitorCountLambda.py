import boto3
from boto3.dynamodb.conditions import Key

PROJECT_ID = 'visitor'

dynamo = boto3.resource('dynamodb')
client = dynamo.Table('Visitor_Count')

# Lambda Handler
def lambda_handler(event, context):
    try:
        # Query for the last sorted value in the given item collection
        response = client.query(
            KeyConditionExpression=Key('Visitor').eq(PROJECT_ID),
            ScanIndexForward=False,
            Limit=1
        )

        # Retrieve the sort key value
        if response['Count'] > 0:
            TotalVisitors = int(response['Items'][0]['TotalVisitors'])
        else:
            TotalVisitors = 0

        # Write using the next value in the sequence, but only if the item doesn’t exist
        response = client.put_item(
            Item={
                'Visitor': PROJECT_ID, 
                'TotalVisitors': TotalVisitors + 1, 
            },
            ConditionExpression='attribute_not_exists(Visitor)'
        )

        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
            },
            'body': 'Successfully updated TotalVisitors',
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
            },
            'body': f'Error: {str(e)}',
        }
