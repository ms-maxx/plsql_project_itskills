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
           v_message := 'Employee: ' || p_first_name ||' '||p_last_name||' Job_id: '||p_job_id
                        ||'. Department id: '||p_department_id||' successfully added to the system.' ;

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



end util;
/
