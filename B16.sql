create database store_management;
use store_management;

create table Customers(
	customer_id int primary key auto_increment,
    customer_name varchar(100) not null,
    phone varchar(20) not null unique,
    address varchar(255)
);


create table Products(
	product_id int primary key auto_increment,
    product_name varchar(100) not null unique,
    price decimal(10,2) not null,
    quantity int not null check(quantity>0),
    category varchar(50) not null
);

create table Employees(
	employee_id int primary key auto_increment,
    employee_name varchar(100) not null,
    birthday date,
    position varchar(50) not null,
    salary decimal(10,2) not null,
	revenue decimal(10,2) default (0)
);


create table Orders(
	order_id int primary key auto_increment,
    customer_id int,
    employee_id int,
    order_date datetime default(current_timestamp()),
    total_amount decimal(10,2) default(0),
    foreign key (customer_id) references Customers(customer_id),
    foreign key (employee_id) references Employees(employee_id)
);

create table OrderDetails(
	order_detail_id int primary key auto_increment,
    order_id int,
    product_id int,
    quantity int not null check(quantity>0),
    unit_price decimal(10,2) not null,
    foreign key (order_id) references Orders(order_id),
    foreign key (product_id) references Products(product_id)
);


-- 3.1
alter table Customers
add column email varchar(100) not null unique;


-- 3.2
alter table Employees
drop column birthday;


-- 4.1
insert into Customers(customer_name,phone,address,email)
values
('Nguyen Van A','0987654321','Thanh Hoa','nguyenvana@gmail.com'),
('Pham Van B','0987654322','Nghe An','phamvanb@gmail.com'),
('Nguyen Thi C','0987654323','Ninh Binh','nguyenthic@gmail.com'),
('Tran Thai Binh D','0987654325','Ha Noi','duongtran@gmail.com'),
('Nguyen Hong E','0987654324','Ha Nam','hongl@gmail.com'),
('Ha Duc L','0987654329','Phu Tho','haducluong@gmail.com'),
('Nguyen Thanh T','0987654312','Bac Ninh','tung2005@gmail.com');


insert into Products(product_name, price, quantity, category)
values 
('Quần Tây', 100000.00, 10, 'Quần Áo'),
('Sách Làm Giàu', 8000.00, 10, 'Sách'),
('quần jean', 150000.00, 15, 'quần áo'),
('sách tiếng anh', 12000.00, 20, 'sách'), 
('áo thun', 80000.00, 25, 'quần áo'),
('mũ lưỡi trai', 45000, 30, 'phụ kiện'),
('dép đi biển', 35000, 12, 'giày dép');


insert into Employees(employee_name,position,salary)
values
('Pham Thanh T','Nhân Viên Bán Hàng','123000.00'),
('Le Thi G','Nhân Viên Chăm Sóc Khách Hàng','125000.00'),
('Nguyen Thi M','Nhân Viên Bán Hàng','150000.00'),
('Thieu Duc N','Quản lí','223000.00'),
('Nguyen Trung H','Nhân Viên Chăm Sóc Khách Hàngg','253000.00'),
('Nguyen Linh T','Nhân Viên Bán Hàng','153000.00')
;

insert into Orders(customer_id,employee_id,total_amount)
values
(1,1,200000.00),
(2,1,350000.00),
(3,2,500000.00),
(1,4,2200000.00),
(4,5,6350000.00),
(3,3,11000.00)
;


insert into OrderDetails(order_id,product_id,quantity,unit_price)
values
(1,1,5,5000.00),
(2,2,4,6000.00),
(3,3,6,11000.00),
(4,4,7,15000.00),
(5,5,9,25000.00)
;

-- 5.1
select * from customers;

-- 5.2
update products
set product_name = 'Laptop Dell XPS', price = '99.99' 
where product_id = 1;

-- 5.3
select o.order_id,c.customer_name,e.employee_name,o.total_amount,o.order_date
from orders o join customers c on o.customer_id = c.customer_id
			  join employees e on e.employee_id = o.employee_id;
              

-- 6.1
select c.customer_id,c.customer_name, count(c.customer_id) as total_order from customers c 
join orders o on o.customer_id = c.customer_id group by o.customer_id;
                       
                       
-- 6.2
select employee_id,employee_name,revenue from employees;


-- 6.3
select p.product_id,p.product_name, sum(od.quantity) as total_quantity 
from orderdetails od join products p on od.product_id = p.product_id 
group by p.product_id having total_quantity>100 order by total_quantity desc;


-- 7.1
select c.customer_id, c.customer_name from customers c 
where customer_id not in
(select distinct customer_id from orders);


-- 7.2
select * from products where price > (select avg(price) from products);


-- 7.3
select c.customer_id, c.customer_name, sum(o.total_amount) as total_sum_amount
from customers c join orders o on c.customer_id = o.customer_id 
group by o.customer_id
having total_sum_amount = (select sum(o.total_amount) as total from orders o group by o.customer_id order by total desc limit 1);


-- 8.1
create view view_order_list as
select o.order_id, c.customer_name, e.employee_name, o.total_amount,o.order_date
from orders o join customers c on o.customer_id = c.customer_id
join employees e on e.employee_id = o.employee_id
order by o.order_date desc;


-- 8.2
create view view_order_detail_product as
select od.order_detail_id, p.product_name,od.quantity,od.unit_price 
from orderdetails od join products p on od.product_id = p.product_id
order by od.quantity desc;



-- 9.1
DELIMITER &&
create procedure proc_insert_employee(
	customer_name_in varchar(100),
    phone_in varchar(20) ,
    address_in varchar(255),
    email_in varchar(100),
    out id_out int
)
begin
	insert into customers(customer_name,phone,address,email)
    values (customer_name_in,phone_in,address_in,email_in);

	select c.customer_id into id_out from customers c where c.customer_name = customer_name_in;
end &&;
DELIMITER &&;

drop procedure proc_insert_employee;
call proc_insert_employee('Pham Van Minh',0355129123,'Thanh Hoa','vminh0227@gmail.com',@result);
select @result;



-- 9.2
DELIMITER &&
create procedure proc_get_orderdetails(
	order_id_in int
)
begin
	select od.order_detail_id, od.order_id, p.product_name, od.quantity, od.unit_price 
    from orderdetails od 
    join products p on od.product_id = p.product_id
    where od.order_id = order_id_in;
end &&;
DELIMITER &&;

call proc_get_orderdetails(1);

-- 9.3
DELIMITER &&
create procedure proc_cal_total_amount_by_order(
    order_id_in int,
    out total_product_types int
)
begin
    select quantity into total_product_types
    from orderdetails
    where order_id = order_id_in;
end &&
DELIMITER &&;

drop procedure proc_cal_total_amount_by_order;
call proc_cal_total_amount_by_order(1,@result_02);
select @result_02;


-- 10
DELIMITER &&

create trigger trigger_after_insert_order_details
before insert on OrderDetails
for each row
begin
    declare stock_quantity int;

    -- Get the current stock quantity of the product
    select quantity into stock_quantity 
    from Products 
    where product_id = NEW.product_id;

    -- Check if there is enough stock
    if stock_quantity < NEW.quantity then
        signal sqlstate '45000'
        set message_text = 'Số lượng sản phẩm trong kho không đủ';
    else
        -- Update the stock by reducing the quantity
        update Products 
        set quantity = quantity - NEW.quantity 
        where product_id = NEW.product_id;
    end if;
end &&

DELIMITER ;



-- 11
DELIMITER &&

create procedure proc_insert_order_details(
    in order_id_in int,
    in product_id_in int,
    in quantity_in int,
    in unit_price_in decimal(10,2)
)
begin
    declare order_exists int;
    declare total_price decimal(10,2);
    
    start transaction;
    
    select count(*) into order_exists from orders where order_id = order_id_in;
    
    if order_exists = 0 then
        signal sqlstate '45000'
        set message_text = 'không tồn tại mã hóa đơn';
    end if;
    
    insert into orderdetails(order_id, product_id, quantity, unit_price)
    values (order_id_in, product_id_in, quantity_in, unit_price_in);
    
    select sum(quantity * unit_price) into total_price 
    from orderdetails 
    where order_id = order_id_in;
    
    update orders 
    set total_amount = total_price
    where order_id = order_id_in;
    
    commit;
    
end &&

DELIMITER ;

drop procedure proc_insert_order_details;
call proc_insert_order_details(1, 2, 3, 12000.00);
