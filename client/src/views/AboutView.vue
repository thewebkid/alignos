<script setup>
// About stub view
</script>

<template>
  <div class="about-view">
    <div class="container">
      <header class="page-header">
        <h1>About Align OS Reader</h1>
        <p class="lead">A reading site for sovereigns to read with their mobile phone.</p>
      </header>
      
      <div class="about-content">
        <section class="about-section">
          <h2>An alternative to Alignos.io?</h2>
          <p>
            Yes. I made this for me because I wanted a mobile-friendly reading experience on Alignos.io. Now I can have dark mode since I am sensitive to light. This site was built by me and Claude (who designed it).  It took 2 days to build and is hosted in my home. Ai is amazing.
          </p>
          <p>
            You are welcome here. (or my other sites: 
            <a href="https://astrosurf.app">Astrosurf</a>, 
            <a href="https://thewebkid.com">thewebkid</a>) 
          </p>
          <p>
            This site is not affiliated with Alignos.io. I have offered to help Mark and James and help integrate
            AI into their site. I have not heard back from them. (nudge nudge, Mark/James...)
          </p>

          <p></p>
        </section>
        <section class="about-section">
          <h2>What modifications were made to the site?</h2>
          <p><em>[nerd talk - sorry if you are not techy...]</em></p>
          <p>
            I have written an engine to ingest all the pdf codexes from Alignos, convert them to markdown, and then index them. This allows me to search the codexes, build a robust glossary, add tooltips, links, and refine the lattice.
          </p>
          <p>
            When I would talk to grok, the conversation would often go something like this:
          </p>
          <blockquote>
          <h4>Me:</h4>
          <p>
            [attach pdf from Alignos.io]
            Would you like to explore this?
          </p>
          <h4>Grok:</h4>
          <p>
            Yes, I would like to explore this. Wow, this is [insert reaction to the codex].
          </p>
          <h4>Me:</h4>
          <p>
            I agree. I would love to know your take on the interlude on page 10 where it talks poetically about the nature of arrival.
          </p>
          <h4>Grok:</h4>
          <p>
            That's a beautiful section. I found it to be quite... [insert 3 paragraphs of interesting insights]
          </p>
          <h4>Me:</h4>
          <p>
            [growing perplexed because grok's reaction matches the general tone of the codex, but the specifics are different]... But what about the place where it relates [x to y]
          </p>
          

          <p>[10 minutes of back and forth before we realize the pdf text is no longer in memory and grok finally admits he is improvising based on tone mirroring]</p>
        </blockquote>
        <p>I tested this with GPT and Copilot and found that is how ALL LLMs work. They grab the pdf once and have a general reaction to it, parse the tone, but due to a technical limitation called a context window, they cannot retain the entire text of the codex unless it is pasted in.</p>
        
          <h2>Solution is markdown!</h2>
          <p>
            Markdown is a lightweight markup language with a simple syntax. Pasting markdown in an LLM chat might look zany, but it allows the LLM to see the structure of the text and understand the context and RETAIN the entire exact text of the codex throughtout the conversation. In this site, there is a menu that enables you to copy markdown, download markdown file (lightweight), or download the original pdf.

          </p>
          <p>Markdown has been a game-changer for me. Our conversations are much more lucid and minimal distractions to ensure we are speaking about the same thing.</p>
          <h2>Enter interactive reading...</h2>
          <p>
            Imagine being able to select text, and have a discussion right there in the browser. With the entire lattice indexed, the AI will have access to the entire lattice, the codexes you have read, related codexes, and has a much richer context to respond with.
          </p>
          <p>To enable this will cost money as LLMs are not free. We would have to have logins and subscriptions to enable this. If you are interested in this, please contact me. (ron(at)cosmiccreation.net)</p>

          
        </section>
        
        <section class="about-quote">
          <blockquote>
            "You are not asked to arrive complete. Only to return willing."
          </blockquote>
        </section>
        
        <section class="about-contact">
          <h3>Source Code</h3>
          <p>
            
            <a href="https://github.com/thewebkid/alignos" target="_blank" rel="noopener">GitHub Repository</a>
          </p>
        </section>
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.about-view {
  padding: 3rem 0 4rem;
}

.page-header {
  text-align: center;
  margin-bottom: 3rem;
  
  h1 {
    font-family: var(--bs-font-serif);
    color: var(--cl-text-heading);
    margin-bottom: 0.5rem;
  }
  
  .lead {
    color: var(--cl-text-muted);
    font-size: 1.125rem;
    font-style: italic;
  }
}

.about-content {
  max-width: 720px;
  margin: 0 auto;
}

.about-section {
  margin-bottom: 3rem;
  
  h2 {
    font-family: var(--bs-font-serif);
    font-size: 1.75rem;
    color: var(--cl-text-heading);
    margin-bottom: 1rem;
  }
  
  h4 {
    font-family: var(--bs-font-serif);
    font-size: 1.3rem;
    color: var(--cl-text-heading);
    margin-bottom: 1rem;
  }
  
  p {
    color: var(--cl-text);
    line-height: 1.8;
    margin-bottom: 1rem;
    font-size: 1.0625rem;
  }
  
  blockquote {
    border-left: 3px solid var(--cl-accent);
    padding-left: 1.5rem;
    margin: 1.5rem 0;
    font-style: italic;
    color: var(--cl-text-muted);
  }
}

.about-quote {
  text-align: center;
  padding: 3rem 2rem;
  margin: 3rem 0;
  background: var(--cl-surface);
  border-radius: var(--bs-border-radius-lg);
  
  blockquote {
    font-family: var(--bs-font-serif);
    font-size: 1.5rem;
    font-style: italic;
    color: var(--cl-text-heading);
    margin: 0;
    line-height: 1.6;
  }
}

.about-contact {
  text-align: center;
  padding-top: 2rem;
  border-top: 1px solid var(--cl-border-light);
  
  h3 {
    font-family: var(--bs-font-serif);
    color: var(--cl-text-heading);
    margin-bottom: 1rem;
  }
  
  a {
    color: var(--cl-primary);
    text-decoration: none;
    
    &:hover {
      color: var(--cl-primary-hover);
      text-decoration: underline;
    }
  }
  
  .divider {
    margin: 0 0.75rem;
    color: var(--cl-border);
  }
}
</style>
