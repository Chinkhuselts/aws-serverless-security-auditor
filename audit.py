import json
import boto3
import os

s3 = boto3.client('s3')
sns = boto3.client('sns')
SNS_TOPIC_ARN = os.environ['SNS_TOPIC_ARN']

def lambda_handler(event, context):
    # 1. Get the bucket name and file name from the event
    record = event['Records'][0]
    bucket_name = record['s3']['bucket']['name']
    file_key = record['s3']['object']['key']
    
    print(f"Scanning file: {file_key} in bucket: {bucket_name}")

    try:
        # 2. Fetch the file content from S3
        response = s3.get_object(Bucket=bucket_name, Key=file_key)
        file_content = response['Body'].read().decode('utf-8')
        config = json.loads(file_content)

        # 3. Security Check Logic (The "Audit")
        # Rule: If "public_access" is set to True, it's a security risk.
        if config.get('public_access') == True:
            risk_message = f"CRITICAL: Public access detected in configuration file '{file_key}'!"
            print(risk_message)
            
            # 4. Send Alert via SNS
            sns.publish(
                TopicArn=SNS_TOPIC_ARN,
                Message=risk_message,
                Subject="Security Alert: Vulnerability Detected"
            )
            return {"status": "Risk Found", "action": "Alert Sent"}
        
        else:
            print("Audit Passed: Configuration is secure.")
            return {"status": "Secure"}

    except Exception as e:
        print(f"Error processing file: {str(e)}")
        raise e