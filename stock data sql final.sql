SELECT * FROM stock_market.fact_dividends;

## Q.1 Market captilisation 
select
concat(sum(outstanding_shares * share_price ),"M") as Total_Mrt_Capilitasation
from stocks;

# Q .2  Average Daily Trading Volume 
SELECT 
round(avg(avg_vol),2) as _Average_Daily_Trading_Volume 
from one_new_daily_return;


## 	Q.3 volitality 
SELECT
    CONCAT(ROUND(STDDEV(daily_return_neww), 3), '%') AS Daily_Volatility
FROM
    one_new_daily_return;


## Q.4 Top sector performance 
select 
sector as sectors ,
sum(current_price) as Current_price 
from stocks
group by sector
order by  Current_price  desc
;

## Q. 5 Portfolio value 
select
sum(quantity*share_price) as portfilio_value 
from stocks;

## Q.6 Portfolio Return 
select 
company_name as compant_name ,
(sum(current_value)-sum(initial_value)/sum(initial_value))*100  as portfolio_Return
from stocks 
group by company_name;

## Q.7  Divident Yield 
SELECT 
    dc.company_name,
    YEAR(fo.`date`) AS year,
    SUM(fd.dividend_per_share) AS annual_dividend_per_share,
round((SUM(fd.dividend_per_share) / AVG(s.share_price)),2)* 100 AS dividend_yield
FROM fact_dividends AS fd
JOIN dim_company AS dc
    ON fd.company_id = dc.company_id
JOIN fact_orders AS fo
    ON dc.company_id = fo.company_id
JOIN stocks AS s
    ON dc.company_name = s.company_name
GROUP BY 
    dc.company_name,
    YEAR(fo.`date`);

## Q.8 Trade win rate 

SELECT
    COUNT(*) AS total_trades,
    SUM(CASE 
            WHEN side = 'SELL' AND (price * quantity - fees) > (SELECT AVG(price*quantity+fees) FROM fact_trades WHERE side='BUY') 
            THEN 1 
            ELSE 0 
        END) AS profitable_trades,
    (SUM(CASE 
            WHEN side = 'SELL' AND (price * quantity - fees) > (SELECT AVG(price*quantity+fees) FROM fact_trades WHERE side='BUY') 
            THEN 1 
            ELSE 0 
        END) * 100.0 / COUNT(*)) AS trade_win_rate
FROM fact_trades;

#   Q.9 TRADER PERFORMANCE 
SELECT 
dc.company_id,
sum(ft.quantity*ft.price)-sum(s.quantity*s.buy_price) as trader_poerformance 
from dim_company as dc
join fact_trades as ft
on dc.company_id=ft.company_id
join
stocks as s
on
dc.company_name=s.company_name
group by company_id;


# Q.10 sharpe ratio 
SELECT
    -- Portfolio return
    (SELECT AVG(return_pct) 
     FROM stocks) AS portfolio_return,

    -- Volatility from daily returns
    (SELECT STDDEV_POP(daily_return_neww) 
     FROM one_new_daily_return) AS volatility,

    (
        (SELECT AVG(return_pct) FROM stocks) - 0.0001
    ) /
    (SELECT STDDEV_POP(daily_return_neww) FROM one_new_daily_return)
    AS sharpe_ratio;
    
    # Excute rate 
    SELECT
    (COUNT(CASE WHEN status = 'filled' THEN 1 END) /
     COUNT(*)) * 100 AS order_execution_rate
FROM fact_orders;












