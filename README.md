## Описание

**create_tables** - создание и наполнение таблиц тестовыми данными;

**create_functions** - создание функций, используемых в итоговых представлениях:
    
    - calculate_worktime_interval_func - вычисляет затраченное рабочее время сотрудника (в нее должны быть переданы часовой пояс, время начала обеденного перерыва, начало и конец рабочего дня сотрудника, а также время начала и завершения этапа задачи, выполняемого сотрудником);

    - extract_days_from_interval_func - преобразует переданный интервал в количество дней (float);

**person_task_interval_view** - создание представления, отражающего сколько рабочего времени каждый из сотрудников затратил на  обработку данной задачи;

**stage_task_days_view** - создание представления, отражающего cколько календарных дней задача находилась на каждом из этапов задачи;

**person_stage_task_interval_view** - создание представления, отражающего, сколько рабочего времени каждый из сотрудников затратил на согласование в рамках каждого этапа;

**test_cases** - содержит несколько отдельных проверок созданных функций.

