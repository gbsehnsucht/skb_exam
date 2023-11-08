CREATE OR REPLACE VIEW person_stage_task_interval_view AS 

   SELECT task_id, 
          s.num  stage, 
          s.name stage_name, 
          person_name, 
          timer 
     FROM (SELECT ta.task_id task_id, 
                  ta.stage_id      stage_id, 
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
            WHERE ta.action_type_id NOT IN ( 1, 5 )
         GROUP BY ta.task_id, ta.stage_id, p.name
          ) sub
LEFT JOIN stages s ON s.id = sub.stage_id 
 ORDER BY task_id, s.num;
