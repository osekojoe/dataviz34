<!-- App.svelte -->
<script context="module">
  import * as d3 from 'd3';
  import { onMount } from 'svelte';
  import './html_css/styles.css';

  function goToPage(page) {
    window.location.href = `./${page}.html`;
  }
</script>

<script>
  // Function to format delivery time value and quantity
  function formatValue(value, valueType) {
    if (valueType === 'typeQuantities') {
      return `${value.toFixed(0)} Units`;
    } else if (valueType === 'typeDeliveryTimes') {
      return `${value.toFixed(0)} Days`;
    } else {
      return `${value}`;
    }
  }


  // function to create the radial plot
  function createRadialPlot(data) {
    const width = 1800;
    const height = 1800;
    const innerRadius = 250;
    const middleRadius = 450;
    const outerRadius = 800;

    //const outerRadius = Math.min(width, height) / 2;
    const series = d3.stack()
            .keys(d3.union(data.map(d => d.Type)))
            .value(([, D], key) => D.get(key).typeQuantities)
            (d3.index(data, d => d.Region, d => d.Type));

    const seriesTime = d3.stack()
            .keys(d3.union(data.map(d => d.Type)))
            .value(([, D], key) => D.get(key).DeliveryTimeDays)
            (d3.index(data, d => d.Region, d => d.Type));
    // Create the arc object
    const arc = d3.arc()
            .innerRadius(d => y(d[0])) // Inner radius
            .outerRadius(d => y(d[1])) // Outer radius
            .startAngle(d => x(d.data[0]))
            .endAngle(d => x(d.data[0]) + x.bandwidth())
            .padAngle(0.02) // Pad angle
            //.padRadius(innerRadius) // Pad radius
            //.cornerRadius(6)
    ;

    const x = d3.scaleBand()
            .domain(data.map(d => d.Region))
            .range([0, 2 * Math.PI])
            .align(0);

    const y = d3.scaleRadial()
            .domain([0, d3.max(series, d => d3.max(d, d => d[1]))])
            .range([innerRadius, outerRadius]);

    const color = d3.scaleOrdinal()
            .domain(series.map(d => d.key))
            .range(d3.schemeSpectral[series.length])
            .unknown("hsl(0,7%,91%)");

    const svg = d3.create("svg")
            .attr("width", width)
            .attr("height", height)
            .attr("viewBox", [-width / 2, -height / 2, width, height])
            .attr("style", "width: 100%; height: auto; font: 10px sans-serif;");
// Add outer circle
    svg.append("circle")
            .attr("fill", "hsl(0,7%,91%")
            .attr("stroke", "black")
            // bold line
            .attr("stroke-width", 6)
            .attr("r", outerRadius+20);

// Add concentric circles
    svg.append("g")
            .attr("font-family", "sans-serif")
            .attr("font-size", 14)
            .selectAll("g")
            .data(y.ticks(3).slice(1))
            .join("g")
            // line type must be dashed
            .attr("stroke", "black")
            .attr("fill", "none")
            .call(g => g.append("circle")
                    .attr("stroke", "#000")
                    .attr("stroke-opacity", 0.2)
                    .attr("r", y))
            .call(g => g.append("text")
                    .attr("y", d => -y(d))
                    .attr("dy", "0.35em")
                    .attr("stroke", "#fff")
                    .attr("stroke-width", 5)
                    .text(y.tickFormat(5, "s")))
            .call(g => g.append("text")
                    .attr("y", d => -y(d))
                    .attr("dy", "0.5em")
                    .text(y.tickFormat(5, "s")));

    // add sectors to the plot for each region
    // Inside the createRadialPlot function

// Add class to product type segments
// Append bars for typeQuantities scaled down with initial opacity
    svg.append("g")
            .selectAll()
            .data(series)
            .join("g")
            .attr("fill", d => color(d.key))
            .selectAll("path")
            .data(D => D.map(d => (d.key = D.key, d)))
            .join("path")
            .attr("d", arc)
            //.attr("transform", `scale(1, ${1 / 10000})`) // Scale down vertically
            .attr("opacity", 1) // Initial opacity
            .on("mouseover", function () {
              d3.select(this).attr("opacity", 1); // Make hovered segment fully opaque
              const className = d3.select(this.parentNode).attr("class");
              d3.selectAll(`.${className}`).attr("opacity", 1); // Make all segments of the same class fully opaque
            })
            .on("mouseout", function () {
              d3.selectAll("path").attr("opacity", 0.5); // Reset opacity of all segments
            })
            .append("title")
            .text(d => `${d.data[0]} ${d.key}\n${formatValue(d.data[1].get(d.key).typeQuantities, 'typeQuantities')}`);

    // Append delivery times
    svg.append("g")
            .selectAll()
            .data(seriesTime)
            .join("g")
            //.attr("fill", d => color(d.key))
            .selectAll("text")
            .data(D => D.map(d => (d.key = D.key, d)))
            .join("text")
            .attr("x", d => arc.centroid(d)[0]*0.9) //3.2
            .attr("y", d => arc.centroid(d)[1]*0.9) //3.2
            .attr("dy", "0.35em")
            .attr("fill", "grey")
            .attr("text-anchor", "middle")
            .attr("font-size", "14px")
            .text(d => formatValue(d.data[1].get(d.key).DeliveryTimeDays, 'typeDeliveryTimes'));

// Add a concentric circle at outer radius

    svg.append("g")
            .attr("text-anchor", "middle")
            .selectAll()
            .data(y.ticks(5).slice(1))
            .join("text")
            .attr("y", d => -y(d))
            .attr("dy", "0.35em")
            .attr("fill", "none")
            // change font size
            .attr("font-size", 14)
            .attr("stroke", "#fff")
            .attr("stroke-width", 5)
            .text(y.tickFormat(5, "s"));
// The values of the concentric circles
    svg.append("g")
            .attr("text-anchor", "middle")
            .selectAll()
            .data(y.ticks(5).slice(1))
            .join("text")
            .attr("font-size", 14)

            .attr("y", d => -y(d))
            .attr("dy", "0.35em")
            .text(y.tickFormat(5, "s"));

// Region manipulation
    svg.append("g")
            .attr("text-anchor", "middle") // start middle end
            .selectAll()
            .data(x.domain())
            .join("g")
            .attr("transform", d => {
              return `\n        rotate(${((x(d) + x.bandwidth() / 2) * 180 / Math.PI - 90)})\n        translate(${middleRadius},0)`;
            })
            .call(g => g.append("line")
                    .attr("x2", -5)
                    .attr("stroke", "#f5f1f1"))// white
            .call(g => {
              return g.append("text")
                      .style("font-size", "20px") // Adjust font size here
                      // font color white
                      .attr("fill", "black")
                      .attr("transform", d => {
                        const angle = (x(d) + x.bandwidth() / 2 + Math.PI / 2) % (2 * Math.PI);
                        if (angle >= 0 && angle < Math.PI / 2) {
                          return "rotate(180)translate(0,0)";
                        } else if (angle >= Math.PI / 2 && angle < Math.PI) {
                          return "rotate(360)translate(0,0)";
                        } else if (angle >= Math.PI && angle < 3 * Math.PI / 2) {
                          return "rotate(360)translate(0,0)";
                        } else {
                          return "rotate(180)translate(0,0)";
                        }
                      })
                      .text(d => d);
            });
// Add chart title
    svg.append("text")
            .attr("x", 0)
            .attr("y", -height / 2 + 50)
            .attr("text-anchor", "middle")
            .attr("font-size", 25)
            .attr("font-weight", "bold")
            .text("A radial stacked barchart of the average Delivery Time in days by Region and Product Type and order Volume ");
// inner legend
    svg.append("g")
            .selectAll()
            .data(color.domain())
            .join("g")
            .attr("transform", (d, i, nodes) => `translate(-40,${(nodes.length / 2 - i - 1) * 30})`)
            .call(g => g.append("rect")
                    .attr("width", 24)
                    .attr("height", 24)
                    .attr("fill", color))
            .call(g => g.append("text")
                    .attr("x", 27)
                    .attr("y", 12)
                    .attr("dy", "0.35em")
                    .text(d => d));

    return svg.node();
  }

  onMount(() => {
    let data = [{"Region":"Amnian Empire","Type":"ADVENTURING EQUIPMENT","DeliveryTimeDays":10.2915,"typeQuantities":239588},{"Region":"Amnian Empire","Type":"ANIMALS & TRANSPORTATION","DeliveryTimeDays":10.2915,"typeQuantities":39967},{"Region":"Amnian Empire","Type":"ARMS & ARMOUR","DeliveryTimeDays":10.2915,"typeQuantities":312058},{"Region":"Amnian Empire","Type":"JEWELRY","DeliveryTimeDays":10.2915,"typeQuantities":31303},{"Region":"Amnian Empire","Type":"MUSICAL INSTRUMENT","DeliveryTimeDays":10.2915,"typeQuantities":24895},{"Region":"Amnian Empire","Type":"POTIONS & SCROLLS","DeliveryTimeDays":10.2915,"typeQuantities":82162},{"Region":"Amnian Empire","Type":"SUMMONING DEVICE","DeliveryTimeDays":10.2915,"typeQuantities":25530},{"Region":"Amnian Empire","Type":"TOOLS & KITS","DeliveryTimeDays":10.2915,"typeQuantities":86933},{"Region":"Bloodlands Empire","Type":"ADVENTURING EQUIPMENT","DeliveryTimeDays":10.0918,"typeQuantities":100493},{"Region":"Bloodlands Empire","Type":"ANIMALS & TRANSPORTATION","DeliveryTimeDays":10.0918,"typeQuantities":16503},{"Region":"Bloodlands Empire","Type":"ARMS & ARMOUR","DeliveryTimeDays":10.0918,"typeQuantities":172557},{"Region":"Bloodlands Empire","Type":"JEWELRY","DeliveryTimeDays":10.0918,"typeQuantities":13400},{"Region":"Bloodlands Empire","Type":"MUSICAL INSTRUMENT","DeliveryTimeDays":10.0918,"typeQuantities":10545},{"Region":"Bloodlands Empire","Type":"POTIONS & SCROLLS","DeliveryTimeDays":10.0918,"typeQuantities":33951},{"Region":"Bloodlands Empire","Type":"SUMMONING DEVICE","DeliveryTimeDays":10.0918,"typeQuantities":10752},{"Region":"Bloodlands Empire","Type":"TOOLS & KITS","DeliveryTimeDays":10.0918,"typeQuantities":35668},{"Region":"Calim Empire","Type":"ADVENTURING EQUIPMENT","DeliveryTimeDays":10.3874,"typeQuantities":169627},{"Region":"Calim Empire","Type":"ANIMALS & TRANSPORTATION","DeliveryTimeDays":10.3874,"typeQuantities":27385},{"Region":"Calim Empire","Type":"ARMS & ARMOUR","DeliveryTimeDays":10.3874,"typeQuantities":194174},{"Region":"Calim Empire","Type":"JEWELRY","DeliveryTimeDays":10.3874,"typeQuantities":21856},{"Region":"Calim Empire","Type":"MUSICAL INSTRUMENT","DeliveryTimeDays":10.3874,"typeQuantities":17118},{"Region":"Calim Empire","Type":"POTIONS & SCROLLS","DeliveryTimeDays":10.3874,"typeQuantities":58169},{"Region":"Calim Empire","Type":"SUMMONING DEVICE","DeliveryTimeDays":10.3874,"typeQuantities":17543},{"Region":"Calim Empire","Type":"TOOLS & KITS","DeliveryTimeDays":10.3874,"typeQuantities":59699},{"Region":"Dwarven Empire","Type":"ADVENTURING EQUIPMENT","DeliveryTimeDays":9.976,"typeQuantities":47020},{"Region":"Dwarven Empire","Type":"ANIMALS & TRANSPORTATION","DeliveryTimeDays":9.976,"typeQuantities":7337},{"Region":"Dwarven Empire","Type":"ARMS & ARMOUR","DeliveryTimeDays":9.976,"typeQuantities":75184},{"Region":"Dwarven Empire","Type":"JEWELRY","DeliveryTimeDays":9.976,"typeQuantities":5986},{"Region":"Dwarven Empire","Type":"MUSICAL INSTRUMENT","DeliveryTimeDays":9.976,"typeQuantities":5061},{"Region":"Dwarven Empire","Type":"POTIONS & SCROLLS","DeliveryTimeDays":9.976,"typeQuantities":17188},{"Region":"Dwarven Empire","Type":"SUMMONING DEVICE","DeliveryTimeDays":9.976,"typeQuantities":5078},{"Region":"Dwarven Empire","Type":"TOOLS & KITS","DeliveryTimeDays":9.976,"typeQuantities":17572},{"Region":"Eastern Empire","Type":"ADVENTURING EQUIPMENT","DeliveryTimeDays":9.9423,"typeQuantities":16944},{"Region":"Eastern Empire","Type":"ANIMALS & TRANSPORTATION","DeliveryTimeDays":9.9423,"typeQuantities":2660},{"Region":"Eastern Empire","Type":"ARMS & ARMOUR","DeliveryTimeDays":9.9423,"typeQuantities":17003},{"Region":"Eastern Empire","Type":"JEWELRY","DeliveryTimeDays":9.9423,"typeQuantities":2380},{"Region":"Eastern Empire","Type":"MUSICAL INSTRUMENT","DeliveryTimeDays":9.9423,"typeQuantities":1818},{"Region":"Eastern Empire","Type":"POTIONS & SCROLLS","DeliveryTimeDays":9.9423,"typeQuantities":5964},{"Region":"Eastern Empire","Type":"SUMMONING DEVICE","DeliveryTimeDays":9.9423,"typeQuantities":1897},{"Region":"Eastern Empire","Type":"TOOLS & KITS","DeliveryTimeDays":9.9423,"typeQuantities":6240},{"Region":"Halruaan Empire","Type":"ADVENTURING EQUIPMENT","DeliveryTimeDays":10.2537,"typeQuantities":160860},{"Region":"Halruaan Empire","Type":"ANIMALS & TRANSPORTATION","DeliveryTimeDays":10.2537,"typeQuantities":25881},{"Region":"Halruaan Empire","Type":"ARMS & ARMOUR","DeliveryTimeDays":10.2537,"typeQuantities":213826},{"Region":"Halruaan Empire","Type":"JEWELRY","DeliveryTimeDays":10.2537,"typeQuantities":20832},{"Region":"Halruaan Empire","Type":"MUSICAL INSTRUMENT","DeliveryTimeDays":10.2537,"typeQuantities":16363},{"Region":"Halruaan Empire","Type":"POTIONS & SCROLLS","DeliveryTimeDays":10.2537,"typeQuantities":54826},{"Region":"Halruaan Empire","Type":"SUMMONING DEVICE","DeliveryTimeDays":10.2537,"typeQuantities":16702},{"Region":"Halruaan Empire","Type":"TOOLS & KITS","DeliveryTimeDays":10.2537,"typeQuantities":58491},{"Region":"New Neverwinter Empire","Type":"ADVENTURING EQUIPMENT","DeliveryTimeDays":10.2447,"typeQuantities":47568},{"Region":"New Neverwinter Empire","Type":"ANIMALS & TRANSPORTATION","DeliveryTimeDays":10.2447,"typeQuantities":7963},{"Region":"New Neverwinter Empire","Type":"ARMS & ARMOUR","DeliveryTimeDays":10.2447,"typeQuantities":53891},{"Region":"New Neverwinter Empire","Type":"JEWELRY","DeliveryTimeDays":10.2447,"typeQuantities":6649},{"Region":"New Neverwinter Empire","Type":"MUSICAL INSTRUMENT","DeliveryTimeDays":10.2447,"typeQuantities":5167},{"Region":"New Neverwinter Empire","Type":"POTIONS & SCROLLS","DeliveryTimeDays":10.2447,"typeQuantities":16127},{"Region":"New Neverwinter Empire","Type":"SUMMONING DEVICE","DeliveryTimeDays":10.2447,"typeQuantities":4918},{"Region":"New Neverwinter Empire","Type":"TOOLS & KITS","DeliveryTimeDays":10.2447,"typeQuantities":17776},{"Region":"None Empire","Type":"ADVENTURING EQUIPMENT","DeliveryTimeDays":10.5886,"typeQuantities":28386},{"Region":"None Empire","Type":"ANIMALS & TRANSPORTATION","DeliveryTimeDays":10.5886,"typeQuantities":4760},{"Region":"None Empire","Type":"ARMS & ARMOUR","DeliveryTimeDays":10.5886,"typeQuantities":32398},{"Region":"None Empire","Type":"JEWELRY","DeliveryTimeDays":10.5886,"typeQuantities":3977},{"Region":"None Empire","Type":"MUSICAL INSTRUMENT","DeliveryTimeDays":10.5886,"typeQuantities":2979},{"Region":"None Empire","Type":"POTIONS & SCROLLS","DeliveryTimeDays":10.5886,"typeQuantities":10255},{"Region":"None Empire","Type":"SUMMONING DEVICE","DeliveryTimeDays":10.5886,"typeQuantities":2913},{"Region":"None Empire","Type":"TOOLS & KITS","DeliveryTimeDays":10.5886,"typeQuantities":10091},{"Region":"Old Empire","Type":"ADVENTURING EQUIPMENT","DeliveryTimeDays":10.4825,"typeQuantities":27585},{"Region":"Old Empire","Type":"ANIMALS & TRANSPORTATION","DeliveryTimeDays":10.4825,"typeQuantities":4387},{"Region":"Old Empire","Type":"ARMS & ARMOUR","DeliveryTimeDays":10.4825,"typeQuantities":37814},{"Region":"Old Empire","Type":"JEWELRY","DeliveryTimeDays":10.4825,"typeQuantities":3685},{"Region":"Old Empire","Type":"MUSICAL INSTRUMENT","DeliveryTimeDays":10.4825,"typeQuantities":2599},{"Region":"Old Empire","Type":"POTIONS & SCROLLS","DeliveryTimeDays":10.4825,"typeQuantities":9295},{"Region":"Old Empire","Type":"SUMMONING DEVICE","DeliveryTimeDays":10.4825,"typeQuantities":2738},{"Region":"Old Empire","Type":"TOOLS & KITS","DeliveryTimeDays":10.4825,"typeQuantities":9342},{"Region":"Purple Dragon Empire","Type":"ADVENTURING EQUIPMENT","DeliveryTimeDays":10.1252,"typeQuantities":146374},{"Region":"Purple Dragon Empire","Type":"ANIMALS & TRANSPORTATION","DeliveryTimeDays":10.1252,"typeQuantities":24342},{"Region":"Purple Dragon Empire","Type":"ARMS & ARMOUR","DeliveryTimeDays":10.1252,"typeQuantities":286210},{"Region":"Purple Dragon Empire","Type":"JEWELRY","DeliveryTimeDays":10.1252,"typeQuantities":18994},{"Region":"Purple Dragon Empire","Type":"MUSICAL INSTRUMENT","DeliveryTimeDays":10.1252,"typeQuantities":15442},{"Region":"Purple Dragon Empire","Type":"POTIONS & SCROLLS","DeliveryTimeDays":10.1252,"typeQuantities":50313},{"Region":"Purple Dragon Empire","Type":"SUMMONING DEVICE","DeliveryTimeDays":10.1252,"typeQuantities":15542},{"Region":"Purple Dragon Empire","Type":"TOOLS & KITS","DeliveryTimeDays":10.1252,"typeQuantities":54093},{"Region":"Southern Empire","Type":"ADVENTURING EQUIPMENT","DeliveryTimeDays":10.3446,"typeQuantities":9505},{"Region":"Southern Empire","Type":"ANIMALS & TRANSPORTATION","DeliveryTimeDays":10.3446,"typeQuantities":1602},{"Region":"Southern Empire","Type":"ARMS & ARMOUR","DeliveryTimeDays":10.3446,"typeQuantities":9339},{"Region":"Southern Empire","Type":"JEWELRY","DeliveryTimeDays":10.3446,"typeQuantities":1368},{"Region":"Southern Empire","Type":"MUSICAL INSTRUMENT","DeliveryTimeDays":10.3446,"typeQuantities":950},{"Region":"Southern Empire","Type":"POTIONS & SCROLLS","DeliveryTimeDays":10.3446,"typeQuantities":3358},{"Region":"Southern Empire","Type":"SUMMONING DEVICE","DeliveryTimeDays":10.3446,"typeQuantities":1006},{"Region":"Southern Empire","Type":"TOOLS & KITS","DeliveryTimeDays":10.3446,"typeQuantities":3484},{"Region":"Thayan Empire","Type":"ADVENTURING EQUIPMENT","DeliveryTimeDays":10.3601,"typeQuantities":147561},{"Region":"Thayan Empire","Type":"ANIMALS & TRANSPORTATION","DeliveryTimeDays":10.3601,"typeQuantities":24228},{"Region":"Thayan Empire","Type":"ARMS & ARMOUR","DeliveryTimeDays":10.3601,"typeQuantities":223060},{"Region":"Thayan Empire","Type":"JEWELRY","DeliveryTimeDays":10.3601,"typeQuantities":19840},{"Region":"Thayan Empire","Type":"MUSICAL INSTRUMENT","DeliveryTimeDays":10.3601,"typeQuantities":15274},{"Region":"Thayan Empire","Type":"POTIONS & SCROLLS","DeliveryTimeDays":10.3601,"typeQuantities":51235},{"Region":"Thayan Empire","Type":"SUMMONING DEVICE","DeliveryTimeDays":10.3601,"typeQuantities":15814},{"Region":"Thayan Empire","Type":"TOOLS & KITS","DeliveryTimeDays":10.3601,"typeQuantities":53448},{"Region":"United Moonshae Empire","Type":"ADVENTURING EQUIPMENT","DeliveryTimeDays":10.3273,"typeQuantities":124264},{"Region":"United Moonshae Empire","Type":"ANIMALS & TRANSPORTATION","DeliveryTimeDays":10.3273,"typeQuantities":19733},{"Region":"United Moonshae Empire","Type":"ARMS & ARMOUR","DeliveryTimeDays":10.3273,"typeQuantities":155843},{"Region":"United Moonshae Empire","Type":"JEWELRY","DeliveryTimeDays":10.3273,"typeQuantities":16364},{"Region":"United Moonshae Empire","Type":"MUSICAL INSTRUMENT","DeliveryTimeDays":10.3273,"typeQuantities":12818},{"Region":"United Moonshae Empire","Type":"POTIONS & SCROLLS","DeliveryTimeDays":10.3273,"typeQuantities":43607},{"Region":"United Moonshae Empire","Type":"SUMMONING DEVICE","DeliveryTimeDays":10.3273,"typeQuantities":12663},{"Region":"United Moonshae Empire","Type":"TOOLS & KITS","DeliveryTimeDays":10.3273,"typeQuantities":45032},{"Region":"Waterdhavian Empire","Type":"ADVENTURING EQUIPMENT","DeliveryTimeDays":10.368,"typeQuantities":59682},{"Region":"Waterdhavian Empire","Type":"ANIMALS & TRANSPORTATION","DeliveryTimeDays":10.368,"typeQuantities":9836},{"Region":"Waterdhavian Empire","Type":"ARMS & ARMOUR","DeliveryTimeDays":10.368,"typeQuantities":55862},{"Region":"Waterdhavian Empire","Type":"JEWELRY","DeliveryTimeDays":10.368,"typeQuantities":8058},{"Region":"Waterdhavian Empire","Type":"MUSICAL INSTRUMENT","DeliveryTimeDays":10.368,"typeQuantities":6188},{"Region":"Waterdhavian Empire","Type":"POTIONS & SCROLLS","DeliveryTimeDays":10.368,"typeQuantities":20849},{"Region":"Waterdhavian Empire","Type":"SUMMONING DEVICE","DeliveryTimeDays":10.368,"typeQuantities":6113},{"Region":"Waterdhavian Empire","Type":"TOOLS & KITS","DeliveryTimeDays":10.368,"typeQuantities":21772},{"Region":"Western Empire","Type":"ADVENTURING EQUIPMENT","DeliveryTimeDays":10.4019,"typeQuantities":19001},{"Region":"Western Empire","Type":"ANIMALS & TRANSPORTATION","DeliveryTimeDays":10.4019,"typeQuantities":3099},{"Region":"Western Empire","Type":"ARMS & ARMOUR","DeliveryTimeDays":10.4019,"typeQuantities":17099},{"Region":"Western Empire","Type":"JEWELRY","DeliveryTimeDays":10.4019,"typeQuantities":2455},{"Region":"Western Empire","Type":"MUSICAL INSTRUMENT","DeliveryTimeDays":10.4019,"typeQuantities":1986},{"Region":"Western Empire","Type":"POTIONS & SCROLLS","DeliveryTimeDays":10.4019,"typeQuantities":6458},{"Region":"Western Empire","Type":"SUMMONING DEVICE","DeliveryTimeDays":10.4019,"typeQuantities":1893},{"Region":"Western Empire","Type":"TOOLS & KITS","DeliveryTimeDays":10.4019,"typeQuantities":6395}];
    const radialPlot = createRadialPlot(data);
    const container = document.getElementById("radial-plot");
    container.appendChild(radialPlot);
  });
</script>

<h4>Stacked Radial Plot of Delivery time by Region and Product Type</h4>
<h5> Description</h5>
<em>Regional Comparison</em>:
Each region is represented by a segment of the circle, with the regions arranged around the circumference.
The plot allows for a comparison of delivery volumes and provides the average delivery time for each region.<br><br>
<em>Product Type Distribution:</em>
Each region segment is divided into smaller segments representing different product types.
The volume of the product types within each region can be observed.
The radial length of each segment corresponds to the volume of orders of each type.
The concentric circles within the plot provide a reference for those orders <br><br>
<em>Consistency in Delivery Time</em>: There is consistency of delivery times across regions and product types.<br><br>
<em>Legend</em>:
A legend is provided within the plot, allowing for easy interpretation of the colors representing different product types.<br><br>
<em>Title and Labels</em>:
The plot includes a title that summarizes the content.
Region names are labeled along the circumference of the circle, aiding in identifying each segment.<br><br>
<em>Data Points / interactivity</em>:
Each segment is interactive and displays the specific delivery time and quantity for the corresponding product type in a tooltip upon hovering.<br><br>
<em>Overall Trend</em>:
Trends in delivery times across regions and product types can be analyzed, identifying any patterns or anomalies.
These observations provide insights into the distribution and variation of delivery times within and across regions,
facilitating decision-making in supply chain management or logistics optimization.
<svelte:head>
  <title>Radial Plot</title>
</svelte:head>

<div id="radial-plot"></div>