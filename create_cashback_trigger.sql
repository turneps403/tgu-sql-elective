CREATE OR REPLACE FUNCTION create_cashback_tran_plan() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
	tp_id bigint;
	ccy_id bigint;
    sender_id bigint;
	reciever_id bigint;
    cb_amount numeric(15,2);
BEGIN
    -- аналитический признак проводки
    tp_id := (SELECT id FROM TransactionPortfolios WHERE name = 'Вознаграждение за операции');
    
    -- получаем идетификатор рублёвой валюты
    ccy_id := (SELECT id FROM Currencies WHERE strcode ='RUB');

    -- рублёвый счет нашего банка-отправителя кешбека
    sender_id := (
        SELECT MAX(a2.id)
        FROM Institutions ins JOIN Accounts acc ON acc.InstownerID = ins.id
        WHERE ins.Code ='**OURBANK**' AND a2.AccType = 0 AND a2.CurrencyID = ccy_id
    );
    
    -- счет получателя кешбека
    reciever_id := (
        SELECT MAX(a.id)
        FROM Cards car JOIN Accounts acc ON acc.InstownerID = car.InstOwnerID
        WHERE car.id = NEW.CardID AND acc.AccType = 1 AND acc.CurrencyID = ccy_id
    );

    -- сумма кэшбека по проводке
    cb_amount := (
        SELECT cc.ratio * NEW.Amount / 100
        FROM cashback_categories_mcc ccm JOIN cashback_categories cc ON cc.id = ccm.category_id
        WHERE ccm.mcc_id = NEW.CardMccID
    );

    -- проверяем условия для планового начисления кешбека
    IF (reciever_id > 0 AND sender_id > 0 AND ccy_id > 0 AND tp_id > 0 AND cb_amount > 0) THEN
        INSERT INTO Transactions(receiverid, senderid, currencyid, amount, trandatetime, is_plan, transaction_portfolio_id)
        VALUES (reciever_id, sender_id, ccy_id, cb_amount, NOW(), true, tp_id);
    END IF;

    -- обязательный возврат new
    RETURN NEW;
END
$$;

-- создаем триггер, который после каждой новой записи в таблицу проводок
-- будет проверять условия и формировать плановую проводку по кешбеку
CREATE TRIGGER cashback_trigger AFTER INSERT ON CardOperations
FOR EACH ROW EXECUTE FUNCTION create_cashback_tran_plan();
