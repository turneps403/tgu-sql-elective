-- populate cashback_categories
INSERT INTO cashback_categories(name, ratio)
VALUES 
    ('Авиабилеты', 10.5), 
    ('Аптеки', 4.5), 
    ('Продукты', 3)
;

-- populate cashback_categories_mcc: авиакомпании
INSERT INTO cashback_categories_mcc(mcc_id, category_id)
    (
        SELECT cm.id, cc.id
        FROM CardMCC cm JOIN cashback_categories cc ON cc.name = 'Авиабилеты'
        WHERE 
            lower(cm.Name) LIKE '%авиакомпании%'
            OR lower(cm.Comment) LIKE '%авиакомпании%'
    )
;

-- populate cashback_categories_mcc: аптеки
INSERT INTO cashback_categories_mcc(mcc_id, category_id)
    (
        SELECT cm.id, cc.id
        FROM CardMCC cm JOIN cashback_categories cc ON cc.name = 'Аптеки'
        WHERE 
            lower(cm.Name) LIKE '%аптеки%'
            OR lower(cm.Comment) LIKE '%опт%'
    )
;

-- populate cashback_categories_mcc: продукты
INSERT INTO cashback_categories_mcc(mcc_id, category_id)
    (
        SELECT cm.id, cc.id
        FROM CardMCC cm JOIN cashback_categories cc ON cc.name = 'Продукты'
        WHERE 
            cm.Code = '5411'
    )
;