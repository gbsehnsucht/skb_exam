CREATE OR REPLACE VIEW person_task_interval_view AS 

   SELECT ta.task_id task_id, 
          p.id       person_id, 
          p.name     person_name, 
          SUM ( calculate_worktime_interval_func (
                p.timezone, 
                sh.from_hours, 
                sh.to_hours, 
                sh.lunch_at, 
                ta.start_date, 
                ta.end_date)) timer
     FROM task_actions ta 
LEFT JOIN persons p ON p.id = ta.person_id
LEFT JOIN shedules sh ON sh.id = p.shedule_id
    -- Выбираем все действия, кроме создания задачи и оставления комментария
    WHERE ta.action_type_id NOT IN ( 1, 5 ) 
 GROUP BY p.id, p.name, ta.task_id
 ORDER BY task_id, timer DESC;
