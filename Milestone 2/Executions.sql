--Executions
--1--
Exec StudentRegister 'Dana', 'Shehab', '123','Business',0,'dana@gmail.com','Heliopolis'
Exec SupervisorRegister 'Remon', 'Simon' ,'123','MET','remon@gucmail.com'
--2--
Declare @Success bit
Exec userLogin 1, '123',@Success output
print @Success
Exec addMobile 4 , '012345678'
Exec addMobile 16, '01234555666'
select * from GUCStudentPhoneNumber
--3--
Exec AdminListSup
Exec AdminViewSupervisorProfile 13
Exec AdminViewAllTheses
declare @thesesCount int
Exec AdminViewOnGoingTheses @thesesCount output
print @thesesCount
select * from GUCianStudentRegisterThesis
Exec AdminViewStudentThesisBySupervisor
select * from GUCianStudentRegisterThesis
select * from NonGUCianStudentRegisterThesis
Exec AdminListNonGucianCourse 1 
Exec AdminUpdateExtension 6
Declare @Success bit
Exec AdminIssueThesisPayment 3,5000,2,10,@Success output
print @Success
Declare @Success bit
Exec AdminIssueThesisPayment 6,2000,4,10,@Success output
print @Success
Exec AdminViewStudentProfile 2
Exec AdminViewStudentProfile 7
Exec AdminIssueInstallPayment 10, '1/1/2022'
Exec AdminListAcceptPublication
Exec AddCourse 'DMET',4,700
Exec linkCourseStudent 7 , 7
select * from Defense
Exec addStudentCourseGrade 2, 6 , 1
Exec ViewExamSupDefense '6/6/2022'

--4--
--ask about a)
select * from Supervisor
select * from GUCianStudentRegisterThesis
select * from NonGUCianStudentRegisterThesis
select * from Thesis
Exec EvaluateProgressReport 12,6,2,0
Exec ViewSupStudentsYears 10
Exec SupViewProfile 13
Exec UpdateSupProfile 13 , 'Ramy younes', 'Mathematics'
Exec ViewAStudentPublications 7
Exec AddDefenseGucian 4 , '2/2/2024','H12'
Exec AddDefenseNonGucian 5, '2/2/2024', 'H13'
select * from NonGucianStudentTakeCourse
select * from NonGUCianStudentRegisterThesis
select * from Thesis
select * from Defense
select * from Examiner
Exec  AddExaminer 5,'2/2/2024','Alex',1,'Business'
select * from GUCianProgressReport
Exec  CancelThesis 3
EXEC AddGrade 6 , 94
select * from Thesis
--5--
exec AddDefenseGrade 5,'2/2/2024',76
select * from Defense

exec AddCommentsGrade 5,'2/2/2024','Great job!'
select * from ExaminerEvaluateDefense
--6--
execute viewMyProfile 2

execute editMyProfile 2,'Shahinoz','Zaghloul','82289','shahinaz@gmail.com','sheraton','Masters'
exec addUndergradID 4 , '49-2127'
Exec ViewCoursesGrades 6
select * from NonGucianStudentTakeCourse
select * from Payment
select * from Course
select * from Installment
select * from NonGucianStudentPayForCourse
Exec ViewCoursePaymentsInstall 6
Exec ViewThesisPaymentsInstall 7
select * from Thesis
select * from NonGUCianStudentRegisterThesis
select * from NonGucianStudentPayForCourse
Exec ViewUpcomingInstallments 7
Exec ViewMissedInstallments 6
Exec AddProgressReport 5, '2/2/2021'
Exec AddProgressReport 4, '2/2/2021'
Exec FillProgressReport 4,5,1,'This report sums up the idea of the thesis'
Exec FillProgressReport 5,9,1,'This report sums up the idea of the thesis'
Exec ViewEvalProgressReport 6,1
Exec ViewEvalProgressReport 3,2
Exec addPublication 'Light','12/19/2021','Harry','London','1'
Exec addPublication 'Darkness','12/19/2021','Harry','London','1'

Exec linkPubThesis 4, 5
