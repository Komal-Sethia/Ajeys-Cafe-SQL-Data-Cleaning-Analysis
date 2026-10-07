create database ajays_cafe;
use ajays_cafe;

create table cafe(
 order_id varchar(50),
 outlet_name varchar(100),
 city varchar(50),
 order_datetime varchar(50),
 item_name varchar(100),
 quantity varchar(50),
 price varchar(50),
 payment_mode varchar(50),
 customer_name varchar(100),
 rating varchar(50),
 franchise_owner varchar(100)
 );
 
/*Dataset was loaded locally using MySQL LOAD DATA INFILE.
Update the file path below according to your local MySQL setup.

set global local_infile = 1;

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ajeys_cafe_franchise_unclean_dataset.csv"
INTO TABLE cafe
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
*/
select count(*) as total_rows from cafe;


select * from cafe;

set sql_safe_updates = 0;

/*capitalize the first letter of each word in the outlet name */
update cafe
set outlet_name = 
case 
	when lower(trim(outlet_name)) like "%surat%" then "Ajey's Cafe - Surat"
    
    when lower(trim(outlet_name)) like "%bengaluru%" or
    lower(trim(outlet_name)) like "%bangalore%" or
    lower(trim(outlet_name)) like "%banglore%" then "Ajey's Cafe - Bengaluru"
    
    when lower(trim(outlet_name)) like "%ahmedabad%" or 
    lower(trim(outlet_name)) like "%ahmadabad%" then "Ajey's Cafe - Ahmedabad"
    
    when lower(trim(outlet_name)) like "%rajkot%" then "Ajey's Cafe - Rajkot"
    
    when lower(trim(outlet_name)) like "%baroda%" or
    lower(trim(outlet_name)) like "%Vadodara%" then "Ajey's Cafe - Vadodara"
    
    when lower(trim(outlet_name)) like "%mumbai%" then "Ajey's Cafe - Mumbai"
    
    when lower(trim(outlet_name)) like "%pune%" then "Ajey's Cafe - Pune"
    
    when lower(trim(outlet_name)) like "%delhi%" or 
    lower(trim(outlet_name)) like "%new delhi%" then "Ajey's Cafe - Delhi"
    
    else null
end;

#Correct the city name 
update cafe
set city = replace(outlet_name, "Ajey's Cafe - ", "");

/*Remove extra space from payment_mode column  */
update cafe
set payment_mode = 
case
	when lower(trim(payment_mode)) = "upi" then "UPI"
    when lower(trim(payment_mode)) = "card" then "Card"
    when lower(trim(payment_mode)) = "cash" then "Cash"
	when lower(trim(payment_mode)) = "netBanking" then "NetBanking"
    when lower(trim(payment_mode)) = "credit card" then "Credit Card"
    when lower(trim(payment_mode)) = "debit card" then "Debit Card"
    else null
end ;

#Handle out the null or blank in payment_mode
update cafe 
set payment_mode = "Not Known"
where payment_mode is null
or trim(payment_mode) = "";

select * from cafe;

/*customer_name clean karo — extra spaces, case inconsistency, blank strings ko proper NaN banao*/

UPDATE cafe
SET customer_name =
    REGEXP_REPLACE(TRIM(customer_name), '[[:space:]]+', ' ')
WHERE customer_name IS NOT NULL;

update cafe
set customer_name = 
concat(
	upper(left(substring_index(lower(trim(customer_name))," ",1),1)),
	substring(substring_index(lower(trim(customer_name))," ",1),2),
	" ",
	upper(left(substring_index(lower(trim(customer_name)), " ", -1),1)),
	substring(substring_index(lower(trim(customer_name))," ", -1),2)
)
where customer_name is not null;

#replace blank and null 
update cafe 
set customer_name = "Not Known"
where customer_name is null
or trim(customer_name) = "";


# capitalize first letter of each word 
update cafe 
set item_name = 
case 
# if only 1 word is present
	when item_name not like "% %" then 
    concat(
	upper(left(substring_index(lower(trim(item_name)), " ", 1),1)),
    substring(substring_index(lower(trim(item_name)), " ", 1),2)
    )
    # if 2 words are present
    else 
	concat(
		upper(left(substring_index(lower(trim(item_name)), " ", 1),1)),
		substring(substring_index(lower(trim(item_name)), " ", 1),2),
		" ",
		upper(left(substring_index(lower(trim(item_name)), " ", -1),1)),
		substring(substring_index(lower(trim(item_name)), " ", -1),2)
    )
end
where item_name is not null;

#franchise_owner ke spelling variants ko ek naam me merge karo

update cafe
set franchise_owner = 
case
	when trim(franchise_owner) = "" then "Not known"
    else "Ajey Shah"
end;
select * from cafe;

# replace blank to null 
update cafe
set quantity = null
where trim(quantity) = "";

/*rating column me out-of-range values (0, 6) ko invalid mark karo*/

alter table cafe
add column rating_status varchar(20) after rating;
select * from cafe;

# replace blank to null
update cafe
set rating = null
where trim(rating) = "";

# Handle null or 0 in rating , sepreate Valid or invalid , missing values
update cafe 
set rating_status = 
case
	when trim(rating) is null then "Missing"
	when trim(rating) = 0 then "Invalid"
    when trim(rating) = 6 then "Invalid"
    else "Valid"
end;

#replace blank to null
update cafe
set price = null
where trim(price) = "";


/*order_datetime ke teeno formats ko ek standard datetime format me convert karo, missing dates ka kya 
karna hai decide karo*/

#remove time 
update cafe
set order_datetime = 
substring_index(trim(order_datetime), " " , 1);

update cafe
set order_datetime = 
case
	when order_datetime like "____-__-__"
    then str_to_date(order_datetime, "%Y-%m-%d")
    
    when order_datetime like "__/__/____"
    then str_to_date(order_datetime, "%d/%m/%Y")
    
    when order_datetime like "__-___-____"
    then str_to_date(order_datetime, "%d-%b-%Y")
    
    else null
end;

# change the data type

alter table cafe
modify column order_id varchar(20),
modify column outlet_name varchar(50),
modify column city varchar(30),
modify column order_datetime DATE,
modify column item_name varchar(30),
modify column quantity decimal(10,2),
modify column price decimal(10,2),
modify column payment_mode varchar(50),
modify column customer_name varchar(50),
modify column rating decimal(10,2),
modify column franchise_owner varchar(50);

select * from cafe;


# give row numbers

alter table cafe
add column row_id int auto_increment primary key;

select *, 
row_number() over(partition by order_id, outlet_name,city,order_datetime,item_name,quantity,price,payment_mode,
customer_name,rating,franchise_owner order by row_id) as rn from cafe;

# show duplicate rows
select * from 
(
	select * ,
    row_number() over(partition by order_id, outlet_name,city,order_datetime,item_name,quantity,price,payment_mode,
	customer_name,rating,franchise_owner order by row_id) as rn from cafe
)t 
where rn > 1;

set sql_safe_updates = 0;

# delete duplicate rows

delete b from cafe b
join
(
select *,
row_number() over(partition by order_id, outlet_name,city,order_datetime,item_name,quantity,price,
payment_mode,customer_name,rating,franchise_owner order by row_id) as rn from cafe
) d
on b.row_id = d.row_id
where d.rn > 1;

select count(*) from cafe;
select * from cafe;

/*quantity aur price me invalid values (negative, zero, null) handle karo — decide karo drop karna hai ya 
impute*/

alter table cafe
add column quantity_status varchar(20) after quantity,
add column price_status varchar(20) after price;

update cafe
set quantity_status = 
case 
	when quantity is null then "Missing"
    when quantity <= 0 then "Invalid"
    else "Valid"
end;

update cafe
set price_status = 
case 
	when price is null then "Missing"
    when price <= 0 then "Invalid"
    else "Valid"
end;

select * from cafe;

#Har outlet (city-wise) ka total revenue nikaalo
select city , sum(quantity * price) as total_revenue from cafe
group by city;

#Sabse zyada bikne wala item kaun sa hai (overall aur outlet-wise)

#overall
select item_name, sum(quantity) as total_quantity_sold from cafe
where quantity_status = "Valid"
group by item_name
order by total_quantity_sold desc
limit 1;

#outlet-wise
select outlet_name,item_name, sum(quantity) as total_quantity_sold from cafe
where quantity_status = "Valid"
group by outlet_name,item_name
order by total_quantity_sold desc;

SELECT 
	outlet_name,
    item_name,
    total_quantity_sold ,
    item_rank
from (
	select  
    outlet_name,
    item_name,
    total_quantity_sold,
    rank() over(partition by outlet_name order by total_quantity_sold desc) as item_rank
    from (
    select 
    outlet_name,
    item_name,
    sum(quantity) as total_quantity_sold from cafe
    where quantity_status = "Valid"
    group by outlet_name, item_name)
    as item_sales)
    as ranked_items
    where item_rank = 1
    order by outlet_name;
    
#Month-wise / year-wise sales trend dikhao

select * from cafe;

select 
year(order_datetime) as Year,
month(order_datetime) as Month,
sum(quantity * price) as total_sales
from cafe
where quantity_status = "Valid"
and price_status = "Valid"
and order_datetime is not null
group by year(order_datetime),
month(order_datetime) 
order by Year,Month;

#Payment mode ka distribution (UPI vs Cash vs Card) nikaalo

select payment_mode,
count(*) as total_transaction
from cafe
where payment_mode in ("UPI" , "Cash" , "Card")
group by payment_mode
order by total_transaction desc;

#Average order value (AOV) per outlet calculate karo

select outlet_name,
avg(order_value) as AOV
from (
	select outlet_name,
    order_id,
    sum(quantity * price) as order_value
    from cafe
    where quantity_status = "Valid"
    and price_status = "Valid"
    group by outlet_name,order_id
    ) as orders
    group by outlet_name
    order by AOV desc;
    
#Rating aur sales ke beech koi correlation hai kya, check karo

select rating, 
count(*) as total_order,
round(avg(quantity * price),2) as average_order_value,
round(sum(quantity * price),2) as revenue
from cafe
where rating is not null 
and quantity_status = "Valid"
and price_status = "Valid"
group by rating
order by rating desc;
    
#Kaunsa outlet sabse zyada profitable/growing hai (year-over-year)?
select * from cafe;

select outlet_name,
	year(order_datetime) as Year,
	sum(quantity * price) as revenue,
    
	lag(sum(quantity * price)) over(partition by outlet_name order by year(order_datetime)) 
    as Previous_year_revenue,

	round((
		sum(quantity * price) -
        lag(sum(quantity * price)) over(partition by outlet_name order by year(order_datetime)))
        /
        lag(sum(quantity * price)) over(partition by outlet_name order by year(order_datetime))
        * 100, 2)
        as YOY_Growth

from cafe
where order_datetime is not null
 and quantity_status = "Valid"
    and price_status = "Valid"
group by outlet_name, year(order_datetime)
order by outlet_name,Year;
    	
#Weekday vs weekend sales pattern kaisa hai?

select 
	case
		when dayofweek(order_datetime) in (1,7) then "Weekend"
        else "Weekday"
	end as Day_type,
    count(*) as total_orders,
    round(sum(quantity * price),2) as total_sales,
    round(avg(quantity * price),2) as Average_order_value
from cafe
where order_datetime is not null
	and quantity_status = "Valid"
    and price_status = "Valid"
group by case
		when dayofweek(order_datetime) in (1,7) then "Weekend"
        else "Weekday"
	end
order by total_sales desc;

#Kaunse items low-rated hain but high-selling — improvement chahiye?

select 
	item_name, 
    round(avg(rating),2) as average_rating,
	round(sum(quantity* price),2) as total_sales
from cafe
where 
	rating is not null 
	and quantity_status = "Valid"
	and price_status = "Valid"
group by item_name
having	average_rating < 3.5
	and sum(quantity* price) > 500000
order by total_sales desc;

#Customer repeat-purchase pattern nikaalo (agar naam clean ho jaye)

select * from cafe;

select 
	customer_name,
    count(distinct order_id) as total_order
from cafe
where 
	customer_name <> "Not Known"
group by customer_name
having count(distinct order_id) > 1
order by total_order desc;

#Window functions use karo — har outlet ka rank by revenue (RANK() OVER (PARTITION BY ... ORDER BY ...))

select 
	outlet_name,
    year(order_datetime) as year,
    sum(quantity * price) as revenue,
    rank() over(partition by year(order_datetime) order by  sum(quantity * price) desc) as revenue_rank
from cafe
where order_datetime is not null
	and quantity_status = "Valid"
    and price_status = "Valid"
group by outlet_name, year(order_datetime)
order by year, revenue_rank;

#Month-over-month growth % nikaalo (LAG() window function)

select 
	outlet_name,
	month(order_datetime) as month,
    sum(quantity * price) as revenue,
    
    lag(sum(quantity * price)) over(partition by outlet_name order by month(order_datetime)) as previous_month_revenue,
    
    round(
		(sum(quantity * price) - 
        lag(sum(quantity * price)) over(partition by outlet_name order by month(order_datetime)))
        /
        lag(sum(quantity * price)) over(partition by outlet_name order by month(order_datetime)) 
        * 100,2) as MOM_growth
from cafe

where order_datetime is not null
	and quantity_status = "Valid"
    and price_status = "Valid"
group by outlet_name, month(order_datetime)
order by outlet_name,month;

#Subquery/CTE se "outlets jinka revenue average se kam hai" nikaalo

select outlet_name,
	revenue
from (
	select outlet_name,
		sum(quantity * price) as revenue
	from cafe
	where quantity_status = "Valid"
		and price_status = "Valid"
group by outlet_name) 
as outlet_sales
where revenue < (
	select 
		avg(revenue) as average_revenue
	from(
		select outlet_name,
			sum(quantity * price) as revenue
		from cafe
		where quantity_status = "Valid"
			and price_status = "Valid"
		group by outlet_name) 
        as outlet_avg
)
order by revenue;    

#Self-join ya EXISTS use karke repeat customers dhundo
select * from cafe;
select distinct
	c1.customer_name
from cafe c1
where c1.customer_name <> "Not Known"
	and exists(
		select 1
			from cafe c2
            where c2.customer_name = c1.customer_name
            and c2.order_id <> c1.order_id
            )
		order by c1.customer_name;
        
#20. Stored procedure banao jo kisi bhi outlet ka monthly report generate kare

delimiter //

create procedure monthly_outlet_report(
	in p_outlet_name varchar(100),
    in p_year int,
    in p_month int
)
begin

	select 
		outlet_name,
        p_year as year,
        p_month as month,
        count(distinct order_id) as total_orders,
        sum(quantity) as total_quantity,
        round(sum(quantity * price),2) as total_revenue,
        round(
			sum(quantity * price)/ count(distinct order_id) , 2) as Average_Order_Value
	from cafe
    where outlet_name = p_outlet_name
		and year(order_datetime) = p_year
        and month(order_datetime) = p_month
        and quantity_status = "Valid"
		and price_status = "Valid"
        group by outlet_name;
end //

delimiter ;
call monthly_outlet_report("Ajey's Cafe - Pune",2023,03);

        