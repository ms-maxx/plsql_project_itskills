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
                              
       procedure fire_an_employee(p_employee_id in number,
                                  p_fire_reason in varchar2 default null);
                                  
       procedure change_attribute_employee(p_employee_id in number,
                                      p_first_name in varchar2 default null,
                                      p_last_name in varchar2 default null,
                                      p_email in varchar2 default null,
                                      p_phone_number in varchar2 default null,
                                      p_job_id in varchar2 default null,
                                      p_salary in number default null,
                                      p_commission_pct in number default null,
                                      p_manager_id in number default null,
                                      p_department_id in number default null);

end util;
/