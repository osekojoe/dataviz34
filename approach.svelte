<script>
    import { onMount } from 'svelte';

    function goToPage(section) {
        window.location.href = section.toLowerCase();
    }

    let headings = [
        { id: 'approach', text: 'Visual Design Approach' },
        { id: 'sketches', text: 'Sketches' }
    ];

    let sketches = [
        {
            title: 'Geographical Influence on Product Demand',
            description: 'This sketch illustrates the flow of products and order characteristics across different regions, emphasizing D.E.A.D.\'s core business areas and product diversity within orders.'
        },
        {
            title: 'Delivery Time per Region',
            description: 'This sketch explores delivery times across regions, using bar lengths to represent average delivery durations and widths to depict order volumes.'

        },
        {
            title: 'Trend of Product Demand Over Five Years',
            description: 'This sketch visualizes the evolution of product demand over five years, facilitating comparisons between product types and years through unique color-coded nodes.'
        }
    ];

    let scrollTo = id => {
        document.getElementById(id).scrollIntoView({ behavior: 'smooth' });
    };
</script>

<div id="container">
    <div id="container"> <h3>Contents</h3> </div>
</div>

<div id="visual_approach">
    <ul>
        {#each headings as { id, text }}
            <li><a href="javascript:void(0);" on:click={() => scrollTo(id)}>{text}</a></li>
        {/each}
    </ul>
</div>

{#each headings as { id, text }}
    <div id={id}>
        <h4>{text}</h4>
        {#if id === 'approach'}
            <p>Our visual design strategy involved a structured process of exploration, comparison, and refinement. We created a variety of sketches tailored to address specific research questions, gradually refining our visualizations to effectively communicate findings and insights.</p>
            <p>By balancing complexity and simplicity, we developed a series of final sketches that provide clear, interpretable representations of the data.</p>
        {:else if id === 'sketches'}
            <h5>Reworked Sketches</h5>
            <ul>
                {#each sketches as { title, description }}
                    <li>
                        <strong>{title}:</strong> {description}
                    </li>
                {/each}
            </ul>
        {/if}
    </div>
{/each}
