import json
from datetime import datetime, timezone


def handler(event, context):
    return {
        'statusCode': 200,
        'body': json.dumps(f'Hello World! It is now {datetime.now(tz=timezone.utc)}.')
    }