--test procedure add_employee

begin 
  util.add_employee(p_first_name => 'Maxim',
                    p_last_name => 'Smirnov',
                    p_email => 'smirnov@email',
                    p_phone_number => '2435336',
                    p_hire_date => sysdate,
                    p_job_id => 'AC_MGR',
                    p_salary => 10400,
                    p_manager_id => 105,
                    p_department_id => 60
                              );
end;
/ 
