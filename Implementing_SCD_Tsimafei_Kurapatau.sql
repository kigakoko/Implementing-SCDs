alter table dimemployee
drop constraint dimemployee_pkey;

alter table dimemployee
add column startdate timestamp,
add column enddate timestamp,
add column iscurrent boolean default true,
add column employeehistoryid serial primary key;

update  dimemployee
set employeehistoryid = default;

update dimemployee
set startdate = hiredate,
    enddate = '2025-12-31';
   
create or replace function employees_update_function()
returns trigger as $$
begin
    if (old.title <> new.title or old.address <> new.address) and old.iscurrent and new.iscurrent then
        update dimemployee
        set enddate = current_timestamp,
            iscurrent = false,
            title = old.title,
            address = old.address
        where employeeid = old.employeeid and iscurrent = true;

      
        insert into dimemployee (employeeid, lastname, firstname, title, birthdate, hiredate, address, city, region, postalcode, country, homephone, extension, startdate, enddate, iscurrent)
        values (old.employeeid, old.lastname, old.firstname, new.title, old.birthdate, old.hiredate, new.address, old.city, old.region, old.postalcode, old.country, old.homephone, old.extension, current_timestamp, '9999-12-31', true);
    end if;
    return new;
end;
$$ language plpgsql;

drop trigger if exists employees_update_trigger on dimemployee cascade;
create trigger employees_update_trigger
after update on dimemployee
for each row
execute function employees_update_function();

update dimemployee
set address = 'Loshitza'
where firstname = 'Gomer' and lastname = 'Simspos' and iscurrent = true;

update dimemployee
set title ='developer'
where firstname = 'Mardj' and lastname = 'Simspos' and iscurrent = true;

