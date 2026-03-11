create or replace package body util is

       function is_check_time (p_date in date default sysdate) return boolean
       is
        v_start_date date := trunc(p_date) + 8/24;
        v_end_date date := trunc(p_date) + 18/24;
        v_day pls_integer;
       begin
         v_day := trunc(p_date) - trunc(p_date, 'IW') + 1;
         if v_day in (6,7) then
           return false;
         end if;
       return (p_date >= v_start_date and p_date <= v_end_date);
       end is_check_time;
       
	   
       procedure add_employee_history (p_employee_id in number,
                                       p_first_name in varchar2,
                                       p_last_name in varchar2,
                                       p_job_id in varchar2,
                                       p_department_id in number,
                                       p_salary in number,
                                       p_hire_date in date,
                                       p_fire_reason in varchar2 default null)
       is
       v_fire_reason employees_history.fire_reason%type;
       begin
         if p_fire_reason is null then 
           v_fire_reason := 'some reason';
       else 
           v_fire_reason := p_fire_reason; 
       end if;
    
       insert into
       employees_history (employee_id,
                          first_name,
                          last_name,
                          job_id,
                          department_id,
                          salary,
                          hire_date,
                          fire_reason)
       values 
          (p_employee_id,
           p_first_name,
           p_last_name,
           p_job_id,
           p_department_id,
           p_salary,
           p_hire_date,
           v_fire_reason
           );
       end add_employee_history;


       procedure add_employee(p_first_name in varchar2,
                              p_last_name in varchar2,
                              p_email in varchar2,
                              p_phone_number in varchar2,
                              p_hire_date in date default trunc(sysdate,'dd'),
                              p_job_id in varchar2,
                              p_salary in number,
                              p_commission_pct in number default null,
                              p_manager_id in number default 100,
                              p_department_id in number
                              )
        is

        v_count_job_id number(6);
        v_count_dep_id number(6);
        v_max_sal jobs.max_salary%type;
        v_min_sal jobs.min_salary%type;
        v_next_emp_id employees.employee_id%type;

        function get_next_emp_id return number
        is
         v_employee_id employees.employee_id%type;
        begin
          Select nvl(max(e.employee_id), 0)
          into v_employee_id
          from employees e;
          return v_employee_id + 1;
        end get_next_emp_id;

       begin
         log_utils.log_start(p_proc_name => 'proc: util.add_employee');

         if not is_check_time() then
           raise_application_error(-20004, 'You may only make changes during normal office hours');
         end if;
         
         begin
           select 1
           into v_count_job_id
           from jobs j
           where j.job_id = p_job_id;
         exception 
           when no_data_found then 
             raise_application_error(-20001, 'A non-existent job_id was entered.');
           when too_many_rows then 
             raise_application_error(-20005, 'More then one line found.');
         end;
         
         begin
           select 1
           into v_count_dep_id
           from departments d
           where d.department_id = p_department_id;
         exception
           when no_data_found then
             raise_application_error(-20002, 'A non-existent department_id was entered.');
           when too_many_rows then 
             raise_application_error(-20005, 'More then one line found.');
         end;

         select j.min_salary, j.max_salary
         into v_min_sal, v_max_sal
         from jobs j
         where job_id = p_job_id;

         if p_salary < v_min_sal or p_salary > v_max_sal then
           raise_application_error(-20003, 'Invalid salary value.');
         end if;

         v_next_emp_id := get_next_emp_id();

         declare
           v_message varchar2(300 char);
         begin
           v_message := 'Employee: ' || p_first_name ||' '||p_last_name||'. Job_id: '||p_job_id
                        ||'. Department id: '||p_department_id||'. successfully added to the system.' ;

           insert into
           employees (employee_id,
                      first_name,
                      last_name,
                      email,
                      phone_number,
                      hire_date,
                      job_id,
                      salary,
                      commission_pct,
                      manager_id,
                      department_id)
           values (v_next_emp_id,
                   p_first_name,
                   p_last_name,
                   p_email,
                   p_phone_number,
                   p_hire_date,
                   p_job_id,
                   p_salary,
                   p_commission_pct,
                   p_manager_id,
                   p_department_id);

         dbms_output.put_line(v_message);
         end;

         log_utils.log_finish(p_proc_name => 'proc: util.add_employee');
       exception 
         when others then 
             log_utils.log_error(p_proc_name => 'proc: util.add_employee',
                                 p_sqlerrm => sqlerrm);
              raise;
       end add_employee;
       
       
       procedure fire_an_employee(p_employee_id in number,
                                  p_fire_reason in varchar2 default null)
       is
       type t_emp_info is record (
          employee_id employees.employee_id%type,
          first_name employees.first_name%type,
          last_name employees.last_name%type,
          job_id employees.job_id%type,
          department_id employees.department_id%type,
          salary employees.salary%type,
         
       hire_date employees.hire_date%type);
                             
       v_info_employee t_emp_info;
       begin
       log_utils.log_start(p_proc_name => 'proc: util.fire_an_employee');
    
       if not is_check_time() then 
          raise_application_error(-20004, 'You may only make changes during normal office hours');
       end if;
    
       begin
         
       select e.employee_id, 
              e.first_name,
              e.last_name,
              e.job_id,
              e.department_id, 
              e.salary,
              e.hire_date
       into v_info_employee.employee_id,
            v_info_employee.first_name,
            v_info_employee.last_name,
            v_info_employee.job_id,
            v_info_employee.department_id,
            v_info_employee.salary,
            v_info_employee.hire_date
       from employees e
       where e.employee_id = p_employee_id;
       
       exception 
       when no_data_found then 
         raise_application_error(-20001, 'A non-existent employee_id was entered.');
       when too_many_rows then
         raise_application_error(-20005, 'More then one line found.');
       end;
    
       add_employee_history(p_employee_id => v_info_employee.employee_id,
                           p_first_name  => v_info_employee.first_name,
                           p_last_name   => v_info_employee.last_name,
                           p_job_id      => v_info_employee.job_id,
                           p_department_id => v_info_employee.department_id,
                           p_salary      => v_info_employee.salary,
                           p_hire_date   => v_info_employee.hire_date,
                           p_fire_reason => p_fire_reason);
    
       declare 
        v_message varchar2(300 char);
       begin 

       delete from employees e
       where e.employee_id = p_employee_id;
      
       v_message := 'Employee: ' || v_info_employee.first_name||' '||v_info_employee.last_name||
                    '. Job_id: '||v_info_employee.job_id||'. Department id: '
                    ||v_info_employee.department_id||'. successfully removed from the system.' ;
      
         dbms_output.put_line(v_message);
       end;
    
       log_utils.log_finish(p_proc_name => 'proc: util.fire_an_employee');
       exception 
         when others then 
           log_utils.log_error(p_proc_name => 'proc: util.fire_an_employee',
                                 p_sqlerrm => sqlerrm);
           raise; 
       end fire_an_employee;
       
       
       procedure change_attribute_employee(p_employee_id in number,
                                      p_first_name in varchar2 default null,
                                      p_last_name in varchar2 default null,
                                      p_email in varchar2 default null,
                                      p_phone_number in varchar2 default null,
                                      p_job_id in varchar2 default null,
                                      p_salary in number default null,
                                      p_commission_pct in number default null,
                                      p_manager_id in number default null,
                                      p_department_id in number default null) is
       begin
    
        log_utils.log_start(p_proc_name => 'proc: util.change_attribute_employee');
    
        if not is_check_time() then
            raise_application_error(-20004, 'You may only make changes during normal office hours');
        end if;
    
        if p_first_name is null 
          and p_last_name is null
          and p_email is null
          and p_phone_number is null
          and p_job_id is null
          and p_salary is null 
          and p_commission_pct is null
          and p_manager_id is null
          and p_department_id is null
        then 
          log_utils.log_finish(p_proc_name => 'proc: util.change_attribute_employee');
          raise_application_error(-20001, 'No attributes were passed for update');
        end if;
    
        update employees e
           set e.first_name = nvl(p_first_name, e.first_name),
               e.last_name = nvl(p_last_name, e.last_name),
               e.email = nvl(p_email, e.email),
               e.phone_number = nvl(p_phone_number, e.phone_number),
               e.job_id = nvl(p_job_id, e.job_id),
               e.salary = nvl(p_salary, e.salary),
               e.commission_pct = nvl(p_commission_pct, e.commission_pct),
               e.manager_id = nvl(p_manager_id, e.manager_id),
               e.department_id = nvl(p_department_id, e.department_id)
           where e.employee_id = p_employee_id; 
         
        if sql%rowcount = 0 then 
          raise_application_error(-20002, 'Employee does not exists');
        end if;
      
        dbms_output.put_line('The employees: '||p_employee_id||' attributes heve been successfully updated');
          
        log_utils.log_finish(p_proc_name => 'proc: util.change_attribute_employee');
       exception 
         when others then 
           log_utils.log_error(p_proc_name => 'proc: util.change_attribute_employee',
                                 p_sqlerrm => sqlerrm);
         raise;  
       end change_attribute_employee;
       

end util;
/