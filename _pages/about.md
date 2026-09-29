---
layout: about
title: About
permalink: /
subtitle: Baseball Operations | Player Development | Baseball Analytics
nav_order: 1
description: Gabriel Sequera combines practical baseball experience with R, Shiny, and data-informed player evaluation.
profile:
  align: right
  image: gabriel-sequera.jpeg
  image_circular: false
  more_info: >
    <p><strong>New Jersey, USA</strong></p>
selected_papers: false
social: true
announcements:
  enabled: false
latest_posts:
  enabled: false
---

<link rel="stylesheet" href="{{ '/assets/css/panalytics.css' | relative_url }}">

<p class="pb-eyebrow">Panalytics Baseball</p>

<h2 class="pb-section-heading">Gabriel Sequera</h2>

<p class="pb-lead">
  Gabriel Sequera is a baseball professional focused on the intersection of practical baseball knowledge, player development, and data analysis. His work uses R, Shiny, visual analysis, and baseball context to turn information into clear evaluations and actionable decisions for Baseball Operations and Player Development environments.
</p>

<p class="pb-meta">Based in New Jersey, USA · English (fluent) · Spanish (native)</p>

<div class="pb-actions" aria-label="Professional links">
  <a class="pb-button" href="https://www.linkedin.com/in/gabriel-sequera/" target="_blank" rel="noopener">LinkedIn</a>
  <a class="pb-button pb-button-secondary" href="https://github.com/PanalyticsBaseball" target="_blank" rel="noopener">GitHub</a>
  <a class="pb-button pb-button-secondary" href="mailto:panalyticsbaseball@gmail.com">Email</a>
</div>

<p class="pb-section-intro">Gabriel's background includes Baseball Operations roles with the Somerset Patriots and New Jersey Jackals, athletics operations at Saint Peter's University, and experience as a collegiate catcher and strength and conditioning coach.</p>

<section class="pb-section" aria-labelledby="featured-work">
  <h2 id="featured-work" class="pb-section-heading">Featured Work</h2>
  <p class="pb-section-intro">A quick view of the technical projects and player-evaluation work most relevant to baseball recruiters.</p>

{% assign sorted_projects = site.projects | sort: "importance" %}
  <div class="pb-grid">
    {% for project in sorted_projects %}
      <article class="pb-card">
        {% if project.img %}
          <img class="pb-card-image pb-project-image {{ project.image_class }}" src="{{ project.img | relative_url }}" alt="{{ project.title }} preview">
        {% endif %}
        <div class="pb-card-body">
          <h3>{{ project.title }}</h3>
          <p>{{ project.description }}</p>
          <a class="pb-button" href="{{ project.url | relative_url }}">View Project</a>
        </div>
      </article>
    {% endfor %}
  </div>
</section>
