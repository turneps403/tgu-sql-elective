CREATE OR REPLACE FUNCTION get_cashback_agg(IN ClientCode varchar, IN DateStart date, IN DateEnd date) RETURNS 
    TABLE(
        date_period varchar, 
        client_code varchar,
        oper_amount numeric, 
        cashback_name varchar, 
        cashback_amount numeric
    )
LANGUAGE sql AS $$
    -- основные вычисления для аггрегированного отчета
    WITH opers AS (
        SELECT 
            TO_CHAR($2, 'DD Month YYYY') || ' - ' || TO_CHAR($3, 'DD Month YYYY') AS date_period,
            inst.Code AS client_code,
            co.Amount AS oper_amount,
            COALESCE(cc.name, 'Без категории') AS cashback_name,
            COALESCE(t.amount, 0) AS cashback_amount
        FROM 
            CardOperations co
            JOIN Cards crd ON crd.id = co.CardID
            JOIN Institutions inst ON inst.id = crd.InstOwnerID
            JOIN Currencies ccy ON ccy.id = co.CurrencyID
            LEFT JOIN cashback_categories_mcc ccm on ccm.mcc_id = co.CardMccID
            LEFT JOIN cashback_categories cc on cc.id = ccm.category_id
            LEFT JOIN Transactions t ON t.operation_id = co.id
            LEFT JOIN TransactionPortfolios tp ON tp.id = t.transaction_portfolio_id AND LOWER(tp.name) = 'вознаграждение за операции'
        WHERE 
            co.TranDateTime BETWEEN $2 AND $3
            AND (inst.Code = $1 OR $1 IS NULL)
   	        AND ccy.strcode = 'RUB'
    )
    -- упорядочиваем и группируем результат
    SELECT 
        date_period, 
        client_code, 
        SUM(oper_amount) AS oper_amount,
       	cashback_name, 
        SUM(cashback_amount)
    FROM
        opers o
    GROUP BY date_period, client_code, cashback_name
    ORDER BY client_code, date_period;
$$;