CREATE DATABASE projectFINAL2
go

USE projectFINAL2

CREATE TABLE PostGradUser(
    id int PRIMARY KEY IDENTITY,
    email VARCHAR(50),
    password VARCHAR(20) 
); 

CREATE TABLE Admin(
    id int PRIMARY KEY ,
    foreign key (id) references PostGradUser on update cascade on delete cascade

);



CREATE TABLE GucianStudent(
    id int PRIMARY KEY ,
    firstName VARCHAR(20),
    lastName VARCHAR(20),
    type VARCHAR(20),
    --ask about type bit? or gucian bit--
    --type bit,--
    faculty VARCHAR(20),
    address VARCHAR(10),
    GPA DEC(3,2),
    undergradID varchar(10),
    foreign key (id) references PostGradUser on update cascade on delete cascade
);


CREATE TABLE NonGucianStudent(
    id int PRIMARY KEY ,
    firstName VARCHAR(20),
    lastName VARCHAR(20),
    type varchar(20),
    faculty VARCHAR(20),
    address VARCHAR(10),
    GPA DEC(3,2),
    foreign key (id) references PostGradUser on update cascade on delete cascade
);

CREATE TABLE GUCStudentPhoneNumber(
    id int,
    phone VARCHAR(20),
    PRIMARY KEY (id,phone),
    FOREIGN KEY (id) REFERENCES GucianStudent ON DELETE CASCADE ON UPDATE CASCADE,


); 
CREATE TABLE NonGUCStudentPhoneNumber(
    id int,
    phone VARCHAR(20),
    PRIMARY KEY (id,phone),
    FOREIGN KEY (id) REFERENCES NonGucianStudent ON DELETE CASCADE ON UPDATE CASCADE,
    

);

 CREATE TABLE Course(
     id int PRIMARY KEY IDENTITY,
     fees decimal,
     creditHours int, 
     code VARCHAR(10)
 );
 
CREATE TABLE Supervisor(
 id int PRIMARY KEY,
 name VARCHAR(20),
 faculty VARCHAR(20),
 FOREIGN KEY (id) REFERENCES PostGradUser ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Payment(
    id int PRIMARY KEY IDENTITY,
    amount decimal(10,2),
    no_Installments int,
    fundPercentage int
);

CREATE TABLE Thesis(
    serialNumber int PRIMARY KEY IDENTITY,
    field VARCHAR(20),
    type VARCHAR(20),
    title VARCHAR(20),
    startDate DATETIME,
    endDate DATETIME,
    defenseDate DATETIME,
    years as Year(endDate) - Year(startDate),
    grade decimal(4,2),
    payment_id int,
    noExtension int,
    FOREIGN KEY(payment_id) REFERENCES Payment ON DELETE CASCADE ON UPDATE CASCADE
    
);
CREATE TABLE Publication (
    id int PRIMARY KEY IDENTITY,
    title VARCHAR(50),
    date DATETIME,
    place VARCHAR(50),
    accepted BIT,
    host VARCHAR(50)
);


CREATE TABLE Examiner(
    id int PRIMARY KEY ,
    name VARCHAR(20),
    fieldOfWork VARCHAR(20),
    isNational BIT,
    FOREIGN KEY (id) REFERENCES PostGradUser ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Defense(
    serialNumber int ,
    date DATETIME,
    location varchar(15),
    grade DECIMAL(4,2),
    FOREIGN KEY (serialNumber) REFERENCES Thesis ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (serialNumber, date)

);
create TABLE GUCianProgressReport (
    sid int,
    no int identity,
    date DATETIME,
    eval int,
    state VARCHAR(20),
    thesisSerialNumber int,
    supid INT,
    check (eval between 0 and 3),
    PRIMARY KEY(sid,no),
    FOREIGN KEY(sid) REFERENCES GucianStudent ON DELETE CASCADE ON UPDATE cascade,
    FOREIGN KEY(thesisSerialNumber) REFERENCES thesis ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(supid) REFERENCES Supervisor ON DELETE no action ON UPDATE no action

);
Alter table GUCianProgressReport
add description varchar(500)

create TABLE NonGUCianProgressReport (
    sid int,
    no int identity,
    date DATETIME,
    eval VARCHAR(100),
    state VARCHAR(20),
    thesisSerialNumber int,
    supid INT,
    check (eval between 0 and 3),
    PRIMARY KEY(sid,no),
    FOREIGN KEY(sid) REFERENCES NonGucianStudent ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(thesisSerialNumber) REFERENCES thesis ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(supid) REFERENCES Supervisor ON DELETE no action ON UPDATE no action

);
Alter table NonGUCianProgressReport
add description varchar(500)



CREATE TABLE Installment(
    date DATETIME,
    paymentid INT,
    amount DECIMAL(10,2),
    done BIT,
    PRIMARY KEY(date,paymentid),
    FOREIGN KEY(paymentid) REFERENCES Payment ON DELETE CASCADE ON UPDATE CASCADE

);

create table NonGucianStudentPayForCourse(
sid int,
paymentNo int,
cid int,
primary key(sid,cid, paymentNo),
foreign key (sid) references NonGucianStudent on delete cascade on update cascade,
foreign key (paymentNo) references Payment on delete cascade on update cascade,
foreign key (cid) references Course on delete cascade on update cascade
);

create table NonGucianStudentTakeCourse(
sid int,
cid int,
--ask is grade float--
grade decimal,
primary key(sid,cid),
foreign key (sid) references NonGucianStudent on delete cascade on update cascade,
foreign key (cid) references Course on delete cascade on update cascade,
);

create table GUCianStudentRegisterThesis(
sid int,
supid int,
serial_no int,
primary key(sid,supid,serial_no),
foreign key(sid) references GucianStudent on delete cascade on update cascade,
foreign key(supid) references Supervisor on delete no action on update no action,
foreign key(serial_no) references Thesis on delete cascade on update cascade
);
create table NonGUCianStudentRegisterThesis (
sid int,
supid int,
serial_no int,
primary key(sid,supid,serial_no),
foreign key(sid) references NonGucianStudent on delete cascade on update cascade,
foreign key(supid) references Supervisor on delete no action on update no action,
foreign key(serial_no) references Thesis on delete cascade on update cascade
);
create table ExaminerEvaluateDefense(
serialNo int,
date datetime,

examinerId int,
comment varchar(300),
primary key( serialNo,date ,examinerId),
foreign key(serialNo,date ) references Defense on delete cascade on update cascade,
foreign key(examinerId) references Examiner on delete cascade on update cascade
);

create table ThesisHasPublication(
serialNo int,
pubid int,
primary key(serialNo, pubid),
foreign key(serialNo) references Thesis on delete cascade on update cascade,
foreign key(pubid) references Publication on delete cascade on update cascade
); 

