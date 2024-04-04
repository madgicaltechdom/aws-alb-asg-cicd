import os
import time
import sys
import boto3


def main():
    asg_name = os.environ.get('ASG_NAME')
    assert asg_name is not None, 'Must set ASG_NAME in environment.'

    autoscaling = boto3.client('autoscaling', region_name='ap-south-1')

    try:
        refresh = autoscaling.describe_instance_refreshes(
            AutoScalingGroupName=asg_name,
            MaxRecords=1
        )

        instance_refreshes = refresh.get('InstanceRefreshes', [])
        if instance_refreshes:
            refresh = instance_refreshes[0]
            
            status = refresh.get('Status')
            end_time = refresh.get('EndTime')

            if status:
                print(f"Instance Refresh Status: {status}")

            if end_time:
                print(f"Instance Refresh End Time: {end_time}")
        else:
            refresh = autoscaling.start_instance_refresh(
                AutoScalingGroupName=asg_name
            )
            time.sleep(600)

            refresh = autoscaling.describe_instance_refreshes(AutoScalingGroupName=asg_name,
                                                              InstanceRefreshIds=[refresh['InstanceRefreshId']])[
                'InstanceRefreshes'][0]

            status = refresh.get('Status')
            end_time = refresh.get('EndTime')

            if status:
                print(f"Instance Refresh Status: {status}")

            if end_time:
                print(f"Instance Refresh End Time: {end_time}")

    except Exception as e:
        print(f'An error occurred: {str(e)}')
        sys.exit(os.EX_UNAVAILABLE)


if __name__ == '__main__':
    main()

