# Message for Stakeholder

Upon reviewing the data via programming tools as well as taking a glimpse at the raw data, I found out around 20% of all approved rewarding receipts have a singular item with bar code that is “Item Not Found”, which raises question regarding the provenance of the data.

It’s highly possible that some of these users might either be “test” users as there are testing brands in the dataset or there are certain errors that got triggered and these data got fed into the system.

I would definitely need more contexts to have a thorough analysis through the data. Data dictionary would be very helpful, especially for the some of the keys in Receipts.**rewardsReceiptItemList .** Such that a more systematic approach can be established to parse the json data into structural data for the data warehouse.

For example, explanation on the keys in **rewardsReceiptItemList** will also be helpful in detecting anomaly as I also noticed there are inconsistencies with the target price and final price on certain items.

Down the road, in order to have a scalable solution that is resilient to changes and aligned with continuous delivery,  leveraging Spark and having uniform key/value dictionary (i.e. what key/value should downstream task expect) would be the key step. 

Implementing a log monitor function that would notify the team if a threshold-exceeding amount of parsing errors occur would be the next step once a workable solution is established.