const mongoose = require('mongoose');
const shortid = require('shortid');

// Define schema for "Accounts" collection
const accountSchema = new mongoose.Schema({
  _id: String,
  password: String,
  employeeID: String
});

// Define schema for "Employees" collection
const employeeSchema = new mongoose.Schema({
  _id: String,
  firstName: String,
  lastName: String,
  dateOfBirth: Date,
  phoneNumber: String,
  position: String,
  email: String,
  idDepartment: String,
  avt: {
    imageName: String,
    imageBinary: String,
  }
});

// Define schema for "Salary" collection
const salarySchema = new mongoose.Schema({
  _id: String,
  employeeID: String,
  basicSalary: Number, 
  allowances: Number, 
  deductions: Number, 
  netSalary: Number, 
  issueDate: Date,
  paymentDate: Date, 
});

// Define schema for "Jobs" collection
const jobSchema = new mongoose.Schema({
  _id: String,
  jobName: String,
  startDate: Date,
  endDate: Date,
  employeeID: String,
  note: String,
});

// Define schema for "Attendance" collection
const attendanceSchema = new mongoose.Schema({
  _id: { type: String, unique: false },
  employeeID: String,
  date: Date,
  time: String,
  status: Number,
});

// Create models from schemas
const Accounts = mongoose.model('Accounts', accountSchema, 'Accounts');
const Employees = mongoose.model('Employees', employeeSchema, 'Employees');
const Salary = mongoose.model('Salary', salarySchema, 'Salary');
const Jobs = mongoose.model('Jobs', jobSchema, 'Jobs');
const Attendances = mongoose.model('Attendance', attendanceSchema);

module.exports = {
  Accounts,
  Employees,
  Salary,
  Jobs,
  Attendances,
};
