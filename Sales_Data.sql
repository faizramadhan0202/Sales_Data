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
