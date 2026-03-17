create or replace package body util_ddl is

  FUNCTION table_from_list(p_list_val  IN VARCHAR2,
                           p_separator IN VARCHAR2 DEFAULT ',')
    RETURN tab_value_list
    PIPELINED IS
  BEGIN
  
    for rec in (SELECT TRIM(REGEXP_SUBSTR(p_list_val,
                                          '[^' || p_separator || ']+',
                                          1,
                                          LEVEL)) AS cur_value
                  FROM dual
                CONNECT BY LEVEL <=
                           REGEXP_COUNT(p_list_val, p_separator) + 1) loop
    
      PIPE ROW(rec.cur_value);
    
    end loop;
  
    return;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END table_from_list;

  procedure copy_table(p_source_scheme in varchar2,
                       p_target_scheme in varchar2 default user,
                       p_list_table    in varchar2,
                       p_copy_data     in boolean default false,
                       po_result       out varchar2) is
    v_create_sql    varchar2(32767 char);
    v_insert_sql    varchar2(32767 char);
    v_source_scheme varchar2(100 char) := upper(p_source_scheme);
    v_target_scheme varchar2(100 char) := upper(p_target_scheme);
    v_count_done    number := 0;
    v_count_skip    number := 0;
    v_count_error   number := 0;
    v_text          varchar2(1000 char);
  
    procedure text_output(text varchar2) is
    begin
      dbms_output.put_line(text);
    end text_output;
  
  begin
    log_utils.log_start(p_proc_name => 'proc: util.copy_table');
    po_result := null;
  
    if p_source_scheme is null then
      raise_application_error(-20001, 'Source schema is required.');
    end if;
  
    if p_list_table is null then
      raise_application_error(-20002, 'Table list is required.');
    end if;
  
    for rec in (select table_name,
                       'create table ' || v_target_scheme || '.' ||
                       table_name || ' (' ||
                       listagg(column_name || ' ' || data_type || case
                                 when data_type in ('VARCHAR2', 'CHAR') then
                                  '(' || data_length || ')'
                                 when data_type = 'NUMBER' then
                                  replace('(' || data_precision || ',' || data_scale || ')',
                                          '(,)',
                                          null)
                                 when data_type = 'DATE' then
                                  null
                               end,
                               ', ') within group(order by column_id) || ')' as ddl_code
                  from all_tab_columns
                 where owner = v_source_scheme
                   and table_name in
                       (select value(t)
                          from table(table_from_list(upper(p_list_table)))t )
                 group by table_name
                 order by table_name) loop
      begin
        v_create_sql := rec.ddl_code;
        v_text       := 'START table ' || rec.table_name;
        text_output(v_text);
        v_text := 'DDL=' || v_create_sql;
        text_output(v_text);
      
        execute immediate v_create_sql;
      
        if p_copy_data then
          v_insert_sql := 'insert into ' || p_target_scheme || '.' ||
                          rec.table_name || ' select * from ' ||
                          v_source_scheme || '.' || rec.table_name;
        
          v_text := 'DML=' || v_insert_sql;
          text_output(v_text);
        
          execute immediate v_insert_sql;
        end if;
      
        v_text := 'SUCCESS table=' || rec.table_name;
        text_output(v_text);
        v_count_done := v_count_done + 1;
      
      exception
        when others then
          if sqlcode = -00955 then
            v_text := 'SKIP table= ' || rec.table_name || ' already exists';
            text_output(v_text);
            v_count_skip := v_count_skip + 1;
            log_utils.log_error(p_proc_name => 'proc: util.copy_table',
                                p_sqlerrm   => sqlerrm,
                                p_text      => v_text);
            continue;
          else
            v_text := 'ERROR table= ' || rec.table_name || ', code=' ||
                      sqlcode || ', msg=' || sqlerrm;
            text_output(v_text);
            v_count_error := v_count_error + 1;
            log_utils.log_error(p_proc_name => 'proc: util.copy_table',
                                p_sqlerrm   => sqlerrm,
                                p_text      => v_text);
            continue;
          end if;
          raise;
      end;
    end loop;
  
    po_result := 'Completed. Created=' || v_count_done || ', Skipped=' ||
                 v_count_skip || ', Errors=' || v_count_error;
  
    text_output(po_result);
    log_utils.log_finish(p_proc_name => 'proc: util.copy_table',
                         p_text      => po_result);
  exception
    when others then
      po_result := 'Fatal error:' || sqlerrm;
      text_output(po_result);
      log_utils.log_error(p_proc_name => 'proc: util.copy_table',
                          p_sqlerrm   => sqlerrm);
      raise;
  end copy_table;

end util_ddl;
/