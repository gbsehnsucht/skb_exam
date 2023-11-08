CREATE OR REPLACE FUNCTION calculate_worktime_interval_func
(timezone IN number, from_h IN number, to_h IN number, lunch_at IN number, 
start_time_in IN TIMESTAMP, end_time_in IN TIMESTAMP) 

RETURN NUMBER 
IS

    timer INTERVAL DAY TO SECOND := '+00 00:00:00.000000';
    
    -- Корректировка начала и завершения этапа с учетом часового пояса 
	start_time TIMESTAMP := start_time_in + NUMTODSINTERVAL(timezone,'HOUR');
    end_time TIMESTAMP := end_time_in + NUMTODSINTERVAL(timezone,'HOUR');
    
    start_date DATE := CAST(start_time AS DATE);
    end_date DATE := CAST(end_time AS DATE);
    current_date DATE := start_date;
    
    -- Переменные, обозначающие границы рабочего дня сотрудника  
    work_start TIMESTAMP;
    lunch_start TIMESTAMP;
    lunch_end TIMESTAMP;
    work_end TIMESTAMP;
    
    -- Функция, проверяющая, является ли дата выходным днем
    FUNCTION check_holiday(date_for_check IN VARCHAR2) 
    RETURN BOOLEAN IS
    BEGIN
    FOR r IN (SELECT h_date FROM holidays WHERE h_date = date_for_check)
    LOOP
        RETURN TRUE;
    END LOOP;
    RETURN FALSE;
    END check_holiday;
    
    -- Функция, преобразующая интервал в количество минут
    FUNCTION extract_minutes_from_interval (timer IN INTERVAL DAY TO SECOND) 
    RETURN NUMBER IS
        timer_minutes NUMBER;
    BEGIN
        timer_minutes := EXTRACT(DAY FROM timer) * 24 * 60 + 
                         EXTRACT(HOUR FROM timer) * 60 +
                         EXTRACT(MINUTE FROM timer);
    RETURN timer_minutes;
    END extract_minutes_from_interval;

    
BEGIN
    
    -- Если этап начат и закончен в выходной день
    IF TO_CHAR(current_date) = TO_CHAR(end_date) 
        AND check_holiday(TO_CHAR(current_date)) THEN NULL;
    
    -- Если этап начат и закончен в рабочий день
    ELSIF TO_CHAR(current_date) = TO_CHAR(end_date) THEN

        work_start := TO_TIMESTAMP( current_date || ' ' || from_h || ':00:00');
        lunch_start := TO_TIMESTAMP( current_date || ' ' || lunch_at || ':00:00');
        lunch_end := TO_TIMESTAMP( current_date || ' ' || (lunch_at + 1) || ':00:00');
        work_end := TO_TIMESTAMP( current_date || ' ' || to_h || ':00:00');
        
        /* Расчет всех варинтов попадания начала и завершения этапа 
        в распорядок дня сотрудника */
        
        -- Если рабочее время не задействовано 
        IF end_time < work_start OR start_time > work_end THEN NULL;  
        
        -- Если этап начат перед началом рабочего дня
        ELSIF start_time < work_start THEN           
            
            IF end_time > work_start AND end_time <= lunch_start THEN
                timer := timer + (end_time - work_start);
            
            ELSIF end_time > lunch_start AND end_time <= lunch_end THEN
                timer := timer + (lunch_start - work_start);
            
            ELSIF end_time > lunch_end AND end_time <= work_end THEN
                timer := timer + (lunch_start - work_start) + (end_time - lunch_end);
            
            ELSE
                timer := timer + (lunch_start - work_start) + (work_end - lunch_end);
            
            END IF;
        
        -- Если этап начат в первой половине рабочего дня
        ELSIF start_time > work_start AND start_time <= lunch_start THEN           
            
            IF end_time <= lunch_start THEN
                timer := timer + (end_time - start_time);
            
            ELSIF end_time > lunch_start AND end_time <= lunch_end THEN
                timer := timer + (lunch_start - start_time);
            
            ELSIF end_time > lunch_end AND end_time <= work_end THEN
                timer := timer + (lunch_start - start_time) + (end_time - lunch_end);
            
            ELSE
                timer := timer + (lunch_start - start_time) + (work_end - lunch_end);
            
            END IF; 
        
        -- Есди этап начат во время обеденного перерыва
        ELSIF start_time > lunch_start AND start_time <= lunch_end THEN           
            
            IF end_time <= lunch_end THEN
                NULL;
            
            ELSIF end_time > lunch_end AND end_time <= work_end THEN
                timer := timer + (end_time - lunch_end);
            
            ELSE
                timer := timer + (work_end - lunch_end);
            
            END IF;   
        
        -- Если этап начат во второй половине рабочего дня
        ELSE           
           
            IF end_time <= work_end THEN
                timer := timer + (end_time - start_time);
           
            ELSE
                timer := timer + (work_end - start_time);
           
            END IF; 
            
        END IF;
    
    -- Если этап начат в один день, а закончен в другой       
    ELSE
        
        -- Расчет затраченного времени для всех дней этапа, кроме последнего
        WHILE current_date < TO_TIMESTAMP( end_date || ' '  || '00:00:00')
        LOOP
            
            IF check_holiday(TO_CHAR(current_date)) THEN
                NULL;
            
            ELSE
             
                work_start := TO_TIMESTAMP( current_date || ' ' || from_h || ':00:00');
                lunch_start := TO_TIMESTAMP( current_date || ' ' || lunch_at || ':00:00');
                lunch_end := TO_TIMESTAMP( current_date || ' ' || (lunch_at + 1) || ':00:00');
                work_end := TO_TIMESTAMP( current_date || ' ' || to_h || ':00:00');
    
                -- Варианты попадания start_time в распорядок дня сотрудника 
                IF start_time <= work_start THEN
                    timer := timer + (lunch_start - work_start) + (work_end - lunch_end); 
                
                ELSIF start_time > work_start AND start_time <= lunch_start THEN
                    timer := timer + (lunch_start - start_time) + (work_end - lunch_end);
                
                ELSIF start_time > lunch_start AND start_time <= lunch_end THEN
                    timer := timer + (work_end - lunch_end);
                
                ELSIF start_time > lunch_end AND start_time < work_end THEN
                    timer := timer + (work_end - start_time);
               
                ELSE
                    null;
                
                END IF;
                            
            END IF;
            current_date := current_date + 1;
            
            /* Если между start_date и end_date есть рабочие дни, 
            start_time для каждого из них устанавливается в начало 
            рабочего дня сотрудника */
            start_time := TO_TIMESTAMP( current_date || ' ' || from_h || ':00:00');
        END LOOP;
        
        
        -- Если этап завершился в выходной день 
        IF check_holiday(TO_CHAR(end_date)) THEN NULL;
        
         
        ELSE
            work_start := TO_TIMESTAMP( end_date || ' ' || from_h || ':00:00');
            lunch_start := TO_TIMESTAMP( end_date || ' ' || lunch_at || ':00:00');
            lunch_end := TO_TIMESTAMP( end_date || ' ' || (lunch_at + 1) || ':00:00');
            work_end := TO_TIMESTAMP( end_date || ' ' || to_h || ':00:00');
            
            -- Варианты попадания end_time в распорядок дня сотрудника
            IF end_time <= work_start THEN
                NULL;
            
            ELSIF end_time > work_start AND end_time <= lunch_start THEN
                timer := timer + (end_time - work_start);
            
            ELSIF end_time > lunch_start AND end_time <= lunch_end THEN
                timer := timer + (lunch_start - work_start);
            
            ELSIF end_time > lunch_end AND end_time <= work_end THEN
                timer := timer + (lunch_start - work_start) + (end_time - lunch_end);
            
            ELSE
                timer := timer + (lunch_start - work_start) + (work_end - lunch_end);
            
            END IF;
            
        END IF;
        
    END IF;
    
    RETURN extract_minutes_from_interval(timer);
    
END;
/


CREATE OR REPLACE FUNCTION extract_days_from_interval_func
(timer IN INTERVAL DAY TO SECOND) 

RETURN FLOAT
IS
    timer_days FLOAT;
BEGIN

    timer_days := (EXTRACT(DAY FROM timer) * 24 * 60 + 
                   EXTRACT(HOUR FROM timer) * 60 +
                   EXTRACT(MINUTE FROM timer)) / 1440;
             
    RETURN ROUND(timer_days, 2);
    
END;
/

