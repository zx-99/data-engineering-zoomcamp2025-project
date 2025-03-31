# 🛠 Reproduce Guide

## ✅ Create a New GCP Project

Navigate to [Google Cloud Platform](https://console.cloud.google.com/) and create a new project by clicking the dropdown next to the current project name, then click **NEW PROJECT**.

## ✅ Create a Service Account

1. Go to **IAM & Admin > Service Accounts** via the navigation menu.
2. Click **CREATE SERVICE ACCOUNT**, name it `project-demo`, and assign the following roles:
   - BigQuery Admin
   - Storage Admin
   - Compute Admin
3. After creation, click the ellipsis next to the account and choose **Manage keys**.
4. Click **ADD KEY** > **Create new key** > Choose **JSON** > **CREATE**.
   - This downloads your credentials file (save it securely).

## ✅ Setup Infrastructure with Terraform

1. Navigate to the terraform directory:

```bash
cd terraform
```

2. Install Terraform (if not installed):

```bash
brew install hashicorp/tap/terraform
```

3. Edit the `variables.tfvars` file:
   - Set up your serive accout JSON file path in ```credentials```
   - Set your GCP project ID
   - Leave others as **default**
4. Initialize Terraform:

```bash
terraform init
```

5. Preview the Terraform plan:

```bash
terraform plan
```

6. Apply the configuration to create resources:

```bash
terraform apply
```

- When prompted, type `yes` to confirm.

## ✅ Setup Pipelines in Kestra

1. Navigate to the Kestra directory:

```bash
cd workflow_orchestration
```

2. Launch Kestra with Docker Compose:

```bash
docker-compose up -d
```

- Access Kestra UI at: [http://localhost:8080](http://localhost:8080)

3. Run the following commands to add flows programmatically using Kestra's API:

```bash
curl -X POST http://localhost:8080/api/v1/flows/import -F fileUpload=@flows/01_gcp_kv.yaml
curl -X POST http://localhost:8080/api/v1/flows/import -F fileUpload=@flows/02_gcp_setup.yaml
curl -X POST http://localhost:8080/api/v1/flows/import -F fileUpload=@flows/03_gcp_spotify_pipeline.yaml
```

4. In the UI:

   - Go to Namespace > `spotify`
   - Open **KV Store** and create `GCP_CREDS`
   - Paste JSON from your service account
![](../asset/namespace.png)
![](../asset/kv_store.png)
![](../asset/new_key_value.png)
![](../asset/create_creds.png)
5. Execute Flows:

![](../asset/flow.png)

   - Run `gcp_kv` → input your Project ID and leave others as default → execute
![](../asset/01_flow.png)
![](../asset/01_execute.png)
![](../asset/01_success.png)

   - Run `gcp_setup`

![](../asset/02_flow.png)
![](../asset/02_execute.png)
![](../asset/02_success.png)

   - Run `gcp_spotify_pipeline`

![](../asset/03_flow.png)
![](../asset/03_execute.png)
![](../asset/03_success.png)

7. Confirm data has been loaded:

   - Check GCS bucket
   - Check BigQuery
![](../asset/gcs_bucket.png)
![](../asset/bq.png)

To stop Kestra:

```bash
docker compose down
```

## ✅ Transform Data with dbt (dbt Cloud)
Create a dbt user account by going to [dbt homepage](https://www.getdbt.com/) and signing up for a free account.

Non-enterprise account can have only one project. Navigate to Account > Projects to delete any old project. Now we can go to the homepage to setup a new project. Please set up the project detail as following.
![](../asset/dbt_project.png)

Add new connection --> Select BigQuery

Click on Upload a Service Account JSON file
![](../asset/dbt_new_connection.png)

Find Optional settings, then set location to **australia-southeast1**, click on Save
![](../asset/dbt_location.png)

Back on your project setup, select BigQuery:
![](../asset/dbt_select_bq.png)

Set values as following, then test the connection and click on save the Development credentials, :
![](../asset/dbt_test_connection.png)

Now its time to setup a repository:
![](../asset/dbt_repo1.png)

Select git clone and paste the SSH key from your repo:
![](../asset/dbt_repo2.png)

Click on import --> Click on next

You will get a deploy key
Head to your Github repo and go to the settings tab. You'll find the menu deploy keys. Click on add key and paste the deploy key provided by dbt cloud. Make sure to click on "write access":
![](../asset/dbt_repo3.png)

Back on dbt cloud, click on next, you should look this:
![](../asset/dbt_repo4.png)

Also make sure you set **dbt/spotify** as the project subdirectory.

Navigate to **Develop** tab on the top to view the project.

dbt does not allow us to work on the main branch after this, hence we need to create a new branch.

### Build the dbt project
If we click on the Lineage tab in the bottom, we should see this diagram:
![](../asset/dbt_lineage.png)
To build the project run:
```bash
dbt build
```
dbt docs can be generated on the cloud or locally with ```dbt docs generate```, and can be hosted in dbt Cloud.

Now, if we navigate to BigQuery we will be able to see the tables created by dbt which is **dbt_spotify**.
![](../asset/dbt_cloud.png)

## ✅ Visualize with Looker Studio

Navigate to Google Looker Studio.

Click on **Create** > **Data source** > **BigQuery** > authorize **BigQuery** > select the Project > Dataset > Table (**fact_spotify**) > **CONNECT**.

Change the default aggregation of categorical fields from **Sum** to **None**. 
![](../asset/visual1.png)
Change the following aggregation of fields to AVG. 
![](../asset/visual2.png)
Then, click on **CREATE REPORT** > **ADD TO REPORT**.Rename the report as **Spotify 2025 Q1 in AU**

### Country control
1. Add a control of Drop-down list
2. Date range dimension = ```snapshot_date```
3. Control field = ```country```
4. Select ```Australia```

### Date control
1. Add a control of Date range control
2. Select ```1 Jan 2025 - 31 Mar 2025```

### Top 10 Artists and Songs by Average Daily Rank in Australia
1. Create Table with bars
2. Date range dimension = ```snapshot_date```
3. Dimension = ```artists```, ```song_name``` 
4. Metric = AVG ```daily_rank```
5. Number of row= Top 10
6. Sort = AVG ```daily_rank``` ASCENDING
7. Go to **STYLE** -> **Metrics** -> Select **Show number** & **Compact numbers**
![](../asset/figure1.png)
### Audio Feature Distribution of Top 10 Songs
1. Create Column Chart
2. Date range dimension = ```snapshot_date```
3. Dimension = ```song_name```
4. Metric = AVG ```danceability```, AVG ```energy```, AVG ```valence```, AVG ```acousticness```, AVG ```instrumentalness```, AVG ```liveness```
5. Sort = AVG ```daily_rank``` ASCENDING 
![](../asset/figure2.png)
### Explicit Content Proportion in Top Songs
1. Create Pie chart
2. Date range dimension = ```snapshot_date```
3. Dimension = ```is_explicit```
4. Metric = CTD ```song_name```

![](../asset/figure3.png)
### Energy vs. Popularity (Australia, Q1 2025)
1. Create Scatter chart
2. Date range dimension = ```snapshot_date```
3. Dimension = ```song_name```
4. Metric X = AVG ```energy```
5. Metric Y = AVG ```popularity```
6. Sort = AVG ```energy``` DESCENDING

![](../asset/figure4.png)
### Danceability vs. Popularity (Australia, Q1 2025)
1. Create Scatter chart
2. Date range dimension = ```snapshot_date```
3. Dimension = ```song_name```
4. Metric X = AVG ```danceability```
5. Metric Y = AVG ```popularity```
6. Sort = AVG ```danceability``` DESCENDING

![](../asset/figure5.png)

## 🧹 Destroy Resources

1. Navigate to the terraform directory
```bash
cd terraform/
```
2. Destroy resources created by terraform
```bash
terraform destroy
```
3. Delete GCP project
4. Delete dbt project
5. Delete Looker Studio dashboard
