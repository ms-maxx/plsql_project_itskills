--test procedure util.add_employee

begin 
  util.add_employee(p_first_name => 'Maxim',
                    p_last_name => 'Smirnov',
                    p_email => 'smirnov@email',
                    p_phone_number => '2435336',
                    p_hire_date => to_date('05.03.2026 9:00:00', 'dd.mm.yyyy hh24:mi:ss'),
                    p_job_id => 'AC_MGR',
                    p_salary => 10400,
                    p_manager_id => 105,
                    p_department_id => 60
                              );
end;
/ 


--test procedure util.fire_an_employee

begin 
  util.fire_an_employee(207, 'Reduction of staff');
end;
/


--test procedure util.change_attribute_employee

begin 
     util.change_attribute_employee(p_employee_id => 207,
                                    p_first_name => 'Maxim',
                                    p_last_name => 'SecondName',
                                    p_email => 'smirnov@gemail',
                                    p_phone_number => '242526',
                                    p_job_id => 'Java_dev',
                                    p_salary => 60500,
                                    p_commission_pct => 0.8,
                                    p_manager_id => 500,
                                    p_department_id => 60);
end;
/


--test procedure util.copy_table

declare 
  v_result varchar2(1000 char);
begin 
  util_ddl.copy_table(
       p_source_scheme => 'HR',
       p_target_scheme => user,
       p_list_table    => 'EMPLOYEES,DEPARTMENTS',
       p_copy_data     => true,
       po_result       => v_result
   );
end;
/










