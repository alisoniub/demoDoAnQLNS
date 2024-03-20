const express = require('express')
const app = express()
const port = process.env.PORT || 3000;
const mongoose = require('mongoose')
const bodyParser = require('body-parser');
const multer = require('multer');
const { Buffer } = require('buffer'); 
const fs = require('fs');
const path = require('path');
const shortid = require('shortid');
const routes = require('./routes');


app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
    next();
  });
  
// Kết nối MongoDB
mongoose.connect('mongodb://localhost:27017/hrminfo', {
  useNewUrlParser: true,
  useUnifiedTopology: true
})
.then(() => console.log('Connected to MongoDB'))
.catch(err => console.error('Could not connect to MongoDB', err));
// Xử lý lỗi kết nối MongoDB
mongoose.connection.on('error', err => {
  console.error('MongoDB connection error:', err);
});
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


// Route requests to routes.js
app.use('/api', routes);

// Start the server
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
