from gql import gql, Client
from gql.transport.requests import RequestsHTTPTransport
from datetime import datetime, timedelta, timezone
import logging

# configuring of the logging system
logging.basicConfig(filename="/tmp/order_reminders_log.txt", level=logging.INFO)

# connect to GraphQL API
transport = RequestsHTTPTransport(
        url="http://localhost:8000/graphql",
        verify=False,
        retries=3,
)

#create a GraphQL client
clt = Client(transport=transport, fetch_schema_from_transport=False)
# sets current time
Lst_week = (datetime.now(timezone.utc) - timedelta(days=7)).strftime("%Y-%m-%d")

#Definition of a GraphQuery
query = gql("""
query ($date: Date!) {
    orders(orderDate_Gte: $date) {
        id
        customer {
            email
            }
    }
}
""")

#Executing the query
try:
    rst = clt.execute(query, variable_values={"date": Lst_week})
    orders = rst.get("orders", [])

    #Logging the results
    for order in orders:
        email = order.get("customer", {}).get("email", "N/A")
        logging.info("Order ID: %s, Email: %s", order["id"], email)

    print("Order reminders processed!")
except Exception as e:
    print("Error:", e)
        print("Error:", e)
