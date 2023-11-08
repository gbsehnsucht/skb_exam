-- calculate_worktime_interval_func

select calculate_worktime_interval_func( 10, 8, 17, 11, 
    TIMESTAMP'2022-04-10 22:00:56', TIMESTAMP'2022-04-11 09:40:27') from dual;


select calculate_worktime_interval_func( 10, 8, 17, 11, 
    TIMESTAMP'2022-04-10 09:00:56', TIMESTAMP'2022-04-11 01:40:27') from dual;


select calculate_worktime_interval_func( -12, 8, 17, 11, 
    TIMESTAMP'2022-04-08 09:00:56', TIMESTAMP'2022-04-11 11:40:27') from dual;
    

select calculate_worktime_interval_func( 7, 9, 18, 13, 
    TIMESTAMP'2022-05-16 09:00:56', TIMESTAMP'2022-05-16 13:40:27') from dual;
    

select calculate_worktime_interval_func( 0, 9, 18, 13, 
    TIMESTAMP'2022-05-16 09:00:56', TIMESTAMP'2022-05-16 13:40:27') from dual;
    

select calculate_worktime_interval_func( 0, 9, 18, 13, 
    TIMESTAMP'2022-05-16 09:00:56', TIMESTAMP'2022-05-17 18:00:27') from dual;
    

select calculate_worktime_interval_func( 3, 9, 18, 13,
    TIMESTAMP'2022-05-16 17:29:56', TIMESTAMP'2022-05-17 13:49:27') from dual;
                        
                        
select calculate_worktime_interval_func( 3, 9, 18, 13, 
    TIMESTAMP'2022-05-16 08:57:39', TIMESTAMP'2022-05-16 12:08:14' ) from dual;
                          
                          
select calculate_worktime_interval_func( -5, 8, 17, 12, 
    TIMESTAMP'2022-05-16 08:57:39', TIMESTAMP'2022-05-16 17:02:58' ) from dual;
    
    
select calculate_worktime_interval_func( -5, 8, 17, 12, 
    TIMESTAMP'2022-05-16 17:29:56', TIMESTAMP'2022-05-16 18:43:06') from dual;
                        
          
-- extract_days_from_interval_func
                                   
select extract_days_from_interval_func(
    TIMESTAMP'2022-04-25 15:13:11' - TIMESTAMP'2022-04-21 17:25:45') from dual;
                
select extract_days_from_interval_func(
    TIMESTAMP'2022-04-29 09:04:40' - TIMESTAMP'2022-04-28 18:01:42') from dual;

select extract_days_from_interval_func(
    TIMESTAMP'2022-04-29 14:57:09' - TIMESTAMP'2022-04-29 09:04:40') from dual;