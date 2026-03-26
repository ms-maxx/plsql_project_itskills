BEGIN
  dbms_scheduler.create_job(job_name        => 'sh_update_cur_exchange',
                            job_type        => 'PLSQL_BLOCK',
                            job_action      => 'begin util.арi_nbu_sync; end;',
                            start_date      => SYSTIMESTAMP,
                            repeat_interval => 'FREQ=DAILY;BYHOUR=6;BYMINUTE=0;BYSECOND=0',
                            end_date        => TO_DATE(NULL),
                            job_class       => 'DEFAULT_JOB_CLASS',
                            enabled         => TRUE,
                            auto_drop       => FALSE,
                            comments        => 'Оновлення валют из nbu api');
END;
/

BEGIN
 DBMS_SCHEDULER.RUN_JOB(job_name => 'sh_update_cur_exchange');
END;
/




