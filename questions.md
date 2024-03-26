Construct an email or slack message that is understandable to a product or business leader who isn’t
 familiar with your day to day work. This part of the exercise should show off how you communicate and 
 reason about data with others. Commit your answers to the git repository along with the rest of your exercise.

#### What questions do you have about the data?
After reviewing the data provided, I have some remaining questions:
 - How are these datasets created?
 - Is the data provided complete or is there additional information to append?
 - How often is each dataset updated?
 - Based on my data model, are these columns expected to be consistent? Are there ever significant chages to the data schema?


#### How did you discover the data quality issues?
After exploring the data, I have noticed some inconsistencies. Starting with trying to extract barcode from the receipts table. I wanted to extract and explode that column to use it as a key in a new table, itemList. However, the barcodes are often missing or unknown. After that, I found a receipt with a barcode that was not in the brands dataset. 

Looking closer at the brands table led me to discover that the barcodes are not unique by row. I expected barcodes to be unique item identifiers. If this is inaccurate, please let me know and I can determine a different way to join the receipt and brand datasets.

According to the documentation, the users table column 'role' should be set to 'CONSUMER'. The users table currently has 82 rows that with the role 'fetch-staff' and 'consumer' is not capitalized. Additionally, there are IDs with multiple rows of data. These will need to be deduplicated to create an accurate users table.


#### What do you need to know to resolve the data quality issues?
To resolve my concerns with the barcodes in the receipts data, I would like know the expected percentage of missing or unknown receipts. Given the data source, some missing or unknown receipts are expected. 
Secondly, I would like to know if there is additional data to add to the brands database. If not, should new brands and barcodes be added from the receipt data?

Additionally, I would like to understand if barcodes are unique by item. If not, what are the unique item identifiers?

Lastly, I would like to understand how the user table is created and how duplicate records are created. Can the users table be deduplicated by ID or can an ID actually represent multiple users?


#### What other information would you need to help you optimize the data assets you're trying to create?
I would prefer to discuss this question as a meeting or call with the stakeholder. A conversation would be more helpful for this question to make sure that we are both aligned on the data and their use cases.

In order to optimize the data assets, it would be helpful to understand the stakeholder's business and business concerns.
Additionally, I would like their priorities with the data. If they would like to optimize storage space, we may need to provide a more normalized data model. If the client users are going to make insights dashboard, we may need to create a further denormalized table for their dashboarding solution.

The questions I would ask during a meeting would be:
- What are your main business objectives and concerns?
- What insights would you like to generate from this data?
- Which team will be ingesting this data and what are their data tools?
- Do you have any concerns about working with large datasets?
- Is this data going to be combined with your internal data? If so, how do you plan to join these datasets?

#### What performance and scaling concerns do you anticipate in production and how do you plan to address them?
Currently the data '_id' columns contain duplicates in several tables. If we were to use '_id' as a joining key, it would create redundant data with slow performance. All of the tables need to be checked for duplicates and de-duplicated. 
If the receipts data becomes very large and the brands table becomes very large, we may want to make a pre-joined table for data analysts to use. This would save computing cost since the join could be performed once instead of in every query that needs those tables. We can also reduce computing power and storage by only including necessary columns in the final datasets. There could even be pre-filtered data depending on the client's needs.