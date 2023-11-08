DECLARE
        
    -- Функция для проверки существования объекта
    FUNCTION this_object_exists (table_name user_objects.object_name%type) 
    RETURN BOOLEAN IS
    BEGIN
       FOR r IN 
        (SELECT 1 FROM user_objects WHERE object_name = UPPER(table_name))
       LOOP
            RETURN TRUE;
       END LOOP;
       RETURN FALSE;
    END this_object_exists;
    
    -- Создание таблиц
    
    PROCEDURE create_table_holidays IS
    BEGIN
        IF NOT this_object_exists('holidays') THEN
            EXECUTE IMMEDIATE 
            'CREATE TABLE holidays
                ( h_date DATE NOT NULL,
                  h_type VARCHAR2(50) NOT NULL,
                  CONSTRAINT holidays_uk UNIQUE (h_date)
                )';
        END IF;
    END create_table_holidays;
    
    PROCEDURE create_table_shedules IS
    BEGIN
        IF NOT this_object_exists('shedules') THEN
            EXECUTE IMMEDIATE 
            'CREATE TABLE shedules
                ( id NUMBER NOT NULL,
                  name VARCHAR2(50) NOT NULL,
                  from_hours NUMBER NOT NULL,
                  to_hours NUMBER NOT NULL,
                  lunch_at NUMBER NOT NULL,
                  CONSTRAINT shedules_pk PRIMARY KEY (id)
                )';
        END IF;
    END create_table_shedules;
    
    PROCEDURE create_table_persons IS
    BEGIN
        IF NOT this_object_exists('persons') THEN
            EXECUTE IMMEDIATE 
            'CREATE TABLE persons
                ( id NUMBER NOT NULL,
                  name VARCHAR2(50) NOT NULL,
                  timezone NUMBER NOT NULL,
                  shedule_id NUMBER NOT NULL,
                  CONSTRAINT persons_pk PRIMARY KEY (id),
                  CONSTRAINT fk_shedules
                    FOREIGN KEY (shedule_id)
                    REFERENCES shedules(id)
                )';
        END IF;
    END create_table_persons;
    
    PROCEDURE create_table_stages IS
    BEGIN
        IF NOT this_object_exists('stages') THEN
            EXECUTE IMMEDIATE 
            'CREATE TABLE stages
                ( id NUMBER NOT NULL,
                  num NUMBER NOT NULL,
                  name VARCHAR2(100) NOT NULL,
                  CONSTRAINT stages_pk PRIMARY KEY (id)
                )';
        END IF;
    END create_table_stages;
    
    PROCEDURE create_table_tasks IS
    BEGIN
        IF NOT this_object_exists('tasks') THEN
            EXECUTE IMMEDIATE 
            'CREATE TABLE tasks
                ( id NUMBER NOT NULL,
                  name VARCHAR2(100) NOT NULL,
                  is_closed VARCHAR2(1) DEFAULT ''N'' NOT NULL,
                  CONSTRAINT tasks_pk PRIMARY KEY (id)
                )';
        END IF;
    END create_table_tasks;
    
    PROCEDURE create_table_action_types IS
    BEGIN
        IF NOT this_object_exists('action_types') THEN
            EXECUTE IMMEDIATE 
            'CREATE TABLE action_types
                ( id NUMBER NOT NULL,
                  type VARCHAR2(50) NOT NULL,
                  CONSTRAINT action_types_pk PRIMARY KEY (id)
                )';
        END IF;
    END create_table_action_types;
    
    PROCEDURE create_table_task_actions IS
    BEGIN
        IF NOT this_object_exists('task_actions') THEN
            EXECUTE IMMEDIATE 
            'CREATE TABLE task_actions
                ( id NUMBER NOT NULL,
                  form_id NUMBER NOT NULL,
                  task_id NUMBER NOT NULL,
                  stage_id NUMBER NOT NULL,
                  person_id NUMBER NOT NULL,
                  action_type_id NUMBER,
                  start_date TIMESTAMP NOT NULL,
                  end_date TIMESTAMP,
                  CONSTRAINT task_actions_pk PRIMARY KEY (id),
                  CONSTRAINT fk_tasks
                    FOREIGN KEY (task_id)
                    REFERENCES tasks(id),
                  CONSTRAINT fk_stages
                    FOREIGN KEY (stage_id)
                    REFERENCES stages(id),
                  CONSTRAINT fk_persons
                    FOREIGN KEY (person_id)
                    REFERENCES persons(id),
                  CONSTRAINT fk_action_types
                    FOREIGN KEY (action_type_id)
                    REFERENCES action_types(id)
                )';
        END IF;
    END create_table_task_actions;
    
    -- Заполнение таблиц
    
    /* Для примера календарь выходных дней заполнен субботами и 
    воскресеньями, а также несколькими праздничными днями */ 
    PROCEDURE fill_holidays (seq_first_date IN DATE, seq_last_date IN DATE) IS
        handle_date DATE;
    BEGIN
        handle_date := seq_first_date;      
        WHILE handle_date <= seq_last_date LOOP
            IF TO_CHAR (
                        handle_date, 
                        'fmday',
                        'nls_date_language = English'
                        ) IN ('saturday', 'sunday') THEN  
                EXECUTE IMMEDIATE
                'INSERT INTO holidays VALUES (:handle_date, ''weekend'')' 
                USING handle_date;
            END IF;
            handle_date := handle_date + 1;
        END LOOP;
        EXECUTE IMMEDIATE
            'INSERT ALL
                INTO holidays (h_date, h_type) 
                VALUES (DATE''2022-05-02'', ''labor day'')
                INTO holidays (h_date, h_type) 
                VALUES (DATE''2022-05-03'', ''labor day'')
                INTO holidays (h_date, h_type) 
                VALUES (DATE''2022-05-09'', ''victory day'')
                INTO holidays (h_date, h_type) 
                VALUES (DATE''2022-05-10'', ''victory day'')
            SELECT 1 FROM DUAL';
    EXCEPTION 
        WHEN OTHERS THEN NULL;
    END fill_holidays;
    
    PROCEDURE fill_shedules IS
    BEGIN
        EXECUTE IMMEDIATE
            'INSERT ALL
                INTO shedules (id, name, from_hours, to_hours, lunch_at) 
                VALUES (1, ''standart_one'', 8, 17, 12)
                INTO shedules (id, name, from_hours, to_hours, lunch_at) 
                VALUES (2, ''standart_two'', 9, 18, 13)
                INTO shedules (id, name, from_hours, to_hours, lunch_at) 
                VALUES (3, ''standart_three'', 10, 19, 14)
                INTO shedules (id, name, from_hours, to_hours, lunch_at) 
                VALUES (4, ''standart_four'', 13, 22, 17)
            SELECT 1 FROM DUAL';
    EXCEPTION 
        WHEN OTHERS THEN NULL;
    END fill_shedules;

    PROCEDURE fill_persons IS
    BEGIN
        EXECUTE IMMEDIATE
            'INSERT ALL
                INTO persons (id, name, timezone, shedule_id) 
                VALUES (1, ''Иванов Иван'', 3, 2)
                INTO persons (id, name, timezone, shedule_id) 
                VALUES (2, ''Калужин Антон'', 3, 2)
                INTO persons (id, name, timezone, shedule_id) 
                VALUES (3, ''Петров Андрей'', 7, 1)
                INTO persons (id, name, timezone, shedule_id) 
                VALUES (4, ''Сиберт Наталья'', 0, 3)
                INTO persons (id, name, timezone, shedule_id) 
                VALUES (5, ''Иванова Тамара'', -5, 1)
                INTO persons (id, name, timezone, shedule_id) 
                VALUES (6, ''Сидоров Роман'', 12, 4)
                INTO persons (id, name, timezone, shedule_id) 
                VALUES (7, ''Попова Мария'', -1, 4)
            SELECT 1 FROM DUAL';
    EXCEPTION 
        WHEN OTHERS THEN NULL;
    END fill_persons;
    
    PROCEDURE fill_action_types IS
    BEGIN
        EXECUTE IMMEDIATE
            'INSERT ALL
                INTO action_types (id, type) 
                VALUES (1, ''Создание'')
                INTO action_types (id, type) 
                VALUES (2, ''Утверждено'')
                INTO action_types (id, type) 
                VALUES (3, ''Отклонено'')
                INTO action_types (id, type) 
                VALUES (4, ''Перезапрос согласования'')
                INTO action_types (id, type) 
                VALUES (5, ''Оставлен комментарий'')
            SELECT 1 FROM DUAL';
    EXCEPTION 
        WHEN OTHERS THEN NULL;
    END fill_action_types;
    
    PROCEDURE fill_stages IS
    BEGIN
        EXECUTE IMMEDIATE
            'INSERT ALL
                INTO stages (id, num, name) 
                VALUES (1, 0, ''Создание'')
                INTO stages (id, num, name) 
                VALUES (2, 1, ''Этап. Руководитель'')
                INTO stages (id, num, name) 
                VALUES (3, 2, ''Этап. Сотрудник. Согласование даты отпуска'')
                INTO stages (id, num, name) 
                VALUES (4, 3, ''Этап. Кадры. Оформление приказа на отпуск'')
                INTO stages (id, num, name) 
                VALUES (5, 4, ''Этап. Сотрудник. Согласование приказа'')
                INTO stages (id, num, name) 
                VALUES (6, 5, ''Этап. Кадры. Учет приказа на отпуск'')
            SELECT 1 FROM DUAL';
    EXCEPTION 
        WHEN OTHERS THEN NULL;
    END fill_stages;
    
    PROCEDURE fill_tasks IS
    BEGIN
        EXECUTE IMMEDIATE
            'INSERT ALL
                INTO tasks (id, name, is_closed) 
                VALUES (1, ''Согласование отпуска Петрову'', ''Y'')
                INTO tasks (id, name, is_closed) 
                VALUES (2, ''Согласование отпуска Сидорову'', ''Y'')
                INTO tasks (id, name, is_closed) 
                VALUES (3, ''Согласование отпуска Поповой'', ''N'')
            SELECT 1 FROM DUAL';
    EXCEPTION 
        WHEN OTHERS THEN NULL;
    END fill_tasks;
    
    PROCEDURE fill_task_actions IS
    BEGIN
        EXECUTE IMMEDIATE
            'INSERT ALL
                INTO task_actions 
                (id, form_id, task_id, stage_id, person_id, action_type_id, 
                start_date, end_date)
                VALUES (1, 870514, 1, 1, 1, 1, TIMESTAMP''2022-04-21 17:23:20'',
                        NULL)
                INTO task_actions 
                (id, form_id, task_id, stage_id, person_id, action_type_id, 
                start_date, end_date)
                VALUES (2, 87051, 1, 2, 2, 2, TIMESTAMP''2022-04-21 17:23:22'',
                        TIMESTAMP''2022-04-21 17:25:45'')
                INTO task_actions 
                (id, form_id, task_id, stage_id, person_id, action_type_id, 
                start_date, end_date)
                VALUES (3, 87051, 1, 3, 3, 2, TIMESTAMP''2022-04-21 17:25:45'',
                        TIMESTAMP''2022-04-25 15:13:11'')
                INTO task_actions 
                (id, form_id, task_id, stage_id, person_id, action_type_id, 
                start_date, end_date)
                VALUES (4, 87051, 1, 4, 4, 2, TIMESTAMP''2022-04-25 15:13:11'',
                        TIMESTAMP''2022-04-28 15:07:08'')
                INTO task_actions 
                (id, form_id, task_id, stage_id, person_id, action_type_id, 
                start_date, end_date)
                VALUES (5, 87051, 1, 5, 3, 4, TIMESTAMP''2022-04-28 15:07:08'',
                        TIMESTAMP''2022-04-28 15:19:40'')
                INTO task_actions 
                (id, form_id, task_id, stage_id, person_id, action_type_id, 
                start_date, end_date)
                VALUES (6, 87051, 1, 5, 3, 5, TIMESTAMP''2022-04-28 15:07:08'',
                        TIMESTAMP''2022-04-28 15:19:40'')
                INTO task_actions 
                (id, form_id, task_id, stage_id, person_id, action_type_id, 
                start_date, end_date)
                VALUES (7, 87051, 1, 4, 4, 2, TIMESTAMP''2022-04-28 15:19:40'',
                        TIMESTAMP''2022-04-28 17:25:26'')
                INTO task_actions 
                (id, form_id, task_id, stage_id, person_id, action_type_id, 
                start_date, end_date)
                VALUES (8, 87051, 1, 5, 3, 4, TIMESTAMP''2022-04-28 17:25:26'',
                        TIMESTAMP''2022-04-28 18:01:42'')
                INTO task_actions 
                (id, form_id, task_id, stage_id, person_id, action_type_id, 
                start_date, end_date)
                VALUES (9, 87051, 1, 4, 4, 2, TIMESTAMP''2022-04-28 18:01:42'',
                        TIMESTAMP''2022-04-29 09:04:40'')
                INTO task_actions 
                (id, form_id, task_id, stage_id, person_id, action_type_id, 
                start_date, end_date)
                VALUES (10, 87051, 1, 5, 3, 2, TIMESTAMP''2022-04-29 09:04:40'',
                        TIMESTAMP''2022-04-29 14:57:09'')
                INTO task_actions 
                (id, form_id, task_id, stage_id, person_id, action_type_id, 
                start_date, end_date)
                VALUES (11, 87051, 1, 6, 4, 2, TIMESTAMP''2022-04-29 14:57:09'',
                        TIMESTAMP''2022-04-30 03:15:09'')
                INTO task_actions 
                (id, form_id, task_id, stage_id, person_id, action_type_id, 
                start_date, end_date)
                VALUES (12, 87051, 1, 6, 5, 2, TIMESTAMP''2022-04-28 14:57:09'',
                        TIMESTAMP''2022-05-05 11:44:37'')               
                INTO task_actions 
                (id, form_id, task_id, stage_id, person_id, action_type_id, 
                start_date, end_date)
                VALUES (13, 87051, 2, 1, 1, 1, TIMESTAMP''2022-05-05 12:00:02'',
                        NULL)
                INTO task_actions 
                (id, form_id, task_id, stage_id, person_id, action_type_id, 
                start_date, end_date)
                VALUES (14, 87051, 2, 2, 2, 2, TIMESTAMP''2022-05-05 12:00:02'',
                        TIMESTAMP''2022-05-05 13:03:10'')
                INTO task_actions 
                (id, form_id, task_id, stage_id, person_id, action_type_id, 
                start_date, end_date)
                VALUES (15, 87051, 2, 3, 6, 2, TIMESTAMP''2022-05-05 13:03:10'',
                        TIMESTAMP''2022-05-06 16:54:20'')
                INTO task_actions 
                (id, form_id, task_id, stage_id, person_id, action_type_id, 
                start_date, end_date)
                VALUES (16, 87051, 2, 4, 4, 2, TIMESTAMP''2022-05-06 16:54:20'',
                        TIMESTAMP''2022-05-06 17:48:47'')
                INTO task_actions 
                (id, form_id, task_id, stage_id, person_id, action_type_id, 
                start_date, end_date)
                VALUES (17, 87051, 2, 5, 6, 2, TIMESTAMP''2022-05-06 17:48:47'',
                        TIMESTAMP''2022-05-12 08:08:33'')
                INTO task_actions 
                (id, form_id, task_id, stage_id, person_id, action_type_id, 
                start_date, end_date)
                VALUES (18, 87051, 2, 6, 5, 2, TIMESTAMP''2022-05-12 08:08:33'',
                        TIMESTAMP''2022-05-12 21:15:04'')
                INTO task_actions 
                (id, form_id, task_id, stage_id, person_id, action_type_id, 
                start_date, end_date)
                VALUES (19, 87051, 3, 1, 1, 1, TIMESTAMP''2022-05-16 08:57:38'',
                        NULL)
                INTO task_actions 
                (id, form_id, task_id, stage_id, person_id, action_type_id, 
                start_date, end_date)
                VALUES (20, 87051, 3, 2, 2, 2, TIMESTAMP''2022-05-16 08:57:39'',
                        TIMESTAMP''2022-05-16 12:08:14'')
                INTO task_actions 
                (id, form_id, task_id, stage_id, person_id, action_type_id, 
                start_date, end_date)
                VALUES (21, 87051, 3, 2, 5, 2, TIMESTAMP''2022-05-16 08:57:39'',
                        TIMESTAMP''2022-05-16 17:02:58'')
                INTO task_actions 
                (id, form_id, task_id, stage_id, person_id, action_type_id, 
                start_date, end_date)
                VALUES (22, 87051, 3, 3, 7, 4, TIMESTAMP''2022-05-16 17:02:58'',
                        TIMESTAMP''2022-05-16 17:29:56'')
                INTO task_actions 
                (id, form_id, task_id, stage_id, person_id, action_type_id, 
                start_date, end_date)
                VALUES (23, 87051, 3, 3, 7, 5, TIMESTAMP''2022-05-16 17:02:58'',
                        TIMESTAMP''2022-05-16 17:29:56'')
                INTO task_actions 
                (id, form_id, task_id, stage_id, person_id, action_type_id, 
                start_date, end_date)
                VALUES (24, 87051, 3, 2, 5, 2, TIMESTAMP''2022-05-16 17:29:56'',
                        TIMESTAMP''2022-05-16 18:43:06'')
                INTO task_actions 
                (id, form_id, task_id, stage_id, person_id, action_type_id, 
                start_date, end_date)
                VALUES (25, 87051, 3, 2, 2, 2, TIMESTAMP''2022-05-16 17:29:56'',
                        TIMESTAMP''2022-05-17 13:49:27'')    
                INTO task_actions 
                (id, form_id, task_id, stage_id, person_id, action_type_id, 
                start_date, end_date)
                VALUES (26, 87051, 3, 3, 7, 2, TIMESTAMP''2022-05-17 13:49:27'',
                        TIMESTAMP''2022-05-17 14:15:22'')
                INTO task_actions
                (id, form_id, task_id, stage_id, person_id, action_type_id, 
                start_date, end_date)
                VALUES (27, 87051, 3, 4, 5, 2, TIMESTAMP''2022-05-17 14:15:22'',
                        TIMESTAMP''2022-05-18 10:04:13'')
                INTO task_actions 
                (id, form_id, task_id, stage_id, person_id, action_type_id, 
                start_date, end_date)
                VALUES (28, 87051, 3, 5, 7, NULL, 
                        TIMESTAMP''2022-05-18 10:04:13'', NULL)            
            SELECT 1 FROM DUAL';
    EXCEPTION 
        WHEN OTHERS THEN NULL;
    END fill_task_actions; 
    
    -- Создание представления для наглядного отображения действий по задачам
    PROCEDURE create_log_view IS
    BEGIN
        EXECUTE IMMEDIATE
            'CREATE OR REPLACE VIEW log_view AS
            SELECT ta.id, 
                   t.id     task_id, 
                   s.num    stage, 
                   s.name   stage_name, 
                   p.id     person_id,
                   p.name   person_name, 
                   ta.start_date, 
                   ta.end_date, 
                   at.type action
            FROM task_actions ta 
                   LEFT JOIN tasks t ON t.id = ta.task_id
                   LEFT JOIN stages s ON s.id = ta.stage_id 
                   LEFT JOIN persons p ON p.id = ta.person_id
                   LEFT JOIN action_types at ON at.id = ta.action_type_id
            ORDER BY ta.id';
    EXCEPTION 
        WHEN OTHERS THEN NULL;
    END create_log_view;
    
    
BEGIN

create_table_holidays;
create_table_shedules;
create_table_persons;
create_table_stages;
create_table_tasks;
create_table_action_types;
create_table_task_actions;

fill_holidays(DATE'2022-01-01', DATE'2022-12-31');
fill_shedules;
fill_persons;
fill_action_types;
fill_stages;
fill_tasks;
fill_task_actions;

create_log_view;

END;
/



 