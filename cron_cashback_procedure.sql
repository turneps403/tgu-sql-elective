CREATE OR REPLACE PROCEDURE process_cashback(in ARG_CALC_DATE date) LANGUAGE plpgsql AS $$
DECLARE
    tp_id  bigint;
    ccy_id bigint;
    ctr_id bigint;
BEGIN
    -- аналитический признак проводки
    tp_id := (SELECT id FROM TransactionPortfolios WHERE name = 'Вознаграждение за операции');

    -- получаем идетификатор рублёвой валюты
    ccy_id := (SELECT id FROM Currencies WHERE strcode = 'RUB');

    -- идентификатор типа контракта на стандартное обслуживание
    ctr_id := (SELECT id FROM ContractTypes WHERE ShortCode ='BANKING');

    --меняем тип проводки с плановой на фактическую
    UPDATE Transactions 
    SET is_plan = false
    FROM Contracts cts
        JOIN Accounts acc ON acc.InstownerID = cts.InstitutionID AND acc.CurrencyID = ccy_id AND acc.AccType = 1
        JOIN Transactions trs ON trs.receiverid = acc.id 
    WHERE 
        cts.DateEnd IS NULL
        AND cts.ContractTypeID = ctr_id
        AND DATE_PART('month', cts.DateStart) = DATE_PART('month', calcdate)
        AND DATE_PART('day', cts.DateStart) = DATE_PART('day', calc_date)
        AND trs.trandatetime BETWEEN (ARG_CALC_DATE - interval '1 month') AND (CURRENT_DATE - interval '1 sec')
        AND trs.is_plan = true
        AND trs.transaction_portfolio_id = tp_id;
END;
$$;