create or replace package util is

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
                              );

end util;
/
