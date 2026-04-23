select * from subscriptions;
select * from monthly_revenue;

-- 1. CHURN ANALYSIS

-- Modifying churn rate

set SQL_SAFE_UPDATES = 0;
update subscriptions
set churned = case
    when churned = 'Yes' then '1'
    when churned = 'No' then '0'
end;
alter table subscriptions
modify column churned int;

-- Overal churn rate

select round(sum(churned) * 100.0 / count(*), 2) as overall_churn_rate
from subscriptions;

-- Churn rate by plan

select
	plan,
	count(customer_id) as total_customer,
	round(sum(churned) * 100.0 / count(customer_id), 2) as churn_rate
from subscriptions
group by plan
order by churn_rate desc;

-- Churn rate by billing cycle

select
	billing_cycle,
	count(customer_id) as total_customer,
	round(sum(churned) * 100.0 / count(customer_id), 2) as churn_rate
from subscriptions
group by billing_cycle
order by churn_rate desc;

-- Churn rate by acquisition channel

select
	acquisition_channel,
	count(customer_id) as total_customer,
	round(sum(churned) * 100.0 / count(customer_id), 2) as churn_rate
from subscriptions
group by acquisition_channel
order by churn_rate desc;

-- Churn rate by  company size

select
	company_size,
	count(customer_id) as total_customer,
	round(sum(churned) * 100.0 / count(customer_id), 2) as churn_rate
from subscriptions
group by company_size
order by churn_rate desc;

-- Churn reasons

select 
    churn_reason,
    count(*) as total_churn
from subscriptions
group by churn_reason
order by total_churn desc
;
    
-- 2.  REVENUE ANALYSIS

-- MRR trend over time

SELECT month, total_mrr, total_active_customers
FROM monthly_revenue
ORDER BY month;

-- New MRR (Rev gained from new cus) & Churned MRR (Rev lost from who cancelled)

with rev_movement as (
select
	month,
    round((new_customers * avg_revenue_per_customer),2) as new_MRR,
    round((churned_customers * avg_revenue_per_customer),2) as churned_MRR
from monthly_revenue )
select 
	month, new_MRR, churned_MRR,
    round((new_MRR - churned_MRR),2) as net_revenue_change
from rev_movement;

alter table monthly_revenue
add column new_mrr decimal(12,2),
add column churned_mrr decimal(12,2),
add column net_revenue_change decimal(12,2);

update monthly_revenue
set
new_mrr = new_customers * avg_revenue_per_customer,
churned_mrr = churned_customers * avg_revenue_per_customer,
net_revenue_change = (new_customers - churned_customers) * avg_revenue_per_customer;

-- Identify Unusual Spikes or Dips

with revenue_inspection as (
select
	month,
	net_revenue_change,
    LAG(net_revenue_change) over(order by month) as previous_month,
    net_revenue_change - lag(net_revenue_change) over(order by month) as change_vs_previous
from monthly_revenue
order by month )
select 
	month,
	net_revenue_change,
    previous_month,
    change_vs_previous,
    case
		when change_vs_previous > 4000 then 'Spike'
		when change_vs_previous < -4000 then 'Dip'
		else 'Normal'
	end as trend_flag
from revenue_inspection
order by month;

-- 3. UNIT ECONOMICS

-- Average CLV Per Plan

select 
	plan,
	round(avg(monthly_revenue),2) as avg_mrr,
	round(sum(churned) * 1.0 / count(*),4) as churn_rate,
	round(1.0 / nullif(sum(churned) * 1.0 / count(*),0),2) as estimated_lifespan_months,
	round(avg(monthly_revenue) * (1.0 / NULLIF(SUM(churned) * 1.0 / COUNT(*),0)),2) as clv
from subscriptions
group by plan
order by clv desc;

-- CLV:CAC Ratio

with clv_table as (
select 
	plan,
    avg(monthly_revenue) * (1.0 / NULLIF(SUM(churned) * 1.0 / COUNT(*),0)) as clv
from subscriptions
group by plan
),
cac_table as (
select
avg(customer_acquisition_cost) as avg_cac
from monthly_revenue
)
select
	c.plan,
	round(c.clv,2) as clv,
	round(a.avg_cac,2) as cac,
	round(c.clv / a.avg_cac,2) as clv_cac_ratio
from clv_table c
cross join cac_table a
order by clv_cac_ratio desc;

-- 4. At-Risk Indicators

-- The relationship between feature usage, NPS, and churn

select
	churned,
    round(avg(feature_usage_pct),2) as avg_feature_usage,
    round(avg(nps_score),2) as avg_nps,
    count(*) as customers
from subscriptions
group by churned;

-- Risk Threshold: Check churn by usage bands

select
	case
		when feature_usage_pct < 25 then '0-24%'
		when feature_usage_pct < 50 then '25-49%'
		when feature_usage_pct < 75 then '50-74%'
	else '75%+'
end as usage_band,
count(*) as customers,
sum(churned) as churned_customers,
round(sum(churned)*100.0/count(*),2) as churn_rate_pct
from subscriptions
group by usage_band
order by usage_band;

-- Flag Current At-Risk Customers

select count (*) as at_risk_customers
from subscriptions
where churned = 0
and feature_usage_pct < 50
and nps_score <= 6;

-- See Who They Are

select
  customer_id, plan, industry, feature_usage_pct, nps_score, support_tickets_12mo
from subscriptions
where churned = 0
  and feature_usage_pct < 50
  and nps_score <= 6
order by feature_usage_pct asc, nps_score asc;
