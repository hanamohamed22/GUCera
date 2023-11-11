--User Stories--

---1-a) Register to the website by using my name (First and last name), password, faculty, email, and,address.
go
create proc StudentRegister
@first_name varchar(20),
@last_name varchar(20),
@password varchar(20),
@faculty varchar(20),
@Gucian bit,
@email varchar(50),
@address varchar(50)
as
declare @maxID int
Insert into PostGradUser values (@email,@password)
select @maxID=SCOPE_IDENTITY() 
if (@Gucian=1)
Insert into GucianStudent (id,firstName, lastName,faculty, address)  values (@maxID,@first_name,@last_name,@faculty,@address)
else
Insert into NonGucianStudent (id,firstName, lastName, faculty, address)  values (@maxID,@first_name,@last_name,@faculty,@address)

go
create proc SupervisorRegister
@first_name varchar(20),
@last_name varchar(20),
@password varchar(20),
@faculty varchar(20),
@email varchar(50)
as
declare @maxID int
Insert into PostGradUser values (@email,@password)
set @maxID=SCOPE_IDENTITY() 
Insert into Supervisor (id,name, faculty)  values (@maxID,@first_name+' '+@last_name,@faculty)
go
--2--
--2-a) login using my username and password.--
create proc userLogin
@ID int,
@password varchar(20),
@Success bit output

as 
if ( EXISTS(select id,password from PostGradUser where @ID=id AND @password=password ))
set @Success=1
else
 set @Success=0


--2-b) add my mobile number(s).--
go
create proc addMobile
 @ID int,
 @mobile_number varchar(20)
 As
 if (Exists (select id from GucianStudent where id=@ID))
 begin
 insert into GUCStudentPhoneNumber Values (@ID, @mobile_number)
 end
 else 
  begin
   insert into NonGUCStudentPhoneNumber Values (@ID, @mobile_number)
  end
go

-- 3--
--3-a) List all supervisors in the system.--
go
create proc AdminListSup
As
Select * 
from Supervisor
go
Exec AdminListSup
--3-b)view the profile of any supervisor that contains all his/her information.
go

create proc AdminViewSupervisorProfile
@supId int
As 
select * 
from Supervisor
where id=@supId
go

--3-c)List all Theses in the system
go 
create proc AdminViewAllTheses
As 
select *
from Thesis
go

--3-d)List the number of on going theses

go

create proc AdminViewOnGoingTheses
@thesesCount int output
As
select @thesesCount= count(*)
from Thesis
where endDate>CURRENT_TIMESTAMP
go
Declare @thesesCount int
Exec AdminViewOnGoingTheses @thesesCount output
print @thesesCount

---checkkk time stamp and ask defense date? ---
-- 3-e)List all supervisors names currently supervising students, theses title, student name.
 go
create proc  AdminViewStudentThesisBySupervisor
as
(select Sup.name, T.title, St.firstName, St.lastName
from Supervisor Sup inner join GUCianStudentRegisterThesis GPS on Sup.id=GPS.supid
 inner join Thesis T on T.serialNumber=GPS.serial_no 
 inner join GucianStudent St on St.id=GPS.sid
 where T.endDate>CURRENT_TIMESTAMP
 )
 Union
 (select Sup.name, T.title, St.firstName, St.lastName
from Supervisor Sup inner join NonGUCianStudentRegisterThesis GPS on Sup.id=GPS.supid
 inner join Thesis T on T.serialNumber=GPS.serial_no 
 inner join NonGucianStudent St on St.id=GPS.sid 
 where T.endDate>CURRENT_TIMESTAMP
 )
 go


 --3-f)List nonGucians names, course code, and respective grade.
 go 
 create proc AdminListNonGucianCourse
 @courseID int
 As 
  Select N1.firstName, N1.lastName, C.id, NGSTC.grade
 From NonGucianStudent N1 inner join NonGucianStudentTakeCourse NGSTC on 
 N1.id= NGSTC.sid inner join Course C on NGSTC.cid=C.id 
 where @courseID=NGSTC.cid
 go


--3-g)Update the number of thesis extension by 1.

go 
create proc AdminUpdateExtension
@ThesisSerialNo int
As
Update Thesis
set noExtension= noExtension+1 
where serialNumber=@ThesisSerialNo



--3-h)Issue a thesis payment
go 
create proc AdminIssueThesisPayment
@ThesisSerialNo int,
@amount decimal,
@noOfInstallments int,
@fundPercentage decimal, 
@Success bit output
As
Declare @payid int
set @Success=0
if (Exists (select serialNumber from Thesis where serialNumber=@ThesisSerialNo))
begin
Insert into Payment( amount, no_Installments, fundPercentage) 
values ( @amount,@noOfInstallments ,@fundPercentage) 
set @payid=SCOPE_IDENTITY() 
--Insert into Installment (date, paymentId, amount, done)
--values (CURRENT_TIMESTAMP, @payid,@amount ,@fundPercentage) 
Update Thesis
set payment_id=@payid
where serialNumber=@ThesisSerialNo
set @Success=1
end
go

--3-i)view the profile of any student that contains all his/her information.
GO

CREATE PROC AdminViewStudentProfile
@sid int
AS
if (Exists (select id from GucianStudent where id=@sid))
begin
SELECT * 
from GucianStudent
WHERE id=@sid 
end
else
begin
SELECT * 
from NonGucianStudent
WHERE id=@sid 
end
go

--3-j)Issue installments as per the number of installments for a certain payment 
--every six months starting from the entered date.
 go
CREATE PROC AdminIssueInstallPayment
@paymentID int, 
@InstallStartDate date

--declare @cnt date
--select @cnt= @InstallStartDate;

AS
if (Exists (select id from Payment where id=@paymentID))
begin
declare @cnt date
set @cnt= @InstallStartDate;
declare @noInstallments int , @amounts decimal(10,2)
select @noInstallments= no_Installments , @amounts=amount
from Payment where id=@paymentID
WHILE( @noInstallments>0)
BEGIN
    INSERT into Installment ([date], paymentId, amount, done) VALUES (@cnt,@paymentID,(@amounts/@noInstallments),0) ;
    SET @cnt=DATEADD(month, 6, @cnt);
        set @amounts=@amounts-(@amounts/@noInstallments)
    set @noInstallments=@noInstallments-1;

END;
end
else
print ('ID Not found')
go

--3-k)List the title(s) of accepted publication(s) per thesis.

GO
create PROC AdminListAcceptPublication
AS 
select title
from Publication
WHERE accepted=1
go

--3-l)Add courses and link courses to students.
go 
CREATE PROC AddCourse
@courseCode varchar(10) ,
@creditHrs int,
@fees decimal 
AS 
INSERT INTO Course (fees,creditHours,code) VALUES(@fees,@creditHrs,@courseCode) 

go 
CREATE PROC linkCourseStudent
@courseID int, 
@studentID int
AS
Insert into NonGucianStudentTakeCourse (sid, cid) Values (@studentID,@courseID)

go
CREATE PROC addStudentCourseGrade
@courseID int, 
@studentID int, 
@grade decimal
AS 
Update NonGucianStudentTakeCourse
set grade=@grade
where sid=@studentID and cid=@courseID
go



--3-m)View examiners and supervisor(s) names attending a thesis defense taking place on a certain date.
--union or if and else askk
GO 
CREATE procedure ViewExamSupDefense
@defenseDate datetime
AS
declare @serialno int
select @serialno=serialNumber
from Defense
where [date]=@defenseDate
(
SELECT E.name,S.name
--FROM Examiner E INNER JOIN ExaminerEvaluateDefense EED ON E.id=EED.examinerId, Supervisor S
FROM Examiner E INNER JOIN ExaminerEvaluateDefense EED ON E.id=EED.examinerId 
inner join GUCianStudentRegisterThesis GS on EED.serialNo=GS.serial_no
inner join Supervisor S on S.id=GS.supid
WHERE EED.date=@defenseDate
)
union 
(

SELECT E.name,S.name
--FROM Examiner E INNER JOIN ExaminerEvaluateDefense EED ON E.id=EED.examinerId, Supervisor S
FROM Examiner E INNER JOIN ExaminerEvaluateDefense EED ON E.id=EED.examinerId 
inner join NonGUCianStudentRegisterThesis GS on EED.serialNo=GS.serial_no
inner join Supervisor S on S.id=GS.supid
WHERE EED.date=@defenseDate
)
GO


--4--
--4-a)Evaluate a student’s progress report, and give evaluation value 0 to 3.--
go
create proc EvaluateProgressReport
@supervisorID int, 
@thesisSerialNo int, 
@progressReportNo int, 
@evaluation int
as

if (exists (select thesisSerialNumber from GUCianProgressReport where @thesisSerialNo=thesisSerialNumber))
 begin
UPDATE GUCianProgressReport
set eval=@evaluation
where thesisSerialNumber=@thesisSerialNo and @progressReportNo=[no]
end
else
begin
UPDATE NonGUCianProgressReport
set eval=@evaluation
where thesisSerialNumber=@thesisSerialNo and @progressReportNo=[no]
end
go
--4-b)View all my students’s names and years spent in the thesis--
go
create proc  ViewSupStudentsYears
@supervisorID int
as

(select GS.firstName,GS.lastName , T.years
from Thesis T inner join GUCianStudentRegisterThesis GSRT on T.serialNumber=GSRT.serial_no inner join GucianStudent GS 
on GSRT.sid=GS.id
where supid=@supervisorID)
Union
(select GS.firstName,GS.lastName ,T.years
from Thesis T inner join NonGUCianStudentRegisterThesis GSRT on T.serialNumber=GSRT.serial_no inner join NonGucianStudent GS 
on GSRT.sid=GS.id
 where supid=@supervisorID)

go
---4-c)View my profile and update my personal information.--

 go
 create proc SupViewProfile
 @supervisorID int
 as
 select *
 from Supervisor
 where id=@supervisorID
 go
 create proc UpdateSupProfile
 @supervisorID int, 
 @name varchar(20), 
 @faculty varchar(20)
 as
 Update Supervisor
 set name=@name, faculty=@faculty
 where id=@supervisorID
 go
--4-d)View all publications of a student.--
go
create proc ViewAStudentPublications
@StudentID int
as
if (Exists( select id from GucianStudent where id=@StudentID))
begin
select P.*
from Publication P inner join ThesisHasPublication THP on P.id=THP.pubid
inner join Thesis T on THP.serialNo=T.serialNumber inner join 
GUCianStudentRegisterThesis GSRT on T.serialNumber=GSRT.serial_no
where GSRT.sid=@StudentID
end
else
begin
select P.*
from Publication P inner join ThesisHasPublication THP on P.id=THP.pubid
inner join Thesis T on THP.serialNo=T.serialNumber inner join 
NonGUCianStudentRegisterThesis GSRT on T.serialNumber=GSRT.serial_no
where GSRT.sid=@StudentID
end

go
--4-e)Add defense for a thesis, for nonGucian students all courses’ grades should be greater than 50percent.--
create proc AddDefenseGucian
@ThesisSerialNo int , 
@DefenseDate Datetime , 
@DefenseLocation varchar(15)
as
insert into Defense (serialNumber, date, location) values
(@ThesisSerialNo , @DefenseDate,@DefenseLocation)
Update Thesis
set defenseDate=@DefenseDate
where serialNumber=@ThesisSerialNo

go

create proc AddDefenseNonGucian
@ThesisSerialNo int , 
@DefenseDate Datetime , 
@DefenseLocation varchar(15)
as
if (not exists( select * from NonGucianStudentTakeCourse NGTC inner join
NonGUCianStudentRegisterThesis NGSRT on NGTC.sid=NGSRT.sid 
where NGSRT.serial_no=@ThesisSerialNo and   NGTC.grade<=50))
begin
insert into Defense (serialNumber, date, location) values
(@ThesisSerialNo , @DefenseDate,@DefenseLocation)
Update Thesis
set defenseDate=@DefenseDate
where serialNumber=@ThesisSerialNo
end
go

--4-f)Add examiner(s) for a defense--
go
create proc AddExaminer
@ThesisSerialNo int ,
@DefenseDate Datetime , 
@ExaminerName varchar(20), 
@National bit, 
@fieldOfWork varchar(20)
as
declare @ExaminerID int
declare @maximumID int
insert into PostGradUser (email,password) values (null,null)
set @ExaminerID=SCOPE_IDENTITY()
insert into Examiner (id, name, fieldOfWork, isNational ) values 
(@ExaminerID,@ExaminerName,@fieldOfWork,@National)
--@ExaminerName=name and @fieldOfWork=fieldOfWork and @National=isNational
insert into ExaminerEvaluateDefense(serialNo,[date], examinerId) values
(@ThesisSerialNo,@DefenseDate,@ExaminerID)
go

--4-g)Cancel a Thesis if the evaluation of the last progress report is zero.--
go
create proc CancelThesis
@ThesisSerialNo int
as
declare @latestdate date
declare @latestgrade decimal
if (EXISTS (select serial_no 
from GUCianStudentRegisterThesis where serial_no=@ThesisSerialNo))
begin
select @latestdate=max([date])
from GUCianProgressReport where thesisSerialNumber=@ThesisSerialNo 

select @latestgrade=eval
from GUCianProgressReport
where thesisSerialNumber=@ThesisSerialNo and [date]=@latestdate

if (@latestgrade=0)
begin
delete from GUCianStudentRegisterThesis
where serial_no=@ThesisSerialNo
end
end
else
begin
select @latestdate=max([date])
from NonGUCianProgressReport where thesisSerialNumber=@ThesisSerialNo 
select @latestgrade=eval
from NonGUCianProgressReport
where thesisSerialNumber=@ThesisSerialNo and [date]=@latestdate
if (@latestgrade=0)
begin
delete from NonGUCianStudentRegisterThesis
where serial_no=@ThesisSerialNo
end
end
go
---4-h)- Add a grade for a thesis.--

CREATE PROC AddGrade
@ThesisSerialNo int ,
@grade decimal
AS 
UPDATE Thesis
SET grade = @grade
WHERE serialNumber=@ThesisSerialNo



--5--
---5-a) Add grade for a defense.--
go 
create proc AddDefenseGrade
@ThesisSerialNo int , 
@DefenseDate Datetime , 
@grade decimal
as
update Defense
set grade = @grade
where serialNumber=@ThesisSerialNo and [date]=@DefenseDate
--5-b)Add comments for a defense.--
go 
create proc AddCommentsGrade
@ThesisSerialNo int , 
@DefenseDate Datetime , 
@comments varchar(300)
as 
Update  ExaminerEvaluateDefense
set comment =@comments
where [date]=@DefenseDate and serialNo=@ThesisSerialNo
--6--
--6-a)View my profile that contains all my information.
go
Create procedure viewMyProfile
@studentId int
As
if (Exists (select id from GucianStudent where @studentId=id ))

select * from GucianStudent G where @studentId=id 

else
select * from NonGucianStudent where @studentId=id 
go

Exec viewMyProfile 1
--6-b)Edit my profile (change any of my personal information)--
go
create  procedure editMyProfile
@studentID int, 
@firstName varchar(10), 
@lastName varchar(10), 
@password varchar(10), 
@email varchar(10), 
@address varchar(10), 
@type varchar(10)
as
Update PostGradUser
set email=@email,
password=@password
where id=@studentID
if (Exists (select id from GucianStudent where @studentId=id ))
begin
Update GucianStudent
set firstName=@firstName,
 lastName=@lastName,
 address=@address,
 type=@type
where id=@studentID
end
else
begin
Update NonGucianStudent
set firstName=@firstName,
 lastName=@lastName,
 address=@address,
 type=@type
where id=@studentID
end

go
-- 6-c)As a Gucian graduate, add my undergarduate ID--

create proc addUndergradID
@studentID int,
@undergradID varchar(10)
as
Update GucianStudent
set undergradID=@undergradID
where id=@studentID

go
--6-d) As a nonGucian student, view my courses’ grades--
create proc ViewCoursesGrades
@studentID int
as
Select sid as studentID,cid as CourseID , grade as Grade
from NonGucianStudentTakeCourse
where sid=@studentID

go
--6-e) View all my payments and installments.--
--try to rxecute register for thesis
create  proc ViewCoursePaymentsInstall
@studentID int
as
select P.* , I.*
from NonGucianStudentPayForCourse NGS inner join Payment P on NGS.paymentNo=P.id inner join Installment I ON I.paymentid=P.id
where NGS.sid=@studentID

go
create proc ViewThesisPaymentsInstall
@studentID int
as
if (Exists (select id from GucianStudent where @studentId=id ))
begin
select P.*,I.*
from GUCianStudentRegisterThesis GS inner join Thesis T  on GS.serial_no=T.serialNumber inner join Payment P on T.payment_id=P.id inner join Installment I ON I.paymentid=P.id
where sid=@studentID
end
else
begin
select P.*,I.*
from NonGUCianStudentRegisterThesis GS inner join Thesis T  on GS.serial_no=T.serialNumber inner join Payment P on T.payment_id=P.id inner join Installment I ON I.paymentid=P.id
where sid=@studentID
end
go

create  proc ViewUpcomingInstallments
@studentID int
as
if (Exists (select id from GucianStudent where @studentId=id ))
begin
select I.*
from GUCianStudentRegisterThesis GS inner join Thesis T  on GS.serial_no=T.serialNumber inner join Payment P on T.payment_id=P.id inner join Installment I ON I.paymentid=P.id
where sid=@studentID and I.date>CURRENT_TIMESTAMP
end
else
begin

(select I.*
from NonGucianStudentPayForCourse NGS inner join Payment P on NGS.paymentNo=P.id inner join Installment I ON I.paymentid=P.id
where NGS.sid=@studentID and I.date>CURRENT_TIMESTAMP)
union
(select I.*
from NonGUCianStudentRegisterThesis GS inner join Thesis T  on GS.serial_no=T.serialNumber inner join Payment P on T.payment_id=P.id inner join Installment I ON I.paymentid=P.id
where sid=@studentID and  I.date>CURRENT_TIMESTAMP
)
end
go

 --ask 3ala current time stamp--
create  proc ViewMissedInstallments
@studentID int
as
if (Exists (select id from GucianStudent where @studentId=id ))
begin
select I.*
from GUCianStudentRegisterThesis GS inner join Thesis T  on GS.serial_no=T.serialNumber inner join Payment P on T.payment_id=P.id inner join Installment I ON I.paymentid=P.id
where sid=@studentID and I.date<CURRENT_TIMESTAMP and done='0'
end
else
begin

(select I.*
from NonGucianStudentPayForCourse NGS inner join Payment P on NGS.paymentNo=P.id inner join Installment I ON I.paymentid=P.id
where NGS.sid=@studentID and I.date<CURRENT_TIMESTAMP and I.done ='0')
union
(select I.*
from NonGUCianStudentRegisterThesis GS inner join Thesis T  on GS.serial_no=T.serialNumber inner join Payment P on T.payment_id=P.id inner join Installment I ON I.paymentid=P.id
where sid=@studentID and  I.date<CURRENT_TIMESTAMP and I.done='0'
)
end
go
--6-f) Add and fill my progress report(s).--
create proc AddProgressReport
@thesisSerialNo int, 
@progressReportDate date

as
declare @id1 int, @sup int
if (Exists (select serial_no from GUCianStudentRegisterThesis where serial_no=@thesisSerialNo))
BEGIN
select @id1=sid,@sup=supid from GUCianStudentRegisterThesis where serial_no=@thesisSerialNo
insert into GUCianProgressReport (sid,  date,thesisSerialNumber, supid) values (@id1,@progressReportDate,@thesisSerialNo,@sup)
end
else
begin
select @id1=sid,@sup=supid from NonGUCianStudentRegisterThesis where serial_no=@thesisSerialNo
insert into NonGUCianProgressReport (sid,  date,thesisSerialNumber, supid) values (@id1,@progressReportDate,@thesisSerialNo,@sup)
end

go 
create proc  FillProgressReport
@thesisSerialNo int,
@progressReportNo int, 
@state int, 
@description varchar(200)
as
declare @id1 int, @sup int
if (Exists (select serial_no from GUCianStudentRegisterThesis where serial_no=@thesisSerialNo))
BEGIN
UPDATE GUCianProgressReport
SET [state]=@state, description=@description
WHERE thesisSerialNumber=@thesisSerialNo and [no]=@progressReportNo
END

ELSE
BEGIN
UPDATE NonGUCianProgressReport
SET [state]=@state, description=@description
WHERE thesisSerialNumber=@thesisSerialNo and [no]=@progressReportNo
END
GO

--
--6-g)View my progress report(s) evaluations.--
go
create proc ViewEvalProgressReport
@thesisSerialNo int, 
@progressReportNo int
as
if (Exists (select thesisSerialNumber from GUCianProgressReport where thesisSerialNumber=@thesisSerialNo ))
begin
SELECT GPR.eval
from GUCianProgressReport GPR
WHERE GPR.thesisSerialNumber=@thesisSerialNo and GPR.[no]=@progressReportNo
end
else
BEGIN
SELECT NGPR.eval
from NonGUCianProgressReport NGPR
WHERE NGPR.thesisSerialNumber=@thesisSerialNo and NGPR.[no]=@progressReportNo
end
go

EXECUTE ViewEvalProgressReport 37,1
go
--6-h)Add publication.--
create proc  addPublication
@title varchar(50), 
@pubDate datetime, 
@host varchar(50), 
@place varchar(50), 
@accepted bit
as
insert into Publication( title, date, place, accepted, host) 
values (@title,@pubDate,@place,@accepted,@host)

go
--6-i)Link publication to my thesis.--
create proc linkPubThesis
@PubID int, 
@thesisSerialNo int
as
insert into ThesisHasPublication (serialNo,pubid)
 values (@thesisSerialNo,@PubID)


