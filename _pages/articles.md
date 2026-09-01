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

<p class="pb-lead">Short-form research, practical observations, and data-informed perspectives on Baseball Operations, Player Development, Scouting, and Analytics.</p>

<div class="pb-grid pb-section">
  {% for article in site.data.articles %}
    <article class="pb-card">
      <div class="pb-card-body">
        <p class="pb-eyebrow">{{ article.date }}</p>
        <h3>{{ article.title }}</h3>
        <p>{{ article.description }}</p>
        {% if article.url %}
          <a class="pb-button" href="{{ article.url }}" target="_blank" rel="noopener">Read on LinkedIn</a>
        {% else %}
          <span class="pb-button pb-button-disabled" aria-disabled="true">Read on LinkedIn · [ADD LINK]</span>
        {% endif %}
      </div>
    </article>
  {% endfor %}
</div>

<p class="pb-placeholder"><strong>Content note:</strong> Add only the article title, short summary, publication date if useful, and LinkedIn URL. The full LinkedIn article does not need to be copied here.</p>
