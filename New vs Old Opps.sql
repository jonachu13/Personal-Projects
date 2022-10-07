/* The goal of this is to see if I can see which opportunities are new and which are old.
   New opportunities are ones that have come in organically, or via marketing as an MQL within 30 days of creation of an opportunity.
   Old is anything older.
 */


-- FIRST THINGS FIRST, I need to confirm with a join on id's that the created date are different for lead created date and opportunity created date
SELECT *
from bi_measured_leads
where converted_opportunity_id = '0060B00000abyuEQAQ'

select *
from bi_measured_opportunities
where opportunity_id = '0060B00000abyuEQAQ'
-- looks like convereted_opportunity_id = opportunity_id

--look for the date
SELECT bi_measured_leads.created_date         as lead_created_date,
       bi_measured_opportunities.created_date as ops_created_date,
       account_created_date
from bi_measured_leads
         JOIN bi_measured_opportunities on opportunity_id = converted_opportunity_id
limit 10;
-- okay the dates are different. lead date always earlier.

-- What do I want to pull? --
/*
 - pulls opportunity age trends
 - basic info about the opp data: opportunity_name,
 - less than 30 days lead, greater than 30 days lead
 - specific days
 - this will be aggregate, so the date will be based on the opportunity date.
 */

-- mkt statistics: org_paid, have_they_gone_live_with_drchrono, demo_completed, stage_name


-- HERE'S THE DOMO CONNECTOR --
WITH new_old_opps_trend as (SELECT bi_measured_opportunities.org_paid,
                                   bi_measured_opportunities.have_they_gone_live_with_drchrono,
                                   bi_measured_opportunities.demo_completed,
                                   bi_measured_opportunities.stage_name,
                                   bi_measured_opportunities.close_date,
                                   bi_measured_opportunities.opportunity_id,
                                   bi_measured_opportunities.opportunity_name,
                                   bi_measured_leads.created_date                     as lead_created_date,
                                   bi_measured_opportunities.created_date             as opp_created_date,
                                   datediff(day, lead_created_date, opp_created_date) as lead_to_opp_days,
                                   datediff(day, lead_created_date, close_date) as lead_to_close_days,
                                   datediff(day, opp_created_date, close_date) as opp_to_close_days
                            FROM bi_measured_opportunities
                                     JOIN bi_measured_leads on opportunity_id = converted_opportunity_id)
SELECT lead_created_date,
       opp_created_date,
       lead_to_opp_days,
       (CASE
            WHEN lead_to_opp_days <= 30 THEN 'new'
            ELSE 'old' END)
           as le2op_30day_new_old,
       lead_to_close_days,
       opp_to_close_days,
       opportunity_id,
       opportunity_name,
       org_paid,
       demo_completed,
       close_date,
       stage_name,
       have_they_gone_live_with_drchrono
FROM new_old_opps_trend

limit 100;




/* how long does it take for a lead to get to closed won vs closed lost
   close_date

 */