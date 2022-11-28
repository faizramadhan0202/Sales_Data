--Check Values
select *
from PortpolioProject02..sales_data_sample

--check unique values
select distinct STATUS from PortpolioProject02..sales_data_sample --Nice Plot
select distinct YEAR_ID from PortpolioProject02..sales_data_sample 
select distinct PRODUCTLINE from PortpolioProject02..sales_data_sample --Nice Plot 
select distinct COUNTRY from PortpolioProject02..sales_data_sample --Nice Plot
select distinct TERRITORY from PortpolioProject02..sales_data_sample --Nice Plot
select distinct DEALSIZE from PortpolioProject02..sales_data_sample --Nice Plot

--Analyst

----Let's start by grouping sales by productline
select PRODUCTLINE, sum(SALES) Revenue
from PortpolioProject02..sales_data_sample
group by PRODUCTLINE
order by 2 desc


select YEAR_ID, sum(SALES) Revenue
from PortpolioProject02..sales_data_sample
group by YEAR_ID
order by 2 desc


select DEALSIZE, sum(SALES) Revenue
from PortpolioProject02..sales_data_sample
group by DEALSIZE
order by 2 desc

----What was the best month for sales in a specific year? How much was earned that month? 

select MONTH_ID, sum(SALES) Revenue, count(ORDERNUMBER) Frequency
from PortpolioProject02..sales_data_sample
where YEAR_ID = 2004
group by MONTH_ID
order by 1

select MONTH_ID, PRODUCTLINE, sum(sales) Revenue, count(ORDERNUMBER)
from PortpolioProject02..sales_data_sample
where YEAR_ID = 2004 AND MONTH_ID = 11
group by MONTH_ID, PRODUCTLINE
order by 3

--Who is our best customer (this could be best answered with RFM)
IF EXISTS(select * from PortpolioProject02..sales_data_sample) 
BEGIN
   DROP TABLE #rfm;
END;

--CTE
;with rfm as 
(
	select 
		CUSTOMERNAME, 
		sum(sales) MonetaryValue,
		avg(sales) AvgMonetaryValue,
		count(ORDERNUMBER) Frequency,
		max(ORDERDATE) last_order_date,
		(select max(ORDERDATE) from PortpolioProject02..sales_data_sample) max_order_date,
		DATEDIFF(DD, max(ORDERDATE), (select max(ORDERDATE) from PortpolioProject02..sales_data_sample)) Recency
	from PortpolioProject02..sales_data_sample
	group by CUSTOMERNAME
),
rfm_calc as
(
	select r.*,
		NTILE(4) OVER (order by Recency desc) rfm_recency,
		NTILE(4) OVER (order by Frequency) rfm_frequency,
		NTILE(4) OVER (order by MonetaryValue) rfm_monetary
	from rfm r
	--order by 4 desc
)
select 
	c.*, rfm_recency + rfm_frequency + rfm_monetary as rfm_cell,
	cast(rfm_recency as varchar) + cast(rfm_frequency as varchar) + cast(rfm_monetary as varchar) as rfm_cell_string
into #rfm
from rfm_calc c

--CASE WHEN
select CUSTOMERNAME, rfm_recency, rfm_frequency, rfm_monetary,
	case 
		when rfm_cell_string in (111, 112 , 121, 122, 123, 132, 211, 212, 114, 141) then 'lost_customers'  --lost customers
		when rfm_cell_string in (133, 134, 143, 244, 334, 343, 344, 144) then 'slipping away, cannot lose' -- (Big spenders who haven’t purchased lately) slipping away
		when rfm_cell_string in (311, 411, 331) then 'new customers'
		when rfm_cell_string in (222, 223, 233, 322) then 'potential churners'
		when rfm_cell_string in (323, 333,321, 422, 332, 432) then 'active' --(Customers who buy often & recently, but at low price points)
		when rfm_cell_string in (433, 434, 443, 444) then 'loyal'
	end rfm_segment

from #rfm

--What products are most often sold together? 
--select *
--from PortPolioProject02..sales_data_sample
--where ORDERNUMBER = 10411

select distinct ORDERNUMBER, Stuff(
	(select ',' + PRODUCTCODE
	from PortpolioProject02..sales_data_sample p
	where ORDERNUMBER IN
		(
			select ORDERNUMBER
			from (
					select ORDERNUMBER, count(*) rn
					from PortpolioProject02..sales_data_sample
					where status = 'Shipped'
					group by ORDERNUMBER
				)rn
			where rn = 2
		)
		and p.ORDERNUMBER = s.ORDERNUMBER
		for xml path (''))

		, 1, 1, '') ProductCodes

	from PortpolioProject02..sales_data_sample s
	order by 2 desc
