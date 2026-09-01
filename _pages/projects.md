---
layout: page
title: Projects
permalink: /projects/
description: Baseball analytics and player-development projects built with practical baseball questions in mind.
nav: true
nav_order: 2
horizontal: false
---

<link rel="stylesheet" href="{{ '/assets/css/panalytics.css' | relative_url }}">

<p class="pb-lead">Selected work demonstrating how Gabriel uses data, visual communication, and baseball context to support evaluation and decision-making.</p>

<div class="pb-placeholder"><strong>Portfolio status:</strong> The first project is structured and ready for the final ShinyApps URL, source-code URL, and application screenshot.</div>

<div class="projects pb-section">
  {% assign sorted_projects = site.projects | sort: "importance" %}
  <div class="pb-grid pb-grid-two">
    {% for project in sorted_projects %}
      <article class="pb-card">
        {% if project.img %}
          <img class="pb-card-image" src="{{ project.img | relative_url }}" alt="{{ project.title }} preview">
        {% endif %}
        <div class="pb-card-body">
          <h3>{{ project.title }}</h3>
          <p>{{ project.description }}</p>
          <a class="pb-button" href="{{ project.url | relative_url }}">View Project</a>
        </div>
      </article>
    {% endfor %}
  </div>
</div>
