---
layout: page
title: Articles
permalink: /articles/
description: Baseball Research & Insights by Gabriel Sequera.
nav: true
nav_order: 4
---

<link rel="stylesheet" href="{{ '/assets/css/panalytics.css' | relative_url }}">

<h2 class="pb-section-heading">Baseball Research &amp; Insights</h2>

<p class="pb-lead">Research articles that turn pitch-level data into practical questions, evidence, and development recommendations for Baseball Operations and Player Development.</p>

<div class="pb-grid pb-grid-two pb-section">
  {% for article in site.data.articles %}
    <article class="pb-card">
      {% if article.image %}
        <img class="pb-card-image" src="{{ article.image | relative_url }}" alt="{{ article.title }}">
      {% endif %}
      <div class="pb-card-body">
        <p class="pb-eyebrow">{{ article.date }}</p>
        <h3>{{ article.title }}</h3>
        <p>{{ article.description }}</p>
        {% if article.url %}
          {% if article.external %}
            <a class="pb-button" href="{{ article.url }}" target="_blank" rel="noopener">{{ article.button_label | default: "Read the Article" }}</a>
          {% else %}
            <a class="pb-button" href="{{ article.url | relative_url }}">{{ article.button_label | default: "Read the Article" }}</a>
          {% endif %}
        {% endif %}
      </div>
    </article>
  {% endfor %}
</div>
