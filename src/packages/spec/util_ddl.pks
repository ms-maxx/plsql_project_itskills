create or replace package util_ddl is

  type rec_value_list is record(
    value_list varchar2(100));

  type tab_value_list is table of rec_value_list;
  v_tab_array tab_value_list;

  function table_from_list(p_list_val  in varchar2,
                           p_separator in varchar2 default ',')
    return tab_value_list
    pipelined;

  procedure copy_table(p_source_scheme in varchar2,
                       p_target_scheme in varchar2 default user,
                       p_list_table    in varchar2,
                       p_copy_data     in boolean default false,
                       po_result       out varchar2);
end util_ddl;
/