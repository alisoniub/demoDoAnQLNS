const { Accounts, Employees, Salary, Jobs, Attendances } = require('./models');
const shortid = require('shortid');

// Define controller functions
const employeeController = {
    getEmployeeById: async (req, res) => {
    const employeeID = req.params.id;
    try {
        // Chỉ lấy thông tin cơ bản của nhân viên, không bao gồm dữ liệu nhị phân của hình ảnh
        const employee = await Employees.findOne({ _id: employeeID }).select('-avt.imageBinary.data');

        if (!employee) {
        return res.status(404).json({ error: 'Employee not found' }); // Trả về lỗi nếu không tìm thấy nhân viên
        }
        
        res.json(employee);
    } catch (error) {
        console.error('Error fetching employee info:', error);
        res.status(500).json({ error: 'Internal server error' });
    }      
    },
    updatePhoneNumber: async (req, res) => {
      const employeeID = req.params.id;
      const { phoneNumber } = req.body; 
    
      try {
        const updatedEmployee = await Employees.findOneAndUpdate(
          { _id: employeeID },
          { $set: { phoneNumber: phoneNumber } },
          { new: true } 
        );
    
        if (!updatedEmployee) {
          return res.status(404).json({ error: 'Employee not found' });
        }
    
        console.log(`Updated phone number of employee with ID ${employeeID}`);
        res.sendStatus(200);
      } catch (error) {
        console.error('Error updating phone number:', error);
        res.sendStatus(500); 
      }
    },
    updateEmail: async (req, res) => {
        const employeeID = req.params.id;
        const { email } = req.body;
    
        // Kiểm tra email có hợp lệ không (chứa dấu @)
        if (!isEmailValid(email)) {
          return res.status(400).json({ error: 'Email không hợp lệ' });
        }
    
        try {
          // Tìm và cập nhật thông tin email của nhân viên có _id tương ứng
          const updatedEmployee = await Employees.findOneAndUpdate(
            { _id: employeeID },
            { $set: { email: email } },
            { new: true } // Trả về bản ghi sau khi được cập nhật
          );
    
          if (!updatedEmployee) {
            return res.status(404).json({ error: 'Employee not found' });
          }
    
          console.log(`Updated email of employee with ID ${employeeID}`);
          res.sendStatus(200); // Trả về mã thành công 200
        } catch (error) {
          console.error('Error updating email:', error);
          res.sendStatus(500); // Trả về mã lỗi 500 nếu có lỗi xảy ra
        }
    },
    getEmployeeList: async(req, res) =>{
        try {
            const employees = await Employees.find(); // Lấy thông tin của tất cả nhân viên
            res.json(employees);
          } catch (error) {
            console.error('Error fetching employee info:', error);
            res.status(500).json({ error: 'Internal server error' });
          }
        
    },
    addEmployee: async(req, res) =>{
        try {
            const { _id, firstName, lastName, phoneNumber, idDepartment} = req.body;
            const newEmployeeData = {
              _id: _id,
              firstName: firstName,
              lastName: lastName,
              phoneNumber: phoneNumber,
              idDepartment: idDepartment
            };
            const newEmployee = new Employees(newEmployeeData);
            await newEmployee.save();
            res.json(newEmployee);
          } catch (error) {
            console.error('Error adding employee:', error);
            res.status(500).json({ error: error.message });
          }        
    },
    editEmployee: async(req, res) =>{
        const employeeID = req.params.id;
        const updatedData = req.body; // Dữ liệu mới của nhân viên được gửi từ phía clienta
      
        try {
          const updatedEmployee = await Employees.findOneAndUpdate({ _id: employeeID }, updatedData, { new: true });
          if (!updatedEmployee) {
            return res.status(404).json({ error: 'Employee not found' });
          }
          res.json({ success: true, message: 'Employee updated successfully', employee: updatedEmployee });
        } catch (error) {
          console.error('Error updating employee:', error);
          res.status(500).json({ error: 'Internal server error' });
        }      
    },
    deleteEmployee: async(req, res) =>{
        const employeeID = req.params.id;
        try {
          const deletedEmployee = await Employees.findOneAndDelete({ _id: employeeID });
          if (!deletedEmployee) {
            return res.status(404).json({ error: 'Employee not found' });
          }
          res.json({ success: true, message: 'Employee deleted successfully' });
        } catch (error) {
          console.error('Error deleting employee:', error);
          res.status(500).json({ error: 'Internal server error' });
        }      
    },
    getAvt: async (req, res) => {
        try {
            const employees = await Employees.find().select('avt.imageName'); 
            res.json(employees);
          } catch (error) {
            console.error('Error fetching employee info:', error);
            res.status(500).json({ error: 'Internal server error' });
          }
    },
};
const accountController = {
    checkLogin: async (req, res) => {
        const { _idController, _passwordController } = req.body;
        try {
            // Tìm tài khoản trong bộ sưu tập "Accounts" có các trường "_id" và "password" khớp với dữ liệu được gửi từ Flutter
            const account = await Accounts.findOne({ _id: _idController, password: _passwordController });
    
            if (account) {
                const employeeID = account._id;
                // Tìm nhân viên trong bộ sưu tập "Employees" có _id trùng khớp với _id của tài khoản
                const employee = await Employees.findOne({ _id: employeeID });
    
                if (employee) {
                    // Trả về thông tin của nhân viên đã đăng nhập thành công
                    res.status(200).json({ success: true, message: 'Login successful', 
                        firstName: employee.firstName,
                        lastName: employee.lastName, 
                        //employeeImage: employee.avt, 
                        employeeID: account.employeeID,
                        email: employee.email, 
                        id: employee._id });
                } else {
                    // Không tìm thấy thông tin nhân viên tương ứng với tài khoản
                    res.status(401).json({ success: false, message: 'Employee information not found' });
                }
            } else {
                res.status(401).json({ success: false, message: 'Incorrect username or password' });
            }
        } catch (error) {
            console.error('Login failed:', error);
            res.status(500).json({ success: false, message: 'An error occurred while logging in' });
        }    
    },    
    editPassword: async (req, res) => {
        const employeeID = req.params.employeeID; // Lấy mã nhân viên từ params
        const { newPassword } = req.body; // Lấy mật khẩu mới từ body của yêu cầu
      
        try {
          // Tìm và cập nhật mật khẩu của nhân viên có mã nhân viên tương ứng
          const updatedAccount = await Accounts.findOneAndUpdate(
            { employeeID: employeeID },
            { $set: { password: newPassword } },
            { new: true } // Trả về bản ghi sau khi được cập nhật
          );
      
          if (!updatedAccount) {
            // Nếu không tìm thấy nhân viên, trả về lỗi 404
            return res.status(404).json({ error: 'Employee account not found' });
          }
          // Trả về thông báo thành công và thông tin tài khoản đã được cập nhật
          res.status(200).json({ success: true, message: 'Password updated successfully', account: updatedAccount });
        } catch (error) {
          // Nếu có lỗi xảy ra trong quá trình cập nhật, trả về lỗi 500
          console.error('Error updating password:', error);
          res.status(500).json({ error: 'Internal server error' });
        }      
    },
    getAccountDetail: async (req, res) => {
        const { employeeID } = req.body;
        try {
          const account = await Accounts.findOne({ employeeID });
          if (account) {
            res.status(200).json({ id: account._id, password: account.password });
          } else {
            res.status(404).json({ message: 'Account not found' });
          }
        } catch (error) {
          res.status(500).json({ message: 'Internal server error' });
        }      
    },
    authenticateAndAuthorize: async (req, res) => {
      const authenticateAndAuthorize = async (req, res, next) => {
          const { id } = req.params;

          try {
              const account = await Accounts.findOne({ _id: id });

              if (account && account._id === 'nv001') {
                  next();
              } else {
                  res.status(403).json({ success: false, message: 'Bạn không có quyền thực hiện hành động này' });
              }
          } catch (error) {
              console.error('Lỗi xác thực và phân quyền:', error);
              res.status(500).json({ success: false, message: 'Đã xảy ra lỗi trong quá trình xác thực và phân quyền' });
          }
      };

      // Áp dụng hàm authenticateAndAuthorize khi có yêu cầu
      authenticateAndAuthorize(req, res, () => {
          // Xử lý khi xác thực và phân quyền thành công
          res.status(200).json({ success: true, message: 'Yêu cầu đã được xác thực và phân quyền thành công' });
      });
  }
};
const salaryController = {
    getSalary: async (req, res) => {
        try {
            const { id } = req.params; // Lấy id từ params
            //const { employeeID } = req.body; // Lấy employeeID từ body
        
            if (id === 'nv001') {
              // Nếu là admin, trả về danh sách bảng lương của tất cả nhân viên
              const salaryRecords = await Salary.find();
              res.json(salaryRecords);
            } else {
              // Nếu là nhân viên, chỉ trả về bảng lương của họ
              const salaryRecord = await Salary.findOne({employeeID: id});
              if (salaryRecord) {
                res.json(salaryRecord);
              } else {
                res.status(404).json({ error: 'Salary record not found' });
              }
            }
          } catch (error) {
            console.error('Error fetching salary record:', error);
            res.status(500).json({ error: 'Internal server error' });
          }          
    },
};
const jobController = {
    getJobs: async (req, res) => {
        try {
            const jobs = await Jobs.find(); // Lấy thông tin của tất cả công việc
            res.json(jobs);
          } catch (error) {
            console.error('Error fetching jobs info:', error);
            res.status(500).json({ error: 'Internal server error' });
          }            
    },
    getJobsByEmployeeId: async (req, res) => {
        const employeeID = req.params.id;
        try {
            // Tìm tất cả các công việc trong collection "Jobs" mà nhân viên có employeeID phụ trách
            const jobs = await Jobs.find({ employeeID: employeeID });
            if (jobs.length > 0) {
            // Nếu tìm thấy công việc, trả về danh sách công việc
            res.json(jobs);
            } else {
            // Nếu không tìm thấy công việc cho nhân viên này
            res.status(404).json({ error: 'No jobs found for this employee' });
            }
        } catch (error) {
            console.error('Error fetching jobs:', error);
            res.status(500).json({ error: 'Internal server error' });
        }
    },
};
const attendanceController = {
    getAttendanceId: async (req, res) => {
        try {
            const id = req.params.id; 
        
            // Truy vấn tất cả các bản ghi chấm công của nhân viên có id
            const attendances = await Attendances.find({ employeeID: id });
        
            // Kiểm tra nếu không có bản ghi nào được tìm thấy
            if (!attendances || attendances.length === 0) {
              return res.status(404).json({ message: 'Không có dữ liệu chấm công' });
            }
        
            // Trả về danh sách chấm công
            res.status(200).json({ attendances: attendances });
          } catch (error) {
            console.error('Lỗi khi lấy danh sách chấm công:', error);
            res.status(500).json({ error: 'Lỗi máy chủ nội bộ' });
          }         
    },
    getAttendanceCount: async (req, res) => {
        try {
            const id = req.params.id; // Lấy id nhân viên từ params
            const currentDate = req.query.currentDate; // Lấy ngày cần tra cứu từ query params
    
            if (!currentDate) {
                return res.status(400).json({ error: 'Thiếu thông tin ngày' });
            }
    
            // Tạo đối tượng Date từ ngày cần tra cứu
            const formattedDate = new Date(currentDate);
    
            if (isNaN(formattedDate.getTime())) {
                return res.status(400).json({ error: 'Ngày không hợp lệ' });
            }
    
            // Đặt giá trị giờ, phút, giây và mili-giây của ngày thành 0 để có thời gian bắt đầu của ngày
            const startOfDay = new Date(formattedDate);
            startOfDay.setHours(0, 0, 0, 0);
    
            // Đặt giá trị giờ, phút, giây và mili-giây của ngày thành 23:59:59.999 để có thời gian kết thúc của ngày
            const endOfDay = new Date(formattedDate);
            endOfDay.setHours(23, 59, 59, 999);
    
            // Đếm số lần chấm công của nhân viên có id cho ngày currentDate
            const count = await Attendances.countDocuments({
                employeeID: id,
                date: { $gte: startOfDay, $lte: endOfDay }
            });
    
            res.status(200).json({ count: count });
        } catch (error) {
            console.error('Lỗi khi lấy số lần chấm công:', error);
            res.status(500).json({ error: 'Lỗi máy chủ nội bộ' });
        }
    },
    addAttendance: async (req, res) => {
        try {
            const { employeeID, status } = req.body;
            const currentTime = new Date().toLocaleTimeString('en-US', { hour12: false });
            const randomString = shortid.generate();
            const attendance = new Attendances({
                _id: `${employeeID}_${randomString}`,
                employeeID,
                date: new Date(), // Lưu trữ ngày hiện tại
                time: currentTime,
            });
            await attendance.save();
            res.status(201).json(attendance);
        } catch (error) {
            res.status(500).json({ error: error.message });
        }        
    },
    getAttendanceInDate: async (req, res) => {
        try {
            const { id, date } = req.params;
            const markedAttendance = await Attendances.find({ id: id, date: date });
            res.status(200).json(markedAttendance);
          } catch (error) {
            console.error('Failed to fetch marked attendance:', error);
            res.status(500).json({ message: 'Failed to fetch marked attendance' }); // Send error response if an error occurs
          }
    },
};
module.exports = {
  employeeController,
  accountController,
  salaryController,
  jobController,
  attendanceController,
  // Other controllers...
};
