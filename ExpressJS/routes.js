const express = require('express');
const { employeeController, salaryController, attendanceController,jobController,accountController } = require('./controllers');
// const { accountController } = require('./controllers');
const router = express.Router();

// Define Employee
router.get('/employee/:id', employeeController.getEmployeeById);
router.put('/updatePhoneNumber/:id', employeeController.updatePhoneNumber);
router.put('/updateEmail/:id', employeeController.updateEmail);
router.get('/employees/list',employeeController.getEmployeeList);
router.post('/employee/add',employeeController.addEmployee);
router.put('/employee/update/:id',employeeController.editEmployee);
router.delete('/employee/delete/:id',employeeController.deleteEmployee);
router.get('/avt',employeeController.getAvt);

//Accounts
router.put('/accounts/updatePassword/:employeeID',accountController.editPassword);
router.post('/get_account_details',accountController.getAccountDetail);
router.post('/login',accountController.checkLogin);
router.post('/authenticate/:id', accountController.authenticateAndAuthorize);

//Salary
router.get('/salary/:id',salaryController.getSalary);

//Jobs
//Lấy danh sách công việc của một nhân viên dựa trên id
router.get('/jobs/:id', jobController.getJobsByEmployeeId);
//Lấy danh sách công việc 
router.get('/jobslist', jobController.getJobs);

//Attendance
// Truy vấn tất cả các bản ghi chấm công của nhân viên có id
router.get('/attendancelist/:id',attendanceController.getAttendanceId);
router.get('/attendance/count/:id',attendanceController.getAttendanceCount);
router.post('/attendance/add',attendanceController.addAttendance);
//router.get('/api/attendance/:id/date',attendanceController.getAttendanceInDate);
module.exports = router;
