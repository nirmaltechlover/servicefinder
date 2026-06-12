## Project- Service finder within City ##Devops##Cloud-Azure## Terraform##Nodejs ##Express

I worked on a Tier-1 Webapplication project local service finder within city . So Bascially user open application url and search service(electrician , plumber ) within city and get the service providers details.

I deployed this web application on Cloud Azure VM using html/css/java script for Front-end, node.js with express for Back-end main logic and APIs as well as mysql for database.

Tier-1 = All three layers front-end,back-end & database on single same Azure vm

Application Techs user:-
1-Hosting Server=> Azure vm with public ip (No Load Balancer)
2-VM OS=> Ubuntu 24.04 lts
3-Front-end=> html, css, javascript(app.js)(front-end logic)==> Front-end will be served by nodejs public/index.html public/style.css public/app.js
4-Back-end => node.js with express ===> server.js
5-Database=> Mysql  
6-nginx as reverse proxy only not front-end
 
Application Flow=>
User request ==> domain (https://nirmal.blog)(Browser)==> mapped to Azure Public vm==> Azure vm ===>nginx server (port-80 ,443)==>proxy pass to vm public ip:3000/(node js server) ==>node js server will server public folder files to front-end(index.html,style.css,app.js)
at this point of time user will get front-end page====> user search service under city ===> app.js activate and call to back-end API /providers /service /cities ==> Back-end receive API request from front-end
Back-end connects to database and ask for data===> mysql retrun the data ===> Back-end will return the result in json format to front-end===> Finally front-end will display the result


Infracture Setup=>
1- Resource group(localservicefinder)
2-Storage account
3-Networking vnet with subnet
4-Network security group
5-Network Interface card
6-VM with public ip
7-OS ubuntu 24.04 Lts

I used terraform codes to create whole infracture on Azure .... 

2-Middle ware setup ==>
-nginx for reverse proxy
-nodejs & npm for back-end
-mysql for database
-front-end will be also handled by nodejs via providing public/index.html public/style.css  public/app.js

I used provisioners block to setup for above required packages ..

3- Project setup(codes)

created project directory == mkdir localservicefinder

then created a another directory inside main directory localservicefinder=== cd /localservicefinder && mkdir public(for front-end serving files)

then created files index.html , style.css & app.js inside public === cd /public && touch index.html style.css app.js

then created 2 files == touch .env (for database connection details) && touch server.js(back-end server file)

4-Iniliazed node project inside localservicefinder directory=== npm init -y    (This will create package.json)

5-Install required packages  npm install express mysql2 cors dotenv
purpose of packages ==  express=> handle API   mysql2=> bridge between back-end and data base cors=> Bridge between Browser and Back-end node server   dotenv==> use for reading database form .env

6-Building 3rd layer-- datatbase 
Login:
sudo mysql

Database:

CREATE DATABASE servicefinder;
User:

CREATE USER 'serviceuser'@'localhost'
IDENTIFIED BY 'StrongPassword123!';

Permissions:

GRANT ALL PRIVILEGES ON servicefinder.* TO 'serviceuser'@'localhost';

FLUSH PRIVILEGES;

Exit:

EXIT;
Step 6: Table Create Karo

Login:

sudo mysql servicefinder

Create table:
CREATE TABLE providers (

id INT AUTO_INCREMENT PRIMARY KEY,

name VARCHAR(100),

service_type VARCHAR(100),

city VARCHAR(100),

phone VARCHAR(20),

rating DECIMAL(2,1),

created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

);


Insert data:

INSERT INTO providers
(name, service_type, city, phone, rating)
VALUES

('Rahul Plumbing Services',
 'Plumber',
 'Ghaziabad',
 '9876543210',
 4.8),

('Sharma Electric Works',
 'Electrician',
 'Ghaziabad',
 '9876543211',
 4.7),

('Modern Carpentry',
 'Carpenter',
 'Ghaziabad',
 '9876543212',
 4.9),

('Noida Home Repair',
 'Plumber',
 'Noida',
 '9876543213',
 4.6),

('Perfect Painters',
 'Painter',
 'Noida',
 '9876543214',
 4.5),

('Delhi Power Experts',
 'Electrician',
 'Delhi',
 '9876543215',
 4.9),

('Quick Cleaning Services',
 'Cleaner',
 'Delhi',
 '9876543216',
 4.7),

('Smart AC Repair',
 'AC Technician',
 'Noida',
 '9876543217',
 4.8);

Step 7: Environment File

nano .env

Paste:

DB_HOST=localhost
DB_USER=devops
DB_PASSWORD=according to you
DB_NAME=servicefinder

PORT=3000 

8-Back-end server setup

nano server.js
paste here

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

then save it



9- Front-end setup 

cd public/

then nano app.js
paste this --

async function loadDropdowns() {

 const cityResponse = await fetch("/cities");
 const cities = await cityResponse.json();

 const citySelect =
 document.getElementById("city");

 cities.forEach(city => {

  citySelect.innerHTML +=
  `<option value="${city.city}">
   ${city.city}
  </option>`;

 });

 const serviceResponse =
 await fetch("/services");

 const services =
 await serviceResponse.json();

 const serviceSelect =
 document.getElementById("service");

 services.forEach(service => {

  serviceSelect.innerHTML +=
  `<option value="${service.service_type}">
   ${service.service_type}
  </option>`;

 });

}

async function loadProviders() {

 const city =
 document.getElementById("city").value;

 const service =
 document.getElementById("service").value;

 const response =
 await fetch(
  `/providers?city=${city}&service=${service}`
 );

 const data =
 await response.json();

 let html = "";

 data.forEach(provider => {

  html += `
   <div class="card">

    <div class="card-content">

     <h3>${provider.name}</h3>

     <p>⭐ ${provider.rating}</p>

     <p>📍 ${provider.city}</p>

     <p>🔧 ${provider.service_type}</p>

     <p>📞 ${provider.phone}</p>

    </div>

   </div>
  `;

 });

 document.getElementById("result")
 .innerHTML = html;

}

loadDropdowns();

save it

then style.css 
nano style.css
paste this 

.field{
    display:flex;
    flex-direction:column;
    color:white;
}

.field label{
    margin-bottom:8px;
    font-weight:bold;
}

.card-content{
    padding:20px;
}

.card-content p{
    margin-top:10px;
}
save it 


then index.html
nano index.html

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Local Service Finder</title>

    <link rel="stylesheet" href="style.css">

    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

</head>

<body>

    <!-- Hero Section -->

    <section class="hero">

        <div class="overlay">

            <h1>
                Find Trusted Local Services
            </h1>

            <p>
                Search verified service providers in your city
            </p>

            <div class="search-box">

                <div class="field">

                    <label>
                        <i class="fa-solid fa-location-dot"></i>
                        City
                    </label>

                    <select id="city">

                        <option value="">
                            Select City
                        </option>

                    </select>

                </div>

                <div class="field">

                    <label>
                        <i class="fa-solid fa-screwdriver-wrench"></i>
                        Service
                    </label>

                    <select id="service">

                        <option value="">
                            Select Service
                        </option>

                    </select>

                </div>

                <button onclick="loadProviders()">

                    <i class="fa-solid fa-magnifying-glass"></i>
                    Search

                </button>

            </div>

        </div>

    </section>

    <!-- Popular Services -->

    <section>

        <h2 class="section-title">

            Popular Services

        </h2>

        <div class="service-icons">

            <div>
                🔧
                <span>Plumber</span>
            </div>

            <div>
                ⚡
                <span>Electrician</span>
            </div>

            <div>
                🪚
                <span>Carpenter</span>
            </div>

            <div>
                🎨
                <span>Painter</span>
            </div>

            <div>
                ❄️
                <span>AC Technician</span>
            </div>

            <div>
                🧹
                <span>Cleaner</span>
            </div>

        </div>

    </section>

    <!-- Providers Section -->

    <section>

        <h2 class="section-title">

            Service Providers

        </h2>

        <div id="result"
             class="providers">

        </div>

    </section>

    <!-- Footer -->

    <footer>

        <p>
            © 2026 Local Service Finder |
            Built with Node.js, Express, MySQL & Azure VM
        </p>

    </footer>

    <script src="app.js"></script>

</body>

</html>


save it 



10- PM2 (Optional but Recommended)

Install:

sudo npm install -g pm2

Run:

pm2 start server.js --name servicefinder

back-end server is now running 
application is running at http://PUBLIC_IP:3000

11-Nginx server server (reverse proxy)

 Nginx Configuration

Create file:

sudo nano /etc/nginx/sites-available/servicefinder

Paste:

server {

    listen 80;

    server_name nirmal.blog www.nirmal.blog;

    location / {

        proxy_pass http://localhost:3000;

        proxy_http_version 1.1;

        proxy_set_header Host $host;

        proxy_set_header X-Real-IP $remote_addr;

        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        proxy_set_header X-Forwarded-Proto $scheme;

    }

}

Save.

Step : Enable Site
sudo ln -s \
/etc/nginx/sites-available/servicefinder \
/etc/nginx/sites-enabled/
Step 5 : Remove Default Site (Recommended)

Check:

ls -l /etc/nginx/sites-enabled/



sudo rm /etc/nginx/sites-enabled/default
Step 6 : Test Nginx
sudo nginx -t

Expected:

syntax is ok
test is successful

Reload Nginx
sudo systemctl reload nginx


Step 12 SSL Install

sudo apt update

sudo apt install certbot python3-certbot-nginx -y
Step 10 : SSL Generate
sudo certbot --nginx -d nirmal.blog -d www.nirmal.blog


====Finally Application is live at https://nirmal.blog
