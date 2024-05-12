<!-- Data.svelte -->
<script>
  function goToPage(page) {
    window.location.href = `./${page}.html`;
  }
</script>
<div id="Sections">
  <div id="container"> <h3>Contents</h3> </div>
  <ul>
    <li><a href="#access">Data Access</a></li>
    <li><a href="#data_description">Description of Dataset</a></li>
  </ul>
</div>

<div id="container">
  <div id="access">
    <h3>Data Access</h3>
    <p>The dataset can be accessed <strong><a href="https://github.com/JannesPeeters/DEAD" target="_blank">HERE</a></strong>.</p>
    <a href="#container">Back to Selection</a>
  </div>

  <div id="data_description">
    <h3>Description of Dataset</h3>
    <p><strong>Data Description:</strong></p>
    <dl>
      <dt>Customers</dt>
      <dd>
        <p>A roster of 2497 customers who have placed orders with us to date. To place an order, customers must have an account, each assigned a unique account code. Our customer base includes private individuals and professional buyers, with each customer assigned an account manager. Additionally, larger professional clients can subscribe to our 'key account' service, which provides them with a dedicated private account manager.</p>
      </dd>
      <dt>Products</dt>
      <dd>
        <p>A comprehensive inventory of all products offered by our company. Each product is categorized by type and subtype, facilitating easy organization and navigation. Furthermore, our products are distributed across three distinct business units. Pricing for each product is denoted in a combination of gold, silver, and copper pieces.</p>
      </dd>
      <dt>Regions</dt>
      <dd>
        <p>A catalog of territories within the Forgotten Realms where orders can be placed with our company.</p>
      </dd>
      <dt>Orders</dt>
      <dd>
        <p>A list of all orders placed with our company over the past five years. Each order may comprise multiple products. Therefore, the order includes a cart price, indicating the total amount paid by the customer for the entire order, as well as a product price, reflecting the price paid for individual products, factoring in quantities purchased.</p>
      </dd>
    </dl>
    <a href="#container">Back to Selection</a>
  </div>
</div>
