-- хранение категорий и начисляемых по ним процентов
CREATE TABLE IF NOT EXISTS cashback_categories (
    id int8 NOT NULL GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name varchar(150) NOT NULL,
    ratio numeric(5,2) NOT NULL,

    CONSTRAINT cashback_categories_ratio_bound CHECK ((ratio >= (0)::numeric AND ratio <= (100)::numeric))
);

-- привязка MCC-кода к категориям кешбэка
CREATE TABLE IF NOT EXISTS cashback_categories_mcc (
    mcc_id int8 NOT NULL,
    category_id int8 NOT NULL,
    updated_at timestamp(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (mcc_id, category_id),
    CONSTRAINT cashback_categories_mcc_fk_cardmcc FOREIGN KEY (mcc_id) REFERENCES CardMCC(id),
    CONSTRAINT cashback_categories_mcc_fk_cashback_categories FOREIGN KEY (category_id) REFERENCES cashback_categories(id)
);