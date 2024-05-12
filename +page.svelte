<header><h1>Data Visualisation</h1></header>
<script>
    import Introduction from './Introduction.svelte';
    import Approach from './Approach.svelte';
    import Data from './Data.svelte';
    import Results from './Results.svelte';
    import Results2 from './Results2.svelte';

    let currentSection = 'Introduction';

    function goToPage(section) {
        currentSection = section;
    }
</script>

<div id="container">
    <button on:click={() => goToPage('Introduction')}>Introduction</button>
    <button on:click={() => goToPage('Approach')}>Approach</button>
    <button on:click={() => goToPage('Data')}>Data and access</button>
    <button on:click={() => goToPage('Results')}>Delivery Time</button>
    <button on:click={() => goToPage('Results2')}>Product Flow</button>


    {#if currentSection === 'Introduction'}
                <Introduction />
            {/if}

            {#if currentSection === 'Approach'}
                <Approach />
            {/if}

            {#if currentSection === 'Data'}
                <Data />
            {/if}

            {#if currentSection === 'Results'}
                <Results />
            {/if}
            {#if currentSection === 'Results2'}
                <Results2 />
    {/if}
</div>
