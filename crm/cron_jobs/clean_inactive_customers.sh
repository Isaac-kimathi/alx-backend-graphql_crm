cat > crm/cron_jobs/clean_inactive_customers.sh << 'EOF'

#!/bin/bash

# Get the script directory using BASH_SOURCE
DIR_SCRIPT= "$(dirname "${BASH_SOURCE[0]")"

# Navigate to the Django project dir (two levels up from cron_jobs)
cd "$DIR_SCRIPT/../.."

# Check the directory
pwd

# change working directory to project root
cdir = $(pwd)

#Get the current timestamp
currenttime = $(date '+%Y-%m-%d %H:%M:%S')

# Execute Django shell command to delete all inactive customers
customers_delete = $(python manage.py shell << 'PYTHON_EOF'

import django
from django.utils import timezone
from datetime import timedelta
from crm.models import Customer

Lst_yr = timezone.now() - timedelta(days=365)

passive_customers = Customer.objects.filter(
	orders_isnull=True
) | Customer.objects.exclude(
	orders_order_date__=Lst_yr
).distinct()

cnt = passive_customers.count()
if cnt > 0:
	passive_customers.delete
	print(f"Deleted {cnt} passive customers")
else:
	print("No passive customers found")
print(cnt)

PYTHON_EOF
)

# Log the result with the time stamp
echo "[$currenttime] Delected $customers_delete passive customers" >> /tmp/customer_cleanup_log.txt

EOF
