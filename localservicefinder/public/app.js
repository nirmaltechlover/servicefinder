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
