create or replace package body log_utils is

       procedure to_log(p_appl_proc IN varchar2,
                        p_message   IN varchar2)
                        is 
       pragma autonomous_transaction;
       begin 
              insert into logs(id, appl_proc, message)
              values (log_seq.nextval, p_appl_proc, p_message);
              commit;
       end to_log;
       
       procedure log_start(p_proc_name in varchar2,
                 p_text in varchar2 default null) 
                 is
         v_message logs.message%type;
       begin 
         if p_text is null then 
           v_message := 'Logging started, process: ' || p_proc_name;
         else
           v_message := p_text;
         end if;
         
         to_log(p_appl_proc => p_proc_name, p_message => v_message);
       end log_start;
       
       
       procedure log_finish(p_proc_name in varchar2,
                 p_text in varchar2 default null)
       is
         v_message logs.message%type;         
       begin
         if p_text is null then 
           v_message := 'Logging finished, process name: ' || p_proc_name;
         else
           v_message := p_text;
         end if;
         
         to_log(p_appl_proc => p_proc_name, p_message => v_message);
       end log_finish;
       

       procedure log_error(p_proc_name in varchar2,
                 p_sqlerrm in varchar2,
                 p_text in varchar2 default null)
       is
         v_message logs.message%type;
       begin
         if p_text is null then 
           v_message := 'Error was occurred in procedure: ' || p_proc_name
           || '. ' || p_sqlerrm;
         else
           v_message := p_text;
         end if;
         
         to_log(p_appl_proc => p_proc_name, p_message => v_message);
       end log_error;

end log_utils;
/
