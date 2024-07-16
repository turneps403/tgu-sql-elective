CREATE OR REPLACE FUNCTION get_cashback_detailed(date_start date, date_end date, client varchar(25)) RETURNS 
    TABLE(
        tran_datetime timestamp, 
        client_code varchar(25), 
        card_number varchar(12), 
        amount numeric, 
        cashback_amount numeric, 
        cashback_runing_total numeric, 
        increase_rate varchar(10), 
        is_plan varchar(4)
    )
LANGUAGE sql AS $$
    WITH res AS (
        SELECT 
            crdop.TranDateTime as tran_datetime,
            inst.Code as client_code,
            crd.Number as card_number,
            crdop.Amount as amount,
            trns.amount as cashback_amount,
            SUM(trns.amount) OVER (ORDER BY crdop.TranDateTime) as casbhack_runing_total,
            CASE WHEN trns.is_plan = true THEN 'План' ELSE 'Факт' END AS is_plan
        FROM CardOperations crdop
            JOIN Cards crd ON crd.id = crdop.CardID
            JOIN Institutions inst ON inst.id = crd.InstOwnerID
            JOIN cashback_categories_mcc ccm on ccm.mcc_id = crdop.CardMccID
            JOIN cashback_categories cc on cc.id = ccm.category_id
            JOIN Transactions trns ON trns.operation_id = crdop.id
            JOIN TransactionPortfolios tprtf ON tprtf.id = trns.transaction_portfolio_id AND LOWER(tprtf.name) = 'вознаграждение за операции'
        WHERE 
            crdop.TranDateTime BETWEEN $1 AND $2 + interval '23 hours 59 minutes 59 seconds' 
            AND inst.Code = $3
      )
    SELECT 
        tran_datetime,
        client_code,
        LEFT(card_number, 4) || '****' || RIGHT(card_number, 4) AS card_number,
        amount,
        cashback_amount,
        casbhack_runing_total,
       '+' || ROUND(cashback_amount / LAG(casbhack_runing_total) OVER() * 100,2) || '%' AS increase_rate,
        is_plan
    FROM res
    ORDER BY tran_datetime ASC;
$$;