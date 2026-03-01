create or replace package log_utils is

       procedure log_start(p_proc_name in varchar2,
                 p_text in varchar2 default null);

       procedure log_finish(p_proc_name in varchar2,
                 p_text in varchar2 default null);

       procedure log_error(p_proc_name in varchar2,
                 p_sqlerrm in varchar2,
                 p_text in varchar2 default null);

end log_utils;
/
