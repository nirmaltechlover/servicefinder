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

please refer file for inserting data---database_data



Step 7: Environment File

nano .env

Paste:

DB_HOST=localhost
DB_USER=devops
DB_PASSWORD=according to you
DB_NAME=servicefinder

PORT=3000 

8-Back-end server setup

please refer file ---server.js

nano server.js
paste the content of server.js
then save it



9- Front-end setup 

cd public/

then nano app.js

please refer app.js file

paste the content of app.js


save it

then do for style.css 

please refer the file style.css

nano style.css
paste the content of style.css



save it 


then do for index.html
please refer the content of index.html file

nano index.html

please paste the content of index.html here 

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
