CREATE OR REPLACE VIEW stage_task_days_view AS 

   SELECT task_id, 
          s.num  stage, 
          s.name stage_name, 
          timer 
     FROM (SELECT task_id, 
                  stage_id, 
                  SUM ( extract_days_from_interval_func( timer ) ) timer
             FROM (SELECT task_id, 
                          stage_id,
                          
                          /* Сравниваются два соседних действиия задачи:
                          если они принадлежат одному этапу (случай с 
                          несколькими участниками согласования), в расчет 
                          попадает только самое продолжительное из них */
                          CASE
                               WHEN stage_id = next_stage 
                                    THEN GREATEST(timer, next_timer)
                               WHEN stage_id = prev_stage 
                                    THEN NUMTODSINTERVAL(0,'HOUR')
                               ELSE timer
                        END AS timer
                     
                     /* В запрос этапов задачи добавлены столбцы с этапами
                     следующего и предыдущего дествия в задачи, а также 
                     интервала следующего действия */
                     FROM (SELECT ta.task_id  task_id, 
                                  ta.stage_id stage_id, 
                                  (ta.end_date - ta.start_date) timer,
                                  lead(ta.stage_id) over 
                                  (partition by task_id order by id) next_stage,
                                  lag(ta.stage_id) over 
                                  (partition by task_id order by id) prev_stage,
                                  (lead(ta.end_date) over (order by id) -
                                   lead(ta.start_date) over (order by id)) next_timer
                             FROM task_actions ta  
                            WHERE ta.action_type_id NOT IN ( 1, 5 ) 
                          )
                  )
         GROUP BY task_id, stage_id
          ) sub   
LEFT JOIN stages s ON s.id = sub.stage_id
 ORDER BY task_id, s.num;
    
    
    