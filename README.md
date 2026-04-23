## SaaS Revenue & Churn Analysis

This project analyzes a synthetic SaaS subscription dataset to evaluate business growth, customer retention, and profitability. SaaS companies often face two core challenges: acquiring customers efficiently while minimizing churn. The goal of this analysis was to identify the key drivers of recurring revenue, detect churn risks, and assess whether customer acquisition efforts are generating sustainable returns.

### Business Problem

Many SaaS businesses grow revenue through new customer acquisition, but long-term success depends on retaining customers and maximizing lifetime value. High churn, weak product engagement, or expensive acquisition costs can reduce profitability even when top-line revenue is increasing.

### Approach

Using SQL for data cleaning, transformation, and KPI analysis, I explored two datasets covering monthly revenue trends and customer subscription behavior. Key analyses included:

* **Revenue Trends:** Tracked Monthly Recurring Revenue (MRR), customer growth, and net revenue change over time.
* **Retention & Churn:** Measured churn rates and identified months with unusual spikes or dips.
* **Unit Economics:** Calculated Customer Lifetime Value (CLV), Customer Acquisition Cost (CAC), and CLV:CAC ratios by plan.
* **At-Risk Customers:** Analyzed feature usage, NPS scores, and churn behavior to flag customers with elevated churn risk.
* **Customer Segmentation:** Compared performance across plans, industries, and acquisition channels.

### Key Insights

* Higher-tier plans generated stronger lifetime value and healthier CLV:CAC ratios.
* Customers with low feature usage and weak NPS scores showed significantly higher churn likelihood.
* Revenue volatility was often tied to churn spikes rather than acquisition slowdowns.
* Certain customer segments delivered better retention and profitability than others.

### Tools Used

* **SQL (MySQL)** for querying, KPI calculations, and data transformation
* **Tableau / Power BI** for dashboarding and visualization

### Outcome

This project demonstrates how data can be used to improve SaaS decision-making across growth, retention, pricing, and customer success strategy.
