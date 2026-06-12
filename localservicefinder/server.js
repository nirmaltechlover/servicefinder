const express = require("express");
const mysql = require("mysql2");
const cors = require("cors");
require("dotenv").config();

const app = express();

app.use(cors());

app.use(express.static("public"));

const db = mysql.createConnection({

 host: process.env.DB_HOST,
 user: process.env.DB_USER,
 password: process.env.DB_PASSWORD,
 database: process.env.DB_NAME

});

db.connect((err)=>{

 if(err){

   console.log(err);

 }else{

   console.log("MySQL Connected");

 }

});

app.get("/providers",(req,res)=>{

 const city = req.query.city;
 const service = req.query.service;

 let sql =
 "SELECT * FROM providers WHERE 1=1";

 let params = [];

 if(city){

   sql += " AND city = ?";
   params.push(city);

 }

 if(service){

   sql += " AND service_type = ?";
   params.push(service);

 }

 db.query(sql,params,(err,result)=>{

   if(err){

     return res.status(500).json(err);

   }

   res.json(result);

 });

});

app.get("/cities",(req,res)=>{

 db.query(
  "SELECT DISTINCT city FROM providers",
  (err,result)=>{

   if(err){

    return res.status(500).json(err);

   }

   res.json(result);

 });

});

app.get("/services",(req,res)=>{

 db.query(
  "SELECT DISTINCT service_type FROM providers",
  (err,result)=>{

   if(err){

    return res.status(500).json(err);

   }

   res.json(result);

 });

});

app.listen(process.env.PORT,()=>{

 console.log(
  `Server Running On Port ${process.env.PORT}`
 );

});
