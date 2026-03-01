create table logs (
    id number(6),
    appl_proc varchar2(50),
    message varchar2(2000), 
    log_date date default sysdate,
    constraint logs_pk primary key(id)
);
/
    